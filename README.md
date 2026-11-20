# JobsPipe agent skills

Official [agent skills](https://skills.sh) from [JobsPipe](https://jobspipe.dev) - the unified jobs and technographics API.

## Install

```bash
npx skills add jobspipe/skills
```

Or install a single skill:

```bash
npx skills add jobspipe/skills --skill jobspipe-job-search
```

## Skills

| Skill | What it does |
|---|---|
| [jobspipe-icp-builder](skills/jobspipe-icp-builder/SKILL.md) | Paste one company and get the ICP, persona and voice config every other skill reads. |
| [jobspipe-recruiter-market](skills/jobspipe-recruiter-market/SKILL.md) | Who is hiring your profile right now: comp bands, seniority mix and the roles heating up. |
| [jobspipe-hiring-triggers](skills/jobspipe-hiring-triggers/SKILL.md) | Turn 'who just started hiring for X' into a watch that fires on the exact req and drafts the opener. |
| [jobspipe-tech-stack](skills/jobspipe-tech-stack/SKILL.md) | Companies that posted for a stack in the last 30 days, ranked with the evidence post. |
| [jobspipe-account-research](skills/jobspipe-account-research/SKILL.md) | Hiring trajectory, org chart, tech stack or a battlecard, before you call. |
| [jobspipe-sales-outreach](skills/jobspipe-sales-outreach/SKILL.md) | The cold email, call script or sequence, opening on one real, dated hiring signal. |
| [jobspipe-prospect-score](skills/jobspipe-prospect-score/SKILL.md) | Score a book or a list by ICP fit from live hiring and stack signals. |
| [jobspipe-layoff-rebound](skills/jobspipe-layoff-rebound/SKILL.md) | Who cut staff, and who is already re-hiring the cut roles. A displacement window, timed. |
| [jobspipe-competitor-diff](skills/jobspipe-competitor-diff/SKILL.md) | What a competitor is hiring for that you are not, read straight from their postings. |
| [jobspipe-org-growth](skills/jobspipe-org-growth/SKILL.md) | Which teams scaled and when, rebuilt from a company's posting history. |
| [jobspipe-signal-watch](skills/jobspipe-signal-watch/SKILL.md) | Save any search and get pinged in Slack, email or a webhook the moment it matches. |
| [jobspipe-job-search](skills/jobspipe-job-search/SKILL.md) | Search live, normalized job postings from 30+ ATS feeds and job boards |
| [jobspipe-stack-scan](skills/jobspipe-stack-scan/SKILL.md) | Detect the technologies a company runs by scanning its domain |
| [jobspipe-mcp](skills/jobspipe-mcp/SKILL.md) | Connect the JobsPipe MCP server to Claude Code, Cursor, or any MCP client |
| [jobspipe-webhooks](skills/jobspipe-webhooks/SKILL.md) | Receive and verify JobsPipe job-event webhooks with HMAC signature checks |
| [jobspipe-agent-discovery](skills/jobspipe-agent-discovery/SKILL.md) | Integrate from machine-readable surfaces: llms.txt, OpenAPI, sandbox, ARD |

## Links

- [Developer resources hub](https://jobspipe.dev/developers)
- [API documentation](https://docs.jobspipe.dev)
- [Free API key](https://jobspipe.dev/signup) (1,000 free credits, one time)
- [Skills catalog](https://jobspipe.dev/skills): every skill, with what it reads and returns
- [CLI](https://github.com/jobspipe/jobspipe-cli): `npm i -g jobspipe-cli`

## License

MIT - see [LICENSE](LICENSE) for details.
