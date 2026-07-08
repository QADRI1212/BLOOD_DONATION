-- =============================================================
-- FIX RLS POLICIES: Allow hospital managers to register hospitals
-- and allow authenticated users to register blood banks
-- =============================================================
-- Run this in your Supabase SQL Editor

-- 1. Allow hospital-role users to insert hospitals
create policy "Hospital managers can insert hospitals"
  on hospitals for insert
  with check (
    exists (select 1 from profiles where id = auth.uid() and role = 'hospital')
  );

-- 2. Allow hospital-role users to update/delete their own hospitals (optional)
-- (Currently hospitals don't have a manager_id field, so this is scoped to any hospital-role user)

-- 3. Add insert policy for blood_banks (currently missing - only has select)
create policy "Authenticated users can insert blood banks"
  on blood_banks for insert
  to authenticated
  with check (true);

-- 4. Allow hospital-role users to update blood banks (optional)
create policy "Authenticated users can update blood banks"
  on blood_banks for update
  to authenticated
  using (true);

-- 5. Add verified column to blood_banks table (required for admin approval workflow)
alter table blood_banks
  add column if not exists verified boolean not null default false;

-- 6. Allow admins to manage blood_banks (update/delete)
create policy "Admins can manage blood banks"
  on blood_banks for all
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );

-- Verify policies were created
select schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
from pg_policies
where tablename in ('hospitals', 'blood_banks')
order by tablename, policyname;
