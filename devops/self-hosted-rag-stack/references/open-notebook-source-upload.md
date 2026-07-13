# Open Notebook — Загрузка источников (Sources) через API

## Структура запроса

API ожидает `multipart/form-data` с полями:

| Поле | Тип | Значение |
|------|-----|----------|
| `type` | string | `"upload"` |
| `notebooks` | string | JSON-массив: `'["notebook:<id>"]'` (обязательно JSON, не просто строка!) |
| `title` | string | Название источника |
| `file` | file | PDF-файл |

> **Важно:** Поле `notebooks` обязательно должно быть **валидным JSON-массивом**. Передача `notebooks=notebook:xxx` (без скобок и кавычек) вызывает `500 Internal Server Error` с ошибкой `"Invalid JSON in notebooks field"`.

## Пример: curl

```bash
curl -X POST "http://localhost:8502/api/sources" \
  -F "type=upload" \
  -F 'notebooks=["notebook:s94zvr64db164u7tjhfz"]' \
  -F "title=My Book" \
  -F "file=@/path/to/book.pdf" --max-time 600
```

Успешный ответ:
```json
{"id":"source:<id>","title":"My Book","status":null}
```

Источник создаётся и возвращается сразу, но статус сначала `null` → через несколько секунд меняется на `running` → `completed`.

## Пример: Python requests

```python
import requests

r = requests.post(
    "http://localhost:8502/api/sources",
    data={
        "type": "upload",
        'notebooks': '["notebook:s94zvr64db164u7tjhfz"]',
        "title": "My Book"
    },
    files={"file": open("/path/to/book.pdf", "rb")},
    timeout=600
)
print(r.json())  # {"id":"source:...","title":"My Book",...}
```

## Проверка статуса

```bash
curl -s http://localhost:8502/api/sources | python3 -c "
import sys, json
sources = json.load(sys.stdin)
for s in sources:
    print(f'{s.get(\"title\",\"?\")} - {s.get(\"status\",\"?\")}')
"
```

## Питфоллы

### Проксирование через 8502 vs прямой доступ к 5055
Фронтенд Open Notebook (порт 8502) проксирует запросы к API (порт 5055). Next.js reverse proxy может подвисать при больших файлах (>10 MB) или при параллельных запросах, выдавая `socket hang up` → `500 Internal Server Error`.

**Решение:** отправлять запросы напрямую к API на порт 5055 (минуя Next.js прокси):

```python
import requests

# Прямой доступ к API — работает даже для файлов >30 MB
r = requests.post(
    "http://localhost:5055/api/sources",  # <-- порт 5055, не 8502
    data={
        "type": "upload",
        'notebooks': '["notebook:id"]',
        "title": "Book"
    },
    files={"file": open("book.pdf", "rb")},
    timeout=600
)
# Status: 200 — OK
```

При этом через 8502 (через прокси) тоже работает для файлов <10 MB:
- Увеличить `--max-time` до 600
- Использовать Python `requests` вместо curl
- Не отправлять несколько файлов одновременно
- Для файлов >10 MB — всегда через 5055 напрямую

### Internal Server Error 500
Если файл падает с 500 без явной ошибки в логах — возможные причины:
- `notebooks` не является JSON-массивом (самая частая причина)
- PDF битый или зашифрован (проверить: `file book.pdf` должен показать PDF document)
- Слишком большой файл (>50 MB) — Open Notebook может не справиться
- Проблемы с SurrealDB (проверить: `docker logs open-notebook-surrealdb-1`)

### Дубликаты источников
Повторная загрузка того же файла создаёт новый source в Open Notebook (дубликат). 
Нужно либо проверять существование источника перед загрузкой, либо удалять старые:
```bash
curl -X DELETE "http://localhost:8502/api/sources/<source_id>"
```
