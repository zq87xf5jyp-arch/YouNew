// Only a local UTC date, never a persistent person/device identifier.
export const guideVisitKey = 'younew.guide-last-visit.2026-11-11';
export function returningWithinWindow(previous: string | null, today: string): boolean {
  if (!previous || !/^\d{4}-\d{2}-\d{2}$/.test(previous)) return false;
  const days=(Date.parse(today)-Date.parse(previous))/86400000;
  return Number.isInteger(days) && days>=7 && days<=30;
}
