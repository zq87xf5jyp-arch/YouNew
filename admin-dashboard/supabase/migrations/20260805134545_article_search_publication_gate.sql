-- Published articles must contain complete, HTTPS-backed search metadata.

create or replace function public.enforce_article_search_metadata_gate()
returns trigger
language plpgsql
set search_path = pg_catalog
as $$
declare
  missing_fields text[] := '{}'::text[];
  invalid_source text;
begin
  if new.status::text <> 'published' then
    return new;
  end if;

  if nullif(btrim(new.canonical_title), '') is null then missing_fields := array_append(missing_fields, 'canonical_title'); end if;
  if new.category_id is null then missing_fields := array_append(missing_fields, 'category'); end if;
  if cardinality(new.search_intents) = 0 then missing_fields := array_append(missing_fields, 'search_intents'); end if;
  if cardinality(new.search_synonyms) = 0 then missing_fields := array_append(missing_fields, 'search_synonyms'); end if;
  if cardinality(new.search_keywords) = 0 then missing_fields := array_append(missing_fields, 'search_keywords'); end if;
  if cardinality(new.supported_languages) = 0 then missing_fields := array_append(missing_fields, 'supported_languages'); end if;
  if cardinality(new.applicable_profiles) = 0 then missing_fields := array_append(missing_fields, 'applicable_profiles'); end if;
  if cardinality(new.source_urls) = 0 then missing_fields := array_append(missing_fields, 'source_urls'); end if;
  if new.content_quality_score <= 0 then missing_fields := array_append(missing_fields, 'content_quality_score'); end if;
  if new.scope_level in ('municipality', 'city', 'neighbourhood')
     and nullif(btrim(coalesce(new.municipality, new.city)), '') is null then
    missing_fields := array_append(missing_fields, 'city_mapping');
  end if;
  if new.search_indexed is not true then missing_fields := array_append(missing_fields, 'search_indexed'); end if;

  select source
  into invalid_source
  from unnest(new.source_urls) as source
  where source !~ '^https://'
  limit 1;
  if invalid_source is not null then missing_fields := array_append(missing_fields, 'invalid_source_url'); end if;

  if cardinality(missing_fields) > 0 then
    raise exception using
      errcode = '23514',
      message = 'article_search_metadata_incomplete:' || array_to_string(missing_fields, ',');
  end if;
  return new;
end;
$$;

drop trigger if exists articles_search_metadata_gate on public.articles;
create trigger articles_search_metadata_gate
before insert or update on public.articles
for each row execute function public.enforce_article_search_metadata_gate();

revoke all on function public.enforce_article_search_metadata_gate() from public, anon, authenticated;
grant execute on function public.enforce_article_search_metadata_gate() to service_role;
