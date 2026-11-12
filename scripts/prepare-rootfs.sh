#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS="${1:-"$ROOT_DIR/linux_distro_original/distro/fs"}"

if [[ ! -d "$ROOTFS" ]]; then
  printf 'error: root filesystem directory not found: %s\n' "$ROOTFS" >&2
  exit 1
fi

if ! command -v file >/dev/null 2>&1; then
  echo "error: 'file' is required to identify ELF executables (install the file package)" >&2
  exit 1
fi

# Restore executable bits for every ELF file, including shared libraries.
while IFS= read -r -d '' candidate; do
  description="$(file -b "$candidate" 2>/dev/null || true)"
  if [[ "$description" == ELF* ]]; then
    chmod 0755 "$candidate"
  fi
done < <(find "$ROOTFS" -type f -print0)

if [[ -f "$ROOTFS/etc/init.d/rcS" ]]; then
  chmod 0755 "$ROOTFS/etc/init.d/rcS"
fi

for relative in init bin/sh bin/toybox sbin/init lib/ld-musl-x86_64.so.1 etc/init.d/rcS; do
  if [[ ! -x "$ROOTFS/$relative" ]]; then
    printf 'error: required executable is missing or not executable: %s\n' "$relative" >&2
    exit 1
  fi
done

echo "Rootfs executable permissions are ready."
