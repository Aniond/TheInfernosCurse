// =============================================================================
// obj_dialogue_box — Create Event
// =============================================================================
// The window into every soul Benedetto meets.
// One persistent instance lives on the Instances layer; scr_open_dialogue()
// and scr_close_dialogue() drive it rather than create/destroy it.
// =============================================================================

// ── Core text state ───────────────────────────────────────────────────────────
dialogue_text   = "";   // full text to be revealed (after corruption filtering)
display_text    = "";   // currently-visible portion, grows via typewriter
npc_name_display = "";  // speaker name shown in the header

// ── Typewriter ────────────────────────────────────────────────────────────────
char_index      = 0;    // how many characters have been revealed so far
typewriter_timer = 0;   // steps since last character reveal
typewriter_speed = 2;   // steps between character reveals (lower = faster)

// ── State flags ───────────────────────────────────────────────────────────────
is_complete  = false;   // true when all characters have been revealed
is_loading   = false;   // true while waiting for an async API response
is_active    = false;   // master gate — nothing draws or updates when false

// ── Context ───────────────────────────────────────────────────────────────────
source_npc_id   = noone; // instance ID of the NPC speaking; used for cleanup
corruption_level = 0;    // copy of source NPC's npc_memory_corruption (0-100)

// ── Interactive Input ─────────────────────────────────────────────────────────
suggested_prompts = [];  // array of 4 strings from the AI
typed_input      = "";   // keyboard_string buffer
input_active     = false; // true when player is allowed to type/click
selected_prompt  = -1;   // hover index for mouse

// ── Loading animation ─────────────────────────────────────────────────────────
dot_string = ".";       // animated "..." string shown while waiting
dot_timer  = 0;         // steps since last dot cycle update
loading_timer = 0;      // steps spent in the loading state (safety timeout)

// ── Autosize ────────────────────────────────────────────────────────────────
bar_height_current = 150;  // current (lerped) bar height; target computed in Draw

// ── Legacy aliases (kept so existing internal code doesn't break) ─────────────
// These shadow the old variable names in case any call site we missed
// still writes to them — they are NOT the canonical vars above.
full_text   = "";       // alias for dialogue_text (old name)
npc_name    = "";       // alias for npc_name_display (old name)
char_timer  = 0;        // alias for typewriter_timer (old name)
char_delay  = 2;        // alias for typewriter_speed (old name)
finished    = false;    // alias for is_complete (old name)
text_loaded = false;    // internal flag (was polling; now set by scr_open_dialogue)
