// obj_mercato_exit — Create
// A walk-into-it room transition trigger. The spawner sets zone_w/zone_h (the
// trigger rectangle, anchored at this instance's top-left x,y), exit_target (the
// destination room's asset name), exit_label, and optionally pre_text. When
// pre_text is set, entering the zone shows a brief centred title card and freezes
// the player before loading; otherwise it transitions immediately. Invisible.
zone_w      = 64;
zone_h      = 64;
exit_target = "";
exit_label  = "exit";
pre_text    = "";       // "" = instant transition; set = brief title card first
zone_active = false;    // edge-trigger guard so it fires once per entry
trans_timer = 0;        // >0 while a gated transition is counting down (frames)
arrive_x    = undefined; // optional arrival position in the destination room — set
arrive_y    = undefined; // both to place the player; leave undefined to keep default
visible     = false;
