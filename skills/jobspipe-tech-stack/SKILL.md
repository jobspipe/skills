---
name: jobspipe-tech-stack
description: Companies that posted for a stack in the last 30 days, ranked with the evidence post. Use when the user wants companies that use or are adopting a technology.
---

# Tech-Stack Prospecting

Companies that posted for a stack in the last 30 days, ranked with the evidence post. Category: Sales & GTM. Invoke as `/jobspipe:tech-stack`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-tech-stack/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_technologies`, `search_companies_by_technology`, `search_jobs`, `search_hiring_companies`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- One or more technologies (for example 'Snowflake, dbt') and optional ICP filters.

## Steps
1. Call `resolve_technologies` with the names. Use the slugs that match exactly, check any prefix match before using it, and note the result's `as_of` date.
2. Call `search_companies_by_technology` with `company_technology_slug_and` (all of them) or `company_technology_slug_or` (any), `tier_min: "confirmed"`, `include_sample_jobs: true` and `order_by: [{ "field": "num_jobs_found", "desc": true }]`. `num_jobs_found` counts postings that name the technology; `num_jobs_last_30_days` counts all of a company's postings. Large consultancies lead this list because they hire for every stack: say so.
3. Call `search_jobs` with `skills_or` for the first technology and `description_or` for the others (not `description_phrase_or`, which misses short names like dbt), `posted_at_max_age_days: 30` and `employer_type_not: ["agency", "broker"]`: hiring for a tool is the strongest adoption signal.
4. Rank with `search_hiring_companies` using the step 3 filters, `known_company_only: true` and `order_by: "jobs"`. For each ranked company, call `search_jobs` with `company_key_or: [key]`, the step 3 filters and `limit: 3`, and take its strongest posting.

## Output
- A ranked list: company, stack evidence (tier and posting counts), number of recent postings, the strongest posting with its date and link, and the technology index date.

## Rules
- Use only what JobsPipe returns. Cite every posting by title, company, date and link.
- Never invent people, emails, phones, salaries or hiring facts. A missing tool or a missing input is not an empty result: never fill the output with placeholders, guesses or names you remember. A shorter answer is better than a padded one.
- If a call returns nothing, say so.
- Titles match loosely ("Head of Data" also finds "Head of Data Center"). Read the results and exclude false matches before you count or rank them.
- Leave staffing agencies and job boards out of company rankings with `employer_type_not: ["agency", "broker"]` unless the user wants them.
- Say how old the data is when it matters: a profile's `history_since`, a technology index's `as_of`.
- Before a run that touches more than 10 companies or reveals contacts, call `get_account_info` and tell the user what it will cost.
- If an ICP from the ICP Builder skill is in the conversation, filter and rank with it.
- Unsure what a filter accepts? Call `search_documentation`. If the data looks wrong, report it with `give_feedback`.
