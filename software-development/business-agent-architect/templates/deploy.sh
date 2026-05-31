#!/bin/bash
# deploy.sh — скрипт деплоя бизнес-агента на VPS
# Использование: ./deploy.sh [prod|dev]
# Пример: ./deploy.sh prod

set -e

ENV="${1:-dev}"
PROJECT_DIR="$(dirname "$0")/.."
cd "$PROJECT_DIR"

echo "=== Деплой бизнес-агента [$ENV] ==="
echo "Директория: $(pwd)"

# 1. Проверка .env
if [ ! -f .env ]; then
    echo "❌ Нет .env файла. Создай из .env.example"
    exit 1
fi

# 2. Сборка и запуск
if [ "$ENV" = "prod" ]; then
    echo "🚀 Production запуск..."
    docker compose -f deploy/docker-compose.yml up --build -d
else
    echo "🧪 Dev запуск..."
    docker compose -f deploy/docker-compose.yml up --build -d
fi

# 3. Миграции БД
echo "📦 Применяю миграции..."
sleep 3
docker compose -f deploy/docker-compose.yml exec -T bot alembic upgrade head

# 4. Проверка
echo "✅ Проверка статуса..."
docker compose -f deploy/docker-compose.yml ps

echo ""
echo "=== Деплой завершён ==="
echo "Логи: docker compose -f deploy/docker-compose.yml logs -f bot"
