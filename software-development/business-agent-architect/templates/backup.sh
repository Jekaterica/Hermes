#!/bin/bash
# backup.sh — ежедневный бэкап проекта агента
# Запускать через cron: 0 3 * * * /home/oleg/agents/project_name/deploy/backup.sh
#
# ДЕЛАЕТ (раз в сутки в 3 ночи):
#   1. Git: авто-коммит всех изменений кода за день
#   2. Бэкап PostgreSQL (дамп БД)
#   3. Бэкап .env (конфиги, ключи — не в Git)
#
# .env, БД и API-ключи НЕ попадают в Git — только в /backups/.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
BACKUP_DIR="/backups/$PROJECT_NAME"
DATE=$(date +%Y-%m-%d)

mkdir -p "$BACKUP_DIR"
echo "=== Ночной бэкап: $PROJECT_NAME / $DATE ==="

# --------------------------------------------------
# 1. Git: авто-коммит изменений кода за день
# --------------------------------------------------
if [ -d "$PROJECT_DIR/.git" ]; then
    cd "$PROJECT_DIR"
    # Добавляем всё, кроме .env и БД (они в .gitignore)
    git add -A
    # Коммит только если есть изменения (не создаём пустые коммиты)
    if ! git diff --staged --quiet; then
        git commit -m "auto: daily update $DATE"
        git push origin main 2>/dev/null || git push origin master 2>/dev/null || \
            echo "⚠️  Git push не удался (возможно, нет remote)"
        echo "OK: код закоммичен в Git"
    else
        echo "Изменений в коде нет. Git пропущен."
    fi
else
    echo "Git не инициализирован. Пропускаю."
fi

# --------------------------------------------------
# 2. Бэкап конфигов (.env — отдельно, не в Git)
# --------------------------------------------------
if [ -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env" "$BACKUP_DIR/env_$DATE"
    chmod 600 "$BACKUP_DIR/env_$DATE"
    echo "OK: .env → $BACKUP_DIR/env_$DATE"
else
    echo ".env не найден. Пропускаю."
fi

# --------------------------------------------------
# 3. Бэкап PostgreSQL
# --------------------------------------------------
if [ -f "$PROJECT_DIR/.env" ]; then
    set -a
    source "$PROJECT_DIR/.env"
    set +a
fi

if command -v pg_dump &> /dev/null && [ -n "$DB_NAME" ]; then
    PGPASSWORD="${DB_PASS:-}" pg_dump -h "${DB_HOST:-localhost}" \
        -U "${DB_USER:-agent_user}" \
        -d "$DB_NAME" \
        > "$BACKUP_DIR/db_$DATE.sql" 2>/dev/null
    gzip -f "$BACKUP_DIR/db_$DATE.sql"
    echo "OK: БД → $BACKUP_DIR/db_$DATE.sql.gz"
else
    echo "БД не настроена или pg_dump не найден. Пропускаю."
fi

# --------------------------------------------------
# 4. Очистка бэкапов старше 30 дней
# --------------------------------------------------
find "$BACKUP_DIR" -name "db_*.sql.gz" -mtime +30 -delete
find "$BACKUP_DIR" -name "env_*" -mtime +30 -delete
echo "=== Готово ==="
