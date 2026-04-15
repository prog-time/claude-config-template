# MCP servers

This directory stores an example configuration file for MCP servers.

## Activation

Copy the example and edit it for your installation:

```bash
cp mcp/servers.json.example ~/.claude/mcp/servers.json
```

Then replace every `<ALL_CAPS>` placeholder with real values.

## Examples in servers.json.example

### filesystem

Local stdio server for filesystem access.

- **command / args** — launches `@modelcontextprotocol/server-filesystem` via `npx`
- **`<ABSOLUTE_PATH_TO_YOUR_DIRECTORY>`** — absolute path to the directory you want to expose (e.g. `/Users/you/projects`)

### github

Remote HTTP server for the GitHub API.

- **command / args** — launches `@modelcontextprotocol/server-github` via `npx`
- **`<YOUR_GITHUB_TOKEN>`** — Personal Access Token (PAT) with the required scopes (usually `repo` + `read:org`)

## Adding your own servers

For each new server, add an entry in `servers.json`. Use:

- `command` + `args` — for stdio servers (local processes)
- `url` + `env` — for HTTP servers with authentication

Full list of official servers: <https://github.com/modelcontextprotocol/servers>
