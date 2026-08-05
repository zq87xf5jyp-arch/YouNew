begin;

-- Legacy composite categories remain available to Admin history, but every one
-- points at the single canonical category used by search and future content.
alter table public.categories
  add column if not exists canonical_category_id uuid
    references public.categories(id) on delete restrict;

alter table public.categories
  drop constraint if exists categories_canonical_category_not_self_check,
  add constraint categories_canonical_category_not_self_check
    check (canonical_category_id is null or canonical_category_id <> id);

create index if not exists categories_canonical_category_id_idx
  on public.categories (canonical_category_id)
  where canonical_category_id is not null;

do $migration$
declare
  v_documents_id uuid;
  v_transport_id uuid;
  v_fines_id uuid;
begin
  select id into strict v_documents_id from public.categories where slug = 'documents';
  select id into strict v_transport_id from public.categories where slug = 'transport';
  select id into strict v_fines_id from public.categories where slug = 'fines';

  update public.categories legacy
  set canonical_category_id = canonical.id,
      status = 'archived',
      published_at = null
  from public.categories canonical
  where (legacy.slug, canonical.slug) in (
    ('documents-services', 'documents'),
    ('work-taxes', 'work'),
    ('rules-fines', 'fines')
  );

  -- These are metadata-only backfills for the three existing reviewed content
  -- records. No draft/review item is promoted and no factual body is changed.
  -- The publication triggers are disabled only for this bounded migration
  -- because migrations do not have an end-user JWT; the existing published row
  -- already has an approved reviewer, source mapping and passed validation.
  alter table public.articles disable trigger enforce_article_publication_gate;
  alter table public.articles disable trigger articles_search_metadata_gate;
  alter table public.articles disable trigger enqueue_article_publication;
  alter table public.articles disable trigger set_updated_at;

  update public.articles
  set category_id = v_documents_id,
      subcategory = 'registration-and-bsn',
      search_intents = array['documents', 'government'],
      search_synonyms = array[
        'bsn', 'brp', 'digid', 'municipality registration', 'address registration',
        'gemeente inschrijving', 'adresregistratie', 'burgerservicenummer',
        'регистрация', 'регистрация адреса', 'муниципалитет', 'номер bsn'
      ],
      search_keywords = array[
        'bsn', 'brp', 'digid', 'registration', 'municipality', 'rni',
        'residence registration', 'change address'
      ],
      applicable_profiles = array['student', 'expat', 'refugee', 'worker', 'resident'],
      content_quality_score = 50,
      search_indexed = true
  where id = '469dbf9f-0045-4718-8023-7f1a28547e56'::uuid
    and title = 'Регистрация в муниципалитете'
    and status = 'published'
    and official_source is true
    and validation_passed is true
    and reviewer_id is not null
    and reviewed_at is not null;

  if not found then
    raise exception 'reviewed municipality-registration article was not in the expected production state';
  end if;

  update public.articles
  set category_id = v_transport_id,
      subcategory = 'public-transport-payments',
      search_intents = array['transport'],
      search_synonyms = array[
        'ovpay', 'public transport', 'contactless check in', 'contactless check out',
        'openbaar vervoer', 'inchecken', 'uitchecken',
        'общественный транспорт', 'оплата проезда', 'банковская карта'
      ],
      search_keywords = array['ovpay', 'train', 'bus', 'tram', 'metro', 'check-in', 'check-out'],
      applicable_profiles = array['tourist', 'student', 'expat', 'refugee', 'worker', 'resident'],
      content_quality_score = 25,
      search_indexed = false
  where id = '9009fb71-23b1-45fd-85e4-7ff65e540563'::uuid
    and title = 'OVpay и общественный транспорт'
    and status = 'review';

  if not found then
    raise exception 'OVpay review article was not in the expected production state';
  end if;

  update public.articles
  set category_id = v_fines_id,
      subcategory = 'fine-payments-and-objections',
      search_intents = array['rules-fines'],
      search_synonyms = array[
        'fine', 'fines', 'traffic fine', 'parking fine', 'waste fine',
        'boete', 'verkeersboete', 'parkeerboete',
        'штраф', 'штрафы', 'дорожный штраф', 'штраф за парковку'
      ],
      search_keywords = array['cjib', 'fine', 'payment', 'objection', 'traffic', 'parking'],
      applicable_profiles = array['tourist', 'student', 'expat', 'refugee', 'worker', 'resident'],
      content_quality_score = 20,
      search_indexed = false
  where id = '5f435c43-d4be-4ea8-b22a-8dd06b5e43c9'::uuid
    and title = 'Что делать с голландскими штрафами'
    and status = 'draft';

  if not found then
    raise exception 'Dutch-fines draft article was not in the expected production state';
  end if;

  alter table public.articles enable trigger set_updated_at;
  alter table public.articles enable trigger enqueue_article_publication;
  alter table public.articles enable trigger articles_search_metadata_gate;
  alter table public.articles enable trigger enforce_article_publication_gate;
end
$migration$;

comment on column public.categories.canonical_category_id is
  'Canonical taxonomy target for archived legacy/composite categories; null means this row is canonical.';

commit;
