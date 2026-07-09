-- ================================================================
-- Migration: Admin Manage Blood Requests Policy
-- ================================================================
-- This migration adds an RLS policy allowing admins full CRUD
-- access to the blood_requests table so they can view, manage,
-- and moderate all blood requests from the admin dashboard.
-- ================================================================

-- ================================================================
-- 1. RLS: Admins can manage blood_requests (full CRUD)
-- ================================================================
-- Uses the public.is_admin() security definer function created
-- in migration 20240704000002 to avoid RLS recursion.
drop policy if exists "Admins can manage blood requests" on public.blood_requests;

create policy "Admins can manage blood requests"
  on public.blood_requests for all
  using (public.is_admin());

-- ================================================================
-- Verify the new policy
-- ================================================================
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
from pg_policies
where tablename = 'blood_requests'
  and policyname = 'Admins can manage blood requests'
order by tablename, policyname;
