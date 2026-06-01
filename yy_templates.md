# GameMaker 2026.0.0.16 — .yy File Format Templates

Use these as the exact source of truth for every .yy file created in this project.
Derived from working files confirmed to load without errors.

---

## Critical version strings

| Record type       | Version tag          | Notes                        |
|-------------------|----------------------|------------------------------|
| `$GMObject`       | `"v0"`               | NOT v1 — v1 causes load error |
| `$GMEvent`        | `"v1"`               | Events inside eventList       |
| `$GMScript`       | `"v1"`               | Script resource files         |
| `$GMRoom`         | `"v1"`               | Room resource files           |
| `$GMRInstance`    | `"v4"`               | Instances inside room layers  |
| All `resourceVersion` | `"2.0"`          | Applies to every record type  |

---

## Object .yy template

```json
{
  "$GMObject":"v0",
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
{"$GMRInstance":"v4","%Name":"inst_name","colour":4294967295,"frozen":false,"hasCreationCode":false,"ignore":false,"imageIndex":0,"imageSpeed":1.0,"inheritCode":false,"inheritedItemId":null,"inheritItemSettings":false,"inheritLayerDepth":false,"isDnd":false,"name":"inst_name","objectId":{"name":"obj_name","path":"objects/obj_name/obj_name.yy",},"properties":[],"resourceType":"GMRInstance","resourceVersion":"2.0","rotation":0.0,"scaleX":1.0,"scaleY":1.0,"x":0.0,"y":0.0,}
```

**Required fields that are easy to miss:**
- `"inheritedItemId":null` — must be present
- `"isDnd":false` — must appear between `inheritLayerDepth` and `name`

---

## GMRInstanceLayer template (inside room layers array)

```
{"$GMRInstanceLayer":"","%Name":"Instances","depth":0,"effectEnabled":true,"effectType":null,"gridX":32,"gridY":32,"hierarchyFrozen":false,"inheritLayerDepth":false,"inheritLayerSettings":false,"inheritSubLayers":true,"isDnd":false,"inheritVisibility":true,"instances":[
    ...instances here...
  ],"layers":[],"name":"Instances","properties":[],"resourceType":"GMRInstanceLayer","resourceVersion":"2.0","userdefinedDepth":false,"visible":true,}
```

**Critical:** `"isDnd":false` must appear between `"inheritSubLayers"` and `"inheritVisibility"`.
Missing this field causes: `Error: Field "isDnd": expected`

---

## instanceCreationOrder entry

```json
{"name":"inst_name","path":"rooms/Room1/Room1.yy",}
```

---

## Common mistakes to avoid

1. `"$GMObject":"v1"` → **must be `"v0"`** for IDE 2026.0.0.16
2. Missing `"inheritedItemId":null` in room instances → silent failure
3. Missing `"isDnd":false` in `$GMRInstanceLayer` → parse error at column ~235
4. Script .yy: `isDnD` (capital D) in field name, `isCompatibility` must come first
5. Child objects: remember to set `parentObjectId`, and remove `"overriddenProperties":[]`
   is still needed even for children
