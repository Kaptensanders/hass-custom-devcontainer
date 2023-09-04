#FROM homeassistant/home-assistant:dev

FROM mcr.microsoft.com/vscode/devcontainers/python:0-3.11

# use: docker build --build-arg HA_VERSION=x.x.x to set another version
# arg gets reset after each FROM 
ARG HA_VERSION=2023.8.4

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bluez \
        libffi-dev \
        libssl-dev \
        libjpeg-dev \
        zlib1g-dev \
        autoconf \
        build-essential \
        libopenjp2-7 \
        libtiff5 \
        libturbojpeg0-dev \
        tzdata \
        ffmpeg \
        liblapack3 \
        liblapack-dev \
        libatlas-base-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --upgrade wheel pip

EXPOSE 8123

VOLUME /config

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt
COPY --chmod=755 container /usr/bin
COPY --chmod=755 hassfest /usr/bin
COPY --chown=vscode:vscode configuration.yaml /config/configuration.yaml
RUN HA_VERSION=${HA_VERSION} container setup

USER vscode

CMD sudo -E container launch-hass
