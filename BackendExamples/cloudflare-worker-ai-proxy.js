// Cloudflare Worker example for YouNew AI proxy.
// Store OPENAI_API_KEY as an encrypted Worker secret. Do not put API keys in the iOS app.
//
// Rate limiting: 20 requests/hour per IP using Cloudflare KV.
// Bind a KV namespace named "RATE_LIMIT_KV" in your Worker settings.
// CORS: allows requests from any origin (YouNew is a native iOS app, no web origin needed).
// Conversation: includes up to 6 prior turns from the request body for context continuity.

const RATE_LIMIT = 20;
const RATE_WINDOW_SECONDS = 3600;

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export default {
  async fetch(request, env) {
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: CORS_HEADERS });
    }

    if (request.method !== "POST") {
      return json({ error: "method_not_allowed" }, 405);
    }

    // Rate limiting by client IP (requires RATE_LIMIT_KV binding)
    if (env.RATE_LIMIT_KV) {
      const ip = request.headers.get("CF-Connecting-IP") || "unknown";
      const key = `rl:${ip}`;
      const now = Math.floor(Date.now() / 1000);

      let record = { count: 0, windowStart: now };
      const stored = await env.RATE_LIMIT_KV.get(key, { type: "json" });
      if (stored && now - stored.windowStart < RATE_WINDOW_SECONDS) {
        record = stored;
      }

      if (record.count >= RATE_LIMIT) {
        return json({ error: "rate_limit_exceeded" }, 429);
      }

      record.count += 1;
      await env.RATE_LIMIT_KV.put(key, JSON.stringify(record), {
        expirationTtl: RATE_WINDOW_SECONDS,
      });
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: "invalid_json" }, 400);
    }

    const userMessage = String(body.userMessage || "").slice(0, 2000);
    const systemPrompt = String(body.systemPrompt || "");
    const context = body.context || {};

    // Include up to 6 prior conversation turns for continuity
    const conversationHistory = Array.isArray(body.conversation)
      ? body.conversation.slice(-6)
      : [];

    if (!userMessage.trim()) {
      return json({ error: "empty_message" }, 400);
    }

    // Build the input string: system prompt + context + conversation history + current question
    const historyBlock = conversationHistory.length > 0
      ? "Prior conversation:\n" + conversationHistory.map(turn => {
          const role = turn.role === "assistant" ? "Assistant" : "User";
          return `${role}: ${String(turn.content || "").slice(0, 500)}`;
        }).join("\n")
      : "";

    const promptParts = [systemPrompt];
    promptParts.push("App context JSON:\n" + JSON.stringify(context).slice(0, 6000));
    if (historyBlock) promptParts.push(historyBlock);
    promptParts.push("User question:\n" + userMessage);
    promptParts.push("Return JSON with answer, sources, safetyNote and suggestedActions.");

    const prompt = promptParts.join("\n\n");

    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${env.OPENAI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: env.OPENAI_MODEL || "gpt-4.1-mini",
        input: prompt,
        text: {
          format: {
            type: "json_schema",
            name: "younew_ai_response",
            schema: {
              type: "object",
              additionalProperties: false,
              required: ["answer", "sources", "safetyNote", "suggestedActions"],
              properties: {
                answer: { type: "string" },
                sources: {
                  type: "array",
                  items: {
                    type: "object",
                    additionalProperties: false,
                    required: ["title", "url", "institution"],
                    properties: {
                      title: { type: "string" },
                      url: { type: ["string", "null"] },
                      institution: { type: ["string", "null"] },
                    },
                  },
                },
                safetyNote: { type: ["string", "null"] },
                suggestedActions: {
                  type: "array",
                  items: { type: "string" },
                },
              },
            },
          },
        },
      }),
    });

    if (!response.ok) {
      return json(
        { error: "openai_unavailable" },
        response.status === 429 ? 429 : 502
      );
    }

    const data = await response.json();
    const text = data.output_text || "{}";
    try {
      return json(JSON.parse(text), 200);
    } catch {
      return json(
        {
          answer:
            "I couldn't generate a structured answer right now. Please check the official source directly.",
          sources: [],
          safetyNote:
            "YouNew provides informational guidance only. Always verify important information with official institutions.",
          suggestedActions: [],
        },
        200
      );
    }
  },
};

function json(payload, status) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...CORS_HEADERS,
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
  });
}
