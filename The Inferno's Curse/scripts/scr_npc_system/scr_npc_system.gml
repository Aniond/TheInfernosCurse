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
            barmaid:   { tier: 1, name: "Rosa",           location: "fiorentine_inn",     relationship_score: 0, emotion_state: "neutral", sin_awareness: 0, event_log: [] },
            innkeeper: { tier: 1, name: "Aldo",           location: "fiorentine_inn",     relationship_score: 0, emotion_state: "neutral", sin_awareness: 0, event_log: [] },
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
        } catch (_e) {
            global.npc_data = scr_npc_default_data();
        }
    } else {
        global.npc_data = scr_npc_default_data();
        scr_npc_save();
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

/// emotion_state → the floating mood-icon sprite shown above an NPC's head.
function scr_npc_emotion_sprite(_emotion) {
    switch (_emotion) {
        case "friendly": return spr_emotion_happy;
        case "warm":     return spr_emotion_happy;
        case "neutral":  return spr_emotion_neutral;
        case "cold":     return spr_emotion_suspicious;
        case "hostile":  return spr_emotion_angry;
    }
    return spr_emotion_neutral;
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
