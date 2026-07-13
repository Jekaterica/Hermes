# GenAI_Agents Patterns — Evaluation & Guardrails

**Repo:** NirDiamant/GenAI_Agents — `/home/oleg/GenAI_Agents/`

## Eval Patterns (06_evaluation)

- **LLM-as-Judge (G-Eval):** Score on correctness, procedure_following, conciseness
- **Self-critique loop:** Agent evaluates own output → retry if composite < 0.8 (max 3 retries)
- **Regression testing:** Before/after metrics per skill change
- **Contextual precision/recall:** For RAG eval

## Guardrail Patterns (05_guardrails)

- **Input guard:** Regex + LLM-based vetting before LLM call
- **Output guard:** Verify response before delivery
- **Business domain guard:** Allowed/blocked topics per agent

## Integration with Hermes

Implemented as skills:
- `agent-evaluation-framework` (mlops) — LLM-as-Judge + self-critique + regression
- `agent-guardrails` (mlops) — input/output/business guard layers
