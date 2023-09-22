#FROM homeassistant/home-assistant:dev

FROM mcr.microsoft.com/vscode/devcontainers/python:0-3.11

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# use: docker build --build-arg ENV_FILE=<file> to set another env file to use
ARG ENV_FILE=container.env
ARG HA_VERSION=2023.8.4
ARG DEVIMAGE_DIR=/home/vscode/.devimage
ARG HA_DIR=/usr/src/homeassistant

ENV DEVIMAGE_DIR=${DEVIMAGE_DIR}
ENV HA_VERSION=${HA_VERSION}
ENV DEVCONTAINER=1
ENV HA_DIR=${HA_DIR}

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

RUN git clone --branch ${HA_VERSION} --single-branch --depth 1 https://github.com/home-assistant/core.git ${HA_DIR}

# remove the .git folder or vscode will complain about unsafe repo. We dont need it
RUN rm -rf ${HA_DIR}/.git

RUN pip install -r ${HA_DIR}/requirements.txt
RUN pip install -e ${HA_DIR}

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

COPY --chmod=755 container /usr/bin
COPY --chmod=755 hassfest /usr/bin

USER vscode

RUN mkdir ${DEVIMAGE_DIR}
COPY configuration.yaml ${DEVIMAGE_DIR}/ha_configuration_base.yaml

RUN container setup-container

CMD /bin/bash -l
 