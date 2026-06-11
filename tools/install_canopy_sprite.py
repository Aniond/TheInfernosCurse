# Install spr_ponte_canopy (128x32 dark wood beam) from the verified template.
import os, shutil, uuid
SPR  = r"c:\TheInfernoCurse\The Inferno's Curse\sprites"
TPL  = os.path.join(SPR, "spr_ponte_floor_cobble", "spr_ponte_floor_cobble.yy")
SRC  = r"c:\TheInfernoCurse\tools\_texture_out\canopy_v2_128x32.png"
NAME = "spr_ponte_canopy"
with open(TPL, encoding="utf-8") as f: t = f.read()
frame, layer, keyid = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
folder = os.path.join(SPR, NAME)
os.makedirs(os.path.join(folder, "layers", frame), exist_ok=True)
shutil.copyfile(SRC, os.path.join(folder, frame + ".png"))
shutil.copyfile(SRC, os.path.join(folder, "layers", frame, layer + ".png"))
t = (t.replace("spr_ponte_floor_cobble", NAME)
      .replace("40745240-83c5-4d6d-bafd-4b7332ff3513", frame)
      .replace("44703afc-f200-4bb8-b34d-d9460f5f9756", layer)
      .replace("514f07c5-9e5c-4362-805b-2b5db621b8da", keyid)
      .replace('"bbox_bottom":63', '"bbox_bottom":31')
      .replace('"height":64', '"height":32'))
with open(os.path.join(folder, NAME + ".yy"), "w", encoding="utf-8", newline="\n") as f: f.write(t)
print(NAME, "installed", frame)
