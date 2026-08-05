begin;

alter table public.articles
  add column if not exists canonical_title text,
  add column if not exists search_subcategory text,
  add column if not exists search_intents text[] not null default '{}'::text[],
  add column if not exists search_synonyms jsonb not null default '{"en":[],"nl":[],"ru":[]}'::jsonb,
  add column if not exists search_keywords text[] not null default '{}'::text[],
  add column if not exists search_languages text[] not null default '{}'::text[],
  add column if not exists content_scope text not null default 'national',
  add column if not exists province_id text,
  add column if not exists municipality_id text,
  add column if not exists city_id text,
  add column if not exists national_fallback boolean not null default true,
  add column if not exists audience_profiles text[] not null default '{}'::text[],
  add column if not exists search_quality_score smallint not null default 0,
  add column if not exists search_indexed boolean not null default false,
  add column if not exists search_warnings text[] not null default '{}'::text[],
  add column if not exists search_model_version smallint not null default 1;

alter table public.articles
  drop constraint if exists articles_canonical_title_bounds,
  add constraint articles_canonical_title_bounds check (
    canonical_title is null or char_length(canonical_title) between 2 and 180
  ),
  drop constraint if exists articles_search_subcategory_bounds,
  add constraint articles_search_subcategory_bounds check (
    search_subcategory is null or (char_length(search_subcategory) <= 80 and search_subcategory ~ '^[a-z0-9][a-z0-9-]*$')
  ),
  drop constraint if exists articles_search_intents_bounds,
  add constraint articles_search_intents_bounds check (cardinality(search_intents) <= 20),
  drop constraint if exists articles_search_keywords_bounds,
  add constraint articles_search_keywords_bounds check (cardinality(search_keywords) <= 60),
  drop constraint if exists articles_search_languages_allowed,
  add constraint articles_search_languages_allowed check (
    search_languages <@ array['en', 'nl', 'ru']::text[] and cardinality(search_languages) <= 3
  ),
  drop constraint if exists articles_content_scope_allowed,
  add constraint articles_content_scope_allowed check (content_scope in ('national', 'province', 'municipality', 'city')),
  drop constraint if exists articles_search_location_bounds,
  add constraint articles_search_location_bounds check (
    (province_id is null or (char_length(province_id) <= 80 and province_id ~ '^[a-z0-9][a-z0-9-]*$'))
    and (municipality_id is null or (char_length(municipality_id) <= 80 and municipality_id ~ '^[a-z0-9][a-z0-9-]*$'))
    and (city_id is null or (char_length(city_id) <= 80 and city_id ~ '^[a-z0-9][a-z0-9-]*$'))
  ),
  drop constraint if exists articles_audience_profiles_allowed,
  add constraint articles_audience_profiles_allowed check (
    audience_profiles <@ array['tourist', 'student', 'expat', 'refugee', 'worker', 'resident']::text[]
    and cardinality(audience_profiles) <= 6
  ),
  drop constraint if exists articles_search_quality_score_bounds,
  add constraint articles_search_quality_score_bounds check (search_quality_score between 0 and 100),
  drop constraint if exists articles_search_synonyms_shape,
  add constraint articles_search_synonyms_shape check (
    jsonb_typeof(search_synonyms) = 'object'
    and pg_column_size(search_synonyms) <= 4096
    and search_synonyms ?& array['en', 'nl', 'ru']::text[]
    and jsonb_typeof(search_synonyms -> 'en') = 'array'
    and jsonb_typeof(search_synonyms -> 'nl') = 'array'
    and jsonb_typeof(search_synonyms -> 'ru') = 'array'
  ),
  drop constraint if exists articles_search_model_version_allowed,
  add constraint articles_search_model_version_allowed check (search_model_version = 1);

create or replace function private.refresh_article_search_metadata()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
declare
  v_category_slug text;
  v_score integer := 0;
  v_warnings text[] := '{}'::text[];
  v_preserved_errors text[] := '{}'::text[];
begin
  select category.slug into v_category_slug
  from public.categories as category
  where category.id = new.category_id;

  new.canonical_title := coalesce(nullif(btrim(new.canonical_title), ''), nullif(btrim(new.title), ''));
  new.search_subcategory := nullif(lower(btrim(new.search_subcategory)), '');
  new.search_intents := coalesce((
    select array_agg(distinct normalized order by normalized)
    from (
      select lower(btrim(value)) as normalized
      from unnest(coalesce(new.search_intents, '{}'::text[])) as value
      where nullif(btrim(value), '') is not null
    ) as normalized_intents
  ), '{}'::text[]);
  if cardinality(new.search_intents) = 0 and v_category_slug is not null then
    new.search_intents := array[v_category_slug];
  end if;
  new.search_keywords := coalesce((
    select array_agg(distinct normalized order by normalized)
    from (
      select lower(btrim(value)) as normalized
      from unnest(
        case
          when cardinality(coalesce(new.search_keywords, '{}'::text[])) = 0 then coalesce(new.tags, '{}'::text[])
          else new.search_keywords
        end
      ) as value
      where nullif(btrim(value), '') is not null
    ) as normalized_keywords
  ), '{}'::text[]);
  new.search_languages := coalesce((
    select array_agg(distinct normalized order by normalized)
    from (
      select lower(btrim(value)) as normalized
      from unnest(coalesce(new.search_languages, '{}'::text[])) as value
      where lower(btrim(value)) in ('en', 'nl', 'ru')
    ) as normalized_languages
  ), '{}'::text[]);
  if cardinality(new.search_languages) = 0 and lower(new.language) in ('en', 'nl', 'ru') then
    new.search_languages := array[lower(new.language)];
  end if;
  new.audience_profiles := coalesce((
    select array_agg(distinct normalized order by normalized)
    from (
      select lower(btrim(value)) as normalized
      from unnest(coalesce(new.audience_profiles, '{}'::text[])) as value
      where lower(btrim(value)) in ('tourist', 'student', 'expat', 'refugee', 'worker', 'resident')
    ) as normalized_profiles
  ), '{}'::text[]);
  new.province_id := nullif(lower(btrim(new.province_id)), '');
  new.municipality_id := nullif(lower(btrim(new.municipality_id)), '');
  new.city_id := nullif(lower(btrim(new.city_id)), '');

  if new.canonical_title is null then
    v_warnings := array_append(v_warnings, 'search:canonical_title_missing');
  else
    v_score := v_score + 10;
  end if;
  if new.category_id is null then
    v_warnings := array_append(v_warnings, 'search:category_missing');
  else
    v_score := v_score + 15;
  end if;
  if cardinality(new.search_intents) = 0 then
    v_warnings := array_append(v_warnings, 'search:intents_missing');
  else
    v_score := v_score + 20;
  end if;
  if cardinality(new.search_languages) = 0 or not (lower(new.language) = any(new.search_languages)) then
    v_warnings := array_append(v_warnings, 'search:language_not_indexed');
  else
    v_score := v_score + 10;
  end if;
  if new.content_scope not in ('national', 'province', 'municipality', 'city') then
    v_warnings := array_append(v_warnings, 'search:scope_invalid');
  else
    v_score := v_score + 10;
  end if;
  if new.content_scope = 'national' and new.national_fallback is not true then
    v_warnings := array_append(v_warnings, 'search:national_fallback_disabled');
  elsif new.content_scope = 'province' and new.province_id is null then
    v_warnings := array_append(v_warnings, 'search:province_missing');
  elsif new.content_scope = 'municipality' and new.municipality_id is null then
    v_warnings := array_append(v_warnings, 'search:municipality_missing');
  elsif new.content_scope = 'city' and new.city_id is null then
    v_warnings := array_append(v_warnings, 'search:city_missing');
  else
    v_score := v_score + 10;
  end if;
  if new.official_source and new.source_url ~ '^https://' then
    v_score := v_score + 15;
  else
    v_warnings := array_append(v_warnings, 'search:official_source_missing');
  end if;
  if nullif(btrim(new.full_content), '') is not null then
    v_score := v_score + 10;
  else
    v_warnings := array_append(v_warnings, 'search:content_missing');
  end if;
  if nullif(btrim(new.short_description), '') is not null then
    v_score := v_score + 5;
  else
    v_warnings := array_append(v_warnings, 'search:summary_missing');
  end if;
  if jsonb_array_length(new.search_synonyms -> 'en')
    + jsonb_array_length(new.search_synonyms -> 'nl')
    + jsonb_array_length(new.search_synonyms -> 'ru') > 0 then
    v_score := least(100, v_score + 5);
  end if;

  if v_score < 80 then
    v_warnings := array_append(v_warnings, 'search:quality_below_80');
  end if;

  select coalesce(array_agg(value), '{}'::text[])
  into v_preserved_errors
  from unnest(coalesce(new.validation_errors, '{}'::text[])) as value
  where value not like 'search:%';

  new.search_quality_score := least(100, greatest(0, v_score));
  new.search_warnings := v_warnings;
  new.validation_errors := v_preserved_errors || v_warnings;
  new.search_indexed := new.status = 'published'
    and new.search_quality_score >= 80
    and cardinality(v_warnings) = 0;
  new.search_model_version := 1;
  return new;
end
$function$;

revoke all on function private.refresh_article_search_metadata() from public, anon, authenticated;

drop trigger if exists article_search_metadata_refresh on public.articles;
create trigger article_search_metadata_refresh
before insert or update of
  title,
  canonical_title,
  short_description,
  full_content,
  category_id,
  language,
  status,
  source_url,
  official_source,
  tags,
  validation_errors,
  search_subcategory,
  search_intents,
  search_synonyms,
  search_keywords,
  search_languages,
  content_scope,
  province_id,
  municipality_id,
  city_id,
  national_fallback,
  audience_profiles
on public.articles
for each row execute function private.refresh_article_search_metadata();

update public.articles
set canonical_title = coalesce(nullif(canonical_title, ''), title),
    search_keywords = case when cardinality(search_keywords) = 0 then tags else search_keywords end,
    search_languages = case
      when cardinality(search_languages) = 0 and lower(language) in ('en', 'nl', 'ru') then array[lower(language)]
      else search_languages
    end,
    content_scope = case
      when nullif(city, '') is not null then 'city'
      when nullif(province, '') is not null then 'province'
      else 'national'
    end,
    city_id = case
      when nullif(city, '') is not null then trim(both '-' from regexp_replace(lower(city), '[^a-z0-9]+', '-', 'g'))
      else city_id
    end,
    province_id = case
      when nullif(province, '') is not null then trim(both '-' from regexp_replace(lower(province), '[^a-z0-9]+', '-', 'g'))
      else province_id
    end,
    national_fallback = true;

create or replace view public.article_search_readiness
with (security_invoker = true)
as
select
  article.id,
  article.slug,
  article.language,
  article.status,
  article.content_scope,
  article.search_intents,
  article.search_languages,
  article.audience_profiles,
  article.search_quality_score,
  article.search_indexed,
  article.search_warnings,
  article.updated_at
from public.articles as article;

revoke all on table public.article_search_readiness from public, anon;
grant select on table public.article_search_readiness to authenticated;

comment on view public.article_search_readiness is
  'Admin projection of governed search metadata, quality score, indexing eligibility and actionable warnings.';

commit;
