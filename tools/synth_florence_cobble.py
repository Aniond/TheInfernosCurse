# Procedural seamless GREY cobblestone for Florence v2 — same proven method as
# the bridge floor (toroidal-wrap irregular stones, no grid/rows/stripes/border).
# Overwrites spr_florence_road_cobble (used for roads AND plazas citywide), so
# the whole city floor goes seamless. Grey Florentine pietra serena palette to
# match the existing look, NOT the bridge's warm sandstone.
import numpy as np
from PIL import Image
import os, math

OUT = r"c:\TheInfernoCurse\tools\_texture_out"
os.makedirs(OUT, exist_ok=True)
S = 64
rng = np.random.RandomState(29)

base = np.array([150, 152, 156], dtype=np.float64)   # cool grey stone
img = np.zeros((S, S, 3), dtype=np.float64)
# low-freq wrap-safe mottle
mottle = np.zeros((S, S))
for (fx, fy, ph, amp) in [(1,1,0.3,0.5),(2,1,1.1,0.3),(1,2,2.0,0.3),(2,3,0.7,0.2)]:
    xx, yy = np.meshgrid(np.arange(S), np.arange(S))
    mottle += amp*np.sin(2*math.pi*(fx*xx/S)+ph)*np.sin(2*math.pi*(fy*yy/S)+ph*1.3)
mottle = (mottle-mottle.min())/(mottle.max()-mottle.min())
for c in range(3):
    img[:,:,c] = base[c]*(0.88+0.16*mottle)

def stamp(cx, cy, rx, ry, ang, col, edge):
    for ox in (-S,0,S):
        for oy in (-S,0,S):
            x0=int(cx+ox-rx-2); x1=int(cx+ox+rx+2)
            y0=int(cy+oy-ry-2); y1=int(cy+oy+ry+2)
            for py in range(max(0,y0),min(S,y1)):
                for px in range(max(0,x0),min(S,x1)):
                    dx=px-(cx+ox); dy=py-(cy+oy)
                    rxr= dx*math.cos(ang)+dy*math.sin(ang)
                    ryr=-dx*math.sin(ang)+dy*math.cos(ang)
                    d=(rxr/rx)**2+(ryr/ry)**2
                    if d<=1.0:
                        t=max(0.0,(d-0.55)/0.45)
                        img[py,px,:]=col*(1-t*0.45)+edge*(t*0.45)

# fine irregular cobbles, jittered (no grid)
for i in range(85):
    cx=rng.uniform(0,S); cy=rng.uniform(0,S)
    r=rng.uniform(3.4,5.8)
    rx=r*rng.uniform(0.8,1.25); ry=r*rng.uniform(0.8,1.25)
    ang=rng.uniform(0,math.pi)
    tone=rng.uniform(0.84,1.10)
    col=np.clip(base*tone+rng.uniform(-8,8,3),70,210)
    edge=base*0.6
    stamp(cx,cy,rx,ry,ang,col,edge)

img=np.clip(img+rng.uniform(-5,5,(S,S,1)),0,255)
# 4px edge cross-fade (belt + suspenders on top of the wrap)
band=4; a=img.copy()
for i in range(band):
    w=0.5-(i+1)/(band+1)*0.5
    a[i,:,:]=img[i,:,:]*(1-w)+img[S-band+i,:,:]*w
    a[S-1-i,:,:]=img[S-1-i,:,:]*(1-w)+img[band-1-i,:,:]*w
b=a.copy()
for i in range(band):
    w=0.5-(i+1)/(band+1)*0.5
    a[:,i,:]=b[:,i,:]*(1-w)+b[:,S-band+i,:]*w
    a[:,S-1-i,:]=b[:,S-1-i,:]*(1-w)+b[:,band-1-i,:]*w

fin=Image.fromarray(np.clip(a,0,255).astype('uint8'),'RGB').convert('RGBA')
fin.save(os.path.join(OUT,'florence_cobble_64.png'))
prev=Image.new('RGBA',(192,192))
for y in range(3):
    for x in range(3): prev.paste(fin,(x*64,y*64))
prev.save(os.path.join(OUT,'florence_cobble_3x3.png'))
print('grey cobble synth + 3x3 preview written')
