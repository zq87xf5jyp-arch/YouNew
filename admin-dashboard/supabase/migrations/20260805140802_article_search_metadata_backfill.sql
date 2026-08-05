alter table public.articles disable trigger enforce_article_publication_gate;
alter table public.articles disable trigger enqueue_article_publication;
alter table public.articles disable trigger set_updated_at;

update public.articles
set
  canonical_title = coalesce(nullif(btrim(canonical_title), ''), title),
  search_keywords = case when cardinality(search_keywords) = 0 then tags else search_keywords end,
  supported_languages = case
    when cardinality(supported_languages) = 0 and nullif(btrim(language), '') is not null then array[lower(btrim(language))]
    else supported_languages
  end,
  source_urls = case
    when cardinality(source_urls) = 0 and source_url ~ '^https://' then array[source_url]
    else source_urls
  end,
  scope_level = case
    when nullif(btrim(city), '') is not null then 'city'
    when nullif(btrim(province), '') is not null then 'province'
    else scope_level
  end
where canonical_title is null
   or cardinality(search_keywords) = 0
   or cardinality(supported_languages) = 0
   or cardinality(source_urls) = 0;

alter table public.articles enable trigger set_updated_at;
alter table public.articles enable trigger enqueue_article_publication;
alter table public.articles enable trigger enforce_article_publication_gate;
