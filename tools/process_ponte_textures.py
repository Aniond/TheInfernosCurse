# Process Ponte Vecchio texture batch (2026-06-10):
#  1. Download the two PixelLab map objects (Pietra Forte tile + Serena strip)
#  2. Measure real sizes (PixelLab status lines lie)
#  3. Flatten full-bleed over a base colour (corner transparency fix)
#  4. 6px edge cross-fade on the floor tile (proven ponte seamless trick)
#  5. Derive a tangent-space normal map from the CURRENT floor albedo
#     (spr_ponte_floor_cobble) — luminance->height->Sobel->RGB encode.
#     OpenGL convention: +Y green = up. Mortar (dark) reads recessed.
import io, os, sys, uuid, urllib.request
import numpy as np
from PIL import Image

ROOT   = r"c:\TheInfernoCurse\The Inferno's Curse\sprites"
OUTDIR = r"c:\TheInfernoCurse\tools\_texture_out"
os.makedirs(OUTDIR, exist_ok=True)

JOBS = {
    "pietra": "https://api.pixellab.ai/mcp/map-objects/4036cf03-dc42-4f03-b45d-acebd7741136/download",
    "serena": "https://api.pixellab.ai/mcp/map-objects/b94a3629-19f0-4400-9fc8-f67c06cf9562/download",
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
    """Make a tile seamless: blend each edge with the opposite edge over `band` px."""
    a = np.asarray(img.convert("RGB"), dtype=np.float64)
    h, w, _ = a.shape
    out = a.copy()
    for i in range(band):
        t = (i + 1) / (band + 1) * 0.5          # 0.5 max blend at the very edge
        wgt = 0.5 - t                            # stronger blend nearer the edge
        out[i, :, :]      = a[i, :, :]      * (1 - wgt) + a[h - band + i, :, :] * wgt
        out[h - 1 - i, :] = a[h - 1 - i, :] * (1 - wgt) + a[band - 1 - i, :]    * wgt
    a2 = out.copy()
    for i in range(band):
        wgt = 0.5 - (i + 1) / (band + 1) * 0.5
        out[:, i, :]          = a2[:, i, :]          * (1 - wgt) + a2[:, w - band + i, :] * wgt
        out[:, w - 1 - i, :]  = a2[:, w - 1 - i, :]  * (1 - wgt) + a2[:, band - 1 - i, :] * wgt
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

def normal_from_albedo(img, strength=2.2):
    """Tangent-space normal map: luminance->height, wrapped Sobel, OpenGL +Y up."""
    rgb = np.asarray(img.convert("RGB"), dtype=np.float64) / 255.0
    hgt = rgb[:, :, 0] * 0.299 + rgb[:, :, 1] * 0.587 + rgb[:, :, 2] * 0.114
    # light 3x3 box blur (wrapped) to soften pixel noise
    acc = np.zeros_like(hgt)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            acc += np.roll(np.roll(hgt, dy, 0), dx, 1)
    hgt = acc / 9.0
    # wrapped Sobel gradients (tile-safe)
    def shift(m, dy, dx): return np.roll(np.roll(m, dy, 0), dx, 1)
    gx = (shift(hgt,-1,-1) + 2*shift(hgt,0,-1) + shift(hgt,1,-1)
        - shift(hgt,-1, 1) - 2*shift(hgt,0, 1) - shift(hgt,1, 1))
    gy = (shift(hgt,-1,-1) + 2*shift(hgt,-1,0) + shift(hgt,-1,1)
        - shift(hgt, 1,-1) - 2*shift(hgt, 1,0) - shift(hgt, 1,1))
    # screen y grows downward; OpenGL green = up  ->  gy sign flips
    nx = gx * strength
    ny = -gy * strength
    nz = np.ones_like(nx)
    ln = np.sqrt(nx*nx + ny*ny + nz*nz)
    n = np.stack(((nx/ln + 1) * 127.5, (ny/ln + 1) * 127.5, (nz/ln + 1) * 127.5), axis=-1)
    return Image.fromarray(np.clip(n, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

report = []

# 1+2. download + measure
imgs = {}
for key, url in JOBS.items():
    img = fetch(url)
    imgs[key] = img
    corners = [img.getpixel((x, y))[3] for x, y in
               [(0,0), (img.width-1,0), (0,img.height-1), (img.width-1,img.height-1)]]
    report.append(f"{key}: measured {img.width}x{img.height}, corner alphas {corners}")

# 3+4. Pietra Forte floor tile: flatten over ochre, resize to 64 if needed, cross-fade
pietra = imgs["pietra"]
if pietra.size != (64, 64):
    pietra = pietra.resize((64, 64), Image.NEAREST)
pietra = flatten(pietra, (146, 120, 84))          # ochre base under any gaps
pietra = crossfade(pietra, 6)
pietra.save(os.path.join(OUTDIR, "pietra_floor_64.png"))
report.append("pietra: flattened + 6px cross-fade -> pietra_floor_64.png")

# Serena strip: flatten over blue-gray, crop vertically to content rows, width-fade
serena = imgs["serena"]
arr = np.asarray(serena)
rows = np.where(arr[:, :, 3].max(axis=1) > 16)[0]
if len(rows) > 0:
    serena = serena.crop((0, int(rows.min()), serena.width, int(rows.max()) + 1))
report.append(f"serena: content rows -> cropped to {serena.width}x{serena.height}")
# normalize to 64x16 curb strip
serena = serena.resize((64, 16), Image.NEAREST)
serena = flatten(serena, (96, 104, 118))
serena.save(os.path.join(OUTDIR, "serena_border_64x16.png"))
report.append("serena: flattened -> serena_border_64x16.png (64x16)")

# 5. normal map from the CURRENT cobble albedo (per-texel aligned)
cobble_png = os.path.join(ROOT, "spr_ponte_floor_cobble", "40745240-83c5-4d6d-bafd-4b7332ff3513.png")
cob = Image.open(cobble_png).convert("RGBA")
report.append(f"cobble albedo: {cob.width}x{cob.height}")
nrm = normal_from_albedo(cob)
nrm.save(os.path.join(OUTDIR, "cobble_normal_64.png"))
mean = np.asarray(nrm.convert("RGB")).mean(axis=(0, 1))
report.append(f"normal: mean RGB {mean.round(1)} (expect ~[127,127,200+]) -> cobble_normal_64.png")

print("\n".join(report))
