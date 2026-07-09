with ranked as (
  select
    id,
    row_number() over (
      partition by staff_profile_id, document_type_id
      order by created_at, id
    ) as duplicate_number
  from credential_documents
)
delete from credential_documents
where id in (select id from ranked where duplicate_number > 1);

create unique index if not exists credential_documents_one_per_slot
on credential_documents (staff_profile_id, document_type_id);

with ranked as (
  select
    id,
    row_number() over (
      partition by staff_profile_id, course_name, completion_date, cpd_points
      order by created_at, id
    ) as duplicate_number
  from cpd_records
)
delete from cpd_records
where id in (select id from ranked where duplicate_number > 1);

notify pgrst, 'reload schema';
