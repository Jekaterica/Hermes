# CLIProxyAPI — Reverse Proxy для AI CLI инструментов

**Репозиторий:** router-for-me/CLIProxyAPI
**Звёзды:** 39.5k ★
**Форков:** 6.5k
**Статус:** активно поддерживается (последний коммит — часы назад)

## Назначение
Оборачивает API Antigravity, ChatGPT Codex, Claude Code, Grok Build в OpenAI/Gemini/Claude/Codex-совместимый API-сервис.

Позволяет:
- Использовать модели Gemini через OpenAI-совместимый API
- Обходить геоблокировку Antigravity
- Получать доступ к моделям через единый API-интерфейс

## Структура
- Go-приложение
- Поддерживает плагины
- Есть встроенная поддержка авторизации
- Работает на Linux

## Использование
Стандартный Go-пайплайн: clone → build → run.
Конфигурация через YAML/JSON/env variables.

## Примечание
CLIProxyAPI — не единственный reverse proxy этой категории.
При поиске альтернатив искать по `reverse proxy` + название инструмента на GitHub.
