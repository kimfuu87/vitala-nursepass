# Intelligence Layer

## Messy Inputs
- Uploaded PDFs/images with expiry dates buried in text
- Managers typing expiry dates in varied formats (DD/MM/YY, Jan 2025, etc.)
- CPD points logged without provider validation

## Auto-Structure (v1 — rule-based only)
Expiry status is computed deterministically from `expiry_date` vs today:
```json
{
  "staff_id": "uuid",
  "document_type": "APC / Nursing License",
  "expiry_date": "2024-12-31",
  "days_remaining": 18,
  "status": "Expiring Soon",
  "computed_at": "2024-12-13T08:00:00Z"
}
```

## Events to Track
- Document uploaded (type, staff, who uploaded)
- Expiry date entered or changed
- Verification status changed
- CPD record added
- Status badge rendered as Expiring Soon or Expired

## Scoring Rules (v1 — rule-based)
- Staff compliance score = (required docs with Valid/Complete status) ÷ (total required doc types) × 100
- Department score = average of staff compliance scores
- CPD progress = total CPD points this year ÷ annual target (default 15 points)

## What Gets Ranked
- Staff list sorted by lowest compliance score first
- Credentials sorted by soonest expiry first

## v1 vs Later
**v1:** All scoring is pure arithmetic — no AI involved.
**Later:** OCR extraction of expiry dates from uploaded files → stores value in `extracted_expiry` + source + confidence + review_status; human confirms before `expiry_date` is updated.
