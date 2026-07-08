-- Add fcm_token column to profiles table for push notification tokens
alter table if exists profiles
  add column if not exists fcm_token text;

-- Add fcm_token column to the trigger function's insert if needed (it already doesn't reference it, so no change needed)
