# figma-restapi-skill

[日本語版はこちら / Japanese](./README.ja.md)

A reusable skill for implementing designs with the Figma REST API.

- For Codex: install as a Skill
- For Claude Code: install as a Skill
- Supports both global installation and per-project installation

## Why use REST API instead of the official Figma MCP

The official Figma MCP is convenient for interactive implementation, but direct REST API usage has these advantages.

Note:

- The official Figma MCP is provided as a Dev Mode feature, so your account/workspace must satisfy Dev Mode access requirements (plan/seat conditions).

- Easier automation
  - Works well with scheduled jobs, batch runs, and CI/CD pipelines via `curl` and scripts
- Better portability across tools
  - The same API logic can be reused outside Codex/Claude Code
- Better for large-scale processing
  - Easier to process many files/nodes and connect to code generation pipelines
- More control
  - You can explicitly control retries, rate-limit handling, caching, and logging
- Easier security/audit operations
  - Token scopes and expiration can be managed according to policy
- Works in headless environments
  - Can run from servers without GUI interaction

In practice, a good split is: MCP for interactive prototyping, REST API for reproducible production workflows.

## Contents

- `skills/figma-rest-api-coding/SKILL.md`
  - Coding workflow using Figma REST API
- `skills/figma-rest-api-coding/references/*`
  - Coding-focused endpoints, implementation workflow, and snippets
- `skills/figma-rest-api-coding/scripts/figma-api.sh`
  - Helper script for Figma API calls

## Installation

### 1. Clone this repository

```bash
git clone <this-repo-url>
cd figma-restapi-skill
```

### 2. Run installer

```bash
./scripts/install.sh [options]
```

Main options:

- `--tool <codex|claude|both>` (default: `both`)
- `--scope <global|project>` (default: `global`)
- `--project-path <path>` (used with `--scope project`)
- `--force` overwrite existing installation

Examples:

```bash
# Install globally for both Codex and Claude
./scripts/install.sh --tool both --scope global

# Install only for Claude in the current project
./scripts/install.sh --tool claude --scope project

# Install only for Codex in a specific project
./scripts/install.sh --tool codex --scope project --project-path /path/to/project
```

## Installation paths

- Codex global: `${CODEX_HOME:-~/.codex}/skills/figma-rest-api-coding`
- Codex project: `<project>/.codex/skills/figma-rest-api-coding`
- Claude global: `${CLAUDE_CONFIG_DIR:-~/.claude}/skills/figma-rest-api-coding`
- Claude project: `<project>/.claude/skills/figma-rest-api-coding`

## Uninstall

```bash
./scripts/uninstall.sh [options]
```

Options are the same as `install.sh` (`--force` is not needed).

Examples:

```bash
./scripts/uninstall.sh --tool both --scope global
./scripts/uninstall.sh --tool codex --scope project --project-path /path/to/project
```

## Figma API token

Set `FIGMA_TOKEN` before using this skill.

### How to get `FIGMA_TOKEN` (Personal Access Token)

1. Sign in to Figma
2. Open `Settings` from the account menu at the top-left of the file browser
3. Open the `Security` tab
4. In `Personal access tokens`, click `Generate new token`
5. Set expiration and scopes, then generate the token
6. Copy and store the token securely right after generation

Notes:

- The token string is shown only once at creation time
- Since the 2025-04-28 update, PATs cannot be non-expiring and are limited to up to 90 days
- `files:read` is deprecated; prefer minimum required granular scopes

Typical scopes for this skill:

- `file_content:read` (read nodes/file content)
- `file_metadata:read` (read file metadata)
- `file_versions:read` (read version history)
- `library_content:read` (read published components/styles)
- `file_dev_resources:read` (read Dev Resources)
- `file_variables:read` (read Variables: Enterprise plan only)

```bash
export FIGMA_TOKEN="your_token"
```

For persistence (example in `~/.zshrc`):

```bash
export FIGMA_TOKEN="your_token"
```

## Helper script examples

```bash
# Parse file_key/node_id from URL
./skills/figma-rest-api-coding/scripts/figma-api.sh parse-url "https://www.figma.com/design/FILE_KEY/Example?node-id=1-2"

# Fetch JSON for specific nodes
FIGMA_TOKEN=xxx ./skills/figma-rest-api-coding/scripts/figma-api.sh nodes FILE_KEY "1:2,3:4" "depth=2"
```
