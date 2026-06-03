// =============================================================================
// scr_battle — Prompt 12: Limbo Battle System
// =============================================================================
// Grid, unit utilities, Limbo tile placement/movement, status effects,
// Dante intervention, Marco name snap-back.
// All constants here are the single source of truth for the battle room.
// =============================================================================

// ── Grid layout constants ─────────────────────────────────────────────────────
#macro BATTLE_GRID_W      10     // columns (x)
#macro BATTLE_GRID_H       8     // rows    (y)
#macro BATTLE_TILE_SIZE   64     // pixels per tile (square)
#macro BATTLE_GRID_X     192     // screen x of tile (0,0) top-left
#macro BATTLE_GRID_Y      64     // screen y of tile (0,0) top-left

// ── Limbo tile tuning ─────────────────────────────────────────────────────────
#macro LIMBO_TILE_MIN      2     // fewest tiles at 0% corruption
#macro LIMBO_TILE_MAX     10     // most tiles at 100% corruption
#macro LIMBO_SHIMMER_COST  3     // sanity lost when Benedetto focuses to see a tile
#macro LIMBO_SHIMMER_STEPS 120   // how long the shimmer stays visible (2 s @ 60 fps)
#macro LIMBO_TILE_MOVE_INTERVAL 360  // steps between tile moves (6 s @ 60 fps).
                                     // Was 90 (1.5 s) — too fast; tiles scattered
                                     // right after a Focus reveal, killing its value.

// ── Corruption threshold for tile movement ────────────────────────────────────
// Tiles relocate once corruption passes this. Movement is intentional — it just
// happens on a slow interval (above) so a Focus reveal stays actionable.
#macro LIMBO_MOVE_THRESHOLD 75

// ── Forgotten status tuning ───────────────────────────────────────────────────
#macro HOLLOW_BASE_FORGET_CHANCE  0.15  // 15% at 0% corruption
#macro HOLLOW_FORGET_SCALE        0.50  // +50% at 100% corruption (max ~65%)


// =============================================================================
// COORDINATE HELPERS
// =============================================================================

/// Returns the screen-centre {x,y} of a given grid cell.
/// @param {real} gx   Grid column (0 to BATTLE_GRID_W-1)
/// @param {real} gy   Grid row    (0 to BATTLE_GRID_H-1)
/// @returns {struct}
function scr_battle_grid_to_screen(gx, gy) {
    return {
        x: BATTLE_GRID_X + gx * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2,
        y: BATTLE_GRID_Y + gy * BATTLE_TILE_SIZE + BATTLE_TILE_SIZE / 2,
    };
}

/// Returns true if (gx, gy) is inside the grid.
/// @param {real} gx
/// @param {real} gy
/// @returns {bool}
function scr_battle_is_valid_cell(gx, gy) {
    return (gx >= 0 && gx < BATTLE_GRID_W && gy >= 0 && gy < BATTLE_GRID_H);
}

/// Returns the unit instance at (gx, gy), or noone.
/// @param {real} gx
/// @param {real} gy
/// @returns {id|noone}
function scr_battle_unit_at_cell(gx, gy) {
    with (obj_unit_base) {
        if (grid_x == gx && grid_y == gy) return id;
    }
    return noone;
}

/// Returns true if any unit (except except_id) occupies (gx, gy).
/// @param {real}   gx
/// @param {real}   gy
/// @param {id}     except_id   Pass noone to check all units.
/// @returns {bool}
function scr_battle_cell_occupied(gx, gy, except_id) {
    with (obj_unit_base) {
        if (id == except_id) continue;
        if (grid_x == gx && grid_y == gy) return true;
    }
    return false;
}

/// Returns a random unoccupied grid cell struct {gx, gy}.
/// Returns {gx:-1, gy:-1} if no empty cell found after 200 attempts.
/// @returns {struct}
function scr_battle_random_empty_cell() {
    var _attempts = 0;
    repeat (200) {
        var _gx = irandom(BATTLE_GRID_W - 1);
        var _gy = irandom(BATTLE_GRID_H - 1);
        if (!scr_battle_cell_occupied(_gx, _gy, noone)) {
            return { gx: _gx, gy: _gy };
        }
        _attempts++;
    }
    return { gx: -1, gy: -1 };
}


// =============================================================================
// LIMBO TILE PLACEMENT + MOVEMENT
// =============================================================================

/// How many Limbo tiles to place given a corruption level (0-100).
/// Scales linearly from LIMBO_TILE_MIN to LIMBO_TILE_MAX.
/// @param {real} corruption   0-100
/// @returns {real}
function scr_battle_tile_count(corruption) {
    return clamp(
        LIMBO_TILE_MIN + floor((corruption / 100) * (LIMBO_TILE_MAX - LIMBO_TILE_MIN)),
        LIMBO_TILE_MIN, LIMBO_TILE_MAX
    );
}

/// Spawns Limbo tiles on random empty cells according to current corruption.
/// Called once from obj_battle_manager Create after units are placed.
/// @param {real} corruption   Current battle_corruption (0-100)
function scr_battle_place_limbo_tiles(corruption) {
    var _count = scr_battle_tile_count(corruption);
    var _placed = 0;
    repeat (200) {
        if (_placed >= _count) break;
        var _gx = irandom(BATTLE_GRID_W - 1);
        var _gy = irandom(BATTLE_GRID_H - 1);
        if (!scr_battle_cell_occupied(_gx, _gy, noone)) {
            var _pos = scr_battle_grid_to_screen(_gx, _gy);
            var _tile = instance_create_layer(_pos.x, _pos.y, "Instances", obj_limbo_tile);
            _tile.grid_x = _gx;
            _tile.grid_y = _gy;
            _placed++;
        }
    }
    show_debug_message("[battle] Placed " + string(_placed) + " Limbo tiles (corruption=" + string(corruption) + ")");
}

/// Moves all existing Limbo tiles one step in a random cardinal direction.
/// Called by obj_battle_manager Step when corruption >= LIMBO_MOVE_THRESHOLD.
/// Tiles that cannot move (all neighbours occupied/invalid) stay put.
function scr_battle_move_limbo_tiles() {
    var _dirs = [
        [  0,  1 ],
        [  0, -1 ],
        [  1,  0 ],
        [ -1,  0 ],
    ];
    with (obj_limbo_tile) {
        var _dir = _dirs[irandom(3)];
        var _nx  = grid_x + _dir[0];
        var _ny  = grid_y + _dir[1];
        if (scr_battle_is_valid_cell(_nx, _ny)
         && scr_battle_unit_at_cell(_nx, _ny) == noone) {
            grid_x = _nx;
            grid_y = _ny;
            triggered = false;   // reset so it can fire again on new cell
        }
    }
}

/// Checks if any Limbo tile occupies the same cell as unit_id.
/// If so, teleports the unit to a random empty cell and re-positions the tile.
/// @param {id} unit_id   A unit instance (obj_unit_base or child)
function scr_battle_check_limbo_tile(unit_id) {
    with (obj_limbo_tile) {
        if (grid_x == unit_id.grid_x && grid_y == unit_id.grid_y && !triggered) {
            triggered = true;
            alarm[0] = 60;   // reset trigger after 1 second

            // Teleport the unit
            var _dest = scr_battle_random_empty_cell();
            if (_dest.gx != -1) {
                unit_id.grid_x = _dest.gx;
                unit_id.grid_y = _dest.gy;
            }

            // Move the tile to a new position
            var _new_pos = scr_battle_random_empty_cell();
            if (_new_pos.gx != -1) {
                grid_x = _new_pos.gx;
                grid_y = _new_pos.gy;
            }

            // Sanity cost for stepping into a Limbo fold
            global.sanity = max(1, global.sanity - 3);
            scr_battle_add_log(unit_id.unit_name + " stepped through the fold. Sanity -3.");

            scr_world_event_log(
                "The floor forgot where it was. So did " + unit_id.unit_name + "."
            );
            break;   // only one tile triggers per move
        }
    }
}


// =============================================================================
// FOCUS ABILITY  (Benedetto's sight — reveals hidden Limbo tiles)
// =============================================================================

/// Returns the Focus class label + charge data for a sanity value.
/// charges = (a) total battle presses (set once at battle start, never refreshed)
///           (b) tiles revealed per press — same number, class-determined.
/// MINIMUM 1 — the Forgotten always has one last charge.
function scr_focus_class(sanity) {
    if (sanity >= 75) return { name: "The Priest",    charges: 4 };  // 75-100%
    if (sanity >= 50) return { name: "The Witness",   charges: 3 };  // 50-74%
    if (sanity >= 25) return { name: "The Tainted",   charges: 2 };  // 25-49%
    if (sanity >= 10) return { name: "The Cursed",    charges: 1 };  // 10-24%
    return { name: "The Forgotten", charges: 1 };                    // 1-9% — never 0
}

/// Focus (F). Each press costs -3 sanity, spends 1 battle charge, and reveals
/// class-based tile count (Priest=4, Witness=3, Tainted=2, Cursed/Forgotten=1).
/// Charges are per BATTLE — set at battle start, never refreshed between turns.
/// Cursed/Forgotten sight may lie (perception check). Tile-move timer resets on use.
function scr_battle_focus() {
    // Spent — no charges left this battle. Debug mode is never spent.
    if (!global.debug_mode && global.focus_charges <= 0) return;

    var _info    = scr_focus_class(global.sanity);
    var _is_last = (global.focus_charges <= 1);   // this press is the last charge

    // Sanity cost — always, regardless of charges remaining or tiles found
    global.sanity = max(1, global.sanity - LIMBO_SHIMMER_COST);

    // Focusing buys time: revealed tiles hold position for a full move interval.
    with (obj_battle_manager) tile_move_timer = 0;

    // Low-sanity sight can deceive: Cursed/Forgotten may reveal a FALSE tile.
    var _revealed = 0;
    if ((_info.name == "The Cursed" || _info.name == "The Forgotten")
        && irandom_range(1, 100) > global.sanity) {
        scr_battle_false_reveal();   // a normal cell, highlighted as Limbo
        _revealed = 1;
    } else {
        // Reveal up to _info.charges hidden Limbo tiles (class-based count)
        var _hidden = [];
        with (obj_limbo_tile) {
            if (!is_shimmer_visible) array_push(_hidden, id);
        }
        var _to_reveal = min(_info.charges, array_length(_hidden));
        for (var _i = 0; _i < _to_reveal; _i++) {
            var _pick_idx = irandom(array_length(_hidden) - 1);
            with (_hidden[_pick_idx]) { is_shimmer_visible = true; shimmer_timer = 0; }
            array_delete(_hidden, _pick_idx, 1);
        }
        _revealed = _to_reveal;
    }

    // Spend a charge (debug mode never depletes)
    if (!global.debug_mode) global.focus_charges = max(0, global.focus_charges - 1);

    // Chronicle — the Forgotten's final charge gets its own line
    if (_info.name == "The Forgotten" && _is_last) {
        scr_battle_add_log("He strains with everything he has left. One moment. Just one. It has to be enough.");
    } else if (_revealed > 1) {
        scr_battle_add_log("He focuses. " + string(_revealed) + " places reveal themselves.");
    } else {
        scr_battle_add_log("He focuses. One place reveals itself.");
    }
}

/// Lights a FALSE shimmer on a random valid cell that holds NO real Limbo tile.
/// The Cursed class's perception failure. Drawn by obj_battle_manager.
function scr_battle_false_reveal() {
    var _candidates = [];
    for (var _gx = 0; _gx < BATTLE_GRID_W; _gx++) {
        for (var _gy = 0; _gy < BATTLE_GRID_H; _gy++) {
            if (!scr_battle_is_valid_cell(_gx, _gy)) continue;
            var _has_tile = false;
            with (obj_limbo_tile) { if (grid_x == _gx && grid_y == _gy) _has_tile = true; }
            if (!_has_tile) array_push(_candidates, [_gx, _gy]);
        }
    }
    if (array_length(_candidates) == 0) return;
    var _pick = _candidates[irandom(array_length(_candidates) - 1)];
    global.false_shimmer_gx     = _pick[0];
    global.false_shimmer_gy     = _pick[1];
    global.false_shimmer_active = true;
    global.false_shimmer_timer  = LIMBO_SHIMMER_STEPS;
}


// =============================================================================
// STATUS EFFECTS
// =============================================================================

/// Returns true if unit_id has the named status effect.
/// @param {id}     unit_id
/// @param {string} status_name
/// @returns {bool}
function scr_battle_has_status(unit_id, status_name) {
    var _effects = unit_id.status_effects;
    for (var _i = 0; _i < array_length(_effects); _i++) {
        if (_effects[_i] == status_name) return true;
    }
    return false;
}

/// Adds a named status effect to unit_id (no duplicates).
/// @param {id}     unit_id
/// @param {string} status_name
function scr_battle_apply_status(unit_id, status_name) {
    if (!scr_battle_has_status(unit_id, status_name)) {
        array_push(unit_id.status_effects, status_name);
    }
}

/// Removes a named status effect from unit_id.
/// @param {id}     unit_id
/// @param {string} status_name
function scr_battle_remove_status(unit_id, status_name) {
    var _new = [];
    var _effects = unit_id.status_effects;
    for (var _i = 0; _i < array_length(_effects); _i++) {
        if (_effects[_i] != status_name) array_push(_new, _effects[_i]);
    }
    unit_id.status_effects = _new;
}


// =============================================================================
// FORGOTTEN TURN MECHANIC  (Limbo effect on units)
// =============================================================================

/// Applies the "forgotten" status to unit_id.
/// The unit's turn will be skipped by obj_battle_manager.
/// @param {id} unit_id
function scr_battle_apply_forgotten(unit_id) {
    scr_battle_apply_status(unit_id, "forgotten");
    scr_world_event_log(unit_id.unit_name + " forgot their purpose. Their turn is lost.");
}

/// Resolves a Hollow unit's forget-chance roll for this turn.
/// Chance = HOLLOW_BASE_FORGET_CHANCE + HOLLOW_FORGET_SCALE * (corruption/100).
/// If the roll succeeds, applies "forgotten" and returns true.
/// @param {id}   unit_id      The Hollow unit
/// @param {real} corruption   Current battle_corruption (0-100)
/// @returns {bool}  true if the unit became Forgotten this turn
function scr_battle_hollow_forget_roll(unit_id, corruption) {
    var _chance = HOLLOW_BASE_FORGET_CHANCE
                + HOLLOW_FORGET_SCALE * (corruption / 100);
    _chance = clamp(_chance, 0, 0.9);   // max 90%

    if (random(1) < _chance) {
        scr_battle_apply_forgotten(unit_id);
        return true;
    }
    return false;
}


// =============================================================================
// SANITY 0% BRANCH  (stub — API-controlled Benedetto)
// =============================================================================

/// Called when Benedetto's sanity reaches 0 during battle.
/// Stub: he freezes and cannot act. Real API control wired later.
/// @param {id} benedetto_id
function scr_battle_sanity_zero(benedetto_id) {
    // TODO: API-controlled Benedetto — wire when Anthropic key available Thursday
    // Claude will receive battle state and choose Benedetto's action against his party.
    // For now: freeze him and surface a message.
    scr_battle_apply_status(benedetto_id, "frozen");
    benedetto_id.sanity_zero_message = true;
    scr_world_event_log("He could no longer find his way back.");
    show_debug_message("[Sanity 0] Benedetto frozen. API stub — wire when key available.");
}


// =============================================================================
// DANTE'S INTERVENTION
// =============================================================================

/// Dante attempts to pull a Forgotten unit back to themselves.
/// Success chance: 80% base, reduced by 0.5% per corruption point.
/// On success: removes "forgotten", restores 5 sanity, logs event.
/// On failure: logs event, costs Dante his action regardless.
/// @param {id}   target_id    The unit to restore
/// @param {real} corruption   Current battle_corruption (0-100)
/// @returns {bool}  true if intervention succeeded
function scr_battle_dante_intervene(target_id, corruption) {
    var _chance = max(0.10, 0.80 - (corruption / 100) * 0.50);

    if (random(1) < _chance) {
        scr_battle_remove_status(target_id, "forgotten");
        scr_battle_remove_status(target_id, "frozen");
        global.sanity = min(global.sanity + 5, 100);
        scr_world_event_log(
            "Dante called out. His voice crossed the corruption. "
            + target_id.unit_name + " remembers."
        );
        return true;
    }

    scr_world_event_log(
        "Dante's voice could not reach across the grey. "
        + target_id.unit_name + " is still lost."
    );
    return false;
}


// =============================================================================
// MARCO'S NAME SNAP-BACK
// =============================================================================

/// Calling Marco's name has a chance to snap him back to himself.
/// Chance scales with his current recognition level (0-100).
/// On success: removes "forgotten"/"frozen", partially restores recognition.
/// @param {id} marco_id   The Marco unit instance
/// @returns {bool}  true if the snap-back worked
function scr_battle_marco_name_snap(marco_id) {
    // Recognition is stored on obj_npc_marco (and mirrored in global).
    // When Marco appears as a battle unit, this variable is copied to the unit.
    var _recognition = variable_instance_get(marco_id, "marco_recognition");
    if (_recognition == undefined) _recognition = 50;

    var _chance = clamp(_recognition / 100 * 0.70, 0.05, 0.70);

    if (random(1) < _chance) {
        scr_battle_remove_status(marco_id, "forgotten");
        scr_battle_remove_status(marco_id, "frozen");
        // Partial recognition restored
        if (variable_instance_exists(marco_id, "marco_recognition")) {
            marco_id.marco_recognition = min(marco_id.marco_recognition + 10, 100);
        }
        scr_world_event_log(
            "\"Marco.\" He blinks. For a moment, he is Marco again."
        );
        return true;
    }

    scr_world_event_log("The name doesn't reach him. He is too far in.");
    return false;
}


// =============================================================================
// BATTLE INITIALISATION
// =============================================================================

/// Initialises all battle globals. Called from obj_battle_manager Create.
/// @param {real} corruption_override   Pass -1 to derive from global Limbo corruption.
function scr_battle_globals_init(corruption_override) {
    global.battle_active      = true;
    global.battle_corruption  = clamp(
                                 (corruption_override >= 0)
                                     ? corruption_override
                                     : global.circle_corruption[CIRCLE_LIMBO],
                                 0, 100
                                 );
    global.battle_turn        = 0;
    global.battle_round       = 0;   // incremented to 1 by first scr_battle_start_round call
    global.battle_result      = "";   // "victory" | "defeat" | ""
    global.input_locked       = false;
    global.false_shimmer_active = false;   // clear any leftover Focus false-reveal
    // Focus charges: set once per battle from the sanity class, never refreshed between turns.
    global.focus_charges = scr_focus_class(global.sanity).charges;
}

/// Triggers a battle transition from the exploration room.
/// Stores the enemy count globally so obj_battle_manager reads it on load.
/// @param {real} enemy_count   Number of Hollow enemies to spawn (clamped 1-5)
function scr_battle_trigger(enemy_count) {
    global.battle_enemy_count = clamp(enemy_count, 1, 5);
    global.battle_corruption  = clamp(global.circle_corruption[CIRCLE_LIMBO], 0, 100);
    room_goto(room_battle);
}

/// Called when Benedetto flees battle. Applies cowardice penalty and returns
/// to Florence. Fleeing always costs something — that's the design.
function scr_battle_flee() {
    // ── Penalty ───────────────────────────────────────────────────────────────
    global.circle_corruption[CIRCLE_LIMBO] = clamp(
        global.circle_corruption[CIRCLE_LIMBO] + 3, 0, 100
    );
    global.sanity = max(global.sanity - 5, 1);   // never below 1 in battle

    // ── World state log ───────────────────────────────────────────────────────
    scr_world_event_log(
        "Benedetto fled — Day " + string(global.day_count) + ". Cowardice."
    );
    scr_battle_add_log("Fled. Corruption rises. The city remembers.");

    // ── Save so the flee is permanent ─────────────────────────────────────────
    scr_save_world_state();

    // ── Return to Florence ────────────────────────────────────────────────────
    scr_battle_globals_cleanup();
    room_goto(Room1);
}

/// Cleans up battle globals on exit. Called when battle room transitions away.
function scr_battle_globals_cleanup() {
    global.battle_active     = false;
    global.battle_corruption = 0;
    global.battle_result     = "";
    global.input_locked      = false;
}


// =============================================================================
// TURN MANAGEMENT  (called from obj_battle_manager)
// =============================================================================

/// Appends a message to obj_battle_manager's combat log.
/// @param {string} msg
function scr_battle_add_log(msg) {
    with (obj_battle_manager) {
        array_insert(combat_log, 0, msg);
        if (array_length(combat_log) > combat_log_capacity) {
            array_delete(combat_log, combat_log_capacity, 1);
        }
    }
}

/// Starts a new round: resets AP for all living units, applies Hollow
/// forget-chance rolls, then sets the phase to the first unit's turn.
function scr_battle_start_round() {
    with (obj_battle_manager) {
        global.battle_round++;
        scr_battle_add_log("--- Round " + string(global.battle_round) + " ---");

        // Passive sanity drain — skip Round 1 so entry sanity carries over cleanly
        if (global.battle_round > 1 && instance_exists(obj_unit_benedetto)) {
            global.sanity = max(1, global.sanity - 1);
            scr_battle_add_log("The grey presses closer. Sanity -1.");
        }

        // Reset AP and clear round-scoped flags on all units
        with (obj_unit_base) {
            if (hp > 0) {
                ap        = max_ap;
                turn_done = false;
                // Hollow enemies roll for Forgotten each round
                if (variable_instance_exists(id, "is_hollow") && is_hollow) {
                    scr_battle_hollow_forget_roll(id, global.battle_corruption);
                }
            }
        }

        // Start with the first unit
        other.active_unit_idx = 0;
        scr_battle_activate_unit(other.turn_order, other.active_unit_idx);
    }
}

/// Activates the unit at turn_order[idx], setting the correct battle phase.
/// @param {array} turn_order
/// @param {real}  idx
function scr_battle_activate_unit(turn_order, idx) {
    with (obj_battle_manager) {
        if (array_length(turn_order) == 0) exit;
        if (idx >= array_length(turn_order)) {
            // End of round — start next
            scr_battle_start_round();
            exit;
        }

        var _uid = turn_order[idx];
        if (!instance_exists(_uid) || _uid.hp <= 0) {
            // Skip dead units
            other.active_unit_idx++;
            scr_battle_activate_unit(turn_order, other.active_unit_idx);
            exit;
        }

        // Check Forgotten status — skip turn
        if (scr_battle_has_status(_uid, "forgotten")) {
            scr_battle_remove_status(_uid, "forgotten");
            scr_battle_add_log(_uid.unit_name + " is lost. Their turn passes.");
            other.active_unit_idx++;
            scr_battle_activate_unit(turn_order, other.active_unit_idx);
            exit;
        }

        // Check Frozen (sanity 0 stub) — skip turn
        if (scr_battle_has_status(_uid, "frozen")) {
            scr_battle_add_log(_uid.unit_name + " cannot find their way back.");
            other.active_unit_idx++;
            scr_battle_activate_unit(turn_order, other.active_unit_idx);
            exit;
        }

        // Activate the unit
        _uid.fsm.change("acting");
        _uid.is_active_turn = true;
        global.battle_turn++;

        if (_uid.team == 0) {
            other.battle_phase = "player_turn";
            scr_battle_add_log(_uid.unit_name + " — your move.");
        } else {
            other.battle_phase = "enemy_turn";
        }
    }
}

/// Advances to the next unit in turn_order.
/// Called by active unit (obj_unit_benedetto) when its turn ends,
/// and by obj_battle_manager Step for enemies.
function scr_battle_advance_turn() {
    with (obj_battle_manager) {
        // Deactivate current unit
        if (array_length(turn_order) > 0) {
            var _prev = turn_order[active_unit_idx];
            if (instance_exists(_prev)) {
                _prev.fsm.change("waiting");
                _prev.is_active_turn = false;
                _prev.turn_done      = false;
            }
        }

        active_unit_idx++;
        scr_battle_activate_unit(turn_order, active_unit_idx);
    }
}

/// Processes a single enemy turn (stub — enemy stands still for now).
/// Immediately ends the enemy's turn and advances.
function scr_battle_process_enemy_turn() {
    with (obj_battle_manager) {
        if (array_length(turn_order) == 0) exit;
        var _uid = turn_order[active_unit_idx];
        if (!instance_exists(_uid)) { scr_battle_advance_turn(); exit; }

        // Hollow forget roll was done at start of round.
        // Stub AI: enemy does nothing, turn passes.
        scr_battle_add_log(_uid.unit_name + " stirs. Then is still.");
        scr_battle_advance_turn();
    }
}
