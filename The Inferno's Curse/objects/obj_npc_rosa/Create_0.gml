// =============================================================================
// obj_npc_rosa — Create
// =============================================================================
// Rosa the barmaid behind the inn counter. Walk into range → she greets you with a
// line from the NPC system (scr_npc_get_response, id "barmaid"); her mood icon floats
// above her head from her emotion_state. Non-blocking (no menu) so it never fights
// the innkeeper's rest menu beside her.
npc_id           = "barmaid";
proximity_radius = 120;    // reaches across the bar counter (80 won't — counter is ~2 cells deep)
greeted          = false;
say_text         = "";
say_timer        = 0;

npc_data = scr_npc_get(npc_id);
event_inherited();
npc_memory_corruption = 0;

// Division of roles: Rosa handles drinks/food/conversation ONLY (rooms are Aldo's).
// E opens her bar menu (Draw_64); off-shift (outside 14-22) the counter is empty
// and a small "Back later." sign is drawn in her place (on_shift, Draw_0).
menu_open = false;
menu_sel  = 0;       // 0 wine · 1 stew · 2 just talk · 3 nothing
msg_text  = "";
msg_timer = 0;
on_shift  = true;


// Relationship wiring: every order/chat is LOGGED (she remembers), but the
// relationship delta only applies the FIRST time each game day — grind-proof.
rel_day_logged = -1;

// FIX 2 — debug: confirm emotion_state loaded from npc_data.json on room entry,
// and whether it maps to an icon. (Output window only — costs nothing in-game.)
var _rd  = scr_npc_get(npc_id);
var _spr = is_undefined(_rd) ? noone : scr_npc_emotion_sprite(_rd.emotion_state);
show_debug_message("[npc] Rosa/" + npc_id + " inn-entry: emotion=" +
    (is_undefined(_rd) ? "<NO DATA>" : _rd.emotion_state) +
    " score=" + (is_undefined(_rd) ? "?" : string(_rd.relationship_score)) +
    " icon=" + (_spr == noone ? "none (neutral has no icon by design)" : sprite_get_name(_spr)));
