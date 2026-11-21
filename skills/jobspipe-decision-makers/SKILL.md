---
name: jobspipe-decision-makers
description: Find and verify the people who own a role or a budget at a target account. Use when the user needs the people who own a role or a budget at a target account.
---

# Decision-Maker Finder

Find and verify the people who own a role or a budget at a target account. Category: Recruiting. Invoke as `/jobspipe:decision-makers`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-decision-makers/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_company`, `people_search`, `search_jobs`, `fetch`. Only some runs need `enrich_email`, `enrich_phone`: check for those when the user asks for what they do.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- A company domain and the function to reach, for example 'data engineering' or 'RevOps'.

## Steps
1. Call `resolve_company` with the company's domain and keep its `key` and `domain`. Check the returned `name` and `linkedin_url` are the company the user means: a domain on a hosting platform (for example notion.so) can return a tenant of that platform. If the record is wrong or answers `company_not_found`, try the company's other domain or its exact name. Accept a record whose `name` and `linkedin_url` match even if its stored `domain` differs from the one the user gave. If none matches, stop, tell the user JobsPipe does not cover that company yet, and name the candidates you checked.
2. Call `people_search` with `titles` for leadership in the function (for data: Head of Data, VP Data, Director of Data, Data Engineering Manager) and `company` set to the domain whose `resolve_company` lookup returned the right company (for Notion, notion.com, not notion.so); if the right company was only found by its name, use the domain the user gave. Without `more` it is free and lists the hiring contacts the company's postings name. To find title holders, tell the user it costs 10 credits for each person new to this account, and only after a yes call it again with `more: true`.
3. Call `search_jobs` with `company_key_or: [key]`, `posted_at_max_age_days: 90`, `include_total_results: true` and `limit: 25` and `job_title_or` for the function, then `fetch` the most senior ones. If a posting names who the role reports to, quote it; most do not, and you must never infer a reporting line. Never filter a company by `company_name_or`: unrelated companies share names. Drop any row whose `company_domain` is neither the resolved record's `domain` nor a subdomain of it (careers.datadoghq.com counts as datadoghq.com).
4. Only if the user asks, call `enrich_email` (or `enrich_phone`) with a person's `person_id` and `company`. Say the credit cost first: 50 credits for a work email, 20 for a personal email and 199 for a phone, charged only when one is found.

## Output
- A table: name, title, profile link, why they own the decision, and the posting that supports it. Fewer rows is fine: never pad it.

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
