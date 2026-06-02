// =============================================================================
// obj_npc_marco — Step Event
// =============================================================================
// Inherits all interaction logic (E key, proximity, dialogue) from obj_npc_base.
// This step only updates Marco's corruption arc and recognition level so the
// system prompt and draw state always reflect the current world corruption.
// =============================================================================

// Inherit base step (interaction, cooldown, npc_memory_corruption mirror)
event_inherited();

// ── Corruption arc ────────────────────────────────────────────────────────────
// Maps Limbo corruption (0-100) to Marco's five-stage dissolution arc.
// The arc drives the personality string injected into his system prompt.
var _c = global.circle_corruption[CIRCLE_LIMBO];

if (_c < 25) {
    // Arc 0 — Fully himself.
    // Cheerful. Offers bread. Asks about your day. Remembers your name.
    // Mentions his children constantly.
    marco_corruption_arc = 0;
    marco_recognition    = 100;

} else if (_c < 50) {
    // Arc 1 — Slightly forgetful.
    // Friendly but something feels off. Occasionally calls Benedetto by the
    // wrong name. Stumbles on one child's name. Still sells bread normally.
    marco_corruption_arc = 1;
    marco_recognition    = clamp(100 - ((_c - 25) * 2), 50, 100);

} else if (_c < 75) {
    // Arc 2 — Doesn't recognise Benedetto at first.
    // Polite to a stranger. Confused about how many children he has.
    // Keeps looking at the bread like he forgot what to do with it.
    // Still at his stall but selling less.
    marco_corruption_arc = 2;
    marco_recognition    = clamp(50 - ((_c - 50) * 1.6), 10, 50);

} else if (_c < 90) {
    // Arc 3 — Barely speaks.
    // Holds bread. Doesn't sell. Doesn't know why he's here.
    // Occasionally whispers a name — Sofia — like trying to remember something vital.
    // Just stands at his stall staring.
    marco_corruption_arc = 3;
    marco_recognition    = clamp(10 - ((_c - 75) * 0.5), 0, 10);

} else {
    // Arc 4 — Ghost of himself.
    // Whispers fragments. Half words. A name almost remembered.
    // Doesn't see Benedetto anymore.
    // The bread in his hands is rotten. He hasn't noticed.
    marco_corruption_arc = 4;
    marco_recognition    = 0;
}
