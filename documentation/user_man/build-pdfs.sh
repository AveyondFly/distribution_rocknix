#!/usr/bin/env bash
# Build user-manual PDFs on the HOST (during ROCKNIX image build).
#
# Default: populate tools/manual-pdf/.cache with Pandoc/TinyTeX + fonts when tools/manual-pdf/ensure-toolchain.sh exists.
# CI / apt builders: SKIP_MANUAL_VENDOR_TOOLCHAIN=1 uses system pandoc+xelatex+Noto (no vendored toolchain run).
set -euo pipefail

DOC_DIR="$(cd "$(dirname "${0}")" && pwd)"
DIST_ROOT="$(cd "${DOC_DIR}/../.." && pwd)"
OUT_DIR="${1:?Usage: ${0} <output-directory-for-pdf-files>}"

TOOLS_SCRIPT="${DIST_ROOT}/tools/manual-pdf/ensure-toolchain.sh"
CACHE_ENV="${DIST_ROOT}/tools/manual-pdf/.cache/env.sh"
PREAMBLE_SYSTEM="${DOC_DIR}/pandoc-preamble-xelatex.tex"

usage_system_hint() {
  printf '%s\n' "Without vendored toolchain, Debian/Ubuntu: sudo apt install pandoc fonts-noto-cjk texlive-xetex texlive-lang-chinese lmodern texlive-fonts-recommended" >&2
}

die() {
  printf '%s\n' "ERROR: $*" >&2
  usage_system_hint
  exit 1
}

if [[ -n "${SKIP_MANUAL_VENDOR_TOOLCHAIN:-}" ]]; then
  unset MANUAL_TOOLS_CACHE MANUAL_PDF_PANDOC MANUAL_PDF_XELATEX MANUAL_PDF_TEX_BINDIR MANUAL_PDF_FONTDIR 2>/dev/null || true
else
  if [[ ! -x "${TOOLS_SCRIPT}" ]]; then
    die "Missing executable ${TOOLS_SCRIPT}"
  fi
  MANUAL_TOOLS_CACHE="${MANUAL_TOOLS_CACHE:-$(dirname "${TOOLS_SCRIPT}")/.cache}" "${TOOLS_SCRIPT}"
  unset MANUAL_TOOLS_CACHE MANUAL_PDF_PANDOC MANUAL_PDF_XELATEX MANUAL_PDF_TEX_BINDIR MANUAL_PDF_FONTDIR 2>/dev/null || true
  if [[ -r "${CACHE_ENV}" ]]; then
    # shellcheck source=/dev/null
    source "${CACHE_ENV}"
  fi
fi

PDF_ENGINE_OPTS=(--pdf-engine=xelatex)
PREAMBLE_FILE="${PREAMBLE_SYSTEM}"

if [[ -z "${SKIP_MANUAL_VENDOR_TOOLCHAIN:-}" ]] &&
  [[ -n "${MANUAL_PDF_FONTDIR:-}" ]] &&
  [[ -f "${MANUAL_PDF_FONTDIR}/SourceHanSansSC-Regular.otf" ]] &&
  [[ -n "${MANUAL_PDF_XELATEX:-}" ]]; then
  PDF_ENGINE_OPTS=(--pdf-engine="${MANUAL_PDF_XELATEX}")
  PREAMBLE_FILE="$(mktemp "${TMPDIR:-/tmp}/rocknix-manual-preamble.XXXXXX.tex")"
  cleanup_preamble() { rm -f "${PREAMBLE_FILE}"; }
  trap cleanup_preamble EXIT
  FONTDIR_ESC="${MANUAL_PDF_FONTDIR}"
  FONTDIR_ESC="${FONTDIR_ESC//\\/\\\\}"
  cat >"${PREAMBLE_FILE}" <<EOS
\usepackage{xeCJK}
\setCJKmainfont{ManualHanSC}[
  Path=${FONTDIR_ESC}/,
  Extension=.otf,
  UprightFont=SourceHanSansSC-Regular,
  BoldFont=SourceHanSansSC-Bold
]
EOS

fi

_have_pandoc=0
if command -v pandoc >/dev/null 2>&1 && [[ -x "$(command -v pandoc)" ]]; then
  _have_pandoc=1
fi
[[ "${_have_pandoc}" -eq 1 ]] || [[ -x "${MANUAL_PDF_PANDOC:-}" ]] || die "'pandoc' is required to build USER_MANUAL PDFs."

if [[ -n "${SKIP_MANUAL_VENDOR_TOOLCHAIN:-}" ]] ||
  [[ -z "${MANUAL_PDF_XELATEX:-}" ]]; then
  command -v xelatex >/dev/null 2>&1 || die "'xelatex' is required when SKIP_MANUAL_VENDOR_TOOLCHAIN=1 or MANUAL_PDF_XELATEX is unset."
else
  [[ -x "${MANUAL_PDF_XELATEX}" ]] || die "Expected XeLaTeX at ${MANUAL_PDF_XELATEX}."
fi

mkdir -p "${OUT_DIR}"

[[ -f "${PREAMBLE_FILE}" ]] || die "Missing preamble ${PREAMBLE_FILE}"

PANDOC_BIN="$(command -v pandoc 2>/dev/null || true)"
if [[ ! -x "${PANDOC_BIN}" ]]; then
  PANDOC_BIN="${MANUAL_PDF_PANDOC:-}"
fi
[[ -x "${PANDOC_BIN}" ]] || die "'pandoc' not executable (PATH or MANUAL_PDF_PANDOC)."

while IFS= read -r -d '' mdpath; do
  base="$(basename "${mdpath}" .md)"
  outpdf="${OUT_DIR}/${base}.pdf"
  printf '  pandoc %s.pdf (xelatex)\n' "${base}"
  "${PANDOC_BIN}" "${mdpath}" \
    -o "${outpdf}" \
    "${PDF_ENGINE_OPTS[@]}" \
    -V geometry:"margin=14mm" \
    -V colorlinks:true \
    -H "${PREAMBLE_FILE}" \
    --resource-path="${DOC_DIR}:${DOC_DIR}/.."
done < <(find "${DOC_DIR}" -maxdepth 1 -name '*.md' -type f ! -iname 'readme.md' -print0)

printf '  Installed manuals into %s\n' "${OUT_DIR}"
ls -la "${OUT_DIR}"/*.pdf
