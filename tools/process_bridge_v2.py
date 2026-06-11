# Process the v2 bridge textures (2026-06-10):
#  Floor: fine irregular Pietra Forte stone, 64x64, 6px edge cross-fade for
#         truly seamless tiling -> overwrites spr_ponte_floor_cobble frame.
#  Canopy: dark weathered wood, downloaded then cropped/resized to a 128x32
#          horizontal beam section -> spr_ponte_canopy.
import io, os, urllib.request
import numpy as np
from PIL import Image

OUT = r"c:\TheInfernoCurse\tools\_texture_out"
os.makedirs(OUT, exist_ok=True)

JOBS = {
    "floor":  "https://api.pixellab.ai/mcp/map-objects/a9b60c54-7fe4-4049-8eb2-3bdb54cdea06/download",
    "canopy": "https://api.pixellab.ai/mcp/map-objects/f54bb545-c02e-4fb0-b478-5672d9469bb1/download",
}

def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "curl/8"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return Image.open(io.BytesIO(r.read())).convert("RGBA")

def flatten(img, base_rgb):
    base = Image.new("RGBA", img.size, base_rgb + (255,))
    base.alpha_composite(img)
    return base

def crossfade(img, band=6):
    a = np.asarray(img.convert("RGB"), dtype=np.float64)
    h, w, _ = a.shape
    out = a.copy()
    for i in range(band):
        wgt = 0.5 - (i + 1) / (band + 1) * 0.5
        out[i, :, :]      = a[i, :, :]      * (1 - wgt) + a[h - band + i, :, :] * wgt
        out[h - 1 - i, :] = a[h - 1 - i, :] * (1 - wgt) + a[band - 1 - i, :]    * wgt
    a2 = out.copy()
    for i in range(band):
        wgt = 0.5 - (i + 1) / (band + 1) * 0.5
        out[:, i, :]         = a2[:, i, :]         * (1 - wgt) + a2[:, w - band + i, :] * wgt
        out[:, w - 1 - i, :] = a2[:, w - 1 - i, :] * (1 - wgt) + a2[:, band - 1 - i, :] * wgt
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

report = []

# ---- FLOOR ----
floor = fetch(JOBS["floor"])
report.append(f"floor downloaded {floor.size}")
if floor.size != (64, 64):
    floor = floor.resize((64, 64), Image.NEAREST)
floor = flatten(floor, (150, 124, 84))     # warm sandstone base under any gaps
floor = crossfade(floor, 6)
floor.save(os.path.join(OUT, "floor_v2_64.png"))
report.append("floor -> floor_v2_64.png (flattened + 6px cross-fade)")

# ---- CANOPY ----
canopy = fetch(JOBS["canopy"])
report.append(f"canopy downloaded {canopy.size}")
# find the content band (non-transparent rows) and crop to it
arr = np.asarray(canopy)
rows = np.where(arr[:, :, 3].max(axis=1) > 16)[0]
if len(rows) > 0:
    canopy = canopy.crop((0, int(rows.min()), canopy.width, int(rows.max()) + 1))
    report.append(f"canopy cropped to content {canopy.size}")
# normalize to a 128x32 horizontal beam section, flatten over dark wood
canopy = canopy.resize((128, 32), Image.NEAREST)
canopy = flatten(canopy, (58, 42, 30))
# horizontal cross-fade only (it tiles left-right along the corridor)
a = np.asarray(canopy.convert("RGB"), dtype=np.float64)
h, w, _ = a.shape
band = 6
out = a.copy()
for i in range(band):
    wgt = 0.5 - (i + 1) / (band + 1) * 0.5
    out[:, i, :]         = a[:, i, :]         * (1 - wgt) + a[:, w - band + i, :] * wgt
    out[:, w - 1 - i, :] = a[:, w - 1 - i, :] * (1 - wgt) + a[:, band - 1 - i, :] * wgt
Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB").convert("RGBA").save(
    os.path.join(OUT, "canopy_v2_128x32.png"))
report.append("canopy -> canopy_v2_128x32.png (128x32, horizontal cross-fade)")

print("\n".join(report))
