-- Canonical deterministic queue ordering for exact offset pagination. RLS on
-- content_review_tasks remains the authorization boundary through the
-- security-invoker view.

create index if not exists content_review_tasks_admin_queue_idx
  on public.content_review_tasks (
    (case severity
      when 'critical' then 0
      when 'high' then 1
      when 'medium' then 2
      else 3
    end),
    sla_due_at,
    id
  )
  where resolved_at is null;

create or replace view public.admin_review_queue
with (security_invoker = true)
as
select
  task.id,
  task.governance_state_id,
  task.owner_id,
  task.reason,
  task.severity,
  case task.severity
    when 'critical' then 0
    when 'high' then 1
    when 'medium' then 2
    else 3
  end as severity_rank,
  task.state,
  task.sla_due_at,
  task.resolved_at,
  task.created_at,
  task.updated_at
from public.content_review_tasks task
where task.resolved_at is null;

revoke all on table public.admin_review_queue from public, anon, authenticated;
grant select on table public.admin_review_queue to authenticated, service_role;

comment on view public.admin_review_queue is
  'Security-invoker Admin review queue. Consumers order by severity_rank, sla_due_at and id before pagination.';
