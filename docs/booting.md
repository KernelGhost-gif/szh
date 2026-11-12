# Booting SZH

SZH currently boots as an x86-64 initramfs guest. The committed kernel is already built; the host-side packaging step creates the initramfs from the checked-in root filesystem.

## Boot sequence

1. The Linux kernel loads the compressed newc archive as its initramfs.
2. The kernel executes `/init`, which is the Toybox init applet.
3. Toybox init reads `/etc/inittab`.
4. The sysinit action runs `/etc/init.d/rcS`.
5. `rcS` creates standard mount points, mounts devtmpfs/procfs/sysfs and temporary filesystems where available, then prints `SZH_INITRAMFS_READY`.
6. The respawn action starts `/bin/sh`.

The init script tolerates mounts that are already present, including devtmpfs auto-mounted by the kernel.

## Manual boot

From the repository root:

```sh
./scripts/build-initramfs.sh
qemu-system-x86_64 \
  -machine accel=tcg -m 512M -smp 2 \
  -kernel linux_distro_original/src/linux/arch/x86/boot/bzImage \
  -initrd build/initramfs.cpio.gz \
  -append "console=ttyS0,115200 rdinit=/init loglevel=7" \
  -display none -serial stdio -monitor none
```

Use `loglevel=7` to increase kernel logging. The serial console is important for observing the boot and interacting with the shell.

## Automated smoke test

```sh
make validate
make initramfs
SZH_QEMU_TIMEOUT=45 make test
```

The smoke test is deliberately bounded. It first requires the init script's readiness marker, then sends `uname -m` over the emulated serial console and requires the shell to return `x86_64`. A kernel banner or init marker alone is insufficient.

## Troubleshooting

- **`No working init found`:** verify that `/init` exists in the archive, is an x86-64 ELF executable, and has its required interpreter and shared libraries.
- **`Permission denied`:** run `scripts/prepare-rootfs.sh`. The packaging workflow also runs it automatically to restore executable bits.
- **No serial output:** check that the kernel config enables `CONFIG_SERIAL_8250_CONSOLE=y` and that the command line includes `console=ttyS0,115200`.
- **The smoke test times out:** inspect the captured output from the script. The test expects the init script to reach `SZH_INITRAMFS_READY`; a kernel banner alone is insufficient.
