// =============================================================================
// obj_npc_stableboy — Create
// =============================================================================
// Pietro, the Fiorentine Stable's boy (~12, simple work clothes, apron). Tier 2
// NPC: horses + stable lodging. Walk up, face him, press E → two-option menu
// ("Stable my horse" / "Claim my horse") — both placeholder responses until the
// horse system lands in a future update. His demeanour tracks Limbo corruption:
// friendly < 50, suspicious 50-74, afraid 75-99, terrified at 100.
proximity_radius = 110;
player_near      = false;
menu_open        = false;
menu_sel         = 0;       // 0 = stable my horse · 1 = claim my horse · 2 = never mind
greeted          = false;   // open once per approach
msg_text         = "";
msg_timer        = 0;

// Relationship wiring: interactions are LOGGED (he remembers), but the
// relationship delta only applies the FIRST time each game day — grind-proof.
rel_day_logged   = -1;

// Debug: confirm emotion_state loaded from npc_data.json on room entry.
var _id  = scr_npc_get("stableboy");
var _spr = is_undefined(_id) ? noone : scr_npc_emotion_sprite(_id.emotion_state);
show_debug_message("[npc] Pietro/stableboy stable-entry: emotion=" +
    (is_undefined(_id) ? "<NO DATA>" : _id.emotion_state) +
    " score=" + (is_undefined(_id) ? "?" : string(_id.relationship_score)) +
    " icon=" + (_spr == noone ? "none (neutral has no icon by design)" : sprite_get_name(_spr)));
