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
| [jobspipe-job-search](skills/jobspipe-job-search/SKILL.md) | Search live, normalized job postings from 30+ ATS feeds and job boards |
| [jobspipe-stack-scan](skills/jobspipe-stack-scan/SKILL.md) | Detect the technologies a company runs by scanning its domain |
| [jobspipe-mcp](skills/jobspipe-mcp/SKILL.md) | Connect the JobsPipe MCP server to Claude Code, Cursor, or any MCP client |
| [jobspipe-webhooks](skills/jobspipe-webhooks/SKILL.md) | Receive and verify JobsPipe job-event webhooks with HMAC signature checks |
| [jobspipe-agent-discovery](skills/jobspipe-agent-discovery/SKILL.md) | Integrate from machine-readable surfaces: llms.txt, OpenAPI, sandbox, ARD |

## Links

- [Developer resources hub](https://jobspipe.dev/developers)
- [API documentation](https://docs.jobspipe.dev)
- [Free API key](https://jobspipe.dev/signup) (100 credits/month)
- [CLI](https://github.com/jobspipe/jobspipe-cli): `npm i -g jobspipe-cli`
