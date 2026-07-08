-- Add UPDATE policy for admins on the reports table
create policy "Admins can update reports"
  on reports for update
  using (
    exists (select 1 from profiles where id = auth.uid() and role = 'admin')
  );
