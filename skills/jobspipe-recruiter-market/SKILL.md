---
name: jobspipe-recruiter-market
description: Who is hiring your profile right now: comp bands, seniority mix and the roles heating up. Use when the user wants to know who is hiring for a profile, at what level and pay.
---

# Recruiter Market Map

Who is hiring your profile right now: comp bands, seniority mix and the roles heating up. Category: Recruiting. Invoke as `/jobspipe:recruiter-market`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-recruiter-market/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `search_jobs`, `search_hiring_companies`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- A role or profile (for example 'senior data engineer') and a location or 'remote'.

## Steps
1. Call `search_jobs` with `job_title_or` for the role, `job_seniority_or` if a level is given (entry_level, mid_level, senior, director, executive), `city_or` or `job_country_code_or` for the place, `posted_at_max_age_days: 30`, `include_total_results: true` and `limit: 25`. Read the titles and add `job_title_not` for any false positives, then run it again.
2. Run the same search with `min_salary_usd: 1` to get only postings that publish a salary, paging with `cursor` for up to 4 pages. Say what share of postings publish one.
3. Call `search_hiring_companies` with the same filters, `employer_type_not: ["agency", "broker"]`, `known_company_only: true` and `order_by: "jobs"` to rank the employers hiring most. List staffing agencies separately if the user wants them.
4. Summarize the salary ranges in the currency posted, grouped by seniority when the search covers more than one level.
5. For trends, count the same search over two windows: `posted_at_max_age_days: 30`, then `posted_at_gte`/`posted_at_lte` for the 30 days before, each with `limit: 1` and `include_total_results: true`. Do the same for 2 or 3 skills with `description_or`.

## Output
- Top 15 hiring employers with open-role counts (agencies left out).
- Salary ranges by seniority, only from posted salaries, with the share that post one.
- Three trends, each backed by the two counts it compares.

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
