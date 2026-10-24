-- Private Visual QA: approved owner/admin/qa SELECT and own-prefix INSERT only.
begin;
do $$
begin
  if not exists(select 1 from storage.buckets where id='screenshots' and public is false and file_size_limit=524288 and allowed_mime_types=ARRAY['image/png','image/jpeg']::text[]) then
    raise exception 'Expected existing private screenshots bucket with reviewed 512KiB PNG/JPEG limits';
  end if;
  if exists(select 1 from public.screenshots) or exists(select 1 from storage.objects where bucket_id='screenshots') then
    raise exception 'Expected reviewed empty screenshots table and bucket; stop for new review';
  end if;
  if not exists(select 1 from pg_class where oid='storage.objects'::regclass and relrowsecurity) then
    raise exception 'Expected storage.objects RLS';
  end if;
  if md5(pg_get_functiondef('private.current_admin_role()'::regprocedure)) <> 'a1e11767c8522b45486cb5f9d1c59f75' then
    raise exception 'Approved-role helper changed; stop for new review';
  end if;
  if not has_function_privilege('authenticated','private.current_admin_role()','EXECUTE')
     or has_function_privilege('anon','private.current_admin_role()','EXECUTE') then
    raise exception 'Approved-role helper privileges changed';
  end if;
  if (select md5(jsonb_agg(jsonb_build_object('policyname',policyname,'permissive',permissive,'roles',roles,'cmd',cmd,'qual',qual,'with_check',with_check) order by policyname)::text) from pg_policies where schemaname='storage' and tablename='objects') is distinct from '4f937a859ac59a326257edff4b613aff' then
    raise exception 'All Storage policies fingerprint changed; stop for new review';
  end if;
  if exists(select 1 from pg_policies where schemaname='storage' and tablename='objects'
      and (policyname like 'younew screenshot reviews %' or coalesce(qual,'') like '%screenshots%' or coalesce(with_check,'') like '%screenshots%')) then
    raise exception 'Screenshot storage policy already exists; inspect instead of widening';
  end if;
end $$;

create policy "younew screenshot reviews read" on storage.objects
for select to authenticated
using (
  bucket_id='screenshots'
  and (select private.current_admin_role()) in ('owner','admin','qa')
  and name ~ '^reviews/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(png|jpg)$'
);

create policy "younew screenshot reviews insert" on storage.objects
for insert to authenticated
with check (
  bucket_id='screenshots'
  and (select private.current_admin_role()) in ('owner','admin','qa')
  and split_part(name,'/',2)=(select auth.uid())::text
  and name ~ '^reviews/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.(png|jpg)$'
);

-- No UPDATE or DELETE policy is granted. Failed/unknown creation uses same-ID byte-verified resume.
commit;
