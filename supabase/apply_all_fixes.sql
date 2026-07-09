-- ====================================================================
-- COMPLETE DATABASE SETUP — Smart Blood & Emergency Donor Network
-- ====================================================================
-- Run this entire script in the Supabase SQL Editor to create or
-- update the full database schema with all tables, RLS policies,
-- triggers, functions, indexes, storage buckets, and seed data.
--
-- Safe to re-run (idempotent) — uses CREATE IF NOT EXISTS and
-- DROP IF EXISTS / CREATE OR REPLACE throughout.
-- ====================================================================

-- ====================================================================
-- 0. EXTENSIONS
-- ====================================================================
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";
create extension if not exists pg_net with schema extensions;

-- ====================================================================
-- 1. TABLES
-- ====================================================================

-- 1.1 Profiles (extends Supabase Auth users)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  email text not null default '',
  phone text,
  blood_group text check (blood_group in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
  gender text check (gender in ('male','female','other')),
  age int check (age >= 1 and age <= 120),
  weight numeric(5,1) check (weight >= 30 and weight <= 300),
  city text,
  latitude numeric(10,7),
  longitude numeric(10,7),
  last_donation_date date,
  is_available boolean not null default false,
  is_suspended boolean not null default false,
  role text not null default 'donor' check (role in ('donor','patient','hospital','admin')),
  avatar_url text,
  fcm_token text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 1.2 Blood Requests
create table if not exists blood_requests (
  id uuid primary key default uuid_generate_v4(),
  patient_id uuid not null references profiles(id) on delete cascade,
  patient_name text,
  blood_group text not null check (blood_group in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
  units int not null default 1 check (units >= 1 and units <= 10),
  hospital_id uuid references hospitals(id) on delete set null,
  hospital_name text,
  latitude numeric(10,7) not null,
  longitude numeric(10,7) not null,
  address text,
  status text not null default 'pending' check (status in ('pending','accepted','completed','cancelled','closed')),
  priority text not null default 'normal' check (priority in ('normal','urgent','critical')),
  notes text,
  donor_id uuid references profiles(id) on delete set null,
  donor_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- 1.3 Donations
create table if not exists donations (
  id uuid primary key default uuid_generate_v4(),
  donor_id uuid not null references profiles(id) on delete cascade,
  donor_name text,
  blood_group text,
  hospital_id uuid references hospitals(id) on delete set null,
  hospital_name text,
  units int not null default 1 check (units >= 1),
  donation_date date not null default current_date,
  remarks text,
  created_at timestamptz not null default now()
);

-- 1.4 Hospitals
create table if not exists hospitals (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  address text,
  latitude numeric(10,7) not null,
  longitude numeric(10,7) not null,
  phone text,
  hours text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

-- 1.5 Blood Banks
create table if not exists blood_banks (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  address text,
  latitude numeric(10,7) not null,
  longitude numeric(10,7) not null,
  phone text,
  verified boolean not null default false,
  created_at timestamptz not null default now()
);

-- 1.6 Notifications
create table if not exists notifications (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  title text not null,
  body text not null,
  type text not null default 'general',
  is_read boolean not null default false,
  related_id text,
  related_type text,
  channel_id text default 'general',
  sound text default 'default',
  created_at timestamptz not null default now()
);

-- Add channel_id and sound columns if not exist (for older tables)
alter table notifications add column if not exists channel_id text default 'general';
alter table notifications add column if not exists sound text default 'default';

-- Update notification type check constraint
alter table notifications drop constraint if exists notifications_type_check;
alter table notifications add constraint notifications_type_check
  check (type in ('emergency', 'reminder', 'general', 'announcement', 'alert', 'update'));

-- 1.7 User Settings
create table if not exists user_settings (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade unique,
  dark_mode boolean not null default false,
  language text not null default 'en',
  notification_enabled boolean not null default true,
  emergency_alerts_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 1.8 Announcements
create table if not exists announcements (
  id uuid primary key default uuid_generate_v4(),
  title text not null,
  description text not null,
  created_at timestamptz not null default now()
);

-- 1.9 Saved Locations
create table if not exists saved_locations (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references profiles(id) on delete cascade,
  hospital_id uuid references hospitals(id) on delete cascade,
  blood_bank_id uuid references blood_banks(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(user_id, hospital_id)
);

-- 1.10 Reports
create table if not exists reports (
  id uuid primary key default uuid_generate_v4(),
  reporter_id uuid not null references profiles(id) on delete cascade,
  reported_user_id uuid references profiles(id) on delete cascade,
  reason text not null,
  status text not null default 'pending' check (status in ('pending','reviewed','resolved')),
  created_at timestamptz not null default now()
);

-- ====================================================================
-- 2. INDEXES
-- ====================================================================
create index if not exists idx_profiles_role on profiles(role);
create index if not exists idx_profiles_blood_group on profiles(blood_group);
create index if not exists idx_profiles_is_available on profiles(is_available);
create index if not exists idx_profiles_city on profiles(city);
create index if not exists idx_blood_requests_status on blood_requests(status);
create index if not exists idx_blood_requests_patient on blood_requests(patient_id);
create index if not exists idx_blood_requests_donor on blood_requests(donor_id);
create index if not exists idx_blood_requests_blood_group on blood_requests(blood_group);
create index if not exists idx_blood_requests_priority on blood_requests(priority);
create index if not exists idx_blood_requests_created on blood_requests(created_at desc);
create index if not exists idx_donations_donor on donations(donor_id);
create index if not exists idx_notifications_user on notifications(user_id);
create index if not exists idx_notifications_unread on notifications(user_id, is_read) where is_read = false;

-- ====================================================================
-- 3. SECURITY DEFINER FUNCTION (bypasses RLS recursion)
-- ====================================================================
create or replace function public.is_admin()
returns boolean
language sql security definer
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
    and role = 'admin'
  );
$$;

-- ====================================================================
-- 4. ROW LEVEL SECURITY (RLS)
-- ====================================================================

-- Enable RLS on all tables
alter table profiles enable row level security;
alter table blood_requests enable row level security;
alter table donations enable row level security;
alter table hospitals enable row level security;
alter table blood_banks enable row level security;
alter table notifications enable row level security;
alter table user_settings enable row level security;
alter table announcements enable row level security;
alter table saved_locations enable row level security;
alter table reports enable row level security;

-- 4.1 Profiles RLS -- using is_admin() for admin checks to avoid recursion
drop policy if exists "Users can view their own profile" on profiles;
create policy "Users can view their own profile"
  on profiles for select
  using (auth.uid() = id);

drop policy if exists "Donors are visible to everyone (for search)" on profiles;
create policy "Donors are visible to everyone (for search)"
  on profiles for select
  using (role = 'donor');

drop policy if exists "Users can update their own profile" on profiles;
create policy "Users can update their own profile"
  on profiles for update
  using (auth.uid() = id);

drop policy if exists "Users can insert their own profile" on profiles;
create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

drop policy if exists "Admins can read all profiles" on profiles;
create policy "Admins can read all profiles"
  on profiles for select
  using (public.is_admin());

drop policy if exists "Admins can update all profiles" on profiles;
create policy "Admins can update all profiles"
  on profiles for update
  using (public.is_admin());

-- 4.2 Blood Requests RLS
drop policy if exists "Anyone can read pending requests" on blood_requests;
create policy "Anyone can read pending requests"
  on blood_requests for select
  using (status = 'pending' or patient_id = auth.uid() or donor_id = auth.uid());

drop policy if exists "Patients can create requests" on blood_requests;
create policy "Patients can create requests"
  on blood_requests for insert
  with check (patient_id = auth.uid());

drop policy if exists "Patients can update their own requests" on blood_requests;
create policy "Patients can update their own requests"
  on blood_requests for update
  using (patient_id = auth.uid());

drop policy if exists "Donors can update to accept/complete" on blood_requests;
create policy "Donors can update to accept/complete"
  on blood_requests for update
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'donor')
  );

drop policy if exists "Admins can manage blood requests" on blood_requests;
create policy "Admins can manage blood requests"
  on blood_requests for all
  using (public.is_admin());

-- 4.3 Donations RLS
drop policy if exists "Donors can view their own donations" on donations;
create policy "Donors can view their own donations"
  on donations for select
  using (donor_id = auth.uid());

drop policy if exists "Donors can insert their own donations" on donations;
create policy "Donors can insert their own donations"
  on donations for insert
  with check (donor_id = auth.uid());

drop policy if exists "Admins can manage all donations" on donations;
create policy "Admins can manage all donations"
  on donations for all
  using (public.is_admin());

-- 4.4 Hospitals RLS
drop policy if exists "Anyone can view hospitals" on hospitals;
create policy "Anyone can view hospitals"
  on hospitals for select
  to authenticated
  using (verified = true);

drop policy if exists "Hospital managers can insert hospitals" on hospitals;
create policy "Hospital managers can insert hospitals"
  on hospitals for insert
  with check (
    exists (select 1 from profiles where id = auth.uid() and role = 'hospital')
  );

drop policy if exists "Admins can manage hospitals" on hospitals;
create policy "Admins can manage hospitals"
  on hospitals for all
  using (public.is_admin());

-- 4.5 Blood Banks RLS
drop policy if exists "Anyone can view blood banks" on blood_banks;
create policy "Anyone can view blood banks"
  on blood_banks for select
  to authenticated
  using (verified = true);

drop policy if exists "Hospital managers can insert blood banks" on blood_banks;
drop policy if exists "Authenticated users can insert blood banks" on blood_banks;
create policy "Hospital managers can insert blood banks"
  on blood_banks for insert
  with check (
    exists (select 1 from profiles where id = auth.uid() and role = 'hospital')
  );

drop policy if exists "Hospital managers can update blood banks" on blood_banks;
drop policy if exists "Authenticated users can update blood banks" on blood_banks;
create policy "Hospital managers can update blood banks"
  on blood_banks for update
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'hospital')
  );

drop policy if exists "Admins can manage blood banks" on blood_banks;
create policy "Admins can manage blood banks"
  on blood_banks for all
  using (public.is_admin());

-- 4.6 Notifications RLS
drop policy if exists "Users can view their own notifications" on notifications;
create policy "Users can view their own notifications"
  on notifications for select
  using (user_id = auth.uid());

drop policy if exists "Users can update their own notifications" on notifications;
create policy "Users can update their own notifications"
  on notifications for update
  using (user_id = auth.uid());

drop policy if exists "Admins can insert notifications" on notifications;
create policy "Admins can insert notifications"
  on notifications for insert
  with check (public.is_admin());

drop policy if exists "Users can insert their own notifications" on notifications;
create policy "Users can insert their own notifications"
  on notifications for insert
  with check (user_id = auth.uid());

-- 4.7 User Settings RLS
drop policy if exists "Users can manage their own settings" on user_settings;
create policy "Users can manage their own settings"
  on user_settings for all
  using (user_id = auth.uid());

-- 4.8 Announcements RLS
drop policy if exists "Anyone can view announcements" on announcements;
create policy "Anyone can view announcements"
  on announcements for select
  to authenticated
  using (true);

drop policy if exists "Admins can create announcements" on announcements;
create policy "Admins can create announcements"
  on announcements for insert
  with check (public.is_admin());

-- 4.9 Saved Locations RLS
drop policy if exists "Users can manage their saved locations" on saved_locations;
create policy "Users can manage their saved locations"
  on saved_locations for all
  using (user_id = auth.uid());

-- 4.10 Reports RLS
drop policy if exists "Users can create reports" on reports;
create policy "Users can create reports"
  on reports for insert
  with check (reporter_id = auth.uid());

drop policy if exists "Admins can read reports" on reports;
create policy "Admins can read reports"
  on reports for select
  using (public.is_admin());

drop policy if exists "Admins can update reports" on reports;
create policy "Admins can update reports"
  on reports for update
  using (public.is_admin());

-- ====================================================================
-- 5. TRIGGER FUNCTIONS
-- ====================================================================

-- 5.1 Auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    coalesce(new.raw_user_meta_data->>'role', 'donor')
  );
  insert into public.user_settings (user_id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 5.2 Auto-update updated_at
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger update_profiles_updated_at
  before update on profiles
  for each row execute function public.update_updated_at_column();

create trigger update_blood_requests_updated_at
  before update on blood_requests
  for each row execute function public.update_updated_at_column();

create trigger update_user_settings_updated_at
  before update on user_settings
  for each row execute function public.update_updated_at_column();

-- 5.3 Notify donors AND admins when a new blood request is created
create or replace function public.handle_new_blood_request()
returns trigger
language plpgsql
security definer
as $$
declare
  donor record;
  admin_record record;
  notification_id uuid;
begin
  -- Loop through all active donors
  for donor in
    select id, name
    from profiles
    where role = 'donor'
      and is_available = true
      and is_suspended = false
  loop
    notification_id := gen_random_uuid();

    insert into public.notifications (
      id, user_id, title, body, type, is_read,
      related_id, related_type, channel_id, sound, created_at
    ) values (
      notification_id,
      donor.id,
      'Urgent Blood Request',
      format('Blood group %s needed. %s unit(s) required.',
             new.blood_group, new.units),
      'emergency',
      false,
      new.id,
      'blood_request',
      'emergency_alerts',
      'default',
      now()
    );
  end loop;

  -- Loop through all admin users to notify them
  for admin_record in
    select id, name
    from profiles
    where role = 'admin'
      and is_suspended = false
  loop
    notification_id := gen_random_uuid();

    insert into public.notifications (
      id, user_id, title, body, type, is_read,
      related_id, related_type, channel_id, sound, created_at
    ) values (
      notification_id,
      admin_record.id,
      'New Blood Request',
      format('%s requested %s blood, %s unit(s).',
             coalesce(new.patient_name, 'A patient'),
             new.blood_group, new.units),
      'alert',
      false,
      new.id,
      'blood_request',
      'general',
      'default',
      now()
    );
  end loop;

  return new;
end;
$$;

drop trigger if exists on_blood_request_created_notify_donors on public.blood_requests;
create trigger on_blood_request_created_notify_donors
  after insert on public.blood_requests
  for each row
  execute function public.handle_new_blood_request();

-- 5.4 Send push notification when a notification is inserted
create or replace function public.handle_new_notification()
returns trigger
language plpgsql
security definer
as $$
declare
  function_url text := 'https://rwvbseupqfizbnynnocy.supabase.co/functions/v1/send-push-notification';
  anon_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dmJzZXVwcWZpemJueW5ub2N5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5MDQ1NjcsImV4cCI6MjA5ODQ4MDU2N30.T0_oABXn_gJWaTfTNyDsdGcZUIs75uJMds2CfXR6kew';
  payload jsonb;
begin
  payload := jsonb_build_object(
    'type', 'INSERT',
    'table', 'notifications',
    'schema', 'public',
    'record', jsonb_build_object(
      'id', new.id,
      'user_id', new.user_id,
      'title', new.title,
      'body', new.body,
      'type', new.type,
      'is_read', new.is_read,
      'related_id', new.related_id,
      'related_type', new.related_type,
      'created_at', new.created_at
    ),
    'old_record', null::jsonb
  );

  perform
    net.http_post(
      url := function_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || anon_key
      ),
      body := payload::text
    );

  return new;
exception
  when others then
    raise warning 'Failed to trigger push notification: %', sqlerrm;
    return new;
end;
$$;

drop trigger if exists on_notification_created_send_push on public.notifications;
create trigger on_notification_created_send_push
  after insert on public.notifications
  for each row
  execute function public.handle_new_notification();

-- ====================================================================
-- 6. STORAGE BUCKETS & POLICIES
-- ====================================================================
insert into storage.buckets (id, name, public)
values ('profile_images', 'profile_images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('hospital_images', 'hospital_images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;

drop policy if exists "Anyone can view profile images" on storage.objects;
create policy "Anyone can view profile images"
  on storage.objects for select
  using (bucket_id = 'profile_images');

drop policy if exists "Users can upload profile images" on storage.objects;
create policy "Users can upload profile images"
  on storage.objects for insert
  with check (
    bucket_id = 'profile_images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

drop policy if exists "Users can update their own profile images" on storage.objects;
create policy "Users can update their own profile images"
  on storage.objects for update
  using (
    bucket_id = 'profile_images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- ====================================================================
-- 7. SEED DATA
-- ====================================================================
insert into hospitals (name, address, latitude, longitude, phone, verified) values
  ('City General Hospital', '123 Healthcare Ave, New Delhi', 28.6139, 77.2090, '+91-11-23456789', true),
  ('Apollo Medical Center', '456 Wellness Rd, New Delhi', 28.5678, 77.2100, '+91-11-34567890', true),
  ('Fortis Healthcare', '789 Cure St, New Delhi', 28.6000, 77.2200, '+91-11-45678901', true)
on conflict do nothing;

insert into blood_banks (name, address, latitude, longitude, phone) values
  ('National Blood Bank', '100 Donor Lane, New Delhi', 28.6200, 77.2000, '+91-11-11111111'),
  ('Red Cross Blood Bank', '200 Save Life Rd, New Delhi', 28.5900, 77.2150, '+91-11-22222222')
on conflict do nothing;

-- ====================================================================
-- 8. VERIFICATION — view all policies
-- ====================================================================
select tablename, policyname, cmd, qual, with_check
from pg_policies
order by tablename, policyname;
