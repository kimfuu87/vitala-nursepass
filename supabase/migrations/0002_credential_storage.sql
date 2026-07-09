insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'credential-documents',
  'credential-documents',
  false,
  10485760,
  array['application/pdf', 'image/jpeg', 'image/png']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "credential_documents_v1_select" on storage.objects;
create policy "credential_documents_v1_select"
on storage.objects for select using (bucket_id = 'credential-documents');

drop policy if exists "credential_documents_v1_insert" on storage.objects;
create policy "credential_documents_v1_insert"
on storage.objects for insert with check (bucket_id = 'credential-documents');

drop policy if exists "credential_documents_v1_update" on storage.objects;
create policy "credential_documents_v1_update"
on storage.objects for update using (bucket_id = 'credential-documents');

drop policy if exists "credential_documents_v1_delete" on storage.objects;
create policy "credential_documents_v1_delete"
on storage.objects for delete using (bucket_id = 'credential-documents');
