#FROM homeassistant/home-assistant:dev

FROM mcr.microsoft.com/vscode/devcontainers/python:0-3.11

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# use: docker build --build-arg ENV_FILE=<file> to set another env file to use
ARG ENV_FILE=container.env

RUN \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | tee /usr/share/keyrings/yarn.gpg >/dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
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

COPY ${ENV_FILE} /tmp/container.env
RUN ENV_FILE=/tmp/container.env container setup

USER vscode

CMD sudo -E container launch-hass
