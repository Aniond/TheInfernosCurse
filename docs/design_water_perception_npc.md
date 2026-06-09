# Design — Overheard NPC Water Perception (corruption-driven, AI-voiced)

Status: **DESIGN ONLY** (2026-06-04). No code written yet. Build plan in §10.

## 1. Concept

Two NPCs standing near the Arno talk **to each other** about the river. Each NPC
sees the water through the lens of *their own* corruption, and **they do not see
the same river**. A clean NPC sees a lovely, sunlit Arno and remarks how fine it
looks; a corrupted NPC sees it running red, still, and wrong — and says so. They
respond to one another, each certain of their own reality. The player overhears
the exchange by walking close.

The horror is the **disagreement**: neither NPC knows they're corrupted. To each
of them, what they see simply *is* the river. The corrupted one isn't describing
a metaphor — to him the water is red. The clean one isn't being polite — to him
it's beautiful. Nobody mentions it. Not even Dante.

This reuses the exact 5-stage staging already driving the river visual in
`obj_street_scene/Draw_0.gml`, so what an NPC "sees" lines up with what the water
would look like at that corruption level.

## 2. Two corruption values — keep them separate

The codebase already has both; this feature leans on the distinction.

| Value | Meaning | Drives |
|-------|---------|--------|
| `global.circle_corruption[CIRCLE_LIMBO]` | Environmental corruption of the circle | The **on-screen water visual** (walls breathe on this too) |
| `<npc>.npc_memory_corruption` | A single NPC's personal corruption | That **NPC's perception** of the water (their dialogue lens) |

So: the *visual* the player sees is environmental. Each *NPC's described* river is
personal. These can disagree — and that dissonance is the point. The player may be
looking at a murky-brown Arno while one NPC calls it crystal clear and another
calls it blood.

## 3. NPC random corruption assignment

- On NPC creation, assign `npc_memory_corruption` a **random** value. Some NPCs
  roll **0** (fully clean — the "it looks great" voice).
- Proposed roll (tunable): weighted so 0 and low values are common, high values
  rarer. e.g. `choose(0, 0, irandom(25), 25+irandom(50), 60+irandom(70))`.
- Existing voice tiers in `scr_npc_build_system_prompt` already key off
  `npc_memory_corruption` at >50/>100/>150, so the scale is ~0–200. Perception
  mapping (§4) normalizes this to the river's 0–100% stages.

## 4. The perception model (shared with the water visual)

Add **one** helper so the dialogue and the visual never drift:

```
scr_water_perception(pct)  // pct = 0..100
  -> { stage, look, sees_red, mood }
```

`pct` for an NPC = `clamp(npc_memory_corruption / 2, 0, 100)` (tunable mapping so
~150+ personal corruption reads as the 100% "red & still" stage).

Stages (same thresholds as the river visual):

| pct | stage | `look` (ground truth handed to the AI as what this NPC SEES) | sees_red |
|-----|-------|-------------------------------------------------------------|----------|
| 0–25 | normal | "clear murky grey-green, calm, catching the light — a fine river" | no |
| 25–50 | silty | "a little brown and silty today, maybe something upstream — but fine" | no |
| 50–75 | wrong | "darker than it should be, sluggish, slow — something is off and you can't say what" | no |
| 75–99 | reversed | "dark, and the current is running the wrong way, upstream — though you'd never say so aloud" | no |
| 100 | dead | "red. completely still. no current at all." | **yes** |

The same five stages already exist as comments + code in
`obj_street_scene/Draw_0.gml` — when this is built, both should call the shared
helper (refactor the visual to read `stage`/colors from it) so there is a single
source of truth.

## 5. Trigger — overheard by proximity

1. Place **NPC pairs** as "conversation anchors" near the river banks (outside the
   water band, off the bridges). Each pair = two `obj_npc_base` children with
   their own random corruption.
2. A lightweight controller (e.g. `obj_river_chatter` or logic on the pair)
   checks player distance to the pair's midpoint each step.
3. When the player enters an **overhear radius** (e.g. ~220px) AND the pair is
   off **cooldown**, start a conversation (§6).
4. Player does **not** drive it — there is no input prompt. The exchange plays out
   in the dialogue box (§7) while the player stands near. Walking away can let it
   finish or cut it (design choice — see §9).
5. **Cooldown** per pair (e.g. 60–120s game time, or once per in-game day) so it
   doesn't re-fire every time the player passes — controls spam and API cost.

Selection rule for a good pair: bias toward pairing **one low-corruption** NPC
with **one higher-corruption** NPC so the disagreement actually happens. Two
clean NPCs = a pleasant nothing; two corrupted = mutual dread. The money case is
the split.

## 6. Conversation orchestration (chained async AI calls)

The existing AI path is single-shot (one NPC, one `request_id`, response routed in
the async-HTTP event). We chain it into a turn-taking exchange:

```
startWaterChat(npcA, npcB):
  state = { a:npcA, b:npcB, turn:0, lines:[], max_turns:4 }
  fire AI call for A   (system = A's prompt + A's `look`; user = opening stage cue)

on async response for A:
  push A.line into state.lines
  show A.line in dialogue box (speaker = A.name)         // §7
  if turns remain:
     fire AI call for B (system = B's prompt + B's `look`;
                         user = "Your companion just said: '<A.line>'. Reply.")
  else end

on async response for B:
  push, show (speaker = B.name)
  alternate back to A with B.line as context, until max_turns
```

- Keep a small **conversation state struct** (global or on a controller instance)
  keyed by the active pair, since the async event needs to know whose turn is next
  and who to call.
- Reuse `scr_ai_call(prompt, system_prompt)` as-is (Haiku, async, cheap).
- The async-HTTP handler is the existing **`Other_62.gml`** event (note: the
  working file is `Other_62.gml`, *not* `Async_62.gml` — known gotcha). It must be
  extended to recognize a chatter `request_id` and advance the conversation
  instead of treating it as a normal player→NPC reply.
- `max_turns` ~4 (A,B,A,B) keeps it short and bounds cost/latency.

## 7. Surfacing in the dialogue box

- Reuse `obj_dialogue_box` (already shows a named speaker, fragments by
  corruption). Each turn calls `scr_open_dialogue(currentSpeaker, line)`.
- The box's existing corruption fragmentation uses the **speaker's** corruption,
  which is exactly right: the corrupted NPC's red-water line also reads more
  broken on screen. Free thematic win.
- Mark these as **overheard** (no "press Z to continue" / no input grab) — they
  auto-advance on a short timer or as each async line lands, so the player just
  watches. (vs. interactive dialogue which waits on input.)
- Optional: a subtle visual cue (small "…" indicator over the pair) so the player
  knows a conversation is happening nearby.

## 8. Prompt templates

**System prompt** = existing `scr_npc_build_system_prompt(npc)` (already injects
personality, world state, atmosphere, memories, 1300 AD grounding, rules) **plus**
a perception block:

```
\n\nWHAT YOU SEE RIGHT NOW:
You are standing by the Arno with <companion name>, a <companion role>.
You glance at the water. To you it looks: <perception.look>.
This is simply what you see. It is real to you. You are certain of it.
```

**Opening user turn (A):**
```
*You and <B.name> pause by the river.* Remark to <B.name> about the water.
```

**Reply user turn (B, and alternating):**
```
<other speaker> just said to you: "<previous line>"
You look at the river again. Respond to them naturally — agree, disagree, or be
unsettled, based on what YOU see. Do not explain yourself or mention madness.
```

Hard rules to reinforce (some already in the base prompt): never use the words
"corruption"/"sin"; never say "I'm imagining it"; ≤2 sentences per turn so the
back-and-forth stays snappy; stay in 1300 AD voice.

## 9. Edge cases & guards

- **No API key** → `scr_ai_call` returns -1. Don't start the chatter at all (or
  show nothing). Never invent lines — matches existing policy.
- **Both NPCs corruption 0** → harmless small talk, no red. Fine but low drama;
  the pair-selection bias (§5) should avoid making this the common case.
- **Identical perception** → still works, they just agree. Acceptable.
- **Player leaves mid-conversation** → choose one: (a) let the current exchange
  finish silently, (b) hard-cut and reset to cooldown. Recommend (a) finish the
  in-flight turn, then stop.
- **Overlapping triggers** → only one active chatter at a time globally; ignore
  new triggers while one runs.
- **Cost/latency** → Haiku + `max_tokens` already small (150); cap `max_turns`;
  per-pair cooldown; only fire when on-screen/near. Each conversation ≈ 4 cheap
  Haiku calls.
- **Async routing collision** → the conversation `request_id`s must be
  distinguishable from normal player-dialogue requests in `Other_62.gml` (tag via
  a lookup of active chatter req_ids).
- **Day/state changes** mid-conversation → snapshot each NPC's `look` at start so
  perceptions don't flip mid-exchange.

## 10. Build plan (phased — for the next step)

1. **Shared perception helper** `scr_water_perception(pct)` + refactor
   `obj_street_scene/Draw_0.gml` to read stage/colors from it (single source of
   truth; visual unchanged).
2. **Random NPC corruption** on creation (weighted, some 0) in the NPC
   create/spawn path.
3. **Perception block** appended in `scr_npc_build_system_prompt` (or a wrapper
   used only by chatter) using the helper.
4. **Conversation controller**: state struct + `scr_river_chatter_start(a,b)` +
   proximity/cooldown trigger.
5. **Async chaining** in `Other_62.gml`: detect chatter req_ids, advance turns,
   push lines to `obj_dialogue_box` in overheard (non-interactive) mode.
6. **Place a test pair** by the river (one low, one high corruption) and run the
   slice end-to-end.

Each phase is independently testable; 1–3 can land without any conversation UI.

## 11. Open questions for later

- Overhear radius + cooldown exact values (tune in play).
- Should the **player's own** corruption tint how the *whole* exchange reads
  (e.g. fragment even the clean NPC's lines)? Currently fragmentation is per
  speaker only.
- Do we want >2 NPCs in a huddle (3-way)? Architecture supports N but start at 2.
- Should especially eerie lines (the "it's red" beat) auto-write a **codex/journal
  entry**? The journal AI path already exists.
