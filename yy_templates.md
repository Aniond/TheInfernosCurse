# GameMaker LTS2026 (runtime 2026.0.0.23) — .yy File Format Templates

## ⚠️ CRITICAL WARNINGS — READ BEFORE EDITING

1. **External library installation can trigger a "project newer than IDE" warning.**
   When `.yymps` packages are extracted and registered in the `.yyp` manually (outside
   the IDE), GM may cache a partially-written file and warn on next open. This is a
   false positive — do NOT let GM downgrade the project. Check `IDEVersion` in the
   `.yyp` against the installed IDE exe (`Get-Item "C:\Program Files\GameMaker-LTS2026\
   GameMaker-LTS2026.exe").VersionInfo.FileVersion`). If they match, click NO and
   fully quit + reopen GM. *Observed 2026-06-02* during Scribble/Input installation.
2. **Always close GameMaker before Claude Code edits any `.yy` or `.yyp` file.**
   GM caches the project and can overwrite external edits (and it caches *failed*
   loads — a bad edit sticks until a full quit).
2. **VS Code can silently revert `.yyp` changes.** If the `.yyp` (or a `.yy`) is open
   in a VS Code buffer while Claude Code edits it on disk, a later (auto)save of the
   stale buffer clobbers the on-disk edit. *Observed 2026-06-01:* 8 freshly-registered
   sprite entries vanished this way. Close the file in VS Code before external edits.
3. **Always fully reload GameMaker after Claude Code makes changes** (quit + reopen,
   then File → Save) so GM re-reads from disk and rewrites the files canonically.
4. **Never hand-edit `.yy` files free-form — use the verified templates in this file
   only.** Field order is a fixed per-record schema; reordering or "tidying" causes
   load failures.
5. **Run `import_sprites.ps1` from the project root (`C:\TheInfernoCurse\`), not from a
   subfolder** — its default `-SourceFolder`/`-ProjectRoot` paths are resolved relative
   to the script's own location.

> # ⚠️ VERIFIED WORKING FORMATS — DO NOT DEVIATE
> Every template below was accepted by an actual clean IDE load. Copy them
> byte-for-byte. Do not "tidy", reorder, or alphabetize fields — the parser
> uses a fixed per-record schema and will reject reordered records. When in
> doubt, trust the verified tally directly below over any intuition.

Use these as the exact source of truth for every .yy file created in this project.

## ✅ Verified-working tally (confirmed by an actual clean project load)

Last full clean load: **2026-06-01**. Each line below was proven by the IDE accepting it.

- `$GMObject` version is `""` (empty = v0). `"v0"` parse-errors, `"v1"` version-mismatches.
- GameMaker .yy files have **no UTF-8 BOM** (first byte is `{`).
- `GMObject` has **no `physicsCollisionGroup`** field (obsolete; remove it).
- `GMEvent` uses **`isDnD`** (capital D), after `eventType`, before `name`.
- `GMScript` uses **`isDnD`** (capital D); `isCompatibility` precedes it.
- `GMRInstance` (v4) uses **`isDnd`** (lowercase), right after `inheritItemSettings`;
  has `inheritedItemId:null`; has **no `inheritLayerDepth`**.
- `GMRInstanceLayer` has **no `isDnd`** field anywhere; `inheritLayerDepth` IS valid here.
- `GMRoom` top level **has `isDnd`** (lowercase).
- Field order is a fixed per-record schema — **NOT reliably alphabetical**. Trust the
  reader's `(line,col) / "Field X: expected"` error over any ordering guess.
- Recovery: extract valid field names from `CoreResources.dll` (`get_*` strings); after
  editing, **fully quit GameMaker** before reload (it caches failed loads); once open,
  **File → Save** rewrites all .yy canonically.

> Add a new bullet here only after the IDE has actually accepted the change. If something
> is still a guess, mark it (?) until a clean load confirms it.

---

## Critical version strings

| Record type       | Version tag          | Notes                        |
|-------------------|----------------------|------------------------------|
| `$GMObject`       | `""`                 | Version 0 = empty string. `"v0"`=parse error, `"v1"`=version mismatch |
| `$GMRInstanceLayer`| `""`                | Version 0 = empty string. No isDnd in v0? No — isDnd IS present (see below) |
| `$GMRBackgroundLayer`| `""`              | Version 0 = empty string. Has NO isDnd field |
| `$GMEvent`        | `"v1"`               | Events inside eventList       |
| `$GMScript`       | `"v1"`               | Script resource files         |
| `$GMRoom`         | `"v1"`               | Room resource files           |
| `$GMRInstance`    | `"v4"`               | Instances inside room layers  |
| All `resourceVersion` | `"2.0"`          | Applies to every record type  |

**One rule governs all .yy files:** version 0 is serialized as `""`, never `"v0"`.

> ⚠️ CORRECTION: an earlier note here claimed fields are ordered ALPHABETICALLY.
> That is FALSE and was the source of repeated load failures. Field order is a
> **fixed per-record schema** (see the verified tally at the top of this file) —
> e.g. GMRInstance puts `isDnd` right after `inheritItemSettings`, not in
> alphabetical position. Copy the templates verbatim; never re-derive order.

---

## Object .yy template

```json
{
  "$GMObject":"",
  "%Name":"obj_name",
  "eventList":[
    {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":0,"isDnd":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
  ],
  "managed":false,
  "name":"obj_name",
  "overriddenProperties":[],
  "parent":{
    "name":"The Inferno's Curse",
    "path":"The Inferno's Curse.yyp",
  },
  "parentObjectId":null,
  "persistent":false,
  "physicsAngularDamping":0.1,
  "physicsCollisionGroup":1,
  "physicsDensity":0.5,
  "physicsFriction":0.2,
  "physicsGroup":1,
  "physicsKinematic":false,
  "physicsLinearDamping":0.1,
  "physicsObject":false,
  "physicsRestitution":0.1,
  "physicsSensor":false,
  "physicsShape":1,
  "physicsShapePoints":[],
  "physicsStartAwake":true,
  "properties":[],
  "resourceType":"GMObject",
  "resourceVersion":"2.0",
  "solid":false,
  "spriteId":null,
  "spriteMaskId":null,
  "visible":true,
}
```

### Event type reference (for eventList entries)

| Event name       | eventType | eventNum |
|------------------|-----------|----------|
| Create           | 0         | 0        |
| Destroy          | 1         | 0        |
| Step             | 3         | 0        |
| Draw             | 8         | 0        |
| Draw GUI         | 8         | 64       |
| Alarm 0          | 2         | 0        |
| Async HTTP       | 7         | 62       |

### Child object — set parentObjectId

```json
"parentObjectId":{"name":"obj_npc_base","path":"objects/obj_npc_base/obj_npc_base.yy",},
```

---

## Script .yy template

```json
{
  "$GMScript":"v1",
  "%Name":"scr_name",
  "isCompatibility":false,
  "isDnD":false,
  "name":"scr_name",
  "parent":{
    "name":"The Inferno's Curse",
    "path":"The Inferno's Curse.yyp",
  },
  "resourceType":"GMScript",
  "resourceVersion":"2.0",
}
```

Note: `isCompatibility` comes before `isDnD` (alphabetical — linter enforces this order).

---

## Room instance record template (GMRInstance v4)

Required field order (parser is strict):

```json
{"$GMRInstance":"v4","%Name":"inst_name","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"isDnd":false,"name":"inst_name","objectId":{"name":"obj_name","path":"objects/obj_name/obj_name.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":0.0,"y":0.0,}
```

**Verified (clean load 2026-06-01):**
- `"inheritedItemId":null` — present
- `"isDnd":false` (lowercase) — comes right after `"inheritItemSettings"`, before `name`
- **No `inheritLayerDepth`** — it is NOT a GMRInstance field (it's a layer field). Including it
  causes `Field "isDnd": expected`.

---

## GMRInstanceLayer template (inside room layers array)

```
{"$GMRInstanceLayer":"","%Name":"Instances","depth":0,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"inheritVisibility":true,"instances":[
    ...instances here...
  ],"layers":[],"name":"Instances","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,}
```

**Critical (verified clean load):** GMRInstanceLayer has **NO `isDnd` field at all** — not in
the header, not after the instances array. After `]` it goes straight to `"layers"`. (Adding
`isDnd` here causes `Field "layers": expected` or `Field "inheritVisibility": expected`.)
Note: the top-level GMRoom DOES have `isDnd`; the instance layer does not.

---

## instanceCreationOrder entry

```json
{"name":"inst_name","path":"rooms/Room1/Room1.yy",}
```

The `instanceCreationOrder` array lists every instance once, in the order their
Create events run. Manager/persistent objects should come first so later
instances can read their globals. Every `name` here must exactly match an
instance `%Name` in the layer's `instances` array.

---

## ⚠️ Per-instance sizing: use scaleX/scaleY, NOT creation code

**Observed 2026-06-01 (running build):** hand-authored per-instance creation code
(`hasCreationCode:true` + `rooms/<room>/<inst>.gml`) loaded and round-tripped in
the IDE but **did NOT execute at runtime** — every obj_wall_stone rendered at its
Create-default 32×32 instead of the size its creation-code file set. GM does not
reliably compile creation code that the IDE itself didn't author.

**Reliable alternative (verified working):** drive per-instance size from
`scaleX`/`scaleY`, which GM ALWAYS applies from the room. In the object's Create:

```gml
wall_w = 32 * image_xscale;   // 32px base × room scale
wall_h = 32 * image_yscale;
```

Then in each room instance set `"scaleX"` / `"scaleY"` (e.g. a 200×400 block uses
`"scaleX":6.25,"scaleY":12.5`) and leave `"hasCreationCode":false`. No per-instance
.gml files needed. `image_xscale`/`image_yscale` are valid even with no sprite.

---

## Instance creation code (per-instance .gml) — format (use with caution, see above)

GameMaker stores per-instance creation code as a **separate .gml file in the
room folder**, named exactly after the instance. This is how each obj_wall /
obj_wall_stone block gets its own `wall_w` / `wall_h` without a unique object.

**Two coupled requirements (both mandatory):**

1. On the instance record in `Room1.yy`, set **`"hasCreationCode":true`**.
2. Create the file **`rooms/<RoomName>/<instanceName>.gml`** (filename = the
   instance's `%Name`, no prefix path beyond the room folder).

Example — instance `inst_church_body` of `obj_wall_stone`:

Instance record (note `hasCreationCode:true`):
```json
{"$GMRInstance":"v4","%Name":"inst_church_body", ... ,"hasCreationCode":true, ... ,"name":"inst_church_body","objectId":{"name":"obj_wall_stone","path":"objects/obj_wall_stone/obj_wall_stone.yy",}, ... ,"x":1500.0,"y":800.0,}
```

File `rooms/Room1/inst_church_body.gml`:
```gml
// Church main body — 1500,800 to 1700,1200
wall_w = 200;
wall_h = 400;
```

**Verified:** this is the exact mechanism the original border walls
(`inst_wall_top.gml`, etc.) use, and it loaded cleanly. The creation code runs
**after** the object's own Create event, so it can override Create defaults
(obj_wall_stone's Create sets `wall_w = 32` as a fallback; the file overrides it).

- If `hasCreationCode:true` but the `.gml` file is missing → load/compile error.
- If the `.gml` file exists but `hasCreationCode:false` → the code is ignored.
- Variable names must match what the object expects (`wall_w`/`wall_h` here).

---

## SPRITE .YY FORMAT - VERIFIED WORKING

> Confirmed by a clean IDE load (`spr_benedetto_south`, LTS2026). This is the exact
> mechanism `import_sprites.ps1` (in `C:\TheInfernoCurse\`) generates. Copy verbatim;
> do not reorder fields.

**Critical version strings:** `$GMSprite` = `"v2"`, `$GMSpriteFrame` = `"v1"`,
`$GMSequence` = `"v1"`, `$Keyframe<SpriteFrameKeyframe>` = `""`, `$GMImageLayer` = `""`,
`$GMNineSliceData` = `""`. (Empty string = version 0, same rule as everywhere else.)

### On-disk layout (all three required)

```
sprites/<spr_name>/<spr_name>.yy
sprites/<spr_name>/<frameGuid>.png                       # composited frame
sprites/<spr_name>/layers/<frameGuid>/<layerGuid>.png    # per-layer image
```

The PNG is copied (not referenced) into both `.png` slots. `<frameGuid>` names BOTH the
top-level frame png AND the `layers/` subfolder; `<layerGuid>` names the layer png.

### GUID cross-reference rules (3 distinct GUIDs)

- **frameGuid** — used in 4 places: frame `%Name`+`name`, the `<frameGuid>.png` filename,
  the `layers/<frameGuid>/` subfolder, and the sequence track's `Channels."0".Id.name`.
- **layerGuid** — layer `%Name`+`name`, and the `<layerGuid>.png` filename.
- **keyframeId** — the keyframe's `id` only (a separate GUID, NOT reused anywhere).

### Dimensions

`width`/`height` MUST equal the PNG's real pixel size (read from the IHDR chunk: width =
big-endian bytes 16–19, height = bytes 20–23). Full-image bbox is safe regardless of
`bboxMode`: `bbox_left`/`bbox_top` = 0, `bbox_right` = width−1, `bbox_bottom` = height−1.

### Template (single 1-frame, 1-layer sprite)

```json
{
  "$GMSprite":"v2",
  "%Name":"<spr_name>",
  "bboxMode":1,
  "bbox_bottom":<height-1>,
  "bbox_left":0,
  "bbox_right":<width-1>,
  "bbox_top":0,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
    {"$GMSpriteFrame":"v1","%Name":"<frameGuid>","name":"<frameGuid>","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},
  ],
  "gridX":0,
  "gridY":0,
  "height":<height>,
  "HTile":false,
  "layers":[
    {"$GMImageLayer":"","%Name":"<layerGuid>","blendMode":0,"displayName":"default","isLocked":false,"name":"<layerGuid>","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},
  ],
  "name":"<spr_name>",
  "nineSlice":{
    "$GMNineSliceData":"","bottom":0,"enabled":false,
    "guideColour":[4294902015,4294902015,4294902015,4294902015,],
    "highlightColour":1728023040,"highlightStyle":0,"left":0,
    "resourceType":"GMNineSliceData","resourceVersion":"2.0","right":0,
    "tileMode":[0,0,0,0,0,],"top":0,
  },
  "origin":0,
  "parent":{"name":"The Inferno's Curse","path":"The Inferno's Curse.yyp",},
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "$GMSequence":"v1","%Name":"<spr_name>","autoRecord":true,
    "backdropHeight":768,"backdropImageOpacity":0.5,"backdropImagePath":"",
    "backdropWidth":1366,"backdropXOffset":0.0,"backdropYOffset":0.0,
    "events":{"$KeyframeStore<MessageEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MessageEventKeyframe>","resourceVersion":"2.0",},
    "eventStubScript":null,"eventToFunction":{},"length":1.0,"lockOrigin":false,
    "moments":{"$KeyframeStore<MomentsEventKeyframe>":"","Keyframes":[],"resourceType":"KeyframeStore<MomentsEventKeyframe>","resourceVersion":"2.0",},
    "name":"<spr_name>","playback":1,"playbackSpeed":30.0,"playbackSpeedType":0,
    "resourceType":"GMSequence","resourceVersion":"2.0","showBackdrop":true,
    "showBackdropImage":false,"timeUnits":1,
    "tracks":[
      {"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{
                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"<frameGuid>","path":"sprites/<spr_name>/<spr_name>.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},
              },"Disabled":false,"id":"<keyframeId>","IsCreationKey":false,"Key":0.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
    ],
    "visibleRange":null,"volume":1.0,"xorigin":0,"yorigin":0,
  },
  "swatchColours":null,"swfPrecision":0.5,
  "textureGroupId":{"name":"Default","path":"texturegroups/Default",},
  "type":0,"VTile":false,"width":<width>,
}
```

### Register in the .yyp (mandatory — GM won't see the sprite otherwise)

Add one line to the `"resources":[` array (GM re-sorts on save, so order is free):

```json
{"id":{"name":"<spr_name>","path":"sprites/<spr_name>/<spr_name>.yy",},},
```

---

## Common mistakes to avoid

1. `"$GMObject"` → **must be `""`** (version 0). `"v0"`=parse error, `"v1"`=version mismatch.
2. Missing `"inheritedItemId":null` in room instances → silent failure
3. `$GMRInstanceLayer` has NO `isDnd` field; `$GMRInstance` `isDnd` (lowercase) goes right after `inheritItemSettings` and must NOT include `inheritLayerDepth`
4. Script .yy: `isDnD` (capital D) in field name, `isCompatibility` must come first
5. Child objects: remember to set `parentObjectId`, and remove `"overriddenProperties":[]`
   is still needed even for children
