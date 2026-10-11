# DGX Spark (GB10) Build & Run Guide

Verified on DGX Spark (GB10, aarch64, Ubuntu 24.04, CUDA 13.0), 2026-10-11.

## Build

```bash
export PATH=/usr/local/cuda/bin:$PATH
cmake -B build -DSD_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=121
cmake --build build --config Release -j$(nproc)
```

- GB10 compute capability is **12.1** (sm_121), CUDA toolkit 13.0.
- Builds **zero-patch** on aarch64 — no ARM-specific source changes needed.
- ~3 min on the GB10's 20 cores.

## Run Qwen-Image-2.1 (GGUF, text-to-image)

Download three files (HuggingFace unreachable from some networks; ModelScope mirrors work):

| File | Source |
|---|---|
| `qwen-image-2.1-Q4_K_M.gguf` (4.2 GB, denoiser) | unsloth/Qwen-Image-2.1-GGUF |
| `vae/qwen_image_2.1_vae_bf16.safetensors` | unsloth/Qwen-Image-2.1-FP8 |
| `Qwen3-VL-8B-Instruct-UD-Q4_K_XL.gguf` (6.5 GB, text encoder) | unsloth/Qwen3-VL-8B-Instruct-GGUF |

```bash
./build/bin/sd-cli \
  --diffusion-model qwen-image-2.1-Q4_K_M.gguf \
  --vae qwen_image_2.1_vae_bf16.safetensors \
  --llm Qwen3-VL-8B-Instruct-UD-Q4_K_XL.gguf \
  -p "a cartoon sloth mascot waving, flat vector illustration" \
  --steps 20 --cfg-scale 6.0 --sampling-method euler -W 1024 -H 1024 --diffusion-fa \
  --seed 42 -o out.png
```

Gotchas:
- `--rng-seed` (seen in some upstream README examples) was renamed to **`--seed`**.
- The VAE is **not** interchangeable with older Qwen-Image / Wan 2.2 VAEs.
- Pure text-to-image does not need the mmproj file; image editing does (`--llm_vision`).

## Serve (OpenAI-compatible HTTP)

```bash
./build/bin/sd-server \
  --diffusion-model qwen-image-2.1-Q4_K_M.gguf \
  --vae qwen_image_2.1_vae_bf16.safetensors \
  --llm Qwen3-VL-8B-Instruct-UD-Q4_K_XL.gguf \
  --listen-ip 127.0.0.1 --listen-port 8189
```

`POST /v1/images/generations` with `{"prompt": "...", "size": "1024x1024", "n": 1}`
returns `{data: [{b64_json: ...}]}`.

## Measured performance (GB10, 128 GB unified memory)

- 1024x1024, 20 steps: sampling 116 s (~5.8 s/step), VAE decode 11.6 s, end-to-end 128.7 s
- Coexists with a 55 GB GPU-resident LLM expert cache without OOM

Helper scripts: see `deploy/dgx-spark/`.
