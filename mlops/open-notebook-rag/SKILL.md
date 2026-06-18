---
name: open-notebook-rag
description: Retrieve knowledge from Open Notebook RAG database — semantic search across documents, notebooks, and sources. Use when you need factual answers grounded in the knowledge base.
---

# Open Notebook RAG Skill

Search the Open Notebook knowledge base for relevant documents and chunks using semantic vector search.

## When to Use
- User asks a question that requires knowledge from stored documents (PDFs, web pages, notes)
- Need to fact-check or ground responses in a curated knowledge base
- Building RAG-powered answers for business clients

## How It Works

1. Send the user's question as a search query to Open Notebook API
2. Open Notebook performs vector + full-text search across all notebooks
3. Return the most relevant chunks with source attribution
4. Use the retrieved context to answer the user's question

## Configuration

Open Notebook runs at:
- API: http://localhost:5055
- Web UI: http://localhost:8502

## Skill Implementation

```python
import httpx
from typing import Optional

OPEN_NOTEBOOK_API = "http://localhost:5055"

async def search_knowledge_base(
    query: str,
    notebook_id: Optional[str] = None,
    limit: int = 10
) -> list[dict]:
    """Search Open Notebook for relevant chunks."""
    async with httpx.AsyncClient(timeout=30) as client:
        payload = {
            "query": query,
            "limit": limit
        }
        if notebook_id:
            payload["notebook_id"] = notebook_id
        
        resp = await client.post(f"{OPEN_NOTEBOOK_API}/api/search", json=payload)
        resp.raise_for_status()
        return resp.json()

async def ask_with_knowledge(
    question: str,
    notebook_id: Optional[str] = None,
    model: str = "deepseek/deepseek-v4-flash"
) -> dict:
    """Ask a question with RAG context from the knowledge base."""
    async with httpx.AsyncClient(timeout=60) as client:
        payload = {
            "question": question,
            "strategy_model": model,
            "answer_model": model,
            "final_answer_model": model,
        }
        if notebook_id:
            payload["notebook_id"] = notebook_id
        
        resp = await client.post(f"{OPEN_NOTEBOOK_API}/api/search/ask", json=payload)
        resp.raise_for_status()
        return resp.json()
```

## RAG Best Practices (from GenAI_Agents)

1. **Chunk wisely** — break documents into semantic chunks (not arbitrary sizes)
2. **Retrieve with context** — include surrounding chunks for coherence
3. **Ground every claim** — cite the source for each piece of information
4. **Re-rank results** — cross-encoder re-ranking improves relevance
5. **Fallback for missing info** — if nothing relevant found, say so clearly
6. **Never hallucinate** — if the knowledge base doesn't contain the answer, don't invent it

## References

- `references/open-notebook-api.md` — полный API reference с реальными вызовами из этой сессии, включая создание ноутбуков, загрузку источников, поиск, вопрос с RAG, настройку креденциалов и питфоллы.
