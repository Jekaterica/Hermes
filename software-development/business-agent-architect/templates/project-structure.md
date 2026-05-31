# Типовая структура проекта бизнес-агента

```
project-name/
│
├── bot/
│   ├── __init__.py
│   ├── main.py              # Точка входа (dispatcher)
│   ├── config.py             # Настройки из .env (pydantic-settings)
│   │
│   ├── core/
│   │   ├── __init__.py
│   │   ├── state_machine.py  # Машина состояний
│   │   ├── router.py         # Маршрутизация по intent + state
│   │   └── escallation.py    # Эскалация человеку
│   │
│   ├── db/
│   │   ├── __init__.py
│   │   ├── models.py         # SQLAlchemy модели
│   │   ├── repository.py     # Слой работы с БД
│   │   └── migrations/       # Alembic миграции
│   │
│   ├── handlers/
│   │   ├── __init__.py
│   │   ├── start.py          # /start, /help
│   │   ├── faq.py            # Ответы на вопросы
│   │   ├── booking.py        # Запись на услуги
│   │   ├── moderation.py     # Модерация
│   │   └── admin.py          # Админ-панель
│   │
│   ├── keyboards/
│   │   ├── __init__.py
│   │   ├── main.py           # Основные клавиатуры
│   │   └── admin.py          # Админ-клавиатуры
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── notification.py   # Уведомления и напоминания
│   │   └── schedule.py       # Логика расписания
│   │
│   └── utils/
│       ├── __init__.py
│       └── logger.py         # Логирование
│
├── prompts/
│   ├── system.md             # System prompt агента
│   └── scenarios.json        # Тестовые сценарии
│
├── scripts/
│   ├── seed.py               # Заполнение тестовыми данными
│   └── backup.py             # Бэкап БД
│
├── tests/
│   ├── __init__.py
│   ├── test_booking.py       # Тесты записи
│   ├── test_router.py        # Тесты маршрутизации
│   └── scenarios.json
│
├── deploy/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── nginx.conf
│   └── deploy.sh
│
├── .env.example
├── .gitignore
├── README.md
├── requirements.txt
└── Makefile
```

## requirements.txt (minimal)
```
aiogram>=3.0,<4.0
fastapi>=0.100,<1.0
uvicorn[standard]>=0.20,<1.0
pydantic-settings>=2.0,<3.0
sqlalchemy[asyncio]>=2.0,<3.0
asyncpg>=0.28,<1.0
alembic>=1.12,<2.0
pytest>=8.0,<9.0
pytest-asyncio>=0.23,<1.0
ruff>=0.1,<1.0
python-dateutil>=2.8,<3.0
```

## Правила работы
1. Каждый агент = отдельная папка в /home/oleg/agents/
2. Общие модули (core/) — копировать в каждый проект
3. .env — не в git. В репозитории только .env.example
4. Все секреты (токены, пароли БД) — только в .env
5. Перед деплоем — прогнать тесты и проверить чеклист
