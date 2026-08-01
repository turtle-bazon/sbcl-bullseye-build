# sbcl-bullseye-build

Builds a modern SBCL from source on Debian bullseye and distributes it two ways:

- a **Docker image** on GitHub Container Registry (`ghcr.io/<owner>/sbcl-bullseye-build/sbcl-bullseye`)
- an **SBCL binary tarball** attached to GitHub Releases

## Why

Official SBCL prebuilt binaries are linked against a recent glibc (2.6.7 needs
GLIBC_2.34) and refuse to start on older systems. Compiling SBCL from source on
bullseye links the runtime against glibc 2.31, so:

- executables saved with this SBCL run on **glibc >= 2.31** (Debian 11+, Ubuntu
  20.04+, RHEL 8+, ...), and
- the SBCL binary itself runs on those systems too.

## Artifacts

### Container image

```sh
docker pull ghcr.io/<owner>/sbcl-bullseye-build/sbcl-bullseye:latest
docker run --rm ghcr.io/<owner>/sbcl-bullseye-build/sbcl-bullseye:latest sbcl --version
```

The image also bootstraps Quicklisp (`~/.sbclrc` loads it), so it is ready to
`ql:quickload` a project.

### Binary tarball

From the GitHub Release for your SBCL version, download
`sbcl-<version>-x86-64-linux.tar.gz`. The tarball contains the install tree
under `local/` (i.e. the contents of `/usr/local`), so extracting it into `/usr`
installs SBCL the standard way:

```sh
tar -xzf sbcl-<version>-x86-64-linux.tar.gz -C /usr
export SBCL_HOME=/usr/local/lib/sbcl
sbcl --version
```

(If you would rather keep it unprivileged, extract anywhere and point
`SBCL_HOME` at the extracted `lib/sbcl`, adding the extracted `bin` to `PATH`.)

## Building / releasing

GitHub Actions does everything:

- pushes the image to GHCR
- extracts `/usr/local` from the built image and uploads it to a
  `sbcl-<version>` GitHub Release

Bump `SBCL_VERSION` in `.github/workflows/release.yml` (and the `ARG` default in
`Dockerfile`) to build a newer SBCL. Run the workflow manually or let it trigger
on changes to `Dockerfile` / `build-sbcl.sh`.

Requires the repo to have a GitHub Actions workflow permission that allows
`packages: write` (GHCR) and `contents: write` (Releases).
