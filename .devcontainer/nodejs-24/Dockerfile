# =============================================================================
# Node.js 24 + TypeScript Dev Container
# =============================================================================
# Extends the official node:24-bookworm image with:
#   Shared tools : neovim, zsh, python3, GitHub CLI, GitHub Copilot CLI
#   Node tools   : TypeScript, Biome (formatter / linter)
#   Test tools   : Playwright (Chromium + system deps)
# =============================================================================

FROM node:24-bookworm

ARG DEBIAN_FRONTEND=noninteractive

# ── Shared system tools ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        git \
        gnupg \
        lsb-release \
        sudo \
        unzip \
        zsh \
        python3 \
        python3-pip \
        neovim \
    && rm -rf /var/lib/apt/lists/*

# ── GitHub CLI (shared) ───────────────────────────────────────────────────────
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
        https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ── Global Node.js tools ──────────────────────────────────────────────────────
RUN npm install -g typescript @biomejs/biome

# ── Playwright: install Chromium + all required system dependencies ───────────
# PLAYWRIGHT_BROWSERS_PATH makes browsers available to every user in the image.
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright
RUN npm install -g playwright \
    && mkdir -p $PLAYWRIGHT_BROWSERS_PATH \
    && playwright install --with-deps chromium \
    && chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

# ── Set zsh as default shell for the built-in 'node' user ────────────────────
RUN chsh -s /usr/bin/zsh node
