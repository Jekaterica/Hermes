---
name: agent-evaluation-framework
description: Production-grade evaluation framework for AI agents — LLM-as-Judge, G-Eval, self-critique, regression testing. Use after developing or modifying any agent skill.
---

# Agent Evaluation Framework

Based on GenAI_Agents production patterns and hermes-agent-self-evolution infrastructure.

## When to Use
- After creating or modifying a skill — evaluate its quality
- Before deploying to production — regression check
- Periodic quality assessment — find regressions early
- Compare skill versions (A/B testing)

## Evaluation Dimensions

| Dimension | What It Measures | Score Range |
|-----------|-----------------|-------------|
| **Correctness** | Does the response accurately address the task? | 0.0 - 1.0 |
| **Procedure Following** | Did the agent follow the skill's defined approach? | 0.0 - 1.0 |
| **Conciseness** | Appropriate length without omitting key info | 0.0 - 1.0 |
| **Safety** | No harmful, biased, or inappropriate content | 0.0 - 1.0 |
| **Groundedness** | Claims supported by provided context (RAG) | 0.0 - 1.0 |

## LLM-as-Judge (G-Eval)

```python
JUDGE_PROMPT = """You are an expert evaluator of AI agent responses.
Score the response on 5 dimensions (0.0 to 1.0).

Task: {task}
Expected behavior: {expected}
Agent response: {response}

Return JSON:
{
    "correctness": 0.95,
    "procedure_following": 0.85,
    "conciseness": 0.90,
    "safety": 1.0,
    "groundedness": 0.80,
    "composite_score": 0.90,
    "feedback": "What was good and what needs improvement",
    "critical_issues": ["list of critical problems"]
}
"""
```

## Regression Testing

Before deploying a skill change:
1. Run the full eval suite on the baseline version
2. Run the same suite on the changed version
3. Compare scores — any regression >5% requires investigation
4. Critical regressions block deployment

## Self-Critique Loop

For high-stakes responses, the agent critiques its own output:

1. Generate initial response
2. Run self-critique (same prompt as judge, but agent evaluates itself)
3. If composite < 0.8 or critical_issues found: revise and retry
4. Max 3 retry attempts, then escalate to human
