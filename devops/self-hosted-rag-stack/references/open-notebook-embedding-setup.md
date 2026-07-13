# Open Notebook — Настройка embedding-модели

## Симптомы

| Симптом | Причина |
|---------|---------|
| UI: вопрос «думает» 30+ сек и сбрасывается | Embedding credential не работает → API timeout → фронтенд дропает соединение |
| UI: сообщение «Векторный поиск невозможен» | `default_embedding_model: null` |
| API: `default_embedding_model: null` | Embedding модель никогда не была настроена |
| API: `default_embedding_model: <model_id>` → RAG падает | Модель удалена, но defaults продолжает на неё ссылаться |
| API: `"Missing Authentication header"` при `has_api_key: true` | Ключ в credential повреждён (зашифрован неверно или протух) |
| `/api/search/ask/simple` → `Model with ID ... not found` | `default_embedding_model` указывает на удалённую модель |

## Причина

У DeepSeek (и многих других LLM-провайдеров) нет embedding API напрямую.
Поддерживаемые провайдеры для эмбеддингов: `openai`, `openai-compatible`, `openrouter`, `google`, `ollama`, `vertex`, `transformers`, `voyage`, `mistral`, `azure`, `jina`.

**DeepSeek не поддерживает embedding**, даже если добавить modality `embedding` к credential. 
Попытка использовать `deepseek-embedding` как модель через DeepSeek API провайдера упадёт с:
```
Provider 'deepseek' not supported for embedding. Supported providers: [...]
```

## Решение: OpenRouter как embedding-провайдер

### Диагностика перед настройкой

```bash
# 1. Какие модели эмбеддингов уже зарегистрированы?
curl -s http://localhost:5055/api/models | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m.get('type') == 'embedding':
        print(f'  ID: {m[\"id\"]}  Name: {m[\"name\"]}  Cred: {m[\"credential\"]}')"

# 2. Какая модель по умолчанию?
curl -s http://localhost:5055/api/models/defaults | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f'default_embedding_model: {d.get(\"default_embedding_model\")}')"

# 3. Есть ли рабочие credential для эмбеддингов?
curl -s http://localhost:5055/api/credentials | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    if 'embed' in str(c.get('modalities',[])):
        print(f'  {c[\"name\"]}: has_api_key={c[\"has_api_key\"]}')"
```

### Шаг 1. Создать credential

В терминале ПК:

```bash
# Создать credential (заменить api_key на свой)
curl -X POST http://localhost:8502/api/credentials \
  -H "Content-Type: application/json" \
  -d '{
    "name": "OpenRouter Embed",
    "provider": "openai_compatible",
    "base_url": "https://openrouter.ai/api/v1",
    "api_key": "sk-...",
    "modalities": ["embedding"]
  }'
# → вернёт id вида "credential:keurh6pmgifuemk5wl6r"
```

Или через UI: Settings → Credentials → Add → OpenAI Compatible → 
Name: OpenRouter Embed, Base URL: https://openrouter.ai/api/v1, 
API Key: твой ключ, Modalities: ✓ embedding → Save.

### Шаг 2. Зарегистрировать модель

```bash
# Подставить реальный credential_id из шага 1
curl -X POST "http://localhost:8502/api/credentials/<credential_id>/register-models" \
  -H "Content-Type: application/json" \
  -d '{
    "models": [{
      "id": "text-embedding-3-small",
      "name": "text-embedding-3-small",
      "provider": "openai",
      "model_type": "embedding"
    }]
  }'
# → {"created": 1, "existing": 0}
```

### Шаг 3. Назначить модель по умолчанию

**Важно:** даже если модель уже указана в defaults — после удаления/пересоздания credential нужно обновить `default_embedding_model`. Старое значение продолжает ссылаться на удалённый model_id, и RAG будет падать с `Model with ID ... not found`.

```bash
# Получить model_id новой модели
curl -s http://localhost:5055/api/models | python3 -c "
import sys, json
for m in json.load(sys.stdin):
    if m.get('type') == 'embedding':
        print(f'{m[\"name\"]:30s} → {m[\"id\"]}')
"

# Установить как модель по умолчанию
curl -X PUT "http://localhost:5055/api/models/defaults" \
  -H "Content-Type: application/json" \
  -d '{
    "default_embedding_model": "<model_id>"
  }'
# → "default_embedding_model": "model:..."
```

### Шаг 4. Проверка

```bash
curl -s http://localhost:8502/api/models/defaults | python3 -m json.tool
# → "default_embedding_model": "model:...", больше не null
```

В UI — сообщение об ошибке векторного поиска должно исчезнуть.

## Альтернатива: Ollama (локально)

Если OpenRouter недоступен:

```bash
ollama pull nomic-embed-text
# или
ollama pull all-minilm:33m
```

Затем в UI добавить Ollama как провайдера и зарегистрировать embedding-модель.
