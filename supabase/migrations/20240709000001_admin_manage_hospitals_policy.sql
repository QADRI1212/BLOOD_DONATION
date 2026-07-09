-- ================================================================
-- Migration: Admin Manage Hospitals & Blood Banks Policy
-- ================================================================
-- This migration adds:
--   1. RLS: Admins can manage hospitals (full CRUD) for the
--      "Manage Hospitals" admin feature.
--   2. RLS: Authenticated users can see only verified hospitals
--      (ensures public listing only shows approved entries).
--   3. RLS: Authenticated users can see only verified blood banks
--      (consistent with hospital policy).
-- ================================================================

-- ================================================================
-- 1. RLS: Admins can manage hospitals (full CRUD)
-- ================================================================
-- Uses the public.is_admin() security definer function created
-- in migration 20240704000002 to avoid RLS recursion.
drop policy if exists "Admins can manage hospitals" on public.hospitals;

create policy "Admins can manage hospitals"
  on public.hospitals for all
  using (public.is_admin());

-- ================================================================
-- 2. RLS: Authenticated users can view only verified hospitals
-- ================================================================
drop policy if exists "Authenticated users can view verified hospitals" on public.hospitals;

create policy "Authenticated users can view verified hospitals"
  on public.hospitals for select
  to authenticated
  using (verified = true);

-- ================================================================
-- 3. RLS: Authenticated users can view only verified blood banks
-- ================================================================
drop policy if exists "Authenticated users can view verified blood banks" on public.blood_banks;

create policy "Authenticated users can view verified blood banks"
  on public.blood_banks for select
  to authenticated
  using (verified = true);

-- ================================================================
-- Verify the new policies
-- ================================================================
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
from pg_policies
where tablename in ('hospitals', 'blood_banks')
  and policyname in (
    'Admins can manage hospitals',
    'Authenticated users can view verified hospitals',
    'Authenticated users can view verified blood banks'
  )
order by tablename, policyname;
