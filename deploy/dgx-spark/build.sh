#!/bin/bash
# DGX Spark (GB10, aarch64, CUDA 13.0) build for stable-diffusion.cpp
# Verified on Ubuntu 24.04 aarch64, cuda-toolkit-13-0, compute capability 12.1
set -euo pipefail
cd "$(dirname "$0")/../.."
export PATH=/usr/local/cuda/bin:$PATH
cmake -B build -DSD_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES=121
cmake --build build --config Release -j"$(nproc)"
echo "BUILD_EXIT_CODE=$?"
