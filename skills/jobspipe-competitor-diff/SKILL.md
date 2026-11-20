---
name: jobspipe-competitor-diff
description: What a competitor is hiring for that you are not, read straight from their postings. Use when the user wants to know what a competitor is building or hiring for.
---

# Competitor Hiring Diff

What a competitor is hiring for that you are not, read straight from their postings. Category: Signals. Invoke as `/jobspipe:competitor-diff`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-competitor-diff/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_company`, `search_jobs`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- The competitor's domain, and the user's own company domain to compare against. If the user says 'we' without naming their company, ask for its domain.

## Steps
1. For the competitor, and for the user's company if given: call `resolve_company` with the company's domain and keep its `key` and `domain`. Check the returned `name` and `linkedin_url` are the company the user means: a domain on a hosting platform (for example notion.so) can return a tenant of that platform. If the record is wrong or answers `company_not_found`, try the company's other domain or its exact name. Accept a record whose `name` and `linkedin_url` match even if its stored `domain` differs from the one the user gave. If none matches, stop, tell the user JobsPipe does not cover that company yet, and name the candidates you checked.
2. Call `search_jobs` with `company_key_or: [key]`, `posted_at_max_age_days: 90`, `include_total_results: true` and `limit: 25` for each company, paging with `cursor` for at most 4 pages (100 postings). If `total_results` is larger, say the diff is from a sample, and count each team with one more search per team (`job_title_or` for the team, `limit: 1`, `include_total_results: true`). Never filter a company by `company_name_or`: unrelated companies share names. Drop any row whose `company_domain` is neither the resolved record's `domain` nor a subdomain of it (careers.datadoghq.com counts as datadoghq.com).
3. Merge the same title posted in several cities or on several sources, then group both companies' postings by team, seniority and named skills or technologies.
4. List what the competitor hires for that the user's company does not, and the reverse.

## Output
- A diff table by team and skill with counts, and three conclusions, each tied to specific postings.

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
