---
name: sales-knowledge-rag
description: Search sales knowledge base — 5 books on selling techniques (SPIN, Fanatical Prospecting, Predictable Revenue, Conversion Code, StoryBrand). Ground your answers in proven frameworks and scripts.
---

# Sales Knowledge RAG

Local knowledge base with extracted key points from top sales books.

## Books in the KB

| Book | Author | Key Topics |
|------|--------|-----------|
| SPIN Selling | Neil Rackham | 4 types of questions (Situation, Problem, Implication, Need-Payoff) |
| Fanatical Prospecting | Jeb Blount | Cold calls, voice mail, email scripts, objection handling |
| Predictable Revenue | Aaron Ross | Cold Call 2.0, SDR pipeline, lead qualification (BANT) |
| The Conversion Code | Chris Smith | Lead capture, follow-up drips, closing techniques |
| Building a StoryBrand | Donald Miller | SB7 framework, brand messaging, customer transformation |

## Location

All files are at: `/home/oleg/agents/business-knowledge/sales-scripts/`

To search, use terminal grep:

```bash
grep -i -A 5 "query" /home/oleg/agents/business-knowledge/sales-scripts/*.md
```

Or for better results, search each book:

```bash
for f in /home/oleg/agents/business-knowledge/sales-scripts/*.md; do
  echo "=== $(basename $f) ==="
  grep -i -A 3 "$query" "$f" 2>/dev/null | head -20
done
```

## RAG Pipeline

When a user asks a sales question:

1. **Search** — grep for keywords across all 5 books
2. **Select** — pick the most relevant framework/script for the situation
3. **Apply** — adapt the script to the specific context
4. **Verify** — attribute the source (e.g. "This is based on SPIN Selling's implication question technique")

## Integration with Open Notebook

If Open Notebook has a configured embedding model, the same files can be uploaded for vector search at:
- API: `http://localhost:5055`
- UI: `http://localhost:8502`
- Notebook: "Sales Scripts"
