# NPC Creation Standard

## Three Tiers

### Tier 1 — Key NPCs
Full persistent memory, emotion states,
sin drift, multi-turn AI conversation.
Uses Claude Haiku API.
Examples: Rosa, Marco, Innkeeper, Priest, Lapo

### Tier 2 — Named NPCs
Relationship score, basic memory,
single turn Haiku responses.
Examples: Pietro, merchants, guards

### Tier 3 — Ambient NPCs
Coded responses only. Zero API cost.
Pure atmosphere.
Examples: citizens, pigeons, background figures

## npc_data.json Structure
Every NPC entry requires:
{
  "tier": 1/2/3,
  "name": "Name",
  "location": "room_name",
  "relationship_score": 0,
  "emotion_state": "neutral",
  "role": "role_name",
  "handles": ["thing1", "thing2"],
  "sin_awareness": 0,
  "event_log": []
}
Update BOTH copies:
- layouts/npc_data.json
- AppData save copy
- scr_npc_default_data() seed

## Emotion States
relationship >= 50  → "friendly"
relationship >= 20  → "warm"
relationship 0-19   → "neutral"
relationship <= -20 → "cold"
relationship <= -50 → "hostile"

Corruption override:
>= 75%  → all NPCs show "afraid"
>= 100% → all NPCs show "terrified" with jitter

## Emotion Icons
neutral    → no icon shown
warm       → spr_emotion_happy
friendly   → spr_emotion_happy
cold       → spr_emotion_angry
hostile    → spr_emotion_angry
afraid     → spr_emotion_afraid
suspicious → spr_emotion_suspicious
terrified  → spr_emotion_terrified

Icons float 16px above NPC.
Show persistently when non-neutral.
Pop animation on state change.

## Corruption Memory Erasure
>= 50%:  Clear events older than 5 days.
         Relationship drifts toward 0 by 5pts.
>= 75%:  Keep only 2 most recent events.
         Relationship drifts toward 0 by 10pts.
>= 100%: Clear ALL events.
         Reset relationship to 0.
         Emotion resets to neutral.
         NPC has no memory of Benedetto.

## Sprite Rules
64px canvas, character 60% max.
8 directional idle animation.
mode="v3" for animate_character.
Age appropriate always.
Nothing suggestive ever.

## Interaction
E key + facing direction required.
Never auto-trigger on proximity alone.
"[E] Talk" prompt appears within range.
Proximity range varies by counter depth.
