#!/usr/bin/env python3
"""Create a reproducible gzip-compressed newc initramfs."""
from __future__ import annotations
import gzip
import os
import stat
import sys
from pathlib import Path

def pad4(stream, size):
    if size % 4:
        stream.write(b"\0" * (4 - size % 4))

def header(stream, fields):
    stream.write(b"070701")
    stream.write("".join(f"{v & 0xffffffff:08x}" for v in fields).encode("ascii"))

def entry(stream, ino, name, mode, uid, gid, epoch, nlink, data=b"", rmajor=0, rminor=0):
    encoded = name.encode("utf-8", "surrogateescape") + b"\0"
    fields = [ino, mode, uid, gid, nlink, epoch, len(data), 0, 0, rmajor, rminor, len(encoded), 0]
    header(stream, fields)
    stream.write(encoded)
    pad4(stream, 110 + len(encoded))
    stream.write(data)
    pad4(stream, len(data))

def collect(root):
    items = {".": root}
    for current, dirs, files in os.walk(root, topdown=True, followlinks=False):
        base = Path(current)
        dirs.sort()
        files.sort()
        for name in list(dirs):
            path = base / name
            items[path.relative_to(root).as_posix()] = path
            if path.is_symlink():
                dirs.remove(name)
        for name in files:
            path = base / name
            items[path.relative_to(root).as_posix()] = path
    return items

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {Path(sys.argv[0]).name} ROOTFS OUTPUT.cpio.gz", file=sys.stderr)
        return 2
    root, out = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
    if not root.is_dir():
        raise SystemExit(f"Rootfs directory does not exist: {root}")
    if root == out or root in out.parents:
        raise SystemExit("Output must be outside the rootfs tree")
    try:
        epoch = int(os.environ.get("SOURCE_DATE_EPOCH", "0"))
    except ValueError:
        raise SystemExit("SOURCE_DATE_EPOCH must be an integer")
    if epoch < 0 or epoch > 0xffffffff:
        raise SystemExit("SOURCE_DATE_EPOCH must fit the unsigned 32-bit newc mtime")
    items = collect(root)
    devices = {
        "dev/console": (stat.S_IFCHR | 0o600, 5, 1),
        "dev/null": (stat.S_IFCHR | 0o666, 1, 3),
        "dev/tty": (stat.S_IFCHR | 0o666, 5, 0),
        "dev/tty0": (stat.S_IFCHR | 0o620, 4, 0),
        "dev/ttyS0": (stat.S_IFCHR | 0o620, 4, 64),
    }
    for name in devices:
        items.setdefault(name, None)
    out.parent.mkdir(parents=True, exist_ok=True)
    tmp = out.with_name(out.name + ".tmp")
    ino = count = 1
    try:
        with tmp.open("wb") as raw:
            with gzip.GzipFile(filename="", mode="wb", compresslevel=9, fileobj=raw, mtime=0) as gz:
                for rel in sorted(items, key=lambda s: s.encode("utf-8", "surrogateescape")):
                    path = items[rel]
                    if rel in devices and (path is None or not stat.S_ISCHR(os.lstat(path).st_mode)):
                        mode, rmajor, rminor = devices[rel]
                        uid = gid = 0
                        nlink, data = 1, b""
                    else:
                        if path is None:
                            continue
                        st = os.lstat(path)
                        mode = st.st_mode
                        uid = gid = 0
                        nlink = 2 if stat.S_ISDIR(mode) else 1
                        rmajor = rminor = 0
                        if stat.S_ISLNK(mode):
                            data = os.readlink(path).encode("utf-8", "surrogateescape")
                        elif stat.S_ISCHR(mode) or stat.S_ISBLK(mode):
                            rmajor, rminor, data = os.major(st.st_rdev), os.minor(st.st_rdev), b""
                        else:
                            data = b""
                    if (rel == "home/brainos" or rel.startswith("home/brainos/")
                            or rel == "run/user/1000" or rel.startswith("run/user/1000/")):
                        uid = gid = 1000
                    if rel == "etc/shadow":
                        mode = stat.S_IFREG | 0o600
                    if rel in ("sbin/brainos-launch", "opt/brainos/bin/brainos-session",
                               "opt/brainos/bin/brainos-desktop"):
                        mode = stat.S_IFREG | 0o755
                    if stat.S_ISREG(mode):
                        size = os.lstat(path).st_size
                        encoded = rel.encode("utf-8", "surrogateescape") + b"\0"
                        header(gz, [ino, mode, uid, gid, nlink, epoch, size, 0, 0, 0, 0, len(encoded), 0])
                        gz.write(encoded)
                        pad4(gz, 110 + len(encoded))
                        with path.open("rb") as source:
                            while chunk := source.read(1024 * 1024):
                                gz.write(chunk)
                        pad4(gz, size)
                    else:
                        entry(gz, ino, rel, mode, uid, gid, epoch, nlink, data, rmajor, rminor)
                    ino += 1
                    count += 1
                entry(gz, ino, "TRAILER!!!", 0, 0, 0, epoch, 1)
        os.replace(tmp, out)
    finally:
        if tmp.exists():
            tmp.unlink()
    print(f"Wrote {out} ({out.stat().st_size} bytes; {count} entries; epoch={epoch})")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
