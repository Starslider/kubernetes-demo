# Muse Glimmer 30B + DFlash on RTX 3090

## Why llama.cpp (not vLLM) on this node

| Constraint | Impact |
|------------|--------|
| `gpu-worker-3090` is **WSL2** | vLLM V1 crashes: **`UVA is not available`** |
| RTX 3090 **24GB** | BF16 Muse (~60GB) cannot load in vLLM |
| Host RAM ~**10Gi** | Heavy HF init downloads get **OOMKilled** |

Working path used by the community on a single 3090:

**llama.cpp `llama-server` + official GGUF kquant-17gb + DFlash draft**

Still exposes an **OpenAI-compatible** API on `http://192.168.1.150:8000/v1`.

## Models (cached on node)

| File | Role |
|------|------|
| `muse-glimmer-30B-kquant-17gb.gguf` | Main model (~17GB) |
| `dflash-kquant.gguf` | DFlash speculative draft |
| `mmproj-kquant.gguf` | Vision projector |

Source: `meta-models/Muse-Glimmer-30B-GGUF`  
Disk: `/var/lib/vllm/gguf-models` on the GPU node

## Caching strategy

1. **Disk** — GGUF files on hostPath (no re-download after first pull)
2. **GPU residency** — all layers + draft on GPU (`-ngl 99`, `-ngld 99`)
3. **Warmup CronJob** — `/health` + short chat every 10 minutes
4. **Continuous batching** — `--cont-batching` for multi-turn agent prompts

## API

```bash
curl http://192.168.1.150:8000/v1/models
curl http://192.168.1.150:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "muse-glimmer",
    "messages": [{"role":"user","content":"Hello"}],
    "temperature": 1.0,
    "top_p": 0.95
  }'
```

## Open WebUI

`OPENAI_API_BASE_URLS=http://192.168.1.150:8000/v1`  
`DEFAULT_MODELS=muse-glimmer`
