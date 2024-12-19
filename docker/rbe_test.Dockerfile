ARG BASE_IMAGE=debian
ARG BASE_IMAGE_TAG=bookworm-slim
FROM $BASE_IMAGE:$BASE_IMAGE_TAG AS debian

ARG TARGETOS
ARG TARGETARCH

ARG REPRODUCIBLE_CONTAINERS_VERSION

ADD --chmod=0755 \
    https://raw.githubusercontent.com/reproducible-containers/repro-sources-list.sh/refs/tags/v${REPRODUCIBLE_CONTAINERS_VERSION}/repro-sources-list.sh \
    /usr/local/bin

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    KEEP_CACHE=1 /usr/local/bin/repro-sources-list.sh

ENV APT_INSTALL='\
set -euxo pipefail; \
\
apt_install() { \
    apt-get update; \
\
    apt-get install -y \
    --no-install-recommends \
    --no-install-suggests \
    $@; \
\
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/log/* /var/cache/ldconfig/aux-cache; \
}; \
'

# setup ca-certificates for SSL cert verification
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install ca-certificates
EOF

## allow to create a non-root user (rules_python notoriously fails when running as root)
ARG USERNAME=nonroot
ARG HOMEDIR=/home/$USERNAME

ENV USERNAME=$USERNAME
ENV HOMEDIR=$HOMEDIR

RUN /bin/bash <<EOF
set -euxo pipefail

[[ "$USERNAME" != "root" ]] && useradd \
    --comment 'Non-root User' \
    --create-home --home-dir "$HOMEDIR" \
    --shell /bin/bash \
    $USERNAME
EOF

USER $USERNAME

FROM debian AS debian-rbe

USER root

## setup compilers
RUN /bin/bash <<EOF
$APT_INSTALL
apt_install libc6-dev gcc g++
EOF

USER $USERNAME
