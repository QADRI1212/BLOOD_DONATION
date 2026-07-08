-- ================================================================
-- Migration: Consolidate Schema — Merge standalone fix scripts
-- ================================================================
-- This migration consolidates schema changes from the standalone
-- fix scripts that were never migrated into proper numbered files:
--
--   supabase/fix_suspension_column.sql
--   supabase/fix_rls_policies.sql
--   supabase/fix_notifications_rls.sql
--
-- After this migration, those standalone scripts are superseded
-- and should no longer be applied manually.
--
-- Changes included:
--   1. Add profiles.is_suspended column
--   2. Add blood_banks.verified column
--   3. Add user_settings.emergency_alerts_enabled column
--   4. RLS: Hospital managers can insert hospitals
--   5. RLS: Authenticated users can insert/update blood banks
--   6. RLS: Admins can manage blood banks (uses public.is_admin())
-- ================================================================

-- ================================================================
-- 1. Add is_suspended column to profiles
-- ================================================================
-- Used by the admin suspension workflow and the blood-request
-- notification trigger (which excludes suspended donors).
alter table public.profiles
  add column if not exists is_suspended boolean not null default false;

-- ================================================================
-- 2. Add verified column to blood_banks
-- ================================================================
-- Required for the admin approval workflow for blood banks.
alter table public.blood_banks
  add column if not exists verified boolean not null default false;

-- ================================================================
-- 3. Add emergency_alerts_enabled column to user_settings
-- ================================================================
-- Allows users to opt out of emergency alert notifications
-- (mapped by the Dart UserSettingsDto model).
alter table public.user_settings
  add column if not exists emergency_alerts_enabled boolean not null default true;

-- ================================================================
-- 4. RLS: Hospital managers can insert hospitals
-- ================================================================
drop policy if exists "Hospital managers can insert hospitals" on public.hospitals;

create policy "Hospital managers can insert hospitals"
  on public.hospitals for insert
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'hospital'
    )
  );

-- ================================================================
-- 5. RLS: Authenticated users can insert blood banks
-- ================================================================
drop policy if exists "Authenticated users can insert blood banks" on public.blood_banks;

create policy "Authenticated users can insert blood banks"
  on public.blood_banks for insert
  to authenticated
  with check (true);

-- ================================================================
-- 6. RLS: Authenticated users can update blood banks
-- ================================================================
drop policy if exists "Authenticated users can update blood banks" on public.blood_banks;

create policy "Authenticated users can update blood banks"
  on public.blood_banks for update
  to authenticated
  using (true);

-- ================================================================
-- 7. RLS: Admins can manage blood banks (full CRUD)
-- ================================================================
-- Uses the public.is_admin() security definer function created
-- in migration 20240704000002 to avoid RLS recursion.
drop policy if exists "Admins can manage blood banks" on public.blood_banks;

create policy "Admins can manage blood banks"
  on public.blood_banks for all
  using (public.is_admin());

-- ================================================================
-- Verify the changes
-- ================================================================
select
  column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'public'
  and (
    (table_name = 'profiles' and column_name = 'is_suspended')
    or (table_name = 'blood_banks' and column_name = 'verified')
    or (table_name = 'user_settings' and column_name = 'emergency_alerts_enabled')
  )
order by table_name, column_name;

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
    'Hospital managers can insert hospitals',
    'Authenticated users can insert blood banks',
    'Authenticated users can update blood banks',
    'Admins can manage blood banks'
  )
order by tablename, policyname;
