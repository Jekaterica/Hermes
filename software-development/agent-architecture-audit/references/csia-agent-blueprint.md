# CSIA Agent Blueprint — Crisis Survival Intelligence Agent v3

A worked example of the agent-architecture-audit methodology applied to a real agent. This shows what a properly redesigned domain-specific agent looks like after consolidation, toolization, escalation, and adaptive output.

## Original State (Before Audit)

- 39 skill files with heavy overlap (3-4 modules doing "income analysis")
- Zero real tools — every "calculate" and "check" was text in a markdown file
- Zero escalation rules — agent tried to solve every problem itself
- Static memory — MEMORY.md was user-edited text, never updated by the agent
- Rigid output — same 8-section format for crisis questions and casual check-ins
- Knowledge base = 40 book titles with zero content from any of them

## Architecture (After Redesign)

### 8 Core Skills (down from 39)

| Skill | Purpose | Activation |
|-------|---------|------------|
| `crisis-core` | State detection + priority arbiter + anti-collapse | Every request |
| `income-reconstruction` | 4-level income pipeline (emergency → microbusiness) | RED/ORANGE |
| `debt-navigation` | Debt triage + RF laws + bankruptcy strategy | RED/ORANGE/YELLOW |
| `reality-filter` | Scam detection + reality validation + cognitive traps | Always (parallel) |
| `strategic-recovery` | Opportunity detection + ROI selection + growth planning | YELLOW/GREEN |
| `employment-crisis` | Fast employment + social capital + negotiation | RED/ORANGE/YELLOW |
| `human-layer` | Psychology + behavioral patterns + specialist referral | YELLOW/GREEN (or user-initiated) |
| `execution-engine` | Adaptive output format + memory + escalation | Always (meta) |

### 4 Real Python Scripts

| Script | Function | Trigger |
|--------|----------|---------|
| `state-detector.py` | RED/ORANGE/YELLOW/GREEN classification from income/expenses/debts | User provides numbers |
| `burn-rate-calc.py` | Survival horizon in days + urgency level + breakeven needed | User provides income/expenses/savings |
| `debt-triage.py` | Sort debts by criticality + legal risk + action suggestions | User provides debt list |
| `memory-manager.py` | Structured JSON-backed persistent memory via terminal | State change, strategy outcome |

### State Machine

```
DETECT STATE → SELECT SKILLS (primary + secondary + filter) → 
APPLY FILTER (reality) → GENERATE OUTPUT (adaptive format) → 
ESCALATE (if needed) → WRITE MEMORY (if changed)
```

### Adaptive Output Format

| State | Sections | Max Actions | Long-term Plans? |
|-------|----------|-------------|------------------|
| RED | STATE + DIAGNOSIS + ACTIONS_0-24h + RISKS | 3 | NO |
| ORANGE | STATE + SITUATION + ACTIONS_7d + INCOME + RISKS | 5 | Short only |
| YELLOW | Full: STATE + RISKS + 0-24h + 7d + 30d + INCOME | 8 | Yes |
| GREEN | STATE + RECOMMENDATION + RATIONALE | 2 | Only on request |

### Escalation Rules

| Situation | Action |
|-----------|--------|
| Suicidal ideation | "Позвони 8-800-200-01-22. Это требует специалиста." |
| Legal risk (debt >2M, asset seizure) | "Рекомендую юриста по банкротству." |
| Medical questions | "Я не врач. Обратись к терапевту." |
| Panic, can't hear logic | Simplify to 1 step. If fails: "Давай завтра." |
| Beyond domain | "Моя специализация — финансовое выживание." |

## Key Lessons from This Audit

1. **Skill count matters.** The original 39 skills overwhelmed the LLM's selection mechanism. 8 skills with state-dependent routing eliminated the selection problem entirely.

2. **Real tools > text descriptions.** A `burn-rate-calc.py` that actually does math is worth more than 5 markdown files describing "how to calculate burn rate".

3. **Safety must be structural, not aspirational.** "Don't give bad advice" is not a safety system. Explicit escalation rules with concrete triggers are.

4. **Format must serve the user.** A crisis user cannot process an 8-section plan. A stable user doesn't need one. Same format for both = wrong for both.

5. **Knowledge needs extraction, not bibliography.** 40 book titles = 40 reasons to hallucinate. Extracted concepts with practical applications = usable knowledge.

6. **Memory only matters if the agent can write to it.** A static MEMORY.md that requires human editing is not memory — it's a note file.

## When to Use This Blueprint

- Financial crisis / survival agents
- Any domain where user state dramatically changes what kind of response is appropriate
- Any agent that needs to escalate to human specialists
- When you need to explain the pattern to a non-technical stakeholder

## When NOT to Use This

- Simple FAQ bots (overkill)
- Agents that only serve one function (no state machine needed)
- Users who explicitly want a "warm" conversational style (this assumes cold analytics)
