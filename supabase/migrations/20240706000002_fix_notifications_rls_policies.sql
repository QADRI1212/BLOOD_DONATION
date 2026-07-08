-- ============================================================
-- Migration: Fix notifications RLS INSERT policies
-- ============================================================
-- The `notifications` table only had SELECT and UPDATE policies.
-- When admins create announcements or when the app inserts
-- notification records, those inserts were rejected with 403.
--
-- This adds INSERT policies for:
--   1. Admins (can insert for any user)
--   2. Users (can insert their own notifications)
-- ============================================================

-- Step 0: Drop existing policies first to make this migration idempotent
drop policy if exists "Admins can insert notifications" on public.notifications;
drop policy if exists "Users can insert their own notifications" on public.notifications;

-- Step 1: Add INSERT policy for admins
-- Admins need to be able to create notification records for any user
-- (e.g., when broadcasting announcements via createAnnouncement())
create policy "Admins can insert notifications"
  on public.notifications for insert
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Step 2: Add INSERT policy for users to insert their own notifications
-- This allows system-triggered inserts that happen on behalf of the user
-- (e.g., when a blood request is matched to a donor)
create policy "Users can insert their own notifications"
  on public.notifications for insert
  with check (user_id = auth.uid());

-- Step 3: Verify the policies
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
from pg_policies
where tablename = 'notifications'
order by policyname;
