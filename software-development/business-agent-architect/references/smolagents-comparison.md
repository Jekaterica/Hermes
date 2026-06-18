# smolagents vs Hermes — Decision Record

## Summary

| Критерий | smolagents | Hermes Agent |
|----------|-----------|-------------|
| **Парадигма** | Агент пишет Python-код (CodeAgent) | Агент вызывает JSON tools |
| **Ядро** | ~1000 строк | Больше |
| **Hub** | push_to_hub() / from_hub() | Нет |
| **Платформы** | CLI / Gradio / HF Space | Telegram, Discord, Slack, CLI |
| **Скиллы** | Нет | SKILL.md |
| **Cron** | Нет | Есть |
| **Sandbox** | AST-executor, E2B, Docker | terminal() + execute_code() |

## Решение

- **Простые агенты** (FAQ, модерация, базовый support, до 20к ₽) → smolagents (быстрее, HF Space)
- **Сложные агенты** (CRM+email+расписания, 40-150к ₽) → Hermes (skills, cron, gateway)

Клиент разницы не видит — интерфейс (Telegram) и качество ответов одинаковы.
