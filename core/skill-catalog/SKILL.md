---
name: skill-catalog
description: "Каталог доменных skills в ~/.hermes/skills-vault/. Загружай конкретный skill через skill_view() когда задача требует его области."
---

# Skill Catalog

Доменные skills лежат в `~/.hermes/skills-vault/`. Загружай через `skill_view(name)` когда задача соответствует области.

## GitHub (6)
- **github-pr-workflow** — PR lifecycle: branch, commit, open, CI, merge
- **github-repo-management** — clone/create/fork repos, remotes, releases
- **github-issues** — create, triage, label, assign issues
- **github-code-review** — review PRs, inline comments
- **github-auth** — GitHub auth: SSH, tokens, gh CLI login
- **codebase-inspection** — inspect codebases (pygount: LOC, languages)

## Productivity (5)
- **obsidian** — read, search, create notes in Obsidian vault
- **notion** — pages, databases, markdown via ntn CLI
- **google-workspace** — Gmail, Calendar, Drive, Docs, Sheets
- **ocr-and-documents** — extract text from PDFs/scans (pymupdf, marker-pdf)
- **nano-pdf** — edit PDF text/typos via CLI

## Creative (3)
- **architecture-diagram** — dark SVG architecture diagrams as HTML
- **sketch** — throwaway HTML mockups (2-3 variants)
- **excalidraw** — hand-drawn JSON diagrams (arch, flow, seq)

## Business (3)
- **sales-knowledge-rag** — search 5 sales books (SPIN, Fanatical Prospecting, etc.)
- **chat-widget** — real-time support chat widget for websites
- **email-auto-responder** — automated email pipeline (fetch, classify, draft)

## Testing (2)
- **agent-evaluation-framework** — LLM-as-Judge, G-Eval, regression testing
- **eval-harness** — Eval-Driven Development: capability evals, graders, pass@k

## Other (6)
- **himalaya** — email via IMAP/SMTP from terminal
- **youtube-content** — YouTube transcripts to summaries
- **arxiv** — search arXiv papers by keyword/author/category
- **open-notebook-rag** — semantic search across documents and notebooks
- **native-mcp** — MCP client: connect servers, register tools
- **webhook-subscriptions** — event-driven agent runs via webhooks
