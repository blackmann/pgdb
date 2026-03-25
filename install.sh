#!/usr/bin/env bash

set -euo pipefail

REPO="${BERRY_REPO:-blackmann/pgdb}"
REF="${BERRY_REF:-main}"
INSTALL_DIR="${BERRY_INSTALL_DIR:-$HOME/.local/bin}"
BIN_NAME="${BERRY_BIN_NAME:-berry}"
RAW_BASE="https://raw.githubusercontent.com/${REPO}/${REF}"
TARGET_PATH="${INSTALL_DIR}/${BIN_NAME}"

say() {
  printf 'berry-install: %s\n' "$*"
}

die() {
  printf 'berry-install: %s\n' "$*" >&2
  exit 1
}

download_to_stdout() {
  local url="$1"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url"
    return 0
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO- "$url"
    return 0
  fi

  die "Missing downloader. Install curl or wget and try again."
}

main() {
  local tmpdir
  local tmpfile

  tmpdir="$(mktemp -d)"
  tmpfile="${tmpdir}/${BIN_NAME}"
  trap "rm -rf '$tmpdir'" EXIT

  say "Downloading ${BIN_NAME} from ${REPO}@${REF}"
  download_to_stdout "${RAW_BASE}/berry" > "$tmpfile"

  mkdir -p "$INSTALL_DIR"
  chmod +x "$tmpfile"
  cp "$tmpfile" "$TARGET_PATH"

  say "Installed to ${TARGET_PATH}"

  case ":${PATH}:" in
    *":${INSTALL_DIR}:"*)
      say "Run '${BIN_NAME} help' to get started."
      ;;
    *)
      say "${INSTALL_DIR} is not on your PATH."
      say "Add this to your shell config:"
      printf 'export PATH="%s:$PATH"\n' "$INSTALL_DIR"
      ;;
  esac
}

main "$@"
