# Runpod Packaging

This repo is set up so GitHub Actions can build a GPU-ready Forge Neo image for Runpod without using local Docker.

## What is preserved

- `sd-webui-forge-classic` on branch `neo`
- Civitai browser extension at a pinned upstream commit plus the local UI/API patches in `runpod/patches/sd-webui-civbrowser.patch`
- Civitai Link extension at a pinned upstream commit
- A sanitized seed config in `runpod/config.seed.json`

## Runtime layout

- Application code lives in the image at `/opt/sd-webui-forge-classic`
- Seed files live in the image at `/opt/webui-seed`
- Persistent data should live on a Runpod network volume mounted at `/workspace`

At container start:

- `/workspace/config.json` is created from the seed config if missing
- `/workspace/extensions/sd-webui-civbrowser` is created from the image seed if missing
- `/workspace/extensions/sd_civitai_extension` is created from the image seed if missing
- models live under `/workspace/models`
- outputs live under `/workspace/output`

## Recommended Runpod template settings

- Container image: `ghcr.io/<owner>/<repo>:latest`
- Volume mount path: `/workspace`
- Exposed HTTP port: `7860`
- Container disk can stay small because models should go on the network volume

## Recommended environment variables

- `CIVITAI_API_KEY=<your key>`
- `FORGE_PORT=7860`
- `FORGE_ENABLE_XFORMERS=0`
- `FORGE_NO_GRADIO_QUEUE=0`
- `FORGE_EXTRA_ARGS=--cuda-malloc --cuda-stream`

Optional model-specific toggles:

- `FORGE_ENABLE_BNB=1` for NF4 workflows
- `FORGE_ENABLE_NUNCHAKU=1` for SVDQ / Nunchaku workflows
- `FORGE_ENABLE_SAGE=1`
- `FORGE_ENABLE_FLASH=1`

## Notes

- `CIVITAI_API_KEY` is intentionally not stored in the repo seed config.
- The image build does not bake models into the image.
- Your current Windows `venv` is not reused; the image rebuilds Python dependencies in Linux.
- The image is pinned to CUDA 12.8 PyTorch wheels for broader Runpod driver compatibility than the fork's default CUDA 13.0 wheels.
