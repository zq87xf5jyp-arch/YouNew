import { ShieldCheck } from "lucide-react";
import { signIn } from "./actions";
import { YouNewLogo } from "@/components/admin/logo";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { isLocalDemoAdminEnabled } from "@/lib/auth";

export default async function LoginPage({
  searchParams
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const params = await searchParams;
  const demoModeEnabled = isLocalDemoAdminEnabled();

  return (
    <main className="grid min-h-screen place-items-center px-4 py-10">
      <div className="w-full max-w-md">
        <div className="mb-8">
          <YouNewLogo />
        </div>
        <Card>
          <CardHeader>
            <CardTitle>Вход в админку</CardTitle>
            <CardDescription>Войдите под одобренным админ-аккаунтом YouNew.nl, чтобы управлять контентом, проверками и релизами.</CardDescription>
          </CardHeader>
          <CardContent>
            {params.error ? (
              <div className="mb-4 rounded-md border border-destructive/30 bg-destructive/10 p-3 text-sm text-red-100">
                {params.error === "configuration"
                  ? "Сервис входа не настроен. Обратитесь к владельцу системы."
                  : params.error === "not-approved"
                    ? "Аккаунт существует, но пока не одобрен для доступа к админке."
                    : "Email или пароль неверный."}
              </div>
            ) : null}
            <form action={signIn} className="flex flex-col gap-4">
              <div className="flex flex-col gap-2">
                <Label htmlFor="email">Email</Label>
                <Input id="email" name="email" type="email" required placeholder="owner@younew.nl" />
              </div>
              <div className="flex flex-col gap-2">
                <Label htmlFor="password">Пароль</Label>
                <Input id="password" name="password" type="password" required />
              </div>
              <Button type="submit">
                <ShieldCheck data-icon="inline-start" />
                Войти
              </Button>
            </form>
          </CardContent>
        </Card>
        <p className="mt-4 text-xs text-muted-foreground">
          {demoModeEnabled
            ? "Локальный демо-режим активен только в среде разработки."
            : "Доступ предоставляется только одобренным администраторам."}
        </p>
      </div>
    </main>
  );
}
