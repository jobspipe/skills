---
name: jobspipe-job-search
description: Search live, normalized job postings from 30+ ATS feeds and job boards (Workday, Greenhouse, Lever, Ashby, LinkedIn) via the JobsPipe API. Use when an agent needs open roles, hiring signals, sourcing data, salary ranges, or location-filtered job listings.
---

# JobsPipe job search

Search live job postings, deduplicated across 30+ sources into one JSON schema.

Base URL: `https://api.jobspipe.dev`. Every request needs a Bearer API key
(prefix `jp_live_`) — free at https://jobspipe.dev/signup (100 credits/month,
1 credit = 1 request).

```bash
export JOBSPIPE_API_KEY=jp_live_YOUR_KEY
```

## Search

`POST /v1/jobs/search`. The body is a JSON object of filters; all fields are
optional and combine with AND. Array filters ending in `_or` match any value.
An empty body returns the most recent postings.

```bash
curl -s https://api.jobspipe.dev/v1/jobs/search \
  -H "Authorization: Bearer $JOBSPIPE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "job_title_or": ["software engineer", "backend engineer"],
    "job_country_code_or": ["US"],
    "remote": true,
    "posted_at_max_age_days": 7,
    "limit": 25,
    "include_total_results": true
  }'
```

CLI equivalent (`npm i -g jobspipe-cli`):

```bash
jobspipe jobs --title "software engineer" --country US --remote --max-age-days 7 --limit 25 --total
```

## Filters

`job_title_or`, `job_title_not`, `description_or` (match a skill or tech in
the description), `description_not`, `job_country_code_or`, `remote`,
`posted_at_max_age_days`, `posted_at_gte` / `posted_at_lte` (`YYYY-MM-DD`),
`company_name_or`, `company_name_partial_match_or`, `job_seniority_or`,
`employment_type_or` (full-time, part-time, contract, temporary, internship),
`source_or`, `limit`, `offset`, `include_total_results`.

## Response shape

```json
{
  "metadata": { "total_results": 412, "truncated_results": 25, "next_cursor": "..." },
  "data": [
    {
      "id": "jp_3958211043",
      "job_title": "Backend Engineer",
      "company": "Acme Inc",
      "company_domain": "acme.com",
      "location": "Remote · United States",
      "country_code": "US",
      "remote": true,
      "seniority": "Mid-Senior",
      "min_annual_salary_usd": 150000,
      "max_annual_salary_usd": 190000,
      "date_posted": "2026-06-18",
      "technology_slugs": ["go", "postgres"],
      "final_url": "https://example.com/careers/3958211043"
    }
  ]
}
```

`limit` is capped by plan (free 25, builder 100, scale 500). Paginate with
`offset` or `metadata.next_cursor` until fewer than `limit` rows return.

## Errors and retries

Errors are JSON `{ "error": "..." }`: `401` bad key, `402` monthly quota
exceeded (check `Retry-After`), `429` per-second rate limit (back off and
retry). Send an `Idempotency-Key` header to make retries safe.

Try without a key first: `POST /v1/sandbox/jobs/search` returns sample data in
the exact live schema. Full reference: https://docs.jobspipe.dev
