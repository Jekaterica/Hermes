# SSH Tunnel Setup for Remote Access

When a service runs on a local/home PC (behind NAT), use SSH tunnels to expose it publicly.

## Quick Reference

| Service | Command | Output |
|---------|---------|--------|
| localhost.run | `ssh -R 80:localhost:3000 localhost.run` | `https://<hash>.lhr.life` |
| serveo.net | `ssh -R 80:localhost:3000 serveo.net` | `https://<name>.serveo.net` |

## Verified: localhost.run (recommended)

**Requirements**: SSH key (any type works).

```bash
# Generate key if none exists
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

# Start tunnel (keep running)
ssh -o StrictHostKeyChecking=accept-new \
    -o ServerAliveInterval=30 \
    -o ExitOnForwardFailure=yes \
    -R 80:localhost:PORT localhost.run
```

Output includes: `https://<random>.lhr.life tunneled with tls termination`

**Pitfalls**:
- Tunnel URL changes on each restart (for permanent URL, register account and add SSH key)
- Connection may drop — `ServerAliveInterval=30` keeps it alive
- Port 3000 assumed — change `80:localhost:PORT` as needed
- Set up as systemd service or cron @reboot for persistence

## Background Process Pattern

In Hermes sessions, always run tunnels with:
```
terminal(background=true, command="ssh -R 80:localhost:PORT localhost.run", notify_on_complete=false)
```

Retrieve URL by checking `process(action='log', session_id='...')` after ~10s.

## Why Not Alternatives

| Service | Issue |
|---------|-------|
| ngrok | Requires account registration + authtoken (`ERR_NGROK_4018` without) |
| serveo.net | SSH may hang on publickey auth when no agent keys match |
| Cloudflare Tunnel | Requires domain + OAuth browser flow — hard on headless server |
