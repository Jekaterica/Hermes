# Digital Twin — Weekly Backup State

## Cron Jobs
| ID | Name | Schedule | Status |
|----|------|----------|--------|
| `89289c218d22` | hermes-weekly-backup | Mon 3:00 | ✅ Active |
| ~~`162b6c98adbd`~~ | ~~skills-nightly-commit~~ | ~~Daily 3:00~~ | ❌ Removed |

## Scripts in `~/.hermes/scripts/`
| Script | Status | Purpose |
|--------|--------|---------|
| `hermes-backup-weekly.sh` | ✅ Active | Weekly snapshot (skills + vault + config + secrets) |
| `encrypt-secrets.sh` | ✅ Active | Encrypts `.env` into `secrets.tar.gz.enc` (reads `SECRETS_PASSWORD` from `.env`) |
| `skills-nightly.sh` | ❌ Deleted | Replaced by weekly |

## What gets backed up (Mon 3:00)
- `skills/` — 20 core skills
- `vault/` — 25 domain skills (copied from `~/.hermes/skills-vault/`)
- `hermes-config/` — SOUL.md, USER.md, HERMES.md, cim-summary.md, strategic-context.md, config.yaml
- `hermes-config/scripts/` — all `*.sh` from `~/.hermes/scripts/`
- `hermes-secrets/secrets.tar.gz.enc` — encrypted `.env` (AES-256-CBC)

## Secrets in the encrypted archive
- `EXA_API_KEY`
- `GITHUB_TOKEN`
- `SECRETS_PASSWORD`

## Recovery from scratch
```bash
git clone git@github.com:Jekaterica/Hermes.git ~/.hermes/skills
cp ~/.hermes/skills/hermes-config/* ~/.hermes/
source ~/.hermes/.env 2>/dev/null
openssl enc -d -aes-256-cbc -pbkdf2 \
  -in ~/.hermes/skills/hermes-secrets/secrets.tar.gz.enc \
  -pass pass:"$SECRETS_PASSWORD" | tar xzf - -C ~/.hermes/
hermes
```
