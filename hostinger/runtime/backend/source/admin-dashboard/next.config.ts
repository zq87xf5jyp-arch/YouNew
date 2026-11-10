import type { NextConfig } from "next";
import { ADMIN_CONTENT_SECURITY_POLICY } from "./src/lib/security-policy";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  output: "standalone",
  experimental: { cpus: 1 },
  webpack(config) { if(process.env.YOUNEW_LOCAL_NO_BUILD_CACHE === "1") config.cache=false; return config; },
  poweredByHeader: false,
  // Next normalizes loopback URLs to localhost, dropping the 127.0.0.1 session on redirects.
  skipMiddlewareUrlNormalize: process.env.NEXT_PUBLIC_YOUNEW_LOCAL_REHEARSAL === "true",
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          { key: "Content-Security-Policy", value: ADMIN_CONTENT_SECURITY_POLICY },
          { key: "Cross-Origin-Opener-Policy", value: "same-origin" },
          { key: "Strict-Transport-Security", value: "max-age=31536000" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "X-Frame-Options", value: "DENY" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=(), payment=()" },
          { key: "X-Robots-Tag", value: "noindex, nofollow, noarchive" }
        ]
      }
    ];
  }
};

export default nextConfig;
