---
name: skill-evolution
description: "Evolve and optimize Hermes Agent skills, prompts, and tool descriptions using DSPy + GEPA — automated self-improvement without GPU."
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [self-evolution, gepa, dspy, skill-optimization, prompt-evolution, automatic-improvement]
    related_skills: [dspy, hermes-agent]
---

# Skill Evolution

## When to Use This Skill

Use skill evolution when you want to:
- **Automatically improve a skill's effectiveness** — evolve SKILL.md text through GEPA mutations guided by LLM-as-judge scores
- **Benchmark a skill with objective metrics** — generate eval datasets (synthetic, from session history, or golden) and score correctness/procedure-following/conciseness
- **Set up the self-evolution pipeline** — clone, configure, run dry-run, and execute full optimization iterations
- **Compare baseline vs evolved versions** — before/after metrics, diff review, constraint validation (size limits, test suite, semantic preservation)
- **Optimize without GPU** — all evolution runs through API calls (DSPy + GEPA mutate text strings, not model weights)

**Requires:** `hermes-agent-self-evolution` repo (NousResearch/hermes-agent-self-evolution), DSPy ≥3.0, GEPA ≥0.0.27.

## Quick Start

```bash
# 1. Clone and install
git clone https://github.com/NousResearch/hermes-agent-self-evolution.git
cd hermes-agent-self-evolution
pip install -e ".[dev]"

# 2. Point at Hermes skills
# Skills live in ~/.hermes/skills/ — set HERMES_AGENT_REPO to ~/.hermes
export HERMES_AGENT_REPO=$HOME/.hermes

# 3. Dry-run (zero API calls — validates setup)
python -m evolution.skills.evolve_skill --skill my-skill-name --dry-run

# 4. Real run (10 iterations, synthetic eval data)
python -m evolution.skills.evolve_skill --skill my-skill-name --iterations 10

# 5. Real run with session history
python -m evolution.skills.evolve_skill --skill my-skill-name --eval-source sessiondb

# 6. Verify the test suite
python -m pytest tests/ -q
```

## Configuration

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `HERMES_AGENT_REPO` | Points to hermes-agent skills root | `$HOME/.hermes` (when installed as pip package) |

### Key Config in `evolution/core/config.py`

| Parameter | Default | Description |
|-----------|---------|-------------|
| `iterations` | 10 | GEPA optimization iterations |
| `population_size` | 5 | Variants per generation |
| `optimizer_model` | `openai/gpt-4.1` | Model for GEPA mutations — override to your provider |
| `eval_model` | `openai/gpt-4.1-mini` | Model for LLM-as-judge scoring |
| `max_skill_size` | 15,000 | Hard limit on evolved skill size (chars) |
| `eval_dataset_size` | 20 | Total evaluation examples to generate |

### Cost Notes

Default models are OpenAI GPT-4.1 — expensive (~$2-10/run). Replace with cheaper models via OpenRouter:

```bash
# Use DeepSeek V4 Flash instead (~$0.50-2.00/run)
python -m evolution.skills.evolve_skill \
  --skill my-skill \
  --optimizer-model openrouter/deepseek/deepseek-v4-flash \
  --eval-model openrouter/deepseek/deepseek-v4-flash
```

## Architecture

The GEPA pipeline reads execution traces to understand *why* a skill fails (not just that it failed), then proposes targeted text mutations.

```
Skill text → DSPy Module wrapper → GEPA Optimizer → Candidate variants
                ↑                                               │
          Execution traces (from batch_runner)                   ▼
                                                      Constraint gates:
                                                      • Test suite (pytest)
                                                      • Size limits (≤15KB)
                                                      • Semantic preservation
                                                      • Caching compatibility
                                                               │
                                                               ▼
                                                      Best variant → PR
```

### Three Eval Data Sources

| Source | When to Use | How |
|--------|-------------|-----|
| **Synthetic** (default) | No existing test data | LLM reads skill → generates test cases |
| **SessionDB** | Has Hermes session history | Mines `~/.hermes/sessions/` for real usage |
| **Golden** | Hand-curated examples | Loads JSONL from `--dataset-path` |

### Fitness Dimensions (LLM-as-Judge)

| Dimension | Weight | What It Measures |
|-----------|--------|-----------------|
| `correctness` | 50% | Did the agent produce correct output? |
| `procedure_following` | 30% | Did it follow the skill's procedure? |
| `conciseness` | 20% | Appropriately concise? |
| `length_penalty` | — | Penalty for verbosity (subtracted from composite) |

### Guardrails (Constraint Validator)

Every evolved variant must pass ALL of these before it can be deployed:

1. **Size limits** — Skills ≤15KB, tool descriptions ≤500 chars
2. **Growth limit** — ≤20% growth over baseline text
3. **Test suite** — `pytest tests/ -q` must pass 100%
4. **Structural integrity** — YAML frontmatter must be valid, name/description present
5. **PR review** — All changes go through human review (git branch + PR)

## Workflow

### 1. Set Up the Repo

```bash
cd /home/oleg/hermes-agent-self-evolution
export HERMES_AGENT_REPO=/home/oleg/.hermes
```

### 2. Find a Skill to Evolve

```bash
python3 -c "
from evolution.skills.skill_module import find_skill
from pathlib import Path
p = find_skill('my-skill-name', Path('/home/oleg/.hermes'))
print(f'Found: {p}' if p else 'Not found')
"
```

### 3. Run Dry-Run

```bash
python -m evolution.skills.evolve_skill --skill my-skill --dry-run
```

Expected output:
```
🧬 Hermes Agent Self-Evolution — Evolving skill: my-skill
  Loaded: skills/<category>/my-skill/SKILL.md
  Name: my-skill
  Size: N,NNN chars
  Description: ...

DRY RUN — setup validated successfully.
  Would generate eval dataset (source: synthetic)
  Would run GEPA optimization (10 iterations)
  Would validate constraints and create PR
```

### 4. Run Full Evolution

Start with low iterations to test:

```bash
python -m evolution.skills.evolve_skill --skill my-skill --iterations 3
```

### 5. Review Results

- The tool creates a git branch + PR against hermes-agent
- Review the diff: do the changes read sensibly to a human?
- Check before/after metrics (correctness, procedure_following, conciseness)

### GenAI_Agents (NirDiamant/GenAI_Agents) — Evaluation + Guardrails

**Repo:** https://github.com/NirDiamant/GenAI_Agents (MIT, 50+ tutorials)
**Cloned:** `/home/oleg/GenAI_Agents/`
**Key patterns adaptable as Hermes plugins:**
- **Evaluation:** LLM-as-Judge (G-Eval), self-critique loops, regression testing → см. skill `agent-evaluation-framework` (mlops)
- **Guardrails:** Input/output guardrails, topic control, PII filtering → см. skill `agent-guardrails` (mlops)
- **Observability:** Span-based telemetry, LangFuse, drift detection
- **Cost tracking:** Per-request token counters, budget limits
- **CI/CD:** Docker/Kubernetes, secret management, GitOps

**Integration:** Hermes lacks native eval pipeline and guardrails. The two skills above fill this gap — eval feeds into self-evolution, guardrails run as pre/post hooks around LLM calls.

### Open Notebook (RAG-база знаний)

**Repo:** https://github.com/lfnovo/open-notebook (MIT)
**Установлен:** Docker Compose, работает на `http://localhost:5055` (API)
**Использование:** Open Notebook может служить источником eval-данных для self-evolution — загрузи документы, сформируй ноутбук, через API `/api/search` получай чанки для тестовых примеров.
**Интеграция:** skill `open-notebook-rag` (mlops) — поиск+вопрос по базе знаний.

## Complementary External Resources

SKILL.md format (YAML frontmatter + markdown body) is a **cross-ecosystem standard** shared by Hermes Agent, Antigravity Awesome Skills, and Claude Code agents. Ready-made skills from these ecosystems can feed into the evolution pipeline as baselines or inspiration.

### Antigravity Awesome Skills (~1,525 SKILL.md files)

**Repo:** https://github.com/sickn33/antigravity-awesome-skills (MIT, 40k+ stars)
**Format:** Exact same SKILL.md — YAML frontmatter + markdown body. **Directly compatible** with Hermes — no conversion needed.
**Install:** `npx antigravity-awesome-skills` (installs to `~/.agents/skills/`)
**Contents:** Covers dev, test, security, infra, product, marketing, and more.
**Use with evolution:** Use any of these as a baseline skill to evolve — they're plain SKILL.md files ready for GEPA optimization.

### Everything Claude Code (~9 agents, ~11 skill packs)

**Repo:** https://github.com/WorldFlowAI/everything-claude-code (MIT)
**Format:** Markdown with YAML frontmatter (name, description, tools, model). Easily convertible to Hermes SKILL.md.
**Key contents:**
- `agents/` — 9 agents (architect, code-reviewer, planner, tdd-guide, security-reviewer, etc.)
- `skills/` — eval-harness, verification-loop, continuous-learning, tdd-workflow, etc.
- `hooks/` — session persistence & CI scripts
- `mcp-configs/` — reusable MCP server configs

### n8n AI Workflow Templates (~70+ patterns)

**Repo:** https://github.com/n8n-io/n8n-templates
**Format:** JSON workflow graphs (not directly importable as skills)
**Use:** Source of patterns for new skills — support chat, email summarizer, RAG Q&A, multi-agent orchestrator, code reviewer, etc. Logic maps to Hermes: trigger → `@listen_to()`, LLM node → `llm_call()`, memory → `hermes.memory`, conditions → `if/else`.

### Prompty (Microsoft)

**Repo:** https://github.com/microsoft/prompty
**Format:** YAML frontmatter with input/output schemas + template body (`.prompty`)
**Compatibility:** Partial. Prompty is a subset of SKILL.md — convertible with losses (no memory/triggers/cron). Useful for exporting skills to Azure/Microsoft ecosystems.

See `references/external-skill-libraries.md` for detailed research on each resource.

## Cost Optimization

Default models (OpenAI GPT-4.1) cost ~$2-10 per 10-iteration run. Replace with cheaper models via OpenRouter:

```bash
# DeepSeek V4 Flash — ~$0.50-2.00/run
python -m evolution.skills.evolve_skill \
  --skill my-skill \
  --optimizer-model openrouter/deepseek/deepseek-v4-flash \
  --eval-model openrouter/deepseek/deepseek-v4-flash

# Or use --iterations 3 for a light trial run before committing to 10
python -m evolution.skills.evolve_skill \
  --skill my-skill --iterations 3
```

## Pitfalls

- **HERMES_AGENT_REPO must point to a directory with `skills/` subfolder.** When Hermes is installed as a pip package (not git clone), set to `~/.hermes` — skills live at `~/.hermes/skills/`.
- **Default model is OpenAI GPT-4.1.** Replace with your actual provider via `--optimizer-model` and `--eval-model` flags to avoid unexpected costs. DeepSeek V4 Flash via OpenRouter costs ~$0.50-2.00/run instead of $2-10.
- **Test_constraints.py errors are OK.** 16 test errors from `tests/core/test_constraints.py` are benign — they happen when the test can't find the full hermes-agent repo (pip install vs git clone). The 123 passing tests validate the core pipeline.
- **First run warms the cache.** DSPy + GEPA may download model metadata on first invocation.
- **Not a replacement for human review.** All evolved variants must be reviewed before merging — the LLM judge can miss semantic drift.
- **SessionDB mining requires real sessions.** If `~/.hermes/sessions/` is empty, use `--eval-source synthetic` instead.
- **Antigravity Awesome Skills installs to `~/.agents/skills/` by default**, not `~/.hermes/skills/`. Point `HERMES_AGENT_REPO` or symlink the skills dir if you want evolution to find them.  
- **Everything Claude Code agents use Claude Code's format (tools field with model name).** When converting to Hermes, replace `tools:` field with Hermes-equivalent tool references and `model:` with Hermes skill config.
