-- ================================================================
-- Migration: Notify Admins on New Blood Request
-- ================================================================
-- Updates the handle_new_blood_request() trigger function to also
-- insert notification records for all admin users when a new blood
-- request is created, so admins are notified alongside donors.
-- ================================================================

-- Replace the existing function to also notify admins
create or replace function public.handle_new_blood_request()
returns trigger
language plpgsql
security definer
as $$
declare
  donor record;
  admin_record record;
  notification_id uuid;
begin
  -- Loop through all active donors (users who are donors and available)
  for donor in
    select id, name
    from profiles
    where role = 'donor'
      and is_available = true
      and is_suspended = false
  loop
    notification_id := gen_random_uuid();

    insert into public.notifications (
      id, user_id, title, body, type, is_read,
      related_id, related_type, channel_id, sound, created_at
    ) values (
      notification_id,
      donor.id,
      'Urgent Blood Request',
      format('Blood group %s needed. %s unit(s) required.',
             new.blood_group, new.units),
      'emergency',
      false,
      new.id,
      'blood_request',
      'emergency_alerts',
      'default',
      now()
    );
  end loop;

  -- Loop through all admin users to notify them
  for admin_record in
    select id, name
    from profiles
    where role = 'admin'
      and is_suspended = false
  loop
    notification_id := gen_random_uuid();

    insert into public.notifications (
      id, user_id, title, body, type, is_read,
      related_id, related_type, channel_id, sound, created_at
    ) values (
      notification_id,
      admin_record.id,
      'New Blood Request',
      format('%s requested %s blood, %s unit(s).',
             coalesce(new.patient_name, 'A patient'), new.blood_group, new.units),
      'alert',
      false,
      new.id,
      'blood_request',
      'general',
      'default',
      now()
    );
  end loop;

  return new;
end;
$$;

-- ================================================================
-- Verify the updated function
-- ================================================================
select
  proname as function_name,
  prosrc as function_body
from pg_proc
where proname = 'handle_new_blood_request';
