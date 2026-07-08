-- =============================================================
-- Fix RLS infinite recursion in profiles table
-- =============================================================
-- The admin policies for profiles were querying the profiles table
-- inside the policy, causing infinite recursion.
-- Fix: Create a security definer function that bypasses RLS.

-- Create a security definer function to check if user is admin
-- This runs as the function owner (postgres), bypassing RLS on profiles
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

-- Drop the recursive admin policies
drop policy if exists "Admins can read all profiles" on profiles;
drop policy if exists "Admins can update all profiles" on profiles;

-- Recreate them using the security definer function
create policy "Admins can read all profiles"
  on profiles for select
  using (public.is_admin());

create policy "Admins can update all profiles"
  on profiles for update
  using (public.is_admin());

-- Also fix similar issues in other tables that reference profiles for admin checks
drop policy if exists "Admins can manage hospitals" on hospitals;

create policy "Admins can manage hospitals"
  on hospitals for all
  using (public.is_admin());

drop policy if exists "Admins can create announcements" on announcements;

create policy "Admins can create announcements"
  on announcements for insert
  with check (public.is_admin());

drop policy if exists "Admins can read reports" on reports;

create policy "Admins can read reports"
  on reports for select
  using (public.is_admin());
