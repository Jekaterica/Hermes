---
name: ai-tool-geo-access
description: "Доступ к AI-инструментам разработки (IDE, CLI-агенты, API-сервисы) из регионов с геоблокировками. Методология поиска обходных решений, reverse proxy, кастомные провайдеры."
tags: [geo-bypass, reverse-proxy, ai-ide, antigravity, claude-code, custom-provider, openai-compatible, patch-safety]
---

# AI Tool Geo Access

Методология получения доступа к AI-инструментам разработки, заблокированным по географическому признаку (Россия, Крым и др.).

## Принцип

Большинство AI-инструментов (IDE, CLI-агенты) используют:
- **Аутентификацию** через Google/Firebase/GitHub OAuth — проверяет IP при регистрации
- **API-запросы** к LLM — можно перенаправить через reverse proxy или сменить провайдера
- **Бинарный код** — Electron-приложения, которые можно проанализировать

## Методология поиска решений

### Шаг 1. Определить тип блокировки
- Регистрационная блокировка (IP при signup) → **VPN при регистрации**
- Периодическая geo-проверка (GetUserStatus) → **reverse proxy** или **патч бинарника**
- Блокировка API-endpoint → **reverse proxy** или **кастомный провайдер**

### Шаг 2. Поиск готовых решений
1. GitHub: искать по `reverse proxy` + название инструмента
2. GitHub: искать по `bypass` + `patch` + название инструмента
3. GitHub Topics: зайти на страницу тега (github.com/topics/название)
4. Китайский сегмент GitHub: там чаще всего появляются патчи
5. Issues репозиториев: поиск по `geolocation`, `Russia`, `blocked`
6. Проверить README на русском языке — признак, что автор из РФ и решает ту же проблему

### Шаг 3. Проверка найденного решения на безопасность
**См. `references/open-source-patch-safety.md`** — подробная методология.

Кратко:
1. Клонировать репозиторий (`git clone --depth 1`)
2. Прочитать `main.py` / точку входа — нет ли подозрительных внешних запросов
3. Проверить `requirements.txt` — только легитимные зависимости
4. Изучить ключевые модули патча — что именно меняется
5. Убедиться, что есть бэкап и откат
6. Проверить, нет ли вшитых ключей/сертификатов, уходящих на внешние серверы

## Обход для конкретных инструментов

### Google Antigravity IDE
- **Патчер:** **AvenCores/open-antigravity-patcher** (466★, активный, v1.2.0, русскоязычный автор)
- **Что делает:** патчит `main.js` (IDE), `app.asar` (standalone), Go-бинарь `agy` (CLI)
- **Поддержка Linux:** да, автопоиск в `/usr/share/antigravity-ide`, `/opt/Antigravity IDE`
- **Кастомные API провайдеры:** **НЕ ПОДДЕРЖИВАЕТ.** Google Antigravity имеет фиксированный список моделей Google. Нет "Add Custom Model".
- **Antigravity Manager** (lbjlaq, 30k★) — это сторонний reverse proxy, а не функция IDE. Тоже не поддерживает свои API-ключи (open feature request #1520).
- **Подробнее:** `references/antigravity-research.md`

### Claude Code (Anthropic)
- **Кастомные провайдеры:** **ОФИЦИАЛЬНО ПОДДЕРЖИВАЮТСЯ.** Terminal CLI и VS Code поддерживают third-party providers.
- **Механизм:** переменные окружения `ANTHROPIC_BASE_URL` + `ANTHROPIC_AUTH_TOKEN` в `~/.claude/settings.json`
- **Готовый инструмент:** **yiqiliu2/SwitchClaude** — bash-скрипт для переключения между Anthropic OAuth и кастомным провайдером
- **Важно:** Claude Code использует **Anthropic Messages API** (`/v1/messages`), а DeepSeek — **OpenAI Chat API** (`/v1/chat/completions`). Форматы разные. Нужен прокси-конвертер (LiteLLM или самописный).
- **Геоблокировка Anthropic:** не имеет значения при использовании кастомного провайдера (OAuth не используется)
- **Linux:** да, `npm i -g @anthropic-ai/claude-code`
- **Подробнее:** `references/claude-code-research.md`

### Другие инструменты (из коробки с DeepSeek)
- **Codex CLI** (OpenAI) — поддерживает OpenAI-совместимые API
- **OpenClaw** — форк с кастомными провайдерами
- **Continue.dev** (VS Code) — полная поддержка
- **Aider** — полная поддержка
- **Hermes** — полная поддержка

## Reverse Proxy (CLIProxyAPI-паттерн)

Основной подход для обхода геоблокировки на уровне API:
- Запускается сервер-прокси, который оборачивает API заблокированного инструмента
- Клиент подключается к прокси вместо прямого API
- Прокси ретранслирует запросы, подменяя гео-данные

**Известные реализации:**
- **CLIProxyAPI** (router-for-me/CLIProxyAPI, 39.5k★) — универсальный reverse proxy для AI CLI инструментов

## Кастомные провайдеры LLM

### Формат API
Большинство AI-инструментов поддерживают один из двух форматов:

| Формат | Эндпоинт | Инструменты |
|--------|----------|-------------|
| **OpenAI Chat API** | `/v1/chat/completions` | Codex CLI, OpenClaw, Continue, Aider, Hermes |
| **Anthropic Messages API** | `/v1/messages` | Claude Code |

**DeepSeek** использует OpenAI-формат. Для Claude Code нужен прокси-конвертер.

### Где искать конфиг
- `~/.<tool-name>/settings.json`
- `~/.config/<tool-name>/User/settings.json`
- `~/.claude/settings.json`
- Внутри GUI инструмента: Settings → Providers → Add Custom

## Linux-совместимость

Большинство AI-инструментов разработки имеют официальные Linux-бинарники:
- **Antigravity**: x86_64 + ARM64 (Linux)
- **Claude Code**: npm-пакет (Linux/macOS)
- **Codex CLI**: Go-бинарник (Linux/macOS)

Для ARM64/Linux (Android через Termux): используйте proot-distro + Debian + X11.

## Pitfalls

- **GitHub API rate limits** при массовом поиске — используйте авторизованные запросы
- **Геоблокировка может меняться** — решение, работавшее месяц назад, может перестать работать
- **Reverse proxy добавляет задержку** — выбирайте прокси-сервер географически близко
- **Патчи бинарников** нестабильны — каждое обновление инструмента ломает патч. Патчеры с бэкапом и откатом — предпочтительны.
- **Firebase-блокировка** может проверять не только IP, но и регион Google-аккаунта
- **DeepSeek V4 Flash** — модель называется `deepseek-chat` в OpenAI-совместимом API
- **Не путать** Google Antigravity IDE (оригинал) с Antigravity Manager (сторонний reverse proxy) — разные вещи
- **Проверка формата API критична** — Anthropic Messages API не совместим с OpenAI Chat API напрямую, нужен конвертер
- **Открытый feature request #1520** в Antigravity Manager — кастомные API ключи пока не реализованы

## References

- `references/antigravity-research.md` — исследование Google Antigravity: геоблокировка, обход, невозможность кастомного API
- `references/claude-code-research.md` — исследование Claude Code: third-party providers, SwitchClaude, проблема формата API
- `references/cli-proxy-api.md` — CLIProxyAPI: reverse proxy для AI CLI инструментов
- `references/open-source-patch-safety.md` — методология проверки open-source патчей на безопасность

## Templates

- `templates/custom-provider.json` — шаблон конфигурации кастомного провайдера (OpenAI-совместимый)
