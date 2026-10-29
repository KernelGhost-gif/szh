# Toybox Linux Shell

A minimal Linux environment built around the Toybox command-line utilities, a custom Linux kernel, and a lightweight userspace.

## Overview

Toybox Linux is a custom Linux distribution project focused on building a functional, lightweight operating system from the ground up.

The project combines a Linux kernel, Toybox utilities, a musl-based root filesystem, and a Wayland-based graphical environment. The goal is to provide a minimal but usable Linux system with a command-line interface and the foundations for a graphical desktop.

This is a real operating-system development project, not a terminal simulator.

## Features and Components

- **Linux Kernel:** Linux 6.18 series.
- **Toybox:** Lightweight implementations of common Unix and Linux command-line utilities.
- **musl Userspace:** A minimal root filesystem using musl libc.
- **Init System:** Startup configuration using `inittab` and `rcS`.
- **Shell:** `/bin/sh` as the initial command-line interface.
- **Wayland:** A foundation for graphical sessions.
- **wlroots:** A library for building Wayland compositors.
- **tinywl:** A minimal Wayland compositor.
- **QEMU:** Intended for virtual-machine testing and development.

## Project Structure

The project contains components for building and assembling a minimal Linux system.

```text
linux_distro_original/
├── Linux kernel
├── Toybox utilities
├── Root filesystem
├── Startup configuration
│   ├── inittab
│   └── rcS
├── Wayland and wlroots components
├── tinywl compositor
└── Additional development files
```

Note: This is a conceptual overview. Exact filenames and directory locations may differ in the current source tree.

## How It Works

The system is assembled from several layers:

1. The Linux kernel initializes the hardware and core system facilities.
2. The root filesystem provides essential userspace files and libraries.
3. The init configuration starts the initial shell and required system services.
4. Toybox supplies lightweight command-line utilities.
5. Wayland, wlroots, and tinywl provide the foundation for a graphical session.

The components are assembled into a minimal Linux environment intended for development, experimentation, and further customization.

## Toybox

Toybox provides compact implementations of common command-line utilities in a single multicall executable.

Depending on the applets included in the build, these utilities can support everyday tasks such as file management, text processing, directory navigation, and system inspection.

Toybox applet availability depends on the configuration used to build it.

## Building and Development

The project has been developed using Linux build tools and a Linux development environment.

The general workflow is:

1. Obtain and configure the Linux kernel source.
2. Build Toybox with the required applets.
3. Prepare the root filesystem and copy the required binaries and libraries.
4. Configure system startup through `inittab` and `rcS`.
5. Include the required Wayland and compositor components.
6. Assemble the system image or filesystem.
7. Boot and test the environment, including through QEMU where configured.

Exact build commands depend on the current source tree, toolchain, kernel configuration, and build scripts.

## Current Development Goals

The project aims to provide a minimal, functional Linux environment with:

- A working command-line shell.
- Essential Unix utilities.
- A correctly configured root filesystem.
- Reliable system initialization.
- A lightweight graphical environment.
- Virtual-machine testing and iterative development.

Additional desktop integration and usability improvements can be developed as the system evolves.

## Philosophy

The goal is to understand and build the operating-system stack rather than rely entirely on a preassembled desktop distribution.

The project emphasizes lightweight components, direct control over the system, and learning through hands-on Linux development.

## Disclaimer

This project is under development. Features, configurations, and build procedures may change. Not every component described here is necessarily enabled or fully functional in every build.

## License

szh combines multiple upstream projects. Each component retains its own licensing terms. Refer to the relevant upstream source repositories and included license files for details.

The project itself uses the GNU license.
