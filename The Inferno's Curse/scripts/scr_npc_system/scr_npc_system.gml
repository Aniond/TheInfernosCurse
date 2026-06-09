// =============================================================================
// scr_npc_system — NPC behaviour + event tracking (MOCK AI mode)
// =============================================================================
// Tracks each NPC's relationship, emotion, sin-awareness and a per-NPC event log,
// persisted as npc_data.json in the save folder (working_directory). Corruption
// erodes NPC memory of Benedetto. Responses are MOCK for now; flip
// global.npc_mock_mode to false and implement scr_npc_ai_response() to go live —
// the live path already builds the full context (event_log + emotion_state).
//
//   scr_npc_system_init()                      — load/seed + set the mock flag
//   scr_npc_get(id)                            — the NPC's struct (or undefined)
//   scr_npc_log_event(id, behavior, outcome, delta) — log + update + erase + save
//   scr_npc_get_response(id, player_input)     — mock (or live) dialogue line
//   scr_npc_save() / scr_npc_load()            — JSON <-> save folder
//   scr_npc_sync_to_layouts()                  — see note (sandbox-blocked at runtime)
// =============================================================================

function scr_npc_data_path()    { return working_directory + "npc_data.json"; }
function scr_npc_current_day()  { return variable_global_exists("game_day") ? global.game_day : 0; }

/// Seed data — mirrors npc_data.json. Tier-2 stableboy has no sin_awareness in the
/// spec; we add it (0) for uniform access. Edit here = edit the default for a fresh save.
function scr_npc_default_data() {
    return {
        npcs: {
            // Division of roles (no crossover): Aldo = lodging ONLY, Rosa = bar ONLY.
            barmaid:   { tier: 1, name: "Rosa", role: "barmaid",   handles: ["drinks", "food", "conversation"], location: "locanda_rosa_camuna", relationship_score: 0, emotion_state: "neutral", sin_awareness: 0, event_log: [] },
            innkeeper: { tier: 1, name: "Aldo", role: "innkeeper", handles: ["lodging", "rooms", "keys"],       location: "locanda_rosa_camuna", relationship_score: 0, emotion_state: "neutral", sin_awareness: 0, event_log: [] },
            marco:     { tier: 1, name: "Marco",          location: "ponte_vecchio",      relationship_score: 0, emotion_state: "neutral", sin_awareness: 0, event_log: [] },
            priest:    { tier: 1, name: "Father Anselmo", location: "santa_lucia_church", relationship_score: 0, emotion_state: "neutral", sin_awareness: 0, event_log: [] },
            stableboy: { tier: 2, name: "Nico",           location: "fiorentine_stable",  relationship_score: 0, emotion_state: "neutral", sin_awareness: 0, event_log: [] },
        }
    };
}

/// Init once (call from obj_game_manager Create). Sets the mock flag + loads/seeds.
function scr_npc_system_init() {
    if (!variable_global_exists("npc_mock_mode")) global.npc_mock_mode = true;   // <- one line to go live
    scr_npc_load();
}

function scr_npc_load() {
    var _p = scr_npc_data_path();
    if (file_exists(_p)) {
        var _f = file_text_open_read(_p);
        var _s = "";
        while (!file_text_eof(_f)) { _s += file_text_read_string(_f); file_text_readln(_f); }
        file_text_close(_f);
        try {
            global.npc_data = json_parse(_s);
            if (!variable_struct_exists(global.npc_data, "npcs")) global.npc_data = scr_npc_default_data();
            scr_npc_backfill_fields();   // saves made before role/handles existed get them seeded
        } catch (_e) {
            global.npc_data = scr_npc_default_data();
        }
    } else {
        global.npc_data = scr_npc_default_data();
        scr_npc_save();
    }
}

/// Backfill struct fields added to the seed AFTER a save file was created (e.g. the
/// role/handles division) so an old npc_data.json never crashes new code. Missing
/// NPCs are added whole; existing NPCs only gain the missing fields.
function scr_npc_backfill_fields() {
    var _d     = scr_npc_default_data();
    var _names = struct_get_names(_d.npcs);
    for (var _i = 0; _i < array_length(_names); _i++) {
        var _k = _names[_i];
        if (!variable_struct_exists(global.npc_data.npcs, _k)) {
            global.npc_data.npcs[$ _k] = _d.npcs[$ _k];
            continue;
        }
        var _src = _d.npcs[$ _k], _dst = global.npc_data.npcs[$ _k];
        if (variable_struct_exists(_src, "role")    && !variable_struct_exists(_dst, "role"))    _dst.role    = _src.role;
        if (variable_struct_exists(_src, "handles") && !variable_struct_exists(_dst, "handles")) _dst.handles = _src.handles;
    }
}

function scr_npc_save() {
    if (!variable_global_exists("npc_data")) return;
    var _s = json_stringify(global.npc_data);
    var _f = file_text_open_write(scr_npc_data_path());   // save folder — sandbox-allowed
    file_text_write_string(_f, _s);
    file_text_close(_f);
}

/// The project layouts\ copy can NOT be written by the running game (file sandbox
/// blocks absolute project paths). The live data lives in the save folder; sync the
/// layouts\npc_data.json copy on COMMIT (outside the game). Kept as a hook so the
/// intent is explicit and the F8 path is one place.
function scr_npc_sync_to_layouts() {
    scr_npc_save();   // ensure the save-folder copy is current; layouts copy synced on commit
}

function scr_npc_get(_npc_id) {
    if (!variable_global_exists("npc_data")) scr_npc_system_init();
    if (variable_struct_exists(global.npc_data.npcs, _npc_id)) return global.npc_data.npcs[$ _npc_id];
    return undefined;
}

/// relationship_score → emotion_state (the behaviour-rules ladder).
function scr_npc_update_emotion(_npc_id) {
    var _npc = scr_npc_get(_npc_id);
    if (is_undefined(_npc)) return;
    var _r = _npc.relationship_score;
    if      (_r >= 50)  _npc.emotion_state = "friendly";
    else if (_r >= 20)  _npc.emotion_state = "warm";
    else if (_r <= -50) _npc.emotion_state = "hostile";
    else if (_r <= -20) _npc.emotion_state = "cold";
    else                _npc.emotion_state = "neutral";
}

/// Drift a score toward 0 by _amount (never overshooting past 0).
function scr_npc_drift(_score, _amount) {
    if (_score > 0) return max(0, _score - _amount);
    if (_score < 0) return min(0, _score + _amount);
    return 0;
}

/// Log an interaction: append the event, apply the delta, refresh emotion, run the
/// corruption memory-erasure pass, and persist. behavior = charming|rude|generous|
/// violent|neutral.
function scr_npc_log_event(_npc_id, _behavior, _outcome, _delta) {
    var _npc = scr_npc_get(_npc_id);
    if (is_undefined(_npc)) return;
    array_push(_npc.event_log, {
        type:               "interaction",
        player_behavior:    _behavior,
        outcome:            _outcome,
        relationship_delta: _delta,
        corruption_at_time: global.circle_corruption[CIRCLE_LIMBO],
        day:                scr_npc_current_day()
    });
    _npc.relationship_score += _delta;
    scr_npc_update_emotion(_npc_id);
    scr_npc_apply_corruption_erasure();
    scr_npc_save();
}

/// Corruption erodes NPC memory of Benedetto. Run on each interaction (and can be
/// called on a daily tick). 50%: forget events >5 days, drift 5. 75%: keep only the
/// last 2 events, drift 10. 100%: wipe everything — the NPC has no memory of him.
function scr_npc_apply_corruption_erasure() {
    if (!variable_global_exists("npc_data")) return;
    var _corr = global.circle_corruption[CIRCLE_LIMBO];
    if (_corr < 50) return;
    var _day   = scr_npc_current_day();
    var _names = struct_get_names(global.npc_data.npcs);

    for (var _i = 0; _i < array_length(_names); _i++) {
        var _id  = _names[_i];
        var _npc = global.npc_data.npcs[$ _id];

        if (_corr >= 100) {
            _npc.event_log          = [];
            _npc.relationship_score = 0;
            _npc.emotion_state      = "neutral";
            continue;
        }

        if (_corr >= 75) {
            var _log = _npc.event_log;
            var _n   = array_length(_log);
            if (_n > 2) _npc.event_log = [ _log[_n - 2], _log[_n - 1] ];   // keep last 2
            _npc.relationship_score = scr_npc_drift(_npc.relationship_score, 10);
            scr_npc_update_emotion(_id);
            continue;
        }

        // 50-74: drop events older than 5 days, drift 5
        var _kept = [];
        for (var _j = 0; _j < array_length(_npc.event_log); _j++) {
            var _ev = _npc.event_log[_j];
            if ((_day - _ev.day) <= 5) array_push(_kept, _ev);
        }
        _npc.event_log          = _kept;
        _npc.relationship_score = scr_npc_drift(_npc.relationship_score, 5);
        scr_npc_update_emotion(_id);
    }
}

// ── Dialogue ────────────────────────────────────────────────────────────────────
/// Public entry: mock line in mock mode, else the live AI path.
function scr_npc_get_response(_npc_id, _player_input) {
    if (variable_global_exists("npc_mock_mode") && !global.npc_mock_mode)
        return scr_npc_ai_response(_npc_id, _player_input);
    return scr_npc_mock_response(_npc_id, _player_input);
}

/// Mock responses keyed to emotion + corruption. Corruption overrides the emotional
/// flavour: as it climbs the NPC forgets Benedetto regardless of past relationship.
function scr_npc_mock_response(_npc_id, _player_input) {
    var _npc = scr_npc_get(_npc_id);
    if (is_undefined(_npc)) return "...";
    var _name = _npc.name;
    var _e    = _npc.emotion_state;
    var _corr = global.circle_corruption[CIRCLE_LIMBO];

    // Corruption erases their memory of him (the taint, not his madness).
    if (_corr >= 100) return _name + " stares blankly. \"I'll be with you in a moment, traveler.\"";
    if (_corr >= 75)  return _name + " looks up with no recognition. \"First time in Florence?\"";
    if (_corr >= 50)  return _name + " pauses, studying your face. \"...Have we met?\"";

    // Below 50% — flavoured by how they feel about you.
    switch (_e) {
        case "friendly": return _name + " smiles warmly. \"Welcome back. The usual?\"";
        case "warm":     return _name + " gives an easy nod. \"Good to see you again. What do you need?\"";
        case "neutral":  return _name + " nods. \"What can I get you?\"";
        case "cold":     return _name + " barely glances up. \"...What is it?\"";
        case "hostile":  return _name + " crosses their arms. \"What do you want.\"";
    }
    return _name + " says nothing.";
}

/// Build the context the live model receives — full event log + emotion + corruption.
function scr_npc_build_context(_npc_id, _player_input) {
    var _npc = scr_npc_get(_npc_id);
    return {
        npc_id:             _npc_id,
        name:               _npc.name,
        emotion_state:      _npc.emotion_state,
        relationship_score: _npc.relationship_score,
        sin_awareness:      variable_struct_exists(_npc, "sin_awareness") ? _npc.sin_awareness : 0,
        corruption:         global.circle_corruption[CIRCLE_LIMBO],
        day:                scr_npc_current_day(),
        event_log:          _npc.event_log,
        player_input:       _player_input
    };
}

/// emotion_state → the floating parchment mood-icon sprite. noone = no icon (neutral).
/// Map (per design): happy/warm/friendly→happy · cold/hostile→angry · afraid→afraid ·
/// suspicious→suspicious · terrified→terrified · neutral/unknown→none.
function scr_npc_emotion_sprite(_emotion) {
    switch (_emotion) {
        case "happy":
        case "friendly":
        case "warm":       return spr_emotion_happy;
        case "cold":
        case "hostile":    return spr_emotion_angry;
        case "afraid":     return spr_emotion_afraid;
        case "suspicious": return spr_emotion_suspicious;
        case "terrified":  return spr_emotion_terrified;
    }
    return noone;   // neutral / unknown → no icon shown
}

/// Force an emotion icon onto an NPC instance for 3 seconds (with a pop), regardless of
/// its relationship data. Call from any interaction when the emotion momentarily changes.
/// The corruption override (>=75) still takes precedence in scr_npc_emotion_draw.
function scr_npc_show_emotion(_inst, _emotion) {
    if (!instance_exists(_inst)) return;
    with (_inst) {
        emo_forced      = _emotion;
        emo_force_timer = 180;   // 3 s @ 60 fps
        emo_pop         = 12;    // trigger the pop animation
    }
}

// ── Interaction helpers (shared by all Tier-1 NPCs) ──────────────────────────────
/// FIX 1: true when obj_player is facing toward world point (_wx,_wy) within _tol
/// degrees. Counter NPCs use this so they only respond when the player actually
/// turns to face them — not when merely walking past. obj_player.facing_dir is in
/// GameMaker degrees (0=E, 90=N/up, 180=W, 270=S/down) and holds the last-faced
/// direction while idle.
function scr_npc_player_facing(_wx, _wy, _tol) {
    if (!instance_exists(obj_player)) return false;
    var _to = point_direction(obj_player.x, obj_player.y, _wx, _wy);
    return abs(angle_difference(obj_player.facing_dir, _to)) <= _tol;
}

/// Angle (deg) between the player's facing and the direction to world point (_wx,_wy).
/// Counter NPCs standing a cell apart have overlapping facing cones — each compares
/// its own delta against its neighbour's so one E press opens exactly ONE menu
/// (the NPC the player is most directly facing).
function scr_npc_facing_delta(_wx, _wy) {
    if (!instance_exists(obj_player)) return 999;
    return abs(angle_difference(obj_player.facing_dir, point_direction(obj_player.x, obj_player.y, _wx, _wy)));
}

/// FIX 3: draw a small pulsing "[E] Talk" prompt centred horizontally on _cx at
/// height _top_y, but ONLY while the player is within _radius px of the NPC body
/// (_npc_x,_npc_y). No-op out of range — so the prompt appears on approach and
/// disappears when Benedetto walks away. Shared by every Tier-1 NPC.
function scr_npc_talk_prompt(_cx, _npc_x, _npc_y, _top_y, _radius) {
    if (!instance_exists(obj_player)) return;
    if (point_distance(_npc_x, _npc_y, obj_player.x, obj_player.y) > _radius) return;
    var _pulse = 0.5 + 0.5 * sin(current_time * 0.006);
    var _old_h = draw_get_halign();
    draw_set_halign(fa_center);
    draw_set_color(c_black);
    draw_text(_cx + 1, _top_y + 1, "[E] Talk");
    draw_set_color(merge_color(make_color_rgb(236, 220, 180), c_white, _pulse));
    draw_text(_cx, _top_y, "[E] Talk");
    draw_set_color(c_white);
    draw_set_halign(_old_h);
}

/// Draw an NPC's floating emotion icon, centred at world (_cx,_cy). Call from the NPC's
/// Draw event. Self-contained: reads emotion from scr_npc_get(_npc_id), applies the
/// corruption override, pops on change, and fades after 3 s unless the state persists.
/// State is stored lazily on the calling instance — no Create wiring needed.
///   corruption >= 75  → all NPCs AFRAID    (persistent, overrides relationship)
///   corruption >= 100 → all NPCs TERRIFIED (persistent, flashing + panic jitter)
function scr_npc_emotion_draw(_inst, _npc_id, _cx, _cy) {
    with (_inst) {
        if (!variable_instance_exists(id, "emo_state")) {   // lazy init
            emo_state = "__init"; emo_timer = 0; emo_pop = 0;
            emo_forced = ""; emo_force_timer = 0;
        }

        var _corr = variable_global_exists("circle_corruption") ? global.circle_corruption[CIRCLE_LIMBO] : 0;
        var _persist = false;
        var _emotion;
        if (_corr >= 100)     { _emotion = "terrified"; _persist = true; }
        else if (_corr >= 75) { _emotion = "afraid";    _persist = true; }
        else if (emo_force_timer > 0) { _emotion = emo_forced; }
        else {
            var _npc = scr_npc_get(_npc_id);
            _emotion = is_undefined(_npc) ? "neutral" : _npc.emotion_state;
        }
        if (emo_force_timer > 0) emo_force_timer--;

        if (_emotion != emo_state) {   // changed → pop + (re)arm the 3 s display
            emo_state = _emotion;
            emo_pop   = 12;
            emo_timer = 180;
        }

        var _spr = scr_npc_emotion_sprite(_emotion);
        if (_spr == noone) { emo_timer = 0; exit; }   // neutral / unknown → no icon (by design)

        // FIX 2: any NON-neutral mood is shown PERSISTENTLY (it resolved to a sprite),
        // not just a 3 s flash on change. neutral already exited above, so it stays
        // icon-free. The pop on change (emo_pop) below still fires for the cue.
        _persist = true;

        var _vis = _persist || (emo_timer > 0);
        if (emo_timer > 0) emo_timer--;
        if (!_vis) exit;

        // pop overshoot then settle + gentle idle bob
        var _sc  = 0.85;
        if (emo_pop > 0) { _sc *= 1 + (emo_pop / 12) * 0.5; emo_pop--; }
        var _bob = sin(current_time / 320) * 2;

        // full-corruption terror: irregular flash + small panic jitter
        var _a = 1, _jit = 0;
        if (_corr >= 100) {
            if ((sin(current_time / 80) + sin(current_time / 53)) < -0.2) _a = 0.2;
            _jit = sin(current_time / 47) * 2 + sin(current_time / 23) * 1.5;
        }

        var _w = sprite_get_width(_spr)  * _sc;
        var _h = sprite_get_height(_spr) * _sc;
        draw_sprite_ext(_spr, 0, _cx - _w * 0.5 + _jit, _cy - _h * 0.5 + _bob, _sc, _sc, 0, c_white, _a);
    }
}

/// LIVE path (architecture ready). Build context, then — TODO — POST it to the Claude
/// API and return the reply. Until that one call is wired, fall back to the mock so
/// nothing breaks when global.npc_mock_mode is flipped early.
function scr_npc_ai_response(_npc_id, _player_input) {
    var _context = scr_npc_build_context(_npc_id, _player_input);
    // TODO (go live): send _context to Claude (see project_ai_dialogue_integration),
    //                 return the model's reply string. Mock fallback for now:
    return scr_npc_mock_response(_npc_id, _player_input);
}
