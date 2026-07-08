-- ============================================================
-- Fix: Add INSERT RLS policy for notifications table
-- ============================================================
-- The `notifications` table only had SELECT and UPDATE policies.
-- When admins create announcements via createAnnouncement(),
-- they insert notification records for every user.
-- Without an INSERT policy, those inserts are rejected with 403.
-- ============================================================

-- Add INSERT policy for admins
create policy "Admins can insert notifications"
  on public.notifications for insert
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role = 'admin'
    )
  );

-- Add INSERT policy for users to insert their own notifications
-- (in case any system-triggered inserts happen on behalf of the user)
create policy "Users can insert their own notifications"
  on public.notifications for insert
  with check (user_id = auth.uid());

-- Verify the policies
select
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
from pg_policies
where tablename = 'notifications'
order by policyname;
