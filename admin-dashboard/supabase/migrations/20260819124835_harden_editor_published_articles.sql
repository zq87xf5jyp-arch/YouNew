-- Editors may draft and revise non-published content. Published rows require
-- Owner/Admin authority. UI state is not a security boundary.

drop policy if exists "content admins insert articles" on public.articles;
create policy "content admins insert articles"
on public.articles
for insert
to authenticated
with check (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
  or (
    (select private.current_admin_role()) = 'editor'::public.admin_role
    and status = any (
      array['draft'::public.publication_status, 'review'::public.publication_status, 'qa'::public.publication_status]
    )
  )
);

drop policy if exists "content admins update articles" on public.articles;
create policy "content admins update articles"
on public.articles
for update
to authenticated
using (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
  or (
    (select private.current_admin_role()) = 'editor'::public.admin_role
    and status = any (
      array['draft'::public.publication_status, 'review'::public.publication_status, 'qa'::public.publication_status]
    )
  )
)
with check (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
  or (
    (select private.current_admin_role()) = 'editor'::public.admin_role
    and status = any (
      array['draft'::public.publication_status, 'review'::public.publication_status, 'qa'::public.publication_status]
    )
  )
);

drop policy if exists "content admins delete articles" on public.articles;
create policy "content admins delete articles"
on public.articles
for delete
to authenticated
using (
  (select private.current_admin_role()) = any (
    array['owner'::public.admin_role, 'admin'::public.admin_role]
  )
  or (
    (select private.current_admin_role()) = 'editor'::public.admin_role
    and status = any (
      array['draft'::public.publication_status, 'review'::public.publication_status, 'qa'::public.publication_status]
    )
  )
);
