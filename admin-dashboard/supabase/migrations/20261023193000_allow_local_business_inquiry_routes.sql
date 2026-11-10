-- Align the database boundary with the already reviewed EN/NL local-business
-- forms. This is additive: existing inquiry rows and receipts are unchanged.

begin;

alter table public.business_inquiries
  drop constraint if exists business_inquiries_source_page_check;

alter table public.business_inquiries
  add constraint business_inquiries_source_page_check check (
    source_page in (
      '/business/apply/',
      '/partners/apply/',
      '/for-business/local/apply/',
      '/nl/voor-bedrijven/aanmelden/'
    )
  ) not valid;

alter table public.business_inquiries
  validate constraint business_inquiries_source_page_check;

do $migration$
declare
  v_definition text;
  v_old_clause constant text :=
    'or v_source_page not in (''/business/apply/'', ''/partners/apply/'')';
  v_new_clause constant text :=
    'or v_source_page not in (''/business/apply/'', ''/partners/apply/'', ''/for-business/local/apply/'', ''/nl/voor-bedrijven/aanmelden/'')';
begin
  select pg_get_functiondef('public.submit_business_inquiry(jsonb,text)'::regprocedure)
  into v_definition;

  if position(v_new_clause in v_definition) > 0 then
    return;
  end if;
  if position(v_old_clause in v_definition) = 0 then
    raise exception 'submit_business_inquiry source-page validation has drifted';
  end if;

  execute replace(v_definition, v_old_clause, v_new_clause);
end
$migration$;

comment on constraint business_inquiries_source_page_check on public.business_inquiries is
  'Accepted reviewed browser entry points. The server RPC enforces the same bounded list.';

commit;
