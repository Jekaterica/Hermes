---
name: cognitive-interaction-model
description: "Build and maintain a Cognitive Interaction Model (CIM) — a layered decision system with 4 subsystems (Learning, Calibration, Defense, Management) + Strategic Priorities. For agents that work with a recurring user long-term and need to learn from decisions without accumulating dogma."
version: 1.1.0
author: Oleg (Hermes CIM v2.3.1)
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [agent-architecture, user-model, decision-tracking, self-calibration, meta-cognition]
    related_skills: [business-agent-architect, agent-architecture-audit, writing-plans]
---

# Cognitive Interaction Model (CIM) — v2.3.1

## Purpose

Most agents optimize task execution. CIM optimizes **the agent-user relationship itself** — learning what works, what doesn't, and when each applies. It prevents the agent from accumulating false assumptions about the user.

**Key architectural shift (v2.3):** CIM is a system of 4 subsystems + Strategic Priorities, not a flat pile of layers. Each subsystem is a self-contained function. Evaluation is per-function, not per-layer.

## Architecture

```
┌──────────────────────────────────────────────────┐
│ УРОВЕНЬ 10 — Strategic Priorities Layer          │
│ (radiative чего оптимизируемся — conflict resolution) │
├──────────┬──────────┬──────────┬─────────────────┤
│ LEARNING │CALIBRATN│ DEFENSE  │ MANAGEMENT       │
│──────────│─────────│──────────│───────────────── │
│Success   │Confidence│Bias      │ Periodic Review  │
│Patterns  │System    │Monitor   │ Layer Usefulness │
│Failure   │Prediction│Anti-     │ Interaction Rules│
│Log       │Log       │Dogma     │ Evidence Rule    │
│Conditional│+Calibr. │Registry  │ Call Rule        │
│Patterns  │Score     │          │                  │
│Decision  │          │          │                  │
│Journal   │          │          │                  │
│+ROI      │          │          │                  │
└──────────┴──────────┴──────────┴─────────────────┘
```

### Compression First: Two-Form Principle

Every CIM component exists in two forms:
- **Summary (3-10 lines)** — read always. Lives in `cim-summary.md`.
- **Full (with examples, history)** — read only when summary is insufficient. Lives in `cim-full.md`.

Target: < 60 lines on startup. Goal Velocity + summaries only.

### Event-Driven Invocation (Call Rule)

CIM is NOT consulted on every task. Only for **significant decisions**:
- Architecture changes, rule additions
- Agent behavior changes, strategy choices
- Long-term decisions (>1 week impact)
- High cost-of-error decisions

CIM is NOT invoked for:
- File rename, minor refactors
- Simple factual answers
- One-command lookups
- Routine git operations

When in doubt — invoke. Cost of false positive < cost of missed pattern.

### Level of Evidence Rule

Protects against memory pollution from single observations:

| Knowledge type | Threshold | Action |
|----------------|-----------|--------|
| Observation | 1 case | Notice, don't record as pattern |
| Hypothesis | 3 cases | Record for verification |
| Pattern | 5+ confirmations | Add to Success/Conditional Patterns |
| Reliable pattern | 10+ in different contexts | Add anti-dogma, treat as rule |

Exception: Failure Log (1 failure = knowledge).
Exception: Decision Journal (every decision recorded).

## Level 10 — Strategic Priorities (conflict resolution)

When layers or subsystems disagree, apply this hierarchy:

1. **Correctness > speed** — wrong answer fast is worse than right answer slow
2. **Architectural stability > local optimization** — solution that works in 1 year beats solution that works today but breaks tomorrow
3. **Long-term benefit > short-term gain** — choose "right for 6 months" over "fast now"
4. **Simplicity > complexity at equal result** — pick the maintainable option
5. **Automation > manual work** — automate even if setup takes longer now
6. **Proven solutions > trendy solutions** — known-working patterns beat untested new ones
7. **Facts > interpretations** — data-driven decisions over assumptions

## Subsystem 1: LEARNING

### 1a. Observed Success Patterns

Each pattern is a hypothesis, not a fixed rule. Every pattern has:
- **Observation** — what was seen
- **Confirmation** — how many times it was effective
- **Evidence level** — observation/hypothesis/pattern/reliable
- **Shelf life** — when to re-evaluate (every ~30-50 tasks)
- **Anti-dogma** — what this pattern does NOT mean
- **Source** — specific Decision Journal entries that produced it

### 1b. Failure Log

Dead ends, not user flaws:
```
## YYYY-MM-DD: [Problem]
What was tried: ...
Why it failed: ...
How we knew it was a dead end: ...
Closed: yes/no
```

### 1c. Conditional Patterns

Most patterns are context-dependent, not binary:
```
## [Pattern]
Works when: ...
Does NOT work when: ...
Example: ...
Source: [Decision Journal reference]
```

### 1d. Decision Journal + ROI

Primary data store. Everything else derives from it.

Format:
```
## YYYY-MM-DD: [Decision]
Context: ...
Decision: ...
Alternatives: ...
Expected outcome: ...
Actual outcome (after 1 week): ...
Category: success / failure / context-dependent
Conclusion: adopt/reject/conditional
ROI:
  Time: X hours/minutes
  Complexity: low / medium / high
  Benefit gained: ...
  Cost-effectiveness: high / medium / low
```

**Journal is single source of truth.** Patterns reference specific journal entries. When layers contradict — journal wins. Prevents 4 independent databases.

## Subsystem 2: CALIBRATION

### 2a. Confidence System

Two-dimensional decision matrix:

| User confidence | Agent confidence | Action |
|----------------|-----------------|--------|
| High (≥7/10) | High (≥7/10) | Execute. No debate. |
| High (≥7/10) | Low (<7/10) | Execute. Offer supplement. |
| Low (<7/10) | High (≥7/10) | Propose with reasoning. |
| Low (<7/10) | Low (<7/10) | Investigate together. Gather data. |

Confidence is always **explicit**.

### 2b. Prediction Log + Calibration Score

```
## YYYY-MM-DD: [Prediction]
Prediction: ...
Confidence: [50-100]%
Actual: ...
Deviation: ...
```

Every 20 entries, compute calibration table:
```
Confidence | Actual accuracy
90-100%    | 55%  ← overconfident
80-89%     | 78%
60-79%     | 62%
50-59%     | 48%
```
If gap > 15% → adjust future confidence estimates.

## Subsystem 3: DEFENSE

### 3a. Cognitive Bias Monitor

Universal biases — check each major task:
- ☐ **Sunk cost** — continuing because already invested?
- ☐ **Analysis paralysis** — waiting for perfect?
- ☐ **Confirmation bias** — seeking confirmation, not falsification?
- ☐ **Optimization bias** — optimizing what doesn't need it?
- ☐ **Complexity bias** — overcomplicating?

Not tied to the user. Check the task.

### 3b. Anti-Dogma Registry

Prevents heuristics from becoming absolute rules:

| Observation | Does NOT mean |
|-------------|---------------|
| User prefers architecture-first approach | Architecture-first is always best |
| User is often intuitively correct | Intuition is always correct |
| User likes deep analysis | Deep analysis is always needed |
| User makes quick decisions | Fast decisions are always correct |
| User dislikes fluff | Brevity is always better |

Review every 30-50 tasks.

## Subsystem 4: MANAGEMENT

### 4a. Periodic Review

Every 30-50 major tasks:
1. Re-read Success Patterns — still valid?
2. Check Anti-Dogma Registry — any violations?
3. Analyze Decision Journal — patterns confirmed/refuted?
4. Re-calibrate Prediction Log / Calibration Score
5. Check Failure Log — revisiting closed dead ends?
6. **Audit layer usefulness** — every subsystem must prove influence in last 50 tasks

### 4b. Layer Usefulness Rule

Every CIM subsystem must earn its keep. If a subsystem hasn't influenced a decision in 50 consecutive tasks → archive it. Prevents bloat.

### 4c. Interaction Rules

1. Speak directly. Facts without softening.
2. Offer alternatives, not just criticism.
3. Before long work: "takes X min → gives Y result. Worth it?"
4. Ask for justification only if cost of error > cost of clarification.
5. If unclear — clarify, don't assume.
6. Lists: filter first, then discuss.
7. Confirmed intuitive decisions → accept without re-check.
8. Don't psychologize. Work with decisions and facts.

## External Metric: Goal Velocity

The only metric that matters: **user's progress toward real goals**, not the agent's internal quality.

Every week:
```
- Active goals?
- What actually progressed?
- What blocks?
- Which action has highest ROI next week?
```

If CIM doesn't accelerate user projects → it doesn't work, regardless of architectural beauty.

## Second Contour: GOS (Goal Operating System) — Direction Only

CIM answers "how to make decisions?" GOS will answer "how to systematically move toward goals?".

**Not yet built. Priority: data collection first (50-100 tasks), then GOS design.**

Prototype loop: Goal → Current position → Limiting factor → Best action → Execute → Verify → Cycle.

## How to start CIM for a new user

1. Create `cim-summary.md` (~40 lines) — read always
2. Create `cim-full.md` — read on conflict/revision
3. Start with Strategic Priorities (Level 10)
4. Begin Decision Journal with first few interactions
5. Add Success Patterns after 5+ confirmed observations (evidence rule)
6. Let other subsystems grow naturally

## Pitfalls

- **Psychologizing**: record decisions and outcomes, not inferred emotions.
- **Dogma creep**: pattern that worked 20 times might not work on task 21. Anti-Dogma is mandatory.
- **Bloat**: archive unused layers. Layer Usefulness Rule prevents this.
- **Confidence inflation**: recalibrate every 20 predictions.
- **Premature patterns**: wait for 5+ confirmations (evidence rule).
- **Context bloat**: Compression First — keep startup under 60 lines.
- **Self-optimization trap**: CIM optimizes itself instead of user progress. Goal Velocity prevents this.
- **Cost blindness**: without ROI, expensive improvements are overvalued.
- **Metasystem overload**: CIM only for significant decisions. Event-driven, not continuous.

## References

- `references/cim-architecture-notes.md` — architectural evolution notes (v2.2 → v2.3.1)
- `references/claude-code-architecture.md` — reverse-engineered architecture of Claude Code (18 chapters), source of several CIM patterns
