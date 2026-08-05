-- Bounded metadata and query indexes for the article search model.

alter table public.articles
  alter column canonical_title set not null,
  drop constraint if exists articles_canonical_title_length_check,
  add constraint articles_canonical_title_length_check
    check (char_length(btrim(canonical_title)) between 1 and 300),
  drop constraint if exists articles_subcategory_length_check,
  add constraint articles_subcategory_length_check
    check (subcategory is null or char_length(btrim(subcategory)) between 1 and 120),
  drop constraint if exists articles_country_scope_check,
  add constraint articles_country_scope_check
    check (country_scope = 'NL'),
  drop constraint if exists articles_scope_level_check,
  add constraint articles_scope_level_check
    check (scope_level in (
      'national', 'province', 'municipality', 'city', 'neighbourhood',
      'organization', 'emergency', 'online_service'
    )),
  drop constraint if exists articles_content_quality_score_check,
  add constraint articles_content_quality_score_check
    check (content_quality_score between 0 and 100),
  drop constraint if exists articles_search_metadata_bounds_check,
  add constraint articles_search_metadata_bounds_check
    check (
      cardinality(search_intents) <= 100
      and cardinality(search_synonyms) <= 200
      and cardinality(search_keywords) <= 200
      and cardinality(supported_languages) <= 12
      and cardinality(applicable_profiles) <= 20
      and cardinality(source_urls) <= 30
    );

create index if not exists articles_search_intents_gin_idx
  on public.articles using gin (search_intents);
create index if not exists articles_search_synonyms_gin_idx
  on public.articles using gin (search_synonyms);
create index if not exists articles_search_keywords_gin_idx
  on public.articles using gin (search_keywords);
create index if not exists articles_search_scope_idx
  on public.articles (status, scope_level, search_indexed);
