# Fix the ponte cobble tile's built-in dark border frame, which created a
# double-thick dark grid line every 64px when tiled back-to-back.
# Approach: detect the dark perimeter band, replace it by extending the
# interior cobble pattern outward (mirror-pad from just inside the frame),
# then re-apply a 6px edge cross-fade so it stays seamless.
import numpy as np
from PIL import Image
import os

SRC = r"c:\TheInfernoCurse\The Inferno's Curse\sprites\spr_ponte_floor_cobble\40745240-83c5-4d6d-bafd-4b7332ff3513.png"
OUT = r"c:\TheInfernoCurse\tools\_texture_out\cobble_fixed_64.png"
os.makedirs(os.path.dirname(OUT), exist_ok=True)

im = Image.open(SRC).convert("RGB")
a = np.asarray(im, dtype=np.float64)
h, w, _ = a.shape

# Measure brightness per row/col; the frame is the dark band at the margins.
lum = a.mean(axis=2)
row_mean = lum.mean(axis=1)
col_mean = lum.mean(axis=1) if False else lum.mean(axis=0)
overall = lum.mean()

# Frame thickness: how many edge rows/cols are notably darker than centre.
def band(mean_line):
    t = 0
    for v in mean_line:
        if v < overall * 0.82:   # >18% darker than average = frame
            t += 1
        else:
            break
    return t

top    = band(row_mean)
bottom = band(row_mean[::-1])
left   = band(col_mean)
right  = band(col_mean[::-1])
# clamp to something sane (1..6)
top, bottom, left, right = [min(max(b, 0), 6) for b in (top, bottom, left, right)]
print(f"detected frame px  top={top} bottom={bottom} left={left} right={right}")

# Crop away the frame to the clean interior, then resize back up to 64 so the
# cobble pattern fills the full tile edge-to-edge (no dark perimeter).
x0, y0, x1, y1 = left, top, w - right, h - bottom
interior = im.crop((x0, y0, x1, y1)).resize((w, h), Image.BILINEAR)

# 6px edge cross-fade for seamless tiling (same trick as before).
arr = np.asarray(interior, dtype=np.float64)
band_px = 6
out = arr.copy()
for i in range(band_px):
    wgt = 0.5 - (i + 1) / (band_px + 1) * 0.5
    out[i, :, :]        = arr[i, :, :]        * (1 - wgt) + arr[h - band_px + i, :, :] * wgt
    out[h - 1 - i, :]   = arr[h - 1 - i, :]   * (1 - wgt) + arr[band_px - 1 - i, :]    * wgt
arr2 = out.copy()
for i in range(band_px):
    wgt = 0.5 - (i + 1) / (band_px + 1) * 0.5
    out[:, i, :]        = arr2[:, i, :]        * (1 - wgt) + arr2[:, w - band_px + i, :] * wgt
    out[:, w - 1 - i, :]= arr2[:, w - 1 - i, :]* (1 - wgt) + arr2[:, band_px - 1 - i, :]  * wgt

Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB").save(OUT)
print("wrote", OUT)
