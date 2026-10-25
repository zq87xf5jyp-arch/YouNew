-- Provision the complete validated Settings contract without overwriting
-- existing operator values or changing their publication state.

insert into public.app_settings (key, value, status)
values
  ('app_name', '"YouNew.nl"'::jsonb, 'published'::public.publication_status),
  ('support_email', '"support@younew.nl"'::jsonb, 'published'::public.publication_status),
  ('telegram_link', '""'::jsonb, 'published'::public.publication_status),
  ('app_store_link', '""'::jsonb, 'published'::public.publication_status),
  ('google_play_link', '""'::jsonb, 'published'::public.publication_status),
  ('privacy_policy_url', '"https://younew.nl/privacy/"'::jsonb, 'published'::public.publication_status),
  ('terms_url', '"https://younew.nl/terms/"'::jsonb, 'published'::public.publication_status),
  ('default_city', '"Amsterdam"'::jsonb, 'published'::public.publication_status),
  ('default_language', '"en"'::jsonb, 'published'::public.publication_status),
  ('announcement', '""'::jsonb, 'published'::public.publication_status),
  ('maintenance_mode', 'false'::jsonb, 'published'::public.publication_status)
on conflict (key) do nothing;

-- Repair only the legacy string representation written by the old Admin form.
-- Unknown values remain untouched so the fail-closed reader can surface them.
update public.app_settings
set value = to_jsonb((value #>> '{}')::boolean),
    updated_at = now()
where key = 'maintenance_mode'
  and jsonb_typeof(value) = 'string'
  and value #>> '{}' in ('true', 'false');

comment on column public.app_settings.value is
  'JSON setting value. maintenance_mode is boolean; editable text/link settings are JSON strings.';
