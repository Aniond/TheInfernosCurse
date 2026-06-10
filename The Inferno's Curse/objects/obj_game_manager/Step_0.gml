// =============================================================================
// obj_game_manager — Step Event
// =============================================================================
// Runs every step. Drives the corruption system and manages the input-lock
// timer that Limbo and Violence effects write to.
// =============================================================================

// ── Florence (re)build ────────────────────────────────────────────────────────────
// This manager is persistent — its Create runs only once. A room change destroys
// Florence's code-spawned props + collision, so rebuild them whenever we (re)enter
// Florence (e.g. returning from the Ponte Vecchio bridge room) — otherwise Florence comes
// back with no market and no river collision.
if (room == Room_florence) {
    if (!variable_global_exists("__florence_built") || !global.__florence_built) {
        scr_florence_build();
        global.__florence_built = true;
    }
} else if (variable_global_exists("__florence_built")) {
    global.__florence_built = false;
}

// ── Global FF6 camera — follow + clamp in every room (see scr_camera) ─────────
scr_camera_update();
scr_banner_step();   // count down the location banner (drawn in obj_player Draw GUI)

// ── Day/night clock ───────────────────────────────────────────────────────────
scr_time_step();

// ── Corruption system ─────────────────────────────────────────────────────────
// Poll all seven circles, trigger sin effects for active ones, and apply
// continuous scaled modifiers (speed drain, price inflation, etc.).
scr_corruption_update();

// ── Vision intensity ──────────────────────────────────────────────────────────
// Recalculate the composite hallucination pressure from Limbo, Gluttony,
// and inverse sanity. Result written to global.vision_intensity.
scr_update_vision_intensity();

// ── Vision trigger check ──────────────────────────────────────────────────────
// Probabilistically fires a vision if the cooldown has elapsed and the
// intensity roll succeeds. Delegates rendering to obj_vision_manager.
scr_check_trigger_vision();


// ── Save / load keyboard shortcuts ───────────────────────────────────────────
if (keyboard_check_pressed(vk_f5)) scr_save_world_state();
if (keyboard_check_pressed(vk_f9)) scr_load_world_state();

// ── DEBUG: advance 1 hour (Ctrl+T) — debug_mode only (F1) ─────────────────────
if (global.debug_mode && keyboard_check(vk_control) && keyboard_check_pressed(ord("T"))) {
    scr_time_advance_hours(1);
    global.save_indicator_text  = "TIME: " + scr_time_str() + " [" + scr_time_phase() + "]";
    global.save_indicator_timer = 120;
}

// ── DEBUG: freeze / unfreeze the day-night clock (T, no Ctrl) ──────────────────
// Holds the clock so NPCs don't drift off-schedule and lighting stays put while
// testing. Ctrl+T still steps it by hand even while frozen.
if (global.debug_mode && keyboard_check_pressed(ord("T")) && !keyboard_check(vk_control)) {
    global.time_frozen = !global.time_frozen;
    global.save_indicator_text  = global.time_frozen
        ? ("TIME FROZEN " + scr_time_str() + " [" + scr_time_phase() + "]")
        : "TIME RESUMED";
    global.save_indicator_timer = 120;
}

// ── DEBUG: toggle debug mode (F1) — controls placeholder visuals ──────────────
if (keyboard_check_pressed(vk_f1)) {
    global.debug_mode = !global.debug_mode;
    global.save_indicator_text  = global.debug_mode ? "DEBUG ON" : "DEBUG OFF";
    global.save_indicator_timer = 120;
}

// ── DEBUG: save the current room-builder layout to file (F8) ──────────────────
//          Shift+F8 = RESET the room layout to the code defaults (deletes save)
if (global.debug_mode && keyboard_check_pressed(vk_f8)) {
    if (keyboard_check(vk_shift)) scr_room_builder_reset_layout();
    else                          scr_room_builder_save();
}

// ── DEBUG: toggle event log panel (F10) ───────────────────────────────────────
if (keyboard_check_pressed(vk_f10)) {
    global.debug_show_log = !global.debug_show_log;
    global.save_indicator_text  = global.debug_show_log ? "PANELS ON" : "PANELS OFF";
    global.save_indicator_timer = 120;
}

// ── DEBUG: AI kill-switch (F11) — no Claude API calls = no tokens during testing ─
// NPC dialogue short-circuits to a placeholder line instead of reaching Claude.
if (keyboard_check_pressed(vk_f11)) {
    global.ai_disabled = !global.ai_disabled;
    global.save_indicator_text  = global.ai_disabled ? "AI OFF (no tokens)" : "AI ON (live)";
    global.save_indicator_timer = 120;
}

// ── DEBUG: click-drag builder objects (grid-snapped on release; F8 saves) ─────
scr_room_builder_drag_update();

// ── DEBUG: fine-nudge the selected object with arrow keys (sub-grid; F8 saves) ─
scr_room_builder_nudge_update();

// ── DEBUG: editor chords — Ctrl+Z undo · Ctrl+D duplicate · [ / ] scale ────────
scr_room_builder_edit_update();

// ── DEBUG: middle-click = teleport Benedetto to the mouse (pairs with N noclip) ─
if (global.debug_mode && mouse_check_button_pressed(mb_middle) && instance_exists(obj_player)) {
    obj_player.x = clamp(mouse_x, 64, room_width  - 64);   // same hard bounds as obj_player Step
    obj_player.y = clamp(mouse_y, 64, room_height - 64);
    global.save_indicator_text  = "TELEPORT " + string(round(obj_player.x)) + "," + string(round(obj_player.y));
    global.save_indicator_timer = 90;
}

// ── DEBUG: toggle 64px grid overlay (F2) — debug_mode only (F1) ────────────────
if (global.debug_mode && keyboard_check_pressed(vk_f2)) {
    if (!variable_global_exists("debug_grid_overlay")) global.debug_grid_overlay = false;
    global.debug_grid_overlay = !global.debug_grid_overlay;
    global.save_indicator_text  = global.debug_grid_overlay ? "GRID ON" : "GRID OFF";
    global.save_indicator_timer = 120;
}

// ── DEBUG: delete the selected room-builder object (Delete key) ────────────────
if (global.debug_mode && keyboard_check_pressed(vk_delete)) scr_room_builder_delete_selected();

// ── DEBUG: noclip (N) — debug_mode only (F1). Walk through walls / out of any
// collision zone the player got stuck inside (e.g. a building dragged under him).
if (global.debug_mode && keyboard_check_pressed(ord("N"))) {
    if (!variable_global_exists("debug_noclip")) global.debug_noclip = false;
    global.debug_noclip = !global.debug_noclip;
    global.save_indicator_text  = global.debug_noclip ? "NOCLIP ON" : "NOCLIP OFF";
    global.save_indicator_timer = 120;
}

// ── DEBUG: cycle Focus class (C) — debug_mode only (F1) ────────────────────────
if (global.debug_mode && keyboard_check_pressed(ord("C"))) {
    if      (global.player_class == "default") global.player_class = "witness";
    else if (global.player_class == "witness") global.player_class = "cursed";
    else                                       global.player_class = "default";
    global.save_indicator_text  = "CLASS: " + global.player_class;
    global.save_indicator_timer = 120;
}

// ── DEBUG: corruption tiers (F3 +20 worse, F4 -20 better) — debug_mode only ──
if (global.debug_mode && keyboard_check_pressed(vk_f3)) {
    global.circle_corruption[CIRCLE_LIMBO] = clamp(global.circle_corruption[CIRCLE_LIMBO] + 20, 0, 100);
    global.save_indicator_text  = "CORRUPTION: " + string(round(global.circle_corruption[CIRCLE_LIMBO]));
    global.save_indicator_timer = 120;
}
if (global.debug_mode && keyboard_check_pressed(vk_f4)) {
    global.circle_corruption[CIRCLE_LIMBO] = clamp(global.circle_corruption[CIRCLE_LIMBO] - 20, 0, 100);
    global.save_indicator_text  = "CORRUPTION: " + string(round(global.circle_corruption[CIRCLE_LIMBO]));
    global.save_indicator_timer = 120;
}

// ── DEBUG: corruption reset / max (F6 reset-to-0, F7 max) ─────────────────────
// Lets you see the dialogue box (and all sin effects) at their default clean
// state or full corruption without playing through a save. F6 clears every
// circle; F7 maxes the current circle so you can test heavy tint/fragmentation.
if (global.debug_mode && keyboard_check_pressed(vk_f6)) {
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) global.circle_corruption[_i] = 0;
    global.save_indicator_text  = "CORRUPTION RESET";
    global.save_indicator_timer = 120;
}
if (global.debug_mode && keyboard_check_pressed(vk_f7)) {
    global.circle_corruption[global.current_circle] = 100;
    global.save_indicator_text  = "CORRUPTION MAX";
    global.save_indicator_timer = 120;
}

// ── DEBUG: NPC behaviour test hooks — exercise scr_npc_log_event end-to-end ────
// The behaviour system is built but nothing in gameplay feeds it yet, so these
// fire sample interactions on Rosa ("barmaid") to verify the whole pipeline:
// relationship delta → emotion ladder → floating icon → corruption memory-erasure.
//   Ctrl+G = GENEROUS +5   ·   Ctrl+H = RUDE -5
// Workflow: raise corruption with F3/F7 first, then fire an event to watch the
// event_log get pruned (>=50: >5-day events drop; >=75: keep last 2; >=100: wiped).
// The save-indicator HUD echoes the new score/emotion/event-count so it's
// verifiable even when Rosa isn't on-screen. debug_mode-gated — dev only.
if (global.debug_mode && keyboard_check(vk_control) && keyboard_check_pressed(ord("G"))) {
    scr_npc_log_event("barmaid", "generous", "Benedetto left extra coin on the counter.", 5);
    var _rosa = scr_npc_get("barmaid");
    global.save_indicator_text  = "ROSA +5  score=" + string(_rosa.relationship_score)
        + "  " + _rosa.emotion_state + "  (events=" + string(array_length(_rosa.event_log)) + ")";
    global.save_indicator_timer = 180;
    scr_npc_show_emotion(obj_npc_rosa, "happy");
}
if (global.debug_mode && keyboard_check(vk_control) && keyboard_check_pressed(ord("H"))) {
    scr_npc_log_event("barmaid", "rude", "Benedetto snapped at her over nothing.", -5);
    var _rosa = scr_npc_get("barmaid");
    global.save_indicator_text  = "ROSA -5  score=" + string(_rosa.relationship_score)
        + "  " + _rosa.emotion_state + "  (events=" + string(array_length(_rosa.event_log)) + ")";
    global.save_indicator_timer = 180;
    scr_npc_show_emotion(obj_npc_rosa, "angry");
}

// ── DEBUG: battle trigger (B) — remove when proper battle triggers are wired ──
// debug_mode only (F1). Pressing B in Florence drops Benedetto into room_battle.
if (global.debug_mode && room == Room_florence && keyboard_check_pressed(ord("B"))) {
    scr_battle_trigger(1);   // 1 Hollow, Florence corruption level
}

// ── Save indicator countdown ──────────────────────────────────────────────────
if (global.save_indicator_timer > 0) global.save_indicator_timer--;

// ── Input lock timer ──────────────────────────────────────────────────────────
// Sin effects that seize control (Limbo dissociation, Violence inversion)
// set input_lock_timer to a step count and input_locked to true.
// This block counts down and clears the lock when the timer expires.
if (global.input_lock_timer > 0) {
    global.input_lock_timer--;
    if (global.input_lock_timer <= 0) {
        global.input_locked     = false;
        global.input_lock_timer = 0;
    }
}
