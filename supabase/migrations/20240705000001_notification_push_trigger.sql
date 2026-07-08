-- ============================================================
-- Migration: Notification Push Trigger
-- ============================================================
-- This trigger sends push notifications via the Supabase
-- Edge Function `send-push-notification` whenever a new
-- notification is inserted into the `notifications` table.
-- It uses pg_net to make an async HTTP request so the
-- INSERT is not blocked by the push delivery.
--
-- Prerequisites:
--   1. Deploy the `send-push-notification` Edge Function
--   2. Enable the pg_net extension: CREATE EXTENSION IF NOT EXISTS pg_net;
--   3. Set environment secrets for Firebase credentials
-- ============================================================

-- Step 1: Enable pg_net extension for async HTTP requests
create extension if not exists pg_net with schema extensions;

-- Step 2: Create the trigger function
create or replace function public.handle_new_notification()
returns trigger
language plpgsql
security definer
as $$
declare
  function_url text := 'https://rwvbseupqfizbnynnocy.supabase.co/functions/v1/send-push-notification';
  anon_key text := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3dmJzZXVwcWZpemJueW5ub2N5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5MDQ1NjcsImV4cCI6MjA5ODQ4MDU2N30.T0_oABXn_gJWaTfTNyDsdGcZUIs75uJMds2CfXR6kew';
  payload jsonb;
begin
  -- Build the payload in the format expected by the Edge Function
  payload := jsonb_build_object(
    'type', 'INSERT',
    'table', 'notifications',
    'schema', 'public',
    'record', jsonb_build_object(
      'id', new.id,
      'user_id', new.user_id,
      'title', new.title,
      'body', new.body,
      'type', new.type,
      'is_read', new.is_read,
      'related_id', new.related_id,
      'related_type', new.related_type,
      'created_at', new.created_at
    ),
    'old_record', null::jsonb
  );

  -- Make async HTTP POST request to the Edge Function
  -- This will not block the INSERT transaction
  perform
    net.http_post(
      url := function_url,
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || anon_key
      ),
      body := payload::text
    );

  return new;
exception
  when others then
    -- Log warning but don't block the insert
    raise warning 'Failed to trigger push notification: %', sqlerrm;
    return new;
end;
$$;

-- Step 3: Drop existing trigger if any, then create
drop trigger if exists on_notification_created_send_push on public.notifications;

create trigger on_notification_created_send_push
  after insert on public.notifications
  for each row
  execute function public.handle_new_notification();

-- Step 4: Add channel_id and sound columns if not exist
-- These are used by the Flutter app to route notifications to the correct channel
alter table public.notifications
  add column if not exists channel_id text default 'general';

alter table public.notifications
  add column if not exists sound text default 'default';

-- Step 5: Update notification type check constraint to include all types
alter table public.notifications
  drop constraint if exists notifications_type_check;

alter table public.notifications
  add constraint notifications_type_check
  check (type in ('emergency', 'reminder', 'general', 'announcement', 'alert', 'update'));

-- ============================================================
-- NOTE: Before applying this migration, make sure:
--   1. Run: CREATE EXTENSION IF NOT EXISTS pg_net;
--   2. Deploy the send-push-notification Edge Function:
--      supabase functions deploy send-push-notification
-- ============================================================
