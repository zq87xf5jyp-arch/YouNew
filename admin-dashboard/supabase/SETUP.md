# Подключение Supabase

1. Создайте проект в Supabase.
2. Выполните в SQL Editor миграции по порядку:
   - `migrations/0001_younew_admin_schema.sql`
   - `migrations/0002_admin_profiles_and_timestamps.sql`
   - `migrations/0003_promote_first_owner.sql`
   - `migrations/0004_security_storage_and_audit.sql`
   - `migrations/0005_public_content_images.sql`
   - при необходимости `seed/seed.sql`
3. Скопируйте `.env.example` в `.env.local` и заполните URL и ключи из Project Settings → API.
4. В Authentication → Users создайте администратора.
5. В SQL Editor одобрите его и назначьте роль:

```sql
update public.profiles
set is_approved = true, role = 'owner'
where email = 'your-email@example.com';
```

6. Перезапустите приложение и войдите через `/login`.

## Изображения контента

- Редактор загружает JPG, PNG и WebP напрямую в публичный bucket `content-images`.
- Перед загрузкой браузер уменьшает файл до 1920×1280 и конвертирует его в WebP.
- Supabase автоматически создаёт URL полной версии и миниатюры; в `articles.images` сохраняются только URL, Storage path, alt-текст и размеры.
- Изображения не пишутся в файловую систему Next.js и не сохраняются в `localStorage`.
- Bucket ограничен 8 МБ на входной объект, а один материал — 12 изображениями на уровне интерфейса.

`SUPABASE_SERVICE_ROLE_KEY` нужен только серверным интеграциям. Никогда не добавляйте его в переменную с префиксом `NEXT_PUBLIC_`.
