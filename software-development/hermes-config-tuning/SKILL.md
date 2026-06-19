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

## Pitfalls
- **Don't reference Context7/Exa in Knowledge Priority unless actually installed.** Dead references waste tokens and confuse the agent.
- **Don't put "always start with RAG" in Knowledge Priority.** RAG is a skill — load it when you need it. Pre-loading costs ~200 tokens per call with zero benefit for most tasks.
- **Don't ask Depth Mode every turn.** Users find it noisy. Default to automatic; offer only when depth is ambiguous.
- **Don't keep duplicate skills.** Two skills covering the same ground (e.g. `code-review-excellence` + `code-reviewer`) inflate the skills block without adding value. Keep the richer one, archive the other.
