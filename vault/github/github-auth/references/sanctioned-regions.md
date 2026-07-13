# GitHub в санкционных регионах (Крым и аналоги)

**Проверено на аккаунте Jekaterica (регион Крым, 2026).**

## Что не работает

| Возможность | Статус | Причина |
|-------------|--------|---------|
| Приватные репозитории | ❌ | Блокировка по региону |
| Создание репо через API | ❌ | Только через веб-интерфейс |
| Платные сервисы | ❌ | Блокировка |
| Классические PAT (`ghp_...`) | ❌ | `Bad credentials` при попытке push |
| Fine-grained PAT (`github_pat_...`) | ❌ | Не дают write-доступ без установки на репо, но даже установленные могут блокироваться |
| GitHub CLI (`gh`) | ❌ | Не установлен, установка через `apt` недоступна |

## Что работает

| Возможность | Статус |
|-------------|--------|
| Публичные репозитории | ✅ |
| Создание репо вручную через https://github.com/new | ✅ (только Public) |
| Чтение через API (unauthenticated) | ✅ |
| **SSH-ключи** | ✅ **Единственный рабочий способ для git push** |

## Рабочий процесс

### 1. Создать репо (только руками)

Пользователь заходит на https://github.com/new:
- Имя репозитория
- **Public**
- Без README/.gitignore (пустой)
- Нажать **Create repository**

### 2. Сгенерировать SSH-ключ (на сервере)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/<repo-name> -N "" -C "<repo-name>"
```

### 3. Добавить ключ в GitHub (пользователь)

Скопировать публичный ключ:
```bash
cat ~/.ssh/<repo-name>.pub
```

Зайти на https://github.com/settings/keys → **New SSH key** → вставить ключ.

### 4. Настроить SSH config

```bash
cat >> ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/<repo-name>
    IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
```

### 5. Проверить связь

```bash
ssh -T git@github.com
# → Hi Username! You've successfully authenticated...
```

### 6. Инициализировать и запушнить

```bash
cd /path/to/project
git init && git branch -m main
git add -A && git commit -m "initial: description"
git remote add origin git@github.com:Username/REPO_NAME.git
git push -u origin main
```

**Важно:** после первого SSH-подключения GitHub добавляет host key в known_hosts. Если push делается из скрипта (cron), может потребоваться предварительный `ssh -T git@github.com` или `GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"` в скрипте.

## Типичные ошибки

### Токен не работает, хотя создан правильно

Симптом: `remote: Invalid username or token. Password authentication is not supported.`
Или: API возвращает `Bad credentials`.

Причина: учётная запись в санкционном регионе — GitHub блокирует write-операции через токены, даже классические.

**Решение:** только SSH. Не тратить время на перебор токенов.

### Не удаётся создать приватное репо

Симптом: на странице https://github.com/new отсутствует выбор Private / Private недоступен.
Решение: создать Public. Код не содержит секретов (.env, БД в .gitignore).

### gh CLI не установлен и не ставится

Симптом: `command not found`, `apt install gh` недоступен.
Решение: git + SSH — не требует установки дополнительных пакетов.
