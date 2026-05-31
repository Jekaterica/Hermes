---
name: hermes-tts-language-config
description: "Configure Hermes TTS for non-English languages — list available voices, select the right one, verify output."
version: 1.0.0
author: agent
created_by: agent
---

# Hermes TTS — Language & Voice Configuration

Use this skill when the user asks to set up TTS for a specific language (Russian, German, French, etc.) or when TTS output is in the wrong language.

## Problem

Edge TTS (default, free) uses `en-US-AriaNeural` as the default voice. For non-English text it either fails silently or produces accented English.

## Solution

1. **Check available voices** for the target language:

```bash
python3 -c "
import edge_tts, asyncio
async def main():
    voices = await edge_tts.list_voices()
    target = [v for v in voices if 'ru' in v.get('Locale','').lower()]
    for v in target:
        print(f\"{v['ShortName']} | {v['Locale']} | {v['Gender']}\")
asyncio.run(main())
```

Replace `'ru'` with the two-letter ISO code for the target language (`'de'`, `'fr'`, `'es'`, etc.).

2. **Set the voice** in `~/.hermes/config.yaml` via CLI:

```bash
hermes config set tts.edge.voice ru-RU-DmitryNeural
```

Replace `ru-RU-DmitryNeural` with the chosen `ShortName`.

3. **Verify** directly via edge-tts:

```bash
python3 -c "
import edge_tts, asyncio
async def main():
    tts = edge_tts.Communicate('Тестовое сообщение', voice='ru-RU-DmitryNeural')
    await tts.save('/tmp/test_tts.ogg')
    print('OK')
asyncio.run(main())
"
```

4. **Test via Hermes** — call `text_to_speech` with Russian text.

### Female Voices

If available, offer a female alternative. For Russian: `ru-RU-SvetlanaNeural`.

### Other Providers (non-edge)

For ElevenLabs / OpenAI TTS: voice is set in config under the respective provider section (`tts.elevenlabs.voice_id`, `tts.openai.voice`). Voice IDs differ per provider — consult provider docs.

## Pitfalls

- **Edge TTS doesn't fail on wrong-language text** — it just sounds terrible. Always verify by ear or by checking that the user confirms it's correct.
- **Config changes require `/reset` or gateway restart** — the TTS provider reads config at session start. In gateway mode: `/restart`.
- **The voice parameter in config.yaml is `tts.edge.voice`**, not `tts.voice` or a top-level key.
- **Edge TTS is rate-limited** at ~5000 chars per request. Long text is truncated by Hermes automatically.
- **Default voice is hardcoded** as `en-US-AriaNeural` in `tools/tts_tool.py` line 156 — user config overrides it.
