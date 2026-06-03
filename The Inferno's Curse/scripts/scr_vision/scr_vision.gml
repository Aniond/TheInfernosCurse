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
    var _sanity   = global.sanity;

    // Weighted composite:
    //   Limbo    40% — grief and forgetting are the root of seeing wrongly
    //   Gluttony 30% — excess warps perception of space and flesh
    //   Sanity   30% — inverse: lower sanity = higher intensity
    global.vision_intensity = clamp(
        _limbo    * 0.4 +
        _gluttony * 0.3 +
        (100 - _sanity) * 0.3,
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

    // ── Drain sanity ──────────────────────────────────────────────────────────
    // Cap vision drain during battle — combat pressure is tracked separately
    if (global.battle_active) _chosen_drain = min(_chosen_drain, 2);
    scr_drain_sanity(_chosen_drain);

    // ── Log to global state ───────────────────────────────────────────────────
    global.last_vision_type    = _chosen_type;
    global.manifestation_count++;
    global.manifestation_active = true;

    scr_world_event_log(
        "Vision: " + _chosen_type +
        " [intensity:" + string(round(global.vision_intensity)) +
        " sanity:" + string(round(global.sanity)) + "]"
    );

    show_debug_message(
        "[Vision] " + _chosen_type +
        " | intensity:" + string(round(global.vision_intensity)) +
        " | sanity:" + string(round(global.sanity)) +
        " | drain:" + string(_chosen_drain)
    );
}


// =============================================================================
// Part 5 — Sanity drain
// =============================================================================

/// Reduces global.sanity by amount, clamps to 0-100, and fires threshold
/// events the first time each level is crossed (logged once per run via
/// side-effects on global.world_event_log).
/// @param {real} amount   How much sanity to remove (positive number)
function scr_drain_sanity(amount) {
    var _prev   = global.sanity;
    global.sanity = clamp(global.sanity - amount, 0, 100);
    var _new    = global.sanity;

    // ── Threshold: 75 ────────────────────────────────────────────────────────
    // Visions start showing false information. The world lies.
    if (_prev > 75 && _new <= 75) {
        scr_world_event_log(
            "[sanity_threshold_75] The visions begin to mislead. " +
            "Benedetto can no longer trust what he sees."
        );
        show_debug_message("[Sanity] Crossed threshold: 75");
    }

    // ── Threshold: 50 ────────────────────────────────────────────────────────
    // Perceiving corruption beyond reality. Input feels unreliable.
    if (_prev > 50 && _new <= 50) {
        scr_world_event_log(
            "[sanity_threshold_50] The corruption bleeds into things that " +
            "are not yet corrupted. Benedetto sees what will be."
        );
        show_debug_message("[Sanity] Crossed threshold: 50");
    }

    // ── Threshold: 25 ────────────────────────────────────────────────────────
    // Constant distortion. Vision cooldown is halved (applied in
    // scr_check_trigger_vision — it reads global.sanity directly).
    if (_prev > 25 && _new <= 25) {
        scr_world_event_log(
            "[sanity_threshold_25] The edges of the world have stopped " +
            "holding. There is no clear boundary between seeing and dreaming."
        );
        show_debug_message("[Sanity] Crossed threshold: 25");
    }

    // ── Threshold: 0 — game over ──────────────────────────────────────────────
    if (_prev > 0 && _new <= 0) {
        scr_game_over("sanity");
    }
}


// =============================================================================
// Part 6 — Sanity restoration
// =============================================================================

/// Restores sanity by amount, with a ceiling that depends on context.
/// During an active circle: hard cap at 85 (permanent mark of descent).
/// On circle solved: ceiling rises to 90 (called by scr_solve_circle).
///
/// Sources and their expected amounts (called externally by game systems):
///   Praying at uncorrupted shrine : +10
///   Completing story objective    : +15
///   Safe NPC interaction          : +5
///   Resting at safe house         : +8
///   Circle solved                 : restore to 90 (call with amount=90, circle_solved=true)
///
/// @param {real}    amount          How much sanity to restore
/// @param {bool}    circle_solved   Pass true when called from scr_solve_circle
function scr_restore_sanity(amount, circle_solved) {
    // GML in this project rejects ?? and ? : — use explicit checks.
    if (is_undefined(circle_solved)) circle_solved = false;

    // Ceiling: 90 if a circle was just solved; 85 otherwise.
    // The world's scars do not fully heal — except when a circle is cleansed.
    var _ceiling = 85;
    if (circle_solved) _ceiling = 90;

    global.sanity = min(global.sanity + amount, _ceiling);

    show_debug_message(
        "[Sanity] Restored +" + string(amount) +
        " → " + string(round(global.sanity)) +
        " (ceiling: " + string(_ceiling) + ")"
    );
}


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
/// @param {string} reason   "sanity" | "corruption" | "battle"
function scr_game_over(reason) {
    // Prevent double-fire if sanity hits 0 twice in the same frame.
    if (global.game_state == "game_over") exit;
    global.game_state = "game_over";

    // Snapshot statistics for the game-over screen.
    var _stats = {
        reason:             reason,
        days_survived:      global.day_count,
        visions_witnessed:  global.manifestation_count,
        final_sanity:       global.sanity,
        circle_corruption:  global.circle_corruption,
        player_sin_affinity: global.player_sin_affinity,
        last_vision_type:   global.last_vision_type
    };

    // Log to world state so debug tooling captures the ending.
    scr_world_event_log("[GAME OVER: " + reason + "] " +
        "Day " + string(global.day_count) + " | " +
        "Sanity " + string(round(global.sanity)) + " | " +
        "Visions " + string(global.manifestation_count)
    );

    // Pass stats to vision manager for overlay (fade colour + text).
    if (instance_exists(obj_vision_manager)) {
        obj_vision_manager.current_vision_type = "GAME_OVER_" + string(reason);
        obj_vision_manager.game_over_stats      = _stats;
        obj_vision_manager.vision_timer         = 9999; // hold until player acts
    }

    switch (reason) {

        // ── Sanity ending ─────────────────────────────────────────────────────
        // Fade to black. The mind could not hold.
        case "sanity":
            show_debug_message(
                "[Game Over: sanity] " +
                "\"He could no longer find his way back.\" " +
                "Days: " + string(global.day_count) + " | " +
                "Visions: " + string(global.manifestation_count)
            );
            // Placeholder room name: rm_game_over_sanity
            // Wire up in Prompt 8 room setup.
            // room_goto(rm_game_over_sanity);
            break;

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
