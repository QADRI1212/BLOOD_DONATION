-- =============================================================
-- Smart Blood & Emergency Donor Network
-- Supabase Migration Script
-- Run this in your Supabase SQL Editor (one-time setup)
-- =============================================================

-- 0. Extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- =============================================================
-- 1. TABLES
-- =============================================================

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
  type text not null default 'general' check (type in ('emergency','reminder','general','announcement')),
  is_read boolean not null default false,
  related_id text,
  related_type text,
  created_at timestamptz not null default now()
);

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

-- =============================================================
-- 2. INDEXES
-- =============================================================

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

-- =============================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- =============================================================

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

-- 3.1 Profiles RLS
create policy "Users can view their own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Donors are visible to everyone (for search)"
  on profiles for select
  using (role = 'donor');

create policy "Users can update their own profile"
  on profiles for update
  using (auth.uid() = id);

create policy "Users can insert their own profile"
  on profiles for insert
  with check (auth.uid() = id);

create policy "Admins can read all profiles"
  on profiles for select
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

create policy "Admins can update all profiles"
  on profiles for update
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- 3.2 Blood Requests RLS
create policy "Anyone can read pending requests"
  on blood_requests for select
  using (status = 'pending' or patient_id = auth.uid() or donor_id = auth.uid());

create policy "Patients can create requests"
  on blood_requests for insert
  with check (patient_id = auth.uid());

create policy "Patients can update their own requests"
  on blood_requests for update
  using (patient_id = auth.uid());

create policy "Donors can update to accept/complete"
  on blood_requests for update
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'donor')
  );

-- 3.3 Donations RLS
create policy "Users can view their own donations"
  on donations for select
  using (donor_id = auth.uid());

create policy "Donors can insert donations"
  on donations for insert
  with check (donor_id = auth.uid());

-- 3.4 Hospitals RLS
create policy "Anyone can view hospitals"
  on hospitals for select
  to authenticated
  using (true);

create policy "Hospital managers can insert hospitals"
  on hospitals for insert
  with check (
    exists (select 1 from profiles where id = auth.uid() and role = 'hospital')
  );

create policy "Admins can manage hospitals"
  on hospitals for all
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- 3.5 Blood Banks RLS
create policy "Anyone can view blood banks"
  on blood_banks for select
  to authenticated
  using (true);

create policy "Authenticated users can insert blood banks"
  on blood_banks for insert
  to authenticated
  with check (true);

create policy "Authenticated users can update blood banks"
  on blood_banks for update
  to authenticated
  using (true);

create policy "Admins can manage blood banks"
  on blood_banks for all
  using (public.is_admin());

-- 3.6 Notifications RLS
create policy "Users can view their own notifications"
  on notifications for select
  using (user_id = auth.uid());

create policy "Users can update their own notifications"
  on notifications for update
  using (user_id = auth.uid());

-- 3.7 User Settings RLS
create policy "Users can manage their own settings"
  on user_settings for all
  using (user_id = auth.uid());

-- 3.8 Announcements RLS
create policy "Anyone can view announcements"
  on announcements for select
  to authenticated
  using (true);

create policy "Admins can create announcements"
  on announcements for insert
  with check (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- 3.9 Saved Locations RLS
create policy "Users can manage their saved locations"
  on saved_locations for all
  using (user_id = auth.uid());

-- 3.10 Reports RLS
create policy "Users can create reports"
  on reports for insert
  with check (reporter_id = auth.uid());

create policy "Admins can read reports"
  on reports for select
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

create policy "Admins can update reports"
  on reports for update
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- =============================================================
-- 4. TRIGGERS
-- =============================================================

-- Auto-create profile on user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
    new.email,
    'donor'
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

-- Auto-update updated_at
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

-- =============================================================
-- 5. STORAGE BUCKETS
-- =============================================================

insert into storage.buckets (id, name, public)
values ('profile_images', 'profile_images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('hospital_images', 'hospital_images', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;

-- Storage RLS
create policy "Anyone can view profile images"
  on storage.objects for select
  using (bucket_id = 'profile_images');

create policy "Users can upload profile images"
  on storage.objects for insert
  with check (
    bucket_id = 'profile_images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "Users can update their own profile images"
  on storage.objects for update
  using (
    bucket_id = 'profile_images'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- =============================================================
-- 6. SEED DATA (sample hospitals and blood banks)
-- =============================================================

insert into hospitals (name, address, latitude, longitude, phone, verified) values
  ('City General Hospital', '123 Healthcare Ave, New Delhi', 28.6139, 77.2090, '+91-11-23456789', true),
  ('Apollo Medical Center', '456 Wellness Rd, New Delhi', 28.5678, 77.2100, '+91-11-34567890', true),
  ('Fortis Healthcare', '789 Cure St, New Delhi', 28.6000, 77.2200, '+91-11-45678901', true)
on conflict do nothing;

insert into blood_banks (name, address, latitude, longitude, phone) values
  ('National Blood Bank', '100 Donor Lane, New Delhi', 28.6200, 77.2000, '+91-11-11111111'),
  ('Red Cross Blood Bank', '200 Save Life Rd, New Delhi', 28.5900, 77.2150, '+91-11-22222222')
on conflict do nothing;

-- =============================================================
-- 7. REALTIME PUBLICATION
-- =============================================================

-- Enable realtime for key tables
-- Run these commands separately in the Supabase SQL Editor:
-- alter publication supabase_realtime add table blood_requests;
-- alter publication supabase_realtime add table notifications;
-- alter publication supabase_realtime add table profiles;
