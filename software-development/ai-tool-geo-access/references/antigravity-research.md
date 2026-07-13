# Google Antigravity — Исследование, июль 2026

## Что это
AI IDE/агент от Google (Project Antigravity) для разработки кода. Аналог Cursor, Claude Code, Codex CLI.
Распространяется как бинарник под Linux (x86_64, ARM64), macOS, Windows.
Официальный репозиторий: github.com/anthropics/claude-code (нет, это Claude Code) — Antigravity не имеет публичного репозитория.

## Геоблокировка для РФ
- Регистрация: проверка IP через Firebase Auth — **Россия заблокирована**
- Периодическая проверка: `GetUserStatus` endpoint — определяет регион
- Экран `ineligible` — блокирует работу
- Ошибка `"User location is not supported for the API use"` (HTTP 400)
- Ошибка `"You do not have a valid license"` (#3501) — проблема на стороне Google API

## Обход

### Решение: AvenCores/open-antigravity-patcher (466★, v1.2.0)
**Рекомендуется.** Активно поддерживается (последний коммит < 24ч), русскоязычный автор.

**Что делает:**
1. **IDE (main.js):** 4 патча — `isGoogleInternal → true`, `ideName → antigravity-insiders`, обход `ineligible`-экрана, runtime workaround для CloudCode endpoint
2. **Standalone (app.asar):** распаковывает → патчит JS + gRPC-фабрику (5 методов авторизации) → запаковывает с корректными SHA256
3. **CLI (agy):** байт-сигнатурный патч машинного кода под x86-64 и ARM64

**Безопасность:** проверено автором Hermes — код прозрачен, нет телеметрии/майнеров, есть бэкап и откат.
Сертификаты только для 127.0.0.1 (локальный HTTPS-прокси для ASAR-режима).
Зависимости: только pyinstaller + packaging.

**Linux:** полная поддержка. Автопоиск: `/usr/share/antigravity-ide`, `/opt/Antigravity IDE`.
Определение версии: dpkg/rpm/package.json. Sudo для системных директорий.

### Альтернативы
- **VPN:** WireGuard/OpenVPN с IP США/Европы — подходит, но Google может детектить
- **Специальные DNS:** Xbox DNS, GeoHide DNS — обход на уровне DNS

## Кастомный API провайдер (DeepSeek V4 Flash)

### ❌ Google Antigravity IDE — НЕ ПОДДЕРЖИВАЕТ
- Список моделей **фиксированный** — только модели Google
- Нет "Add Custom Model" или OpenAI-совместимого эндпоинта
- `settings.json` не содержит полей для кастомных провайдеров
- Подтверждено документацией Tayzeus/open-antigravity

### ❌ Antigravity Manager (lbjlaq, 30k★) — тоже НЕТ
- Это сторонний прокси-шлюз, а не часть Google IDE
- Проксирует запросы к Google/Anthropic через аккаунты пользователя
- **Не поддерживает свои API-ключи** — открытый feature request #1520, пока не реализован

## Итог
- Обход геоблокировки: **✅ AvenCores/open-antigravity-patcher**
- DeepSeek в Antigravity: **❌ невозможно**
- Linux: **✅ поддерживается**

Для DeepSeek V4 Flash нужен другой инструмент: Hermes, Codex CLI, OpenClaw, Continue.dev, Aider.
