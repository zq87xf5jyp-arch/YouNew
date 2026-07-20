# YouNew GPT-5.6 backend reference

This directory contains an undeployed Cloudflare Worker reference for the
`BuildWeekNewcomerDemo` scenario. It calls the OpenAI Responses API and returns
a bounded, structured sequence for BSN, DigiD, Dutch health insurance, and
huisarts registration. The repository does not prove that this Worker has been
deployed or that the configured OpenAI account can access a GPT-5.6 model.

## Contract

- Endpoint: `POST /v1/newcomer-demo`
- Required Worker secret: `OPENAI_API_KEY`
- Required Worker variable: `OPENAI_MODEL`
- Allowed model values: `gpt-5.6` or `gpt-5.6-sol`. The backend returns the
  actually used model. When configured with the `gpt-5.6` alias, it accepts
  only `gpt-5.6` or the confirmed `gpt-5.6-sol` resolution; when configured
  explicitly with `gpt-5.6-sol`, it accepts only that exact model.
- For an unambiguous live-evidence run, configure `OPENAI_MODEL=gpt-5.6-sol`.
  The alias remains supported by this reference, but it is not used to infer a
  provider resolution that the returned metadata does not prove.
- No default model and no silent model fallback
- Scenario: `BuildWeekNewcomerDemo`
- Context version: `newcomer-after-address.v1`

The client request contains only `question`, `locale`, `scenario`,
`contextVersion`, and `knowledgeRecordIDs`. Prompts, facts, official URLs, and
app routes are owned and allowlisted by the Worker. The Worker sends
`store: false`, uses a strict JSON schema, applies request/output limits, and
aborts the upstream request after 12 seconds. The provider response body is
rejected above 128 KiB before JSON parsing. The Worker never logs the request
body or returns provider error text or credentials.

An HTTP-successful provider response is not sufficient for a live answer. The
Worker accepts it only when it is a canonical completed Responses API object:
`object == "response"`, `status == "completed"`, and both `error` and
`incomplete_details` are `null`. Partial, failed, or provider-error responses
become the safe `invalid_upstream_response` error and therefore local guide
fallback in the iOS app.

The reference endpoint does not emit browser CORS permission headers; the native
iOS client does not need them. This is not authentication. Before deployment, add
owner-selected platform rate limits and abuse controls without embedding a shared
secret in the iOS bundle.

The successful public response is:

```json
{
  "summary": "",
  "steps": [
    {
      "title": "",
      "reason": "",
      "action": "",
      "sourceTitle": "",
      "sourceURL": "",
      "appDestination": ""
    }
  ],
  "warnings": [],
  "model": "",
  "requestId": ""
}
```

`model` is copied from the successful OpenAI response after an exact GPT-5.6
allowlist check. `requestId` uses OpenAI's safe `x-request-id` response header
when present and otherwise uses the Worker's generated opaque request ID.

## Local contract tests

No package installation is needed. With a current Node.js runtime:

```sh
cd BackendExamples
npm test
```

Tests mock the upstream network call. They do not use an API key and do not
prove live model access.

## Deployment boundary

Before any owner-approved deployment, create the Worker and configure
`OPENAI_API_KEY` as an encrypted secret plus `OPENAI_MODEL` as a non-secret
variable. Configure abuse controls at the Cloudflare account level. Do not
place the API key in the iOS target, an Info.plist, source code, an `.env` file
committed to Git, or a client-visible response.
