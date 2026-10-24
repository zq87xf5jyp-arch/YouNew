import { SourceError } from './collect.mjs';

const validTime = value => typeof value === 'string' && Number.isFinite(Date.parse(value))
  && new Date(value).toISOString() === value;
const sameBinding = (a, b) => a && b && a.accountId === b.accountId && a.environment === b.environment && a.source === b.source;

// Previous state is accepted only from an integrity-verified immutable report.
// This tracks completed collection, never a worker run or financial completeness.
export function synchronizationState({ attemptedAt, completedAt, accountingReviewedAt, provider, providerCompletedAt, scope, commerce, commerceConfig, previous }) {
  if (!validTime(attemptedAt) || !validTime(completedAt) || completedAt < attemptedAt) throw new SourceError('synchronization_clock_invalid');
  function source(name, binding, status, successAt) {
    if (successAt && (!validTime(successAt) || successAt < attemptedAt || successAt > completedAt)) throw new SourceError('synchronization_clock_invalid');
    const prior = previous?.version === 1 ? previous[name] : null;
    let priorSuccess = null;
    if (sameBinding(prior?.binding, binding) && prior.lastSuccessfulAt !== null) {
      if (!validTime(prior.lastSuccessfulAt) || !validTime(previous.completedAt)
        || prior.lastSuccessfulAt > previous.completedAt || prior.lastSuccessfulAt > completedAt) throw new SourceError('previous_synchronization_time_invalid');
      priorSuccess = prior.lastSuccessfulAt;
    }
    return { binding, status, attemptedAt: status === 'disabled' ? null : attemptedAt, completedAt: status === 'disabled' ? null : completedAt,
      currentSuccessfulAt: successAt, lastSuccessfulAt: successAt ?? priorSuccess };
  }
  return { version: 1, attemptedAt, completedAt, accountingReviewedAt,
    stripe: source('stripe', scope ? { source: 'stripe-scoped-payments', accountId: scope.accountId, environment: scope.environment } : null,
      provider.status, provider.status === 'scoped_read_complete' ? providerCompletedAt : null),
    commerce: source('commerce', commerceConfig?.expectedAccountId ? { source: 'arrival-commerce-diagnostics', accountId: commerceConfig.expectedAccountId, environment: commerceConfig.environment } : null,
      commerce.status, commerce.status === 'observed' ? commerce.observedAt : null) };
}

export function synchronizationLines(state) {
  const line = (name, value) => `${name} (${value.binding?.environment ?? 'среда не установлена'}): попытка ${value.attemptedAt ?? 'не выполнялась — источник отключён'}; результат ${value.status}; последнее успешное чтение ${value.lastSuccessfulAt ?? 'не подтверждено'}.${value.lastSuccessfulAt && !value.currentSuccessfulAt ? ' Успех относится к прежнему чтению; текущие данные не подтверждены.' : ''}`;
  return [`Попытка отчёта: ${state.attemptedAt}; завершение: ${state.completedAt}; исходная бухгалтерская проверка: ${state.accountingReviewedAt ?? 'не подтверждена'}.`,
    line('Stripe — разрешённая выборка', state.stripe), line('Arrival Commerce — диагностика', state.commerce),
    'Успешное чтение не подтверждает полноту учёта, банковские поступления или работу worker. Sandbox не входит в доход.'];
}
