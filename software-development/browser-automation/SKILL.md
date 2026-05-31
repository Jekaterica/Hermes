---
name: browser-automation
description: Playwright + Firefox browser automation — cookie migration, human-speed interaction, Xvfb for non-headless mode, and pitfalls
---

# Browser Automation (Firefox + Playwright)

Trigger: user asks to open a web service in a browser, especially one requiring existing auth (Google, Yandex, etc.), and explicitly names Firefox or Playwright.

## Workflow

### 1. Setup

```bash
pip install playwright
playwright install firefox
```

Playwright installs its own Firefox binary (may be older than system Firefox). If profile version mismatch occurs, extract cookies instead.

### 2. Cookie Extraction from Real Firefox Profile

The user's real Firefox profile likely has valid session cookies. Extract them:

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
        slow_mo=600,          # human speed — user prefers this
        viewport={"width": 1280, "height": 900},
    )
    await context.add_cookies(google_cookies)
    page = context.pages[0] if context.pages else await context.new_page()
    await page.goto("https://target.site")
```

### 4. Xvfb for Non-Headless Mode

When a site detects `--headless`:

```bash
# Terminal 1: Start Xvfb in background
terminal(command="Xvfb :99 -screen 0 1280x900x24", background=true)

# Then set DISPLAY and run with headless=False
import os
os.environ["DISPLAY"] = ":99"
# ... launch_persistent_context(headless=False)
```

## Pitfalls

- **Firefox profile version mismatch**: Playwright bundles an older Firefox. Using `launch_persistent_context` with the user's real profile fails with "This profile was last used with a newer version". Always copy the profile first (`cp -a`) or extract cookies.
- **Cookie expiry in milliseconds**: Firefox SQLite stores expiry as JS timestamp (ms). Playwright expects Unix timestamp (seconds). Always check: `if expiry > 9999999999: expiry //= 1000`.
- **Cookie with expiry=0**: Playwright throws `Cookie should have a valid expires`. Filter these out or set to `-1`.
- **Profile lock**: If Firefox is running, `cookies.sqlite` is locked. Kill Firefox first or copy the profile.
- **launch_persistent_context reuses profile**: Subsequent launches reuse the same temp profile. Delete it (`rm -rf`) between runs for clean state.
- **VPN location matters**: Some services (NotebookLM, etc.) block datacenter VPN IPs even when "connected". `?location=unsupported` param in URL means Google blocks the current IP region.

## User Preferences

- Firefox ONLY, never Chromium
- Human speed: `slow_mo=600` minimum, 8-15 second waits between actions
- Prefer Playwright over built-in browser tool for controlled automation

## Reference Files

- `references/cookie-extraction.md` — full working script for cookie extraction + injection
