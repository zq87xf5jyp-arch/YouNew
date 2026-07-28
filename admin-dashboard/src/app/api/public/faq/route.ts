import { publicTableResponse } from "@/lib/public-api";

export async function GET() {
  return publicTableResponse("faq_items");
}
