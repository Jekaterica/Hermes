# Exa Search Setup

Exa (exa.ai) — search API for AI agents. Added 2026-06-19.

## Setup
```bash
echo "export EXA_API_KEY=your_key_here" >> ~/.hermes/.env
echo "export GITHUB_TOKEN=ghp_your_token_here" >> ~/.hermes/.env
```

Both are automatically included in the encrypted secrets archive (`secrets.tar.gz.enc`) by `encrypt-secrets.sh`.

## Usage
```bash
curl -s -X POST "https://api.exa.ai/search" \
  -H "Authorization: Bearer $EXA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "search query here", "numResults": 3}'
```

Returns: `requestId`, `results[]` with `id` (URL), `title`, `url`, `publishedDate`, plus `costDollars` per query.

## Pricing
~$0.007 per search query (as of 2026-06-19). Cost varies by result count and search type.

## When to use
- Fresh web data, news, docs
- When browser navigation is too heavy
- Third-tier knowledge source: Memory → RAG → Exa
