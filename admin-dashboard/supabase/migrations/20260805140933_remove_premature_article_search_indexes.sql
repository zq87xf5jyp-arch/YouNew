-- Three current Admin articles do not justify write-amplifying search indexes.
-- Reintroduce them after query plans show a real table-size/selectivity need.

drop index if exists public.articles_search_intents_gin_idx;
drop index if exists public.articles_search_synonyms_gin_idx;
drop index if exists public.articles_search_keywords_gin_idx;
drop index if exists public.articles_search_scope_idx;
