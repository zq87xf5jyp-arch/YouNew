"use server";

import { redirect } from "next/navigation";
import { isLocalDemoAdminEnabled } from "@/lib/auth";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export async function signIn(formData: FormData) {
  const email = String(formData.get("email") ?? "");
  const password = String(formData.get("password") ?? "");
  const supabase = await createSupabaseServerClient();

  if (!supabase) {
    redirect(isLocalDemoAdminEnabled() ? "/dashboard" : "/login?error=configuration");
  }

  const { error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) {
    redirect("/login?error=invalid");
  }

  redirect("/dashboard");
}

export async function signOut() {
  const supabase = await createSupabaseServerClient();
  if (supabase) await supabase.auth.signOut();
  redirect("/login");
}
