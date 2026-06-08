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
