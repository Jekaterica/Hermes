# Case Study: Смарта (CSIA) Transformation

## Before: Pure Prompt Engineering

**Framework:** OpenClaw
**Files:** 39 skill files + SYSTEM_PROMPT + TOOLS + knowledge-base + MEMORY
**Code:** Zero executable tools

### Problems identified:
1. **39 skills** — heavy overlap (Burn Rate Calc ≈ Micro-Cashflow Analyst ≈ Survival Resource Optimizer)
2. **Zero tools** — everything described, nothing runnable
3. **Memory** — static MEMORY.md, no write mechanism, empty "effective strategies" section
4. **Knowledge base** — 40 book titles with no actual content
5. **No escalation** — advised on everything, including beyond competence
6. **Rigid output** — 8-section format for ALL states, even GREEN
7. **No formula** — burn rate described conceptually but no computation

## After: Architecture with Tools

**Structure:**
```
workspace-smarta/
├── SYSTEM_PROMPT.md        # 97 lines (was 198)
├── AGENTS.md               # Startup + orchestration rules
├── TOOLS.md                # 8 skills + 4 scripts map
├── MEMORY.md               # JSON-backed structured memory
├── knowledge-base.md       # Concepts + cases (not just titles)
├── IDENTITY.md / SOUL.md   # Core identity
├── skills/ (8 modules)
│   ├── crisis-core.md          # State machine + priority arbiter
│   ├── income-reconstruction.md # 4-level income model
│   ├── debt-navigation.md       # Debt triage + RF laws
│   ├── reality-filter.md        # Scam detection + validation
│   ├── strategic-recovery.md    # YELLOW/GREEN planning
│   ├── employment-crisis.md     # Fast employment tactics
│   ├── human-layer.md           # Psychology + escalation
│   └── execution-engine.md      # Adaptive output + memory
└── scripts/ (4 tools)
    ├── memory-manager.py   # JSON memory read/write
    ├── state-detector.py   # RED/ORANGE/YELLOW/GREEN by numbers
    ├── burn-rate-calc.py   # Survival horizon + breakeven
    └── debt-triage.py      # Debt priority + legal risk
```

### Key Design Decisions

**Skill-to-State binding (not LLM choice):**
```
RED   → crisis-core + income-reconstruction + debt-navigation
ORANGE→ income-reconstruction + employment-crisis + debt-navigation
YELLOW→ strategic-recovery + income-reconstruction + human-layer
GREEN → strategic-recovery + human-layer
```
Always-on: crisis-core + reality-filter (filter)

**Adaptive output format by state:**
- RED: 1-3 actions, no 30d plans, no psychology
- GREEN: 2-line recommendation

**Escalation rules:**
- Suicidal thoughts → hotline number
- Large debt + assets → lawyer referral
- Medical → "я не врач"
- Panic → collapse to 1 step

**Memory constraints:**
- Only writes: state changes, effective strategies, failed strategies, new risks
- Max 50 observations (ring buffer)
- JSON-backed via Python script, not freeform text
