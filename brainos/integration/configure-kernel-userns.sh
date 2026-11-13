#!/usr/bin/env bash
set -Eeuo pipefail
if [[ $# -lt 1 || $# -gt 2 ]]; then echo "Usage: $0 KERNEL_SOURCE [JOBS]" >&2; exit 2; fi
src=$(realpath "$1")
jobs=${2:-$(nproc)}
[[ -f "$src/Makefile" && -f "$src/.config" ]] || { echo "Kernel source/.config missing: $src" >&2; exit 2; }
config="$src/scripts/config"
[[ -x "$config" ]] || { echo "Kernel scripts/config missing; run make scripts first." >&2; exit 2; }
for opt in MULTIUSER NAMESPACES UTS_NS IPC_NS USER_NS PID_NS NET_NS POSIX_MQUEUE TMPFS DEVTMPFS DEVTMPFS_MOUNT UNIX INET DRM DRM_KMS_HELPER DRM_VIRTIO_GPU DRM_BOCHS DRM_FBDEV_EMULATION INPUT INPUT_EVDEV SECCOMP SECCOMP_FILTER; do
    "$config" --file "$src/.config" --enable "$opt"
done
make -C "$src" olddefconfig
for opt in MULTIUSER NAMESPACES USER_NS PID_NS IPC_NS UTS_NS TMPFS DEVTMPFS DRM DRM_VIRTIO_GPU INPUT_EVDEV SECCOMP SECCOMP_FILTER; do
    grep -qx "CONFIG_${opt}=y" "$src/.config" || { echo "CONFIG_${opt}=y did not survive olddefconfig" >&2; exit 1; }
done
make -C "$src" -j"$jobs" bzImage
printf 'Kernel image: %s/arch/x86/boot/bzImage\n' "$src"
printf 'Runtime gate: user.max_user_namespaces must be greater than zero.\n'
