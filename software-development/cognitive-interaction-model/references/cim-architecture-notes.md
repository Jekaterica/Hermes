# CIM v2.3.1 — Architectural Evolution Notes

## How v2.2 → v2.3.1 changed

### Structural: Flat layers → 4 subsystems
- **Before:** 10+1 flat layers (Success Patterns, Confidence System, Decision Journal, Prediction Log, Conditional Patterns, Failure Log, Bias Monitor, Anti-Dogma, Periodic Review, Layer Usefulness Rule + Strategic Priorities)
- **After:** 4 subsystems (Learning, Calibration, Defense, Management) + Strategic Priorities
- **Why:** Easier to evaluate by function than by layer. One subsystem can contain multiple layers that serve the same purpose.

### Invocation: Always-on → Event-driven
- **Before:** Every task triggered full CIM consideration
- **After:** Only significant decisions trigger CIM (architecture, rules, strategy, high-cost errors)
- **Why:** Prevented 20% task / 80% methodology death spiral

### Storage: Bloated → Compressed
- **Before:** 361 lines read every startup
- **After:** 32 lines summary + 361 lines full (full read on demand only)
- **Why:** Cost of reading context > cost of storing it. Compression First became the single most valuable change.

### Source of truth: Distributed → Centralized
- **Before:** Success Patterns, Conditional Patterns, Failure Log, Decision Journal — 4 independent stores
- **After:** Journal is primary. Everything else references Journal entries.
- **Why:** Eliminated contradiction between layers. Journal wins on conflict.

### Metric: Internal → External
- **Before:** "How many patterns accumulated?" "Is my architecture good?"
- **After:** Goal Velocity — "What real user goals progressed?"
- **Why:** The system that optimizes itself is a trap. The system that accelerates user goals is a tool.

### Evidence: Implicit → Explicit
- **Before:** One observation could become a pattern
- **After:** Level of evidence: 1 (observation) → 3 (hypothesis) → 5+ (pattern) → 10+ in different contexts (reliable)
- **Why:** Memory pollution from single events destroyed trust in patterns.

### Cost awareness: Absent → Present
- **Before:** Decision recorded outcome but not cost
- **After:** ROI field per decision: time, complexity, benefit, cost-effectiveness
- **Why:** "3% quality gain in 5 hours" is worse than "2% gain in 20 minutes" — without ROI, agents overvalue expensive improvements.

## Key realization that drove v2.3

CIM had no answer to "radiative чего оптимизироваться?" (what are we optimizing for?). All 9+1 layers answered "how to work better" but not "what should we prioritize when they conflict." Strategic Priorities Layer filled that gap.

## The self-revision

The reviewer also revised his own assessment mid-session:
- **Initial bias:** Overvalued number of layers, underestimated cost of reading
- **Correction:** Compression First + event-driven invocation
- **Lesson:** Layer count is irrelevant. Total lines read on startup is the real metric.

## Risk vector

CIM v2.3.1 is close to saturation. Next growth should not be more CIM layers but a second contour: **GOS (Goal Operating System)** for execution and goal tracking. Do NOT build GOS until 50-100 tasks of CIM data are accumulated.
