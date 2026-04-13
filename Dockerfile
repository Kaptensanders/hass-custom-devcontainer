FROM mcr.microsoft.com/devcontainers/python:3.14-trixie

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# use: docker build --build-arg ENV_FILE=<file> to override or set another env file to use
ARG ENV_FILE=container.env
ARG HA_VERSION=2026.3.4
ARG HA_DIR=/home/vscode/ha_core
ARG HA_CONFIG_DIR=/home/vscode/ha_config

ENV HA_VERSION=${HA_VERSION}
ENV DEVCONTAINER=1
ENV HA_DIR=${HA_DIR}
ENV HA_CONFIG_DIR=${HA_CONFIG_DIR}
ENV PYTHONPATH=${HA_DIR}

EXPOSE 8123

# homeassistant dependencies
# see https://www.home-assistant.io/installation/linux
RUN apt-get update \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        autoconf pkg-config libssl-dev libxml2-dev \
        libxslt1-dev libjpeg-dev libffi-dev libudev-dev \
        zlib1g-dev libavformat-dev libavcodec-dev libavdevice-dev \
        libavutil-dev libavfilter-dev libswscale-dev libswresample-dev \
        ffmpeg libgammu-dev bluez build-essential libopenjp2-7 libtiff6 \
        libturbojpeg0-dev tzdata liblapack3 liblapack-dev libpcap-dev \
        nodejs npm \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

USER vscode

RUN git clone --branch ${HA_VERSION} --single-branch --depth 1 https://github.com/home-assistant/core.git ${HA_DIR}


RUN ${HA_DIR}/script/setup 

# (copy will always set root permissions)
COPY --chmod=755 container /usr/bin
COPY --chmod=755 hassfest /usr/bin
COPY --chmod=755 add_ha_resource /usr/bin

RUN mkdir ${HA_CONFIG_DIR}
COPY configuration.yaml ${HA_CONFIG_DIR}/configuration.yaml
RUN sudo chown vscode:vscode ${HA_CONFIG_DIR}/configuration.yaml

RUN container setup-container

CMD /bin/bash -l
