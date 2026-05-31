---
name: linux-system-diagnostics
description: "Probe Linux system health — CPU model/load, RAM usage, disk space, temperature, top processes, uptime. Answer 'what's going on with my computer' requests."
version: 1.0.0
author: agent
created_by: agent
---

# Linux System Diagnostics

Use when the user asks about system health, performance, resource usage, temperature, or "всё ли в порядке с компьютером".

## Quick Diagnostic Command

Run all probes in a single terminal call:

```bash
echo "=== CPU ==="
cat /proc/cpuinfo | grep "model name" | head -1
nproc
echo ""
echo "=== LOAD ==="
uptime
cat /proc/loadavg
echo ""
echo "=== MEMORY ==="
free -h
echo ""
echo "=== DISKS ==="
df -h / /home 2>/dev/null
echo ""
echo "=== TEMP ==="
cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null || echo "sensors not available"
echo ""
echo "=== TOP 5 CPU PROCESSES ==="
ps aux --sort=-%cpu | head -6
echo ""
echo "=== TOP 5 MEM PROCESSES ==="
ps aux --sort=-%mem | head -6
echo ""
echo "=== SWAP ==="
swapon --show 2>/dev/null
free -h | grep -i swap
```

## Interpretation Guide

### CPU
- **Load average** (3 values: 1m, 5m, 15m): values < nproc = healthy. ~0 = idle.
- **Temperature** from `/sys/class/thermal/thermal_zone*/temp`: values in millidegrees Celsius. Divide by 1000. 30-50°C idle is normal. >85°C under load is concerning.

### Memory
- **Free -h output:** `total` vs `available` is the important comparison. `available` includes reclaimable cache.
- **Swap:** should be 0 used on a system with enough RAM. Non-zero swap usage indicates memory pressure.

### Disk
- **Usage %:** >85% warrants attention. >95% is critical.

### Processes
- Top CPU + MEM consumers reveal what's actually running.
- Watch for: stale Node.js processes, memory leaks, orphaned Python/Node children.

## When to Deliver as Voice Reply

If the user sent a voice message (STT transcription has `the user sent a voice message` prefix), reply with a TTS voice message. Keep the summary conversational:

- CPU: model, cores, load (idle/light/moderate/heavy), temperature
- RAM: total, used %, available
- Disk: total, used %
- Notable processes: the top 2-3 consumers
- Verdict: "всё в порядке" / "есть вопросы"

## Pitfalls

- **`sensors` command** (`lm-sensors`) is often not installed. Prefer `/sys/class/thermal/thermal_zone*/temp`.
- **`ps aux` sorting** — `--sort=-%cpu` and `--sort=-%mem` flags use `-` for descending. Without the minus, sort is ascending.
- **Multiple thermal zones** — a laptop may have 6+ zones (CPU cores, GPU, battery). The highest is the relevant one.
- **Disk paths differ** — check both `/` and `/home` separately. On single-partition setups they're the same.
- **Kernel caches** — `free -h` shows cached/buffered memory separately. Linux uses free RAM for disk cache aggressively; this is normal.
