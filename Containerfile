# add s6 overlay
# https://github.com/linuxserver/docker-baseimage-fedora/blob/master/Dockerfile
FROM alpine:latest AS rootfs-stage

RUN set -x \
  \
  && VERSION=$(wget -O - https://api.github.com/repos/just-containers/s6-overlay/releases/latest |grep tag_name | cut -d '"' -f 4 | tr -d 'v') \
  && mkdir -p /root-out src \
  && wget -O src/s6-overlay-noarch.tar.xz \
    https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-noarch.tar.xz \
  && wget -O src/s6-overlay-arch.tar.xz \
    https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-$(arch).tar.xz \
  && wget -O src/s6-overlay-symlinks-noarch.tar.xz \
    https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-symlinks-noarch.tar.xz \
  && wget -O src/s6-overlay-symlinks-arch.tar.xz \
    https://github.com/just-containers/s6-overlay/releases/download/v${VERSION}/s6-overlay-symlinks-arch.tar.xz \
  && tar -C /root-out -Jxpf src/s6-overlay-noarch.tar.xz \
  && tar -C /root-out -Jxpf src/s6-overlay-arch.tar.xz \
  && tar -C /root-out -Jxpf src/s6-overlay-symlinks-noarch.tar.xz \
  && tar -C /root-out -Jxpf src/s6-overlay-symlinks-arch.tar.xz \
  && rm -rf src

FROM registry.fedoraproject.org/fedora-minimal:latest
ARG VERSION

COPY --from=rootfs-stage /root-out/ /

RUN set -x \
  \
  && TARGETARCH=$(arch) \
  && TARGETARCH=${TARGETARCH/x86_64/amd64} && TARGETARCH=${TARGETARCH/aarch64/arm64} \
  \
  # && VERSION=$(curl -s https://api.github.com/repos/coder/code-server/releases/latest | grep tag_name | cut -d '"' -f 4 | tr -d 'v') \
  && echo 'exclude=*.i386 *.i686' >> /etc/dnf.conf \
  && microdnf install -y --setopt=install_weak_deps=False --best \
    # tools
    sudo \
    git-core \
    git-lfs \
    iproute-tc \
    iptables-nft \
    iputils \
    gzip \
    tar \
    xz \
    unar \
    jq \
    procps-ng \
    which \
    lsof \
    strace \
    ldns-utils \
    vim-minimal \
    tmux \
    bash-completion \
    # container
    podman-remote \
    kubernetes-client \
    helm \
    # apps
    https://github.com/coder/code-server/releases/download/v$VERSION/code-server-$VERSION-$TARGETARCH.rpm \
    python3-pip \
    conda \
  \
  && curl -L -o /usr/local/bin/mc \
    https://dl.min.io/client/mc/release/linux-$TARGETARCH/mc \
  && chmod +x /usr/local/bin/mc \
  \
  && microdnf clean all \
  && rm -rf \
    /var/cache \
    /var/log/*

RUN set -x \
  \
  && echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \
  && ln -sf /usr/bin/python3 /usr/bin/python \
  && ln -sf /usr/bin/podman-remote /usr/bin/podman

ENV \
  S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
  S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  S6_VERBOSITY=1 \
  LANG=C.UTF-8

ENTRYPOINT ["/init"]