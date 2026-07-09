import Link from "next/link";
import { signIn, signUp } from "@/app/auth/actions";
export default async function Login({searchParams}:{searchParams:Promise<{error?:string;message?:string}>}) {
  const p=await searchParams;
  return <main className="shell narrow"><Link className="back" href="/">← Dashboard</Link><section className="panel form-panel"><p className="eyebrow">Secure workspace</p><h1>Sign in or create account</h1>{p.error&&<div className="error-banner">{p.error}</div>}{p.message&&<div className="success-banner">{p.message}</div>}<form className="form-grid"><label className="wide">Email<input name="email" type="email" required/></label><label className="wide">Password<input name="password" type="password" minLength={8} required/></label><div className="wide actions"><button formAction={signUp} className="button">Create account</button><button formAction={signIn} className="button primary">Sign in</button></div></form></section></main>;
}
