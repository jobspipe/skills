---
name: jobspipe-hiring-triggers
description: Turn 'who just started hiring for X' into a watch that fires on the exact req and drafts the opener. Use when the user wants to know which companies just started hiring for something and to reach them while it is fresh.
---

# Hiring Triggers

Turn 'who just started hiring for X' into a watch that fires on the exact req and drafts the opener. Category: Sales & GTM. Invoke as `/jobspipe:hiring-triggers`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-hiring-triggers/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `search_hiring_companies`, `search_jobs`, `list_signals`, `create_signal`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- What to watch: a role, a skill or a technology, optionally a region and company size, and the window (default 14 days). Use the ICP if one exists.

## Steps
1. Call `search_hiring_companies` with `skills_or` for a skill or technology (add `job_title_or` when the user names a role), `posted_at_max_age_days` for the window, `employer_type_not: ["agency", "broker"]`, `known_company_only: true`, `order_by: "last_posted"`, `limit: 25` and the ICP filters. Leave out the technology's own vendor and its close partners (for Snowflake: Snowflake itself), and read each posting enough to drop uses that are not the product ("Snowflake schema" is a modelling method).
2. To keep only companies that started hiring for it, run the same search for the 90 days that end where the window starts (`posted_at_gte`/`posted_at_lte`) with `company_key_or` set to those keys, and drop every company that already had matches then. Most active hirers are not new, so if few are left, fetch the next page of step 1 with `cursor` and repeat until you have enough or run out.
3. For each remaining company, call `search_jobs` with `company_key_or: [key]` and the same trigger filters to get the exact posting, its title and posted date.
4. Call `list_signals` to check the watch is not saved already, then `create_signal` with `mode: "companies"` and the same filters, leaving out the `posted_at` ones, `known_company_only` and `order_by` (a signal does not take them), the user's destination and an `idempotency_key`. Tell the user each delivered match costs 1 credit.
5. Draft an opener per company that names the posting and its date and ties it to what the user sells.

## Output
- A table: company, posting title, posted date, link.
- The created signal id and what it watches.
- One opener per company, under 80 words.

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
