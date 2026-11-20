---
name: jobspipe-signal-watch
description: Save any search and get pinged in Slack, email or a webhook the moment it matches. Use when the user wants to be told when new postings, hiring companies or layoffs match a search.
---

# Signal Watch

Save any search and get pinged in Slack, email or a webhook the moment it matches. Category: Signals. Invoke as `/jobspipe:signal-watch`.

## Setup (once)
This skill runs on live hiring data from JobsPipe through its MCP server. In Claude, Claude Code, Cursor, Windsurf, ChatGPT or another agent, add the server `https://mcp.jobspipe.dev/mcp` and sign in (or send `Authorization: Bearer <JOBSPIPE_API_KEY>`; get a key at https://jobspipe.dev/dashboard).
Only if your agent cannot use MCP at all, call the same data over REST at `https://api.jobspipe.dev` with that header; the reference is at https://docs.jobspipe.dev.

To install this as a Claude Code skill, save this file as `~/.claude/skills/jobspipe-signal-watch/SKILL.md`.

## Before you start
1. Check these JobsPipe tools are available: `get_account_info`, `search_jobs`, `list_signals`, `create_signal`.
2. If JobsPipe is not connected, or any of these tools is missing, stop. Tell the user which tool is missing and that this skill cannot run without it. Do not replace it with another tool, a REST call, a web search or your own knowledge.
3. If an input listed below is missing, ask for it before calling anything.

## Inputs
- What to watch, and where to be told (email, Slack or a webhook URL).

## Steps
1. Run the search once with `search_jobs` (`posted_at_max_age_days: 30`, `include_total_results: true`) and read every match. Add `job_title_not` or other `_not` filters for false positives, and run it again until the matches are right. For an industry like fintech, use `isic_division_or` (64, 65 and 66 are financial services, which also brings in banks and asset managers), read the companies, drop the ones that are not what the user meant, and say the industry match is approximate.
2. Call `list_signals` to check the same watch is not saved already.
3. Call `create_signal` with the exact filters from step 1 without the `posted_at` ones, `mode` (`jobs` for postings, `companies` for hiring companies), a destination with `kind`, `target` and `cadence`, and an `idempotency_key`. Tell the user each delivered match costs 1 credit.
4. Call `list_signals` to confirm it is saved.

## Output
- Today's matches, the signal id, what it watches, where alerts go, and the cost per match.

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
