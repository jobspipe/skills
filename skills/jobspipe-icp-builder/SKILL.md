---
name: jobspipe-icp-builder
description: Paste one company and get the ICP, persona and voice config every other skill reads. Use when the user wants an ideal customer profile, a persona or a writing voice for outreach, or before running any other JobsPipe skill.
---

# ICP Builder

Paste one company and get the ICP, persona and voice config every other skill reads. Category: Recruiting. Invoke as `/jobspipe:icp-builder`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-icp-builder/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_company`, `get_company_profile`, `get_company_tech_stack`, `search_jobs`, `search_companies_by_technology`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- One company: a domain (stripe.com). Usually the user's own company or their best customer. If none is given, ask for it.

## Steps
1. Call `resolve_company` with the company's domain and keep its `key` and `domain`. Check the returned `name` and `linkedin_url` are the company the user means: a domain on a hosting platform (for example notion.so) can return a tenant of that platform. If the record is wrong or answers `company_not_found`, try the company's other domain or its exact name. Accept a record whose `name` and `linkedin_url` match even if its stored `domain` differs from the one the user gave. If none matches, stop, tell the user JobsPipe does not cover that company yet, and name the candidates you checked.
2. Call `get_company_profile` with the key and `sections: ["header", "facts", "trends", "peers"]`. Size is in `header`, growth is `trends.share_index.recent_vs_prior`, and the team mix is `trends.function_mix`.
3. Call `get_company_tech_stack` with the company's `key` as `company` and `tier_min: "confirmed"` (without it a large company returns hundreds of technologies).
4. Call `search_jobs` with `company_key_or: [key]`, `posted_at_max_age_days: 90`, `include_total_results: true` and `limit: 25`, then read which teams and seniorities the postings are for. Never filter a company by `company_name_or`: unrelated companies share names. Drop any row whose `company_domain` is not the resolved record's `domain`.
5. For lookalikes, use the `peers` section from step 2. If it is empty, call `search_companies_by_technology` with `company_technology_slug_and` set to 2 or 3 of the company's most distinctive confirmed technologies, `tier_min: "confirmed"`, `min_employee_count` and `max_employee_count` around its size (drop any row outside that range), and its headquarters country in `company_country_code_or`. Call these stack matches, not lookalikes. The suggest_companies tool only autocompletes names: never use it for lookalikes.
6. Write the ICP from that evidence only: firmographics, must-have stack, hiring patterns that signal buying intent, and disqualifiers. Then one buyer persona and a short voice guide.

## Output
- An `ICP` block in Markdown: Industries, Company size, Regions, Must-have stack, Buying signals in postings, Disqualifiers, and up to 10 peer or stack-matched companies, labelled as which they are.
- A `Persona` block and a `Voice` block.
- Tell the user to keep this ICP in the project or chat memory: every other JobsPipe skill reads it.

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
