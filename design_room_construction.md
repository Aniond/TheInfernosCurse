# The Inferno's Curse — Room Construction Method (STANDARD)

The reference for building every interior room. Established with **Room_duomo**
(Basilica di Santa Maria del Fiore). All future rooms — chapels, palaces, crypts,
the other circles' interiors — follow this exact method.

> Goal: *"Build the memory, not the blueprint."* The player walks in and instantly
> knows what kind of place this is.

---

## 1. The Black-Void Method (the core idea)

JRPG/FF6 construction. **Three layers only:**

1. **Black void** — the background, everywhere. This *is* the wall. No wall tiles.
2. **Dark border tile** — one tile tracing the floor's whole perimeter (1 cell).
   The thin outline that reads "the floor ends here" against the black.
3. **Floor tile** — fills every walkable cell inside the border. No gaps.

Then: **objects on the floor only** (columns, statues, candelabra, altar, shrine…).
Objects against the black read as walls/fixtures naturally. The black between areas
is what gives each space its definition and makes the lit floor "stick out."

Never draw a "wall sprite band." Black + the border outline + edge objects = walls.

---

## 2. Geometry — cell predicates (scr_<room>)

Rooms are a grid of 64px cells. Define the floor **shape** as boolean predicates,
not hand-placed tiles. Everything (rendering + collision) reads these, so visuals
and collision can never drift.

Required predicates (see `scr_duomo`):
- `is_interior(cx,cy)` — walkable floor (union of rectangles: nave, transepts, …).
- `is_border(cx,cy)` — interior cell touching void (4-neighbour) → dark border tile.
- `is_corner(cx,cy)` — inside-corner border cell → darkest corner tile.
- `is_wall(cx,cy)` — void cell touching interior (8-neighbour) → **collision only**.
- Room-specific accents: `is_dome` (crossing medallion), `is_dais` (raised platform).

Shape philosophy: **a clean cross/important silhouette beats a literal blueprint.**
Don't build full side rooms if an alcove object sells the same idea (see §6).

Grid is cheap; for big floorplans cache the zone grid once (array) — but a simple
cross (Room_duomo = 20×22) needs no cache.

---

## 3. The scene object (obj_<room>_scene)

One controller per room, placed on a depth-160 layer (under the player at 100).

- **Create**: `room` guard → `scr_<room>_build()` (places props + collision) →
  spawn the exit trigger(s) (`obj_mercato_exit`, with `arrive_x/arrive_y`) →
  corruption-keyed entry chronicle.
- **Draw**: paints the three layers + carpet + decoration. Order:
  1. Black rectangle (whole room).
  2. Floor pass: per interior cell, solid dark **base fill** (no gaps under
     transparent tile parts) then the tile (corner / border / dais / dome / field).
  3. Carpet (see §5), dais medallion, apse wall + stained glass + banners, steps,
     entrance archway.
  4. Ambient overlay (warm add when lucid → cold dark as corruption rises).

obj_game_manager is **persistent** (created in Room1), so all globals are live in
every room — the room only needs the player + the scene instance.

---

## 4. Tilesets (PixelLab `create_tiles_pro`)

Dark, warm, muted — **never bright white marble.** square_topdown, 64px, top-down,
`outline_mode: outline`. The tool returns 16 variations; pick 5 roles:

| Role     | sprite                     | look                                  |
|----------|----------------------------|---------------------------------------|
| Field    | spr_<room>_floor_field     | main dark warm stone, subtle geometry |
| Border   | spr_<room>_floor_border    | slightly darker, traces the edge      |
| Corner   | spr_<room>_floor_corner    | darkest, at void corners              |
| Carpet   | spr_<room>_floor_carpet    | deep crimson runner                   |
| Platform | spr_<room>_floor_platform  | raised dais (single centred medallion)|

Import via `import_sprites.ps1` (stage PNGs **without** the `spr_` prefix; clear
`sprite_import` first). Overwrite an existing sprite in place by copying the new PNG
over its `{frameGUID}.png` **and** `layers/{frameGUID}/{layerGUID}.png` (same GUIDs →
no .yy/.yyp change).

---

## 5. The seven SNES construction rules (apply to every room with a nave)

1. **Wall depth** — black void *is* depth here; the border tile is the lip. (In
   tile-wall rooms instead: cap row + 2-3 face rows. Black-void is preferred.)
2. **Columns** — paired rows down the central axis, every ~2 cells. Columns sell
   scale better than wall texture. Each column gets a **ground contact shadow**
   (dark ellipse under the base) so it never floats.
3. **Altar/focus area** — raised **dais** (platform tile, ONE centred medallion +
   plain fill), stone wall face behind with **stained-glass windows** + **banners**,
   coloured light spilling onto the dais, a **figure** (priest) on the platform, and
   **step lines** leading up from the carpet. Eye order: focus → figure → path to it.
4. **Carpet** — **bright** crimson, **gold trim both edges**, full length of the
   nave from entrance to the dais steps. The strongest element; it's the eye-line.
5. **Pews / seating** — rows flanking the carpet, a clear gap to the columns, all
   facing the focus. **Fixed furniture — never randomize/rotate them.**
6. **Floor edge darkening** — floor darker toward the void, lightest mid-room.
7. **Stained glass** — on the focus wall (and side walls if tiled), with coloured
   light pooled on the floor below.

---

## 6. Faking scale with alcoves (don't over-build)

If a labelled space (crypt, treasury, chapel, confessional) doesn't need to be
entered, **don't build the room** — place an **alcove object** on the floor edge
against the black and let it suggest the space:
- shrine + prayer candles, confessional booth, statue + candelabra, stairs, etc.
Cheaper, reads instantly, keeps the silhouette clean.

---

## 7. Props & collision

- Props are **placed objects** via `scr_<room>_default_layout()` (object, gx, gy,
  scale). Draggable / arrow-nudge / Delete / **F8-save** in debug (F1) — the player
  fine-tunes positions; F8 writes `working_directory/<room>_layout.txt`.
- Reference the placed objects + name-placed sprites in a **keep-alive** array so
  the asset stripper doesn't delete them.
- Collision: `scr_<room>_build_collision()` spawns invisible `obj_wall` on every
  `is_wall` cell (auto-traced perimeter) + a tight footprint under each solid prop.

---

## 8. Camera (FF6 scrolling viewport) — GLOBAL, automatic

Never show the whole room. This is now a **global default** — `scr_camera`, driven
every step by obj_game_manager. **New rooms need ZERO view setup.**
- Port 1366×768; view height = `global.cam_view_h` (default 384 → ~2× zoom). Width
  is derived from the port aspect and both are clamped to the room size, so it never
  distorts and never shows black bars (even on rooms smaller than the view, e.g. the
  bridge). It clamp-follows obj_player.
- Tune per need: `global.cam_view_h` (zoom), `global.cam_enabled` (off), or
  `global.cam_skip_room` (leave a static-framed room like room_battle alone).
- Distance sells the scale — walking the nave should take several seconds.

---

## 9. Lighting & corruption ambience

- Candelabra/torches: warm additive glow, flicker; ~half go dark at 50% Limbo
  corruption, all cold at 100%.
- Scene ambient: gentle warm add when lucid → cold/dark overlay as corruption rises
  (keep it gentle enough that floor detail still reads).
- Altar relieves corruption (floor 15); confessional sealed at 75%+; the place
  "forgets what it was" at 100%. Tie room state to `global.circle_corruption[CIRCLE_LIMBO]`.

---

## 10. Transitions

- Enter: a press-**E** trigger on the exterior in the parent room (spawned in code,
  e.g. `scr_room1_build`, so it never needs a layout-version bump).
- Exit: walk into an `obj_mercato_exit` zone at the doorway → parent room, with
  `arrive_x/arrive_y` set so you land next to the exterior.
- Player spawn: place the room's `inst_player` at the entrance; the entrance trigger
  sets `global.player_spawn_override` to the same spot.

---

## New-room checklist

1. Generate dark `create_tiles_pro` floor set (field/border/corner/carpet/platform).
2. Generate any hero sprites (priest, statue…) or reuse existing.
3. `scr_<room>`: `is_interior` shape + accents, default prop layout, build + collision.
4. `obj_<room>_scene`: Create (build + exit + chronicle) + Draw (three layers + §5).
5. Objects for interactive props; column shadow Draw; alcove objects for faked rooms.
6. Room .yy: size + player spawn. **Camera is global** (scr_camera) — no per-room
   view needed; just tune `global.cam_view_h` if a room wants a different zoom.
7. Register sprites/objects/room in the .yyp; entrance trigger in the parent room.
8. `clean_build.ps1`; walk it; tune via debug drag + F8.

---

*Established 2026-06-08 with Room_duomo. Keep this in sync as the method evolves.*
