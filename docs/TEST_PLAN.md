# Test Plan

## Core Success Scenario (manual)
1. Open the app homepage — staff list loads with seeded demo profiles. No login prompt.
2. Click **Add Staff** → enter: Name = "Ahmad Farid", IC = "900101-01-1234", Role = "Staff Nurse", Department = "Medical Ward" → Submit.
3. Confirm: Ahmad Farid appears in the staff list.
4. Click Ahmad Farid → detail page shows all document type slots with status **Missing**.
5. Click **Upload** on APC slot → select any PDF → enter expiry date = today + 45 days → Submit.
6. Confirm: APC slot now shows **Expiring Soon** badge. File link is accessible.
7. Click **Upload** on BLS slot → enter expiry date = today + 200 days → Submit.
8. Confirm: BLS slot shows **Valid**.
9. Click **Upload** on IC slot (no expiry) → Submit.
10. Confirm: IC slot shows **Complete**.
11. Leave Nursing Diploma slot untouched → confirms it stays **Missing**.
12. Open Supabase table view → confirm rows exist in `staff_profiles` and `credential_documents`.

## Empty State Tests
- New staff with zero documents: all slots show **Missing**, no JS errors.
- Department with no staff: dashboard shows "No staff in this department" message, not a blank screen.

## Error State Tests
- Submit Add Staff form with blank name → inline validation error, no row created.
- Upload a file > 10 MB → error toast "File too large", no partial record written.
- Enter an expiry date in the past → system accepts it and renders **Expired** (valid scenario).
- Supabase offline (simulate): page shows error banner, not a white screen.

## Status Logic Tests
| expiry_date | Expected Status |
|---|---|
| null (has_expiry = false, file present) | Complete |
| No record | Missing |
| Today + 200 days | Valid |
| Today + 45 days | Expiring Soon |
| Today − 1 day | Expired |

## CPD Tests
- Add 3 CPD records for one staff member → total points on profile = sum of all three.
- Delete one CPD record → total updates immediately.

## Not Done Until
- Every button triggers a real DB write confirmed in Supabase.
- Refreshing the page shows the same data (no localStorage-only state).
- No Supabase service role key visible in browser network tab.
