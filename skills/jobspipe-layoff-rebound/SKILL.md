---
name: jobspipe-layoff-rebound
description: Who cut staff, and who is already re-hiring the cut roles. A displacement window, timed. Use when the user wants companies that cut staff and are now re-hiring, a window to sell or recruit.
---

# Layoff Rebound

Who cut staff, and who is already re-hiring the cut roles. A displacement window, timed. Category: Signals. Invoke as `/jobspipe:layoff-rebound`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-layoff-rebound/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `search_layoffs`, `search_jobs`, `create_signal`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- A time window (default 90 days) and optional US states.

## Steps
1. Call `search_layoffs` with `notice_date_gte` (today minus the window), `states` if given, `min_employees` if the user wants only large cuts and `limit: 25`, paging with `offset` only if the user wants more. It covers US WARN notices only. Drop notices whose `company` is null and say how many were dropped (the same employer can appear both matched and unmatched).
2. For each matched company, call `search_jobs` with `company_key_or: [company.key]`, `posted_at_gte` set to the notice date and `include_total_results: true`, once company-wide and once with `city_or` (or `region_or`) set to the notice's place.
3. WARN notices give headcount, place and kind, not the roles cut. Flag re-hiring at or near the notice location from the second count, and say plainly that the functions cut are not in the data.
4. Offer to save it with `create_signal` (`mode: "jobs"`, `company_key_or` set to the companies, the user's destination, an `idempotency_key`) so new re-hiring is reported as it happens. Each delivered match costs 1 credit.

## Output
- A table: company, notice date, place and size, roles now open, re-hiring at or near the cut site, and days since the notice.

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
