"use server";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
export async function chooseWorkspace(formData:FormData){
  const supabase=await createClient();const{data:{user}}=await supabase.auth.getUser();if(!user)redirect("/login");
  const workspace=String(formData.get("workspace_type"));if(!["personal","team"].includes(workspace))throw new Error("Choose a workspace");
  const name=String(formData.get("display_name")||user.email?.split("@")[0]||"My profile").trim();
  const{error}=await supabase.from("profiles").update({workspace_type:workspace,display_name:name,updated_at:new Date().toISOString()}).eq("id",user.id);if(error)throw new Error(error.message);
  if(workspace==="personal"){const{data}=await supabase.from("staff_profiles").select("id").eq("user_id",user.id).limit(1);if(!data?.length)await supabase.from("staff_profiles").insert({user_id:user.id,full_name:name,email:user.email,role:"Nurse",department:"Personal",employment_status:"Active"});}
  redirect("/dashboard");
}
