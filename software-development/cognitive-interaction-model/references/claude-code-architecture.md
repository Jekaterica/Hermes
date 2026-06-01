# Claude Code Architecture — Key Patterns (from reverse engineering)

Source: github.com/alejandrobalderas/claude-code-from-source (18 chapters)
arXiv: 2604.14228 (13 design principles + 5 human values)
Official docs: code.claude.com/docs

## Patterns that inspired CIM layers

| CIM Layer | Claude Code Source |
|-----------|-------------------|
| Confidence System | Permission chain (7 modes, deny-first) + tool classification |
| Decision Journal | Cost tracking (reservoir sampling) + KAIROS logs |
| Prediction Log | Token budgeting (8K default → 64K escalation) |
| Conditional Patterns | Context-dependent tool safety (isConcurrencySafe(input)) |
| Cognitive Bias Monitor | 13 design principles (transparency, debuggability) |
| Anti-Dogma Registry | Sticky latches (prevent mid-session cache drift) |
| Layer Usefulness Rule | Feature flags with dead code elimination at build |

## Patterns NOT applicable without Anthropic infrastructure

- Prompt caching (ephemeral, 1h, global — requires Anthropic API)
- Fork agents (byte-identical prefix — requires cache)
- Sticky latches (cache key protection — requires cache)
- Dynamic boundary (static/dynamic system prompt split — requires cache)
- Speculative tool execution (SSE streaming — requires client-side streaming)

## Key architectural insight

Claude Code's architecture prioritizes simplicity over multi-agent complexity:
"single-threaded while-loop with tool calls" > "fancy multi-agent swarms"
This philosophy directly influenced CIM's design: 10 simple layers > 50 micro-rules.
