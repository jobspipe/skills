---
name: jobspipe-candidate-sourcing
description: Open role to a ranked shortlist of people doing that job at the companies you name, with outreach drafts. Use when the user has an open role and wants a shortlist of people doing that job today, with outreach drafts.
---

# Candidate Sourcing

Open role to a ranked shortlist of people doing that job at the companies you name, with outreach drafts. Category: Recruiting. Invoke as `/jobspipe:candidate-sourcing`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-candidate-sourcing/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `fetch`, `search_hiring_companies`, `people_search`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- The role: a job posting id, or a title plus must-have skills.
- Where to look: the companies to source from (domains). If none are given, ask, or offer to find companies that hire for this role.

## Steps
1. If given a posting, call `fetch` with its id and extract title, seniority and skills.
2. If the user has no companies to source from, call `search_hiring_companies` with `job_title_or` for the role, `employer_type_not: ["agency", "broker"]` and `known_company_only: true`, and offer the top 10 as companies where people do this job.
3. Call `get_account_info`, then tell the user that finding people costs 10 credits for each person new to this account, and wait for a yes.
4. For each company, call `people_search` with `company` set to the company's domain as the user gave it, `titles` set to the role's titles and its seniority variants, and `more: true`.
5. Rank by how closely each person's title matches the role. Drop anyone whose title does not support the match.
6. For the top 5, draft a short note that names their current title and company and one concrete detail of the role. Do not claim anything about their past work: JobsPipe returns titles, not work history.

## Output
- A ranked table: name, current title and company, profile link, why they fit. Fewer rows is fine: never pad it.
- Up to five drafts, under 90 words each, one per person.

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
