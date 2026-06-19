# Skills Organization: Core + Vault + Catalog

Applied 2026-06-19 to `~/.hermes/skills/` → `~/.hermes/skills-vault/`.

## Decision rationale

The original 118 skills in `~/.hermes/skills/` generated a ~2750-token `<available_skills>` block in the system prompt. Most were domain-specific and rarely used.

The split into Core (always in context) + Vault (on-demand) + Catalog (one-liner index) preserves full capability while cutting the token cost by ~2100 per call.

## Core — what stayed in `~/.hermes/skills/`

Selection criteria: used in >50% of sessions, OR governs the agent's own cognition/architecture.

- **architect** — system design (regular need)
- **planner / writing-plans** — task decomposition
- **spike** — throwaway experiments
- **architecture-decision-records** — ADRs
- **cognitive-interaction-model** — CIM (meta-cognition)
- **business-agent-architect** — primary business skill
- **business-knowledge-engineering** — knowledge gathering
- **systematic-debugging** — root cause analysis
- **code-reviewer / security-reviewer / requesting-code-review** — review pipeline
- **hermes-agent** — Hermes config/usage
- **skill-evolution / hermes-agent-skill-authoring** — self-improvement
- **system-diagnostics** — health checks
- **python-debugpy / node-inspect-debugger** — debugging
- **hermes-config-tuning** — this skill itself
- **core/skill-catalog** — vault index

Total: 20 skills

## Vault — what moved to `~/.hermes/skills-vault/`

Selection criteria: domain-specific, used in <15% of sessions.

| Category | Skills | Reason |
|----------|--------|--------|
| GitHub (6) | pr-workflow, repo-management, issues, code-review, auth, codebase-inspection | Only need when doing Git work |
| Productivity (5) | obsidian, notion, google-workspace, ocr-and-documents, nano-pdf | Tool-specific, not every session |
| Creative (3) | architecture-diagram, sketch, excalidraw | Infrequent but valuable |
| Business (3) | sales-knowledge-rag, chat-widget, email-auto-responder | Client-specific |
| Testing (2) | agent-evaluation-framework, eval-harness | Only during agent development cycles |
| Other (6) | himalaya, youtube-content, arxiv, open-notebook-rag, native-mcp, webhook-subscriptions | Rare but irreplaceable |

Total: 25 skills. Zero tokens in context.

## Archive — `~/.hermes/skills-archive/`

80 skills that were never or almost never used: apple/, gaming/, red-teaming/, most creative/, most mlops/, smart-home/, social-media/, etc. Available via `/skill name` if needed.

## Catalog — `core/skill-catalog/`

One SKILL.md listing every vault skill with a one-line description. The catalog stays in context (~150 tokens) so the agent knows what exists and can load it on demand.

## Token comparison

| State | Skills in `skills/` | Block tokens |
|-------|---------------------|-------------|
| Before (118) | 118 | ~2750 |
| After (20 core + catalog) | 21 | ~650 |
| Savings | — | **~2100 per call** |

## What to do when adding a new skill

1. Determine if it's Core or Vault material
2. If Core → add to `~/.hermes/skills/<category>/`
3. If Vault → add to `~/.hermes/skills-vault/<category>/` AND update `core/skill-catalog/SKILL.md`
4. Verify the new skill appears in `find ~/.hermes/skills -name SKILL.md`
