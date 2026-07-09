# Architecture

## Stack
- **Frontend:** Next.js 14 (App Router) on Vercel
- **Database + Storage:** Supabase (Postgres, Row Level Security, Storage for file uploads)
- **Auth (later):** Supabase Auth — added in the Lock-Down sprint

## What to Build Now vs Later
**Now:** staff profiles, document slots, expiry-date entry, status badges, CPD point totals, compliance dashboard — all readable without login.
**Later:** login/signup, per-user data isolation, email reminders, report export, competency checklists, bulk import.

## Key User Action — Step by Step
1. Manager opens the staff list page (server-rendered, demo rows visible immediately).
2. Clicks **Add Staff** → fills the profile form → submitted to `POST /api/staff` → row written to `staff_profiles`.
3. Opens the new staff's detail page → sees credential slots for each required document type, all showing **Missing**.
4. Clicks **Upload** on the APC slot → selects file + enters expiry date → file stored in Supabase Storage, metadata written to `credential_documents`.
5. Page re-fetches the staff record; status badge recomputes server-side based on `expiry_date` vs today.
6. Manager sees **Expiring Soon** (≤ 90 days) or **Valid** (> 90 days) rendered immediately.

## Layer Order
1. **Data layer first** — tables, constraints, RLS policies, seed data.
2. **App logic** — status computation, form validation, file upload handling (all in server functions, not client JS).
3. **Smart features later** — expiry reminders, compliance scoring, eventual OCR — layered on top without touching the core.

## Core Without AI
Status computation is pure date arithmetic. All credential tracking works with zero AI; intelligence features are additive only.
