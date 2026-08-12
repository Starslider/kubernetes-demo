# vLLM · Muse Glimmer 30B + DFlash (gpu-worker-3090)

Replaces the Ollama operator stack on the RTX 3090.

## Stack

| Component | Value |
|-----------|--------|
| Image | `vllm/vllm-openai:muse-glimmer` |
| Target | `meta-models/Muse-Glimmer-30B` |
| Draft (DFlash) | `meta-models/Muse-Glimmer-30B-assistant` |
| Endpoint | `http://192.168.1.150:8000/v1` (hostNetwork) |
| Model name | `muse-glimmer` |

## Caching strategy

1. **Disk / HF hub cache** — `hostPath` `/var/lib/vllm/hf-cache` on the GPU node  
   Models are downloaded once by the init container; restarts do not re-pull.
2. **Prefix caching** — `--enable-prefix-caching` (shared system prompts / agent scaffolds).
3. **Warmup CronJob** — every 10 minutes hits `/health`, `/v1/models`, and a tiny chat  
   so the model stays loaded and common prefixes stay warm.
4. **Speculative DFlash** — draft head proposes 15-token blocks; target verifies in parallel.

## OpenAI API

```bash
curl http://192.168.1.150:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "muse-glimmer",
    "messages": [
      {"role": "system", "content": "Reasoning strength: medium"},
      {"role": "user", "content": "Hello"}
    ],
    "temperature": 1.0,
    "top_p": 0.95
  }'
```

## Open WebUI

Points at `OPENAI_API_BASE_URLS=http://192.168.1.150:8000/v1`  
Default model: `muse-glimmer`.

## 3090 notes

- Full BF16 weights are ~60GB; a single 24GB 3090 cannot hold them at full precision.
- This chart uses reduced `max-model-len` (8k) and high GPU util for the day-0 image.
- If the pod OOMs, switch `MODEL_ID` in the ConfigMap to a compressed HF checkpoint
  that vLLM can load on Ampere (or lower `MAX_MODEL_LEN` / disable multimodal).
- Official K-quant ~17GB is primarily for llama.cpp; vLLM day-0 path is the muse-glimmer image.

## Ops

```bash
kubectl -n vllm logs -f deploy/vllm-muse-glimmer
kubectl -n vllm get pods,svc,cronjob
curl -s http://192.168.1.150:8000/v1/models
```
