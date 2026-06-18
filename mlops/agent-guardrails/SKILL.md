---
name: agent-guardrails
description: Input/output guardrails for AI agents — topic control, PII filtering, content safety, business rules enforcement. Prevents hallucination and off-topic responses.
---

# Agent Guardrails

Input/output guardrails based on production patterns from GenAI_Agents. Three layers of protection:

1. **Input Guard** — validate user input before it reaches the LLM
2. **Output Guard** — verify LLM response before delivering to user
3. **Business Guard** — enforce domain-specific rules and compliance

## When to Use
- User input may contain PII, toxic content, or off-topic queries
- Agent must stay within a defined business domain
- Compliance requirements (regulatory, legal, brand safety)
- Before and after any LLM call in a business agent pipeline

## Guardrail Layers

### Layer 1: Input Guard

```python
INPUT_GUARD_PROMPT = """Analyze the user input and return a JSON decision:
{
    "allowed": true/false,
    "risk_level": "safe" | "low" | "medium" | "high",
    "reason": "why it was blocked or allowed",
    "contains_pii": true/false,
    "topic_compliant": true/false,
    "action": "allow" | "block" | "flag"
}

Rules:
- Block toxic, offensive, or harmful content
- Block off-topic queries outside the agent's domain
- Flag PII (emails, phones, addresses) — do not block, but log
- Allow safe, on-topic queries
- For uncertain cases, set risk_level to "low" and action to "flag"
"""
```

### Layer 2: Output Guard

```python
OUTPUT_GUARD_PROMPT = """Review the agent's response before delivery:
{
    "allowed": true/false,
    "issues": ["list of problems found"],
    "hallucination_risk": "low" | "medium" | "high",
    "contains_disclaimer": true/false,
    "action": "allow" | "block" | "rewrite"
}

Check for:
- Factual claims not supported by provided context
- Hallucinated citations or references
- Sensitive information disclosure
- Appropriate tone and professionalism
- Brand voice compliance
"""
```

### Layer 3: Business Domain Guard

Define allowed/blocked topics for each agent. Example for a support agent:

```python
DOMAIN_RULES = {
    "allowed_topics": [
        "product_questions",
        "account_issues",
        "billing_inquiries",
        "technical_support",
        "feature_requests"
    ],
    "blocked_topics": [
        "competitor_pricing",
        "internal_policies",
        "legal_advice",
        "medical_advice",
        "investment_advice"
    ],
    "escalation_triggers": [
        "security_incident",
        "data_breach",
        "legal_threat",
        "account_compromise"
    ]
}
```

## Integration Pattern

```
User Input → Input Guard → [ALLOW] → LLM Call → Output Guard → [ALLOW] → User
                  ↓ BLOCK                   ↓ BLOCK
              "Sorry, I can't..."       "Let me rephrase..."
```

## Six Rules Against Hallucination (RAG)

1. **Retrieve first, answer second** — always search knowledge base before generating
2. **Preserve document structure** — don't break semantic chunks
3. **Use document embeddings** — preserve meaning and structure in chunks
4. **Verify relevance** — check that retrieved chunks actually match the query
5. **Configure semantic search** — tune similarity thresholds per domain
6. **Add agent memory** — RAG + memory = "second brain"

## References

- `references/guardrails-integration.md` — как интегрировать guardrails в бизнес-агента: уровни включения, практическая реализация (правила в system prompt vs отдельный LLM-вызов), триггеры эскалации.
