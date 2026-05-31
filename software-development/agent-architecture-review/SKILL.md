---
name: agent-architecture-review
description: "Audit, critique, and restructure AI agent architecture: consolidate bloated skills, add real tools, fix memory, enforce safety and escalation."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [agent-architecture, prompt-engineering, restructuring, review, agent-design]
    related_skills: [systematic-debugging, writing-plans, spike]
---

# Agent Architecture Review

## Overview

AI agents (OpenClaw, Hermes, Claude Code, Codex) often start as pure prompt-engineering: a SYSTEM_PROMPT.md, a folder of skill files, a knowledge-base, and no actual executable code. This skill covers **how to audit such an agent and transform it from a "text-only advisor" into a functional tool-wielding system.**

**Core principle:** Most agent quality problems are architecture problems, not prompt problems. More text doesn't fix what more code should handle.

## When to Use

- User asks you to review/audit an existing AI agent
- You see 20+ skill files that overlap in function
- Knowledge base is just a list of book titles with no actual content
- No real tools (Python scripts, API wrappers, data processors)
- Memory is a static text file, not backed by any persistence mechanism
- No escalation rules (agent advises on everything, even outside competence)
- Output format is rigid (same 8 sections for RED crisis and GREEN growth)
- State machine exists but skills aren't bound to states

## The Audit Framework (5 Dimensions)

### 1. Skill Bloat Check
**Problem:** 30+ skill files that overlap 80% in function. LLM can't meaningfully choose.

**Diagnosis:**
```
Skill A ≈ Skill B ≈ Skill C (same domain, minor wording diff)
Meta-skills mixed with domain skills (compression, memory, contradiction — these are not skills)
Skills that are just "roles" with no actual algorithm
```

**Fix:** Consolidate to 7-12 real modules:
- Each must have a UNIQUE function
- Each must have a concrete algorithm/decision tree
- Meta-instructions go in SYSTEM_PROMPT or AGENTS.md, not as skills
- Skills should have a `replaces:` list so the LLM knows what old modules folded in

### 2. Tool Gap Analysis
**Problem:** Agent describes what it COULD do but has no code to actually DO it.

**Diagnosis:**
```
Tool described in TOOLS.md → No actual script/function
"Can check FSSP debts" → No API call exists
"Can calculate burn rate" → No formula, no computation
Memory mentioned → Static text file, no write mechanism
```

**Fix:** Create `scripts/` with real executable tools:

| Tool Type | Purpose | Example |
|-----------|---------|---------|
| **State detector** | Classify crisis level from numbers | `state-detector.py --income X --expenses Y` |
| **Calculator** | Compute survival metrics | `burn-rate-calc.py --income X --expenses Y` |
| **Triage engine** | Sort items by priority | `debt-triage.py --debts [...]` |
| **Memory manager** | Read/write persistent store | `memory-manager.py set section.key value` |

### 3. Memory Architecture
**Problem:** Memory is a markdown file that grows unstructured or is never written to.

**Diagnosis:**
```
MEMORY.md has empty sections ("Эффективные стратегии (что сработало)" — empty)
No mechanism to WRITE to memory
Memory is read-only, so the agent never learns
```
**Fix:**
- Memory as structured JSON inside the markdown file
- A Python script that reads/writes individual fields
- Only store: state changes, effective strategies, failed strategies, risk observations
- Cap at N entries (e.g. 50 observations max) so context doesn't bloat

### 4. Safety & Escalation
**Problem:** Agent has no boundaries. Advises on everything, even where dangerous.

**Diagnosis:**
```
No rules for: suicidal ideation, medical advice, legal counsel beyond competence
No "здесь я не специалист" language
Agent always tries to answer, even outside domain
```

**Fix — add explicit escalation table:**
| Situation | Action |
|-----------|--------|
| Suicidal ideation | Hotline number, "это к специалисту" |
| Legal with high stakes | "Рекомендую юриста, я подготовлю вопросы" |
| Medical | "Я не врач" |
| Panic/paralysis | Reduce to 1 step. If persists → pause |
| Outside competence | "Моя специализация — X. Здесь могу ошибаться." |

### 5. Adaptive Output Format
**Problem:** Same rigid format for every state. User in crisis gets 8-section essay.

**Fix:** Format varies by state:
- **RED** (crisis): 1-3 actions, no 30-day plans, no psychology
- **ORANGE** (pressure): cashflow focus, 7-day horizon
- **YELLOW** (recovery): full analysis, 30-day plan, psychology allowed
- **GREEN** (stable): 2-line recommendation, respect user's time

## The Transformation Recipe

### Phase 1: Discover
1. Read ALL files in the agent workspace
2. Map skill overlap (A≈B≈C)
3. Count tools vs tool-descriptions
4. Check memory mechanism
5. Identify missing safety rules

### Phase 2: Design
1. Consolidate skills to 7-12 (list what each replaces)
2. Choose 3-5 tools to implement first (highest ROI)
3. Design structured memory format (JSON-backed)
4. Write escalation and output-format rules
5. Update knowledge-base from "book list" to "actual concepts"

### Phase 3: Execute
1. Delete old skill files
2. Write new skill files with clear replacement pointers
3. Create scripts/ with runnable Python tools
4. Rewrite SYSTEM_PROMPT.md (tighter, cleaner)
5. Rewrite AGENTS.md (new startup instructions)
6. Rewrite MEMORY.md (new JSON-backed format)
7. Rewrite knowledge-base.md (concepts + cases, not just titles)
8. Update TOOLS.md, IDENTITY.md, SOUL.md for consistency
9. Update MCP schema if present

## Common Anti-Patterns

| Anti-pattern | Why it fails | Fix |
|-------------|-------------|-----|
| 30+ skills | LLM can't choose; context noise | 7-12 modules, state-bound |
| "Can do X" but no code | Agent can't execute | Write the tool first |
| Static memory file | Agent never learns | JSON + write script |
| Book-list KB | Agent already knows titles | Add actual content, concepts, cases |
| Rigid output format | Wrong for user's state | Adaptive by state |
| No escalation | Agent gives bad/dangerous advice | Explicit rules + hotline numbers |
| 100% prompt, 0% code | Agent is a talker, not a doer | Real scripts + cron tasks |

## Russian-Language Agents (Special Notes)

When auditing agents for Russian-speaking users:
- Verify РФ-specific laws (ТК РФ, 127-ФЗ банкротство, 353-ФЗ МФО)
- Verify РФ platforms (hh.ru, ФССП, Госуслуги, Авито)
- Watch for: "американские" схемы, неработающие платформы в РФ
- Крипта/трейдинг как основной доход — 97% теряют деньги, запретить
- Инфоцыганщина — специфический РФ феномен, блокировать
