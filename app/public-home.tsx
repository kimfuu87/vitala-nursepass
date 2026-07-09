import Link from "next/link";
import LandingPage from "./landing";
import { createClient } from "@/lib/supabase/server";
import { redirect } from "next/navigation";
export default async function PublicHome(){
  const supabase=await createClient();const{data:{user}}=await supabase.auth.getUser();if(user)redirect("/dashboard");
  return <><LandingPage/><Link className="pricing-float-link" href="/pricing">Plans from RM12 · View pricing</Link></>;
}
