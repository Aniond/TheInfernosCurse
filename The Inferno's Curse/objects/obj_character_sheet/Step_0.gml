// =============================================================================
// obj_character_sheet — Step: toggle, close keys, fade animation
// =============================================================================

// Never in battle — force closed and bail.
if (room == room_battle) {
    if (is_open) { is_open = false; }
    global.char_sheet_open = false;
    if (held_input_lock) { global.input_locked = false; held_input_lock = false; }
    fade = 0;
    exit;
}

// ── Toggle key: C (Shift+C while debug mode owns plain C for class cycling) ───
var _toggle = false;
if (keyboard_check_pressed(ord("C"))) {
    if (global.debug_mode) _toggle = keyboard_check(vk_shift);
    else                   _toggle = true;
}

// Don't open over an active conversation or the journal.
var _dialogue_busy = instance_exists(obj_dialogue_box) && obj_dialogue_box.is_active;
var _journal_busy  = instance_exists(obj_journal) && obj_journal.is_open;

if (_toggle && !is_open && !_dialogue_busy && !_journal_busy) {
    is_open    = true;
    quote_text = scr_char_sheet_quote();
    if (!global.input_locked) { global.input_locked = true; held_input_lock = true; }
} else if (is_open && (_toggle || keyboard_check_pressed(vk_escape))) {
    is_open = false;
}

// Release the lock once fully faded out (so movement resumes after the close).
if (!is_open && fade <= 0.05 && held_input_lock) {
    global.input_locked = false;
    held_input_lock = false;
}

// ── Fade (smooth in/out, ~12 frames each way) ─────────────────────────────────
fade = clamp(fade + (is_open ? 0.085 : -0.085), 0, 1);

// Time pause flag — scr_time_step checks this; corruption is NOT paused.
global.char_sheet_open = (is_open || fade > 0.05);
