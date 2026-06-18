# Open Notebook API Reference

## Setup
- **Docker Compose:** `/home/oleg/open-notebook/docker-compose.yml`
- **Порты:** API=5055, UI=8502, SurrealDB=8002
- **Ключ шифрования:** сгенерирован, задан в docker-compose.yml
- **Креденциал для OpenRouter:** создан (id=`credential:miw9v46w16ny53opokqk`), base_url=https://openrouter.ai/api/v1. API-ключ задать через UI (http://localhost:8502)

## API Endpoints (использованные в сессии)

### Ноутбуки

```bash
# Создать ноутбук (базу знаний)
curl -X POST http://localhost:5055/api/notebooks \
  -H "Content-Type: application/json" \
  -d '{"name": "Sales Scripts", "description": "..."}'
# → {"id": "notebook:7wiiia3mtgh7d1pf4bxm", ...}

# Список ноутбуков
curl http://localhost:5055/api/notebooks
```

### Источники (документы)

```bash
# Загрузить текст как источник
curl -X POST http://localhost:5055/api/sources \
  -F "type=text" \
  -F "notebook_id=notebook:XXX" \
  -F "title=My Document" \
  -F "content=$(cat file.md)"

# Проверить статус обработки
curl http://localhost:5055/api/sources/{source_id}/status
# → {"status": "completed", "embedded_chunks": 42, ...}
```

**ВАЖНО:** content передаётся как form-data поле, не как файл. Если передать как файл, API вернёт `"Input should be a valid string"`.

### Поиск

```bash
# Векторный поиск по ноутбуку (нужна настроенная embedding-модель)
curl -X POST http://localhost:5055/api/search \
  -H "Content-Type: application/json" \
  -d '{"query": "SPIN вопросы", "notebook_id": "notebook:XXX", "limit": 5}'
# → {"results": [...chunks...], "total_count": N}
```

### Вопрос с RAG-контекстом

```bash
curl -X POST http://localhost:5055/api/search/ask \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Как квалифицировать лида?",
    "strategy_model": "deepseek/deepseek-v4-flash",
    "answer_model": "deepseek/deepseek-v4-flash",
    "final_answer_model": "deepseek/deepseek-v4-flash",
    "notebook_id": "notebook:XXX"
  }'
```

**Требует:** question + все три model-поля. Без них → 422.

### Модели и креденциалы

```bash
# Создать креденциал для OpenAI-совместимого провайдера (OpenRouter)
curl -X POST http://localhost:5055/api/credentials \
  -H "Content-Type: application/json" \
  -d '{"provider": "openai_compatible", "name": "OpenRouter", "config": {"base_url": "https://openrouter.ai/api/v1"}}'

# Обновить (поля напрямую, не nested)
curl -X PUT http://localhost:5055/api/credentials/{id} \
  -H "Content-Type: application/json" \
  -d '{"base_url": "https://openrouter.ai/api/v1", "api_key": "sk-..."}'

# Список провайдеров
curl http://localhost:5055/api/models/providers
# → {"available": ["openai"], "unavailable": ["anthropic",...,"openrouter"]}
```

## Питфоллы

1. **Без API-ключа embedding не работают.** `embedded_chunks: 0` даже после успешной обработки источника.
2. **content в multipart — строка, не файл.** Используй `-F "content=$(cat file)"`, не `-F "content=@file"`.
3. **Путь к OpenRouter:** `openai_compatible` провайдер, base_url=https://openrouter.ai/api/v1, модель указывать как `deepseek/deepseek-v4-flash`.
4. **Порты:** surrealdb на 8002 (8000 занят другим процессом на этой VPS).
