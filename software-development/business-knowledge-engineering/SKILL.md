---
name: business-knowledge-engineering
description: "Collect, structure and validate domain knowledge for a business AI agent: what data to gather, what to skip, what is often missed, and how to organize it for maximum agent performance."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [knowledge-engineering, data-collection, business-agents, RAG, domain-design]
    related_skills: [agent-architecture-audit]
---

# Business Knowledge Engineering

## Overview

The single biggest time investment in building a domain-specific agent is collecting and structuring knowledge about the business. This skill covers what to gather, what to skip, and how to organize it so the agent actually uses it.

**Core principle:** An agent is only as good as its knowledge base — but a bloated knowledge base with wrong priorities is worse than none at all.

## When to Use

Use when:
- Building a new business agent from scratch
- Auditing an existing agent's knowledge quality
- A client says "I have everything in Google Docs / Notion"
- The user asks how to prepare data for an agent

## Recommended Directory Structure

```
📁 knowledge_base/
├── 01_products/            # Товары и услуги
│   ├── catalog.md
│   └── prices.md
├── 02_processes/           # Как работаем
│   ├── ordering.md
│   ├── returns.md
│   └── delivery.md
├── 03_communication/       # Как общаемся   ← MOSTLY OVERLOOKED
│   ├── tone_of_voice.md    # Стиль общения (см. ниже)
│   ├── faq.md              # Типовые вопросы
│   ├── escalation.md       # Когда звать человека ← CRITICAL
│   └── boundaries.md       # Что агент НЕ делает
├── 04_examples/            # Примеры
│   ├── good_dialogs.md     # Хорошие ответы
│   └── bad_dialogs.md      # Плохие ответы  ← OVERLOOKED
└── 05_company/             # О компании
    └── contacts_hours.md
```

## What to Collect (Priority Order)

### Tier 1 — Must Have (agent cannot function without)

1. **Product/service descriptions** — what you sell, in plain language
2. **Pricing** — list prices, discounts, promo conditions
3. **Core processes** — how orders, returns, support work step by step
4. **FAQ** — the 20 questions customers actually ask, with real answers

### Tier 2 — Often Missed but Critical

5. **Tone of voice** — how the agent should sound:
   - На «ты» или «вы»?
   - С эмодзи или без?
   - Формально или дружелюбно?
   - Коротко или развёрнуто?
   - Как реагировать на злость, шутки, непонимание?

6. **Escalation rules** — when to call a human:
   - "Клиент угрожает судом → передать руководителю"
   - "Сумма возврата > 5000₽ → запросить одобрение"
   - "Техническая проблема вне FAQ → передать специалисту"
   - Without this, the agent either escalates everything or escalates nothing.

7. **Agent boundaries** — what the agent must NOT do:
   - "Я НЕ могу изменить адрес после отправки"
   - "Я НЕ могу отменить оплаченный заказ"
   - "Я НЕ могу давать юридические консультации"
   - Every missing boundary is a future customer complaint.

8. **Bad examples** — real responses the agent should avoid:
   - *"К сожалению, я не могу решить вашу проблему, обратитесь в поддержку"* (dead end)
   - *"Я передал ваш вопрос специалисту. Обычно ответ занимает до 2 часов"* (good handoff)
   - Show the agent what NOT to do as clearly as what to do.

### Tier 3 — Optional (phase 2+)

9. **Competitor comparisons** — only if sales involves comparison
10. **Customer personas** — only if personalization matters
11. **Historical conversations** — for fine-tuning tone (not for RAG)
12. **Policy documents** — only if the agent needs them for decisions

## What to Skip at Phase 1

| Item | Why skip |
|------|---------|
| Full SQL database connection | Hermes does not natively connect to SQL. Needs custom tool. Phase 2. |
| CRM API integration | Requires auth, rate limits, error handling. Phase 2. |
| Fine-tuning / training data | Hermes works with RAG + skills, not model training. |
| Raw chat logs as knowledge base | Unstructured, contradictory, full of noise. Extract examples instead. |
| "All our documentation" | If you can't answer "what 3 things does the agent NEED to know?", the docs aren't ready. |

## Knowledge Quality Checks

Before loading into the agent, test each file:

- [ ] Can someone who knows nothing about the business understand this?
- [ ] Does it contain actual answers, not "see internal doc X"?
- [ ] Are there concrete examples, not abstract principles?
- [ ] Would two people reading it give the same answer to the same question?
- [ ] Is there anything the agent might misinterpret?

## For Crisis / Survival Agents (CSIA Pattern)

Financial survival agents need additional knowledge tiers:

- **Laws and regulations** — concrete articles, not descriptions. "Ст. 12 353-ФЗ: макс ставка МФО 0.8%/день"
- **Realistic income channels** — not "start a business", but "Авито Услуги, YouDo, стройка, склады"
- **Debt strategy** — what to pay, what to stop paying, when to bankrupt
- **Risk patterns** — common scams, MLM structures, predatory offers
- **Local platforms** — region-specific job sites, social services, legal resources

This tier requires domain expertise. If the agent author lacks it, the skill should say "consult a [domain expert]" rather than filling from general knowledge.

## Source Material Priorities

Rank business data sources by usefulness:

1. **Notion / Confluence** — structured, maintained, searchable ← best
2. **Google Docs** — good if organized, bad if scattered
3. **CSV/Excel** — excellent for pricing, inventory, schedules
4. **PDF manuals / instructions** — good if text-extractable, bad if scanned
5. **Word documents** — medium (often outdated)
6. **Slack/Telegram archives** — useful for tone, dangerous for facts
7. **Email threads** — worst (noise + contradictions)

## Common Mistakes

### "Just dump everything into RAG"
Agent needs structured knowledge, not a firehose. 10 well-written pages >> 1000 pages of raw docs.

### "The agent will learn from conversations"
No. Not without a feedback loop. The agent needs explicit boundary files to know what it can and cannot handle.

### "We'll add escalation later"
Later never comes. Add it before the agent talks to a real customer. One wrong promise about a refund you don't offer = lost trust.

### "Our FAQ covers everything"
FAQ covers questions people already asked. The agent needs processes, boundaries, and tone on top of FAQ.

## User-Specific Preferences (this user)

For Russian-language business agents (this user's domain):
- Avoid English-language business models that don't apply in Russia
- Prefer local platforms (Авито, hh.ru, YouDo, Профи.ру, Госуслуги)
- Tone: cold analytics, professional, no motivational fluff
- Reminders: only if explicitly requested — no default scheduling
- Agent architecture: state-machine based, not flat chatbot
