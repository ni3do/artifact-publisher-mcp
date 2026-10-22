# Claude Desktop / claude.ai: custom connector

Claude Desktop connects to remote MCP servers as **custom connectors** (Customize > Connectors > Add custom connector). There is no JSON config file for remote servers.

Artifact Publisher authenticates with a publisher key sent in a request header, so it needs the connector's **Request headers** section. Anthropic documents request-header authentication as **beta, available to a limited set of organizations**. If you don't see "Request headers" in the dialog, your account doesn't have it yet; use Claude Code instead (`../claude-code/add.sh`).

If you have it:

1. Customize > Connectors > Add custom connector (in a Claude organization, an Owner adds it under Organization settings > Connectors).
2. Name: `Artifact Publisher`. MCP server URL: `https://app.artifactpublisher.com/mcp`.
3. Authentication: **No sign-in**.
4. Request headers: header `authorization`, value `Bearer <your publisher key>` (include `Bearer ` and the space; Claude sends the value exactly as entered). Mark it Required.
5. Add.

In a Claude organization, a request header is one shared credential for everyone in the organization. Use a key with only the scopes you want everyone to have.

Source: https://claude.com/docs/connectors/custom/remote-mcp
