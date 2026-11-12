#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INITRAMFS="${1:-"$ROOT_DIR/build/initramfs.cpio.gz"}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 is required to run the serial-console smoke test" >&2
  exit 1
fi

exec python3 "$ROOT_DIR/scripts/qemu-smoke-test.py" "$INITRAMFS"
