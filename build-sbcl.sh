#!/usr/bin/env bash
# Build SBCL from source on Debian bullseye and install it into /usr/local
# (the SBCL default). Run as root (e.g. inside a container).
set -euo pipefail

SBCL_VERSION="${SBCL_VERSION:-2.6.8}"

# Bullseye is EOL, so deb.debian.org no longer serves its security pool: the
# bullseye-security Packages index still advertises deb11uN versions, but those
# .debs now 404. archive.debian.org is the frozen, complete mirror and serves
# the identical signed Release file, so point apt there. See README.
cat > /etc/apt/sources.list <<'EOF'
deb http://archive.debian.org/debian bullseye main
deb http://archive.debian.org/debian-security bullseye-security main
EOF
# Neutralise any extra source files the base image may ship, so a leftover
# deb.debian.org entry cannot reintroduce the 404s.
rm -f /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources
# archive.debian.org drops Valid-Until, but be explicit so a future mirror
# without it cannot break the build.
echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

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
