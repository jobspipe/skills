---
name: jobspipe-mcp
description: Connect the JobsPipe MCP server to Claude Code, Claude Desktop, Cursor, or any MCP client to search jobs, list job sources, and read pricing as native agent tools. Use when wiring JobsPipe into an agent over the Model Context Protocol instead of raw REST calls.
---

# JobsPipe MCP server

JobsPipe ships two public MCP servers over Streamable HTTP, no auth required:

- **Product**: `https://jobspipe.dev/mcp` — tools `search_jobs`,
  `list_job_sources`, `list_pricing_plans`, `search_upwork_jobs`; resources
  expose the OpenAPI spec, pricing, and the source catalog.
- **Docs**: `https://docs.jobspipe.dev/mcp` — tools `search_docs`,
  `list_docs` over the developer documentation.

Registry entry: `dev.jobspipe/mcp` in the official MCP registry. Discovery
manifest: `https://jobspipe.dev/.well-known/mcp.json`. Server card:
`https://jobspipe.dev/.well-known/mcp/server-card.json`.

## Claude Code

```bash
claude mcp add --transport http jobspipe https://jobspipe.dev/mcp
claude mcp add --transport http jobspipe-docs https://docs.jobspipe.dev/mcp
```

## Cursor / generic mcp.json

```json
{
  "mcpServers": {
    "jobspipe": { "url": "https://jobspipe.dev/mcp" },
    "jobspipe-docs": { "url": "https://docs.jobspipe.dev/mcp" }
  }
}
```

## Protocol details

Streamable HTTP, protocol version `2025-06-18`. POST JSON-RPC to the endpoint
with `Accept: application/json, text/event-stream`; keep the returned
`Mcp-Session-Id` header on subsequent calls. All tools are read-only
(`readOnlyHint: true`).

`search_jobs` returns guidance for calling the authenticated REST API
(`POST https://api.jobspipe.dev/v1/jobs/search`, Bearer key `jp_live_...`
from https://jobspipe.dev/signup) — the MCP surface itself never needs a key.
`search_upwork_jobs`, `list_job_sources`, and `list_pricing_plans` return live
data directly.
