-- Intentional product reset: keep accounts/plans, remove all operational records.
delete from competency_records;
delete from cpd_records;
delete from credential_documents;
delete from staff_profiles;
delete from audit_logs;

-- Personal workspaces always have exactly one private self-profile.
insert into staff_profiles (user_id, full_name, email, role, department, employment_status)
select id, coalesce(display_name, split_part(email,'@',1)), email, 'Nurse', 'Personal', 'Active'
from profiles where workspace_type = 'personal';
delete from audit_logs;

-- Remove demo-readable policies and enforce strict ownership.
do $$
declare t text;
begin
  foreach t in array array['staff_profiles','credential_documents','cpd_records','competency_records'] loop
    execute format('drop policy if exists %I on %I', t || '_owner_read', t);
    execute format('create policy %I on %I for select using (auth.uid() = user_id)', t || '_owner_read', t);
  end loop;
end $$;

drop policy if exists "audit_logs_owner_read" on audit_logs;
create policy "audit_logs_owner_read" on audit_logs for select using (auth.uid() = user_id);
notify pgrst, 'reload schema';
