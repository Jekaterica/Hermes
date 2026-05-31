# Yandex Mail — Search & Extraction Patterns

## Search Queries for Finding Books/Attachments

Yandex Mail searches message bodies, subject lines, AND PDF/docx text content. Use these patterns:

| Goal | Search Query | Notes |
|------|-------------|-------|
| Find PDF books | `pdf` | Broad, many results |
| Find named books | `книга.pdf` | Searches filenames + content |
| Hair topic | `волосы`, `уход`, `hair` | Searches inside PDF text |
| Specific sender | Use folder navigation instead |

## Folder Navigation

- **Входящие (Inbox):** `571` total messages (as of session date)
- **Отправленные (Sent):** `53` total messages
- **Рассылки (Subscriptions):** `839` total
- **Папка "С вложениями"** — pre-built filter for attachment-only view

## Message Extraction via JavaScript

After search results load:

```javascript
// Extract all list items (folders + messages)
Array.from(document.querySelectorAll('[role="listitem"]'))
  .map(el => el.textContent.trim())
  .filter(t => t.length > 10 && t.length < 200)
  .join('\n')

// Message snippet if role-based selector fails
Array.from(document.querySelectorAll('.ns-view-messages-message, .message-snippet, [data-key]'))
  .map(el => el.textContent.trim())
```

## Ref Behavior

- Yandex Mail is a React SPA — element refs change on every navigation/state change
- Always call `browser_snapshot()` before attempting clicks
- The search box uses `[aria-label="Поиск"]` consistently across page states

## Attachments

Attachments appear in the message snippet as `<filename>.<ext><size>`. Size is in KB (`pdf2` = 2KB attachment). Common file types found:
- `.pdf` — full books
- `.docx` — Word documents
- `.fb2` — FictionBook ebooks
- `.jpeg` — photos
