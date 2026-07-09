# Tasks & Sprints

## Sprint 1 — Database + Core Credential Engine
**Goal:** A working staff profile + document upload flow, viewable without login.

- [ ] Run migration SQL (all tables, seed data)
- [ ] Staff list page: shows seeded profiles, department filter, overall status chip
- [ ] Staff detail page: all document type slots listed, status badge per slot (Missing / Complete / Valid / Expiring Soon / Expired)
- [ ] Add Staff form: name, IC, role, department → persists to `staff_profiles`
- [ ] Upload Credential form: document type selector, file upload, expiry date → persists to `credential_documents` + Supabase Storage
- [ ] Edit/update expiry date on existing credential
- [ ] Status computation function (server-side, pure date logic)
- [ ] Handle all UI states: loading skeleton, empty slot, error toast, success confirmation
- [ ] Verify: seeded rows are editable/deletable (not display-only)

**Definition of Done:** A manager can add a new staff profile from scratch, upload an APC certificate with an expiry date 45 days away, and see the status badge render **Expiring Soon** — with the data confirmed in the Supabase table. No login required.

---

## Sprint 2 — CPD Tracker + Compliance Dashboard
**Goal:** CPD points log and facility-wide compliance overview.

- [ ] CPD record form: course name, provider, date, points, certificate upload
- [ ] CPD total displayed on staff detail page
- [ ] Compliance dashboard: counts by status across all staff
- [ ] Department filter on dashboard
- [ ] Expiring credentials list: next 30 / 60 / 90 days
- [ ] Delete credential document and CPD record (with confirm dialog)
- [ ] Audit log append on every write

**Definition of Done:** Dashboard shows live counts matching actual database rows; CPD total updates when a new record is added; an expired credential appears in the "Expiring in 30 days" list correctly.

---

## Sprint 3 — Lock It Down (Auth + RLS) ★ v1 Functional Milestone
**Goal:** Real users can sign up, own their data, and no one can see another user's records.

- [ ] Supabase Auth: email/password signup + login pages
- [ ] Assign `user_id = auth.uid()` on all new records
- [ ] Replace open v1 RLS policies with owner-scoped policies
- [ ] Manager role: department-scoped read access
- [ ] Protect all write API routes behind authenticated session check
- [ ] Migrate demo seed rows gracefully (assign to a demo account)
- [ ] Test: unauthenticated user cannot write; wrong-user cannot read another's records

**Definition of Done:** A second test account cannot see or modify records created by the first account. All writes require a valid session.

---

## Sprint 4 — Reminders, Reports, Competency
**Goal:** Proactive alerting and audit-ready exports.

- [ ] Expiry reminder email draft (manager reviews before send)
- [ ] Scheduled job: flag credentials expiring in 90 / 30 / 7 days
- [ ] Competency checklist: add items, mark Competent / Not Yet Competent per staff
- [ ] Compliance report CSV export (all staff, all statuses)
- [ ] HR verification flow: mark document Verified / Flagged
- [ ] Audit log viewer page for managers

**Definition of Done:** Manager can export a CSV of all staff statuses and open it in Excel showing correct expiry dates and statuses.

---

## Gantt (Sprint → Weeks)
```
Week 1:  Sprint 1 — DB + credential engine
Week 2:  Sprint 2 — CPD + dashboard
Week 3:  Sprint 3 — Auth lock-down  ← v1 functional milestone
Week 4:  Sprint 4 — Reminders + reports
```
