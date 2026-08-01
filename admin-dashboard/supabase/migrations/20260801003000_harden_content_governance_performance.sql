-- Follow-up hardening for the content-governance platform.
-- Keep the original rollout migration immutable while optimizing foreign-key
-- maintenance and evaluating role checks once per statement.

create index if not exists content_governance_state_owner_idx
  on public.content_governance_state (content_owner_id);
create index if not exists content_governance_state_reviewed_by_idx
  on public.content_governance_state (reviewed_by);
create index if not exists content_governance_state_second_reviewed_by_idx
  on public.content_governance_state (second_reviewed_by);
create index if not exists content_governance_versions_actor_idx
  on public.content_governance_versions (actor_id);
create index if not exists content_review_events_governance_state_idx
  on public.content_review_events (governance_state_id);
create index if not exists content_review_events_task_idx
  on public.content_review_events (task_id);
create index if not exists content_review_tasks_owner_idx
  on public.content_review_tasks (owner_id);
create index if not exists content_review_tasks_source_issue_idx
  on public.content_review_tasks (source_issue_id);
create index if not exists governance_action_receipts_state_idx
  on public.governance_action_receipts (governance_state_id);
create index if not exists governance_feature_flags_changed_by_idx
  on public.governance_feature_flags (changed_by);
create index if not exists research_consents_created_by_idx
  on public.research_consents (created_by);
create index if not exists research_observations_recorded_by_idx
  on public.research_observations (recorded_by);
create index if not exists research_observations_session_idx
  on public.research_observations (research_session_id);

drop policy if exists "approved admins read governance state"
  on public.content_governance_state;
create policy "approved admins read governance state"
on public.content_governance_state for select to authenticated
using ((select private.governance_current_admin_role()) is not null);

drop policy if exists "approved admins read governance versions"
  on public.content_governance_versions;
create policy "approved admins read governance versions"
on public.content_governance_versions for select to authenticated
using ((select private.governance_current_admin_role()) is not null);

drop policy if exists "approved admins read source checks"
  on public.source_check_attempts;
create policy "approved admins read source checks"
on public.source_check_attempts for select to authenticated
using ((select private.governance_current_admin_role()) is not null);

drop policy if exists "approved admins read review tasks"
  on public.content_review_tasks;
create policy "approved admins read review tasks"
on public.content_review_tasks for select to authenticated
using ((select private.governance_current_admin_role()) is not null);

drop policy if exists "approved admins read review events"
  on public.content_review_events;
create policy "approved admins read review events"
on public.content_review_events for select to authenticated
using ((select private.governance_current_admin_role()) is not null);

drop policy if exists "owners and admins manage governance flags"
  on public.governance_feature_flags;
drop policy if exists "approved admins read governance flags"
  on public.governance_feature_flags;

create policy "approved admins read governance flags"
on public.governance_feature_flags for select to authenticated
using ((select private.governance_current_admin_role()) is not null);
create policy "owners and admins insert governance flags"
on public.governance_feature_flags for insert to authenticated
with check ((select private.governance_current_admin_role()) in ('owner', 'admin'));
create policy "owners and admins update governance flags"
on public.governance_feature_flags for update to authenticated
using ((select private.governance_current_admin_role()) in ('owner', 'admin'))
with check ((select private.governance_current_admin_role()) in ('owner', 'admin'));
create policy "owners and admins delete governance flags"
on public.governance_feature_flags for delete to authenticated
using ((select private.governance_current_admin_role()) in ('owner', 'admin'));

drop policy if exists "approved researchers read research consent"
  on public.research_consents;
drop policy if exists "approved researchers manage research consent"
  on public.research_consents;
create policy "approved researchers read research consent"
on public.research_consents for select to authenticated
using ((select private.governance_current_admin_role()) in ('owner', 'admin', 'qa'));
create policy "approved researchers create research consent"
on public.research_consents for insert to authenticated
with check (
  (select private.governance_current_admin_role()) in ('owner', 'admin', 'qa')
  and created_by = (select auth.uid())
);

drop policy if exists "approved researchers read observations"
  on public.research_observations;
create policy "approved researchers read observations"
on public.research_observations for select to authenticated
using ((select private.governance_current_admin_role()) in ('owner', 'admin', 'qa'));
