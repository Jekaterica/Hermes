# Crisis Knowledge Base Example — CSIA Agent

A worked example of the business-knowledge-engineering methodology applied to a financial crisis survival agent. This shows the difference between "book titles" and "usable knowledge."

## Before: Typical "List of Books" Approach (Waste of Tokens)

```markdown
## Sources
- "The Psychology of Money" — Morgan Housel
- "Your Money or Your Life" — Vicki Robin
- "Scarcity" — Mullainathan & Shafir
- "The Total Money Makeover" — Dave Ramsey
- "Antifragile" — Taleb
```

**Why this fails:** The LLM already knows these books exist. Listing titles adds zero useful signal. The agent either remembers the content (from training) or doesn't. A bare bibliography doesn't help.

## After: Extracted Concepts with Practical Application

### ПСИХОЛОГИЯ ДЕФИЦИТА (Mullainathan & Shafir)

**Главное:** Бедность — это когнитивный дефицит. Когда ресурсов не хватает, IQ падает на 13-15 пунктов.

**Применение в агенте:**
- Чем тяжелее ситуация, тем проще решения (макс 1-3 пункта)
- Не говорить "возьми себя в руки" — человек не может, его мозг занят выживанием
- Создавать "слоты" для стратегических решений, освобождать когнитивную нагрузку

### ВЫХОД ИЗ ДОЛГОВ (Ramsey + практика РФ)

**Snowball:** платить от малого к большому (психология: быстрые победы)
**Avalanche:** платить от высокой ставки к низкой (математика: экономит больше)

**Применение для РФ:**
1. Микрозаймы (365%+) — прекратить платить, не гасятся
2. Кредитки (30%+) — закрыть или рефинансировать
3. Потребкредиты (15-25%) — платить по графику
4. Ипотека (<15%) — не трогать

## What Makes Knowledge "Usable"

| Property | Before (bad) | After (good) |
|----------|-------------|--------------|
| Format | Book title + author | Extracted concept + application rule |
| Actionability | "Read this book" | "If X → do Y because Z" |
| Specificity | "General principles" | Concrete numbers: 13-15 IQ, 365% rate, 0.8%/day |
| Localization | "Generic finance" | Russia-specific: МФО limits, ФССП, 353-ФЗ, самозанятость |
| Risk awareness | "Good advice" | Explicit forbidden items + why they're dangerous |

## Template: Knowledge Entry Format

For each concept in a knowledge base, fill:

```markdown
### [Concept Name] ([Source])

**Суть:** (1-2 предложения, суть)

**Цифры / факты:** (конкретные числа, статьи законов)

**Применение в ответах:**
- Если [ситуация A] → [рекомендация]
- Если [ситуация B] → [другая рекомендация]
- Ошибка: [что НЕ надо говорить]

**Для РФ:** (локальные особенности, если есть)

**Кейс:** (реальный пример из практики, 3-5 предложений)
```

## Template: Crisis Knowledge Architecture

For financial crisis agents, include these knowledge tiers:

1. **Психология дефицита** — как работает мозг без денег
2. **Когнитивные ловушки** — таблица искажений с контрмерами
3. **Стратегии выхода из долгов** — snowball/avalanche + РФ-адаптация
4. **Российские реалии** — МРОТ, прожиточный минимум, ставки МФО, лимиты банкротства
5. **Что НЕ работает в РФ** — крипта, сетевой, инфобизнес (с причинами)
6. **Реальные кейсы** — 3-5 short stories with specific numbers and outcomes
7. **Финансовые правила** — 50/30/20, 3-6 months buffer, 30% housing rule
