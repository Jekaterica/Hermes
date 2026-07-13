---
name: self-hosted-rag-stack
description: "Deploy and maintain self-hosted RAG stacks: Open WebUI (+ RAG), Obsidian integration, and bridge to Hermes for AI-augmented learning. Covers sanctioned-region workarounds (registry mirrors, HF mirrors)."
version: 1.3.0
author: Hermes Agent
tags: [rag, open-webui, obsidian, docker, sanctions, hf-mirror, self-hosted, tailscale, vpn, nat, maintenance, update]
---

# Self-Hosted RAG Stack

Deploy a NotebookLM-like learning environment: **Open Notebook** or **Open WebUI** for RAG (PDF chat, notes, study programs) + Obsidian for personal notes/knowledge graph + Hermes (Telegram) as bridge.

## Architecture

```
User (Telegram/Phone)  →  Hermes (VPS)  →  Open WebUI (Docker, port 3000)
                     ↕                     Obsidian (Flatpak on same host)
```

- **Open Notebook** (рекомендуется, порт 8502) — RAG-чат по PDF, заметки, подкасты. Self-hosted аналог NotebookLM. Имеет встроенную систему credentials (SurrealDB).
- **Open WebUI** (альтернатива, порт 3000) — RAG-чат по PDF/YouTube, экзамены, программы обучения.
- **Obsidian** — Личные конспекты, карта знаний, связи между концепциями.
- **Hermes (Telegram)** — Быстрые запросы, загрузка PDF, мост между пользователем и стеком.

> **Выбор RAG-приложения:** Open Notebook лучше для глубокой работы с источниками (ноутбуки, заметки, подкасты). Open WebUI лучше для обучения с экзаменами и тестами.

## 1. Open WebUI — Deployment

### Docker Compose

```yaml
# /home/oleg/open-webui/docker-compose.yaml
services:
  open-webui:
    image: openwebui/open-webui:latest-slim   # см. Питфоллы про теги и slim
    container_name: open-webui
    restart: unless-stopped
    ports:
      - "3000:8080"
    volumes:
      - open-webui:/app/backend/data
    environment:
      - HF_ENDPOINT=https://hf-mirror.com      # зеркало HF для санкционных регионов
      - WEBUI_MAX_FILE_SIZE=200
      - ANONYMIZED_TELEMETRY=false
      - WEBUI_NAME=Hermes Study
    extra_hosts:
      - host.docker.internal:host-gateway

volumes:
  open-webui:
```

### Run

```bash
cd /home/oleg/open-webui
docker compose up -d
```

### First Setup

1. Открой `http://<VPS_IP>:3000` в браузере
2. Зарегистрируй первого пользователя (становится админом)
3. Настройки → Подключения → OpenRouter → вставь API-ключ
4. Выбери модель (deepseek/deepseek-v4-flash)
5. Включи RAG: Настройки → Документы → активируй

## 1b. Open Notebook — Deployment (рекомендуется)

### Docker Compose

```yaml
# /home/oleg/open-notebook/docker-compose.yml
services:
  surrealdb:
    image: surrealdb/surrealdb:v2
    command: start --log info --user root --pass root rocksdb:/mydata/mydatabase.db
    user: root
    ports:
      - "8000:8000"
    volumes:
      - ./surreal_data:/mydata
    environment:
      - SURREAL_EXPERIMENTAL_GRAPHQL=true
    restart: always

  open_notebook:
    image: lfnovo/open_notebook:v1-latest
    ports:
      - "8502:8502"  # Web UI
      - "5055:5055"  # REST API
    environment:
      # Обязательно: сгенерировать свой ENCRYPTION_KEY
      - OPEN_NOTEBOOK_ENCRYPTION_KEY=<сгенерировать: openssl rand -hex 32>
      - SURREAL_URL=ws://surrealdb:8000/rpc
      - SURREAL_USER=root
      - SURREAL_PASSWORD=root
      - SURREAL_NAMESPACE=open_notebook
      - SURREAL_DATABASE=open_notebook
    volumes:
      - ./notebook_data:/app/data
    depends_on:
      - surrealdb
    restart: always
```

### Run

```bash
cd /home/oleg/open-notebook
docker compose up -d
```

### First Setup

1. Открой `http://<IP>:8502` в браузере
2. Настройки → Credentials → Добавить OpenRouter или DeepSeek:
   - **DeepSeek (прямой)**: provider = `deepseek`, вставь API-ключ DeepSeek
   - **OpenRouter**: provider = `openai_compatible`, base_url = `https://openrouter.ai/api/v1`, вставь API-ключ OpenRouter
3. Настройки → Models → Добавить модель, привязать к credentials
4. Создай Notebook → Sources → Upload files (PDF, аудио, URL)
5. Чат внутри Notebook будет использовать RAG по загруженным источникам

> **Важно:** Open Notebook хранит API-ключи в зашифрованном виде в SurrealDB. ENCRYPTION_KEY в docker-compose должен быть уникальным.

### Настройка embedding-модели для векторного поиска

Без модели эмбеддингов Open Notebook не может делать векторный поиск по источникам (в UI будет сообщение об ошибке). DeepSeek не предоставляет embedding API — нужен отдельный провайдер.

**Вариант 1: Через OpenRouter (рекомендуется)**

Если уже есть ключ DeepSeek/OpenRouter — можно использовать OpenRouter как OpenAI-compatible embedding провайдер:

1. Settings → Credentials → Add credential
2. Provider: `OpenAI Compatible`
3. Name: `OpenRouter Embed`
4. Base URL: `https://openrouter.ai/api/v1`
5. API Key: тот же ключ (DeepSeek или OpenRouter)
6. Modalities: `embedding` (отметить)
7. Save

Или через API:
```bash
# Создать credential
curl -X POST http://localhost:8502/api/credentials \
  -H "Content-Type: application/json" \
  -d '{
    "name": "OpenRouter Embed",
    "provider": "openai_compatible",
    "base_url": "https://openrouter.ai/api/v1",
    "api_key": "sk-...",
    "modalities": ["embedding"]
  }'

# Зарегистрировать модель text-embedding-3-small
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

# Назначить как модель по умолчанию
curl -X PUT "http://localhost:8502/api/models/defaults" \
  -H "Content-Type: application/json" \
  -d '{
    "default_embedding_model": "<model_id>"
  }'
```

**Вариант 2: Локально через Ollama**

```bash
# Установить embedding модель в Ollama
ollama pull nomic-embed-text  # или all-minilm:33m (легче)
```

Если `ollama pull` не работает (медленный интернет, санкции) — установить вручную через hf-mirror или использовать OpenRouter (вариант 1).

> **Диагностика:** `default_embedding_model: null` в `GET /api/models/defaults` — явный признак отсутствия embedding-модели.

## 2. Obsidian — Installation

```bash
flatpak install -y flathub md.obsidian.Obsidian
flatpak run md.obsidian.Obsidian
```

Для синхронизации с телефоном используй Obsidian Sync (платный) или Obsidian Git (бесплатный плагин).

## 3. How Hermes bridges the stack

- Пользователь кидает PDF в Telegram → Hermes может загрузить прямо в Open Notebook через API
- Пользователь задаёт вопрос → Hermes может искать через Open Notebook API или через Open WebUI API
- Пользователь просит конспект → Hermes создаёт заметку в Obsidian vault
- Один ключ API (DeepSeek или OpenRouter) используется для всех инструментов — и Hermes, и RAG-приложения

## 4. Pipeline: PDF → RAG → Obsidian

Рекомендуемый workflow при обучении:

### С Open Notebook
1. Создать Notebook в Open Notebook
2. Загрузить книгу/статью через Sources → Upload files (PDF, URL, аудио)
3. Читать/спрашивать в чате Notebook — RAG работает по загруженным источникам
4. Делать заметки → Notes → сохраняются в том же Notebook
5. Параллельно вести конспекты в Obsidian (своими словами, связи между темами)

### С Open WebUI
1. Загрузить книгу в Open WebUI (RAG-чат по содержанию)
2. Читать/спрашивать → понимать концепции
3. Параллельно вести конспекты в Obsidian (своими словами, связи между темами)
4. Просить Open WebUI провести экзамен по загруженным материалам

## 5. Maintenance: Updating Containers

### Проблема: плавающие теги (`:v1-latest`, `:latest`) не всегда указывают на свежий образ

`docker compose pull` с `pull_policy: always` может НЕ подтянуть новый образ, если тег `:v1-latest` на Docker Hub не был перезаписан после GitHub-релиза. Текущий образ на диске остаётся старым, хотя новая версия уже вышла.

Причина: Docker сравнивает digest локального образа с digest на registry. Если тег не обновлён (digest на registry не изменился), Docker считает образ актуальным и не скачивает.

**Признак проблемы:** `docker compose pull` сообщает «Image is up to date», но changelog показывает новую версию, а `docker inspect <image>` показывает старую дату создания.

**Диагностика:**
```bash
# 1. Сравнить digest локального образа с Docker Hub
docker images lfnovo/open_notebook --digests

# 2. Проверить дату создания образа
docker inspect lfnovo/open_notebook:v1-latest | python3 -c "
import sys,json; d=json.load(sys.stdin)[0]
print('Created:', d['Created'])
"

# 3. Сверить с Docker Hub через браузер:
#    https://hub.docker.com/r/lfnovo/open_notebook/tags
#    Если digest/дата отличается — нужна принудительная переустановка

# 4. Проверить последний релиз на GitHub
#    https://github.com/lfnovo/open-notebook/releases
```

### Procedure: принудительное обновление (когда pull не помогает)

**Всегда сначала делать backup данных:**

```bash
cd /home/oleg/open-notebook
tar czf "backup/open-notebook-$(date +%Y%m%d_%H%M%S).tar.gz" \
  surreal_data/ notebook_data/ docker-compose.yml
```

**Затем — принудительная пересборка контейнера:**

```bash
cd /home/oleg/open-notebook

# 1. Остановить контейнер
docker compose stop open_notebook

# 2. Удалить контейнер (чтобы освободить привязку к старому образу)
docker rm open-notebook-open_notebook-1

# 3. Удалить старый образ
docker rmi lfnovo/open_notebook:v1-latest

# 4. Скачать свежий образ
docker compose pull open_notebook

# 5. Создать контейнер заново
docker compose up -d open_notebook
```

**Для Open WebUI** (openwebui/open-webui) — тот же принцип:
```bash
cd /home/oleg/open-webui
docker compose stop open-webui
docker rm open-webui
docker rmi openwebui/open-webui:latest-slim
docker compose pull open-webui
docker compose up -d open-webui
```

### Проверка после обновления

```bash
# Проверить, что контейнер запущен
docker compose ps

# Проверить HTTP-ответ
curl -s -o /dev/null -w "%{http_code}" http://localhost:8502/   # Open Notebook UI
curl -s http://localhost:5055/health                              # Open Notebook API

# Проверить версию (дата образа)
docker inspect lfnovo/open_notebook:v1-latest | python3 -c "
import sys,json; d=json.load(sys.stdin)[0]
print('Image:', d['Config']['Image'])
print('Created:', d['Created'])
"

# Проверить логи на старте
docker compose logs --tail 30 open_notebook
```

Искать в логах сообщение `Application startup complete` и `Next.js` с номером версии.

### Post-update: проверка связки источников с блокнотами

После обновления Open Notebook v1.10.0 **источники могут отвязаться от блокнотов**. База SurrealDB сохраняет источники, но их привязка (notebook → source reference) теряется. В результате RAG-чат ищет по пустому контексту и не отвечает.

**Диагностика:**

```bash
# 1. Проверить, есть ли источники в БД вообще
curl -s http://localhost:5055/api/sources | python3 -c "
import sys, json; d = json.load(sys.stdin)
print(f'Total sources: {len(d)}')
for s in d:
    nbs = s.get('notebooks', [])
    print(f'  {s.get(\"title\",\"?\")} — notebooks: {nbs}')
"

# 2. Проверить ноутбук — сколько источников привязано
curl -s http://localhost:5055/api/notebooks | python3 -c "
import sys, json; d = json.load(sys.stdin)
for n in d:
    print(f'{n.get(\"name\",\"?\")}: source_count={n.get(\"source_count\",0)}')
"

# 3. Проверить, находит ли контекст что-то (если sources: [] — проблема)
curl -s -X POST http://localhost:5055/api/chat/context \
  -H 'Content-Type: application/json' \
  -d '{
    "notebook_id": "notebook:<id>",
    "context_config": {
      "messages": [{"role": "user", "content": "test"}],
      "model_id": "model:<id>",
      "notebook_id": "notebook:<id>"
    }
  }' | python3 -c "import sys, json; d=json.load(sys.stdin); print(f'sources: {len(d[\"context\"][\"sources\"])}, notes: {len(d[\"context\"][\"notes\"])}')"
```

**Восстановление привязки:**

```bash
# Получить список source_id из БД
curl -s http://localhost:5055/api/sources | python3 -c "
import sys, json; d = json.load(sys.stdin)
for s in d: print(s['id'])
"

# Привязать источники к ноутбуку через PUT (POST не сохраняет привязку!)
NOTEBOOK="notebook:<notebook_id>"
SOURCE_IDS='["source:id1","source:id2",...]'

curl -s -X PUT "http://localhost:5055/api/notebooks/${NOTEBOOK}" \
  -H "Content-Type: application/json" \
  -d "{\"source_ids\": ${SOURCE_IDS}}"

# Проверить — после PUT source_count должен увеличиться
# ВАЖНО: GET /api/notebooks/{id} может показывать sources: 0 даже после привязки.
# Реальная проверка — через RAG-чат (см. ниже).
```

**Тест RAG после восстановления:**

```bash
# Создать сессию чата с ноутбуком
SESS=$(curl -s -X POST http://localhost:5055/api/chat/sessions \
  -H "Content-Type: application/json" \
  -d '{"notebook_id": "notebook:<id>"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

# Отправить вопрос с notebook_id в context
curl -s -X POST "http://localhost:5055/api/chat/execute" \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": \"$SESS\",
    \"message\": \"На основе источников ответь коротко: ...\",
    \"context\": {
      \"notebook_id\": \"notebook:<id>\"
    }
  }"
```

Если ответ содержит ссылки на источники (`[note:...]`) — RAG работает.

### Плавающие теги и их тайминги

- `:v1-latest` (Open Notebook) — не гарантирует мгновенного обновления после GitHub-релиза. Может отставать на дни
- `:latest` (Open WebUI) — то же самое
- **Надёжнее всего:** дождаться, пока появится конкретный тег версии (например, `:1.10.0`), и временно переключить docker-compose на него. После появления `:v1-latest` с тем же или более новым digest — вернуть обратно

### SurrealDB при обновлении

SurrealDB остаётся старым контейнером — обновлять её не нужно. Open Notebook при старте автоматически применяет миграции схемы БД. Данные не теряются (хранятся в `./surreal_data/` и `./notebook_data/`).

При миграции подкастов могут быть предупреждения (`No credential found for provider 'openai'`) — это не ошибка, а сообщение о том, что speaker-профили не могут быть автоматически перенесены без OpenAI-credentials. Функциональность не страдает.

### References

- [Docker Hub: lfnovo/open_notebook tags](https://hub.docker.com/r/lfnovo/open_notebook/tags)
- [GitHub Releases: lfnovo/open-notebook](https://github.com/lfnovo/open-notebook/releases)
- [Open Notebook CHANGELOG](https://github.com/lfnovo/open-notebook/blob/main/CHANGELOG.md)
- [Local SSH Tunnel Setup](references/local-tunnel-setup.md) — detailed patterns for localhost.run, serveo.net, localtunnel
- [Sanctions Workarounds](references/sanctions-workarounds.md) — comprehensive registry/Docker Hub/HF/Cloudflare bypass patterns

## Troubleshooting: RAG не отвечает / вопрос зависает

### Симптомы

| Симптом | Вероятная причина |
|---------|-------------------|
| Вопрос «думает» 30+ секунд, потом сбрасывается | Embedding-запрос падает с ошибкой → фронтенд ждёт → таймаут → дроп |
| Ответ приходит, но без ссылок на источники | `notebook_id` не передан в `context` при execute, или источники не привязаны |
| `/api/search/ask/simple` возвращает ошибку | Embedding credential не работает или модель по умолчанию удалена |
| Ответ от DeepSeek, но не по источникам | Чат сработал (LLM отвечает), но RAG-поиск не нашёл контекст |

### Цепочка отказа RAG (уровень за уровнем)

```
Вопрос в UI
  → frontend отправляет POST /api/chat/execute с notebook_id в context
    → API вызывает vector_search(term, ...)
      → embedding модель генерирует вектор запроса
        → [ОШИБКА] embedding credential не работает (ключ, провайдер, модель)
          → API падает с исключением → frontend ждёт → timeout → дроп
```

**Проверка уровня 1: credential**

```bash
curl -s http://localhost:5055/api/credentials | python3 -c "
import sys, json
for c in json.load(sys.stdin):
    print(f'{c[\"name\"]:30s} | has_api_key={c[\"has_api_key\"]} | modalities={c[\"modalities\"]} | decryption_error={c.get(\"decryption_error\")}')
"
```

Если `has_api_key: false` или `decryption_error` не null — credential повреждён. Удалить и создать заново.

**Проверка уровня 2: embedding модель по умолчанию**

```bash
curl -s http://localhost:5055/api/models/defaults | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f'default_embedding_model: {d.get(\"default_embedding_model\")}')
em = d.get('default_embedding_model', '')
if em and em != 'null':
    # Проверить, существует ли модель
    import subprocess
    r = subprocess.run(['curl', '-s', f'http://localhost:5055/api/models/{em}'], capture_output=True, text=True)
    if 'not found' in r.stdout.lower() or r.stdout.strip() == '':
        print('⚠ model_id не существует!')
    else:
        print('✓ модель существует')
"
```

Если `default_embedding_model: null` — embedding модель никогда не была настроена.
Если `default_embedding_model: <model_id>` и модель удалена — RAG будет падать с `Model with ID ... not found`.

**Проверка уровня 3: привязка источников к ноутбуку**

```bash
curl -s -X POST http://localhost:5055/api/chat/context \
  -H 'Content-Type: application/json' \
  -d '{
    "notebook_id": "<notebook_id>",
    "context_config": {
      "messages": [{"role": "user", "content": "test"}],
      "model_id": "<model_id>",
      "notebook_id": "<notebook_id>"
    }
  }' | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f'sources: {len(d[\"context\"][\"sources\"])}, notes: {len(d[\"context\"][\"notes\"])}')
"
```

sources: 0 → источники не привязаны к ноутбуку. Использовать PUT `/api/notebooks/{id}` с `source_ids`.

**Проверка уровня 4: функциональность LLM**

```bash
# Чат без RAG (без notebook_id в context)
curl -s -X POST http://localhost:5055/api/chat/execute \
  -H 'Content-Type: application/json' \
  -d '{
    "session_id": "<session_id>",
    "message": "Ответь коротко: 2+2=?",
    "context": {"sources": [], "notes": []}
  }'
```

Если и это не работает — проблема с credential для чата, не с эмбеддингами.

### Прямой тест RAG

```bash
# Создать сессию
SESS=$(curl -s -X POST http://localhost:5055/api/chat/sessions \
  -H "Content-Type: application/json" \
  -d '{"notebook_id": "<notebook_id>"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")

# Отправить вопрос с notebook_id в context
curl -s -X POST "http://localhost:5055/api/chat/execute" \
  -H "Content-Type: application/json" \
  -d "{
    \"session_id\": \"$SESS\",
    \"message\": \"На основе источников блокнота ответь коротко: чем отличается Terraform от Ansible?\",
    \"context\": {
      \"notebook_id\": \"<notebook_id>\"
    }
  }"
```

Если ответ содержит `[note:...]` или явное указание источника — RAG работает.

### Что делать, если всё равно не работает

1. **Проверить логи API:** `docker compose logs --tail 50 open_notebook | grep -i -E "error|fail|embed|auth|traceback"`
2. **Проверить версию:** после обновления мог измениться API (см. [reference: open-notebook-v110-migration.md](references/open-notebook-v110-migration.md))
3. **Создать credential заново:** ошибка "Missing Authentication header" при `has_api_key: true` — признак повреждённого ключа в хранилище. Удалить credential → создать новый с тем же ключом.

### «Долго думает и сбрасывается» — краткий диагноз

Если вопрос в UI уходит в бесконечное ожидание (30+ сек) и потом сбрасывается без ответа — это почти всегда **проблема с эмбеддингами**:

1. Frontend шлёт запрос → API пытается сделать vector_search
2. Embedding credential не работает → API не отвечает 30+ секунд
3. Frontend timeout → соединение рвётся → пользователь видит «сброс»

**Решение:** проверить credential для эмбеддингов, `default_embedding_model`, и пересоздать при необходимости.

## Очистка дубликатов источников (Source Deduplication)

После многократной загрузки одних и тех же PDF/URL в Open Notebook могут появиться дубликаты источников. Они занимают место, но не влияют на RAG (поиск идёт по всем). Удалять их стоит, чтобы не путаться в UI.

### Диагностика дубликатов

```bash
# 1. Получить все источники, сгруппировать по названию
curl -s http://localhost:5055/api/sources | python3 -c "
import sys, json
d = json.load(sys.stdin)
from collections import defaultdict
groups = defaultdict(list)
for s in d:
    title = s.get('title', '?').strip().lower()
    groups[title].append(s)

for title, sources in sorted(groups.items()):
    if len(sources) > 1:
        print(f'{sources[0].get(\"title\",\"?\")} ({len(sources)} копии):')
        for s in sources:
            print(f'  ID: {s[\"id\"]}  Created: {s.get(\"created\",\"?\")[:19]}')
        print()
"
```

### Проверка идентичности (важно!)

Перед удалением убедись, что копии действительно одинаковые. Сравнивай по полю `full_text` — там обычно указана версия/год издания.

```bash
# Сравнить две копии
curl -s "http://localhost:5055/api/sources/<id_1>" | python3 -c "
import sys, json
s = json.load(sys.stdin)
# Ищем версию в full_text
ft = s.get('full_text', '')
import re
# Ищем паттерны: 'version', 'edition', 'published', year
for line in ft.split('\n')[:10]:
    if any(k in line.lower() for k in ['version','edition','published','copyright','isbn']):
        print(f'{s[\"id\"]}: {line.strip()[:100]}')
"
```

Если год/версия одинаковые — это дубликаты, можно удалять.
Если год/версия разные — оставить обе.

### Удаление дубликатов

```bash
# Только если источники НЕ привязаны к Sales Scripts (не трогать!)
for SRC_ID in "source:id1" "source:id2"; do
  curl -s -o /dev/null -w "Deleted $SRC_ID: %{http_code}\n" -X DELETE "http://localhost:5055/api/sources/${SRC_ID}"
done
```

**Важно:** после удаления привязка к ноутбукам теряется для удалённых источников. Нужно заново привязать оставшиеся:

```bash
NOTEBOOK="notebook:<notebook_id>"
for SRC_ID in "source:id1" "source:id2" "source:id3"; do
  curl -s -o /dev/null -X POST "http://localhost:5055/api/notebooks/${NOTEBOOK}/sources/${SRC_ID}"
done
```

### Практика из этого проекта

В блокноте «Курс DevOps» были дубликаты:
- Ansible for DevOps: 2 шт → 1 (идентичные, 2023)
- Pro Git: 4 шт → 1 (все Version 2.1.449, 2025-12-12)
- Terraform Up & Running: 2 шт → 1 (3rd ed, 2022)
- Windows Networking Essentials: 3 шт → 1 (Darril Gibson)

Всего удалено: 7 копий, оставлено 9 уникальных источников.

## Pitfalls

### Теги на Docker Hub
На Docker Hub у `openwebui/open-webui` **нет тега `:main`**. Используй:
- `latest` (полный образ, ~1.7 GB)
- `latest-slim` (урезанный, ~900 MB — рекомендую, не блокирует старт загрузкой HF-моделей)
- `0.9.6` (конкретная версия)
- `0.9.6-slim`

### ghcr.io заблокирован (санкции)
GitHub Container Registry (ghcr.io) может быть недоступен. Open WebUI официально публикуется **на оба registry**: ghcr.io и Docker Hub. Используй `openwebui/open-webui` (Docker Hub).

### HuggingFace заблокирован (санкции)
Open WebUI скачивает embedding-модели (sentence-transformers/all-MiniLM-L6-v2) с HuggingFace. Если HF недоступен:
```bash
# Добавить в environment контейнера
HF_ENDPOINT=https://hf-mirror.com
```
Китайское зеркало hf-mirror.com обычно доступно из любых регионов. Работает как для полного образа, так и для slim.

### Доступ с телефона (ПК за NAT — без публичного IP)

Если Open WebUI на VPS с публичным IP — просто:
```bash
ufw allow 3000/tcp
```

Если на **локальном ПК за NAT** — варианты, от лучшего к худшему:

#### 🥇 Tailscale (рекомендуется)
WireGuard-based mesh VPN. Не требует открытых портов, проходит любой NAT, стабилен.

**На ПК (нативный, через sudo):**
```bash
# Добавить репозиторий Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list >/dev/null
sudo apt-get update && sudo apt-get install -y tailscale
# Запустить авторизацию
sudo tailscale up
```
После `tailscale up` открой ссылку в браузере для авторизации.

**Альтернатива — Tailscale в Docker** (если ставить пакет не хочется или нельзя):
```bash
docker run -d --name=tailscale \
  --restart=always \
  -v tailscale-data:/var/lib/tailscale \
  -v /dev/net/tun:/dev/net/tun \
  --network=host \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  tailscale/tailscale:latest tailscaled

# Активация
docker exec tailscale tailscale up --auth-key <key>
```

**На Android (альтернатива Google Play — для санкционных регионов):**
Google Play может быть заблокирован. Скачай APK из GitHub Releases:
```
https://github.com/tailscale/tailscale-android/releases
```
Выбери последний релиз → Assets → `tailscale-android-universal-*.apk`

**После установки:** устройства увидят друг друга. Доступ к сервисам:
```
http://100.x.x.x:3000   # Open WebUI
http://100.x.x.x:8502   # Open Notebook
http://100.x.x.x:5678   # n8n
```

#### 🥈 IPv6 напрямую
Если у ПК есть публичный IPv6 (проверить: `curl -6 ifconfig.me`) и у телефона/провайдера тоже есть IPv6:
```bash
ufw allow 3000/tcp
```
Доступ: `http://[IPv6_адрес]:3000`. Минус: IPv6 может быть нестабилен или отсутствовать на мобильном интернете.

#### 🥉 SSH-туннель через VPS
Если есть VPS с публичным IP — проброс через SSH:
```bash
# На ПК (однократно, держать соединение):
ssh -R 3000:localhost:3000 -o ServerAliveInterval=60 user@vps
```
Доступ: `http://VPS_IP:3000`. Минус: соединение может рваться, нужен автореконнект (autossh/systemd).

### SUDO_PASSWORD для Hermes
Если Hermes (агент) не может выполнять `sudo` — настрой пароль в `.env`:
```bash
echo 'SUDO_PASSWORD=твой_пароль' >> /home/oleg/.hermes/.env
chmod 600 /home/oleg/.hermes/.env
```
**Важно:** `sudo -S` (передача пароля через stdin) блокируется Hermes security. Работает только через `.env`.
После записи перезапуск сессии не нужен — Hermes подхватывает при следующем `sudo` в `terminal()`.

### Первый старт может быть медленным
- Полный образ (`latest`): ~1.7 GB скачивание + скачивание HF-моделей при первом старте
- Slim (`latest-slim`): ~900 MB + модели скачиваются лениво при первом RAG-запросе
- Интернет под санкциями может быть медленным — закладывай 5-10 минут на скачивание

### Источники отваливаются от блокнотов после обновления

Open Notebook v1.10.0 может сбросить связи между источниками и блокнотами при обновлении. Симптом: вопросы в чате висят без ответа (или отвечают без ссылок на источники), хотя источники в БД есть.

**Восстановление:** см. раздел «Post-update: проверка связки источников с блокнотами» выше.

### API изменился в v1.10.0

Open Notebook v1.10.0 изменил эндпоинты чата:

| Что изменилось | Было (v1.9.x) | Стало (v1.10.0) |
|----------------|---------------|-----------------|
| Отправить сообщение в чат | `/api/chat` (POST) | `/api/chat/execute` (POST) + `/api/chat/context` (POST) |
| Поиск с RAG | `/api/search/ask` (простой) | `/api/search/ask` требует 3 model_id (`strategy_model`, `answer_model`, `final_answer_model`) |
| Создание сессии | `/api/chat/sessions` (POST) | `/api/chat/sessions` (POST) — без изменений |
| Путь отправки сообщения | Прямой POST в чат | POST `/api/chat/execute` с `session_id`, `message`, `context.notebook_id` |

Подробнее: [Open Notebook v1.10.0 API Reference](references/open-notebook-v110-migration.md)

## References

- [Open WebUI Quick Start](https://docs.openwebui.com/getting-started/quick-start/)
- [Obsidian](https://obsidian.md/)
- [Docker Hub: openwebui/open-webui](https://hub.docker.com/r/openwebui/open-webui)
- [Open Notebook — настройка embedding-модели](references/open-notebook-embedding-setup.md)
- [Open Notebook — загрузка источников через API](references/open-notebook-source-upload.md)
- [Open Notebook v1.10.0 — API и миграция](references/open-notebook-v110-migration.md)
- [Local SSH Tunnel Setup](references/local-tunnel-setup.md) — detailed patterns for localhost.run, serveo.net, localtunnel
- [Sanctions Workarounds](references/sanctions-workarounds.md) — comprehensive registry/Docker Hub/HF/Cloudflare bypass patterns
