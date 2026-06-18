---
name: browser-auth-automation
description: "Access authenticated web services by bridging browser session cookies — supporting both the Hermes headless browser (cookie injection via browser_console) and Playwright-based Firefox automation (add_cookies API)."
version: 1.0.0
author: agent (consolidated)
created_by: agent
---

# Browser Auth & Automation

## Overview

Two approaches to access authenticated web services (webmail, SaaS, admin panels) without re-entering credentials:

1. **Hermes Native Browser (MCP)** — inject cookies from Firefox's cookies.sqlite via `browser_console` into the built-in headless browser. Lightweight, no extra dependencies.
2. **Playwright Firefox Automation** — standalone Playwright session with `add_cookies` API. More control (slow_mo, viewport, non-headless via Xvfb).

Use Approach 1 for quick data extraction. Use Approach 2 for complex multi-page automation where you need full Playwright control.

## Workflow: Approach 1 — Hermes Native Browser (Cookie Injection)

### 1. Locate the Firefox Profile

```bash
ls ~/.mozilla/firefox/*.default*/
```

Each directory contains `cookies.sqlite` (SQLite database of cookies) and `places.sqlite` (bookmarks).

### 2. Extract Session Cookies

```python
import sqlite3
conn = sqlite3.connect('/home/user/.mozilla/firefox/PROFILE/cookies.sqlite')
c = conn.cursor()
c.execute('SELECT host, path, name, value, isSecure, expiry FROM moz_cookies WHERE host LIKE "%.yandex.com" AND name IN ("Session_id", "sessionid2", "yandexuid", "yandex_login")')
```

### 3. Inject via browser_console

Navigate to the root domain **first** (so `document.cookie` can write to that domain):

```python
browser_console(expression='document.cookie = "NAME=VALUE; path=/; domain=.example.com; secure=true; max-age=86400"')
```

### 4. Navigate to Authenticated App

```python
browser_navigate(url='https://app.example.com')
```

### 5. Extract Data

```javascript
Array.from(document.querySelectorAll('[role="listitem"]')).map(el => el.textContent.trim()).join('\n')
```

## Workflow: Approach 2 — Playwright Firefox Automation

### 1. Setup

```bash
pip install playwright
playwright install firefox
```

### 2. Cookie Extraction from Firefox Profile

```python
import sqlite3

FF_COOKIES_DB = "/path/to/firefox/profile/cookies.sqlite"

def extract_cookies():
    conn = sqlite3.connect(FF_COOKIES_DB)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()
    cur.execute("SELECT host, name, value, path, isSecure, isHttpOnly, sameSite, expiry FROM moz_cookies")
    
    pw_cookies = []
    for row in cur.fetchall():
        host = row["host"]
        domain = host[1:] if host.startswith(".") else host
        same_site_map = {0: "None", 1: "Lax", 2: "Strict"}
        
        expiry = row["expiry"]
        # FIREFOX USES MILLISECONDS — divide by 1000
        if expiry > 9999999999:
            expiry = expiry // 1000
        # Playwright rejects 0 or negative — use -1 (session)
        if expiry <= 0:
            expiry = -1
        
        pw_cookies.append({
            "name": row["name"], "value": row["value"],
            "domain": domain, "path": row["path"],
            "secure": bool(row["isSecure"]),
            "httpOnly": bool(row["isHttpOnly"]),
            "sameSite": same_site_map.get(row["sameSite"], "Lax"),
            "expires": expiry,
        })
    conn.close()
    return pw_cookies
```

### 3. Launch Playwright with Injected Cookies

```python
from playwright.async_api import async_playwright

cookies = extract_cookies()
google_cookies = [c for c in cookies if "google" in c["domain"]]

async with async_playwright() as p:
    context = await p.firefox.launch_persistent_context(
        "/tmp/pw_ff_profile",
        headless=True,
        slow_mo=600,          # human speed
        viewport={"width": 1280, "height": 900},
    )
    await context.add_cookies(google_cookies)
    page = context.pages[0] if context.pages else await context.new_page()
    await page.goto("https://target.site")
```

### 4. Xvfb for Non-Headless Mode

When a site detects `--headless`:

```bash
Xvfb :99 -screen 0 1280x900x24
export DISPLAY=:99
# Then launch with headless=False
```

## Pitfalls (Both Approaches)

- **`document.cookie` can only set cookies for the current domain.** Always navigate to the root domain first, inject cookies, then navigate to subdomain.
- **Secure cookies require HTTPS page.** Navigate to `https://` version before injecting.
- **SPA refs are ephemeral.** Yandex Mail, React SPAs regenerate element refs on every state change. Get a fresh `browser_snapshot` after every click.
- **Headless browser process is ephemeral.** The built-in browser session can lose injected cookies mid-task. Recovery: re-extract from Firefox's `cookies.sqlite`, re-inject.
- **Cookies may have native expiry.** Session cookies from Firefox may expire after ~24h.
- **Some cookies are HttpOnly** — can't set via `document.cookie`. Playwright's `add_cookies` can set them.
- **Firefox profile version mismatch**: Playwright bundles an older Firefox. Using `launch_persistent_context` with the user's real profile fails with version mismatch. Always extract cookies.
- **Cookie expiry in milliseconds**: Firefox SQLite stores expiry as JS timestamp (ms). Playwright expects Unix timestamp (seconds). Always check: `if expiry > 9999999999: expiry //= 1000`.
- **Cookie with expiry=0**: Playwright throws `Cookie should have a valid expires`. Filter these out or set to `-1`.
- **Profile lock**: If Firefox is running, `cookies.sqlite` is locked. Kill Firefox first or copy the profile.
- **VPN location matters**: Some services block datacenter VPN IPs. `?location=unsupported` param means Google blocks the current IP region.
- **Rate limiting.** Rapid browser interactions can trigger bot detection. Pause between actions.

## User Preferences

- Firefox ONLY, never Chromium
- Human speed: `slow_mo=600` minimum, 8-15 second waits between actions
- Prefer Playwright over built-in browser tool for controlled automation
- For quick lookups: built-in browser with cookie injection is sufficient

## Reference Files

- `references/yandex-mail-search-patterns.md` — Yandex Mail specific search, folder, and extraction patterns
- `references/cookie-extraction.md` — Full cookie extraction script for Playwright with domain filtering
