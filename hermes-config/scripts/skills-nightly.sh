#!/bin/bash
# skills-nightly.sh — авто-коммит скиллов на GitHub, 3:00 ежедневно
# Запускается через cron Hermes Agent

REPO="$HOME/.hermes/skills"
VAULT="$HOME/.hermes/skills-vault"

cd "$REPO" || exit 1

# Копируем vault внутрь репо для коммита
rm -rf vault
cp -a "$VAULT" vault/

# Собираем изменения
git add -A

# Проверяем, есть ли что коммитить
if git diff --cached --quiet; then
    echo "🟢 Нет изменений за $(date +%Y-%m-%d)"
    exit 0
fi

# Коммит и пуш
git commit -m "auto: daily update $(date +%Y-%m-%d)"
git push origin main 2>&1
echo "✅ Закоммичено и запушено: $(date +%Y-%m-%d)"
