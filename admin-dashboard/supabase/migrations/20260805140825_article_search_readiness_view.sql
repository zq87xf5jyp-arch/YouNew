-- Search-readiness projection uses invoker RLS from public.articles.

create or replace view public.article_search_readiness
with (security_invoker = true)
as
select
  article.id,
  article.title,
  article.canonical_title,
  article.status,
  article.scope_level,
  article.city,
  article.municipality,
  article.province,
  article.content_quality_score,
  article.search_indexed,
  article.verified_date as last_verified,
  array_remove(array[
    case when cardinality(article.search_synonyms) = 0 then 'no_synonyms' end,
    case when cardinality(article.source_urls) = 0 or article.official_source is not true then 'no_official_source' end,
    case when article.national_fallback is not true then 'no_national_fallback' end,
    case when article.scope_level in ('municipality', 'city', 'neighbourhood')
      and nullif(btrim(coalesce(article.municipality, article.city)), '') is null then 'no_city_mapping' end,
    case when article.category_id is null then 'no_category' end,
    case when exists (
      select 1 from public.articles duplicate
      where duplicate.id <> article.id
        and duplicate.search_intents && article.search_intents
    ) then 'duplicate_intent' end,
    case when exists (
      select 1 from public.articles conflict
      where conflict.id <> article.id
        and conflict.category_id is distinct from article.category_id
        and conflict.search_synonyms && article.search_synonyms
    ) then 'conflicting_aliases' end,
    case when article.status::text = 'published' and article.search_indexed is not true then 'content_not_indexed' end,
    case when article.status::text = 'published'
      and (article.verified_date is null or article.verified_date < current_date - 90) then 'stale_content' end,
    case when cardinality(article.search_intents) = 0
      or cardinality(article.search_synonyms) = 0
      or cardinality(article.search_keywords) = 0 then 'empty_result_risk' end
  ], null)::text[] as warnings
from public.articles article;

revoke all on public.article_search_readiness from public, anon;
grant select on public.article_search_readiness to authenticated, service_role;
