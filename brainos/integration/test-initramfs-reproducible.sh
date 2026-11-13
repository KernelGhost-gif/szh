#!/usr/bin/env bash
set -Eeuo pipefail
if [[ $# -ne 2 ]]; then echo "Usage: $0 ROOTFS PACKER.py" >&2; exit 2; fi
root=$(realpath "$1")
packer=$(realpath "$2")
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cp -a "$root" "$work/rootfs"
SOURCE_DATE_EPOCH=0 python3 "$packer" "$work/rootfs" "$work/a.cpio.gz"
find "$work/rootfs" -depth -exec touch -h -d '@1700000000' {} +
SOURCE_DATE_EPOCH=0 python3 "$packer" "$work/rootfs" "$work/b.cpio.gz"
a=$(sha256sum "$work/a.cpio.gz" | awk '{print $1}')
b=$(sha256sum "$work/b.cpio.gz" | awk '{print $1}')
printf 'A %s\nB %s\n' "$a" "$b"
[[ "$a" == "$b" ]] || { echo "initramfs is not reproducible" >&2; exit 1; }
echo "PASS: hash is invariant under timestamp perturbation."
