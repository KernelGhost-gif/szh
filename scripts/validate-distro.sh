#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOTFS="$ROOT_DIR/linux_distro_original/distro/fs"
KERNEL_DIR="$ROOT_DIR/linux_distro_original/src/linux"
KERNEL="$KERNEL_DIR/arch/x86/boot/bzImage"
CONFIG="$KERNEL_DIR/.config"

for tool in file readelf; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'error: required host tool not found: %s\n' "$tool" >&2
    exit 1
  fi
done

[[ -s "$KERNEL" ]] || { echo "error: prebuilt kernel bzImage is missing or empty" >&2; exit 1; }
[[ -s "$CONFIG" ]] || { echo "error: kernel .config is missing or empty" >&2; exit 1; }

for relative in init bin/sh bin/toybox sbin/init etc/inittab etc/init.d/rcS lib/ld-musl-x86_64.so.1; do
  [[ -s "$ROOTFS/$relative" ]] || {
    printf 'error: required rootfs file is missing or empty: %s\n' "$relative" >&2
    exit 1
  }
done

for setting in \
  CONFIG_X86_64 \
  CONFIG_BLK_DEV_INITRD \
  CONFIG_RD_GZIP \
  CONFIG_DEVTMPFS \
  CONFIG_DEVTMPFS_MOUNT \
  CONFIG_PROC_FS \
  CONFIG_SYSFS \
  CONFIG_TMPFS \
  CONFIG_SERIAL_8250_CONSOLE; do
  if ! grep -Fxq "$setting=y" "$CONFIG"; then
    printf 'error: kernel config does not enable %s\n' "$setting" >&2
    exit 1
  fi
done

"$ROOT_DIR/scripts/prepare-rootfs.sh" "$ROOTFS"

for binary in "$ROOTFS/init" "$ROOTFS/bin/sh" "$ROOTFS/bin/toybox"; do
  if ! readelf -h "$binary" | grep -Eq 'Machine:.*X86-64'; then
    printf 'error: expected an x86-64 ELF binary: %s\n' "$binary" >&2
    exit 1
  fi
done

interpreter="$(readelf -l "$ROOTFS/bin/sh" | sed -n 's/.*Requesting program interpreter: \(.*\)]/\1/p')"
if [[ -n "$interpreter" && ! -e "$ROOTFS$interpreter" ]]; then
  printf 'error: /bin/sh requires missing ELF interpreter: %s\n' "$interpreter" >&2
  exit 1
fi

sh -n "$ROOTFS/etc/init.d/rcS"
echo "Distro validation passed."
