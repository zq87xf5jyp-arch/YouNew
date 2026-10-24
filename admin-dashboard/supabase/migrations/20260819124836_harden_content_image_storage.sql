-- Browser sessions may upload and replace draft images, but deletion is
-- server-only and follows a successful article save plus a reference check.

create or replace function private.content_image_is_published(p_path text)
returns boolean
language sql
stable
security definer
set search_path = pg_catalog
as $$
  select exists (
    select 1
    from public.articles article
    cross join lateral jsonb_array_elements(
      case
        when jsonb_typeof(article.images) = 'array' then article.images
        else '[]'::jsonb
      end
    ) image
    where article.status = 'published'::public.publication_status
      and image ->> 'path' = p_path
  );
$$;

revoke all on function private.content_image_is_published(text)
from public, anon, authenticated, service_role;
grant execute on function private.content_image_is_published(text)
to authenticated, service_role;

drop policy if exists "editors update content images" on storage.objects;
drop policy if exists "approved roles update content images" on storage.objects;
create policy "approved roles update content images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'content-images'
  and (
    (select private.current_admin_role()) = any (
      array['owner'::public.admin_role, 'admin'::public.admin_role]
    )
    or (
      (select private.current_admin_role()) = 'editor'::public.admin_role
      and not private.content_image_is_published(name)
    )
  )
)
with check (
  bucket_id = 'content-images'
  and (
    (select private.current_admin_role()) = any (
      array['owner'::public.admin_role, 'admin'::public.admin_role]
    )
    or (
      (select private.current_admin_role()) = 'editor'::public.admin_role
      and not private.content_image_is_published(name)
    )
  )
);

-- No authenticated DELETE policy remains for content-images. The server first
-- commits the article mutation, then removes only paths proven unreferenced.
drop policy if exists "editors delete content images" on storage.objects;

create or replace function public.content_image_paths_in_use(p_paths text[])
returns table(path text)
language sql
stable
security invoker
set search_path = pg_catalog, public
as $$
  select distinct requested.path
  from unnest(coalesce(p_paths, '{}'::text[])) requested(path)
  where exists (
    select 1
    from public.articles article
    cross join lateral jsonb_array_elements(
      case
        when jsonb_typeof(article.images) = 'array' then article.images
        else '[]'::jsonb
      end
    ) image
    where image ->> 'path' = requested.path
  );
$$;

revoke all on function public.content_image_paths_in_use(text[])
from public, anon, authenticated, service_role;
grant execute on function public.content_image_paths_in_use(text[])
to service_role;

comment on function public.content_image_paths_in_use(text[]) is
  'Server-only reference guard used before deleting editorial Storage objects.';
