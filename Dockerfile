FROM debian

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
        locales \
        locales-all \
        make \
        mpv \
        pandoc \
        python-is-python3 \
        python3 \
        python3-dev \
        python3-pip \
        python3-pyxattr \
        rtmpdump \
        vim \
        zip \
    && git config --global advice.detachedHead false \
    # Install yt-dlp via curl
    && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp \
    && chmod a+x /usr/local/bin/yt-dlp \
    # Create /config directory
    && mkdir -p /config \
    # Clean-up
    && rm -rf /var/lib/apt/lists/* /tmp/* /src \
    # Document version
    && mkdir -p /versions \
    && yt-dlp --version > /versions/yt-dlp.txt \
    && ffmpeg -version > /versions/ffmpeg.txt \
    # all ok
    && echo "All done."


COPY /scripts /scripts
