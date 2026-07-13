# Context Files: AGENTS.md / CLAUDE.md / HERMES.md

Discovered during research 2026-06-19. Hermes Agent officially supports cross-ecosystem context files from the Hermes/Claude Code/Cursor ecosystem.

## Supported files (priority order)

Only ONE project context file is loaded per session (first match wins):

| Priority | File | Ecosystem |
|----------|------|-----------|
| 1 | `.hermes.md` or `HERMES.md` | Hermes Agent (walks to git root) |
| 2 | `AGENTS.md` | Cross-agent standard |
| 3 | `CLAUDE.md` | Claude Code |
| 4 | `.cursorrules` | Cursor IDE |

## Discovery mechanism

- `~/.hermes/HERMES.md` — loaded globally from `HERMES_HOME`
- `HERMES.md` in git root — walks up from CWD to find it
- AGENTS.md / CLAUDE.md — discovered progressively from CWD at startup + subdirectories
- SOUL.md — always loaded independently (slot #1 in system prompt)

## Implications for agent projects

For Oleg's business agents in `~/agents/templates/`:
- Each template already has `HERMES.md` — correct
- Should consider adding a root `~/agents/AGENTS.md` with shared conventions
- AGENTS.md can define: architecture patterns, state-machine rules, variable naming, common tools

## Best practice

If supporting multiple AI tools (Hermes, Claude Code, Cursor), prefer `AGENTS.md` as the cross-compatible standard. If Hermes-only, `HERMES.md` is fine.
