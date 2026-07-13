# hermes-agent-self-evolution Setup

**Repo:** NousResearch/hermes-agent-self-evolution (MIT)
**Installed at:** `/home/oleg/hermes-agent-self-evolution/`
**Dependencies installed:** dspy 3.2.1, gepa 0.0.27, litellm 1.88.0

## Key Finding: HERMES_AGENT_REPO

Hermes Agent is installed as a pip package (not git clone), so skills are at `~/.hermes/skills/`. The evolution tool expects `HERMES_AGENT_REPO` to point to a directory containing a `skills/` subfolder.

```bash
export HERMES_AGENT_REPO=/home/oleg/.hermes
```

This works because `find_skill()` in `skill_module.py` does `hermes_agent_path / "skills"` → rglob for `SKILL.md`.

## Installation Log

```bash
git clone https://github.com/NousResearch/hermes-agent-self-evolution.git
cd hermes-agent-self-evolution
pip install -e ".[dev]"
```

Installed in current venv alongside Hermes. No conflicts.

## Dry-Run Verification

Tested with `systematic-debugging` skill (10,442 chars):

```bash
HERMES_AGENT_REPO=/home/oleg/.hermes \
  python -m evolution.skills.evolve_skill \
  --skill systematic-debugging --dry-run
```

Output: ✅ Found skill, validated all setup, zero API calls.

## Test Suite

```bash
python -m pytest tests/ -q --tb=short
```

- **123 passed** — core pipeline, dataset builder, skill module
- **16 errors** — from `test_constraints.py` (expects full hermes-agent repo, inconsequential)

## Cost Profile

| Model | ~Cost per 10-iteration run | Notes |
|-------|---------------------------|-------|
| GPT-4.1 (default) | $2-10 | OpenAI — set as default in config.py |
| DeepSeek V4 Flash | $0.50-2.00 | Via OpenRouter, user's current model |

Override with: `--optimizer-model openrouter/deepseek/deepseek-v4-flash --eval-model openrouter/deepseek/deepseek-v4-flash`

## Skills Already Installed (for quick reference)

Skills available in ~/.hermes/skills/ include: `systematic-debugging`, `business-agent-architect`, `dspy`, `hermes-agent`, and others in `mlops/`, `software-development/`, `autonomous-ai-agents/` categories.
