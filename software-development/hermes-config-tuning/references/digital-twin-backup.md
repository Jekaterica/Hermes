# Digital Twin Backup (Weekly Snapshot)

Implemented 2026-06-19. Cron job `89289c218d22`, runs Monday 3:00.

## File layout in repo (`Jekaterica/Hermes`)

```
hermes-config/
├── SOUL.md                 # identity + principles
├── USER.md                 # user profile + cognitive traps
├── HERMES.md               # operational framework
├── cim-summary.md          # CIM v3.6
├── strategic-context.md    # active projects, decisions
├── config.yaml             # model, toolsets, security, approvals
└── scripts/
    └── hermes-backup-weekly.sh  # weekly: everything (config + vault + scripts)
    └── encrypt-secrets.sh       # secrets encryption utility

hermes-secrets/
└── secrets.tar.gz.enc     # AES-256 encrypted .env dump (Exa + GITHUB_TOKEN)

skills/                      # core skills (20)
vault/                       # domain skills (25) — copied from skills-vault/ by weekly script
```

## Encryption

Password stored in agent memory, not in repo.

### Encrypt
```bash
tar czf - -C ~/.hermes .env | \
  openssl enc -aes-256-cbc -salt -pbkdf2 -pass pass:"PASSWORD" \
  -out ~/.hermes/skills/hermes-secrets/secrets.tar.gz.enc
```

### Decrypt (on recovery)
```bash
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"PASSWORD" \
  -in ~/.hermes/skills/hermes-secrets/secrets.tar.gz.enc | tar xzf - -C ~/.hermes/
```

## Cron jobs

Only one job — everything in one weekly snapshot (skills + vault + config + scripts + secrets).

| Job | ID | Schedule | Script | What |
|-----|----|----------|--------|------|
| hermes-weekly | 89289c218d22 | Monday 3:00 | hermes-backup-weekly.sh | skills/ + vault/ + config + scripts + 🔐 secrets |

`no_agent: true` (shell script, no LLM cost). Daily cron was removed 2026-06-19 — unified into weekly.

## Recovery procedure

```bash
git clone git@github.com:Jekaterica/Hermes.git ~/.hermes/skills
cp -r ~/.hermes/skills/hermes-config/* ~/.hermes/
cp -r ~/.hermes/skills/vault/* ~/.hermes/skills-vault/
openssl enc -d -aes-256-cbc -pbkdf2 -pass pass:"PASSWORD" \
  -in ~/.hermes/skills/hermes-secrets/secrets.tar.gz.enc | tar xzf - -C ~/.hermes/
hermes
```
