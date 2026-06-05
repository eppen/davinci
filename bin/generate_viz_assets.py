#!/usr/bin/env python3
"""Generate missing Davinci viz background PNG assets (bg1-bg19, profile, noDashboard)."""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

OUT_DIR = Path(__file__).resolve().parents[1] / "webapp" / "app" / "assets" / "images"

PALETTES = [
    (27, 152, 224),
    (34, 87, 122),
    (46, 125, 50),
    (198, 40, 40),
    (142, 36, 170),
    (230, 81, 0),
    (0, 121, 107),
    (63, 81, 181),
    (121, 85, 72),
    (69, 90, 100),
    (25, 118, 210),
    (56, 142, 60),
    (211, 47, 47),
    (123, 31, 162),
    (245, 124, 0),
    (0, 150, 136),
    (92, 107, 192),
    (141, 110, 99),
    (84, 110, 122),
]


def png_chunk(tag: bytes, data: bytes) -> bytes:
    crc = zlib.crc32(tag + data) & 0xFFFFFFFF
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)


def write_solid_png(path: Path, width: int, height: int, rgb: tuple[int, int, int]) -> None:
    row = b"\x00" + bytes(rgb) * width
    raw = row * height
    compressed = zlib.compress(raw, 9)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    png = (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", ihdr)
        + png_chunk(b"IDAT", compressed)
        + png_chunk(b"IEND", b"")
    )
    path.write_bytes(png)


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for i, rgb in enumerate(PALETTES, start=1):
        write_solid_png(OUT_DIR / f"bg{i}.png", 320, 180, rgb)
        print(f"Wrote bg{i}.png")
    write_solid_png(OUT_DIR / "profile.png", 96, 96, (27, 152, 224))
    write_solid_png(OUT_DIR / "noDashboard.png", 240, 160, (224, 236, 244))
    print("Wrote profile.png, noDashboard.png")


if __name__ == "__main__":
    main()
