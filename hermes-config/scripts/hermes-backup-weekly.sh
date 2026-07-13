#!/bin/bash
# hermes-backup-weekly.sh — еженедельный бэкап цифрового образа
# Конфигурация: ~/.hermes/config.yaml, SOUL.md, USER.md, HERMES.md,
# cim-summary.md, strategic-context.md, scripts/
# 
# Запускается через cron Hermes Agent, 1 раз в неделю в 3:00

REPO="$HOME/.hermes/skills"
HERMES_HOME="$HOME/.hermes"

cd "$REPO" || exit 1

# Шифруем secrets для цифрового образа
bash "$HERMES_HOME/scripts/encrypt-secrets.sh"

# Копируем vault (доменные skills) внутрь репо
VAULT="$HOME/.hermes/skills-vault"
rm -rf vault
cp -a "$VAULT" vault/

mkdir -p hermes-config/scripts

# Копируем конфигурационные файлы (ядро личности)
for f in SOUL.md HERMES.md cim-summary.md strategic-context.md config.yaml; do
  if [ -f "$HERMES_HOME/$f" ]; then
    cp "$HERMES_HOME/$f" hermes-config/
    echo "  copied $f"
  fi
done

# Копируем USER.md из memories
if [ -f "$HERMES_HOME/memories/USER.md" ]; then
  cp "$HERMES_HOME/memories/USER.md" hermes-config/
  echo "  copied USER.md"
fi

# Копируем скрипты
if [ -d "$HERMES_HOME/scripts" ]; then
  cp "$HERMES_HOME/scripts/"*.sh hermes-config/scripts/ 2>/dev/null
  echo "  copied scripts"
fi

# Собираем изменения
git add -A

# Проверяем, есть ли что коммитить
if git diff --cached --quiet; then
    echo "🟢 Образ не изменился за неделю"
    exit 0
fi

# Коммит и пуш
git commit -m "weekly: digital twin snapshot $(date +%Y-%m-%d)"
git push origin main 2>&1
echo "✅ Цифровой образ сохранён: $(date +%Y-%m-%d)"
