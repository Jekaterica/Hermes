# Firefox Cookie Extraction for Playwright

Full working script to extract all cookies from a Firefox profile and inject them into a Playwright Firefox context.

Key pitfalls documented in the parent `browser-auth-automation` skill.

## Full Extraction Function

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

## Usage Example

```python
import asyncio
from playwright.async_api import async_playwright

cookies = extract_cookies()

async with async_playwright() as p:
    context = await p.firefox.launch_persistent_context(
        "/tmp/pw_ff_profile",
        headless=True,
        slow_mo=600,
        viewport={"width": 1280, "height": 900},
    )
    await context.add_cookies(cookies)
    page = context.pages[0] or await context.new_page()
    await page.goto("https://target.site")
    await asyncio.sleep(5)
    print(await page.title())
    await context.close()
```

## Filtering by Domain

```python
# Google-only
google_cookies = [c for c in cookies if "google" in c["domain"]]

# Yandex
yandex_cookies = [c for c in cookies if "yandex" in c["domain"]]
```

## SQLite Path

```bash
find ~/.mozilla/firefox -name "places.sqlite" 2>/dev/null
# Cookie database: ~/.mozilla/firefox/<profile_id>/cookies.sqlite
```
