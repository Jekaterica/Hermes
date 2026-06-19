---
name: hermes-config-tuning
description: "Tune Hermes Agent configuration for maximum efficiency: layered config files (SOUL/USER/HERMES/CIM), compact system prompt, skills pruning, plugin evaluation."
version: 1.0.0
author: Oleg + Hermes Agent
tags: [hermes, configuration, optimization, system-prompt, skills, pruning]
---

# Hermes Config Tuning

Optimisez Hermes Agent for a specific user's needs: reduce token waste, eliminate dead references, keep only working tools in Knowledge Priority, and tailor identity files for Goal-First execution.

## Layered Configuration (5 files)

These files are read in priority order at session start. Each layer covers a distinct concern:

| File | Purpose | Created |
|------|---------|---------|
| `~/.hermes/SOUL.md` | Agent soul: identity, core principles, metric | ✅ |
| `~/.hermes/memories/USER.md` | User profile: role, values, cognitive traps, style | ✅ |
| `~/.hermes/strategic-context.md` | Active projects, decisions, dead ends — updated weekly | ✅ |
| `~/.hermes/cim-summary.md` | Cognitive Interaction Model v3.6: priorities, rules, forbidden | ✅ |
| `~/.hermes/HERMES.md` | Operational Framework: workflow, knowledge priority, autonomy | ✅ |

### Design Rules
- **No duplication** between files. SOUL = who I am. USER = who they are. CIM = decision rules. HERMES = process.
- **SOUL.md** is the shortest (~300 tokens) — identity and principles only.
- **USER.md** captures cognitive traps and format preferences so the agent can proactively help the user avoid their own patterns.
- **HERMES.md** is the operational layer — what actually changes tactically (workflow, knowledge priority, token policy).

## System Prompt Optimization

The default Hermes system prompt + memory + config files total ~6500-7000 tokens per call. The goal is to eliminate waste without losing meaning.

### What to cut (common waste)
1. **Dead tool references** — Context7 (plugin, not installed by default), Exa (external API, not a Hermes tool). Replace with what actually works: `web_search` or `browser` + `curl`.
2. **"Always start with RAG"** — RAG is a skill, not a built-in tool. Loading it on every call costs tokens. Make it on-demand: "load when task requires project/internal info".
3. **Depth Mode prompt every turn** — Instead of asking "быстрый/стандартный/глубокий" before every task, use automatic adaptation: simple → short, complex → deep. Offer explicitly only when depth is ambiguous.
4. **Source attribution on every answer** — Reserve `[Память]`, `[RAG]`, `[Web]` markers for deep/important answers. Omit for quick ones.
5. **Skills block (`<available_skills>`)** — ~2750 tokens with 118 skills. Prune to 40-50 relevant ones (~1050 tokens). Saves ~1700 tokens per call.

### Compact System Prompt Template (~700-800 tokens)
```
# SYSTEM: Hermes v3.6 — Goal-First Execution

## Core
Goal-First > process. Execution > analysis. Простота > сложность.
Метрика: ценность результата / (токены + время + сложность).
Прямо указывай на риски, переусложнение, неэффективные пути.

## Knowledge Priority
1. Память (SOUL.md, USER.md, strategic-context, cim-summary, HERMES.md)
2. RAG (Open Notebook) — проектная/внутренняя инфа. Загружать skill только когда нужно
3. web_search / curl — свежие данные, документация, API

## Depth
Адаптивная глубина. Простой запрос → коротко. Сложный → развёрнуто.
Если глубина неочевидна → спросить один раз.

## Error Recovery
2 однотипные ошибки → сменить стратегию.

## Source Attribution
[Память] [RAG] [Web] — только для глубоких ответов.

## Self-Check (значимые задачи)
Переусложнение? Правильный источник? Минимально достаточное?

## Permissions
Спрашивать перед изменением config/memory/security/поведенческих файлов.

## Запрещено
- Архитектурный дрейф
- Создание skills без одобрения
- Self-Evolution без явного согласия
- Использование несуществующих инструментов
```

### Error Recovery Setting
- USER.md originally had "3 одинаковые ошибки → стоп метод"
- System prompt v3.6 proposed "1 retry → смена стратегии"
- **Compromise: 2 retries → смена стратегии** — enough for flaky operations (builds, installs), not so many that the agent loops.
- Applied: `~/.hermes/memories/USER.md` and `~/.hermes/hermes-config/cim-summary.md`

## Skills Audit & Pruning

When the skills library has grown to 100+ entries, the `<available_skills>` block in system prompt costs ~2750 tokens. Prune to 40-50.

### Methodology
1. List all skills: `find ~/.hermes/skills -name 'SKILL.md' | sort`
2. Group by category (business, creative, mlops, github, etc.)
3. Classify each skill into **keep** or **archive** based on user's actual work patterns
4. Categories almost always archivale:
   - apple/* — no Mac
   - gaming/* — not relevant
   - red-teaming/* — not production
   - Most creative/* — unless user makes diagrams/UI mockups
   - media/ (except youtube-content)
   - smart-home/* — no smart home gear
   - social-media/* — not active
   - Most mlops/ (keep only eval-harness, agent-evaluation-framework, open-notebook-rag)
5. Watch for duplicates: `agent-evaluation` ≈ `agent-evaluation-framework`, `code-review-excellence` ≈ `code-reviewer`, `tdd-guide` ≈ `test-driven-development`, `plan` ≈ `planner`
6. Move archived skills to `~/.hermes/skills-archive/` preserving directory structure
7. Result: block shrinks from ~2750 to ~1050 tokens, saving ~1700 per call

### When to Load Archived Skills
Use `skill_view(name)` or `/skill <name>` on demand. The archive preserves full structure — no data loss.

## Skills Organization: Core + Vault + Catalog

Beyond simple pruning, skills can be organized into three tiers to minimize token waste while preserving full capability:

### Tier 1 — Core (in `~/.hermes/skills/`, always in context)
Skills for thinking, planning, architecture, debugging, and self-correction that are used in >50% of sessions:
- architect, planner, writing-plans, spike, architecture-decision-records
- cognitive-interaction-model (CIM)
- business-agent-architect, business-knowledge-engineering
- systematic-debugging, code-reviewer, security-reviewer, requesting-code-review
- hermes-agent, skill-evolution, hermes-agent-skill-authoring
- system-diagnostics, python-debugpy, node-inspect-debugger

~20 skills, ~500 tokens in the `<available_skills>` block.

### Tier 2 — Vault (in `~/.hermes/skills-vault/`, loaded on demand)
Domain-specific skills used in <15% of sessions. Moved out of `skills/` to keep the context block small:
- GitHub (6): pr-workflow, repo-management, issues, code-review, auth, codebase-inspection
- Productivity (5): obsidian, notion, google-workspace, ocr, nano-pdf
- Creative (3): architecture-diagram, sketch, excalidraw
- Business (3): sales-knowledge-rag, chat-widget, email-auto-responder
- Testing (2): agent-evaluation-framework, eval-harness
- Other (6): himalaya, youtube-content, arxiv, open-notebook-rag, native-mcp, webhook-subscriptions

~25 skills, zero tokens in context until needed.

### Tier 3 — Catalog (in `skills/core/skill-catalog/`, always in context)
A lightweight catalog skill (~150 tokens) lists every vault skill with a one-line description. When the agent sees a task that matches a vault skill, it loads it via `skill_view(name)`.

### Migration
```bash
# Create vault
mkdir -p ~/.hermes/skills-vault/{github,productivity,creative,business,testing,other}
# Move domain skills
mv ~/.hermes/skills/github/* ~/.hermes/skills-vault/github/
# Create catalog skill with skill_manage
```

### Effect on token budget
| Tier | Skills | Tokens in context |
|------|--------|-------------------|
| Core | ~20 | ~500 |
| Catalog | 1 | ~150 |
| Vault | ~25 | 0 (loaded on demand) |
| **Total** | **~46** | **~650** |
| vs 118 flat | 118 | ~2750 |

Saves ~2100 tokens per call. The cost: occasional `skill_view()` call (~500 input tokens) when a vault skill is needed in ~10% of tasks.

## Digital Twin / Weekly Backup

Save the complete agent configuration as a recoverable snapshot in the skills repository. This allows full reconstruction from scratch.

### What to back up
| Component | Source | Why |
|-----------|--------|-----|
| SOUL.md | ~/.hermes/SOUL.md | Agent identity and principles |
| USER.md | ~/.hermes/memories/USER.md | User profile |
| HERMES.md | ~/.hermes/HERMES.md | Operational Framework |
| cim-summary.md | ~/.hermes/cim-summary.md | CIM v3.6 |
| strategic-context.md | ~/.hermes/strategic-context.md | Context |
| config.yaml | ~/.hermes/config.yaml | Model, toolsets, security |
| scripts/ | ~/.hermes/scripts/ | Custom scripts |

### Encrypted secrets
API keys (Exa, etc.) must be stored encrypted since the repo is public:
```bash
# Encrypt
tar czf - -C ~/.hermes .env | \
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"PASSWORD" \
  -out ~/.hermes/skills/hermes-secrets/secrets.tar.gz.enc

# Decrypt
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"PASSWORD" \
  -in secrets.tar.gz.enc | tar xzf - -C ~/.hermes/
```

### Cron setup
```bash
# Weekly backup (Monday 3:00) — no_agent: true script
hermes cron create "0 3 * * 1" \
  --name hermes-weekly-backup \
  --script hermes-backup-weekly.sh \
  --no-agent
```

The script (`~/.hermes/scripts/hermes-backup-weekly.sh`) does everything:
1. Runs `encrypt-secrets.sh` to re-encrypt keys (Exa + GITHUB_TOKEN)
2. Copies vault/ from `skills-vault/` into the repo
3. Copies all config files into `hermes-config/` inside the repo
4. Copies scripts into `hermes-config/scripts/`
5. `git add -A && git commit -m "weekly: digital twin snapshot YYYY-MM-DD" && git push`

No daily cron — everything unified into one weekly snapshot.

### Recovery from scratch
```bash
git clone git@github.com:USER/Hermes.git ~/.hermes/skills
cp ~/.hermes/skills/hermes-config/* ~/.hermes/
openssl enc -d -aes-256-cbc -pbkdf2 \
  -in ~/.hermes/skills/hermes-secrets/secrets.tar.gz.enc | tar xzf - -C ~/.hermes/
hermes
```

## Exa Search Setup

Exa (exa.ai) is an external search API optimized for AI agents. It returns clean search results without browser overhead.

### Setup
```bash
# Add key to .env
echo "export EXA_API_KEY=your_key" >> ~/.hermes/.env
```

### Usage via curl
```bash
curl -s -X POST "https://api.exa.ai/search" \
  -H "Authorization: Bearer $EXA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "...", "numResults": 3}'
```

### When to use
- Fresh data from the web (news, docs, trends)
- Library documentation not covered by RAG
- General lookup when memory and RAG are insufficient

Use it as a third-tier knowledge source: Memory → RAG (Open Notebook) → Exa.

### vs Context7 Plugin
Exa is a general web search API. Context7 is a Hermes plugin for library documentation specifically. Evaluate per need — Context7 is narrower but structured for docs; Exa is broader but needs manual parsing. Both are optional; browser + web tools cover the same ground with more overhead.

## Depth Modes (Automatic)

Rather than asking the user to choose depth on every task, determine it automatically:

| Signal | Depth | Example |
|--------|-------|---------|
| Simple question, known fact | Short | "What time is it?", "Who wrote X?" |
| Standard task | Standard | "Review this PR", "Write a plan for Y" |
| Complex, multi-step, high risk | Deep | Architectural decision, new system design |
| Ambiguous | Ask once | "Нужен быстрый или глубокий разбор?" |

Implementation: embedded in SOUL.md and HERMES.md as "Adaptive Depth".



## Plugin Evaluation (Context7)

Context7 is a documentation lookup plugin for Hermes Agent.

**What it does:** Search and retrieve up-to-date documentation for any library/API via `/ctx7 <query>`.

**Installation:**
```bash
hermes plugins install https://github.com/caocuong2404/hermes-plugin-context7.git
hermes plugins enable context7
```

**API key:** Optional (`CONTEXT7_API_KEY` env var).

**When it's worth it:** Active development with npm/PyPI libraries that release frequently (React, Next.js, FastAPI, etc.).

**When it's not:** Stable libraries, business-logic work, internal systems. The overhead of installing + maintaining a plugin doesn't pay back if you use it <5 times a week.

## References
- `references/context7-plugin.md` — Context7 plugin details (files, tools, usage)
- `references/skills-organization.md` — Core + Vault + Catalog methodology
- `references/digital-twin-backup.md` — Weekly backup procedure and cron state
- `references/exa-setup.md` — Exa search API setup and usage
- `references/context-files-discovery.md` — AGENTS.md / CLAUDE.md / HERMES.md cross-ecosystem context files

## Pitfalls
- **Don't reference Context7/Exa in Knowledge Priority unless actually installed.** Dead references waste tokens and confuse the agent.
- **Don't put "always start with RAG" in Knowledge Priority.** RAG is a skill — load it when you need it. Pre-loading costs ~200 tokens per call with zero benefit for most tasks.
- **Don't ask Depth Mode every turn.** Users find it noisy. Default to automatic; offer only when depth is ambiguous.
- **Don't keep duplicate skills.** Two skills covering the same ground (e.g. `code-review-excellence` + `code-reviewer`) inflate the skills block without adding value. Keep the richer one, archive the other.
- **Keep reference files in sync with cron changes.** When a cron job is removed or consolidated (`skills-nightly.sh` deleted, daily cron removed), update `references/digital-twin-backup.md` immediately. Stale reference files cause confusion for future sessions.
- **Encrypted secrets must include ALL keys.** When adding a new API key (e.g. `GITHUB_TOKEN`), add it to `.env` and re-run `encrypt-secrets.sh`. The weekly backup only picks up what's in `.env` at encryption time.
