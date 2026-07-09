create or replace function public.append_audit_log()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into audit_logs (action, target_table, target_id, diff)
  values (
    lower(tg_op),
    tg_table_name,
    coalesce(new.id, old.id),
    jsonb_build_object('before', case when tg_op <> 'INSERT' then to_jsonb(old) else null end,
                       'after', case when tg_op <> 'DELETE' then to_jsonb(new) else null end)
  );
  return coalesce(new, old);
end;
$$;

drop trigger if exists audit_staff_profiles on staff_profiles;
create trigger audit_staff_profiles after insert or update or delete on staff_profiles
for each row execute function append_audit_log();

drop trigger if exists audit_credential_documents on credential_documents;
create trigger audit_credential_documents after insert or update or delete on credential_documents
for each row execute function append_audit_log();

drop trigger if exists audit_cpd_records on cpd_records;
create trigger audit_cpd_records after insert or update or delete on cpd_records
for each row execute function append_audit_log();
