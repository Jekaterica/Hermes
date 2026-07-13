# Claude Code — Исследование, июль 2026

## Что это
CLI-агент для разработки от Anthropic. Аналог Codex CLI, Antigravity, Cursor.
137k★ на GitHub: github.com/anthropics/claude-code
Установка: `npm install -g @anthropic-ai/claude-code`

## Геоблокировка для РФ
- Официально Claude Code использует **OAuth** через `api.anthropic.com`
- Anthropic может блокировать регион при OAuth-логине
- **НО:** при использовании кастомного провайдера OAuth Anthropic не используется — блокировка не имеет значения

## Кастомный API провайдер (DeepSeek V4 Flash)

### ✅ Официально поддерживается
Из документации Anthropic: **"The Terminal CLI and VS Code also support third-party providers."**

### Механизм подключения
Переменные окружения в `~/.claude/settings.json`:

```json
{
  "ANTHROPIC_BASE_URL": "https://твой-эндпоинт/v1",
  "ANTHROPIC_AUTH_TOKEN": "sk-..."
}
```

### Готовый инструмент для переключения
**yiqiliu2/SwitchClaude** — bash-скрипт:
- Переключает между Anthropic OAuth и кастомным провайдером
- Бэкапит OAuth-креды
- Поддерживает несколько профилей провайдеров
- Linux/macOS/Windows (Git Bash/WSL)
- `./claude-provider-switch.sh` — один переключатель

### ⚠️ Проблема: формат API

DeepSeek использует **OpenAI Chat API** (`/v1/chat/completions`).
Claude Code ожидает **Anthropic Messages API** (`/v1/messages`).

Форматы НЕСОВМЕСТИМЫ напрямую:

| | Anthropic API | OpenAI API (DeepSeek) |
|---|---|---|
| Эндпоинт | `/v1/messages` | `/v1/chat/completions` |
| Структура запроса | `{model, messages[], max_tokens, system}` | `{model, messages[], max_tokens}` |
| messages | `{role: "user"/"assistant", content: string\|array}` | `{role: "user"/"assistant"/"system", content: string}` |
| Структура ответа | `content: [{type: "text", text: "..."}]` | `choices: [{message: {role, content}}]` |

### Решение: прокси-конвертор
Нужен промежуточный сервис, переводящий Anthropic → OpenAI формат:

**Варианты:**
1. **LiteLLM** — самый популярный, поддерживает ~100 моделей, может проксировать Anthropic → OpenAI
2. **simple-anthropic-to-openai-proxy** — лёгкий самописный конвертер
3. **Написать свой** — FastAPI за пару часов (конвертация формата запроса/ответа)

**Логика конвертера:** принять запрос в Anthropic Messages API → перевести в OpenAI Chat API → отправить в DeepSeek → перевести ответ обратно в Anthropic формат.

### Linux
✅ Полная поддержка. Установка через npm.

### Итог
- Кастомный провайдер: **✅ официально поддерживается**
- DeepSeek V4 Flash: **🟡 нужно через прокси-конвертер** (LiteLLM или самописный)
- Геоблокировка: **✅ не актуальна при кастомном провайдере**
- Linux: **✅**
