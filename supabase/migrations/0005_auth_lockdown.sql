do $$
declare t text;
begin
  foreach t in array array['staff_profiles','credential_documents','cpd_records','competency_items','competency_records'] loop
    execute format('drop policy if exists %I on %I', t || '_v1_read', t);
    execute format('drop policy if exists %I on %I', t || '_v1_write', t);
    execute format('create policy %I on %I for select using (user_id is null or auth.uid() = user_id)', t || '_owner_read', t);
    execute format('create policy %I on %I for insert with check (auth.uid() is not null and auth.uid() = user_id)', t || '_owner_insert', t);
    execute format('create policy %I on %I for update using (auth.uid() = user_id) with check (auth.uid() = user_id)', t || '_owner_update', t);
    execute format('create policy %I on %I for delete using (auth.uid() = user_id)', t || '_owner_delete', t);
  end loop;
end $$;

drop policy if exists "audit_logs_v1_write" on audit_logs;
create policy "audit_logs_no_direct_write" on audit_logs for insert with check (false);

drop policy if exists "credential_documents_v1_insert" on storage.objects;
create policy "credential_documents_owner_insert" on storage.objects for insert
with check (bucket_id = 'credential-documents' and auth.uid() is not null);
drop policy if exists "credential_documents_v1_update" on storage.objects;
create policy "credential_documents_owner_update" on storage.objects for update
using (bucket_id = 'credential-documents' and auth.uid() is not null);
drop policy if exists "credential_documents_v1_delete" on storage.objects;
create policy "credential_documents_owner_delete" on storage.objects for delete
using (bucket_id = 'credential-documents' and auth.uid() is not null);
