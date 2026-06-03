// =============================================================================
// obj_unit_benedetto — Step
// Player input for grid movement, focus (shimmer reveal), and end-turn.
// All input gates on fsm state "acting" so input only works on this unit's turn.
// =============================================================================

event_inherited();   // updates world pos, checks death

// ── Only act on our turn ──────────────────────────────────────────────────────
if (!fsm.state_is("acting")) exit;

// ── Sanity warning at 10 ─────────────────────────────────────────────────────
if (global.sanity <= 10 && global.sanity > 0) {
    // Log once per turn (battle manager resets this flag each turn activation)
    if (!variable_instance_exists(id, "sanity_warned_this_turn") || !sanity_warned_this_turn) {
        scr_battle_add_log("Benedetto is losing himself...");
        sanity_warned_this_turn = true;
    }
}

// ── Sanity 0 — stub: force end turn only (no permanent freeze) ───────────────
// TODO: API-controlled Benedetto — wire when Anthropic key available Thursday
// Real behaviour: Claude receives battle state and acts against Benedetto's party.
// Temp: surrender the turn and reset sanity to 10 next round so combat continues.
if (global.sanity <= 0) {
    scr_battle_add_log("He could no longer find his way back.");
    global.sanity = 10;   // clings on — proper API takeover wires Thursday
    turn_done = true;
    exit;
}

// ── Grid movement — WASD, one cell per keypress, costs 1 AP ──────────────────
var _moved = false;
var _dx    = (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right))
           - (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left));
var _dy    = (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down))
           - (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up));

// Diagonal not allowed — prefer horizontal
if (_dx != 0 && _dy != 0) _dy = 0;

// Update facing from movement direction (persists after move so idle shows last direction)
if (_dx != 0 || _dy != 0) {
    if      (_dx > 0 && _dy == 0) unit_facing = "east";
    else if (_dx < 0 && _dy == 0) unit_facing = "west";
    else if (_dx == 0 && _dy < 0) unit_facing = "north";
    else if (_dx == 0 && _dy > 0) unit_facing = "south";
    else if (_dx > 0 && _dy < 0)  unit_facing = "north_east";
    else if (_dx < 0 && _dy < 0)  unit_facing = "north_west";
    else if (_dx > 0 && _dy > 0)  unit_facing = "south_east";
    else                           unit_facing = "south_west";
}

if ((_dx != 0 || _dy != 0) && ap > 0) {
    var _nx = grid_x + _dx;
    var _ny = grid_y + _dy;
    if (scr_battle_is_valid_cell(_nx, _ny)
     && !scr_battle_cell_occupied(_nx, _ny, id)) {
        grid_x = _nx;
        grid_y = _ny;
        ap--;
        _moved = true;
        // Check Limbo tile landing
        scr_battle_check_limbo_tile(id);
    }
}

// ── Focus — F key: reveal nearby Limbo shimmer at sanity cost ─────────────────
if (keyboard_check_pressed(ord("F"))) {
    // Signal all Limbo tiles within 2 Manhattan steps to show shimmer
    with (obj_limbo_tile) {
        var _dist = abs(grid_x - other.grid_x) + abs(grid_y - other.grid_y);
        if (_dist <= 2 && global.sanity > 0) {
            is_shimmer_visible = true;
            shimmer_timer      = 0;
            global.sanity      = max(0, global.sanity - LIMBO_SHIMMER_COST);
            scr_battle_add_log("Benedetto focused his sight. Sanity -" + string(LIMBO_SHIMMER_COST) + ".");
        }
    }
}

// ── End turn — Z or Enter only — AP exhaustion NEVER auto-advances ───────────
// Player must explicitly end their turn. This keeps them in control.
if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
    turn_done = true;
}
