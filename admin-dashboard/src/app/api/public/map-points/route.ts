import { publicTableResponse } from "@/lib/public-api";

export async function GET() {
  return publicTableResponse("map_points");
}
