# dev-containers

A collection of VS Code Dev Container configurations for consistent, reproducible development environments.

---

## Table of Contents

- [Repository Structure](#repository-structure)
- [Available Containers](#available-containers)
- [Getting Started](#getting-started)
- [Shared Tools & Extensions](#shared-tools--extensions)
- [MCP Servers](#mcp-servers)
- [Environment Variables](#environment-variables)
- [Adding a New Container](#adding-a-new-container)

---

## Repository Structure

```
.
├── .devcontainer/
│   ├── nodejs-24/
│   │   ├── devcontainer.json   # VS Code dev container configuration
│   │   └── Dockerfile          # Image definition (extends node:24-bookworm)
│   └── shared/
│       ├── base.Dockerfile     # Shared base image (reference / reuse)
│       └── extensions.json     # Shared VS Code extensions reference
├── .vscode/
│   └── mcp.json                # Shared MCP server configurations
├── .env.example                # Environment variable template
├── .env                        # Your local secrets (git-ignored, never commit)
└── README.md
```

---

## Available Containers

### `nodejs-24` – Node.js 24 + TypeScript

| Category | Included |
|---|---|
| **Runtime** | Node.js 24 LTS on Debian Bookworm |
| **Language** | TypeScript (global `tsc`) |
| **Formatter / Linter** | [Biome](https://biomejs.dev/) |
| **Testing** | [Playwright](https://playwright.dev/) (Chromium pre-installed) |
| **Shell** | zsh (default) |
| **Editor** | Neovim + VS Code |

---

## Getting Started

### Prerequisites

- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine)

### 1. Clone the repository

```bash
git clone https://github.com/DanielKlossek/dev-containers.git
cd dev-containers
```

### 2. Set up your environment variables

```bash
cp .env.example .env
# Edit .env and fill in your tokens
```

See [Environment Variables](#environment-variables) for details on each value.

### 3. Open a container

1. Open VS Code in this repository folder.
2. Press **Ctrl/Cmd + Shift + P** → **Dev Containers: Reopen in Container**.
3. Select the desired container (e.g., `Node.js 24 + TypeScript`).
4. VS Code will build the image and open the workspace inside the container.

> **Tip:** The `initializeCommand` in `devcontainer.json` automatically creates a `.env` from `.env.example` if one does not already exist, so the container will always start successfully.

---

## Shared Tools & Extensions

The following tools and extensions are included in **every** container in this repository.

### Tools (installed in the image)

| Tool | Purpose |
|---|---|
| [Neovim](https://neovim.io/) | Terminal editor |
| [zsh](https://www.zsh.org/) | Default shell |
| [Python 3](https://www.python.org/) | Scripting & tooling |
| [GitHub CLI (`gh`)](https://cli.github.com/) | GitHub from the terminal |
| [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) (`gh copilot`) | AI-powered shell commands (installed as a `gh` extension in `postCreateCommand`) |

### VS Code Extensions (shared)

| Extension | ID |
|---|---|
| Vim | `vscodevim.vim` |
| GitHub Copilot | `GitHub.copilot` |
| GitHub Copilot Chat | `GitHub.copilot-chat` |

These extensions are listed in `.devcontainer/shared/extensions.json` for reference and included in every `devcontainer.json`.

---

## MCP Servers

[Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers extend GitHub Copilot Chat with additional tools.  They are configured in two places so they work both inside dev containers and in a local VS Code workspace:

- **`.vscode/mcp.json`** – workspace-level config (shared across all containers)
- **`devcontainer.json` → `customizations.vscode.settings.mcp`** – embedded per-container

### Configured Servers

| Server | Package | Purpose |
|---|---|---|
| **context7** | `@upstash/context7-mcp` | Injects up-to-date library documentation into Copilot context |
| **github** | `@modelcontextprotocol/server-github` | Repo, PR, issue and code-search tools for Copilot |
| **chrome-devtools** | `@chrome-devtools/chrome-devtools-mcp` | Browser automation & debugging via Chrome DevTools Protocol |

> The GitHub MCP server requires `GITHUB_PERSONAL_ACCESS_TOKEN` to be set in your `.env` file.

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values.  The `.env` file is **never committed** (it is listed in `.gitignore`).

| Variable | Required | Description |
|---|---|---|
| `GITHUB_TOKEN` | Yes | GitHub PAT for `gh` CLI and Copilot CLI. Scopes: `repo`, `read:org`, `workflow` |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | Yes | GitHub PAT for the GitHub MCP server (can be the same token as above) |
| `CHROME_DEBUGGING_PORT` | No | Custom Chrome remote debugging port (default: `9222`) |

---

## Adding a New Container

1. Create `.devcontainer/<name>/Dockerfile` – start from a suitable base image and include the shared tools block from `.devcontainer/shared/base.Dockerfile`.
2. Create `.devcontainer/<name>/devcontainer.json` – copy the template below and adjust as needed.
3. Add any container-specific extensions, settings, or `postCreateCommand` steps.

### devcontainer.json template

```jsonc
{
  "name": "My Container",
  "build": {
    "dockerfile": "Dockerfile",
    "context": "../.."
  },
  "initializeCommand": "test -f ${localWorkspaceFolder}/.env || cp ${localWorkspaceFolder}/.env.example ${localWorkspaceFolder}/.env",
  "runArgs": ["--env-file=${localWorkspaceFolder}/.env"],
  "remoteUser": "<user>",
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh",
        "mcp": {
          "servers": {
            "context7": {
              "type": "stdio",
              "command": "npx",
              "args": ["-y", "@upstash/context7-mcp@latest"]
            },
            "github": {
              "type": "stdio",
              "command": "npx",
              "args": ["-y", "@modelcontextprotocol/server-github"],
              "env": {
                "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_PERSONAL_ACCESS_TOKEN}"
              }
            },
            "chrome-devtools": {
              "type": "stdio",
              "command": "npx",
              "args": ["-y", "@chrome-devtools/chrome-devtools-mcp"]
            }
          }
        }
      },
      "extensions": [
        "vscodevim.vim",
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "<your-extension-id>"
      ]
    }
  },
  "postCreateCommand": "gh extension install github/gh-copilot 2>/dev/null || true"
}
```

### Dockerfile template

```dockerfile
FROM <base-image>

ARG DEBIAN_FRONTEND=noninteractive

# ── Shared system tools (keep in sync with .devcontainer/shared/base.Dockerfile) ──
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates git gnupg lsb-release sudo unzip \
        zsh python3 python3-pip neovim \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
        https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ── Container-specific tools ──
# ...

RUN chsh -s /usr/bin/zsh <user>
```
