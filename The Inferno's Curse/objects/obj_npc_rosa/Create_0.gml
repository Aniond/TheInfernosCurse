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
