#!/usr/bin/env bash
# Idempotent bootstrap for documentation/user_man → PDF builds.
# Caches Pandoc binaries, TinyTeX (XeLaTeX + tlmgr), CJK fonts, and optional xeCJK
# under tools/manual-pdf/.cache — no apt installs required once populated.
#
# Environment (optional overrides):
#   MANUAL_TOOLS_CACHE    — cache root (default: <this-dir>/.cache)
#   MANUAL_PANDOC_VERSION — default: 3.9.0.2 (must match upstream Linux tarball naming)
#   MANUAL_TINYTEX_VERSION — CTAN snapshot tag without "v", default: 2026.05
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE="${MANUAL_TOOLS_CACHE:-${SCRIPT_DIR}/.cache}"
BINDIR="${CACHE}/bin"
FONTDIR="${CACHE}/fonts"
PANDOC_VERSION="${MANUAL_PANDOC_VERSION:-3.9.0.2}"
TINYTEX_VERSION="${MANUAL_TINYTEX_VERSION:-2026.05}"

PANDOC_ROOT="${CACHE}/pandoc-${PANDOC_VERSION}"
TEXDIR="${CACHE}/.TinyTeX"

export PATH="${BINDIR}:${PATH}"

die() {
  printf '%s\n' "ERROR: $*" >&2
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

is_musl() {
  if ls /lib/libc.musl-*.so.1 2>/dev/null | grep -q .; then
    return 0
  fi
  if ldd --version 2>&1 | grep -qi musl; then
    return 0
  fi
  return 1
}

download_file() {
  local url="$1" out="$2"
  if have_cmd curl; then
    curl -fsSL --retry 5 --retry-delay 10 -o "${out}.part" "${url}"
  elif have_cmd wget; then
    wget -q --tries=5 --waitretry=10 -O "${out}.part" "${url}"
  else
    die "Need curl or wget to download toolchain."
  fi
  mv -f "${out}.part" "${out}"
}

ensure_xz() {
  command -v xz >/dev/null 2>&1 || die "Unpacking TinyTeX needs xz (Debian/Ubuntu: xz-utils)."
}

uname_m="$(uname -m)"
OS="$(uname -s)"

pandoc_arch() {
  case "${uname_m}" in
    x86_64) printf '%s' 'amd64' ;;
    aarch64 | arm64) printf '%s' 'arm64' ;;
    *) die "Unsupported machine for Pandoc tarball: ${uname_m}" ;;
  esac
}

tinytex_name() {
  # Match rstudio/tinytex-releases naming (see yihui.org tinytex install-bin-unix.sh).
  local installer="TinyTeX-1"
  local ext="tar.xz"
  if [[ "${OS}" != Linux ]]; then
    die "TinyTeX bundle is only automated for Linux hosts (detected ${OS}). Install pandoc+xelatex+fonts manually."
  fi
  if is_musl; then
    [[ "${uname_m}" == x86_64 ]] || die "TinyTeX musl bundle is only x86_64."
    printf '%s' "${installer}-linuxmusl-x86_64-v${TINYTEX_VERSION}.${ext}"
    return 0
  fi
  case "${uname_m}" in
    x86_64) printf '%s' "${installer}-linux-x86_64-v${TINYTEX_VERSION}.${ext}" ;;
    aarch64) printf '%s' "${installer}-linux-arm64-v${TINYTEX_VERSION}.${ext}" ;;
    arm64) printf '%s' "${installer}-linux-arm64-v${TINYTEX_VERSION}.${ext}" ;;
    *) die "Unsupported Linux arch for TinyTeX: ${uname_m}" ;;
  esac
}

install_pandoc() {
  local arch pandoc_exe
  arch="$(pandoc_arch)"
  pandoc_exe="${PANDOC_ROOT}/bin/pandoc"
  if [[ -x "${pandoc_exe}" ]]; then
    ln -sf "${pandoc_exe}" "${BINDIR}/pandoc"
    return 0
  fi
  mkdir -p "${CACHE}" "${BINDIR}"
  have_cmd gzip || die "'gzip' is required to unpack Pandoc tarball."
  local url tmp
  url="https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-${arch}.tar.gz"
  tmp="$(mktemp "${TMPDIR:-/tmp}/manual-pdf-pandoc.XXXXXX.tar.gz")"
  printf '  [manual-pdf] downloading Pandoc %s (%s)…\n' "${PANDOC_VERSION}" "${arch}"
  download_file "${url}" "${tmp}"
  rm -rf "${PANDOC_ROOT}"
  tar -xzf "${tmp}" -C "${CACHE}"
  rm -f "${tmp}"
  pandoc_exe="${PANDOC_ROOT}/bin/pandoc"
  [[ -x "${pandoc_exe}" ]] || die "Expected ${pandoc_exe} after extract."
  ln -sf "${pandoc_exe}" "${BINDIR}/pandoc"
}

tex_bin_dir() {
  local d
  for d in \
    "${TEXDIR}/bin/x86_64-linux" \
    "${TEXDIR}/bin/aarch64-linux"; do
    if [[ -x "${d}/xelatex" ]]; then
      printf '%s\n' "${d}"
      return 0
    fi
  done
  if [[ -d "${TEXDIR}/bin" ]]; then
    while IFS= read -r d; do
      if [[ -x "${d}/xelatex" ]]; then
        printf '%s\n' "${d}"
        return 0
      fi
    done < <(find "${TEXDIR}/bin" -mindepth 1 -maxdepth 1 -type d | sort)
  fi
  die "TinyTeX layout missing ${TEXDIR}/bin/<platform>/xelatex"
}

tinytex_installed() {
  [[ -d "${TEXDIR}/bin" ]] || return 1
  for d in "${TEXDIR}/bin/x86_64-linux" "${TEXDIR}/bin/aarch64-linux"; do
    [[ -x "${d}/xelatex" ]] && return 0
  done
  # Other layouts (e.g. linuxmusl bundles): fall back to a directory scan once.
  if [[ -d "${TEXDIR}/bin" ]]; then
    local d
    while IFS= read -r d; do
      [[ -x "${d}/xelatex" ]] && return 0
    done < <(find "${TEXDIR}/bin" -mindepth 1 -maxdepth 1 -type d | sort)
  fi
  return 1
}

ensure_xecjk() {
  have_cmd perl || die "TinyTeX tlmgr needs perl."
  local texbin tlmgr kpsewhich
  texbin="$(tex_bin_dir)"
  tlmgr="${texbin}/tlmgr"
  kpsewhich="${texbin}/kpsewhich"
  if "${kpsewhich}" -format=tex xeCJK.sty >/dev/null 2>&1; then
    return 0
  fi
  printf '  [manual-pdf] installing LaTeX packages (xeCJK, first run may take a minute)…\n'
  "${tlmgr}" postaction install script xetex >/dev/null 2>&1 || true
  # Bundled tlmgr can lag behind the CTAN mirror; install refuses until self-update.
  if ! "${tlmgr}" update --self; then
    "${tlmgr}" update --self --no-verify-downloads
  fi
  "${tlmgr}" install xecjk
}

install_tinytex() {
  if ! tinytex_installed; then
    mkdir -p "${CACHE}" "${BINDIR}"
    ensure_xz
    have_cmd perl || die "TinyTeX tlmgr needs perl."
    local name url tmp
    name="$(tinytex_name)"
    url="https://github.com/rstudio/tinytex-releases/releases/download/v${TINYTEX_VERSION}/${name}"
    tmp="$(mktemp "${TMPDIR:-/tmp}/manual-pdf-${name}.XXXXXX")"
    printf '  [manual-pdf] downloading TinyTeX %s…\n' "${name}"
    download_file "${url}" "${tmp}"
    rm -rf "${TEXDIR}"
    # Tarball expands to TinyTeX/ under parent of TEXDIR (same as upstream script).
    tar -xJf "${tmp}" -C "$(dirname "${TEXDIR}")"
    rm -f "${tmp}"
  fi
  [[ -x "$(tex_bin_dir)/xelatex" ]] || die "xelatex missing after TinyTeX extract."
  ensure_xecjk
}

ensure_cjk_fonts() {
  mkdir -p "${FONTDIR}"
  local base="https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SimplifiedChinese"
  local f
  for f in SourceHanSansSC-Regular.otf SourceHanSansSC-Bold.otf; do
    if [[ ! -f "${FONTDIR}/${f}" ]]; then
      printf '  [manual-pdf] downloading font %s…\n' "${f}"
      download_file "${base}/${f}" "${FONTDIR}/${f}"
    fi
  done
}

write_env_sh() {
  local texbin pandoc_exe
  texbin="$(tex_bin_dir)"
  pandoc_exe="${PANDOC_ROOT}/bin/pandoc"
  {
    printf '# Generated by tools/manual-pdf/ensure-toolchain.sh — do not edit.\n'
    printf 'export MANUAL_TOOLS_CACHE=%q\n' "${CACHE}"
    printf 'export MANUAL_PDF_PANDOC=%q\n' "${pandoc_exe}"
    printf 'export MANUAL_PDF_XELATEX=%q\n' "${texbin}/xelatex"
    printf 'export MANUAL_PDF_TEX_BINDIR=%q\n' "${texbin}"
    printf 'export MANUAL_PDF_FONTDIR=%q\n' "${FONTDIR}"
    printf 'export PATH=%q\n' "${BINDIR}:${texbin}:${PATH}"
  } >"${CACHE}/env.sh"
}

mkdir -p "${BINDIR}" "${FONTDIR}"
install_pandoc
install_tinytex
ensure_cjk_fonts
write_env_sh

printf '  [manual-pdf] toolchain ready under %s\n' "${CACHE}"
