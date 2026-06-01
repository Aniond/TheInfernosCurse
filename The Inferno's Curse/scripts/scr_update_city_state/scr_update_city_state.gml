/// @description Updates city-wide state based on current corruption levels,
/// sin affinities, and world events.
///
/// Called by scr_new_day_corruption_update() at each day rollover.
///
/// STUB — implement when the city and NPC systems are built out.
/// Future responsibilities:
///   - Adjust NPC disposition thresholds based on local circle corruption
///   - Open or close districts as corruption spreads
///   - Trigger world events and gossip propagation between NPCs
///   - Update available quests and narrative branches
///   - Feed a city-state struct to the Claude API for richer NPC context

function scr_update_city_state() {

    // Diagnostic output so day-cycle testing is visible in the output window
    show_debug_message(
        "[City] State update — Day " + string(global.day_count) +
        " | Limbo: " + string(global.circle_corruption[CIRCLE_LIMBO]) +
        " | Circle: " + global.circle_names[global.current_circle]
    );

    // TODO: implement district lockdown when CIRCLE_LIMBO >= 75
    // TODO: trigger "The Fog Thickens" world event when CIRCLE_LIMBO >= 100
    // TODO: NPC mass disposition shift when any circle >= 150
}
