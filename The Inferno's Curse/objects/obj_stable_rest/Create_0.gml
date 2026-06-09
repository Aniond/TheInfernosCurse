// =============================================================================
// obj_stable_rest — Create
// =============================================================================
// Invisible rest trigger over the sleeping area (bottom-right straw pallet).
// Press E within range:
//   global.merchant_guild <= 0  → allowed: a rough night in the straw — full HP,
//                                 day skips to 06:00, corruption +2% (the straw
//                                 of this place is not clean of the curse)
//   global.merchant_guild >  0  → redirected: a man with guild standing sleeps
//                                 at the Locanda della Rosa Camuna, not in straw
interact_range = 96;
player_near    = false;
msg_text       = "";
msg_timer      = 0;
