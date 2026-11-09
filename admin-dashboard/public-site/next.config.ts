import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export",
  outputFileTracingRoot: process.cwd(),
  trailingSlash: true,
  poweredByHeader: false,
  ...(process.env.YOUNEW_HOSTINGER_QA_BUILD === "1"
    ? { experimental: { cpus: 1, workerThreads: false } }
    : {}),
  webpack(config) {
    // Optional local resource limit; default hosting behavior stays unchanged.
    if (process.env.YOUNEW_LOCAL_NO_BUILD_CACHE === "1") config.cache = false;
    return config;
  },
  images: {
    unoptimized: true,
    formats: ["image/avif", "image/webp"]
  }
};

export default nextConfig;
