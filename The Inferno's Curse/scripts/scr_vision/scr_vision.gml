/// @description Vision and sanity system — the horror Benedetto sees alone.
///
/// This script is the soul of the game. Everything here represents
/// psychological deterioration: what Benedetto witnesses, how his mind
/// fractures, and the point of no return when the visions consume him.
///
/// VISION INTENSITY: 0-100 composite score driven by Limbo corruption,
///   Gluttony corruption, and inverse sanity. Calculated every step by
///   scr_update_vision_intensity(). Controls how often visions trigger.
///
/// VISION TYPES (weighted by corruption source):
///   WALL_BREATHE    — Limbo corruption
///   FACE_DISTORT    — Lust corruption
///   SHADOW_WRONG    — Limbo corruption
///   GROUND_PULSE    — Gluttony corruption
///   THING_WATCHING  — Violence corruption
///   FULL_MANIFEST   — All corruption combined (only at intensity > 70)
///
/// SANITY THRESHOLDS:
///   75 — visions occasionally show false information
///   50 — player perceives beyond actual corruption; input sluggish
///   25 — screen edges distort constantly; vision cooldown halved
///    0 — game over ("He could no longer find his way back")


// =============================================================================
// Part 2 — Vision intensity update
// =============================================================================

/// Recalculates global.vision_intensity every step based on the three
/// weighted contributors: Limbo corruption, Gluttony corruption, and
/// inverse sanity. Result is clamped 0-100.
/// Called every step from obj_game_manager Step event.
function scr_update_vision_intensity() {
    var _limbo    = global.circle_corruption[CIRCLE_LIMBO];
    var _gluttony = global.circle_corruption[CIRCLE_GLUTTONY];

    // Weighted composite. The old "inverse sanity" 30% term IS Limbo corruption
    // now (sanity = 100 - Limbo), so it folds into Limbo's weight:
    //   Limbo    70% — grief/forgetting are the root of seeing wrongly (40% + 30%)
    //   Gluttony 30% — excess warps perception of space and flesh
    global.vision_intensity = clamp(
        _limbo    * 0.7 +
        _gluttony * 0.3,
        0, 100
    );
}


// =============================================================================
// Part 3 — Vision trigger check
// =============================================================================

/// Checks each step whether conditions are right to fire a vision.
/// Cooldown shortens as vision_intensity rises (more corruption = more
/// frequent visions). A probability roll prevents visions from being
/// perfectly predictable even at high intensity.
/// Called every step from obj_game_manager Step event.
function scr_check_trigger_vision() {
    // Never fire during battle or dialogue — no interrupting NPC conversations
    if (global.battle_active) exit;
    if (instance_exists(obj_dialogue_box) && obj_dialogue_box.is_active) exit;

    var _intensity = global.vision_intensity;
    var _now       = get_timer();   // microseconds since app start

    // ── Real-time cooldown ────────────────────────────────────────────────────
    // 10s base; drops to 5s at intensity >= 60; hard floor 3s.
    var _min_gap;
    if (_intensity >= 60) {
        _min_gap = 5000000;    // 5 seconds
    } else {
        _min_gap = 10000000;   // 10 seconds
    }
    _min_gap = max(_min_gap, 3000000);   // 3s hard floor

    if (_now - global.last_vision_time < _min_gap) exit;

    // ── Idle gate — no visions when player is standing still ─────────────────
    // Fires if player has moved in the last 5s, or day just advanced.
    if (!global.player_is_moving &&
        _now - global.last_player_move_time > 5000000) exit;

    // ── Probability roll ──────────────────────────────────────────────────────
    if (random(1) >= _intensity / 100) exit;

    scr_trigger_vision();
    global.last_vision_time = _now;
}


// =============================================================================
// Part 4 — Vision trigger (weighted random selection)
// =============================================================================

/// Selects a vision type weighted by the corruption levels that drive each
/// type, then activates it via obj_vision_manager and drains sanity.
/// Never fires FULL_MANIFEST below vision_intensity 70.
function scr_trigger_vision() {
    var _limbo    = global.circle_corruption[CIRCLE_LIMBO];
    var _lust     = global.circle_corruption[CIRCLE_LUST];
    var _gluttony = global.circle_corruption[CIRCLE_GLUTTONY];
    var _violence = global.circle_corruption[CIRCLE_VIOLENCE];
    var _all      = _limbo + _lust + _gluttony + _violence +
                    global.circle_corruption[CIRCLE_GREED] +
                    global.circle_corruption[CIRCLE_WRATH] +
                    global.circle_corruption[CIRCLE_HERESY];

    // ── Build weighted pool ───────────────────────────────────────────────────
    // Each entry is [type_string, weight, sanity_drain].
    // Weight 0 means the type cannot be selected (no corruption = no trigger).
    var _pool = [
        ["WALL_BREATHE",   _limbo,    2],
        ["FACE_DISTORT",   _lust,     3],
        ["SHADOW_WRONG",   _limbo,    2],
        ["GROUND_PULSE",   _gluttony, 4],
        ["THING_WATCHING", _violence, 5],
    ];

    // FULL_MANIFEST only available above intensity threshold — it is the worst.
    if (global.vision_intensity > 70) {
        var _full_weight = max(_all / 7, 1); // average corruption as weight
        array_push(_pool, ["FULL_MANIFEST", _full_weight, 10]);
    }

    // ── Weighted random pick ──────────────────────────────────────────────────
    var _total_weight = 0;
    for (var _i = 0; _i < array_length(_pool); _i++) {
        _total_weight += _pool[_i][1];
    }

    if (_total_weight <= 0) exit; // no corruption in any relevant circle

    var _roll = random(_total_weight);
    var _chosen_type  = "WALL_BREATHE";
    var _chosen_drain = 2;
    var _running = 0;
    for (var _i = 0; _i < array_length(_pool); _i++) {
        _running += _pool[_i][1];
        if (_roll < _running) {
            _chosen_type  = _pool[_i][0];
            _chosen_drain = _pool[_i][2];
            break;
        }
    }

    // ── Activate vision ───────────────────────────────────────────────────────
    // Communicate the chosen type to obj_vision_manager (if it exists).
    // The manager handles overlay rendering and timer.
    if (instance_exists(obj_vision_manager)) {
        obj_vision_manager.current_vision_type = _chosen_type;

        switch (_chosen_type) {
            case "WALL_BREATHE":    obj_vision_manager.vision_timer = irandom_range(120, 240); break; // 2-4 s
            case "FACE_DISTORT":    obj_vision_manager.vision_timer = irandom_range(30,  60);  break; // 0.5-1 s
            case "SHADOW_WRONG":    obj_vision_manager.vision_timer = 180;                     break; // 3 s
            case "GROUND_PULSE":    obj_vision_manager.vision_timer = irandom_range(60,  120); break; // 1-2 s
            case "THING_WATCHING":  obj_vision_manager.vision_timer = 180;                     break; // 3 s
            case "FULL_MANIFEST":   obj_vision_manager.vision_timer = irandom_range(180, 300); break; // 3-5 s
        }
    }

    // ── Taint: raise corruption ───────────────────────────────────────────────
    // Cap vision taint during battle — combat pressure is tracked separately
    if (global.battle_active) _chosen_drain = min(_chosen_drain, 2);
    scr_corruption_taint(_chosen_drain);

    // ── Log to global state ───────────────────────────────────────────────────
    global.last_vision_type    = _chosen_type;
    global.manifestation_count++;
    global.manifestation_active = true;

    scr_world_event_log(
        "Vision: " + _chosen_type +
        " [intensity:" + string(round(global.vision_intensity)) +
        " corruption:" + string(round(global.circle_corruption[CIRCLE_LIMBO])) + "]"
    );

    show_debug_message(
        "[Vision] " + _chosen_type +
        " | intensity:" + string(round(global.vision_intensity)) +
        " | corruption:" + string(round(global.circle_corruption[CIRCLE_LIMBO])) +
        " | taint:" + string(_chosen_drain)
    );
}


// =============================================================================
// Part 5 — (removed) Sanity drain → scr_corruption_taint()
// =============================================================================
// Corruption is the single madness axis. Raising it (with the narrative
// thresholds and the lost-state at 100) now lives in scr_corruption_taint() in
// scr_corruption.gml.


// =============================================================================
// Part 6 — (removed) Sanity restoration → scr_corruption_relieve()
// =============================================================================
// Relief now LOWERS Limbo corruption (with a floor — the scars never fully
// heal). See scr_corruption_relieve(amount, deep) in scr_corruption.gml.
// Callers (shrine, safe house) were updated to call it directly.


// =============================================================================
// Part 9 — Game over handler
// =============================================================================

/// Initiates the appropriate game-over sequence based on the cause of ending.
/// All branches fade to a colour, display a message with statistics, and
/// present restart / quit options.
///
/// Actual screen rendering is delegated to obj_vision_manager (overlay) and
/// a dedicated game-over Draw GUI flow — stubbed with debug output until
/// those are fully built.
///
/// @param {string} reason   "corruption" | "battle"
function scr_game_over(reason) {
    // Prevent double-fire if sanity hits 0 twice in the same frame.
    if (global.game_state == "game_over") exit;
    global.game_state = "game_over";

    // Snapshot statistics for the game-over screen.
    var _stats = {
        reason:             reason,
        days_survived:      global.day_count,
        visions_witnessed:  global.manifestation_count,
        final_corruption:   global.circle_corruption[CIRCLE_LIMBO],
        circle_corruption:  global.circle_corruption,
        player_sin_affinity: global.player_sin_affinity,
        last_vision_type:   global.last_vision_type
    };

    // Log to world state so debug tooling captures the ending.
    scr_world_event_log("[GAME OVER: " + reason + "] " +
        "Day " + string(global.day_count) + " | " +
        "Corruption " + string(round(global.circle_corruption[CIRCLE_LIMBO])) + " | " +
        "Visions " + string(global.manifestation_count)
    );

    // Pass stats to vision manager for overlay (fade colour + text).
    if (instance_exists(obj_vision_manager)) {
        obj_vision_manager.current_vision_type = "GAME_OVER_" + string(reason);
        obj_vision_manager.game_over_stats      = _stats;
        obj_vision_manager.vision_timer         = 9999; // hold until player acts
    }

    switch (reason) {

        // ── Corruption ending ─────────────────────────────────────────────────
        // Fade to deep red. The world forgot itself.
        case "corruption":
            show_debug_message(
                "[Game Over: corruption] " +
                "\"The world forgot itself completely.\" " +
                "Days: " + string(global.day_count)
            );
            // Placeholder room name: rm_game_over_corruption
            // Wire up in Prompt 8 room setup.
            // room_goto(rm_game_over_corruption);
            break;

        // ── Battle ending ─────────────────────────────────────────────────────
        // Fade to black. The body gave out.
        case "battle":
            show_debug_message(
                "[Game Over: battle] " +
                "\"Even blessed hands can only hold so much.\" " +
                "Days: " + string(global.day_count)
            );
            // Placeholder room name: rm_game_over_battle
            // Wire up in Prompt 8 room setup.
            // room_goto(rm_game_over_battle);
            break;

        default:
            show_debug_message("[Game Over: unknown reason '" + reason + "']");
            break;
    }
}
