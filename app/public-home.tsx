import Link from "next/link";
import LandingPage from "./landing";
export default async function PublicHome(){
  return <><LandingPage/><Link className="pricing-float-link" href="/pricing">Plans from RM12 · View pricing</Link></>;
}
