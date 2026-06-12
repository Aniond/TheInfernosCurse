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

    // ── Safety: never trap the player on a hung request ───────────────────────
    // ESC cancels immediately. Otherwise time out after ~10s (600 steps @ 60fps)
    // and convert the hang into a dismissable message — which also tells us no
    // response ever arrived (vs. an API-error message from Async_62).
    loading_timer++;

    if (keyboard_check_pressed(vk_escape)) {
        scr_close_dialogue();
        exit;
    }

    if (loading_timer >= 1200) {
        is_loading    = false;
        dialogue_text = "[ No response from Gemini (timed out after 20s). Check the Output log. Press E. ]";
        display_text  = "";
        char_index    = 0;
        is_complete   = false;
        // Release the pending NPC so it can be spoken to again.
        if (instance_exists(source_npc_id)) source_npc_id.api_pending = false;
        // Fall through to the typewriter below so the message reveals + dismisses.
    } else {
        exit; // still waiting — nothing else runs this step
    }
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
            finished     = true;
            if (array_length(suggested_prompts) > 0) {
                input_active = true;
                keyboard_string = "";
                typed_input = "";
            }
        }
    }
}

// ── Input: prompts and custom text ────────────────────────────────────────────
if (input_active) {
    // 1. Capture keyboard
    typed_input = keyboard_string;
    
    // 2. Mouse selection for suggested prompts (handled in Draw/Step implicitly, but we'll check clicks here)
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    
    var _click = mouse_check_button_pressed(mb_left);
    var _submit = "";
    
    if (keyboard_check_pressed(vk_enter) && typed_input != "") {
        _submit = typed_input;
    } else if (_click && selected_prompt != -1 && selected_prompt < array_length(suggested_prompts)) {
        _submit = suggested_prompts[selected_prompt];
    }
    
    if (_submit != "") {
        // Send to AI
        if (instance_exists(source_npc_id)) {
            source_npc_id.api_pending = true;
            source_npc_id.request_id = scr_ai_call(_submit, scr_npc_build_system_prompt(source_npc_id));
            is_loading = true;
            is_complete = false;
            input_active = false;
            dialogue_text = "";
            display_text = "";
            suggested_prompts = [];
            typed_input = "";
        } else {
            scr_close_dialogue();
        }
    }
    
} else {
    // Legacy dismiss logic for when there are no prompts (or not input_active)
    var _interact = keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("E"));

    if (_interact) {
        if (!is_complete) {
            char_index   = string_length(dialogue_text);
            display_text = dialogue_text;
            is_complete  = true;
            finished     = true;
            if (array_length(suggested_prompts) > 0) {
                input_active = true;
                keyboard_string = "";
                typed_input = "";
            }
        } else if (!is_loading) {
            scr_close_dialogue();
        }
    }
}
