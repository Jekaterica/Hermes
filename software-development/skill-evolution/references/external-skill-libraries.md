# External Skill Libraries — Cross-Ecosystem SKILL.md Sources

Research conducted June 2026. Most of these use the same **YAML frontmatter + markdown body** format as Hermes Agent SKILL.md, making them directly compatible or trivially convertible.

## 1. Antigravity Awesome Skills (Priority: HIGH)

**URL:** https://github.com/sickn33/antigravity-awesome-skills
**Version:** V12.2.1 (June 2026)
**Size:** 1,525+ SKILL.md files, 40k+ GitHub stars
**License:** MIT
**Install:** `npx antigravity-awesome-skills` (default: `~/.agents/skills/`)

### Format Compatibility

```
SKILL.md:
---
name: github
description: "Use the `gh` CLI for issues, pull requests, Actions runs..."
risk: safe
source: "Dimillian/Skills (MIT)"
date_added: "2026-03-25"
---

# GitHub Skill
Body text with instructions, tool usage examples, and conventions...
```

**Identical format to Hermes.** The frontmatter has extra fields (risk, source, date_added) that Hermes ignores gracefully. Skills can be copied directly into `~/.hermes/skills/<category>/<name>/SKILL.md`.

### Coverage Areas

- Development (GitHub, Git, CI/CD, Docker, Kubernetes)
- Testing and QA (accessibility, security scanning, load testing)
- Infrastructure (Terraform, AWS, GCP, Cloudflare)
- Product & Marketing (analytics, social media, content generation)
- Database & Backend (SQL, PostgreSQL, Redis, API design)
- Frontend & UI (React, CSS, accessibility, responsive design)

### Using with Evolution

```bash
# 1. Install alongside Hermes
npx antigravity-awesome-skills --path /home/oleg/antigravity-skills

# 2. Point evolution at it
HERMES_AGENT_REPO=/home/oleg/antigravity-skills \
  python -m evolution.skills.evolve_skill --skill github --iterations 5

# 3. Or symlink directly into Hermes skills
ln -s /home/oleg/antigravity-skills/skills/github /home/oleg/.hermes/skills/antigravity/github
```

## 2. Everything Claude Code (Priority: HIGH)

**URL:** https://github.com/WorldFlowAI/everything-claude-code
**License:** MIT
**Contents:** 9 agents, 11 skill packs, hooks, rules, MCP configs
**Also available:** `xu-xiang/everything-claude-code-zh` (Chinese translation)

### Agent Format

```markdown
---
name: code-reviewer
description: Expert code review specialist...
tools: Read, Grep, Glob, Bash
model: opus
---

Body with instructions, checklist, and workflow steps.
```

### Conversion to Hermes

Claude Code agents convert to Hermes skills with minimal changes:
- `tools:` field → Hermes tool references (map tool names)
- `model:` → remove (Hermes uses session model)
- Body → body of SKILL.md (already markdown)
- Add Hermes frontmatter fields (version, author, license, metadata)

### Most Valuable Agents/Skills for Evolution

| Agent/Skill | Why | Conversion | 
|-------------|-----|------------|
| `eval-harness` | Verification/evaluation pipeline — complements self-evolution | Direct — markdown body |
| `verification-loop` | Checkpoint vs continuous eval strategies | Direct |
| `continuous-learning` | Auto-extract patterns from sessions | Direct |
| `tdd-workflow` | Test-driven development procedure | Direct |
| `code-reviewer` | General-purpose code review skill | Needs tools mapping |
| `planner` | Architecture planning agent | Direct |

## 3. n8n AI Workflow Templates (Priority: MEDIUM)

**URL:** https://github.com/n8n-io/n8n-templates
**License:** Sustainable Use License (free for self-hosting)
**Format:** JSON workflow graphs (nodes + edges), not SKILL.md

### Pattern Mapping to Hermes Skills

| n8n Pattern | Hermes Equivalent |
|-------------|-------------------|
| Trigger (webhook, cron, email) | `@listen_to()`, `cron` |
| LLM Node (OpenAI, Claude) | `llm_call()` |
| Memory / Vector Store | `hermes.memory` |
| Tool Node (HTTP, DB, Code) | Python function / built-in tool |
| Condition / Switch | `if` / `match` |
| AI Agent Node (ReAct) | Loop with `llm_call()` + tool processing |
| Sub-workflow | Cross-skill call via skills API |

### Notable AI Templates (70+)

- AI Agent: Support Chat — customer support agent
- AI Agent: Email Summarizer — digest incoming mail
- AI Agent: Web Scraper with GPT — extract + process web data
- AI Agent: Slack Assistant — AI-powered Slack responses
- AI Agent: Code Reviewer — automated PR reviews
- AI Agent: RAG Q&A Bot (PDF) — document Q&A with RAG
- AI Agent: Multi-Agent Orchestrator — orchestrate multiple agents
- AI Agent: Customer Feedback Analyzer — sentiment analysis
- AI Agent: SQL Query Builder — natural language to SQL

## 4. Prompty (Microsoft) (Priority: LOW — for client export)

**URL:** https://github.com/microsoft/prompty
**License:** MIT
**Format:** `.prompty` — YAML frontmatter (name, model, inputs schema, outputs schema) + template body

### Conversion Assessment

```
SKILL.md → Prompty:  Can extract system prompt + input schema.
                     Loses: memory, triggers, cron, tools, multi-message roles.
                     Model/params must be manually supplied.

Prompty → SKILL.md:  Can embed prompt body + input/output schemas.
                     Loses: nothing, but gains no Hermes-specific features.
                     Result: basic skill with no triggers/memory/tools.
```

Useful when a client requires Microsoft/Azure-compatible prompt format.

## 5. Skills.sh (Vercel) (Priority: LOW)

**URL:** https://skills.sh
**Format:** JSON with HTTP endpoint (not directly importable)

Skills.sh skills are remote HTTP-callable, not local Python. Requires a wrapper plugin in Hermes to bridge.

## 6. Awesome AI Agent Skills (Priority: MEDIUM)

**URL:** https://github.com/meow-org/awesome-ai-agent-skills
**Size:** 253+ skills in markdown
**Format:** Separate markdown files per skill with YAML frontmatter (name, description, instructions, tools, tags)

Can be converted with a simple Python script (~50 lines): parse YAML frontmatter, extract body, write to `~/.hermes/skills/<category>/<name>/SKILL.md`.

## 7. Addy Osmani's Agent Skills (Priority: MEDIUM)

**URL:** https://github.com/addyosmani/agent-skills
**Size:** 7 slash commands, production-grade engineering skills
**Format:** SKILL.md directories (api-and-interface-design, code-review-and-quality, tdd-workflow, etc.)
**Install for Claude Code:** `/plugin marketplace add addyosmani/agent-skills`

Skills are quality-focused (spec before code, code simplification, ship to production). Useful as high-quality baseline for evolution.

## Resource Evaluation Criteria

When evaluating external skill sources for import to Hermes, use these dimensions:

| Criteria | Weight | Why |
|----------|--------|-----|
| **Format compatibility** | High | SKILL.md (YAML+markdown) = direct import. Other formats need conversion or are unmappable |
| **Skill count** | Medium | More skills = broader search surface, but higher selection cost |
| **Quality (size + depth)** | High | Skills ≥8KB usually have real substance. <2KB is often boilerplate |
| **Relevance to current use** | High | For Oleg: priority to business-agent skills (CRM, support, chat) and self-evolution (eval, testing) |
| **License** | Medium | MIT/Apache = safe. AGPL = code evolution only via external CLI |
| **Active maintenance** | Low | Date of last commit, star count, issue activity |

### Selection Process (from 1525 Antigravity skills)

1. `ls -d skills/*/` → grep for keywords matching target class (eval, debug, agent, memory, plan, etc.)
2. For each match: check `wc -c SKILL.md` + read description from frontmatter
3. Prioritize: 8-37KB range (deep content > boilerplate)
4. Open top candidates and read the body — does it teach something new or just restate common knowledge?
5. Copy to `~/.hermes/skills/<category>/<name>/` if it adds value

### Claude Code Agent → Hermes SKILL.md Conversion

```python
import os, pathlib

agents = {
    "architect": {"desc": "Software architecture specialist — system design, scalability, technical decisions.", "cat": "software-development"},
    "planner":  {"desc": "Expert planning specialist — create detailed implementation plans, break down complex features.",    "cat": "software-development"},
    "code-reviewer": {"desc": "Expert code review specialist — quality, security, maintainability.", "cat": "software-development"},
    "tdd-guide": {"desc": "Test-Driven Development specialist — enforce RED-GREEN-REFACTOR.", "cat": "software-development"},
    "security-reviewer": {"desc": "Security review specialist — vulnerability assessment, OWASP.", "cat": "software-development"},
}

for name, info in agents.items():
    src = f"/home/oleg/everything-claude-code/agents/{name}.md"
    content = pathlib.Path(src).read_text()
    
    hermes = f"""---
name: {name}
description: {info['desc']}
---

{content}
"""
    dest = pathlib.Path(f"/home/oleg/.hermes/skills/{info['cat']}/{name}/SKILL.md")
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(hermes)
```

Key changes during conversion:
- Remove `tools:` and `model:` fields from Claude Code frontmatter (Hermes doesn't use them — model is set per session, tools are inherited)
- Body stays as-is — Claude Code agent bodies are already high-quality markdown instructions
- `eval-harness` and `continuous-learning` from `skills/` directory are converted the same way (they already use SKILL.md format)

## Local Installation Paths (June 2026)

After evaluating all resources, these were installed:

| Resource | Path | When to Use |
|----------|------|-------------|
| Antigravity Awesome Skills | `/home/oleg/antigravity-skills/` | Browse 1525 SKILL.md for any domain |
| Everything Claude Code | `/home/oleg/everything-claude-code/` | Agents (architect, planner) + eval-harness + continuous-learning |
| hermes-agent-self-evolution | `/home/oleg/hermes-agent-self-evolution/` | Run GEPA optimization on any skill |

### Actually Imported Skills

From Antigravity:
- `agent-evaluation` (37KB) → software-development — testing/benchmarking LLM agents
- `agent-memory-systems` (31KB) → software-development — memory architecture patterns
- `autonomous-agent-patterns` (23KB) → software-development — design patterns for agents
- `architecture-decision-records` (13KB) → software-development — ADRs
- `code-review-excellence` (1.7KB) → software-development — constructive code review
- `ask-questions-if-underspecified` (4.3KB) → software-development — requirement clarity
- `customer-support` (8.9KB) → business — AI support agent
- `chat-widget` (27KB) → business — real-time support chat with widget
- `business-analyst` (8.1KB) → business — analytics, KPI, dashboards
- `helpdesk-automation` (6.3KB) → business — ticket management
- `sales-automator` (1.8KB) → business — cold emails, proposals
- `odoo-sales-crm-expert` (4.4KB) → business — Odoo CRM pipeline
- `global-chat-agent-discovery` (4.4KB) → business — MCP/agent discovery

From Everything Claude Code (converted):
- `architect` (6.5KB) → software-development — architecture specialist
- `planner` (3.4KB) → software-development — implementation planning
- `code-reviewer` (3.0KB) → software-development — code review specialist
- `tdd-guide` (7.2KB) → software-development — TDD RED-GREEN-REFACTOR
- `security-reviewer` (14.4KB) → software-development — OWASP, dependency audit
- `eval-harness` (5.2KB) → mlops — eval-driven development framework
- `continuous-learning` (2.2KB) → mlops — pattern extraction from sessions

## General Installation Pattern

```bash
# Install an external skill library
git clone <repo> /home/oleg/external-skills/<name>
# Or npx for Antigravity
npx antigravity-awesome-skills --path /home/oleg/external-skills/antigravity

# Point evolution at external library
HERMES_AGENT_REPO=/home/oleg/external-skills/antigravity \
  python -m evolution.skills.evolve_skill --skill <name> --iterations 5

# Or import specific skills into Hermes
cp -r /home/oleg/external-skills/antigravity/skills/github /home/oleg/.hermes/skills/github/
```
