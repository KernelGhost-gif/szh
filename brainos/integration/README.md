# BrainOS integration layer for SZH

This branch-side integration layer keeps the existing Toybox/musl userspace intact. The supplied Qt 6 desktop is a glibc ELF, so its runtime belongs under /opt/brainos/runtime. Do not overwrite /lib/ld-musl-x86_64.so.1 or replace Toybox applets.

## Ground-truth audit

The uploaded kit manifest gives the prebuilt binary SHA-256 a981a64021de4a924002884ee339f9c82308003fe92321b1260bbaca6d8f1356. ELF inspection shows PT_INTERP=/lib64/ld-linux-x86-64.so.2 and direct dependencies on Qt6WaylandCompositor, Qt6Quick, Qt6Gui, Qt6DBus, Qt6Qml, Qt6Network, Qt6Core, libstdc++, libm, libgcc_s, and libc. On the inspected host, ldd reports the seven direct Qt libraries as not found. The ZIP does not include the matching glibc/Qt/WebEngine runtime bundle; desktop boot is not yet a verified gate.

## Dual boot contract

Install brainos-launch at /sbin/brainos-launch, brainos-session at /opt/brainos/bin/brainos-session, and the desktop executable at /opt/brainos/bin/brainos-desktop. Add /lib64/ld-linux-x86-64.so.2 pointing to the extracted glibc loader. Extract the amd64 glibc/Qt runtime under /opt/brainos/runtime. Keep /lib/ld-musl-x86_64.so.1 unchanged.

Set brainos.mode=cli on the kernel command line to boot directly to /bin/sh. brainos.mode=desktop requests BrainOS; desktop is the launcher's default, with Toybox CLI fallback when payload/account/su is absent or the desktop exits. The launcher never disables the Chromium sandbox and runs the desktop through Toybox su as unprivileged user brainos.

The init integration must change only the existing ::respawn:/bin/sh line in /etc/inittab to ::respawn:/sbin/brainos-launch after runtime/account staging. Mount proc, sysfs, devtmpfs, devpts, tmpfs at /dev/shm and tmpfs at /run before respawning the launcher.

## Kernel rebuild

Run brainos/integration/configure-kernel-userns.sh linux_distro_original/src/linux. It applies namespace, tmpfs/devtmpfs, DRM/virtio GPU/Bochs/fbdev, evdev and seccomp options; runs make olddefconfig; rejects USER_NS being silently disabled; and builds bzImage. At runtime check /proc/sys/user/max_user_namespaces > 0. Do not assume kernel.unprivileged_userns_clone exists on every upstream kernel. Never disable the Chromium sandbox to work around missing kernel support.

## Deterministic initramfs

Run:

    SOURCE_DATE_EPOCH=0 python3 brainos/integration/pack_initramfs.py ROOTFS /tmp/initramfs.cpio.gz
    bash brainos/integration/test-initramfs-reproducible.sh ROOTFS brainos/integration/pack_initramfs.py

The packer fixes all cpio mtimes to SOURCE_DATE_EPOCH (default 0), normalizes uid/gid (uid/gid 1000 only for the BrainOS home/runtime subtrees), assigns inode numbers in bytewise sorted path order, and writes gzip with mtime=0 and no original filename. The source tree is not modified.

## CMake and build dependencies

The supplied CMakeLists requires Qt6 Core, DBus, Gui, Qml, Quick, QuickControls2, WaylandCompositor and WebEngineQuick. On Ubuntu/Debian install at least:

    sudo apt-get install build-essential cmake ninja-build pkg-config qt6-base-dev qt6-declarative-dev qt6-wayland-dev qt6-webengine-dev qt6-tools-dev qt6-tools-dev-tools

Also install the matching QPA plugins and QML modules for QtWayland compositor and QtWebEngine. The runtime needs glibc, libstdc++, ICU, NSS/NSPR, OpenSSL, CA certificates, D-Bus, fontconfig/FreeType/fonts, Mesa EGL/GLES/GBM/DRM, Wayland client/server/EGL, xkbcommon, QtWebEngineProcess, .pak resources and locale packs. Names vary by distribution; resolve the complete amd64 dependency closure on the target distro rather than assuming a fixed short package list. Source builds need Qt development packages; prebuilt staging needs the exact runtime closure, QPA plugins, QML modules and WebEngine assets.

## Required proof gates

1. Verify prebuilt SHA-256 against the kit manifest.
2. Use readelf and the matching staged glibc loader to inspect the main binary, every QPA/QML plugin, and QtWebEngineProcess. Reject any missing library.
3. Verify Toybox sh, su and id still request /lib/ld-musl-x86_64.so.1 and that the musl loader remains unchanged.
4. Run the timestamp perturbation test and record identical A/B hashes.
5. Boot QEMU with brainos.mode=cli and exercise sh, su and id.
6. Boot QEMU with a graphical virtual GPU and brainos.mode=desktop; require an actual compositor startup marker and stable process. Capture serial and graphical/VNC output. A serial-only kernel boot is not proof of GUI startup.

No graphical QEMU success is claimed until all six gates pass with the real runtime closure and desktop executable present.
