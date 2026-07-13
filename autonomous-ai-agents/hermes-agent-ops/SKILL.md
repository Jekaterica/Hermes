---
name: hermes-agent-ops
description: "Maintain, tune, and improve Hermes Agent over time: configuration tuning, system prompt optimization, skills pruning, backup/recovery, skill evolution via DSPy/GEPA, plugin evaluation, and external skill library integration."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [hermes, configuration, optimization, system-prompt, skills, pruning, self-evolution, gepa, dspy, backup]
    related_skills: [hermes-agent, skill-catalog, hermes-agent-skill-authoring]
---

# Hermes Agent Operations

Maintain and improve Hermes Agent over its lifespan. This skill covers everything from day-one configuration tuning through ongoing skills pruning, automated skill evolution, backup/recovery, and plugin evaluation.

**Scope:** Anything a maintainer does TO Hermes, not the work Hermes does FOR you. For day-to-day Hermes usage (CLI commands, spawning, gateway), see the `hermes-agent` skill.

---

## 1. Layered Configuration (5 Files)

Read in priority order at session start. Each file covers a distinct concern — no duplication between them.

| File | Purpose |
|------|---------|
| `~/.hermes/SOUL.md` | Agent identity, core principles, metric (~300 tokens) |
| `~/.hermes/memories/USER.md` | User profile: role, values, cognitive traps, style |
| `~/.hermes/strategic-context.md` | Active projects, decisions, dead ends (updated weekly) |
| `~/.hermes/cim-summary.md` | Cognitive Interaction Model: priorities, rules, forbidden |
| `~/.hermes/HERMES.md` | Operational framework: workflow, knowledge priority, autonomy |

### Design Rules

- **SOUL.md** = shortest (~300 tokens) — identity and principles only
- **USER.md** = cognitive traps and format preferences so the agent proactively avoids the user's patterns
- **HERMES.md** = the tactical operational layer (workflow, knowledge priority, token policy)
- **CIM** = decision rules (loaded from `~/.hermes/cim-summary.md`)

See `references/skills-organization.md` for the full catalog split rationale.

---

## 2. System Prompt Optimization

The default Hermes system prompt + memory + config files totals ~6500-7000 tokens per call. The goal is to eliminate waste without losing meaning.

### What to Cut

1. **Dead tool references** — Context7 (plugin, not installed by default), Exa (external API, not a built-in tool). Replace with what actually works: `web_search` or `browser` + `curl`.
2. **"Always start with RAG"** — RAG is a skill, not a built-in tool. Loading it on every call costs tokens. Make it on-demand: "load when task requires project/internal info".
3. **Depth Mode prompt every turn** — Use automatic adaptation: simple → short, complex → deep. Offer explicitly only when depth is ambiguous.
4. **Source attribution on every answer** — Reserve markers for deep/important answers only.
5. **Skills block (`<available_skills>`)** — Prune from 118 to ~40-50 relevant skills (~1700 tokens saved per call). See §3 below.

### Compact System Prompt Template (~700-800 tokens)

```
# SYSTEM: Hermes v3.6 — Goal-First Execution

## Core
Goal-First > process. Execution > analysis. Simplicity > complexity.
Metric: result value / (tokens + time + complexity).
Flag risks, overcomplication, inefficient paths directly.

## Knowledge Priority
1. Memory (SOUL.md, USER.md, strategic-context, cim-summary, HERMES.md)
2. RAG (Open Notebook) — load skill on demand
3. browser / curl — live data, docs, APIs

## Depth
Adaptive. Simple query → short. Complex → detailed.
If ambiguous → ask once.

## Error Recovery
2 same-type errors → change strategy.

## Source Attribution
[Memory] [RAG] [Web] — deep answers only.

## Self-Check (significant tasks)
Overcomplication? Right source? Minimal sufficient?

## Permissions
Ask before changing config/memory/security/behaviour files.

## Forbidden
- Architectural drift
- Creating skills without approval
- Self-evolution without explicit consent
- Using non-existent tools
```

---

## 3. Skills Audit & Pruning

When the skills library grows to 100+ entries, the `<available_skills>` block costs ~2750 tokens/turn. Prune aggressively.

### Methodology

1. List all skills: `find ~/.hermes/skills -name 'SKILL.md' | sort`
2. Group by category (business, creative, mlops, github, etc.)
3. Classify each as **keep** or **archive** based on user's actual work patterns
4. Categories almost always archiveable: apple/* (no Mac), gaming/*, red-teaming/*, most creative/*, media/ (except youtube-content), smart-home/*, social-media/*, most mlops/
5. Watch for near-duplicates: `agent-evaluation` ≈ `agent-evaluation-framework`, `code-review-excellence` ≈ `code-reviewer`, `plan` ≈ `planner`
6. Move archived skills to `~/.hermes/skills-archive/` preserving directory structure
7. Result: block shrinks from ~2750 to ~1050 tokens — saves ~1700 per call

### Skills Organization: Core + Vault + Catalog

Beyond pruning, organize skills into three tiers:

| Tier | Location | Tokens in context |
|------|----------|-------------------|
| **Core** (~20 skills, used in >50% of sessions) | `~/.hermes/skills/` | ~500 |
| **Vault** (~25 skills, loaded on demand) | `~/.hermes/skills-vault/` | 0 |
| **Catalog** (1 skill listing vault contents) | `~/.hermes/skills/core/skill-catalog/` | ~150 |
| **Total** (~46 skills) | | **~650 vs ~2750** |

The catalog (~150 tokens) lists every vault skill with a one-line description. When the agent sees a task matching a vault skill, it loads it via `skill_view(name)`.

### Migration (one-time)

```bash
mkdir -p ~/.hermes/skills-vault/{github,productivity,creative,business,testing,other}
mv ~/.hermes/skills/github/* ~/.hermes/skills-vault/github/
```

See `references/skills-organization.md` for the exact split decision.

---

## 4. Backup & Recovery (Digital Twin)

Save the complete agent configuration as a recoverable snapshot — allows full reconstruction from scratch.

### What to Back Up

| Component | Source |
|-----------|--------|
| SOUL.md | `~/.hermes/SOUL.md` |
| USER.md | `~/.hermes/memories/USER.md` |
| HERMES.md | `~/.hermes/HERMES.md` |
| cim-summary.md | `~/.hermes/cim-summary.md` |
| strategic-context.md | `~/.hermes/strategic-context.md` |
| config.yaml | `~/.hermes/config.yaml` |
| scripts/ | `~/.hermes/scripts/` |

### Encrypted Secrets

API keys must be stored encrypted (repo is public). The password belongs in `.env`, NEVER hardcoded:

```bash
# ~/.hermes/.env contains:
SECRETS_PASSWORD=your_password_here

# encrypt-secrets.sh reads it:
source "$HOME/.hermes/.env"
tar czf - -C "$HOME/.hermes" .env | \
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$SECRETS_PASSWORD" \
  -out "$HOME/.hermes/skills/hermes-secrets/secrets.tar.gz.enc"

# Decrypt:
source ~/.hermes/.env 2>/dev/null
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$SECRETS_PASSWORD" \
  -in secrets.tar.gz.enc | tar xzf - -C ~/.hermes/
```

### Cron Schedule (One Weekly Snapshot)

```bash
hermes cron create "0 3 * * 1" \
  --name hermes-weekly-backup \
  --script hermes-backup-weekly.sh \
  --no-agent
```

The script does everything: re-encrypt secrets, copy vault + config files + scripts into the repo, commit, push.

**Do NOT keep a separate daily cron.** The weekly backup covers everything (skills + vault + config + scripts + secrets) in one shot.

### Recovery from Scratch

```bash
git clone git@github.com:USER/Hermes.git ~/.hermes/skills
cp ~/.hermes/skills/hermes-config/* ~/.hermes/
source ~/.hermes/.env 2>/dev/null
openssl enc -d -aes-256-cbc -pbkdf2 \
  -in ~/.hermes/skills/hermes-secrets/secrets.tar.gz.enc \
  -pass pass:"$SECRETS_PASSWORD" | tar xzf - -C ~/.hermes/
hermes
```

See `references/digital-twin-backup.md` for the full applied state (cron IDs, script paths).

---

## 5. Skill Evolution (DSPy + GEPA)

Automatically improve a skill's effectiveness through GEPA mutations guided by LLM-as-judge scores. No GPU required — all evolution runs through API calls.

**Requires:** `hermes-agent-self-evolution` repo, DSPy ≥3.0, GEPA ≥0.0.27.

### Quick Start

```bash
git clone https://github.com/NousResearch/hermes-agent-self-evolution.git
cd hermes-agent-self-evolution
pip install -e ".[dev]"
export HERMES_AGENT_REPO=$HOME/.hermes

# Dry-run (zero API calls)
python -m evolution.skills.evolve_skill --skill my-skill --dry-run

# Full run (10 iterations, synthetic data)
python -m evolution.skills.evolve_skill --skill my-skill --iterations 10

# Real run with session history (mines ~/.hermes/sessions/)
python -m evolution.skills.evolve_skill --skill my-skill --eval-source sessiondb
```

### Key Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `iterations` | 10 | GEPA optimization iterations |
| `population_size` | 5 | Variants per generation |
| `optimizer_model` | `openai/gpt-4.1` | Model for GEPA mutations |
| `eval_model` | `openai/gpt-4.1-mini` | Model for LLM-as-judge scoring |
| `max_skill_size` | 15,000 | Hard limit on evolved skill size (chars) |

### Cost Notes

Default models (OpenAI GPT-4.1) cost ~$2-10 per 10-iteration run. Replace with cheaper models via OpenRouter:

```bash
python -m evolution.skills.evolve_skill \
  --skill my-skill \
  --optimizer-model openrouter/deepseek/deepseek-v4-flash \
  --eval-model openrouter/deepseek/deepseek-v4-flash
```

### Architecture

```
Skill text → DSPy Module wrapper → GEPA Optimizer → Candidate variants
                ↑                                          │
          Execution traces (from batch_runner)              ▼
                                                   Constraint gates:
                                                   • Test suite (pytest)
                                                   • Size limits (≤15KB)
                                                   • Semantic preservation
                                                   • Caching compatibility
                                                            │
                                                            ▼
                                                   Best variant → PR
```

### Three Eval Data Sources

| Source | When to use |
|--------|-------------|
| **Synthetic** (default) | No existing test data — LLM reads skill, generates test cases |
| **SessionDB** | Has Hermes session history — mines `~/.hermes/sessions/` |
| **Golden** | Hand-curated examples — loads JSONL from `--dataset-path` |

### Fitness Dimensions (LLM-as-Judge)

| Dimension | Weight | What It Measures |
|-----------|--------|-----------------|
| `correctness` | 50% | Did the agent produce correct output? |
| `procedure_following` | 30% | Did it follow the skill's procedure? |
| `conciseness` | 20% | Appropriately concise? |
| `length_penalty` | — | Penalty for verbosity (subtracted from composite) |

### When to Propose Self-Evolution

Propose **after sufficiently complex projects** (agents, automations) where enough execution traces have accumulated for meaningful improvement. Do NOT propose for:
- Simple one-off tasks
- Projects with <5-10 sessions of real usage data
- Initial setup/configuration sessions

For complex projects: propose with cost estimate (DeepSeek ~$0.50-2/run). For simple: skip.

### External Skill Libraries (for evolution baselines)

These libraries use the same **YAML frontmatter + markdown body** format as Hermes SKILL.md, making them directly usable as evolution baselines:

| Resource | Size | Format | Compatibility |
|----------|------|--------|--------------|
| Antigravity Awesome Skills | 1,525+ SKILL.md files | Identical YAML+md | Direct copy |
| Everything Claude Code | 9 agents, 11 skill packs | Similar markdown | Minimal conversion (remove tools/model fields) |
| Addy Osmani Agent Skills | 7 skills | SKILL.md directories | Direct copy |

```bash
# Use Antigravity skills as evolution baselines
ln -s /home/oleg/antigravity-skills/skills/github /home/oleg/.hermes/skills/antigravity/github
HERMES_AGENT_REPO=/home/oleg/antigravity-skills \
  python -m evolution.skills.evolve_skill --skill github --iterations 5
```

See `references/external-skill-libraries.md` for full research and `references/hermes-agent-self-evolution-setup.md` for local installation details.

---

## 6. Plugin Evaluation (Context7)

Context7 is a documentation lookup plugin for Hermes Agent — search and retrieve up-to-date documentation for any library/API via `/ctx7 <query>`.

### When It's Worth It

Active development with npm/PyPI libraries that release frequently (React, Next.js, FastAPI, etc.) — use it >5 times/week.

### When It's Not

Stable libraries, business-logic work, internal systems. The overhead of installing + maintaining a plugin doesn't pay back with infrequent use.

### Installation

```bash
hermes plugins install https://github.com/caocuong2404/hermes-plugin-context7.git
hermes plugins enable context7
```

### vs Exa Search

Exa is a general web search API (via `curl`). Context7 is a Hermes plugin focused on library docs. Browser + web tools cover the same ground with more overhead. Both are optional.

See `references/context7-plugin.md` for plugin internals and `references/exa-setup.md` for Exa API setup.

---

## 7. Memory Auto-Compacting (On-Demand)

Hermes memory (MEMORY.md, USER.md) has fixed char limits: 2,200 and 1,375 chars. When full, the `memory` tool returns an error.

### Approach (no Honcho/Mem0 needed)

1. **Trigger:** memory tool returns "would exceed limit" error
2. **Same-turn response:** remove stale/duplicate entries, merge related facts, retry the write
3. **Cost per compact:** ~1,000 tokens (700 read + 300 write) — a few cents/year on DeepSeek
4. **Frequency:** once every few weeks at current fill rate (~85%)

Consider Honcho/Mem0 only when memory exceeds 5,000+ chars of durable facts and you need semantic search.

---

## 8. LSP — Built-in, No Setup

Language Server Protocol diagnostics run **automatically** in Hermes — no plugin, no install, no config.

- After every `write_file` or `patch` inside a git repo, Hermes queries the LSP (pyright, gopls, rust-analyzer, etc.)
- Only **new** diagnostics are shown (baseline subtracted)
- Outside git repos: dormant (zero cost)
- If LSP fails: silent fallback to syntax-only check
- **Zero LLM tokens** — LSP is a local process, not an API call

---

## Pitfalls

- **Don't reference Context7/Exa in Knowledge Priority unless actually installed.** Dead references waste tokens.
- **Don't put "always start with RAG" in Knowledge Priority.** RAG is a skill — load it when needed.
- **Don't ask Depth Mode every turn.** Default to automatic; offer only when ambiguous.
- **Don't keep duplicate skills.** Two skills covering the same ground inflate the skills block without adding value.
- **Keep reference files in sync with cron changes.** When a cron job is removed or consolidated, update the backup reference immediately.
- **Encrypted secrets must include ALL keys.** When adding a new API key, add it to `.env` and re-run `encrypt-secrets.sh`.
- **Never hardcode the encryption password in scripts.** Read from `.env`.
- **Remove old cron jobs and scripts after consolidation.** Leftover scripts confuse future sessions.
- **HERMES_AGENT_REPO must point to a directory with `skills/` subfolder.** When Hermes is pip-installed, set to `~/.hermes`.
- **Default evolution model is OpenAI GPT-4.1.** Override with `--optimizer-model` and `--eval-model` to avoid unexpected costs.
- **Not a replacement for human review.** All evolved variants must be reviewed before merging.
- **SessionDB mining requires real sessions.** If `~/.hermes/sessions/` is empty, use `--eval-source synthetic`.
