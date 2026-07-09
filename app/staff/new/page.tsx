import Link from "next/link";
import { addStaff } from "@/app/actions";

export default function NewStaff() {
  return <main className="shell narrow"><Link className="back" href="/">← Staff dashboard</Link><section className="panel form-panel"><p className="eyebrow">New team member</p><h1>Add staff profile</h1><p>Create the profile first; required credential slots appear automatically.</p><form action={addStaff} className="form-grid"><label className="wide">Full name<input name="full_name" required placeholder="Ahmad Farid" /></label><label>IC number<input name="ic_number" required placeholder="900101-01-1234" /></label><label>Email<input name="email" type="email" placeholder="name@hospital.my" /></label><label>Role<select name="role" required><option>Staff Nurse</option><option>Senior Staff Nurse</option><option>Nurse Manager</option><option>HR / Admin</option></select></label><label>Department<input name="department" required placeholder="Medical Ward" /></label><div className="wide actions"><Link className="button" href="/">Cancel</Link><button className="button primary">Create profile</button></div></form></section></main>;
}
