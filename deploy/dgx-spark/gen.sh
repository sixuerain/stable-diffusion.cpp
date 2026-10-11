#!/bin/bash
# Qwen-Image-2.1 GGUF text-to-image via sd-cli
# Models (ModelScope): unsloth/Qwen-Image-2.1-GGUF, unsloth/Qwen-Image-2.1-FP8 (vae/),
# unsloth/Qwen3-VL-8B-Instruct-GGUF
set -euo pipefail
M="$HOME/sd-data/models"
cd "$(dirname "$0")/../../build/bin"
exec ./sd-cli \
  --diffusion-model "$M/qwen-image-2.1-Q4_K_M.gguf" \
  --vae "$M/vae/qwen_image_2.1_vae_bf16.safetensors" \
  --llm "$M/Qwen3-VL-8B-Instruct-UD-Q4_K_XL.gguf" \
  -p "${1:?usage: gen.sh <prompt>}" \
  --steps 20 --cfg-scale 6.0 --sampling-method euler -W 1024 -H 1024 --diffusion-fa \
  --seed 42 -o "${2:-$HOME/sd-data/out.png}"
