# Data Model

## document_types
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid nullable | |
| name | text | e.g. "APC / Nursing License" |
| has_expiry | boolean | false for IC, degree cert |
| is_required | boolean | |
| sort_order | int | display order |

## staff_profiles
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid nullable | owner at lock-down |
| full_name | text | |
| ic_number | text | |
| email | text | |
| role | text | Staff Nurse / Senior / Manager |
| department | text | |
| employment_status | text | Active / Inactive |

## credential_documents
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid nullable | |
| staff_profile_id | uuid FK → staff_profiles | |
| document_type_id | uuid FK → document_types | |
| file_url | text | Supabase Storage URL |
| file_name | text | |
| issue_date | date | |
| expiry_date | date | drives status badge |
| verification_status | text | Unverified / Verified / Flagged |
| verified_by | text | |
| verified_at | timestamptz | |
| notes | text | |
| extracted_expiry | date | **AI field** |
| extracted_expiry_source | text | e.g. "ocr-v1" |
| extracted_expiry_confidence | numeric | 0–1 |
| extracted_expiry_review_status | text | unreviewed / accepted / rejected |

**Status computation (server):**
- No row for type → **Missing**
- `has_expiry = false` and file present → **Complete**
- `expiry_date > today + 90 days` → **Valid**
- `expiry_date` within 90 days → **Expiring Soon**
- `expiry_date < today` → **Expired**

## cpd_records
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid nullable | |
| staff_profile_id | uuid FK | |
| course_name | text | |
| provider | text | |
| completion_date | date | |
| cpd_points | numeric | |
| certificate_url | text | |
| verification_status | text | |

## competency_items / competency_records
`competency_items`: name, category, department.
`competency_records`: staff_profile_id FK, competency_item_id FK, status (Not Assessed / Competent / Not Yet Competent), assessed_by, assessed_at.

## audit_logs
actor_email, action, target_table, target_id, diff (jsonb), ip_address. Append-only.

**RLS:** v1 = fully open (demo). Lock-Down sprint replaces with `auth.uid() = user_id`.
