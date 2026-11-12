#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS="$ROOT_DIR/linux_distro_original/distro/fs"
OUTPUT="${1:-"$ROOT_DIR/build/initramfs.cpio.gz"}"

if [[ "$OUTPUT" != /* ]]; then
  OUTPUT="$ROOT_DIR/$OUTPUT"
fi

for tool in cpio gzip sha256sum; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'error: required host tool not found: %s\n' "$tool" >&2
    exit 1
  fi
done

"$ROOT_DIR/scripts/validate-distro.sh"
mkdir -p "$(dirname "$OUTPUT")"

if [[ -z "${SOURCE_DATE_EPOCH:-}" ]]; then
  SOURCE_DATE_EPOCH="$(git -C "$ROOT_DIR" log -1 --format=%ct 2>/dev/null || printf '0')"
fi

# Normalize timestamps so identical tracked inputs produce a stable archive.
find "$ROOTFS" -print0 | xargs -0 -r touch -h -d "@$SOURCE_DATE_EPOCH"

temporary="$(mktemp "${OUTPUT}.tmp.XXXXXX")"
trap 'rm -f "$temporary"' EXIT

(
  cd "$ROOTFS"
  LC_ALL=C find . -print0 |
    LC_ALL=C sort -z |
    cpio --null --create --format=newc --owner=0:0 --reproducible
) | gzip -n -9 > "$temporary"

gzip -t "$temporary"
mv "$temporary" "$OUTPUT"
trap - EXIT

KERNEL="$ROOT_DIR/linux_distro_original/src/linux/arch/x86/boot/bzImage"
OUTPUT_RELATIVE="${OUTPUT#"$ROOT_DIR"/}"
(
  cd "$ROOT_DIR"
  sha256sum "linux_distro_original/src/linux/arch/x86/boot/bzImage" "$OUTPUT_RELATIVE"
) > "$(dirname "$OUTPUT")/SHA256SUMS"

printf 'Initramfs created: %s\n' "$OUTPUT"
du -h "$OUTPUT"
