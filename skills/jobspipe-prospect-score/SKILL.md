---
name: jobspipe-prospect-score
description: Score a book or a list by ICP fit from live hiring and stack signals. Use when the user wants a list of accounts ranked by fit and timing.
---

# Prospect Scoring

Score a book or a list by ICP fit from live hiring and stack signals. Category: Sales & GTM. Invoke as `/jobspipe:prospect-score`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-prospect-score/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_company`, `get_company_profile`, `get_company_tech_stack`, `search_jobs`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- A list of company domains, and the ICP. If there is no ICP in the conversation, ask the user to run ICP Builder first: do not invent one.

## Steps
1. Call `get_account_info` and tell the user the cost first: about four calls per company.
2. For each domain, follow this lookup: call `resolve_company` with the company's domain and keep its `key` and `domain`. Check the returned `name` and `linkedin_url` are the company the user means: a domain on a hosting platform (for example notion.so) can return a tenant of that platform. If the record is wrong or answers `company_not_found`, try the company's other domain or its exact name. Accept a record whose `name` and `linkedin_url` match even if its stored `domain` differs from the one the user gave. If none matches, stop, tell the user JobsPipe does not cover that company yet, and name the candidates you checked.
3. Call `get_company_profile` with each key and `sections: ["header", "facts"]`, and `get_company_tech_stack` with each company's `key` as `company` and `tier_min: "confirmed"`.
4. Call `search_jobs` per company with `company_key_or: [key]`, `posted_at_max_age_days: 30`, `include_total_results: true` and the ICP's buying-signal titles in `job_title_or`. Count distinct postings, merging the same title posted on several sources or in several cities.
5. Score fit 0-50 (size band 0-15, overlap with the ICP's must-have stack 0-25, industry 0-10) and timing 0-50 (distinct matching postings in 30 days: 0 is 0, 1-2 is 15, 3-5 is 30, 6 or more is 50).

## Output
- The list sorted by total score, with fit, timing, and the single posting that drove the timing score.

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
