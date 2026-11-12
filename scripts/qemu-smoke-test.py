#!/usr/bin/env python3
"""Boot the checked-in kernel and prove the initramfs shell executes commands."""

from __future__ import annotations

import os
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
KERNEL = ROOT / "linux_distro_original/src/linux/arch/x86/boot/bzImage"
DEFAULT_INITRAMFS = ROOT / "build/initramfs.cpio.gz"
TIMEOUT = max(5, int(os.environ.get("SZH_QEMU_TIMEOUT", "45")))


def read_until(
    serial: socket.socket,
    buffer: bytearray,
    pattern: bytes,
    deadline: float,
) -> None:
    while pattern not in buffer:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError(f"timed out waiting for serial output: {pattern!r}")
        serial.settimeout(remaining)
        chunk = serial.recv(4096)
        if not chunk:
            raise ConnectionError("QEMU closed the serial connection")
        buffer.extend(chunk)


def main() -> int:
    initramfs = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_INITRAMFS
    if not initramfs.is_absolute():
        initramfs = ROOT / initramfs

    qemu = shutil_which("qemu-system-x86_64")
    if not qemu:
        print("error: qemu-system-x86_64 is required", file=sys.stderr)
        return 2
    if not KERNEL.is_file() or not KERNEL.stat().st_size:
        print(f"error: kernel image missing: {KERNEL}", file=sys.stderr)
        return 2
    if not initramfs.is_file() or not initramfs.stat().st_size:
        print(f"error: initramfs missing: {initramfs}", file=sys.stderr)
        return 2

    with tempfile.TemporaryDirectory(prefix="szh-qemu-") as temporary:
        socket_path = Path(temporary) / "serial.sock"
        qemu_log = Path(temporary) / "qemu.stderr"
        command = [
            qemu,
            "-machine", "accel=tcg",
            "-m", "512M",
            "-smp", "2",
            "-kernel", str(KERNEL),
            "-initrd", str(initramfs),
            "-append", "console=ttyS0,115200 rdinit=/init loglevel=4 panic=1",
            "-display", "none",
            "-serial", f"unix:{socket_path},server=on,wait=off",
            "-monitor", "none",
            "-no-reboot",
        ]

        output = bytearray()
        process: subprocess.Popen[bytes] | None = None
        serial: socket.socket | None = None
        try:
            with qemu_log.open("wb") as stderr:
                process = subprocess.Popen(
                    command,
                    stdin=subprocess.DEVNULL,
                    stdout=subprocess.DEVNULL,
                    stderr=stderr,
                )

                connect_deadline = time.monotonic() + min(10, TIMEOUT)
                while time.monotonic() < connect_deadline:
                    if process.poll() is not None:
                        raise RuntimeError(
                            f"QEMU exited before opening serial (status {process.returncode})"
                        )
                    if socket_path.exists():
                        serial = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                        try:
                            serial.connect(str(socket_path))
                            break
                        except OSError:
                            serial.close()
                            serial = None
                    time.sleep(0.1)

                if serial is None:
                    raise TimeoutError("QEMU did not create its serial socket")

                boot_deadline = time.monotonic() + TIMEOUT
                read_until(serial, output, b"SZH_INITRAMFS_READY", boot_deadline)
                print("Initramfs startup marker received.")

                # The test command deliberately does not contain the expected
                # output token, so a serial echo of typed input cannot pass.
                serial.sendall(b"uname -m\n")
                shell_deadline = min(boot_deadline, time.monotonic() + 10)
                read_until(serial, output, b"\nx86_64\r\n", shell_deadline)
                print("Interactive init shell executed: uname -m -> x86_64")
                print("QEMU boot and shell smoke tests passed.")
                return 0

        except (OSError, TimeoutError, ConnectionError, RuntimeError) as error:
            print(f"error: {error}", file=sys.stderr)
            if output:
                print("--- guest serial output ---", file=sys.stderr)
                print(output.decode("utf-8", errors="replace"), file=sys.stderr)
            if qemu_log.exists():
                log = qemu_log.read_text(errors="replace")
                if log:
                    print("--- QEMU stderr ---", file=sys.stderr)
                    print(log, file=sys.stderr)
            return 1
        finally:
            if serial is not None:
                serial.close()
            if process is not None and process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=3)


def shutil_which(program: str) -> str | None:
    """Small PATH lookup to avoid an external Python dependency."""
    for directory in os.environ.get("PATH", "").split(os.pathsep):
        candidate = Path(directory) / program
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return None


if __name__ == "__main__":
    raise SystemExit(main())
