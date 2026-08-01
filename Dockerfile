ARG SBCL_VERSION=2.6.7
FROM debian:bullseye

ARG SBCL_VERSION
ENV SBCL_VERSION=${SBCL_VERSION}

# Build a modern SBCL from source on bullseye (glibc 2.31). Official prebuilt
# SBCL binaries are linked against a newer glibc and would not run here;
# compiling from source links the runtime against the old glibc, so saved
# executables keep a low glibc floor and run on older Linux distributions.
# SBCL installs into /usr/local (its default).
COPY build-sbcl.sh /tmp/build-sbcl.sh
RUN chmod +x /tmp/build-sbcl.sh \
    && /tmp/build-sbcl.sh \
    && rm /tmp/build-sbcl.sh

ENV SBCL_HOME=/usr/local/lib/sbcl
