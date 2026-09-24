---
name: jobspipe-mcp
description: Connect the JobsPipe MCP server to Claude Code, Claude Desktop, Cursor, or any MCP client to search jobs, list job sources, and read pricing as native agent tools. Use when wiring JobsPipe into an agent over the Model Context Protocol instead of raw REST calls.
---

# JobsPipe MCP server

JobsPipe ships three MCP servers over Streamable HTTP. **Live job results
come only from the authenticated one** - wire that up for real data:

- **Live (authenticated)**: `https://mcp.jobspipe.dev/mcp` — tools
  `search_jobs` (returns the postings) and `list_pricing_plans`. Requires
  `Authorization: Bearer jp_live_<key>` (free key at
  https://jobspipe.dev/signup, dashboard Settings -> API Keys).
- **Demo (no key)**: `https://jobspipe.dev/mcp` — tools `search_jobs`,
  `list_job_sources`, `list_pricing_plans`; resources expose the OpenAPI
  spec, pricing, and the source catalog. Its `search_jobs` returns real
  matching postings within a small daily allowance.
- **Docs**: `https://docs.jobspipe.dev/mcp` — tools `search_docs`,
  `list_docs` over the developer documentation. No key.

Registry entry: `dev.jobspipe/mcp` in the official MCP registry. Discovery
manifest: `https://jobspipe.dev/.well-known/mcp.json`. Server card:
`https://jobspipe.dev/.well-known/mcp/server-card.json`.

## Claude Code

```bash
claude mcp add --transport http jobspipe https://mcp.jobspipe.dev/mcp \
  --header "Authorization: Bearer jp_live_YOUR_KEY"
claude mcp add --transport http jobspipe-docs https://docs.jobspipe.dev/mcp
```

## Cursor / generic mcp.json

```json
{
  "mcpServers": {
    "jobspipe": {
      "url": "https://mcp.jobspipe.dev/mcp",
      "headers": { "Authorization": "Bearer jp_live_YOUR_KEY" }
    },
    "jobspipe-docs": { "url": "https://docs.jobspipe.dev/mcp" }
  }
}
```

## Protocol details

Streamable HTTP, protocol version `2025-06-18`. POST JSON-RPC to the endpoint
with `Accept: application/json, text/event-stream`; keep the returned
`Mcp-Session-Id` header on subsequent calls. All tools are read-only
(`readOnlyHint: true`).

Both servers return real postings from `search_jobs`. The demo server caps
how many rows it returns per day; use the live server with a key for full
results and filters.
