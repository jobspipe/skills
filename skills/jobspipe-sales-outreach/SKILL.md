---
name: jobspipe-sales-outreach
description: The cold email, call script or sequence, opening on one real, dated hiring signal. Use when the user wants a cold email, call script or sequence for a company.
---

# Sales Outreach

The cold email, call script or sequence, opening on one real, dated hiring signal. Category: Sales & GTM. Invoke as `/jobspipe:sales-outreach`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-sales-outreach/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_company`, `search_jobs`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- A company domain, what the user sells, and the channel (email, call or a 3-step sequence). If the user has not said what they sell, ask.

## Steps
1. Call `resolve_company` with the company's domain and keep its `key` and `domain`. Check the returned `name` and `linkedin_url` are the company the user means: a domain on a hosting platform (for example notion.so) can return a tenant of that platform. If the record is wrong or answers `company_not_found`, try the company's other domain or its exact name. Accept a record whose `name` and `linkedin_url` match even if its stored `domain` differs from the one the user gave. If none matches, stop, tell the user JobsPipe does not cover that company yet, and name the candidates you checked.
2. Call `search_jobs` with `company_key_or: [key]`, `posted_at_max_age_days: 30`, `include_total_results: true` and `limit: 25`, plus `job_title_or` built from the team that buys what the user sells (titles find relevant postings far more precisely than `description_or`). If nothing comes back, widen the titles to the wider team, then the window to 90 days, and if there is still nothing, tell the user there is no hiring signal to open on. Never filter a company by `company_name_or`: unrelated companies share names. Drop any row whose `company_domain` is neither the resolved record's `domain` nor a subdomain of it (careers.datadoghq.com counts as datadoghq.com).
3. Pick the one posting most related to what the user sells, preferring one with a `ghost_score` under 30. Note its title, team and posted date.
4. Write the outreach so the first line names that real posting and its date, then connects it to one outcome.

## Output
- The requested email, script or sequence, with the posting it relies on cited underneath (title, date, link).

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
