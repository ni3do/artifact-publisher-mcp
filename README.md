# Artifact Publisher MCP: connect

Agents publish self-contained HTML to a stable review link, with page-level feedback and revoke.

This repository holds **connection docs and client configs only**. Artifact Publisher is a hosted remote MCP server; there is nothing to install or run locally, and no server source code lives here.

## What it is

Artifact Publisher gives an AI agent a place to put the HTML it makes. The agent sends one self-contained HTML document (up to 10 MiB) through a remote MCP server and gets back a stable, unlisted link: anyone with the link can open it in a browser without an account, and it is not listed, searched or indexed. Reviewers can leave page-level comments, with no account needed to comment on public links; the agent reads them with `get_feedback` and answers with `reply_to_feedback`. `update_artifact` adds a new version behind the same link, and `revoke_artifact` stops serving it. Pages render in a sandbox with no network access, so everything must be inline.

Free plan available; see https://artifactpublisher.com/pricing/.

## Connect

| | |
|---|---|
| Endpoint | `https://app.artifactpublisher.com/mcp` |
| Transport | Streamable HTTP (`POST`) |
| Auth | `Authorization: Bearer <publisher key>` |
| Get a key | https://artifactpublisher.com/account/ |

Create a scoped publisher key in your workspace at https://artifactpublisher.com/account/. The key is shown once and stored only as a hash.

`initialize`, `tools/list` and `ping` answer without a key, so you (or a directory) can see the tool list before signing up. Tool calls need authorization; with a publisher key, send `Authorization: Bearer <publisher key>`.

**Keep the key out of prompts, repositories and artifacts.** Every config in this repo reads it from an environment variable or a client prompt. Set it in your shell profile, for example:

```sh
export ARTIFACT_PUBLISHER_KEY="<your publisher key>"
```

If a key is ever exposed, revoke it and create a new one.

## Tools

| Tool | Key scope | What it does |
|---|---|---|
| `publish_artifact` | `artifacts:write` | Publish a self-contained HTML document as version 1 and get back its link |
| `update_artifact` | `artifacts:write` | Add a new version behind the same link |
| `get_feedback` | `feedback:read` | Read reviewers' comments |
| `reply_to_feedback` | `feedback:write` | Reply to a comment |
| `list_artifacts` | `artifacts:read` | List your artifacts, newest first, with open comment counts |
| `revoke_artifact` | `artifacts:write` | Stop serving an artifact |

`tools/list` also returns `set_artifact_access`, `configure_workspace` (scope `workspace:configure`), `get_artifact_state`, `set_artifact_state`, `reset_artifact_state` and `get_authoring_guide`. The server's own `tools/list` is authoritative for input schemas; the full reference is at https://artifactpublisher.com/docs/mcp/.

Key scopes: `artifacts:write`, `artifacts:read`, `feedback:read`, `feedback:write`, `workspace:configure`. Give each key only the scopes it needs.

## Quickstart by client

Each snippet uses the server name `artifact-publisher`. The name is only a local label in your client.

### Claude Code

```sh
claude mcp add --transport http artifact-publisher https://app.artifactpublisher.com/mcp \
  --header "Authorization: Bearer ${ARTIFACT_PUBLISHER_KEY}"
```

Add `--scope user` to use it in every project. To share it with a project instead, commit the [`.mcp.json`](.mcp.json) at the repo root: Claude Code expands `${ARTIFACT_PUBLISHER_KEY}` from each person's environment and asks before using a project server.

```json
{
  "mcpServers": {
    "artifact-publisher": {
      "type": "http",
      "url": "https://app.artifactpublisher.com/mcp",
      "headers": { "Authorization": "Bearer ${ARTIFACT_PUBLISHER_KEY}" }
    }
  }
}
```

### Claude Desktop / claude.ai

Add it as a custom connector (Customize > Connectors > Add custom connector) with **No sign-in** and a request header `authorization: Bearer <your publisher key>`. Request-header authentication is a beta that Anthropic offers to a limited set of organizations; if you don't see "Request headers", use Claude Code. Step by step: [`configs/claude-desktop/README.md`](configs/claude-desktop/README.md).

### Cursor

Put this in `.cursor/mcp.json` (one project) or `~/.cursor/mcp.json` (everywhere). File: [`configs/cursor/mcp.json`](configs/cursor/mcp.json).

```json
{
  "mcpServers": {
    "artifact-publisher": {
      "url": "https://app.artifactpublisher.com/mcp",
      "headers": { "Authorization": "Bearer ${env:ARTIFACT_PUBLISHER_KEY}" }
    }
  }
}
```

### VS Code (GitHub Copilot)

Put this in `.vscode/mcp.json`, or run **MCP: Open User Configuration** for your profile. VS Code asks for the key once and stores it. File: [`configs/vscode/mcp.json`](configs/vscode/mcp.json).

```json
{
  "inputs": [
    { "type": "promptString", "id": "artifact-publisher-key", "description": "Artifact Publisher publisher key", "password": true }
  ],
  "servers": {
    "artifact-publisher": {
      "type": "http",
      "url": "https://app.artifactpublisher.com/mcp",
      "headers": { "Authorization": "Bearer ${input:artifact-publisher-key}" }
    }
  }
}
```

### Windsurf (Cascade)

Add this under `mcpServers` in Cascade's `mcp_config.json` (open it from the Cascade panel: `...` > MCPs > Open MCP config file). File: [`configs/windsurf/mcp_config.json`](configs/windsurf/mcp_config.json).

```json
{
  "mcpServers": {
    "artifact-publisher": {
      "serverUrl": "https://app.artifactpublisher.com/mcp",
      "headers": { "Authorization": "Bearer ${env:ARTIFACT_PUBLISHER_KEY}" }
    }
  }
}
```

### Codex (CLI, IDE extension, ChatGPT desktop app)

Add this to `~/.codex/config.toml` (or a trusted project's `.codex/config.toml`). Codex sends the variable's value as a bearer token. File: [`configs/codex/config.toml`](configs/codex/config.toml).

```toml
[mcp_servers.artifact-publisher]
url = "https://app.artifactpublisher.com/mcp"
bearer_token_env_var = "ARTIFACT_PUBLISHER_KEY"
```

### Other clients

Any MCP client that supports streamable HTTP with a custom header works: point it at `https://app.artifactpublisher.com/mcp` and send `Authorization: Bearer <publisher key>`.

## Check the connection

1. Restart or reload your client and confirm it lists the `artifact-publisher` tools.
2. Ask your agent: *"Publish a one-page HTML summary of this conversation with Artifact Publisher and give me the link."*
3. Open the link, leave a comment, then ask the agent to read the feedback.

A `401` on a tool call means the key is missing, wrong or revoked. Check that the environment variable is set in the environment your client starts from.

## Registry metadata

[`server.json`](server.json) is the entry for the official MCP Registry (`com.artifactpublisher/mcp`).

## Links

- Docs: https://artifactpublisher.com/docs/
- MCP reference: https://artifactpublisher.com/docs/mcp/
- Pricing: https://artifactpublisher.com/pricing/
- Privacy: https://artifactpublisher.com/privacy/
- Imprint: https://artifactpublisher.com/imprint/
- Terms: https://artifactpublisher.com/terms/
- Contact: contact@artifactpublisher.com

## Operator

Artifact Publisher is operated by Angle Labs GmbH, Switzerland.

## License

The docs and config snippets in this repository are MIT-licensed; see [LICENSE](LICENSE). Use of the hosted service is governed by its terms: https://artifactpublisher.com/terms/
