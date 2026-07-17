---
name: jobspipe-agent-discovery
description: Discover and integrate the JobsPipe API from its machine-readable surfaces - llms.txt, OpenAPI spec, markdown page twins, no-key sandbox, agent auth metadata, and the ARD catalog. Use when an agent needs to explore what JobsPipe offers without reading human docs.
---

# JobsPipe agent discovery surfaces

Every JobsPipe developer resource lives at a predictable URL and has a
machine-readable form. Start here instead of scraping HTML.

## Indexes

- `https://jobspipe.dev/llms.txt` — navigation index for agents: product
  overview, developer resources, machine-readable endpoints.
- `https://jobspipe.dev/.well-known/ai-catalog.json` — ARD catalog listing
  every agentic resource with `urn:air` identifiers.
- `https://jobspipe.dev/.well-known/api-catalog` — RFC 9727 linkset of all
  APIs (request with `Accept: application/linkset+json`).
- `https://jobspipe.dev/?mode=agent` — condensed agent view of the whole
  product (JSON; `Accept: text/markdown` for markdown).

## API description

- `https://jobspipe.dev/openapi.json` (or `.yaml`) — OpenAPI 3.1 for
  `POST /v1/jobs/search` and `POST /v1/stack/scan`, including error model,
  pagination, rate-limit headers, webhooks, and scoped permissions
  (`jobs:read`, `stack:read`).

## Markdown everywhere

Append `.md` to any jobspipe.dev content page or send `Accept: text/markdown`
to get the page as markdown, e.g. `https://jobspipe.dev/developers.md`,
`https://jobspipe.dev/pricing.md`.

## Try before signing up

The sandbox needs no API key and costs nothing:

```bash
curl -s -X POST https://api.jobspipe.dev/v1/sandbox/jobs/search \
  -H "Content-Type: application/json" \
  -d '{"job_title_or":["data engineer"],"remote":true}'
```

Also under `/v1/sandbox`: a batch search (`/jobs/search/batch`) and an async
export demonstrating the 202-plus-poll pattern (`/jobs/export`).

## Agent auth

- `https://api.jobspipe.dev/.well-known/oauth-protected-resource` — RFC 9728
  metadata with `scopes_supported`.
- `https://jobspipe.dev/auth.md` — step-by-step agent registration
  walkthrough, from discovery to a working `jp_live_` key.
