# Security

## Secret Handling
- `SUPABASE_SERVICE_ROLE_KEY` used only in server-side API routes — never in client bundles.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` is the only key exposed to the browser.
- Supabase Storage bucket for document uploads is private; files served via signed URLs generated server-side.

## Permission Model
**v1 (demo):** Open RLS policies — all reads and writes allowed. No login required. Safe only for non-sensitive demo data.
**After Lock-Down sprint:**
- Nurse: read/write own `staff_profiles`, `credential_documents`, `cpd_records` where `user_id = auth.uid()`.
- Manager: read all records in their department (department-scoped policy).
- HR/Admin: read all records; write verification_status only.
- Service role: used only in server API routes for audit log writes.

## Approved Tools Rule
Only the named tools in `AGENTIC_LAYER.md` may be invoked by any automated action. No raw `execute_any_sql` or `send_any_email` calls.

## Audit Principle
Every meaningful write (upload, update, delete, verify) appends an immutable row to `audit_logs`. Logs are never deleted. UI shows audit trail to managers.

## Stop and Get Help
If implementing signed URL expiry, HIPAA/PDPA data residency, or certificate tampering detection — stop and involve a qualified security reviewer before deploying.
