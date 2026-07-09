export type CredentialStatus =
  | "Missing"
  | "Complete"
  | "Valid"
  | "Expiring Soon"
  | "Expired";

export function credentialStatus(
  hasExpiry: boolean,
  expiryDate?: string | null,
  hasFile = true,
  now = new Date(),
): CredentialStatus {
  if (!hasFile) return "Missing";
  if (!hasExpiry) return "Complete";
  if (!expiryDate) return "Missing";

  const expiry = new Date(`${expiryDate}T23:59:59Z`);
  const today = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()));
  if (expiry < today) return "Expired";
  const days = Math.ceil((expiry.getTime() - today.getTime()) / 86_400_000);
  return days <= 90 ? "Expiring Soon" : "Valid";
}

export const statusClass: Record<CredentialStatus, string> = {
  Missing: "status missing",
  Complete: "status complete",
  Valid: "status valid",
  "Expiring Soon": "status warning",
  Expired: "status expired",
};
