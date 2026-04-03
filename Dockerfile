FROM python:3.13-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TINI_SUBREAPER=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin \
    TORCH_INDEX_URL=https://download.pytorch.org/whl/cu130

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    git \
    libgl1 \
    libglib2.0-0 \
    libgoogle-perftools4 \
    tini \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv "$VIRTUAL_ENV" && \
    python -m pip install --upgrade pip setuptools wheel

WORKDIR /opt/sd-webui-forge-classic

COPY . /opt/sd-webui-forge-classic

RUN bash runpod/install_extensions.sh

RUN mkdir -p /opt/webui-seed && \
    cp runpod/config.seed.json /opt/webui-seed/config.seed.json && \
    printf "{}\n" > /opt/webui-seed/ui-config.seed.json

RUN python launch.py \
    --skip-torch-cuda-test \
    --exit

RUN rm -rf /root/.cache /tmp/*

EXPOSE 7860

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["bash", "/opt/sd-webui-forge-classic/runpod/start.sh"]
