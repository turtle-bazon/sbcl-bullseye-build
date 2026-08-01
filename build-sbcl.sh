#!/usr/bin/env bash
# Build SBCL from source on Debian bullseye and install it into /usr/local
# (the SBCL default). Run as root (e.g. inside a container).
set -euo pipefail

SBCL_VERSION="${SBCL_VERSION:-2.6.7}"

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

sh make.sh
sh install.sh

# The apt sbcl was only the host for the bootstrap; remove it so the image
# keeps just the source-built SBCL.
apt-get purge -y sbcl
rm -rf /var/lib/apt/lists/*

rm -rf /tmp/sbcl-build /tmp/sbcl-source.tar.bz2
