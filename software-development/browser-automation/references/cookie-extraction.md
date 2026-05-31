# Firefox Cookie Extraction for Playwright

Full working script to extract all cookies from a Firefox profile and inject them into a Playwright Firefox context.

Key pitfalls documented in the parent `browser-automation` skill.

## Usage

```python
import asyncio
from playwright.async_api import async_playwright

# Assume extract_cookies() is defined per the skill
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

For Google-only services:

```python
google_cookies = [c for c in cookies if "google" in c["domain"]]
```

For Yandex:

```python
yandex_cookies = [c for c in cookies if "yandex" in c["domain"]]
```

## SQLite Path

```bash
# Find Firefox profiles
find ~/.mozilla/firefox -name "places.sqlite" 2>/dev/null

# Profile cookies
~/.mozilla/firefox/<profile_id>/cookies.sqlite
```
