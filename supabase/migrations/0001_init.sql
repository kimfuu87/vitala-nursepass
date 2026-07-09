create table if not exists document_types (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  created_at timestamptz not null default now(),
  name text not null,
  has_expiry boolean not null default true,
  is_required boolean not null default true,
  sort_order int not null default 0
);

alter table document_types enable row level security;
drop policy if exists "document_types_v1_read" on document_types;
create policy "document_types_v1_read" on document_types for select using (true);
drop policy if exists "document_types_v1_write" on document_types;
create policy "document_types_v1_write" on document_types for all using (true) with check (true);

insert into document_types (id, name, has_expiry, is_required, sort_order) values
  ('11111111-0001-0001-0001-000000000001', 'IC (Identity Card)', false, true, 1),
  ('11111111-0001-0001-0001-000000000002', 'Nursing Diploma / Degree Certificate', false, true, 2),
  ('11111111-0001-0001-0001-000000000003', 'LJM Certificate', true, true, 3),
  ('11111111-0001-0001-0001-000000000004', 'APC / Nursing License', true, true, 4),
  ('11111111-0001-0001-0001-000000000005', 'BLS Certificate', true, true, 5),
  ('11111111-0001-0001-0001-000000000006', 'ACLS Certificate', true, false, 6),
  ('11111111-0001-0001-0001-000000000007', 'CPD Certificate', true, false, 7)
on conflict (id) do nothing;

create table if not exists staff_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  created_at timestamptz not null default now(),
  full_name text not null,
  ic_number text,
  email text,
  role text not null default 'Staff Nurse',
  department text not null,
  employment_status text not null default 'Active'
);

alter table staff_profiles enable row level security;
drop policy if exists "staff_profiles_v1_read" on staff_profiles;
create policy "staff_profiles_v1_read" on staff_profiles for select using (true);
drop policy if exists "staff_profiles_v1_write" on staff_profiles;
create policy "staff_profiles_v1_write" on staff_profiles for all using (true) with check (true);

insert into staff_profiles (id, full_name, ic_number, email, role, department, employment_status) values
  ('22222222-0002-0002-0002-000000000001', 'Nur Farah Amalina binti Razak', '921104-14-5678', 'farah.amalina@hospital.my', 'Staff Nurse', 'Medical Ward', 'Active'),
  ('22222222-0002-0002-0002-000000000002', 'Priya d/o Subramaniam', '880315-08-1234', 'priya.sub@hospital.my', 'Senior Staff Nurse', 'ICU', 'Active'),
  ('22222222-0002-0002-0002-000000000003', 'Lee Mei Ling', '950720-12-4321', 'meiling.lee@hospital.my', 'Staff Nurse', 'Emergency', 'Active'),
  ('22222222-0002-0002-0002-000000000004', 'Mohammad Hafiz bin Kamal', '870610-03-9876', 'hafiz.kamal@hospital.my', 'Nurse Manager', 'Medical Ward', 'Active'),
  ('22222222-0002-0002-0002-000000000005', 'Siti Hajar binti Mohd Noor', '991230-11-6543', 'sitihajar@hospital.my', 'Staff Nurse', 'Surgical Ward', 'Active')
on conflict (id) do nothing;

create table if not exists credential_documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  created_at timestamptz not null default now(),
  staff_profile_id uuid not null references staff_profiles(id) on delete cascade,
  document_type_id uuid not null references document_types(id),
  file_url text,
  file_name text,
  issue_date date,
  expiry_date date,
  verification_status text not null default 'Unverified',
  verified_by text,
  verified_at timestamptz,
  notes text,
  extracted_expiry date,
  extracted_expiry_source text,
  extracted_expiry_confidence numeric,
  extracted_expiry_review_status text default 'unreviewed'
);

alter table credential_documents enable row level security;
drop policy if exists "credential_documents_v1_read" on credential_documents;
create policy "credential_documents_v1_read" on credential_documents for select using (true);
drop policy if exists "credential_documents_v1_write" on credential_documents;
create policy "credential_documents_v1_write" on credential_documents for all using (true) with check (true);

insert into credential_documents (staff_profile_id, document_type_id, file_url, file_name, issue_date, expiry_date, verification_status) values
  ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000001', '/demo/ic_farah.pdf', 'IC_Farah.pdf', '2010-01-01', null, 'Verified'),
  ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000004', '/demo/apc_farah.pdf', 'APC_Farah_2024.pdf', '2024-01-01', '2024-12-31', 'Verified'),
  ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000005', '/demo/bls_farah.pdf', 'BLS_Farah.pdf', '2023-06-01', '2025-06-01', 'Unverified'),
  ('22222222-0002-0002-0002-000000000002', '11111111-0001-0001-0001-000000000001', '/demo/ic_priya.pdf', 'IC_Priya.pdf', '2008-03-15', null, 'Verified'),
  ('22222222-0002-0002-0002-000000000002', '11111111-0001-0001-0001-000000000004', '/demo/apc_priya.pdf', 'APC_Priya_2024.pdf', '2024-01-01', '2025-03-31', 'Verified'),
  ('22222222-0002-0002-0002-000000000002', '11111111-0001-0001-0001-000000000006', '/demo/acls_priya.pdf', 'ACLS_Priya.pdf', '2023-09-01', '2025-09-01', 'Verified'),
  ('22222222-0002-0002-0002-000000000003', '11111111-0001-0001-0001-000000000004', '/demo/apc_meiling.pdf', 'APC_MeiLing.pdf', '2023-01-01', '2024-12-15', 'Unverified'),
  ('22222222-0002-0002-0002-000000000004', '11111111-0001-0001-0001-000000000001', '/demo/ic_hafiz.pdf', 'IC_Hafiz.pdf', '2007-06-10', null, 'Verified'),
  ('22222222-0002-0002-0002-000000000004', '11111111-0001-0001-0001-000000000003', '/demo/ljm_hafiz.pdf', 'LJM_Hafiz.pdf', '2022-01-01', '2025-01-01', 'Verified'),
  ('22222222-0002-0002-0002-000000000005', '11111111-0001-0001-0001-000000000005', '/demo/bls_siti.pdf', 'BLS_Siti.pdf', '2022-11-01', '2024-11-01', 'Unverified')
on conflict (id) do nothing;

create table if not exists cpd_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  created_at timestamptz not null default now(),
  staff_profile_id uuid not null references staff_profiles(id) on delete cascade,
  course_name text not null,
  provider text,
  completion_date date not null,
  cpd_points numeric not null default 0,
  certificate_url text,
  certificate_file_name text,
  verification_status text not null default 'Unverified'
);

alter table cpd_records enable row level security;
drop policy if exists "cpd_records_v1_read" on cpd_records;
create policy "cpd_records_v1_read" on cpd_records for select using (true);
drop policy if exists "cpd_records_v1_write" on cpd_records;
create policy "cpd_records_v1_write" on cpd_records for all using (true) with check (true);

insert into cpd_records (staff_profile_id, course_name, provider, completion_date, cpd_points, verification_status) values
  ('22222222-0002-0002-0002-000000000001', 'Wound Care Management', 'Hospital Education Dept', '2024-03-10', 4, 'Verified'),
  ('22222222-0002-0002-0002-000000000001', 'Patient Safety Seminar', 'MNA', '2024-07-20', 3, 'Verified'),
  ('22222222-0002-0002-0002-000000000002', 'Critical Care Nursing Update', 'MSICM', '2024-05-15', 6, 'Verified'),
  ('22222222-0002-0002-0002-000000000003', 'Infection Control Workshop', 'Hospital Education Dept', '2024-02-08', 2, 'Unverified'),
  ('22222222-0002-0002-0002-000000000005', 'Medication Safety', 'MOH', '2024-09-01', 3, 'Verified')
on conflict (id) do nothing;

create table if not exists competency_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  created_at timestamptz not null default now(),
  name text not null,
  category text not null,
  department text
);

alter table competency_items enable row level security;
drop policy if exists "competency_items_v1_read" on competency_items;
create policy "competency_items_v1_read" on competency_items for select using (true);
drop policy if exists "competency_items_v1_write" on competency_items;
create policy "competency_items_v1_write" on competency_items for all using (true) with check (true);

create table if not exists competency_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  created_at timestamptz not null default now(),
  staff_profile_id uuid not null references staff_profiles(id) on delete cascade,
  competency_item_id uuid not null references competency_items(id),
  status text not null default 'Not Assessed',
  assessed_by text,
  assessed_at date,
  notes text
);

alter table competency_records enable row level security;
drop policy if exists "competency_records_v1_read" on competency_records;
create policy "competency_records_v1_read" on competency_records for select using (true);
drop policy if exists "competency_records_v1_write" on competency_records;
create policy "competency_records_v1_write" on competency_records for all using (true) with check (true);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  created_at timestamptz not null default now(),
  actor_email text,
  action text not null,
  target_table text not null,
  target_id uuid,
  diff jsonb,
  ip_address text
);

alter table audit_logs enable row level security;
drop policy if exists "audit_logs_v1_read" on audit_logs;
create policy "audit_logs_v1_read" on audit_logs for select using (true);
drop policy if exists "audit_logs_v1_write" on audit_logs;
create policy "audit_logs_v1_write" on audit_logs for all using (true) with check (true);