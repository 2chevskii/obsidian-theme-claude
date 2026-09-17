FROM node:24-bookworm@sha256:6dac556d980b7f0e5498d08f08cee0ca67798b4ad6c23964a9214920e67758d0

RUN apt-get update \
  && apt-get install --yes --no-install-recommends \
    ca-certificates \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnss3 \
    libx11-xcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxkbcommon0 \
    libxrandr2 \
    libxshmfence1 \
    imagemagick \
    xdotool \
    xauth \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir --mode=1777 /tmp/.X11-unix \
  && useradd --create-home --shell /bin/bash gallery
WORKDIR /workspace/tools/gallery
COPY tools/gallery/package.json tools/gallery/package-lock.json ./
RUN npm ci --ignore-scripts
COPY . /workspace
RUN node /workspace/tools/gallery/download-locked-assets.mjs
USER gallery
ENV HOME=/home/gallery \
    XDG_CONFIG_HOME=/tmp/obsidian-config \
    XDG_CACHE_HOME=/tmp/obsidian-cache \
    DISPLAY=:99
ENTRYPOINT ["/workspace/tools/gallery/run-in-container.sh"]
