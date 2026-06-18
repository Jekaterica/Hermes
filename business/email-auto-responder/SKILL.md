---
name: email-auto-responder
description: Automated email processing pipeline — fetch, classify, analyze, and draft responses. Converted from crewAI email_auto_responder_flow pattern.
---

# Email Auto Responder

Automated email processing pipeline, adapted from crewAI `email_auto_responder_flow`.

## Pipeline

```
Fetch → Classify → Analyze → Draft → Review
  ↑                                  |
  └──── wait 180s ──────────────────┘
```

## State

Each email goes through these stages:

| Stage | Что делает | Выход |
|-------|-----------|-------|
| **Classify** | Определяет категорию: complaint, inquiry, lead, spam, other | category + priority |
| **Analyze** | Извлекает суть: тональность, ключевые факты, срочность | sentiment + key_points + urgency |
| **Draft** | Генерирует черновик ответа по шаблону | draft_response |
| **Review** | Проверяет качество перед отправкой | approved / needs_revision |

## Usage

```python
# Trigger manually
from hermes_tools import terminal

# Or via cron job — see setup below

async def process_email(email_text: str, sender: str) -> dict:
    """Process a single email through the pipeline."""

    # Step 1: Classify
    classification = await llm_call(
        system="""Classify this email into one category:
        - complaint: жалоба или проблема
        - inquiry: вопрос или запрос информации
        - lead: потенциальный клиент
        - spam: спам/рассылка
        - other: прочее

        Also assign priority: urgent, high, normal, low""",
        messages=[{"role": "user", "content": f"From: {sender}\n\n{email_text}"}]
    )

    if classification.get("category") == "spam":
        return {"action": "ignore", "reason": "spam"}

    # Step 2: Analyze
    analysis = await llm_call(
        system="""Extract from this email:
        - sentiment: positive | neutral | negative
        - key_points: list of important facts
        - urgency: low | medium | high
        - requires_response: yes | no""",
        messages=[{"role": "user", "content": email_text}]
    )

    if analysis.get("requires_response") == "no":
        return {"action": "note_only", "analysis": analysis}

    # Step 3: Draft response
    draft = await llm_call(
        system="""Write a professional email response.
        Tone should match the sender's sentiment:
        - positive → warm and engaged
        - neutral → clear and helpful
        - negative → apologetic and solution-oriented

        Keep it concise (3-5 sentences). Do NOT include subject line.""",
        messages=[
            {"role": "user", "content": f"Original: {email_text}\n\nCategory: {classification.get('category')}\nSentiment: {analysis.get('sentiment')}\nKey points: {analysis.get('key_points')}"}
        ]
    )

    return {
        "action": "draft_ready",
        "category": classification.get("category"),
        "priority": classification.get("priority"),
        "analysis": analysis,
        "draft": draft
    }
```

## Cron Setup (auto-polling)

Add a cron job that runs every 3 minutes:

```bash
hermes cron create   --schedule "*/3 * * * *"   --prompt "Check for new emails and process them using the email-auto-responder skill"
```

Or run as a oneshot for testing:

```bash
hermes cron run --job-id <id>
```

## Dependencies

This skill doesn't require crewAI or any external library — pure LLM calls.
For actual Gmail integration, set up IMAP credentials or use Gmail API.

## Gmail Integration (optional)

If you want real email fetching:

```python
import imaplib, email

IMAP_SERVER = "imap.gmail.com"
USERNAME = "your@email.com"
PASSWORD = "app-password"  # Use app-specific password

def fetch_unseen():
    mail = imaplib.IMAP4_SSL(IMAP_SERVER)
    mail.login(USERNAME, PASSWORD)
    mail.select("INBOX")
    _, ids = mail.search(None, "UNSEEN")
    emails = []
    for eid in ids[0].split()[:10]:  # max 10 per poll
        _, data = mail.fetch(eid, "(RFC822)")
        msg = email.message_from_bytes(data[0][1])
        emails.append({
            "id": eid.decode(),
            "sender": msg["From"],
            "subject": msg["Subject"],
            "body": msg.get_payload(decode=True).decode(errors="ignore")[:5000]
        })
    return emails
```
