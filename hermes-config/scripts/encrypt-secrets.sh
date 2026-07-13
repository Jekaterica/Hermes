#!/bin/bash
# encrypt-secrets.sh — шифрует .env в зашифрованный архив
# Используется перед коммитом цифрового образа
# Пароль берётся из .env → SECRETS_PASSWORD
# Расшифровка: source .env && openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"$SECRETS_PASSWORD" -in secrets.tar.gz.enc | tar xzf -

ENV_FILE="$HOME/.hermes/.env"
OUTPUT="$HOME/.hermes/skills/hermes-secrets/secrets.tar.gz.enc"

# Пароль читаем из .env
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

if [ -z "$SECRETS_PASSWORD" ]; then
    echo "❌ SECRETS_PASSWORD не задан (добавь в .env)"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env не найден"
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

# Упаковываем и шифруем
tar czf - -C "$HOME/.hermes" .env 2>/dev/null | \
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$SECRETS_PASSWORD" -out "$OUTPUT"

if [ $? -eq 0 ]; then
    echo "✅ Secrets зашифрованы: $(ls -lh "$OUTPUT" | awk '{print $5}')"
else
    echo "❌ Ошибка шифрования"
    exit 1
fi
