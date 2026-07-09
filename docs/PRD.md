# Vitala NursePass — Product Requirements

## Problem
Nursing teams manage credentials across paper files, spreadsheets, and email. APC renewals, BLS expiry, LJM certificates, and CPD targets go untracked until an audit or renewal crisis.

## Target Users
Staff nurses, senior nurses, nurse managers, HR, and nursing education officers in Malaysian hospitals.

## Core Objects
- **Staff Profile** — name, IC number, role, department, employment status
- **Credential Document** — document type, uploaded file, issue date, expiry date, verification status
- **Document Type** — IC, Nursing Diploma/Degree, LJM Certificate, APC/License, BLS, ACLS, CPD Certificate
- **CPD Record** — course name, provider, date, points, certificate upload
- **Competency Record** — checklist item, assessed status, assessor, date

## MVP Must-Haves (v1)
- [ ] Add a staff profile (name, IC, role, department)
- [ ] Upload a credential document per document type slot
- [ ] Enter and edit expiry dates
- [ ] Auto-compute per-document status: **Missing / Valid / Expiring Soon / Expired**
- [ ] Staff detail page showing all credential slots and their statuses
- [ ] Staff list dashboard with overall compliance at a glance
- [ ] All screens viewable without login (demo-first)
- [ ] Every form persists to the database; UI reflects saved state immediately

## Non-Goals (v1)
Payroll, patient records, EMR integration, CPD marketplace, certificate OCR, mobile app store, full roster system, automated SMS/WhatsApp.

## Success Criterion
A nurse manager adds a new staff profile, uploads their APC and BLS certificates with expiry dates, and the dashboard immediately shows **Expiring Soon** for a certificate due in 60 days and **Valid** for one due in 200 days — without any login required.
