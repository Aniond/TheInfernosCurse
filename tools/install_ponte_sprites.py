# Install the three processed ponte textures as GameMaker sprites by cloning
# the VERIFIED spr_ponte_floor_cobble.yy template (new name/uuids/size only —
# format byte-identical otherwise, per CLAUDE.md .yy rules).
import os, shutil, uuid

SPR  = r"c:\TheInfernoCurse\The Inferno's Curse\sprites"
OUT  = r"c:\TheInfernoCurse\tools\_texture_out"
TPL  = os.path.join(SPR, "spr_ponte_floor_cobble", "spr_ponte_floor_cobble.yy")
TPL_NAME  = "spr_ponte_floor_cobble"
TPL_FRAME = "40745240-83c5-4d6d-bafd-4b7332ff3513"
TPL_LAYER = "44703afc-f200-4bb8-b34d-d9460f5f9756"
TPL_KEYID = "514f07c5-9e5c-4362-805b-2b5db621b8da"

with open(TPL, "r", encoding="utf-8") as f:
    template = f.read()

SPRITES = [
    ("spr_ponte_floor_normal",  "cobble_normal_64.png",     64, 64),
    ("spr_ponte_floor_pietra",  "pietra_floor_64.png",      64, 64),
    ("spr_ponte_border_serena", "serena_border_64x16.png",  64, 16),
]

for name, png, w, h in SPRITES:
    frame, layer, keyid = str(uuid.uuid4()), str(uuid.uuid4()), str(uuid.uuid4())
    folder = os.path.join(SPR, name)
    os.makedirs(os.path.join(folder, "layers", frame), exist_ok=True)
    shutil.copyfile(os.path.join(OUT, png), os.path.join(folder, frame + ".png"))
    shutil.copyfile(os.path.join(OUT, png), os.path.join(folder, "layers", frame, layer + ".png"))
    yy = (template
          .replace(TPL_NAME, name)
          .replace(TPL_FRAME, frame)
          .replace(TPL_LAYER, layer)
          .replace(TPL_KEYID, keyid)
          .replace('"bbox_bottom":63', f'"bbox_bottom":{h-1}')
          .replace('"bbox_right":63',  f'"bbox_right":{w-1}')
          .replace('"height":64',      f'"height":{h}')
          .replace('"width":64',       f'"width":{w}'))
    with open(os.path.join(folder, name + ".yy"), "w", encoding="utf-8", newline="\n") as f:
        f.write(yy)
    print(f"{name}: frame {frame} ({w}x{h})")
