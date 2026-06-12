/// @description Called every in-game day rollover. Advances corruption and
/// triggers cascade effects between circles.
///
/// Corruption scale is 0-100 (the single madness axis; 100 = fully lost).
///
/// Cascade thresholds (Limbo, index 0) — fire during the descent, before 100:
///   >= 60   Gluttony (index 2) begins spreading — consumed souls feed excess
///   >= 75   Lust (index 1) begins spreading — desire fills the void of grief
///
/// NOTE: This function writes directly to the global corruption arrays.

// DESIGN: Limbo is the root corruption.
// Solving Limbo stops all downstream bleed.
// Each circle only bleeds when its upstream trigger threshold is met.
function scr_new_day_corruption_update() {

    // ── Primary corruption advance (enabled circles only) ─────────────────────
    // Limbo's corruption deepens by 8 each day — the ticking clock of the world.
    if (global.circle_enabled[CIRCLE_LIMBO]) {
        global.circle_corruption[CIRCLE_LIMBO] += 8;
    }
    
    // Reset daily sanity loss for Indefinite Insanity checks
    global.daily_sanity_loss = 0;

    // ── Cascade bleed: only lands on ENABLED circles ──────────────────────────
    // While a target circle is disabled (locked until its city), no bleed reaches
    // it, so its sin effects never fire. Re-enables automatically via circle_enabled
    // once the player reaches that city (scr_solve_circle unlocks the next).
    // During Circle 1 development only Limbo is enabled, so these are inert.
    // TODO: tune thresholds when those circles are sealed and tested.
    if (global.circle_enabled[CIRCLE_GLUTTONY] && global.circle_corruption[CIRCLE_LIMBO] >= 60) {
        global.circle_corruption[CIRCLE_GLUTTONY] += 5;   // Gluttony cascade
    }
    if (global.circle_enabled[CIRCLE_LUST] && global.circle_corruption[CIRCLE_LIMBO] >= 75) {
        global.circle_corruption[CIRCLE_LUST] += 3;       // Lust cascade
    }

    // ── Clamp all circles 0-100 ───────────────────────────────────────────────
    // 100 is the ceiling — fully lost, the single madness axis maxed out.
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        global.circle_corruption[_i] = clamp(global.circle_corruption[_i], 0, 100);
    }
    
    // ── NPC Personal Corruption Advance ───────────────────────────────────────
    // The environment decays, and so do the minds of the citizens. We slowly raise
    // each NPC's personal corruption. Those with higher faith/sin_awareness might resist.
    if (variable_global_exists("npc_data") && variable_struct_exists(global.npc_data, "npcs")) {
        var _names = struct_get_names(global.npc_data.npcs);
        for (var _j = 0; _j < array_length(_names); _j++) {
            var _npc = global.npc_data.npcs[$ _names[_j]];
            if (variable_struct_exists(_npc, "personal_corruption")) {
                var _awareness = variable_struct_exists(_npc, "sin_awareness") ? _npc.sin_awareness : 0;
                // Base gain of 5, reduced by awareness (priests resist, peasants succumb)
                var _gain = max(1, 5 - (_awareness * 2));
                _npc.personal_corruption = clamp(_npc.personal_corruption + _gain, 0, 100);
            }
        }
        scr_npc_save(); // Save the new corruption states
    }

    // ── World event log ───────────────────────────────────────────────────────
    // Record the day transition so the Claude API has narrative context.
    scr_world_event_log(
        "Day " + string(global.day_count) + " dawns. " +
        "Limbo corruption: " + string(global.circle_corruption[CIRCLE_LIMBO]) + ". " +
        "Gluttony: " + string(global.circle_corruption[CIRCLE_GLUTTONY]) + ". " +
        "Lust: "     + string(global.circle_corruption[CIRCLE_LUST]) + "."
    );

    // ── City state update ─────────────────────────────────────────────────────
    // Propagate new corruption levels to NPC behaviours, world events, etc.
    scr_update_city_state();

    // ── Auto-save full world state at day end ─────────────────────────────────
    scr_save_world_state();

    show_debug_message(
        "[Day " + string(global.day_count) + "] Corruption — " +
        "Limbo:" + string(global.circle_corruption[CIRCLE_LIMBO]) +
        " Gluttony:" + string(global.circle_corruption[CIRCLE_GLUTTONY]) +
        " Lust:" + string(global.circle_corruption[CIRCLE_LUST])
    );
}
