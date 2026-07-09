"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

function required(formData: FormData, name: string) {
  const value = String(formData.get(name) ?? "").trim();
  if (!value) throw new Error(`${name.replaceAll("_", " ")} is required`);
  return value;
}

export async function addStaff(formData: FormData) {
  const supabase = await createClient();
  const payload = {
    full_name: required(formData, "full_name"),
    ic_number: required(formData, "ic_number"),
    email: String(formData.get("email") ?? "").trim() || null,
    role: required(formData, "role"),
    department: required(formData, "department"),
    employment_status: "Active",
  };
  const { data, error } = await supabase.from("staff_profiles").insert(payload).select("id").single();
  if (error) throw new Error(error.message);
  revalidatePath("/");
  redirect(`/staff/${data.id}?saved=staff`);
}

export async function uploadCredential(formData: FormData) {
  const staffId = required(formData, "staff_profile_id");
  const documentTypeId = required(formData, "document_type_id");
  const file = formData.get("file");
  if (!(file instanceof File) || !file.size) throw new Error("A file is required");
  if (file.size > 10 * 1024 * 1024) throw new Error("File too large");

  const supabase = await createClient();
  const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, "_");
  const path = `${staffId}/${crypto.randomUUID()}-${safeName}`;
  const { error: storageError } = await supabase.storage
    .from("credential-documents")
    .upload(path, file, { contentType: file.type, upsert: false });
  if (storageError) throw new Error(storageError.message);

  const { error } = await supabase.from("credential_documents").insert({
    staff_profile_id: staffId,
    document_type_id: documentTypeId,
    file_url: path,
    file_name: file.name,
    issue_date: String(formData.get("issue_date") ?? "") || null,
    expiry_date: String(formData.get("expiry_date") ?? "") || null,
    verification_status: "Unverified",
  });
  if (error) {
    await supabase.storage.from("credential-documents").remove([path]);
    throw new Error(error.message);
  }
  revalidatePath("/");
  revalidatePath(`/staff/${staffId}`);
  redirect(`/staff/${staffId}?saved=credential`);
}

export async function updateExpiry(formData: FormData) {
  const staffId = required(formData, "staff_profile_id");
  const id = required(formData, "credential_id");
  const expiryDate = String(formData.get("expiry_date") ?? "") || null;
  const supabase = await createClient();
  const { error } = await supabase.from("credential_documents").update({ expiry_date: expiryDate }).eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/");
  revalidatePath(`/staff/${staffId}`);
  redirect(`/staff/${staffId}?saved=expiry`);
}

export async function deleteStaff(formData: FormData) {
  const id = required(formData, "staff_profile_id");
  const supabase = await createClient();
  const { error } = await supabase.from("staff_profiles").delete().eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath("/");
  redirect("/?saved=deleted");
}

export async function addCpdRecord(formData: FormData) {
  const staffId = required(formData, "staff_profile_id");
  const supabase = await createClient();
  let certificateUrl: string | null = null;
  let certificateFileName: string | null = null;
  const file = formData.get("file");
  if (file instanceof File && file.size) {
    if (file.size > 10 * 1024 * 1024) throw new Error("File too large");
    certificateFileName = file.name;
    certificateUrl = `${staffId}/cpd/${crypto.randomUUID()}-${file.name.replace(/[^a-zA-Z0-9._-]/g, "_")}`;
    const { error } = await supabase.storage.from("credential-documents").upload(certificateUrl, file);
    if (error) throw new Error(error.message);
  }
  const { error } = await supabase.from("cpd_records").insert({
    staff_profile_id: staffId,
    course_name: required(formData, "course_name"),
    provider: required(formData, "provider"),
    completion_date: required(formData, "completion_date"),
    cpd_points: Number(required(formData, "cpd_points")),
    certificate_url: certificateUrl,
    certificate_file_name: certificateFileName,
  });
  if (error) throw new Error(error.message);
  revalidatePath(`/staff/${staffId}`);
  redirect(`/staff/${staffId}?saved=cpd`);
}

export async function deleteCpdRecord(formData: FormData) {
  const staffId = required(formData, "staff_profile_id");
  const id = required(formData, "cpd_id");
  const supabase = await createClient();
  const { error } = await supabase.from("cpd_records").delete().eq("id", id);
  if (error) throw new Error(error.message);
  revalidatePath(`/staff/${staffId}`);
  redirect(`/staff/${staffId}?saved=cpd-deleted`);
}

export async function deleteCredential(formData: FormData) {
  const staffId = required(formData, "staff_profile_id");
  const id = required(formData, "credential_id");
  const path = required(formData, "file_url");
  const supabase = await createClient();
  const { error } = await supabase.from("credential_documents").delete().eq("id", id);
  if (error) throw new Error(error.message);
  await supabase.storage.from("credential-documents").remove([path]);
  revalidatePath("/");
  revalidatePath(`/staff/${staffId}`);
  redirect(`/staff/${staffId}?saved=credential-deleted`);
}

export async function signedDocumentUrl(path: string) {
  const supabase = await createClient();
  const { data, error } = await supabase.storage.from("credential-documents").createSignedUrl(path, 300);
  if (error) throw new Error(error.message);
  return data.signedUrl;
}
