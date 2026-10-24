export const feedbackStatuses = {
  new: "Новое",
  reviewed: "Просмотрено",
  planned: "Запланировано",
  rejected: "Отклонено",
  resolved: "Решено"
} as const;

export type FeedbackStatus = keyof typeof feedbackStatuses;

export type FeedbackRow = {
  id: string;
  confirmation_code: string | null;
  feedback_type: string | null;
  page_reference: string | null;
  user_email: string | null;
  message: string;
  status: FeedbackStatus;
  resolution_note: string | null;
  resolved_by: string | null;
  created_at: string;
  updated_at: string;
  record_origin?: "user_submission" | "sample" | "synthetic_test" | "legacy_unclassified";
};

export type FeedbackUpdate = Pick<FeedbackRow, "id" | "status" | "resolution_note" | "resolved_by" | "updated_at">;
export type FeedbackActionResult = { ok: true; row: FeedbackUpdate } | { ok: false; message: string };

export function canManageFeedback(role: string) {
  return role === "owner" || role === "admin" || role === "qa";
}
