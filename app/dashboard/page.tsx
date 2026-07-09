import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { credentialStatus, statusClass, type CredentialStatus } from "@/lib/credentials";
import { signOut } from "@/app/auth/actions";
import { redirect } from "next/navigation";

export const dynamic = "force-dynamic";

export default async function Home({ searchParams }: { searchParams: Promise<{ department?: string; saved?: string }> }) {
  const params = await searchParams;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase.from("profiles").select("*").eq("id", user.id).single();
  if (!profile?.workspace_type) redirect("/onboarding");
  const [{ data: staff, error }, { data: types }, { data: docs }] = await Promise.all([
    supabase.from("staff_profiles").select("*").order("full_name"),
    supabase.from("document_types").select("*").eq("is_required", true).order("sort_order"),
    supabase.from("credential_documents").select("*"),
  ]);
  if (error) return <main className="shell"><div className="error-banner">Unable to load staff: {error.message}</div></main>;

  const departments = [...new Set((staff ?? []).map((item) => item.department))].sort();
  const visible = params.department ? (staff ?? []).filter((item) => item.department === params.department) : staff ?? [];
  const rows = visible.map((person) => {
    const statuses = (types ?? []).map((type) => {
      const doc = (docs ?? []).find((item) => item.staff_profile_id === person.id && item.document_type_id === type.id);
      return credentialStatus(type.has_expiry, doc?.expiry_date, Boolean(doc));
    });
    const complete = statuses.filter((status) => status === "Valid" || status === "Complete").length;
    const priority: CredentialStatus = statuses.includes("Expired") ? "Expired" : statuses.includes("Expiring Soon") ? "Expiring Soon" : statuses.includes("Missing") ? "Missing" : "Valid";
    return { ...person, score: types?.length ? Math.round((complete / types.length) * 100) : 0, priority };
  }).sort((a, b) => a.score - b.score);

  return <main className="shell">
    <header className="workspace-head"><div><p className="eyebrow">{profile.workspace_type==="personal"?"My credential wallet":"Team credential command centre"}</p><h1>Good day, {profile.display_name??user.email?.split("@")[0]}</h1><p>{profile.workspace_type==="personal"?"Keep your professional records current and ready.":"Here is what needs attention across your nursing team."}</p></div>{profile.workspace_type==="team"&&<Link className="button primary" href="/staff/new">+ Add staff</Link>}</header>
    {params.saved && <div className="success-banner">Changes saved successfully.</div>}
    <div className="plan-banner"><div><span>{profile.plan==="trial"?"Free trial":profile.plan.replace("_"," ")}</span><strong>{profile.plan==="trial"?`${Math.max(0,Math.ceil((new Date(profile.trial_ends_at).getTime()-Date.now())/86400000))} days remaining`:"Active plan"}</strong></div><Link className="button" href="/pricing">View plans</Link></div>
    <nav className="workspace-nav"><Link className="active" href="/dashboard">Overview</Link>{profile.workspace_type==="team"&&<Link href="/competencies">Competency</Link>}<Link href="/verify">Document review</Link><Link href="/reminders">Reminders</Link>{profile.workspace_type==="team"&&<Link href="/audit">Audit trail</Link>}<a href="/api/reports">Export CSV</a><form action={signOut}><button>Sign out</button></form></nav>
    <section className="metrics"><article><span>{profile.workspace_type==="personal"?"My profile":"Active staff"}</span><strong>{staff?.length ?? 0}</strong></article><article><span>Expiring soon</span><strong>{rows.filter((row) => row.priority === "Expiring Soon").length}</strong></article><article><span>Needs attention</span><strong>{rows.filter((row) => ["Expired", "Missing"].includes(row.priority)).length}</strong></article></section>
    <section className="panel"><div className="panel-head"><div><h2>{profile.workspace_type==="personal"?"My professional record":"Team compliance"}</h2><p>{profile.workspace_type==="personal"?"Upload certificates and track CPD, BLS and ACLS expiry dates.":"Lowest compliance appears first."}</p></div>{profile.workspace_type==="team"&&<form><select name="department" defaultValue={params.department ?? ""} aria-label="Filter by department"><option value="">All departments</option>{departments.map((department) => <option key={department}>{department}</option>)}</select><button className="button" type="submit">Filter</button></form>}</div>
      {rows.length === 0 ? <div className="empty">No staff in this department.</div> : <div className="staff-grid">{rows.map((person) => <Link className="staff-card" href={`/staff/${person.id}`} key={person.id}><div className="avatar">{person.full_name.split(" ").slice(0,2).map((word: string) => word[0]).join("")}</div><div className="staff-main"><h3>{person.full_name}</h3><p>{person.role} · {person.department}</p><div className="progress"><i style={{width: `${person.score}%`}} /></div></div><div className="staff-score"><strong>{person.score}%</strong><span className={statusClass[person.priority as CredentialStatus]}>{person.priority}</span></div></Link>)}</div>}
    </section>
    <section className="panel cpd-panel"><div className="panel-head"><div><h2>Expiry watch · next 90 days</h2><p>Credentials due soon, ordered by date.</p></div></div><div className="slots">{(docs ?? []).filter((doc) => doc.expiry_date && credentialStatus(true, doc.expiry_date) === "Expiring Soon").sort((a,b) => a.expiry_date.localeCompare(b.expiry_date)).map((doc) => { const person=(staff ?? []).find((item) => item.id===doc.staff_profile_id); const type=(types ?? []).find((item) => item.id===doc.document_type_id); return <Link className="staff-card" href={`/staff/${doc.staff_profile_id}`} key={doc.id}><div className="staff-main"><h3>{person?.full_name}</h3><p>{type?.name} · {person?.department}</p></div><strong>{doc.expiry_date}</strong></Link>; })}</div></section>
  </main>;
}
