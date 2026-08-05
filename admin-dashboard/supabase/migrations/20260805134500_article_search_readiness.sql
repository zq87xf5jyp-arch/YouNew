-- Search-ready content metadata for the Admin editorial workflow.
-- Additive and backward compatible: existing article bodies and governance
-- evidence are preserved, while future publication requires explicit search
-- applicability metadata.

insert into public.categories (title, slug, short_description, status, priority)
values
  ('Housing', 'housing', 'Renting, housing support and tenant rights.', 'draft', 10),
  ('Work', 'work', 'Jobs, employment contracts, pay and workplace rights.', 'draft', 20),
  ('Documents', 'documents', 'BSN, BRP, DigiD and residence documents.', 'draft', 30),
  ('Healthcare', 'healthcare', 'GPs, hospitals, pharmacies and health insurance.', 'draft', 40),
  ('Education', 'education', 'Schools, vocational and higher education.', 'draft', 50),
  ('Language learning', 'language-learning', 'Dutch courses, NT2 and language support.', 'draft', 60),
  ('Government', 'government', 'National government services and authorities.', 'draft', 70),
  ('Banking', 'banking', 'Bank accounts, payments and financial-service routes.', 'draft', 80),
  ('Taxes', 'taxes', 'Tax returns, assessments and Tax Administration routes.', 'draft', 90),
  ('Benefits', 'benefits', 'Housing, healthcare, childcare and child benefits.', 'draft', 100),
  ('SIM & telecom', 'sim-telecom', 'SIM cards, mobile subscriptions and telecom rights.', 'draft', 110),
  ('Internet', 'internet', 'Home internet, installation and provider switching.', 'draft', 120),
  ('Utilities', 'utilities', 'Energy, water, meters and utility contracts.', 'draft', 130),
  ('Transport', 'transport', 'Public transport, cycling, driving and parking.', 'draft', 140),
  ('Rules', 'rules', 'National and municipal rules and permits.', 'draft', 150),
  ('Fines', 'fines', 'Traffic, parking and waste fines and objections.', 'draft', 160),
  ('Legal help', 'legal-help', 'Legal information, advice and representation routes.', 'draft', 170),
  ('Family', 'family', 'Family records, relationships and family migration.', 'draft', 180),
  ('Children', 'children', 'Birth, childcare, school and youth services.', 'draft', 190),
  ('Safety', 'safety', 'Police, crime reports, scams and domestic safety.', 'draft', 200),
  ('Emergency', 'emergency', 'Immediate danger and verified emergency routes.', 'draft', 210),
  ('Shopping', 'shopping', 'Consumer rights, returns and warranties.', 'draft', 220),
  ('Daily life', 'daily-life', 'Practical everyday services and routines.', 'draft', 230),
  ('Pets', 'pets', 'Registration, veterinary care and local pet rules.', 'draft', 240),
  ('Business', 'business', 'Starting and operating a business.', 'draft', 250),
  ('Integration', 'integration', 'Civic integration duties, routes and exams.', 'draft', 260),
  ('Municipal services', 'municipal-services', 'Registration, moving and local public services.', 'draft', 270)
on conflict (slug) do nothing;

alter table public.articles
  add column if not exists canonical_title text,
  add column if not exists subcategory text,
  add column if not exists search_intents text[] not null default '{}',
  add column if not exists search_synonyms text[] not null default '{}',
  add column if not exists search_keywords text[] not null default '{}',
  add column if not exists supported_languages text[] not null default '{}',
  add column if not exists country_scope text not null default 'NL',
  add column if not exists scope_level text not null default 'national',
  add column if not exists municipality text,
  add column if not exists national_fallback boolean not null default true,
  add column if not exists applicable_profiles text[] not null default '{}',
  add column if not exists source_urls text[] not null default '{}',
  add column if not exists content_quality_score integer not null default 0,
  add column if not exists search_indexed boolean not null default false;

-- The legacy publication gate correctly rejects out-of-session writes to a
-- published article. This bounded metadata backfill must not impersonate an
-- admin, enqueue a new publication, or change updated_at.
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
