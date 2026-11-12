# SZH — Toybox Linux

SZH is an experimental x86-64 Linux userspace assembled around Toybox, musl, and a small Wayland stack. The repository includes a prebuilt Linux kernel, a staged root filesystem, and the wlroots/tinywl sources and binaries.

This project is an operating-system experiment, not a production distribution. The automated boot test targets QEMU's x86-64 PC machine.

## What is included

- **Kernel:** Linux 6.18.37 x86-64 configuration and a prebuilt `bzImage` at `linux_distro_original/src/linux/arch/x86/boot/bzImage`.
- **Root filesystem:** `linux_distro_original/distro/fs`, including Toybox applets, a musl loader, libraries, and init configuration.
- **Init:** Toybox init is staged at `/init` and `/sbin/init`. The inittab runs `/etc/init.d/rcS` and respawns `/bin/sh`.
- **Graphical stack:** wlroots 0.18 and tinywl sources, with runtime libraries staged in `/usr/lib`.
- **Build helpers:** scripts to normalize executable permissions, validate boot inputs, and package the root filesystem as a compressed newc initramfs.

## Build and boot

On Ubuntu or Debian, install the host tools:

```sh
sudo apt-get update
sudo apt-get install -y cpio gzip qemu-system-x86 file binutils
```

From the repository root:

```sh
./scripts/validate-distro.sh
./scripts/build-initramfs.sh
./scripts/qemu-smoke-test.sh
```

The build produces `build/initramfs.cpio.gz`. The kernel is the committed prebuilt `bzImage`; this workflow packages and tests the current kernel/rootfs pair and does not claim to rebuild the kernel from a pristine source checkout.

To start QEMU yourself:

```sh
qemu-system-x86_64 \
  -machine accel=tcg -m 512M \
  -kernel linux_distro_original/src/linux/arch/x86/boot/bzImage \
  -initrd build/initramfs.cpio.gz \
  -append "console=ttyS0,115200 rdinit=/init" \
  -display none -serial stdio -monitor none
```

The init script prints `SZH_INITRAMFS_READY` after setting up runtime mount points. The smoke test looks for this marker and stops QEMU after a bounded timeout.

## Repository layout

```text
.
├── .github/workflows/ci.yml
├── docs/booting.md
├── scripts/
│   ├── prepare-rootfs.sh
│   ├── validate-distro.sh
│   ├── build-initramfs.sh
│   └── qemu-smoke-test.sh
└── linux_distro_original/
    ├── distro/fs/       # staged target root filesystem
    └── src/
        ├── linux/       # kernel source/build tree and .config
        └── wlroots/     # wlroots and tinywl sources
```

Generated images and local build outputs belong in `build/` and are not committed. The old tracked `distro/init.cpio` was an empty archive; generate a real initramfs from `distro/fs` with the build script instead.

## CI

GitHub Actions validates required files and kernel settings, checks shell syntax, creates the initramfs, and boots it using QEMU's TCG mode. Run the workflow manually from the Actions tab to publish the kernel and initramfs as a short-lived artifact.

The workflow only reads repository contents. It does not push generated files or rewrite `main`.

## Known limitations

- The checked-in kernel is a prebuilt x86-64 image. A clean, pinned, end-to-end kernel build pipeline is not yet provided.
- The presence of wlroots/tinywl and their libraries does not mean a complete graphical session is configured or hardware-tested.
- The default init configuration respawns a root shell. Do not expose this image to an untrusted network or use it as a secure multi-user system.
- QEMU boot success is a smoke test, not proof of physical-device compatibility or support for Android/ARM hosts.

## Licensing

SZH bundles components with their own upstream licenses. See the included license files and upstream project notices before redistributing a combined image.
