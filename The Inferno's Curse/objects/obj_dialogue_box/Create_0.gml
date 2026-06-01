// ── Dialogue Box: Create ─────────────────────────────────────────────────────

full_text    = "";    // complete dialogue line to reveal
display_text = "";    // currently-visible portion (grows via typewriter effect)
npc_name     = "";    // speaker's display name

char_index  = 0;
char_timer  = 0;
char_delay  = 2;      // steps between each character reveal
finished    = false;  // true when the full line has been revealed
text_loaded = false;  // true once we've pulled text from the active NPC
                      // stays false until last_response is non-empty
                      // (allows real API responses to arrive asynchronously)
