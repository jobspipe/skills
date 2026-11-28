---
name: jobspipe-email-enrich
description: A list of people to their work emails and phones, each marked verified or not. Use when the user has people and needs their work emails or phones.
---

# Email Enrichment

A list of people to their work emails and phones, each marked verified or not. Category: Sales & GTM. Invoke as `/jobspipe:email-enrich`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-email-enrich/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `resolve_people`, `enrich_email`. Only some runs need `enrich_phone`: check for those when the user asks for what they do.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- A list of people: LinkedIn URLs, or full names with company domains. If the list is not attached, ask for it.

## Steps
1. Call `get_account_info` and tell the user the most the run can cost: 50 credits for a work email, 20 for a personal email and 199 for a phone, charged only when one is found (phones only if asked). Nothing found costs nothing, and a contact this account revealed before is free.
2. Call `resolve_people` with the list to give each row a person id. It is free and only checks that a row names someone; whether that person can be found is decided in the next step. Mark any row it calls invalid.
3. For each row, call `enrich_email` with `type: "work"` and its `linkedin_url`, or its `full_name` and `domain`, and keep each result's `status` and `verified` value. A lookup can take up to a minute, longest when nothing is found. If a call times out or errors, retry it once: a retry never charges twice. If it fails again, mark the row as not checked.
4. Only if the user asks for phones, call `enrich_phone` the same way.
5. Mark any row with nothing found instead of guessing. Never guess an email from a name pattern, and never use a posting's recruiter email as a person's email.

## Output
- The same list with columns added: work email, verified (true, false or unknown), phone if requested, and credits charged.

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
