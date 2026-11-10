export const BUSINESS_INQUIRY_STATUSES = [
  "new",
  "qualified",
  "discovery",
  "proposal",
  "won",
  "lost",
  "archived"
] as const;

export type BusinessInquiryStatus = (typeof BUSINESS_INQUIRY_STATUSES)[number];

export const BUSINESS_INQUIRY_STATUS_LABELS: Record<BusinessInquiryStatus, string> = {
  new: "новая",
  qualified: "квалифицирована",
  discovery: "диагностика",
  proposal: "предложение",
  won: "выиграна",
  lost: "проиграна",
  archived: "архив"
};

export const BUSINESS_INQUIRY_OFFER_INTERESTS = [
  "not_specified",
  "onboarding_pilot",
  "founding_partner_page",
  "sponsored_practical_guide",
  "other"
] as const;

export type BusinessInquiryOfferInterest = (typeof BUSINESS_INQUIRY_OFFER_INTERESTS)[number];

export const BUSINESS_INQUIRY_OFFER_LABELS: Record<BusinessInquiryOfferInterest, string> = {
  not_specified: "не указано",
  onboarding_pilot: "90-дневный onboarding pilot",
  founding_partner_page: "Founding Partner Page",
  sponsored_practical_guide: "Sponsored Practical Guide",
  other: "другое"
};

export const BUSINESS_INQUIRY_LOST_REASONS = [
  "no_observed_problem",
  "existing_solution_sufficient",
  "wrong_owner",
  "no_budget",
  "timing",
  "insufficient_proof",
  "security_privacy",
  "content_trust",
  "price_value",
  "scope_delivery",
  "no_response_after_sequence",
  "other_explicit"
] as const;

export type BusinessInquiryLostReason = (typeof BUSINESS_INQUIRY_LOST_REASONS)[number];

export const BUSINESS_INQUIRY_LOST_REASON_LABELS: Record<BusinessInquiryLostReason, string> = {
  no_observed_problem: "проблема не подтверждена",
  existing_solution_sufficient: "текущее решение достаточно",
  wrong_owner: "не тот владелец решения",
  no_budget: "нет бюджета в периоде теста",
  timing: "неподходящее время",
  insufficient_proof: "недостаточно доказательств",
  security_privacy: "security/privacy не согласованы",
  content_trust: "недостаточно доверия к контенту",
  price_value: "цена не подтверждена ценностью",
  scope_delivery: "не подходит scope/SLA/capacity",
  no_response_after_sequence: "нет ответа после разрешённой серии",
  other_explicit: "другая явно названная причина"
};

export const BUSINESS_INQUIRY_WON_EVIDENCE_TYPES = [
  "paid_pilot",
  "paid_founding_partner_page",
  "signed_paid_trial"
] as const;

export type BusinessInquiryWonEvidenceType = (typeof BUSINESS_INQUIRY_WON_EVIDENCE_TYPES)[number];

export const BUSINESS_INQUIRY_WON_EVIDENCE_LABELS: Record<BusinessInquiryWonEvidenceType, string> = {
  paid_pilot: "оплаченный pilot",
  paid_founding_partner_page: "оплаченная partner page",
  signed_paid_trial: "подписанный платный trial"
};

export function isBusinessInquiryStatus(value: string): value is BusinessInquiryStatus {
  return BUSINESS_INQUIRY_STATUSES.some((status) => status === value);
}

export function isBusinessInquiryOfferInterest(value: string): value is BusinessInquiryOfferInterest {
  return BUSINESS_INQUIRY_OFFER_INTERESTS.some((offer) => offer === value);
}

export function isBusinessInquiryLostReason(value: string): value is BusinessInquiryLostReason {
  return BUSINESS_INQUIRY_LOST_REASONS.some((reason) => reason === value);
}

export function isBusinessInquiryWonEvidenceType(value: string): value is BusinessInquiryWonEvidenceType {
  return BUSINESS_INQUIRY_WON_EVIDENCE_TYPES.some((evidence) => evidence === value);
}
