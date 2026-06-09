// =============================================================================
// obj_npc_innkeeper — Create
// =============================================================================
// The innkeeper behind the bar. Walk within proximity_radius (80px) and the rest
// menu opens; the offered room is keyed to global.guild_reputation, paid in
// global.player_gold (both inited in obj_game_manager). A room = full HP rest +
// corruption relief scaled by the tier.
proximity_radius = 130;   // reaches across the bar counter to the player on the patron side
player_near      = false;
menu_open        = false;
menu_sel         = 0;       // 0 = take the room · 1 = maybe later
greeted          = false;   // open once per approach
msg_text         = "";
msg_timer        = 0;

// Relationship wiring: every purchase is LOGGED (he remembers), but the
// relationship delta only applies the FIRST time each game day — grind-proof.
rel_day_logged   = -1;

// FIX 2 — debug: confirm emotion_state loaded from npc_data.json on room entry,
// and whether it maps to an icon. (Output window only — costs nothing in-game.)
var _id  = scr_npc_get("innkeeper");
var _spr = is_undefined(_id) ? noone : scr_npc_emotion_sprite(_id.emotion_state);
show_debug_message("[npc] Aldo/innkeeper inn-entry: emotion=" +
    (is_undefined(_id) ? "<NO DATA>" : _id.emotion_state) +
    " score=" + (is_undefined(_id) ? "?" : string(_id.relationship_score)) +
    " icon=" + (_spr == noone ? "none (neutral has no icon by design)" : sprite_get_name(_spr)));
