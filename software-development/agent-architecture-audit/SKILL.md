---
name: agent-architecture-audit
description: "Audit, diagnose and redesign existing AI agents: find common antipatterns, consolidate skill bloat, add real tools, escalation rules, and adaptive output formats."
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [agent-design, architecture-review, refactoring, autonomous-agents]
    related_skills: [writing-plans, systematic-debugging]
---

# Agent Architecture Audit

## Overview

When asked to review, fix, or improve an existing agent — whether built with OpenClaw, Claude Code, Codex, or Hermes — follow this systematic audit process. Most agents start as prompt engineering projects and accumulate structural debt: skill bloat, no real tools, no escalation, no feedback loop. This skill gives you the checklist to find and fix those issues.

**Core principle:** An agent is only as good as its weakest structural layer. Fixing prompts without fixing architecture is polishing a leaky pipe.

## The Five Gaps

Every agent audit checks these five dimensions. Missing any one means the audit is incomplete.

### 1. Skill Bloat Gap
**Symptom:** 30+ skill files, all with similar names and overlapping descriptions.

**Diagnosis:**
- Count the skills. If >15, bloat is likely.
- Read 3-5 skill files. Do they share the same structure? The same verbs?
- Run a pairwise comparison: do any two skills cover overlapping territory?

**Treatment:**
- Consolidate by function, not by name. Group skills that serve the same purpose.
- Target: 7-12 real modules. Anything beyond 12 is noise.
- The LLM cannot meaningfully choose from 39 options — you're paying for a roulette wheel, not routing.
- Give each consolidated skill: (a) clear trigger conditions, (b) specific algorithms, (c) concrete forbidden items, (d) edge cases.

### 2. Toolization Gap
**Symptom:** The agent describes tools it cannot use. "Check FSSP database" but there's no API call. "Calculate burn rate" but there's no formula. "Write to memory" but memory is a static text file.

**Diagnosis:**
- Every verb in every skill: is it backed by actual code or is it a text description?
- Look for: "рассчитать", "проверить", "записать", "отправить" followed by prose, not scripts.
- Check if memory is a JSON-backed file, a database, or plain markdown.

**Treatment:**
- Convert metrics-heavy modules into real Python scripts the agent can run via terminal.
- At minimum: memory manager, calculator tools, data validators.
- The script doesn't need to be complex — 50-100 lines is enough. What matters is that it produces verifiable output, not LLM hallucinated numbers.
- A burn rate calculator that takes `--income 87000 --expenses 95000` and returns `{"survival_horizon_days": 65}` is infinitely more trustworthy than an LLM guessing the same number from prose.

### 3. Escalation Gap
**Symptom:** The agent never says "I don't know" or "this needs a specialist". It tries to solve everything itself.

**Diagnosis:**
- Search for escalation rules. If none exist, the agent WILL eventually give dangerous advice.
- Check: suicide prevention, legal jeopardy, medical issues, domain boundaries.

**Treatment:**
- Add explicit escalation rules covering at minimum:
  - Suicidal ideation → hotline number
  - Legal risk (debt >2M, asset seizure) → recommend lawyer
  - Medical questions → "I am not a doctor"
  - Panic/overwhelm → simplify to 1 step, offer to pause
  - Beyond competence → "My specialty is X. I may be wrong about Y."

### 4. Feedback Loop Gap
**Symptom:** The agent gives advice but never learns whether it worked. No tracking, no analysis, no improvement.

**Diagnosis:**
- Is there a mechanism to mark strategies as "worked" or "failed"?
- Is there a periodic review of past advice quality?
- Does the agent adapt based on outcomes?

**Treatment:**
- Add a memory field like `strategies.completed` and `strategies.failed`
- Teach the agent to write outcomes: "This strategy worked → save as effective"
- Add a periodic review prompt: "Analyze last N interactions. Which patterns helped? Which didn't?"

### 5. Output Rigidity Gap
**Symptom:** The same 8-section template for every user, every state, every question. A user in crisis gets the same format as a stable user asking a simple question.

**Diagnosis:**
- Is the output format conditional on user state?
- Does the format change based on context (emergency vs routine vs quick question)?

**Treatment:**
- Make output format state-dependent:
  - Emergency: 3 action items max, no long-term plans
  - Recovery: full structured format
  - Stable: short, respects user's time
- The format should serve the user, not the other way around.

## Audit Procedure (Step-by-Step)

### Phase 1: Discovery

```markdown
1. Map the workspace tree
   - List all files in the agent workspace
   - Note: SYSTEM_PROMPT, AGENTS, AGENTS instructions, skills/, knowledge-base, tools/, scripts/

2. Read the core identity files
   - IDENTITY.md — who is this agent?
   - SOUL.md — what is its character?
   - SYSTEM_PROMPT.md — how does it operate?
   - USER.md — who is it serving?

3. Catalog all skills
   - List every .md file in skills/
   - Count them. Flag if >15.
   - Read 3-5 representative ones. Note overlapping content.

4. Check for real tools
   - Is there a scripts/ directory?
   - Can the agent actually calculate anything, or does it describe calculations?
   - Can it write to persistent memory?

5. Check escalation
   - Search for: "эскалация", "специалист", "юрист", "психолог", "врач", "горячая линия"
   - If none found, this is a gap.
```

### Phase 2: Diagnosis

For each gap found, document:
- **What exists:** current state
- **What's missing:** the gap
- **Impact:** why it matters (what breaks if left unfixed)

### Phase 3: Redesign

```
For each gap, apply the treatment from the Five Gaps section above.

Priority order:
1. Escalation gap (safety-critical)
2. Toolization gap (trustworthiness-critical)
3. Skill bloat gap (quality-critical)
4. Output rigidity gap (usability-critical)
5. Feedback loop gap (growth-critical)
6. **For crisis/survival agents specifically:**
   - Escalation → #1 always
   - **Follow-up loop (Commitment Protocol)** → #2 — agent must track whether advice was followed and log outcomes
   - Toolization → #3
   - Compression First → #4 — startup lines matter; delete fluff files (SOUL.md, etc.)
```

### Phase 4: Implementation

1. Delete redundant skill files
2. Create consolidated skill files (target: 7-12)
3. Write real Python scripts (at minimum: memory manager + 2 domain calculators)
4. Update SYSTEM_PROMPT with escalation rules and adaptive output
5. Update AGENTS startup instructions
6. Update knowledge base — replace book lists with actual content
7. Test scripts independently
8. Verify agent reads new structure correctly

## Common Antipatterns

| Antipattern | Signs | Fix |
|-------------|-------|-----|
| **Index-card skills** | Every skill is 15 lines: name, objective, output format. No algorithms. | Merge by function. Add decision trees, formulas, edge cases. |
| **Toy knowledge base** | 40 book titles, zero content from any of them. LLM needs read the books to use them. | Replace titles with extracted concepts, quotes, and practical applications. |
| **Static memory** | MEMORY.md written by the user, never updated by the agent. | Add memory management script + instructions to write after each meaningful interaction. |
| **Uniform voice** | Agent talks the same way to a suicidal user and a curious prospect. | Add state-dependent tone and format rules. |
| No forbidden list | Agent can recommend anything. | Add explicit forbidden section per skill. Include real-world dangerous patterns. |
| **Empty memory infrastructure** | MEMORY.md exists but is a template — no data ever written. Memory manager scripts exist but never called. | Add a startup instruction: 'Write at least one observation after each meaningful session.' Scripts without data are theater. |
| **Fluff files** | SOUL.md, STYLE.md, PERSONALITY.md — poetic files with zero operational value. 24 lines that distill to 'be helpful'. | Delete. Merge any unique content into IDENTITY.md (3-5 lines max). Every file on startup costs tokens. |
| **Duplicated core instructions** | SYSTEM_PROMPT.md and execution-engine.md both define output format identically. Two sources of truth. | Consolidate into one. Remove format from execution-engine, keep only unique parts (action algorithm, escalation). |
| **No follow-up loop** | Agent gives advice, never checks if followed. For crisis/survival agents this is critical — user needs accountability. | Add Commitment Protocol: record user's commitment, check next session, log outcome. |
| **Fantasy infrastructure** | "Check API", "query database", "send notification" — but no actual connection. (Also known as **"100% prompt, 0% code"** — the agent is a talker, not a doer.) | Either implement the tool or replace with "recommend the user to check manually via [platform URL]". |

## Verification Checklist

After redesign, verify:

- [ ] Skills reduced to 7-12, no functional overlap
- [ ] At least 1 real script (memory) + 2 domain scripts
- [ ] Escalation rules covering: suicide, legal, medical, panic, out-of-domain
- [ ] Output format varies by user state
- [ ] Memory is script-managed, not static
- [ ] Knowledge base has actual content, not just references
- [ ] Startup instructions tell the agent what to load and what to defer
- [ ] Agent knows its own boundaries and when to say "I can't help here"

## Appendix: Russian-Language Agents

When auditing agents for Russian-speaking users, check these region-specific concerns:

### РФ Legal & Regulatory Knowledge
- Verify РФ-specific laws: ТК РФ, 127-ФЗ (банкротство), 353-ФЗ (МФО)
- Verify РФ platforms: hh.ru, ФССП, Госуслуги, Авито, YouDo
- Watch for: "американские" схемы and non-functional РФ platforms
- Крипта/трейдинг as primary income — 97% lose money; disable
- Инфоцыганщина — specific РФ phenomenon; block in knowledge base

### РФ Platform Integration
- Job search: hh.ru, Авито Услуги, YouDo, Профи.ру
- Government: Госуслуги, ФНС, ФССП
- Legal: КонсультантПлюс, Гарант (or their public excerpts)
- ВТБ/Сбер/Т-Банк APIs only via official channels

### РФ Communication Style
- Formal register preferred unless relationship is established
- Avoiding English business models that don't apply in Russia
- Cold analytics, professional tone, no motivational fluff
- Direct problem-solving over conversational niceties

## User-Specific Preferences (this user)

When auditing agents for this user (Oleg):
- Language: Russian only. Dry, precise, no motivational fluff.
- Architecture preference: state machines + skill routing. Not generic chatbot prompts.
- Reminders/cron: only implement if explicitly requested. Default: no periodic pushes.
- Communication: cold analytics, "по делу", functional over elegant UI.
