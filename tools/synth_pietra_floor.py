# Procedural seamless Pietra Forte floor tile — the guaranteed-seamless path
# (PixelLab kept making gridded/striped/centered tiles). Builds a 64x64 tile of
# fine irregular packed stones with TRUE toroidal wrap (every stone that crosses
# an edge is drawn again on the opposite side), so it tiles with zero seams and
# has NO regular grid/rows/columns. Warm golden-brown sandstone palette.
import numpy as np
from PIL import Image
import os, math

OUT = r"c:\TheInfernoCurse\tools\_texture_out"
S = 64
rng = np.random.RandomState(13)   # deterministic — same tile every run

# base warm sandstone with low-freq mottling
img = np.zeros((S, S, 3), dtype=np.float64)
base = np.array([164, 138, 96], dtype=np.float64)
# value-noise mottle (a few sine octaves, wrap-safe)
mottle = np.zeros((S, S))
for (fx, fy, ph, amp) in [(1,1,0.3,0.5),(2,1,1.1,0.3),(1,2,2.0,0.3),(3,2,0.7,0.2)]:
    xx, yy = np.meshgrid(np.arange(S), np.arange(S))
    mottle += amp * np.sin(2*math.pi*(fx*xx/S) + ph) * np.sin(2*math.pi*(fy*yy/S) + ph*1.3)
mottle = (mottle - mottle.min()) / (mottle.max() - mottle.min())
for c in range(3):
    img[:,:,c] = base[c] * (0.86 + 0.20 * mottle)

def stamp(cx, cy, rx, ry, ang, col, edge):
    # draw one rounded irregular stone (rotated ellipse) with darker mortar edge,
    # wrapping across tile borders for seamless tiling
    for ox in (-S, 0, S):
        for oy in (-S, 0, S):
            x0 = int(cx+ox-rx-2); x1 = int(cx+ox+rx+2)
            y0 = int(cy+oy-ry-2); y1 = int(cy+oy+ry+2)
            for py in range(max(0,y0), min(S,y1)):
                for px in range(max(0,x0), min(S,x1)):
                    dx = px-(cx+ox); dy = py-(cy+oy)
                    rxr =  dx*math.cos(ang)+dy*math.sin(ang)
                    ryr = -dx*math.sin(ang)+dy*math.cos(ang)
                    d = (rxr/rx)**2 + (ryr/ry)**2
                    if d <= 1.0:
                        t = max(0.0, (d-0.55)/0.45)         # darken toward edge = mortar groove
                        img[py,px,:] = col*(1-t*0.5) + edge*(t*0.5)

# scatter many small irregular stones (no grid — jittered positions)
N = 90
for i in range(N):
    cx = rng.uniform(0, S); cy = rng.uniform(0, S)
    r  = rng.uniform(3.2, 5.6)
    rx = r * rng.uniform(0.8, 1.25); ry = r * rng.uniform(0.8, 1.25)
    ang = rng.uniform(0, math.pi)
    tone = rng.uniform(0.82, 1.12)
    col  = np.clip(base * tone + rng.uniform(-10,10,3), 60, 235)
    edge = base * 0.55
    stamp(cx, cy, rx, ry, ang, col, edge)

# subtle per-pixel grain
grain = rng.uniform(-6, 6, (S,S,1))
img = np.clip(img + grain, 0, 255)

# final 4px edge cross-fade for safety (the wrap already makes it seamless)
band = 4
a = img.copy()
for i in range(band):
    w = 0.5 - (i+1)/(band+1)*0.5
    a[i,:,:]      = img[i,:,:]      *(1-w) + img[S-band+i,:,:]*w
    a[S-1-i,:,:]  = img[S-1-i,:,:]  *(1-w) + img[band-1-i,:,:]*w
b = a.copy()
for i in range(band):
    w = 0.5 - (i+1)/(band+1)*0.5
    a[:,i,:]      = b[:,i,:]      *(1-w) + b[:,S-band+i,:]*w
    a[:,S-1-i,:]  = b[:,S-1-i,:]  *(1-w) + b[:,band-1-i,:]*w

fin = Image.fromarray(np.clip(a,0,255).astype('uint8'),'RGB').convert('RGBA')
fin.save(os.path.join(OUT,'pietra_synth_64.png'))
prev = Image.new('RGBA',(192,192))
for y in range(3):
    for x in range(3): prev.paste(fin,(x*64,y*64))
prev.save(os.path.join(OUT,'pietra_synth_3x3.png'))
print('synth floor written + 3x3 preview')
