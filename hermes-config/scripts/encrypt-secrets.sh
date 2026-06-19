#!/bin/bash
# encrypt-secrets.sh — шифрует .env в зашифрованный архив
# Используется перед коммитом цифрового образа
# Расшифровка: openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:ПАРОЛЬ -in secrets.tar.gz.enc | tar xzf -

ENV_FILE="$HOME/.hermes/.env"
OUTPUT="$HOME/.hermes/skills/hermes-secrets/secrets.tar.gz.enc"
PASSWORD="168801"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env не найден"
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"

# Упаковываем и шифруем
tar czf - -C "$HOME/.hermes" .env 2>/dev/null | \
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"$PASSWORD" -out "$OUTPUT"

if [ $? -eq 0 ]; then
    echo "✅ Secrets зашифрованы: $(ls -lh "$OUTPUT" | awk '{print $5}')"
else
    echo "❌ Ошибка шифрования"
    exit 1
fi
