-- ================================================================
-- Migration: Add missing columns to donations table
-- ================================================================
-- The Donation model in the Flutter app expects these columns:
--   id, donor_id, donor_name, blood_group, hospital_id,
--   hospital_name, units, donation_date, remarks, created_at
--
-- This migration ensures all columns exist so donation records
-- created by the auto-recording logic in completeRequest() persist
-- and are visible in the donation history screen.
-- ================================================================

-- Step 1: Create the donations table if it doesn't already exist
create table if not exists public.donations (
  id uuid not null default gen_random_uuid() primary key,
  donor_id uuid not null references public.profiles(id) on delete cascade,
  units integer not null default 1,
  donation_date timestamptz not null default now(),
  remarks text,
  created_at timestamptz not null default now()
);

-- Step 2: Add columns that the Donation model expects (if missing)
alter table public.donations
  add column if not exists donor_name text;

alter table public.donations
  add column if not exists blood_group text;

alter table public.donations
  add column if not exists donation_date timestamptz not null default now();

alter table public.donations
  add column if not exists hospital_name text;

-- Note: 'created_at' already has a default in the CREATE TABLE above,
-- but in case the table already existed without it:
alter table public.donations
  add column if not exists created_at timestamptz not null default now();

-- Add hospital_id FK in a DO block to gracefully handle the case
-- where the hospitals table might not exist yet.
do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'donations' and column_name = 'hospital_id'
  ) then
    execute 'alter table public.donations add column hospital_id uuid references public.hospitals(id) on delete set null';
  end if;
exception
  when undefined_table then
    raise notice 'hospitals table does not exist yet, skipping hospital_id FK';
end;
$$;

-- Step 3: Enable Row Level Security (idempotent)
alter table public.donations enable row level security;

-- Step 4: Drop existing policies first to avoid conflicts
drop policy if exists "Donors can view their own donations" on public.donations;
drop policy if exists "Donors can insert their own donations" on public.donations;
drop policy if exists "Admins can manage all donations" on public.donations;

-- Step 5: RLS policies

-- Donors can view only their own donation history
create policy "Donors can view their own donations"
  on public.donations for select
  using (donor_id = auth.uid());

-- Donors (or the system acting on their behalf) can insert their own donations
-- This allows the auto-recording logic in completeRequest() to work.
create policy "Donors can insert their own donations"
  on public.donations for insert
  with check (donor_id = auth.uid());

-- Admins have full CRUD access to donations
create policy "Admins can manage all donations"
  on public.donations for all
  using (public.is_admin());

-- Step 6: Verify the results
select
  column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public' and table_name = 'donations'
order by ordinal_position;

select *
from pg_policies
where tablename = 'donations'
order by policyname;
