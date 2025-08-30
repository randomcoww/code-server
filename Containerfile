FROM registry.fedoraproject.org/fedora-minimal:latest
ARG VERSION

RUN set -x \
  \
  && TARGETARCH=$(arch) \
  && TARGETARCH=${TARGETARCH/x86_64/amd64} && TARGETARCH=${TARGETARCH/aarch64/arm64} \
  \
  && echo 'exclude=*.i386 *.i686' >> /etc/dnf.conf \
  && microdnf install -y --setopt=install_weak_deps=False --best \
    # tools
    tini \
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
    gawk \
    # container
    kubernetes-client \
    helm \
    # apps
    https://github.com/coder/code-server/releases/download/v$VERSION/code-server-$VERSION-$TARGETARCH.rpm \
    python3-pip \
    conda \
  \
  && microdnf clean all \
  && rm -rf \
    /var/cache \
    /var/log/* \
  && echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel \
  \
  && ln -sf /usr/bin/python3 /usr/bin/python \
  && curl -L -o /usr/local/bin/mc \
    https://dl.min.io/client/mc/release/linux-$TARGETARCH/mc \
  && chmod +x /usr/local/bin/mc

ENV \
  LANG=C.UTF-8 \
  XDG_DATA_DIRS=/usr/local/share:/usr/share

ENTRYPOINT ["tini", "--"]