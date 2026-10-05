FROM debian:bullseye

# Optional override, e.g. --build-arg SBCL_VERSION=2.6.7. Empty means "read
# the VERSION file", which is the normal path.
ARG SBCL_VERSION

# Build a modern SBCL from source on bullseye (glibc 2.31). Official prebuilt
# SBCL binaries are linked against a newer glibc and would not run here;
# compiling from source links the runtime against the old glibc, so saved
# executables keep a low glibc floor and run on older Linux distributions.
# SBCL installs into /usr/local (its default).
# The version to build lives in the VERSION file, so bumping it is a one-file
# change that both this build and the release workflow pick up.
# Keep these in their own directory: build-sbcl.sh uses $work_dir (/tmp/sbcl-build
# by default) for the unpacked source and deletes it when finished.
COPY VERSION build-sbcl.sh /tmp/sbcl-build-helpers/
RUN chmod +x /tmp/sbcl-build-helpers/build-sbcl.sh \
    && SBCL_VERSION="$SBCL_VERSION" /tmp/sbcl-build-helpers/build-sbcl.sh \
    && rm -rf /tmp/sbcl-build-helpers

ENV SBCL_HOME=/usr/local/lib/sbcl
