FROM registry.fedoraproject.org/fedora-minimal:latest
ARG VERSION

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
    kubernetes-client \
    helm \
    # apps
    tini \
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
  && ln -sf /usr/bin/python3 /usr/bin/python

ENV \
  LANG=C.UTF-8

ENTRYPOINT ["tini", "--", "code-server"]