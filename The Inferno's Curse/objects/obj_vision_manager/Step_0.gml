// =============================================================================
// obj_vision_manager — Step Event
// =============================================================================

// ── Pause entirely during dialogue — no stutter behind parchment frame ────────
if (instance_exists(obj_dialogue_box) && obj_dialogue_box.is_active) exit;

// ── Vision timer countdown ────────────────────────────────────────────────────
if (vision_timer > 0) {
    vision_timer--;

    // Fade alpha: peak at the middle of the timer, return to 0 at end.
    // Uses a normalised 0-1 ramp so the overlay breathes rather than snaps.
    // Peak alpha is capped at 0.85 so the game world stays partly visible.
    var _peak  = 0.85;
    var _total = vision_timer + 1; // approximate original duration at step 0
    // Simple linear fade-out for now — replace with sine curve when
    // proper duration tracking is added.
    _target_alpha = _peak * (vision_timer / max(_total, 1));

} else if (vision_timer <= 0 && vision_overlay_alpha > 0) {

    // Timer expired — fade toward zero until fully clear.
    _target_alpha = 0;
}

// Lerp toward target alpha each step (smooth fade).
vision_overlay_alpha = lerp(vision_overlay_alpha, _target_alpha, 0.08);

// ── Clear when fully faded ────────────────────────────────────────────────────
if (vision_timer <= 0 && vision_overlay_alpha < 0.01) {
    vision_overlay_alpha   = 0;
    current_vision_type    = "";
    global.manifestation_active = false;
    ds_list_clear(active_visions);
}
