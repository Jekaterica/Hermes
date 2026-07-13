# Context7 Plugin for Hermes Agent

Discovered: 2026-06-19
Source: https://github.com/caocuong2404/hermes-plugin-context7

## What It Does
Search and retrieve up-to-date documentation for any library/API. Uses Context7's API as the backend — indexes official docs from npm, PyPI, crates.io, and other package registries.

## Installation
```bash
hermes plugins install https://github.com/caocuong2404/hermes-plugin-context7.git
hermes plugins enable context7
```

## Usage
```
/ctx7 react how do I create a custom hook?
/ctx7 next.js app router metadata
```

## API Key
Optional. Set `CONTEXT7_API_KEY` in shell before starting Hermes if the account requires one.

## Plugin File Inventory
The plugin registers:
- `commands.py` — slash command `/ctx7`
- `context7_client.py` — HTTP client for the Context7 API
- `tools.py` — tool registration
- `schemas.py` — request/response models
- `plugin.yaml` — plugin metadata
- `__init__.py` — plugin entry point

## MCP Alternatives
Also available as MCP servers:
- `hyper-mcp-rs/context7-plugin` — Rust-based MCP server
- `upstash-context7-marketplace-context7-plugin` — Upstash marketplace version

## When to Install
- **Install if:** you actively develop with fast-moving libraries (React 19, Next.js 15+ app router, FastAPI 0.115+, etc.) and need current docs at least a few times per week.
- **Skip if:** your work is mostly business logic, stable APIs, or internal systems. Browser + curl + official docs site cover the same ground without plugin overhead.
