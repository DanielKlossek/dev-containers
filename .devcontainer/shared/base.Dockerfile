# =============================================================================
# Shared Base Dockerfile
# =============================================================================
# This file defines the shared tooling layer used by all dev containers in
# this repository.  It is intended to be built and tagged as a local image
# that individual containers can reference with `FROM dev-containers-base`.
#
# Build locally before building a specific container:
#   docker build -f .devcontainer/shared/base.Dockerfile \
#                -t dev-containers-base .
# =============================================================================

FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

# ── Core utilities ────────────────────────────────────────────────────────────
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

# ── GitHub CLI ────────────────────────────────────────────────────────────────
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
        https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# ── Default shell ─────────────────────────────────────────────────────────────
RUN chsh -s /usr/bin/zsh root
