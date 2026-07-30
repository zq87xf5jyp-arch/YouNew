-- Complete the Admin editorial-image path omitted by the remote-only base
-- migration history, and move the relocatable citext extension out of public.

create schema if not exists extensions;
alter extension citext set schema extensions;

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
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
on storage.objects for select
to public
using (bucket_id = 'content-images');

drop policy if exists "editors upload content images" on storage.objects;
create policy "editors upload content images"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'content-images'
  and (select private.current_admin_role()) in ('owner', 'admin', 'editor')
);

drop policy if exists "editors update content images" on storage.objects;
create policy "editors update content images"
on storage.objects for update
to authenticated
using (
  bucket_id = 'content-images'
  and (select private.current_admin_role()) in ('owner', 'admin', 'editor')
)
with check (
  bucket_id = 'content-images'
  and (select private.current_admin_role()) in ('owner', 'admin', 'editor')
);

drop policy if exists "editors delete content images" on storage.objects;
create policy "editors delete content images"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'content-images'
  and (select private.current_admin_role()) in ('owner', 'admin', 'editor')
);
