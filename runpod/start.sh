#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/sd-webui-forge-classic"
DATA_DIR="${FORGE_DATA_DIR:-/workspace}"
MODELS_DIR="${FORGE_MODELS_DIR:-$DATA_DIR/models}"
SEED_DIR="/opt/webui-seed"
PYTHON_BIN="${VIRTUAL_ENV:-/opt/venv}/bin/python"

copy_if_missing() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "$dst" && -e "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -a "$src" "$dst"
    fi
}

copy_dir_if_missing() {
    local src="$1"
    local dst="$2"

    if [[ ! -d "$dst" && -d "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -a "$src" "$dst"
    fi
}

mkdir -p \
    "$DATA_DIR" \
    "$DATA_DIR/extensions" \
    "$DATA_DIR/output" \
    "$DATA_DIR/cache" \
    "$MODELS_DIR" \
    "$MODELS_DIR/Stable-diffusion" \
    "$MODELS_DIR/Lora" \
    "$MODELS_DIR/VAE" \
    "$MODELS_DIR/ControlNet" \
    "$MODELS_DIR/ControlNetPreprocessor" \
    "$MODELS_DIR/Codeformer" \
    "$MODELS_DIR/GFPGAN" \
    "$MODELS_DIR/ESRGAN" \
    "$MODELS_DIR/embeddings" \
    "$MODELS_DIR/text_encoder" \
    "$MODELS_DIR/diffusers"

copy_if_missing "$SEED_DIR/config.seed.json" "$DATA_DIR/config.json"
copy_if_missing "$SEED_DIR/ui-config.seed.json" "$DATA_DIR/ui-config.json"
copy_dir_if_missing "$SEED_DIR/extensions/sd-webui-civbrowser" "$DATA_DIR/extensions/sd-webui-civbrowser"
copy_dir_if_missing "$SEED_DIR/extensions/sd_civitai_extension" "$DATA_DIR/extensions/sd_civitai_extension"

export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-expandable_segments:True}"
export HF_HOME="${HF_HOME:-$DATA_DIR/cache/huggingface}"
export TRANSFORMERS_CACHE="${TRANSFORMERS_CACHE:-$HF_HOME/transformers}"

ARGS=(
    --listen
    --port "${FORGE_PORT:-7860}"
    --api
    --enable-insecure-extension-access
    --skip-torch-cuda-test
    --data-dir "$DATA_DIR"
    --model-ref "$MODELS_DIR"
    --ui-settings-file "$DATA_DIR/config.json"
    --ui-config-file "$DATA_DIR/ui-config.json"
)

if [[ "${FORGE_ENABLE_XFORMERS:-0}" == "1" ]]; then
    ARGS+=(--xformers)
fi

if [[ "${FORGE_ENABLE_SAGE:-0}" == "1" ]]; then
    ARGS+=(--sage)
fi

if [[ "${FORGE_ENABLE_FLASH:-0}" == "1" ]]; then
    ARGS+=(--flash)
fi

if [[ "${FORGE_ENABLE_BNB:-0}" == "1" ]]; then
    ARGS+=(--bnb)
fi

if [[ "${FORGE_ENABLE_NUNCHAKU:-0}" == "1" ]]; then
    ARGS+=(--nunchaku)
fi

if [[ "${FORGE_ENABLE_ONNXRUNTIME_GPU:-0}" == "1" ]]; then
    ARGS+=(--onnxruntime-gpu)
fi

if [[ "${FORGE_NO_GRADIO_QUEUE:-0}" == "1" ]]; then
    ARGS+=(--no-gradio-queue)
fi

if [[ -n "${FORGE_EXTRA_ARGS:-}" ]]; then
    # shellcheck disable=SC2206
    EXTRA_ARGS=( ${FORGE_EXTRA_ARGS} )
    ARGS+=("${EXTRA_ARGS[@]}")
fi

cd "$APP_DIR"
exec "$PYTHON_BIN" launch.py "${ARGS[@]}"
