# Open Notebook v1.10.0 — API и миграция

## API Endpoints (v1.10.0)

### Чат (основной способ работы с RAG)

```bash
# 1. Создать сессию чата для ноутбука
SESS=$(curl -s -X POST http://localhost:5055/api/chat/sessions \
  -H "Content-Type: application/json" \
  -d '{"notebook_id": "notebook:<id>"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

# 2. Отправить сообщение с RAG-контекстом
curl -s -X POST "http://localhost:5055/api/chat/execute" \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "'"$SESS"'",
    "message": "Твой вопрос к источникам",
    "context": {
      "notebook_id": "notebook:<id>"
    }
  }'
```

**Важно:** `notebook_id` в `context` обязателен для RAG-поиска. Без него чат отвечает из знаний модели, не из источников.

### Build context (проверка, какие источники подтягиваются)

```bash
curl -s -X POST http://localhost:5055/api/chat/context \
  -H "Content-Type: application/json" \
  -d '{
    "notebook_id": "notebook:<id>",
    "context_config": {
      "messages": [{"role": "user", "content": "test"}],
      "model_id": "model:<id>",
      "notebook_id": "notebook:<id>"
    }
  }'
```

Ответ:
```json
{
  "context": {
    "sources": [...],  // найденные источники с контентом
    "notes": [...]
  },
  "token_count": 1234,
  "char_count": 5678
}
```

Если `sources: []` — источники не привязаны к ноутбуку.

### Search / Ask (прямой вопрос к поиску)

```bash
curl -s -X POST http://localhost:5055/api/search/ask/simple \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Что такое Git?",
    "strategy_model": "model:<id>",
    "answer_model": "model:<id>",
    "final_answer_model": "model:<id>"
  }'
```

**Требует 3 model_id** (стратегия поиска, генерация ответов, финальный ответ). Можно использовать одну модель для всех трёх полей.

### Источники (Sources)

| Endpoint | Метод | Назначение |
|----------|-------|------------|
| `/api/sources` | GET | Список всех источников |
| `/api/sources` | POST | Загрузить новый источник (multipart) |
| `/api/sources/{id}` | GET | Детали источника |
| `/api/sources/{id}` | DELETE | Удалить источник |
| `/api/sources/{id}/retry` | POST | Повторить обработку (если failed) |
| `/api/sources/{id}/status` | GET | Статус обработки |

### Ноутбуки (Notebooks)

| Endpoint | Метод | Назначение |
|----------|-------|------------|
| `/api/notebooks` | GET | Список ноутбуков |
| `/api/notebooks` | POST | Создать ноутбук |
| `/api/notebooks/{id}` | GET | Детали ноутбука |
| `/api/notebooks/{id}` | PUT | Обновить ноутбук (+ привязать источники через `source_ids`) |
| `/api/notebooks/{id}/sources/{source_id}` | POST | Добавить источник в ноутбук |
| `/api/notebooks/{id}/sources/{source_id}` | DELETE | Удалить источник из ноутбука |

**Привязка источников:** POST `/api/notebooks/{id}/sources/{source_id}` возвращает 200, но может НЕ сохранить привязку. Надёжнее — PUT `/api/notebooks/{id}` с полем `source_ids: [...]`.

### Credentials

| Endpoint | Метод | Назначение |
|----------|-------|------------|
| `/api/credentials` | GET | Список credentials |
| `/api/credentials` | POST | Создать credential |
| `/api/credentials/{id}` | GET | Детали credential |
| `/api/credentials/{id}` | PUT | Обновить credential |
| `/api/credentials/{id}` | DELETE | Удалить credential |
| `/api/credentials/{id}/register-models` | POST | Зарегистрировать модели для credential |

## Изменения v1.9.0 → v1.10.0

### Удалено
- `/api/chat` (simple chat POST) — **удалён**, возвращает 404
- `/api/chat/sessions/{session_id}/messages` (top-level) — **удалён**, существует только для source-scoped сессий

### Добавлено
- `/api/chat/execute` — отправка сообщения в существующую сессию
- `/api/chat/context` — построение контекста из источников (без отправки в LLM)
- `/api/search/ask` — теперь требует 3 model_id вместо одного

### Изменилось
- Chat session теперь требует `notebook_id` при создании
- Для RAG-ответа нужно передавать `notebook_id` в `context` при execute

## Диагностика: проверка RAG

```bash
# 1. Есть ли embedding модель?
curl -s http://localhost:5055/api/models | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m.get('type') == 'embedding':
        print(f'Embedding: {m[\"name\"]} (credential: {m.get(\"credential\",\"?\")})')
"

# 2. Работает ли embedding?
curl -s -X POST http://localhost:5055/api/search/ask/simple \
  -H "Content-Type: application/json" \
  -d '{
    "question": "test",
    "strategy_model": "model:<lang_model_id>",
    "answer_model": "model:<lang_model_id>",
    "final_answer_model": "model:<lang_model_id>"
  }' | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('detail','OK')[:200])"

# 3. Проверить credential на has_api_key
curl -s http://localhost:5055/api/credentials | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    print(f'{c[\"name\"]}: has_api_key={c[\"has_api_key\"]}, decryption_error={c.get(\"decryption_error\")}')
"
```

## Типовые ошибки

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `"detail":"Not Found"` на `/api/chat` | Эндпоинт удалён в v1.10.0 | Использовать `/api/chat/execute` |
| `sources: []` в контексте | Источники не привязаны к ноутбуку | PUT `/api/notebooks/{id}` с `source_ids` |
| `"Missing Authentication header"` | API-ключ не передан или повреждён | Проверить credential → удалить и создать заново |
| `Ask operation failed: Failed to generate embeddings` | Embedding credential не настроен или ключ невалидный | Проверить `has_api_key` и `decryption_error` в credential |
