#!/usr/bin/env python3
"""Rasterize the Zivybb mark into the PNGs Android needs.

The shape is the same one in ``assets/images/zivybb_logo.svg`` — the
coordinates below are copied from that file, so editing the SVG means
editing the constants here too (and vice versa).

Nothing in the build runs this; it is a one-shot generator kept in the repo
so the icons can be regenerated from source rather than being opaque
binaries. Requires numpy + Pillow::

    python3 tools/zivybb_logo.py
"""

from __future__ import annotations

import os

import numpy as np
from PIL import Image

# --- Geometry, in the SVG's 512x512 user space -------------------------
CANVAS = 512.0
STROKE_WIDTH = 62.0
CORNER_RADIUS = 114.0

# Top bar -> descending diagonal -> kicked-up tail. Already rotated 8
# degrees; see the note in zivybb_logo.svg.
POINTS = [
    (116.9, 164.5),
    (350.6, 131.6),
    (230.4, 382.8),
    (385.9, 282.2),
]

STROKE_GRADIENT_START = (100.0, 110.0)
STROKE_GRADIENT_END = (400.0, 400.0)
STROKE_STOPS = [
    (0.00, (0x22, 0xD3, 0xEE)),
    (0.45, (0x8B, 0x5C, 0xF6)),
    (1.00, (0xF4, 0x3F, 0x8E)),
]

BACKDROP_TOP = (0x1A, 0x17, 0x30)
BACKDROP_BOTTOM = (0x0E, 0x0C, 0x18)

SUPERSAMPLE = 4


def _sample_grid(size: int) -> tuple[np.ndarray, np.ndarray]:
    """Pixel-center coordinates for a supersampled `size`x`size` render,
    expressed back in the 512-unit design space."""
    n = size * SUPERSAMPLE
    axis = (np.arange(n) + 0.5) * (CANVAS / n)
    return np.meshgrid(axis, axis)


def _distance_to_polyline(xs: np.ndarray, ys: np.ndarray) -> np.ndarray:
    """Shortest distance from every sample to the mark's centerline.

    Thresholding this against half the stroke width is what gives the
    round caps and round joins the SVG asks for: the set of points within
    r of a segment is a capsule, and the union of capsules rounds every
    corner automatically.
    """
    best = np.full(xs.shape, np.inf)
    for (ax, ay), (bx, by) in zip(POINTS, POINTS[1:]):
        abx, aby = bx - ax, by - ay
        length_sq = abx * abx + aby * aby
        t = ((xs - ax) * abx + (ys - ay) * aby) / length_sq
        np.clip(t, 0.0, 1.0, out=t)
        dx = xs - (ax + t * abx)
        dy = ys - (ay + t * aby)
        np.minimum(best, np.hypot(dx, dy), out=best)
    return best


def _distance_to_rounded_rect(xs: np.ndarray, ys: np.ndarray) -> np.ndarray:
    half = CANVAS / 2.0
    inner = half - CORNER_RADIUS
    dx = np.abs(xs - half) - inner
    dy = np.abs(ys - half) - inner
    return np.hypot(np.maximum(dx, 0.0), np.maximum(dy, 0.0)) - CORNER_RADIUS


def _ramp(stops, t: np.ndarray) -> np.ndarray:
    """Piecewise-linear colour ramp; `t` in [0, 1] -> float RGB."""
    out = np.zeros(t.shape + (3,), dtype=np.float64)
    for (t0, c0), (t1, c1) in zip(stops, stops[1:]):
        band = (t >= t0) & (t <= t1)
        local = (t[band] - t0) / (t1 - t0)
        for channel in range(3):
            out[band, channel] = c0[channel] + local * (
                c1[channel] - c0[channel]
            )
    out[t < stops[0][0]] = stops[0][1]
    out[t > stops[-1][0]] = stops[-1][1]
    return out


def _stroke_colour(xs: np.ndarray, ys: np.ndarray) -> np.ndarray:
    gx = STROKE_GRADIENT_END[0] - STROKE_GRADIENT_START[0]
    gy = STROKE_GRADIENT_END[1] - STROKE_GRADIENT_START[1]
    t = ((xs - STROKE_GRADIENT_START[0]) * gx +
         (ys - STROKE_GRADIENT_START[1]) * gy) / (gx * gx + gy * gy)
    return _ramp(STROKE_STOPS, np.clip(t, 0.0, 1.0))


def _downsample(block: np.ndarray, size: int) -> np.ndarray:
    """Average each SUPERSAMPLE x SUPERSAMPLE cell — this is the antialiasing."""
    trailing = block.shape[2:]
    return block.reshape(
        (size, SUPERSAMPLE, size, SUPERSAMPLE) + trailing
    ).mean(axis=(1, 3))


def render(size: int, *, backdrop: bool, scale: float = 1.0) -> Image.Image:
    """Render the mark at `size` px.

    `scale` shrinks the mark about the canvas centre without shrinking the
    canvas, which is how the adaptive-icon foreground keeps the mark inside
    Android's safe zone.
    """
    xs, ys = _sample_grid(size)
    if scale != 1.0:
        centre = CANVAS / 2.0
        xs = centre + (xs - centre) / scale
        ys = centre + (ys - centre) / scale

    rgb = np.zeros(xs.shape + (3,), dtype=np.float64)
    alpha = np.zeros(xs.shape, dtype=np.float64)

    if backdrop:
        inside_card = _distance_to_rounded_rect(xs, ys) <= 0.0
        vertical = np.clip(ys / CANVAS, 0.0, 1.0)
        card = _ramp([(0.0, BACKDROP_TOP), (1.0, BACKDROP_BOTTOM)], vertical)
        rgb[inside_card] = card[inside_card]
        alpha[inside_card] = 1.0

    inside_stroke = _distance_to_polyline(xs, ys) <= STROKE_WIDTH / 2.0
    stroke = _stroke_colour(xs, ys)
    rgb[inside_stroke] = stroke[inside_stroke]
    alpha[inside_stroke] = 1.0

    # Premultiply before averaging so partially-covered edge pixels don't
    # pick up colour from fully transparent samples.
    flat = _downsample(rgb * alpha[..., None], size)
    flat_alpha = _downsample(alpha, size)
    with np.errstate(invalid="ignore", divide="ignore"):
        unpremultiplied = np.where(
            flat_alpha[..., None] > 0, flat / flat_alpha[..., None], 0.0
        )

    rgba = np.concatenate(
        [unpremultiplied, flat_alpha[..., None] * 255.0], axis=2
    )
    return Image.fromarray(np.round(rgba).astype(np.uint8), mode="RGBA")


# Android launcher densities, in px.
LEGACY_DENSITIES = {
    "mdpi": 48,
    "hdpi": 72,
    "xhdpi": 96,
    "xxhdpi": 144,
    "xxxhdpi": 192,
}
# Adaptive-icon layers are 108dp with only the inner 72dp (66%) guaranteed
# visible under every launcher mask. The mark already occupies ~65% of the
# design canvas, so this scales it to land at ~59% — comfortably inside the
# safe zone without leaving it looking lost in the middle of the tile.
ADAPTIVE_DENSITIES = {
    "mdpi": 108,
    "hdpi": 162,
    "xhdpi": 216,
    "xxhdpi": 324,
    "xxxhdpi": 432,
}
ADAPTIVE_MARK_SCALE = 0.92


def main() -> None:
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    images = os.path.join(root, "assets", "images")
    res = os.path.join(root, "android", "app", "src", "main", "res")
    os.makedirs(images, exist_ok=True)

    render(512, backdrop=False).save(os.path.join(images, "zivybb_logo.png"))
    render(512, backdrop=True).save(os.path.join(images, "zivybb_icon.png"))
    print("wrote assets/images/zivybb_logo.png, zivybb_icon.png")

    for density, px in LEGACY_DENSITIES.items():
        folder = os.path.join(res, f"mipmap-{density}")
        os.makedirs(folder, exist_ok=True)
        render(px, backdrop=True).save(os.path.join(folder, "ic_launcher.png"))
    print("wrote mipmap-*/ic_launcher.png")

    for density, px in ADAPTIVE_DENSITIES.items():
        folder = os.path.join(res, f"mipmap-{density}")
        os.makedirs(folder, exist_ok=True)
        render(px, backdrop=False, scale=ADAPTIVE_MARK_SCALE).save(
            os.path.join(folder, "ic_launcher_foreground.png")
        )
    print("wrote mipmap-*/ic_launcher_foreground.png")


if __name__ == "__main__":
    main()
