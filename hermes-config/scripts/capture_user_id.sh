#!/bin/bash
# Capture @miss_melisska's Telegram user ID and lock down Hermes config
BOT_TOKEN="8818346670:AAE7JiUaO442VQcgxub0qwqmDiqDKYjvEFk"
TARGET_USERNAME="miss_melisska"
CONFIG_FILE="/home/oleg/.hermes/config.yaml"
ENV_FILE="/home/oleg/.hermes/.env"
LAST_UPDATE_ID="0"

echo "[$(date)] Starting monitor for @${TARGET_USERNAME}..."

while true; do
    # Get updates from Telegram
    RESPONSE=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${LAST_UPDATE_ID}&timeout=30" 2>/dev/null)

    if [ -z "$RESPONSE" ]; then
        sleep 5
        continue
    fi

    # Extract updates
    UPDATES=$(echo "$RESPONSE" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    results = data.get('result', [])
    for r in results:
        update_id = r.get('update_id', 0)
        msg = r.get('message', {})
        from_user = msg.get('from', {})
        user_id = str(from_user.get('id', ''))
        username = from_user.get('username', '')
        first_name = from_user.get('first_name', '')
        text = msg.get('text', '')
        print(f'{update_id}|{user_id}|{username}|{first_name}|{text[:50]}')
except:
    pass
" 2>/dev/null)

    if [ -n "$UPDATES" ]; then
        while IFS='|' read -r update_id user_id username first_name text; do
            LAST_UPDATE_ID=$((update_id + 1))

            echo "[$(date)] Message from: @${username} (ID: ${user_id}, Name: ${first_name})"

            # Check if this is our target user
            if [ "$username" = "$TARGET_USERNAME" ]; then
                echo "[$(date)] 🎯 Found @${TARGET_USERNAME}! User ID: ${user_id}"

                # Update .env file
                sed -i "s/TELEGRAM_ALLOWED_USERS=.*/TELEGRAM_ALLOWED_USERS=1283621889,${user_id}/" "$ENV_FILE"
                echo "[$(date)] Updated $ENV_FILE"

                # Update config.yaml - platforms.telegram section
                python3 -c "
import yaml
with open('$CONFIG_FILE', 'r') as f:
    cfg = yaml.safe_load(f)
# Update platforms.telegram
if 'platforms' in cfg and 'telegram' in cfg['platforms']:
    cfg['platforms']['telegram']['allowed_users'] = [1283621889, int($user_id)]
# Update messaging.telegram
if 'messaging' in cfg and 'telegram' in cfg['messaging']:
    cfg['messaging']['telegram']['allowed_users'] = [1283621889, int($user_id)]
with open('$CONFIG_FILE', 'w') as f:
    yaml.dump(cfg, f, default_flow_style=False, allow_unicode=True)
print('config.yaml updated')
" 2>/dev/null
                echo "[$(date)] Updated $CONFIG_FILE"

                # Restart gateway via systemd
                systemctl --user restart hermes-gateway.service 2>&1
                sleep 3
                echo "[$(date)] Gateway restarted with locked-down config"

                # Remove cron job
                crontab -l 2>/dev/null | grep -v "capture_user_id.sh" | crontab - 2>/dev/null

                echo "[$(date)] ✅ Done! @${TARGET_USERNAME} (ID: ${user_id}) added successfully"
                exit 0
            fi
        done <<< "$UPDATES"
    fi

    sleep 3
done
