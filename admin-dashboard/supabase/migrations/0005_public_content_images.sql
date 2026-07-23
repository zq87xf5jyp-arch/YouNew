-- Public, optimized editorial images for the app and public website.
-- Files live only in Supabase Storage; article rows keep portable metadata and URLs.

alter table public.articles
  add column if not exists images jsonb not null default '[]'::jsonb;

alter table public.articles
  drop constraint if exists articles_images_array_check;

alter table public.articles
  add constraint articles_images_array_check
  check (jsonb_typeof(images) = 'array');

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'content-images',
  'content-images',
  true,
  8388608,
  array['image/avif', 'image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "public reads content images" on storage.objects;
create policy "public reads content images"
on storage.objects for select to public
using (bucket_id = 'content-images');

drop policy if exists "editors upload content images" on storage.objects;
create policy "editors upload content images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'content-images'
  and public.current_admin_role() in ('owner', 'admin', 'editor')
);

drop policy if exists "editors update content images" on storage.objects;
create policy "editors update content images"
on storage.objects for update to authenticated
using (
  bucket_id = 'content-images'
  and public.current_admin_role() in ('owner', 'admin', 'editor')
)
with check (
  bucket_id = 'content-images'
  and public.current_admin_role() in ('owner', 'admin', 'editor')
);

drop policy if exists "editors delete content images" on storage.objects;
create policy "editors delete content images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'content-images'
  and public.current_admin_role() in ('owner', 'admin', 'editor')
);
