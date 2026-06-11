# Regenerate spr_ponte_floor_normal from the CURRENT spr_ponte_floor_cobble
# albedo (the floor art was regenerated 2026-06-10 after the original normal
# derivation, so the maps were out of sync). Same derivation as
# process_ponte_textures.py step 5: luminance -> height -> wrapped Sobel ->
# OpenGL tangent-space encode (+Y green = up; mortar reads recessed).
# Writes BOTH the sprite frame PNG and its layers/ copy in place.
import os, shutil, sys
import numpy as np
from PIL import Image

SPRITES = r"c:\TheInfernoCurse\The Inferno's Curse\sprites"
ALBEDO  = os.path.join(SPRITES, "spr_ponte_floor_cobble", "40745240-83c5-4d6d-bafd-4b7332ff3513.png")
NRM_DIR = os.path.join(SPRITES, "spr_ponte_floor_normal")
NRM_PNG = os.path.join(NRM_DIR, "12ffcb36-c8f6-4208-b18a-a0e6761c6054.png")

def normal_from_albedo(img, strength=2.2):
    rgb = np.asarray(img.convert("RGB"), dtype=np.float64) / 255.0
    hgt = rgb[:, :, 0] * 0.299 + rgb[:, :, 1] * 0.587 + rgb[:, :, 2] * 0.114
    acc = np.zeros_like(hgt)
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            acc += np.roll(np.roll(hgt, dy, 0), dx, 1)
    hgt = acc / 9.0
    def shift(m, dy, dx): return np.roll(np.roll(m, dy, 0), dx, 1)
    gx = (shift(hgt,-1,-1) + 2*shift(hgt,0,-1) + shift(hgt,1,-1)
        - shift(hgt,-1, 1) - 2*shift(hgt,0, 1) - shift(hgt,1, 1))
    gy = (shift(hgt,-1,-1) + 2*shift(hgt,-1,0) + shift(hgt,-1,1)
        - shift(hgt, 1,-1) - 2*shift(hgt, 1,0) - shift(hgt, 1,1))
    nx, ny, nz = gx * strength, -gy * strength, np.ones_like(gx)
    ln = np.sqrt(nx*nx + ny*ny + nz*nz)
    n = np.stack(((nx/ln + 1) * 127.5, (ny/ln + 1) * 127.5, (nz/ln + 1) * 127.5), axis=-1)
    return Image.fromarray(np.clip(n, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

cob = Image.open(ALBEDO).convert("RGBA")
print(f"albedo: {cob.width}x{cob.height}")
# strength 4.0 (POC used 2.2 on rougher art): the regenerated procedural
# cobble is smoother, so push gradients harder to land near the POC's
# approved relief intensity (mean Z ~233).
nrm = normal_from_albedo(cob, strength=4.0)
nrm.save(NRM_PNG)
mean = np.asarray(nrm.convert("RGB")).mean(axis=(0, 1))
print(f"normal mean RGB {mean.round(1)} (expect ~[127,127,200+]) -> {NRM_PNG}")

# mirror into the layers/ frame copy (GM keeps a per-layer duplicate)
layers_root = os.path.join(NRM_DIR, "layers", "12ffcb36-c8f6-4208-b18a-a0e6761c6054")
for f in os.listdir(layers_root):
    if f.lower().endswith(".png"):
        shutil.copyfile(NRM_PNG, os.path.join(layers_root, f))
        print(f"layers copy updated: {f}")
