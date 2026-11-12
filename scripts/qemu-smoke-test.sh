#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KERNEL="$ROOT_DIR/linux_distro_original/src/linux/arch/x86/boot/bzImage"
INITRAMFS="${1:-"$ROOT_DIR/build/initramfs.cpio.gz"}"
TIMEOUT_SECONDS="${SZH_QEMU_TIMEOUT:-30}"

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "error: qemu-system-x86_64 is required (install qemu-system-x86)" >&2
  exit 1
fi
if ! command -v timeout >/dev/null 2>&1; then
  echo "error: GNU timeout is required" >&2
  exit 1
fi
[[ -s "$KERNEL" ]] || { echo "error: kernel bzImage is missing" >&2; exit 1; }
[[ -s "$INITRAMFS" ]] || {
  printf 'error: initramfs not found: %s (run scripts/build-initramfs.sh first)\n' "$INITRAMFS" >&2
  exit 1
}

log_file="$(mktemp)"
trap 'rm -f "$log_file"' EXIT

set +e
timeout --signal=TERM --kill-after=3s "${TIMEOUT_SECONDS}s" \
  qemu-system-x86_64 \
    -machine accel=tcg \
    -m 512M \
    -smp 2 \
    -kernel "$KERNEL" \
    -initrd "$INITRAMFS" \
    -append "console=ttyS0,115200 rdinit=/init loglevel=4 panic=1" \
    -display none \
    -serial stdio \
    -monitor none \
    -no-reboot >"$log_file" 2>&1
qemu_status=$?
set -e

cat "$log_file"
if grep -Fq "SZH_INITRAMFS_READY" "$log_file"; then
  echo "QEMU boot smoke test passed."
  exit 0
fi

printf 'error: QEMU did not reach the initramfs-ready marker (exit status %s)\n' "$qemu_status" >&2
exit 1
