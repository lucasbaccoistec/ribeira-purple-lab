#!/usr/bin/env bash
# Descarrega o Chainsaw (versão fixa) para .tools/chainsaw/ e confirma o SHA-256.
# Uso: bash detections/tests/get-chainsaw.sh
set -euo pipefail

VERSION="2.18.0"
BASE="https://github.com/WithSecureLabs/chainsaw/releases/download/v${VERSION}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEST="${ROOT}/.tools/chainsaw"

if [ -x "${DEST}/chainsaw" ]; then
  echo "Chainsaw já está instalado em ${DEST}"
  exit 0
fi

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)
    asset="chainsaw_aarch64-apple-darwin.zip"
    expected="24c28acb0700756c0b37cdca9fd2624cbbd4dcf053c56c7a135843bcf832d559"
    ;;
  Darwin-x86_64)
    asset="chainsaw_x86_64-apple-darwin.zip"
    expected="540bcbcdd7f127e3cfbba824ec32f6295c2fea2829aa847da96640db057801fb"
    ;;
  Linux-x86_64)
    asset="chainsaw_x86_64-unknown-linux-gnu.tar.gz"
    expected="66dcbe261fac77d342f51a97a33f718e6bb485232c29248e590d88f2db0718e6"
    ;;
  Linux-aarch64)
    asset="chainsaw_aarch64-unknown-linux-gnu.tar.gz"
    expected="3ef99e8665fef505277e5a385b9ccab1bca56a4e7f392f60874d57b861a2a25b"
    ;;
  *)
    echo "Sistema não suportado: $(uname -s)-$(uname -m)" >&2
    exit 1
    ;;
esac

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d ' ' -f 1
  else
    shasum -a 256 "$1" | cut -d ' ' -f 1
  fi
}

tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT

echo "A descarregar ${asset} (Chainsaw ${VERSION})..."
curl -fsSL --retry 3 -o "${tmp}/${asset}" "${BASE}/${asset}"

actual="$(sha256_of "${tmp}/${asset}")"
if [ "${actual}" != "${expected}" ]; then
  echo "SHA-256 não confere para ${asset}" >&2
  echo "  esperado: ${expected}" >&2
  echo "  obtido:   ${actual}" >&2
  exit 1
fi

mkdir "${tmp}/out"
case "${asset}" in
  *.zip)    unzip -q "${tmp}/${asset}" -d "${tmp}/out" ;;
  *.tar.gz) tar -xzf "${tmp}/${asset}" -C "${tmp}/out" ;;
esac

mkdir -p "${ROOT}/.tools"
mv "${tmp}/out/chainsaw" "${DEST}"
chmod +x "${DEST}/chainsaw"
"${DEST}/chainsaw" --version
