/// @description Corruption system — utility functions for all seven circles
///
/// INDEXING: All circle arrays use 0-based indexing throughout the project.
///   0 = Limbo  |  1 = Lust  |  2 = Gluttony  |  3 = Greed
///   4 = Wrath  |  5 = Heresy  |  6 = Violence
///
/// INITIALISATION: Global arrays are declared in obj_game_manager Create_0.gml
///   and that object is first in Room1's creation order. Do NOT call
///   scr_corruption_init() — that function has been removed.

// ── Circle index constants (0-based) ─────────────────────────────────────────
// Use these macros everywhere instead of raw numbers so a rename is one change.
#macro CIRCLE_LIMBO    0
#macro CIRCLE_LUST     1
#macro CIRCLE_GLUTTONY 2
#macro CIRCLE_GREED    3
#macro CIRCLE_WRATH    4
#macro CIRCLE_HERESY   5
#macro CIRCLE_VIOLENCE 6
#macro CIRCLE_COUNT    7  // total number of circles; valid indices are 0..(CIRCLE_COUNT-1)

// ── Lucidity — the single madness axis ───────────────────────────────────────
// There is NO sanity stat. Limbo corruption IS Benedetto's grip on reality; he
// only THINKS he is going insane — it is the corruption tainting him. Anything
// that needs a "high = lucid" value (0-100) reads this view of corruption:
//   lucidity = 100 - clamp(Limbo corruption, 0, 100)
// So 0 corruption = 100 lucid, 100 corruption = 0 = lost.
function scr_lucidity() {
    return 100 - clamp(global.circle_corruption[CIRCLE_LIMBO], 0, 100);
}

/// Raises Limbo corruption by `amount` (was "drain sanity"). Fires the narrative
/// thresholds as it climbs and the lost-state at 100.
function scr_corruption_taint(amount) {
    var _prev = global.circle_corruption[CIRCLE_LIMBO];
    global.circle_corruption[CIRCLE_LIMBO] = clamp(_prev + amount, 0, 100);
    var _new  = global.circle_corruption[CIRCLE_LIMBO];

    if (_prev < 25 && _new >= 25)
        scr_world_event_log("[limbo_25] The visions begin to mislead. Benedetto can no longer trust what he sees.");
    if (_prev < 50 && _new >= 50)
        scr_world_event_log("[limbo_50] The corruption bleeds into things not yet corrupted. Benedetto sees what will be.");
    if (_prev < 75 && _new >= 75)
        scr_world_event_log("[limbo_75] The edges of the world have stopped holding. No clear boundary between seeing and dreaming.");
    if (_prev < 100 && _new >= 100)
        scr_game_over("corruption");
}

/// Lowers Limbo corruption by `amount` (was "restore sanity"). The scars never
/// fully heal — a floor remains (15 normally, 10 when `deep`, e.g. a solved
/// circle). Never raises corruption.
function scr_corruption_relieve(amount, deep) {
    if (is_undefined(deep)) deep = false;
    var _floor = deep ? 10 : 15;
    var _cur   = global.circle_corruption[CIRCLE_LIMBO];
    if (_cur > _floor) global.circle_corruption[CIRCLE_LIMBO] = max(_floor, _cur - amount);
}


// =============================================================================
// Corruption read / write
// =============================================================================

/// Raises or lowers corruption for one circle and logs major shifts.
/// @param {real}   circle   Circle index 0-6 (use CIRCLE_* macros)
/// @param {real}   amount   Delta — positive corrupts, negative cleanses
function scr_corruption_modify(circle, amount) {
    if (circle < 0 || circle >= CIRCLE_COUNT) exit;

    global.circle_corruption[circle] = clamp(
        global.circle_corruption[circle] + amount, 0, 100
    );

    // Only log shifts large enough to matter as world-event context for the API.
    if (abs(amount) >= 10) {
        var _verb = (amount > 0) ? "deepens in" : "recedes from";
        scr_world_event_log(
            "The corruption " + _verb + " " + global.circle_names[circle] + "."
        );
    }
}

/// Returns the current corruption level of a circle (0-100).
/// Returns 0 for out-of-range indices rather than erroring.
/// @param {real} circle   Circle index 0-6
/// @returns {real}
function scr_corruption_get(circle) {
    if (circle < 0 || circle >= CIRCLE_COUNT) return 0;
    return global.circle_corruption[circle];
}

/// Returns the mean corruption across all seven circles (0-100).
/// @returns {real}
function scr_corruption_global_average() {
    var _total = 0;
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        _total += global.circle_corruption[_i];
    }
    return _total / CIRCLE_COUNT;
}


// =============================================================================
// Corruption spread
// =============================================================================

/// Bleeds corruption from each circle into its immediate neighbours.
/// Uses global.circle_bleed_rate and global.circle_bleed_threshold so
/// each circle can have different spread behaviour tuned in obj_game_manager.
///
/// Call after significant world events (boss defeats, rests, day transitions).
/// Limbo (0) and Violence (6) only have one neighbour each.
function scr_corruption_spread() {
    // Build new values in a scratch array so neighbour reads are from the
    // CURRENT state, not the partially-updated one.
    var _new_vals = array_create(CIRCLE_COUNT, 0);

    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        var _val   = global.circle_corruption[_i];
        var _bleed = 0;

        // Left neighbour — only exists for circles 1-6
        if (_i > 0) {
            var _left = global.circle_corruption[_i - 1];
            // Only bleeds if it has crossed its own threshold
            if (_left > global.circle_bleed_threshold[_i - 1]) {
                _bleed += _left * global.circle_bleed_rate[_i - 1];
            }
        }

        // Right neighbour — only exists for circles 0-5
        if (_i < CIRCLE_COUNT - 1) {
            var _right = global.circle_corruption[_i + 1];
            if (_right > global.circle_bleed_threshold[_i + 1]) {
                _bleed += _right * global.circle_bleed_rate[_i + 1];
            }
        }

        _new_vals[_i] = clamp(_val + _bleed, 0, 100);
    }

    global.circle_corruption = _new_vals;
    scr_world_event_log("The corruption shifts, bleeding across the circle boundaries.");
}


// =============================================================================
// World event log
// =============================================================================

/// Prepends a text entry to the world event log. Oldest entry is dropped
/// when the log exceeds 20 entries.
/// @param {string} text   Short description of what happened
function scr_world_event_log(text) {
    array_insert(global.world_event_log, 0, text);
    if (array_length(global.world_event_log) > 20) {
        array_delete(global.world_event_log, 20, 1);
    }
}

/// Returns the most recent world events concatenated into one string
/// for inclusion in Claude API system prompts.
/// @param {real}   count   How many recent entries to include (capped at log length)
/// @returns {string}
function scr_world_events_to_string(count) {
    var _max = min(count, array_length(global.world_event_log));
    if (_max == 0) return "Nothing notable has occurred yet.";
    var _out = "";
    for (var _i = 0; _i < _max; _i++) {
        _out += global.world_event_log[_i];
        if (_i < _max - 1) _out += " ";
    }
    return _out;
}


// =============================================================================
// Sin affinity
// =============================================================================

/// Adjusts the player's affinity with a particular circle's sin.
/// Stored in global.player_sin_affinity (0-indexed, matches circle arrays).
/// @param {real} circle   Circle index 0-6
/// @param {real} amount   Delta — positive builds affinity, negative reduces it
function scr_sin_affinity_modify(circle, amount) {
    if (circle < 0 || circle >= CIRCLE_COUNT) exit;
    global.player_sin_affinity[circle] = clamp(
        global.player_sin_affinity[circle] + amount, 0, 100
    );
}

/// Returns the player's sin profile as a compact string for API context.
/// Only includes circles where affinity is non-zero.
/// @returns {string}
function scr_sin_profile_to_string() {
    var _out = "";
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        if (global.player_sin_affinity[_i] > 0) {
            _out += global.sin_names[_i] + ":" +
                    string(global.player_sin_affinity[_i]) + " ";
        }
    }
    return (_out == "") ? "No notable sin affinity yet." : string_trim(_out);
}


// =============================================================================
// Per-step corruption polling
// =============================================================================

// DESIGN: Limbo is the root corruption.
// Solving Limbo stops all downstream bleed.
// Each circle only bleeds when its upstream trigger threshold is met.

/// Called every step from obj_game_manager Step event.
/// Checks all circle corruption levels and fires sin effects for any
/// circle above the 30% active threshold.
/// Threshold is 30 on the 0-100 corruption scale (the single axis; 100 = lost).
function scr_corruption_update() {
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        // Only ENABLED circles apply their per-frame sin effect. Disabled circles
        // stay dormant even if corruption bled past the threshold.
        // TODO: circles enable as the player reaches their cities (scr_solve_circle).
        if (!global.circle_enabled[_i]) continue;
        if (global.circle_corruption[_i] > 30) {
            scr_apply_sin_effect(_i);
        }
    }
    // Apply continuous scaled effects for the current circle.
    scr_apply_active_sin_effects();
}


// =============================================================================
// Continuous sin effects (per-step scaled)
// =============================================================================

/// Loops all 7 circles and applies a proportional ongoing effect for each
/// one above the 30% threshold. Effects scale with the corruption percentage.
/// Called at the end of scr_corruption_update() every step.
function scr_apply_active_sin_effects() {
    for (var _i = 0; _i < CIRCLE_COUNT; _i++) {
        // Only ENABLED circles apply continuous effects (HP drain, price mods, etc.).
        // This is what stopped Lust draining HP while the player is still in Limbo.
        // TODO: circles enable as the player reaches their cities (scr_solve_circle).
        if (!global.circle_enabled[_i]) continue;
        var _c = global.circle_corruption[_i];
        if (_c <= 30) continue;

        // Normalised 0.0-1.0 intensity above the threshold.
        // At corruption=30 this is 0.0; at corruption=100 it reaches 1.0.
        var _intensity = (_c - 30) / 70;

        switch (_i) {

            // ── Limbo: no continuous self-erosion ─────────────────────────────
            // Corruption IS the madness axis now, so it must not drain itself —
            // it rises via new-day accrual, visions (scr_corruption_taint), and
            // battle. Nothing to do here continuously.
            case CIRCLE_LIMBO:
                break;

            // ── Lust: HP drain via desire ─────────────────────────────────────
            // The pull of desire is physically exhausting the longer it's resisted.
            case CIRCLE_LUST:
                // Handled per-frame in scr_apply_sin_effect (attraction pulse).
                // The continuous effect here is a gentle HP bleed from longing.
                if (instance_exists(obj_player)) {
                    obj_player.hp -= 0.002 * _intensity;
                }
                break;

            // ── Gluttony: HP + speed drain ────────────────────────────────────
            // The circle's excess weighs the player down each step.
            case CIRCLE_GLUTTONY:
                if (instance_exists(obj_player)) {
                    obj_player.hp -= 0.005 * _intensity;
                    // Speed penalty applied directly to the player's move_spd.
                    // scr_apply_sin_effect handles the per-frame modifier.
                }
                break;

            // ── Greed: price inflation ────────────────────────────────────────
            // Avarice seeps into every transaction. Runs each step so the
            // modifier stays current as corruption rises.
            case CIRCLE_GREED:
                global.shop_price_modifier = 1.0 + (_c / 100);
                break;

            // ── Wrath: attack modifiers ───────────────────────────────────────
            // Rage sharpens speed but clouds aim.
            case CIRCLE_WRATH:
                global.attack_speed_modifier = 1.0 + (_c / 100);
                global.attack_accuracy       = 1.0 - (_c / 150);
                global.attack_accuracy       = max(global.attack_accuracy, 0.1);
                break;

            // ── Heresy: HUD flicker ───────────────────────────────────────────
            // Doubt erodes the interface — handled as event-driven in
            // scr_apply_sin_effect; nothing continuous here.
            case CIRCLE_HERESY:
                break;

            // ── Violence: nothing continuous ──────────────────────────────────
            // Control inversion is event-driven (per-trigger in sin_effect).
            case CIRCLE_VIOLENCE:
                break;
        }
    }
}


// =============================================================================
// Event-driven sin effects (triggered per circle on threshold cross)
// =============================================================================

/// Applies a one-time / probabilistic sin effect for the given circle.
/// Called every step from scr_corruption_update() for each active circle,
/// so frequency gates inside each case must use step counters or irandom().
/// @param {real} circle_index   Circle index 0-6 (use CIRCLE_* macros)
function scr_apply_sin_effect(circle_index) {
    var _c = global.circle_corruption[circle_index];

    switch (circle_index) {

        // ── CIRCLE 0: LIMBO — input dissociation ──────────────────────────────
        // Grief blanks the mind. The player briefly loses control as the world
        // goes grey — a mechanical echo of forgetting who you are.
        case CIRCLE_LIMBO:
            // Fire roughly once per (130 - _c) steps. At corruption=30 that
            // is ~100 steps (~1.7 s at 60 fps); at corruption=100 it hits the
            // 30-step floor (~0.5 s).
            var _freq_limbo = max(130 - _c, 30);
            if (!global.input_locked && irandom(_freq_limbo) == 0) {
                global.input_locked    = true;
                global.input_lock_timer = 30; // 0.5 s at 60 fps
                // Grey flash: draw_set_colour and alpha handled in obj_player Draw.
                // Signal via a global so the Draw event can read it cheaply.
                global.vision_intensity = min(global.vision_intensity + 20, 100);
                scr_world_event_log("A moment of grey dissociation — Limbo takes hold.");
            }
            break;

        // ── CIRCLE 1: LUST — gravitational pull toward enemies ────────────────
        // Desire is a force. The player is drawn toward what they shouldn't want.
        case CIRCLE_LUST:
            // TODO: pull the player toward the nearest overworld enemy once an
            // enemy object exists. Stubbed — there is no overworld enemy object
            // yet, and the old obj_enemy reference was undefined (runtime crash).
            // When overworld enemies ship, restore the instance_nearest pull and
            // gate it with object_exists() on the real enemy object.
            //
            // Crimson pulse intensity is read by the Draw GUI event.
            // vision_intensity doubles as the screen-edge tint driver.
            global.vision_intensity = min(global.vision_intensity + (0.1 * (_c / 100)), 100);
            break;

        // ── CIRCLE 2: GLUTTONY — slowing weight ───────────────────────────────
        // Excess fills the body until movement becomes agony.
        case CIRCLE_GLUTTONY:
            if (instance_exists(obj_player)) {
                // Speed reduction: up to 50% at corruption=100 (the max).
                // Writes to player variable each step; player Create must set
                // a base_move_spd that this can reference.
                var _spd_penalty = obj_player.base_move_spd * (_c / 100) * 0.5;
                obj_player.move_spd = max(obj_player.base_move_spd - _spd_penalty, 0.5);
            }
            break;

        // ── CIRCLE 3: GREED — shop inflation ─────────────────────────────────
        // Handled entirely in scr_apply_active_sin_effects (continuous modifier).
        // Gold flicker is a Draw GUI responsibility; no step logic here.
        case CIRCLE_GREED:
            break;

        // ── CIRCLE 4: WRATH — combat distortion ──────────────────────────────
        // Rage is already applied continuously in scr_apply_active_sin_effects.
        // Screen tint is read by Draw GUI from vision_intensity.
        case CIRCLE_WRATH:
            if (_c > 70) {
                // Ramp up the red tint signal above the wrath threshold.
                global.vision_intensity = min(global.vision_intensity + 0.5, 100);
            }
            break;

        // ── CIRCLE 5: HERESY — HUD corruption ────────────────────────────────
        // Doubt makes the interface lie. At high corruption even damage numbers
        // cannot be trusted.
        case CIRCLE_HERESY:
            // Rare HUD flicker (roughly once per 240 steps under normal corruption).
            if (irandom(240) == 0) {
                global.vision_intensity = min(global.vision_intensity + 15, 100);
                scr_world_event_log("The interface shudders — Heresy distorts what is real.");
            }
            // Fake damage numbers: only at corruption > 60.
            if (_c > 60 && irandom(180) == 0) {
                // Spawn a false damage indicator at a random screen position.
                // The actual damage-number object reads a global flag to know
                // it is fake (so no real damage is applied).
                // TODO: replace with instance_create_layer when damage objects exist.
                show_debug_message("[Heresy] Fake damage number triggered at corruption " + string(_c));
            }
            break;

        // ── CIRCLE 6: VIOLENCE — control inversion ────────────────────────────
        // At the bottom of hell, violence turns everything against itself —
        // including the player's own hands.
        case CIRCLE_VIOLENCE:
            if (_c > 50 && !global.input_locked) {
                // Frequency: once per (250 - (_c-50)*3) steps. At _c=50 → 250
                // steps (~4 s); at _c=100 → ~100 steps (~1.7 s).
                var _freq_violence = max(250 - (_c - 50) * 3, 60);
                if (irandom(_freq_violence) == 0) {
                    global.input_locked     = true;
                    global.input_lock_timer  = 60; // 1 second at 60 fps
                    // Inversion flag: obj_player reads this to flip movement direction.
                    global.vision_intensity  = min(global.vision_intensity + 30, 100);
                    scr_world_event_log("Violence inverts — hands move against their owner's will.");
                }
            }
            break;
    }
}


// =============================================================================
// API context builder
// =============================================================================

/// Builds a JSON string summarising the current corruption state of all
/// seven circles. Used as context in Claude API system prompts so the AI
/// knows how far Hell has claimed each region.
/// @returns {string}   JSON-formatted corruption snapshot
function scr_get_bleed_context() {
    // Find the dominant (highest) circle.
    var _dom_idx   = 0;
    var _dom_level = global.circle_corruption[0];
    for (var _i = 1; _i < CIRCLE_COUNT; _i++) {
        if (global.circle_corruption[_i] > _dom_level) {
            _dom_level = global.circle_corruption[_i];
            _dom_idx   = _i;
        }
    }

    var _state = {
        limbo:         global.circle_corruption[CIRCLE_LIMBO],
        lust:          global.circle_corruption[CIRCLE_LUST],
        gluttony:      global.circle_corruption[CIRCLE_GLUTTONY],
        greed:         global.circle_corruption[CIRCLE_GREED],
        wrath:         global.circle_corruption[CIRCLE_WRATH],
        heresy:        global.circle_corruption[CIRCLE_HERESY],
        violence:      global.circle_corruption[CIRCLE_VIOLENCE],
        dominant_sin:  global.circle_names[_dom_idx],
        dominant_level: _dom_level,
        day:           global.day_count,
        time:          global.time_of_day
    };

    return json_stringify(_state);
}


// =============================================================================
// Circle solving
// =============================================================================

/// Resets a circle's corruption to zero, restores partial sanity, logs the
/// event, and signals a room transition to the next circle.
///
/// DESIGN: Solving a circle stops its bleed entirely (corruption=0 means
/// it can no longer meet any downstream threshold). Sanity is restored but
/// capped at 85 mid-game — the world's scars leave a permanent mark.
///
/// @param {real} circle_index   Circle index 0-6 (use CIRCLE_* macros)
function scr_solve_circle(circle_index) {
    if (circle_index < 0 || circle_index >= CIRCLE_COUNT) exit;

    var _name = global.circle_names[circle_index];

    // ── Reset corruption ──────────────────────────────────────────────────────
    // Setting to 0 also stops all downstream bleed triggered by this circle,
    // because every cascade threshold check (>= 60, >= 75, etc.) will fail.
    global.circle_corruption[circle_index] = 0;

    // ── Relief is implicit ────────────────────────────────────────────────────
    // Corruption for this circle was just zeroed above, which is the cure — and
    // since corruption IS the madness axis, perceived sanity is restored with it.

    // ── Unlock input if it was locked ─────────────────────────────────────────
    // Solving the circle that caused a dissociation should free the player.
    if (circle_index == CIRCLE_LIMBO || circle_index == CIRCLE_VIOLENCE) {
        global.input_locked     = false;
        global.input_lock_timer  = 0;
    }

    // ── Restore combat modifiers if wrath/greed are solved ───────────────────
    if (circle_index == CIRCLE_WRATH) {
        global.attack_speed_modifier = 1.0;
        global.attack_accuracy       = 1.0;
    }
    if (circle_index == CIRCLE_GREED) {
        global.shop_price_modifier = 1.0;
    }

    // ── World event log ───────────────────────────────────────────────────────
    scr_world_event_log("Circle solved: " + _name + ". The corruption recedes.");

    show_debug_message("[solve] Circle " + string(circle_index) + " (" + _name + ") solved. Limbo corruption: " + string(global.circle_corruption[CIRCLE_LIMBO]));

    // ── Room transition ───────────────────────────────────────────────────────
    // Advance to the next circle. Violence (6) is the final circle — no room
    // beyond it (handled by checking index bounds).
    // TODO: replace room_goto with a proper transition manager once rooms exist.
    var _next = circle_index + 1;
    if (_next < CIRCLE_COUNT) {
        global.current_circle      = _next;
        global.circle_enabled[_next] = true;   // unlock the next circle's effects + bleed
        // room_goto(asset_get_index("rm_circle_" + string(_next)));
        show_debug_message("[transition] → Circle " + string(_next) + " (" + global.circle_names[_next] + ") — enabled");
    } else {
        // Player has solved all seven circles — game ending branch.
        scr_world_event_log("All circles cleansed. The Inferno's Curse is broken.");
        show_debug_message("[ending] All circles solved.");
        // room_goto(rm_ending);
    }
}
