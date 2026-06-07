"""
create_garden_objects.py
Creates GameMaker LTS2026 object .yy files for Giardino delle Rose props
and registers them in The Inferno's Curse.yyp.
"""
import os
import sys

project_root = r"C:\TheInfernoCurse\The Inferno's Curse"
objects_root = os.path.join(project_root, "objects")
yyp_path     = os.path.join(project_root, "The Inferno's Curse.yyp")

# (obj_name, sprite_name, solid)
GARDEN_OBJECTS = [
    ("obj_garden_fountain",       "spr_obj_fountain",        True),
    ("obj_garden_bench",          "spr_obj_bench_stone",     True),
    ("obj_garden_archway",        "spr_obj_archway_rose",    False),
    ("obj_garden_urn",            "spr_obj_urn_terracotta",  True),
    ("obj_garden_cypress",        "spr_tree_cypress_italian",False),
    ("obj_garden_tree_olive",     "spr_tree_olive",          False),
    ("obj_garden_tree_flowering", "spr_tree_flowering",      False),
]


def make_yy(name, sprite_name, solid):
    s = "true" if solid else "false"
    # Field order verified against obj_barrel.yy and obj_cypress_tree.yy.
    # No physicsCollisionGroup (obsolete). Empty eventList (no custom code).
    lines = [
        '{',
        '  "$GMObject":"",',
        '  "%Name":"' + name + '",',
        '  "eventList":[],',
        '  "managed":false,',
        '  "name":"' + name + '",',
        '  "overriddenProperties":[],',
        '  "parent":{',
        '    "name":"The Inferno\'s Curse",',
        '    "path":"The Inferno\'s Curse.yyp",',
        '  },',
        '  "parentObjectId":null,',
        '  "persistent":false,',
        '  "physicsAngularDamping":0.1,',
        '  "physicsDensity":0.5,',
        '  "physicsFriction":0.2,',
        '  "physicsGroup":1,',
        '  "physicsKinematic":false,',
        '  "physicsLinearDamping":0.1,',
        '  "physicsObject":false,',
        '  "physicsRestitution":0.1,',
        '  "physicsSensor":false,',
        '  "physicsShape":1,',
        '  "physicsShapePoints":[],',
        '  "physicsStartAwake":true,',
        '  "properties":[],',
        '  "resourceType":"GMObject",',
        '  "resourceVersion":"2.0",',
        '  "solid":' + s + ',',
        '  "spriteId":{',
        '    "name":"' + sprite_name + '",',
        '    "path":"sprites/' + sprite_name + '/' + sprite_name + '.yy",',
        '  },',
        '  "spriteMaskId":null,',
        '  "visible":true,',
        '}',
        '',  # trailing newline
    ]
    return '\n'.join(lines)


created = []
skipped = []

for (name, sprite_name, solid) in GARDEN_OBJECTS:
    obj_dir = os.path.join(objects_root, name)
    yy_file = os.path.join(obj_dir, name + ".yy")
    if os.path.exists(obj_dir):
        print("SKIP %s (already exists)" % name)
        skipped.append(name)
        continue
    os.makedirs(obj_dir, exist_ok=True)
    content = make_yy(name, sprite_name, solid)
    # No BOM — same as import_sprites.ps1
    with open(yy_file, 'w', encoding='utf-8', newline='') as f:
        f.write(content)
    print("CREATE %s  (solid=%s, sprite=%s)" % (name, solid, sprite_name))
    created.append(name)

# Register new objects in the .yyp
if created:
    with open(yyp_path, 'r', encoding='utf-8') as f:
        raw = f.read()

    anchor = '  "resources":['
    idx = raw.find(anchor)
    if idx < 0:
        print("ERROR: could not find resources:[ in .yyp", file=sys.stderr)
        sys.exit(1)
    insert_at = idx + len(anchor)

    new_entries = ''
    for name in created:
        entry = '{"id":{"name":"' + name + '","path":"objects/' + name + '/' + name + '.yy",},},'
        if entry not in raw:
            new_entries += '\n    ' + entry

    if new_entries:
        raw = raw[:insert_at] + new_entries + raw[insert_at:]
        with open(yyp_path, 'w', encoding='utf-8', newline='') as f:
            f.write(raw)
        print("\nRegistered %d object(s) in The Inferno's Curse.yyp" % len(created))
    else:
        print("\nAll objects already registered in .yyp")

print("\nDone. Created: %d  Skipped: %d" % (len(created), len(skipped)))
