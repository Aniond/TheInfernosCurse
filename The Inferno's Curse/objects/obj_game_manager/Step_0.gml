// =============================================================================
// obj_game_manager — Step Event
// =============================================================================
// Runs every step. Drives the corruption system and manages the input-lock
// timer that Limbo and Violence effects write to.
// =============================================================================

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

// ── DEBUG: toggle debug mode (F1) — controls placeholder visuals ──────────────
if (keyboard_check_pressed(vk_f1)) {
    global.debug_mode = !global.debug_mode;
    global.save_indicator_text  = global.debug_mode ? "DEBUG ON" : "DEBUG OFF";
    global.save_indicator_timer = 120;
}

// ── DEBUG: battle trigger (B) — remove when proper battle triggers are wired ──
// Unconditional in Room1 so it always works during development, regardless of
// debug_mode / save state. Pressing B drops Benedetto into room_battle vs 3 Hollows.
if (room == Room1 && keyboard_check_pressed(ord("B"))) {
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
