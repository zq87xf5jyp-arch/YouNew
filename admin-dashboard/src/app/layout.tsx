import type { Metadata } from "next";
import { ADMIN_META_CONTENT_SECURITY_POLICY } from "@/lib/security-policy";
import "./globals.css";

export const metadata: Metadata = {
  title: "Админка YouNew.nl",
  description: "Админ-панель для контента, визуальной проверки и релизов мобильного приложения YouNew.nl.",
  robots: { index: false, follow: false, nocache: true }
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="ru" className="dark">
      <head>
        <meta httpEquiv="Content-Security-Policy" content={ADMIN_META_CONTENT_SECURITY_POLICY} />
      </head>
      <body>{children}</body>
    </html>
  );
}
