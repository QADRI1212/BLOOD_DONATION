-- ============================================================
-- Migration: Blood Request Notification Trigger
-- ============================================================
-- When a new blood request is created, this trigger inserts
-- a notification record for each active donor so they get
-- notified via the existing push notification pipeline.
--
-- The existing trigger `on_notification_created_send_push`
-- on the `notifications` table will then fire the Edge
-- Function to send push notifications.
-- ============================================================

-- Step 1: Create the trigger function
create or replace function public.handle_new_blood_request()
returns trigger
language plpgsql
security definer
as $$
declare
  donor record;
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
      id,
      user_id,
      title,
      body,
      type,
      is_read,
      related_id,
      related_type,
      channel_id,
      sound,
      created_at
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

  return new;
end;
$$;

-- Step 2: Drop existing trigger if any, then create
drop trigger if exists on_blood_request_created_notify_donors on public.blood_requests;

create trigger on_blood_request_created_notify_donors
  after insert on public.blood_requests
  for each row
  execute function public.handle_new_blood_request();
