-- =============================================================
-- APPLY ALL FIXES: RLS policies + schema changes
-- =============================================================
-- Safe to re-run (all drops use IF EXISTS, all creates use IF NOT EXISTS)

-- =============================================================
-- 1. Ensure is_admin() function exists (from migration 20240704000002)
-- =============================================================
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

-- =============================================================
-- 2. Schema changes (from migration 20240708000001)
-- =============================================================
alter table public.profiles
  add column if not exists is_suspended boolean not null default false;

alter table public.blood_banks
  add column if not exists verified boolean not null default false;

alter table public.user_settings
  add column if not exists emergency_alerts_enabled boolean not null default true;

-- =============================================================
-- 3. HOSPITALS — RLS policies
-- =============================================================

-- Insert: Only hospital managers
drop policy if exists "Hospital managers can insert hospitals" on public.hospitals;
create policy "Hospital managers can insert hospitals"
  on public.hospitals for insert
  with check (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'hospital')
  );

-- Select: Admins can see ALL hospitals (for approval workflow)
drop policy if exists "Admins can manage hospitals" on public.hospitals;
create policy "Admins can manage hospitals"
  on public.hospitals for all
  using (public.is_admin());

-- Select: Authenticated users can see only verified hospitals
drop policy if exists "Authenticated users can view verified hospitals" on public.hospitals;
create policy "Authenticated users can view verified hospitals"
  on public.hospitals for select
  to authenticated
  using (verified = true);

-- =============================================================
-- 4. BLOOD BANKS — RLS policies
-- =============================================================

-- Insert: Only hospital managers (was "any authenticated user")
drop policy if exists "Hospital managers can insert blood banks" on public.blood_banks;
drop policy if exists "Authenticated users can insert blood banks" on public.blood_banks;
create policy "Hospital managers can insert blood banks"
  on public.blood_banks for insert
  with check (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'hospital')
  );

-- Update: Only hospital managers (was "any authenticated user")
drop policy if exists "Hospital managers can update blood banks" on public.blood_banks;
drop policy if exists "Authenticated users can update blood banks" on public.blood_banks;
create policy "Hospital managers can update blood banks"
  on public.blood_banks for update
  using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'hospital')
  );

-- Select: Admins can see ALL blood banks (for approval workflow)
drop policy if exists "Admins can manage blood banks" on public.blood_banks;
create policy "Admins can manage blood banks"
  on public.blood_banks for all
  using (public.is_admin());

-- Select: Authenticated users can see only verified blood banks
drop policy if exists "Authenticated users can view verified blood banks" on public.blood_banks;
create policy "Authenticated users can view verified blood banks"
  on public.blood_banks for select
  to authenticated
  using (verified = true);

-- =============================================================
-- 5. Verify policies
-- =============================================================
select tablename, policyname, cmd, qual, with_check
from pg_policies
where tablename in ('hospitals', 'blood_banks')
order by tablename, policyname;
