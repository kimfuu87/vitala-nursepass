# Agentic Layer

## Risk Levels & Actions

### Low Risk — Auto-execute
- Compute and render credential status badge on each page load
- Calculate compliance score per staff member and department
- Aggregate CPD points total for a staff member
- Flag documents as **Expiring Soon** in dashboard summary

### Medium Risk — Show draft, user confirms
- Generate expiry reminder email draft for a manager to review before sending
- Suggest a missing document prompt when a required slot has no record
- Pre-fill extracted expiry date from OCR with `review_status = unreviewed` — user accepts or corrects

### High Risk — Explicit approval required
- Send expiry reminder email to a nurse or manager
- Mark a document as **Verified** (HR or manager action, logged)
- Export compliance report (triggers file generation + download)

### Critical — Human only
- Delete a staff profile and all associated documents
- Bulk-delete records
- Any action affecting credentials used in a regulatory submission

## Named Tools (approved list)
- `compute_credential_status(staff_profile_id)` — returns status per document type
- `generate_expiry_reminder_email(staff_profile_id, document_type_id)` — draft only
- `export_compliance_report(department?)` — CSV generation
- `upload_document(staff_profile_id, document_type_id, file)` — stores file + metadata

## Audit Log Fields
`actor_email`, `action`, `target_table`, `target_id`, `diff` (before/after JSON), `ip_address`, `created_at`.
Every write to `credential_documents`, `cpd_records`, and `staff_profiles` appends a row.

## v1
Only Low-risk auto actions in v1. Medium/High introduced in Sprint 4.
