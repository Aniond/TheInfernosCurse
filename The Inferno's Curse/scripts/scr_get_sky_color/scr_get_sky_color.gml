/// @description Returns the current sky colour based on time of day and Limbo corruption.
///
/// Time periods (global.time_of_day, 0-24 scale):
///   Dawn   5.0 – 7.0  →  warm orange/gold
///   Day    7.0 – 17.0 →  clear blue
///   Dusk  17.0 – 19.0 →  purple/orange
///   Night 19.0 –  5.0 →  deep dark blue
///
/// Corruption effect (global.circle_corruption[CIRCLE_LIMBO]):
///   As Limbo corruption rises toward 100, all colours desaturate toward a
///   grey/ash tone. At 100+ (hyper-corruption), the sky is always ash regardless
///   of time — the Curse has consumed the light.

function scr_get_sky_color() {

    var _tod     = global.time_of_day;
    var _corrupt = global.circle_corruption[CIRCLE_LIMBO]; // index 0

    // ── Base colour for the current time period ───────────────────────────────
    var _r, _g, _b;

    if (_tod >= 5 && _tod < 7) {
        // Dawn — warm orange/gold as the cursed sun struggles up
        _r = 255; _g = 180; _b = 100;

    } else if (_tod >= 7 && _tod < 17) {
        // Day — pale blue; already muted compared to a healthy world
        _r = 100; _g = 160; _b = 255;

    } else if (_tod >= 17 && _tod < 19) {
        // Dusk — bruised purple/orange, the sky reflecting the Curse below
        _r = 180; _g = 80; _b = 120;

    } else {
        // Night (19:00-05:00) — deep dark blue, almost void-like
        _r = 10; _g = 10; _b = 40;
    }

    // ── Corruption desaturation ───────────────────────────────────────────────
    // Limbo corruption drains colour from the sky. Values above 100 (hyper-
    // corruption) are clamped to 1.0 so the sky stays fully ashen once the
    // circle is consumed — the visual already shows total corruption.
    var _ratio = clamp(_corrupt / 100, 0, 1);

    // Ash target: dark warm grey — not pure grey, there's a faint soot warmth
    var _ash_r = 50;
    var _ash_g = 45;
    var _ash_b = 45;

    // Linear interpolation from the base colour toward ash
    _r = lerp(_r, _ash_r, _ratio);
    _g = lerp(_g, _ash_g, _ratio);
    _b = lerp(_b, _ash_b, _ratio);

    return make_color_rgb(round(_r), round(_g), round(_b));
}
