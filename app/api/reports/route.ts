import { createClient } from "@/lib/supabase/server";
import { credentialStatus } from "@/lib/credentials";
export async function GET() {
  const supabase=await createClient(); const {data:{user}}=await supabase.auth.getUser();
  if(!user) return new Response("Sign in required",{status:401});
  const [{data:staff},{data:types},{data:docs}]=await Promise.all([supabase.from("staff_profiles").select("*"),supabase.from("document_types").select("*"),supabase.from("credential_documents").select("*")]);
  const esc=(v:unknown)=>`"${String(v??"").replaceAll('"','""')}"`;
  const rows=[["Staff","Department","Document","Expiry","Status"],...(staff??[]).flatMap(person=>(types??[]).map(type=>{const doc=(docs??[]).find(d=>d.staff_profile_id===person.id&&d.document_type_id===type.id);return [person.full_name,person.department,type.name,doc?.expiry_date??"",credentialStatus(type.has_expiry,doc?.expiry_date,Boolean(doc))]}))];
  return new Response(rows.map(row=>row.map(esc).join(",")).join("\r\n"),{headers:{"Content-Type":"text/csv","Content-Disposition":"attachment; filename=vitala-compliance.csv"}});
}
