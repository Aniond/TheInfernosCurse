// =============================================================================
// obj_dialogue_box — Step Event
// =============================================================================

// ── Master gate ───────────────────────────────────────────────────────────────
if (!is_active) exit;

// ── Loading animation ─────────────────────────────────────────────────────────
// Cycles "." → ".." → "..." every 20 steps while waiting for the API.
// The Draw GUI event reads dot_string directly.
if (is_loading) {
    dot_timer++;
    if (dot_timer >= 20) {
        dot_timer = 0;
        switch (dot_string) {
            case ".":   dot_string = "..";  break;
            case "..":  dot_string = "..."; break;
            default:    dot_string = ".";   break;
        }
    }
    exit; // nothing else runs while loading
}

// ── Typewriter reveal ─────────────────────────────────────────────────────────
// Adds one character every typewriter_speed steps until the full text is shown.
if (!is_complete && dialogue_text != "") {
    typewriter_timer++;
    if (typewriter_timer >= typewriter_speed) {
        typewriter_timer = 0;
        char_index++;
        display_text = string_copy(dialogue_text, 1, char_index);
        if (char_index >= string_length(dialogue_text)) {
            is_complete  = true;
            // Keep aliases in sync so any legacy code reading them still works.
            finished     = true;
        }
    }
}

// ── Input: skip or close ──────────────────────────────────────────────────────
var _interact = keyboard_check_pressed(vk_space)
             || keyboard_check_pressed(ord("E"));

if (_interact) {
    if (!is_complete) {
        // Skip typewriter — reveal the full line instantly.
        char_index   = string_length(dialogue_text);
        display_text = dialogue_text;
        is_complete  = true;
        finished     = true;
    } else {
        // Line fully revealed — player dismisses.
        scr_close_dialogue();
    }
}
