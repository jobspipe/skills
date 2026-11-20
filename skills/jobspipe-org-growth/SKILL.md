---
name: jobspipe-org-growth
description: Which teams scaled and when, rebuilt from a company's posting history. Use when the user wants to know which teams a company has grown and when.
---

# Org-Growth Timeline

Which teams scaled and when, rebuilt from a company's posting history. Category: Signals. Invoke as `/jobspipe:org-growth`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-org-growth/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_company`, `get_company_profile`, `search_jobs`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- A company domain and a period (default 12 months).

## Steps
1. Call `resolve_company` with the company's domain and keep its `key` and `domain`. Check the returned `name` and `linkedin_url` are the company the user means: a domain on a hosting platform (for example notion.so) can return a tenant of that platform. If the record is wrong or answers `company_not_found`, try the company's other domain or its exact name. Accept a record whose `name` and `linkedin_url` match even if its stored `domain` differs from the one the user gave. If none matches, stop, tell the user JobsPipe does not cover that company yet, and name the candidates you checked.
2. Call `get_company_profile` with the key and `sections: ["trends"]` for the recent team mix (`trends.function_mix`). Its counts are measured differently from `search_jobs`, so never put the two side by side.
3. For each month of the period, call `search_jobs` with `company_key_or: [key]`, `status: "any"` (not only postings still open), `posted_at_gte` and `posted_at_lte` for the month, `include_total_results: true` and `limit: 5`. The first month with postings is where JobsPipe's record of this company starts: report from there and say so. Note which sources each month's postings come from.
4. Count by team with one more search per team per month, using `job_title_or` keywords for the team and `job_title_not` so teams do not overlap (for engineering, exclude "Sales Engineer"). Check a sample of titles for each team.
5. Mark the months where a team's hiring jumped and name the roles behind each jump. A rise is a coverage change, not a jump, when it comes in the first month or two of the record, around the profile's `trends.history_since`, or in a month where new sources appear (one careers site before, several job boards after): say so instead. The same role posted on several sources counts once.

## Output
- A month-by-team table of posting counts from the first month on record, and a short timeline of the biggest changes with the postings behind them.

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
