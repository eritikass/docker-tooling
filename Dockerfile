FROM debian

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY /scripts /scripts
COPY /custom.sh /tmp/custom.sh

RUN set -x \
    # Install packages
    && apt-get update -y \
    && apt-get install -y \
        adduser \
        aria2 \
        atomicparsley \
        bash \
        build-essential \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        jq \
        locales \
        locales-all \
        make \
        mpv \
        pandoc \
        pkg-config \
        python-is-python3 \
        python3 \
        python3-dev \
        python3-pip \
        python3-pyxattr \
        rtmpdump \
        sudo \
        vim \
        wget \
        zip \
    && git config --global advice.detachedHead false \
    # Create /config directory
    && mkdir -p /config \
    # Run custom script
    && bash /tmp/custom.sh \
    # Clean-up
    && rm -rf /var/lib/apt/lists/* /tmp/* /src \
    # all ok
    && echo "All done."

WORKDIR /tooling
