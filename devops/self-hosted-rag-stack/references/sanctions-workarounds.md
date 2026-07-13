# Sanctions Workarounds for Container/Package Registries

When operating from regions with restricted access (e.g., Crimea), several common registries are blocked. This reference documents proven workarounds.

## GitHub Container Registry (ghcr.io)

**Blocked**: `ghcr.io` — connection timeout on any operation.

**Workaround**: Use Docker Hub equivalents where available.

| Image | GHCR (blocked) | Docker Hub (works) |
|-------|---------------|-------------------|
| Open WebUI | `ghcr.io/open-webui/open-webui:main` | `openwebui/open-webui:latest` |
| cloudflared | `ghcr.io/cloudflare/cloudflared` | `cloudflare/cloudflared` (test) |

**Pro tip**: Docker Hub often uses different tags. Always check with:
```bash
curl -s "https://hub.docker.com/v2/repositories/openwebui/open-webui/tags?page_size=30" | python3 -c "import json,sys; [print(r['name']) for r in json.load(sys.stdin)['results']]"
```

## HuggingFace Hub (huggingface.co)

**Blocked**: HF Hub may be unreachable, causing embedding model downloads to hang at 0%.

**Workaround**: Set `HF_ENDPOINT` to the Chinese mirror.

```bash
# Docker env or ~/.bashrc
export HF_ENDPOINT=https://hf-mirror.com
```

The mirror is fully compatible — same model files, same API.

## Docker Hub Proxy

For images only on ghcr.io, try a Docker Hub proxy:
- `ghcr.dockerproxy.com/<org>/<image>:<tag>` — experimental, not always reliable

## Cloudflare Tunnel (port 7844)

**May also be blocked**: Cloudflare's `cloudflared` tunnel uses QUIC on port 7844 and TCP fallback on the same port. Under certain blocking regimes, both are unreachable:

```
UDP Connectivity  → FAIL (QUIC connection failed)
TCP Connectivity  → FAIL (HTTP/2 connection is blocked or unreachable)
```

**Workaround**: Use SSH-based tunnels instead — they run over port 22 which is rarely blocked.

| Tunnel | Method | Auth | Status |
|--------|--------|------|--------|
| localhost.run | SSH -R | SSH key or anonymous | ✅ Works |
| localtunnel | npx localtunnel | None | ✅ Works |
| serveo.net | SSH -R | keyboard-interactive | ✅ Works |
| Cloudflare Tunnel | cloudflared | OAuth+domain | ❌ Port 7844 blocked |
| ngrok | ngrok binary | Account+authtoken | ⚠️ Needs registration |

## General Pattern

1. Identify the blocked registry URL
2. Search Docker Hub for an equivalent image name
3. If not on Docker Hub, search for existing mirrors (e.g., `backplane/open-webui` was a mirror until official Docker Hub publishing started)
4. For ML models, set `HF_ENDPOINT` to the Chinese mirror
5. For pip packages, use `mirrors.tuna.tsinghua.edu.cn` or local PyPI mirror
