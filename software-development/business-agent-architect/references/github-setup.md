# GitHub Setup (Олег / Jekaterica)

**GitHub:** github.com/Jekaterica
**Git email:** jekaterinarusskaya@yandex.ru

## Токены (не работают — используй SSH)

**Все переданные токены не работают для git push.** Проверено:
- 3 fine-grained PAT (`github_pat_...`) — ни один не дал push
- 1 классический PAT (`ghp_...`) — тоже `Bad credentials`
- Причина: учётная запись в регионе Крым, GitHub блокирует любые write-операции через токены

Единственный рабочий способ — **SSH**.

### Что можно с токеном (ограничено)
| Возможность | Статус |
|-------------|--------|
| Авторизация пользователя (user endpoint) | ✅ |
| Чтение публичных репо | ✅ |
| Push / создание / запись / приватные репо | ❌ Все блокировано |
| Создание репо через API | ❌ Только руками через https://github.com/new (публичный) |

## SSH — единственный рабочий способ

### Создание ключа
```bash
ssh-keygen -t ed25519 -f ~/.ssh/hermes-skills -N "" -C "hermes-skills"
```

Ключи создаются с пустой passphrase (для авто-коммитов по cron).

### Настройка
1. Скопировать публичный ключ: `cat ~/.ssh/hermes-skills.pub`
2. Добавить в GitHub: https://github.com/settings/keys → **New SSH key**
3. Title: `hermes-skills`, Key: вставить скопированное
4. SSH-ключи добавляются к **аккаунту**, не к конкретному репо — не требуют установки на каждый репо

### SSH config (чтобы git знал, какой ключ использовать)
```bash
cat >> ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/hermes-skills
    IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
```

### Проверка
```bash
ssh -T git@github.com
# → Hi Jekaterica! You've successfully authenticated...
```

### Использование в backup.sh (и везде)
После настройки SSH — все `git push` работают автоматически.
HTTPS-remote заменяется на SSH:
```bash
git remote set-url origin git@github.com:Jekaterica/REPO_NAME.git
```

## Репозитории

- `Hermes` — публичный, для скиллов (~/.hermes/skills/), ночной авто-коммит
- Каждый проект агента → отдельный публичный репо (приватные недоступны)

### Создание нового репо
Приватные репо недоступны из-за санкций. Новый репо создаётся только:
1. Руками через https://github.com/new (публичный)
2. Затем: `git remote add origin git@github.com:Jekaterica/REPO_NAME.git && git push -u origin main`

## Авто-коммит

**Транспорт:** SSH (токены не работают).
**Git config:** user.name=Jekaterica, user.email=jekaterinarusskaya@yandex.ru

Схема: `git add -A` → `git commit -m "auto: daily update YYYY-MM-DD"` (только если есть изменения) → `git push`.
Для проектов — в `deploy/backup.sh` (cron 0 3 * * *).
Для скиллов — отдельный cron entry (запускается из ~/.hermes/skills/).

### Питфолл: push может упасть после создания репо
После создания репо через веб-интерфейс и добавления remote — первый push может попросить подтверждение host key. Либо выполнить `ssh -T git@github.com` один раз вручную, либо в скрипте добавить `GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"`:
