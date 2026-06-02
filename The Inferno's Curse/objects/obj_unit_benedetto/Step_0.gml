// =============================================================================
// obj_unit_benedetto — Step
// Player input for grid movement, focus (shimmer reveal), and end-turn.
// All input gates on fsm state "acting" so input only works on this unit's turn.
// =============================================================================

event_inherited();   // updates world pos, checks death

// ── Only act on our turn ──────────────────────────────────────────────────────
if (!fsm.state_is("acting")) exit;

// ── Sanity 0 — stub: freeze and display message ───────────────────────────────
if (global.sanity <= 0) {
    if (!scr_battle_has_status(id, "frozen")) {
        scr_battle_sanity_zero(id);
        turn_done = true;   // surrender turn
    }
    exit;
}

// ── Grid movement — WASD, one cell per keypress, costs 1 AP ──────────────────
var _moved = false;
var _dx    = keyboard_check_pressed(ord("D")) - keyboard_check_pressed(ord("A"));
var _dy    = keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));

// Diagonal not allowed — prefer horizontal
if (_dx != 0 && _dy != 0) _dy = 0;

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

// ── End turn — Z or Enter ─────────────────────────────────────────────────────
if (keyboard_check_pressed(ord("Z")) || keyboard_check_pressed(vk_enter)) {
    turn_done = true;
}

// ── AP exhausted — auto end turn ─────────────────────────────────────────────
if (ap <= 0) {
    turn_done = true;
}
