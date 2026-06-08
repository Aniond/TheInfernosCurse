// =============================================================================
// obj_inn_candle — Create
// =============================================================================
// A table candle. It burns LIT until Limbo corruption passes this candle's own
// threshold, then snuffs to spr_inn_candle_unlit. Thresholds are spread 50-88% so
// across the room the candles go cold ONE BY ONE as corruption climbs.
cold_at = 50 + irandom(38);   // this candle dies somewhere between 50% and 88%
flick   = random(6.28);       // per-candle flame-glow flicker phase
depth   = 90;                 // draw IN FRONT of the table (depth 100) so it shows on top
