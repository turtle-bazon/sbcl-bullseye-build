ARG SBCL_VERSION=2.6.7
FROM debian:bullseye

ARG SBCL_VERSION
ENV SBCL_VERSION=${SBCL_VERSION} \
    INSTALL_ROOT=/opt/sbcl

# Build a modern SBCL from source on bullseye (glibc 2.31). Official prebuilt
# SBCL binaries are linked against a newer glibc and would not run here;
# compiling from source links the runtime against the old glibc, so saved
# executables keep a low glibc floor and run on older Linux distributions.
COPY build-sbcl.sh /tmp/build-sbcl.sh
RUN chmod +x /tmp/build-sbcl.sh \
    && /tmp/build-sbcl.sh \
    && rm /tmp/build-sbcl.sh

ENV PATH=/opt/sbcl/bin:${PATH} \
    SBCL_HOME=/opt/sbcl/lib/sbcl

# Quicklisp convenience: ~/.sbclrc loads it, so containers can ql:quickload.
RUN curl -fsSL https://beta.quicklisp.org/quicklisp.lisp -o /tmp/quicklisp.lisp \
    && sbcl --non-interactive --load /tmp/quicklisp.lisp \
           --eval '(quicklisp-quickstart:install)' \
    && rm /tmp/quicklisp.lisp \
    && echo '(load "~/quicklisp/setup.lisp")' >> /root/.sbclrc
