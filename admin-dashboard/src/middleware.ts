import { type NextRequest, NextResponse } from "next/server";
import { createServerClient } from "@supabase/ssr";
import type { CookieOptions } from "@supabase/ssr";
import { canAccessPath, type AdminRole } from "@/lib/authorization";

type CookieToSet = {
  name: string;
  value: string;
  options: CookieOptions;
};

export async function middleware(request: NextRequest) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !anonKey) {
    const explicitLocalDemo = process.env.NODE_ENV !== "production" && process.env.YOUNEW_ADMIN_DEMO_MODE === "true";
    if (!explicitLocalDemo) {
      return request.nextUrl.pathname === "/login"
        ? NextResponse.next()
        : NextResponse.redirect(new URL("/login?error=configuration", request.url));
    }
    return NextResponse.next();
  }

  let response = NextResponse.next({ request });
  const supabase = createServerClient(url, anonKey, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet: CookieToSet[]) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
      }
    }
  });

  const { data: { user } } = await supabase.auth.getUser();
  const pathname = request.nextUrl.pathname;
  const isLogin = pathname === "/login";
  const isProtected = !pathname.startsWith("/api/public/") && !pathname.startsWith("/api/mobile/") && pathname !== "/" && !isLogin;

  if (!user && isProtected) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  if (user) {
    const { data: profile } = await supabase
      .from("profiles")
      .select("role,is_approved")
      .eq("id", user.id)
      .maybeSingle();

    if (!profile?.is_approved) {
      await supabase.auth.signOut();
      return NextResponse.redirect(new URL("/login?error=not-approved", request.url));
    }

    const role = (profile.role ?? "viewer") as AdminRole;
    if (isLogin) return NextResponse.redirect(new URL("/dashboard", request.url));
    if (isProtected && !canAccessPath(role, pathname)) {
      return NextResponse.redirect(new URL("/dashboard?error=forbidden", request.url));
    }
  }
  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)"]
};
