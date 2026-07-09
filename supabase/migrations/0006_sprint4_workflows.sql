create or replace function public.append_audit_log()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into audit_logs (user_id, actor_email, action, target_table, target_id, diff)
  values (auth.uid(), auth.jwt()->>'email', lower(tg_op), tg_table_name, coalesce(new.id, old.id),
    jsonb_build_object('before', case when tg_op <> 'INSERT' then to_jsonb(old) else null end,
                       'after', case when tg_op <> 'DELETE' then to_jsonb(new) else null end));
  return coalesce(new, old);
end; $$;

drop policy if exists "audit_logs_v1_read" on audit_logs;
create policy "audit_logs_owner_read" on audit_logs for select
using (user_id is null or auth.uid() = user_id);

insert into competency_items (id, name, category, department) values
('33333333-0003-0003-0003-000000000001','Medication administration safety','Clinical safety',null),
('33333333-0003-0003-0003-000000000002','Basic life support response','Emergency readiness',null),
('33333333-0003-0003-0003-000000000003','Infection prevention protocol','Clinical safety',null)
on conflict (id) do nothing;
