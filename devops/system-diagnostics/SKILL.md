---
name: system-diagnostics
description: "Comprehensive system health checks — CPU, memory, disk, temperature, processes, and network diagnostics for Linux hosts."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [system, diagnostics, health-check, monitoring, linux]
---

# System Diagnostics

Run when the user asks about system health, performance, temperature, or "как там мой компьютер".

## Quick Health Check

Single command — covers all essentials:

```bash
echo "=== CPU ===" && cat /proc/cpuinfo | grep "model name" | head -1 && nproc && \
echo "=== LOAD ===" && uptime && cat /proc/loadavg && \
echo "=== MEMORY ===" && free -h && \
echo "=== DISKS ===" && df -h / /home 2>/dev/null && \
echo "=== TEMP ===" && cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null || echo "sensors not available" && \
echo "=== TOP 5 CPU ===" && ps aux --sort=-%cpu | head -6 && \
echo "=== TOP 5 MEM ===" && ps aux --sort=-%mem | head -6
```

## Components to Check

### CPU
- Model: `cat /proc/cpuinfo | grep "model name" | head -1`
- Cores/threads: `nproc`
- Load: `uptime` and `/proc/loadavg`
- Per-process: `ps aux --sort=-%cpu | head -N`

### Memory
- Total/used/available: `free -h`
- Swap: `swapon --show` and `free -h | grep -i swap`
- Top consumers: `ps aux --sort=-%mem | head -N`

### Disk
- Usage: `df -h / /home` (add other mount points as needed)
- NVMe/SSD check: check for `nvme` in `df -h` output

### Temperature
- Linux thermal zones: `cat /sys/class/thermal/thermal_zone*/temp`
  - Values are in millidegrees Celsius (divide by 1000)
  - Example: `34000` = 34°C
- Alternative: `sensors` command (requires `lm-sensors` package)

### Network (optional)
- Check for listening services: `ss -tlnp`
- Check for established connections: `ss -tunp`

## Voice Reply Mode

If the user sent a voice message (STT transcription has `the user sent a voice message` prefix), reply with a TTS voice message. Keep the summary conversational:

- CPU: model, cores, load (idle/light/moderate/heavy), temperature
- RAM: total, used %, available
- Disk: total, used %
- Notable processes: the top 2-3 consumers
- Verdict: "всё в порядке" / "есть вопросы"

## Pitfalls

- **Temperature zones**: multiple zones exist; the relevant one is usually `thermal_zone0` or the one with `x86_pkg_temp` type. Check `cat /sys/class/thermal/thermal_zone*/type` to identify.
- **Load average interpretation**: load average = sum of running + waiting threads. On an N-core system, load < N means idle. Values above N mean saturation.
- **`free -h` column meanings**: «занят» = used - buffers/cache. «доступно» = available for new processes. Use «доступно» for the real free memory.
- **Swap usage**: zero swap usage on a system with swap configured means plenty of RAM. Non-zero swap suggests memory pressure.
- **Response format**: present findings concisely — user (Олег) prefers cold analytics, no motivational fluff. Russian language.
