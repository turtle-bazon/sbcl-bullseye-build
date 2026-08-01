#!/usr/bin/env bash
# Build SBCL from source on Debian bullseye and install it into
# ${INSTALL_ROOT:-/opt/sbcl}. Run as root (e.g. inside a container).
set -euo pipefail

SBCL_VERSION="${SBCL_VERSION:-2.6.7}"
INSTALL_ROOT="${INSTALL_ROOT:-/opt/sbcl}"

apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    zlib1g-dev \
    sbcl
rm -rf /var/lib/apt/lists/*

curl -fsSL \
    "https://downloads.sourceforge.net/project/sbcl/sbcl/${SBCL_VERSION}/sbcl-${SBCL_VERSION}-source.tar.bz2" \
    -o /tmp/sbcl-source.tar.bz2

mkdir /tmp/sbcl-build
tar -xjf /tmp/sbcl-source.tar.bz2 -C /tmp/sbcl-build --strip-components=1
cd /tmp/sbcl-build

INSTALL_ROOT="${INSTALL_ROOT}" sh make.sh
INSTALL_ROOT="${INSTALL_ROOT}" sh install.sh

rm -rf /tmp/sbcl-build /tmp/sbcl-source.tar.bz2
