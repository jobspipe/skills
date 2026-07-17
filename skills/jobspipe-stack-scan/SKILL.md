---
name: jobspipe-stack-scan
description: Detect the technologies a company runs (frameworks, CDNs, analytics, payments) by scanning its domain with the JobsPipe API. Use for technographics, sales intelligence, competitor research, or qualifying whether a company uses a specific tool.
---

# JobsPipe tech-stack scan

Scan any domain on demand and get back the technologies detected on it, with
confidence scores and the signals behind each detection.

Base URL: `https://api.jobspipe.dev`. Requires a Bearer API key (prefix
`jp_live_`) — free at https://jobspipe.dev/signup.

## Scan

`POST /v1/stack/scan` with `{ "domain": "<domain>" }`. Optional `mode`:
`auto` (default: fast HTTP fetch, headless render if the page is thin),
`html`, or `render`.

```bash
curl -s https://api.jobspipe.dev/v1/stack/scan \
  -H "Authorization: Bearer $JOBSPIPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{ "domain": "stripe.com" }'
```

CLI equivalent (`npm i -g jobspipe-cli`):

```bash
jobspipe stack stripe.com
jobspipe stack vercel.com --mode render
```

## Response shape

```json
{
  "domain": "stripe.com",
  "scanned_at": "2026-06-25T12:00:00.000Z",
  "http_status": 200,
  "render_path": "curl_cffi",
  "detected": [
    {
      "slug": "react",
      "name": "React",
      "categories": ["JavaScript frameworks"],
      "confidence": 95,
      "version": null,
      "signals": [{ "kind": "script", "match": "react.production.min.js" }],
      "website": "https://react.dev",
      "pricing": ["open source"],
      "saas": false,
      "oss": true
    }
  ]
}
```

Scans are cached for about 14 days; a repeat within the window is served from
cache and still costs one request.

## Errors

`400` invalid domain, `401` bad key, `402` quota exceeded, `429` rate limit,
`502` scanner failed (retry with `"mode": "render"`), `504` timeout (retry).

Combine with job search for hiring-based buying signals: a company posting
roles that mention a technology plus a stack scan confirming it is a strong
intent signal. Full reference: https://docs.jobspipe.dev
