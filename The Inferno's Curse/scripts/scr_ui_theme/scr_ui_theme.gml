// =============================================================================
// scr_ui_theme — corruption-reactive UI palette
// =============================================================================
// Four themes keyed to Limbo corruption (the single axis):
//   0-49 Florentine Clean · 50-74 Troubled · 75-99 Corrupted · 100 The Forgotten
// When corruption crosses a threshold the active palette LERPS to the new one
// over UI_THEME_LERP_FRAMES — no hard cuts.
//
// RULE (CLAUDE.md + .claude/skills/ui-theme): UI code never hardcodes colors.
// Draw events read scr_ui_theme_get(UI_*); obj_game_manager Step calls
// scr_ui_theme_apply() once per frame to advance the cached blend.
// =============================================================================

// ── Color keys (indices into the palette arrays) ──────────────────────────────
#macro UI_BACKGROUND        0
#macro UI_PARCHMENT         1
#macro UI_TEXT_PRIMARY      2
#macro UI_TEXT_SECONDARY    3
#macro UI_ACCENT            4
#macro UI_HIGHLIGHT         5
#macro UI_BORDER            6
#macro UI_CANDLE_GLOW       7
#macro UI_THEME_KEY_COUNT   8

#macro UI_THEME_LERP_FRAMES 60   // 1 second @ 60fps between themes

/// The palette for one theme tier (0-3). Colors from .claude/skills/ui-theme.
function scr_ui_theme_palette(_tier) {
    switch (_tier) {
        case 0: return [   // Florentine Clean (0-49%)
            make_color_rgb(0x2C, 0x18, 0x10),   // BACKGROUND  #2C1810
            make_color_rgb(0xF4, 0xE4, 0xC1),   // PARCHMENT   #F4E4C1
            make_color_rgb(0x1A, 0x0F, 0x00),   // TEXT_PRI    #1A0F00
            make_color_rgb(0x5C, 0x3D, 0x1E),   // TEXT_SEC    #5C3D1E
            make_color_rgb(0xC9, 0xA2, 0x27),   // ACCENT      #C9A227
            make_color_rgb(0x8B, 0x1A, 0x1A),   // HIGHLIGHT   #8B1A1A
            make_color_rgb(0x8B, 0x69, 0x14),   // BORDER      #8B6914
            make_color_rgb(0xFF, 0x9B, 0x3D),   // CANDLE_GLOW #FF9B3D
        ];
        case 1: return [   // Florentine Troubled (50-74%)
            make_color_rgb(0x1E, 0x10, 0x08),   // #1E1008
            make_color_rgb(0xD4, 0xC4, 0xA1),   // #D4C4A1
            make_color_rgb(0x0F, 0x08, 0x00),   // #0F0800
            make_color_rgb(0x3C, 0x2D, 0x0E),   // #3C2D0E
            make_color_rgb(0xA0, 0x82, 0x17),   // #A08217
            make_color_rgb(0x6B, 0x0A, 0x0A),   // #6B0A0A
            make_color_rgb(0x6B, 0x50, 0x04),   // #6B5004
            make_color_rgb(0xCC, 0x7B, 0x2D),   // #CC7B2D
        ];
        case 2: return [   // Florentine Corrupted (75-99%)
            make_color_rgb(0x0F, 0x08, 0x04),   // #0F0804
            make_color_rgb(0xA4, 0x94, 0x71),   // #A49471
            make_color_rgb(0xE8, 0xD4, 0xB0),   // #E8D4B0
            make_color_rgb(0x8B, 0x73, 0x55),   // #8B7355
            make_color_rgb(0x50, 0x6B, 0x14),   // #506B14
            make_color_rgb(0x3B, 0x05, 0x05),   // #3B0505
            make_color_rgb(0x3B, 0x2D, 0x04),   // #3B2D04
            make_color_rgb(0x8B, 0x5B, 0x1D),   // #8B5B1D
        ];
        default: return [  // The Forgotten (100%)
            make_color_rgb(0x05, 0x04, 0x02),   // #050402
            make_color_rgb(0x1A, 0x18, 0x10),   // #1A1810
            make_color_rgb(0x4A, 0x3D, 0x2A),   // #4A3D2A
            make_color_rgb(0x2A, 0x1F, 0x10),   // #2A1F10
            make_color_rgb(0x1A, 0x4A, 0x0A),   // #1A4A0A
            make_color_rgb(0x1A, 0x02, 0x02),   // #1A0202
            make_color_rgb(0x0F, 0x0D, 0x08),   // #0F0D08
            make_color_rgb(0x1A, 0x4A, 0x0A),   // #1A4A0A
        ];
    }
}

/// Current theme tier (0-3) from Limbo corruption. Safe before globals exist.
function scr_ui_theme_tier() {
    if (!variable_global_exists("circle_corruption")) return 0;
    var _c = global.circle_corruption[CIRCLE_LIMBO];
    if (_c >= 100) return 3;
    if (_c >= 75)  return 2;
    if (_c >= 50)  return 1;
    return 0;
}

/// Advance the cached palette one frame. Called from obj_game_manager Step.
/// On a tier change the cache lerps from its CURRENT colors (mid-blend safe)
/// to the new palette over UI_THEME_LERP_FRAMES.
function scr_ui_theme_apply() {
    var _tier = scr_ui_theme_tier();

    // First run — snap straight to the active palette, no blend.
    if (!variable_global_exists("ui_theme_cache")) {
        global.ui_theme_cache  = scr_ui_theme_palette(_tier);
        global.ui_theme_tier   = _tier;
        global.ui_theme_from   = scr_ui_theme_palette(_tier);
        global.ui_theme_target = scr_ui_theme_palette(_tier);
        global.ui_theme_blend  = UI_THEME_LERP_FRAMES;   // fully arrived
        return;
    }

    // Threshold crossed — start a fresh 60-frame blend from wherever we are.
    if (_tier != global.ui_theme_tier) {
        global.ui_theme_tier   = _tier;
        global.ui_theme_from   = global.ui_theme_cache;  // current (possibly mid-blend)
        global.ui_theme_target = scr_ui_theme_palette(_tier);
        global.ui_theme_blend  = 0;
    }

    // Advance the blend and rebuild the cache.
    if (global.ui_theme_blend < UI_THEME_LERP_FRAMES) {
        global.ui_theme_blend += 1;
        var _t = global.ui_theme_blend / UI_THEME_LERP_FRAMES;
        var _cache = array_create(UI_THEME_KEY_COUNT);
        for (var _i = 0; _i < UI_THEME_KEY_COUNT; _i++) {
            _cache[_i] = merge_color(global.ui_theme_from[_i], global.ui_theme_target[_i], _t);
        }
        global.ui_theme_cache = _cache;
    }
}

/// THE accessor — every UI draw reads colors through this. Never hardcode.
/// @param {real} _key   UI_BACKGROUND .. UI_CANDLE_GLOW
function scr_ui_theme_get(_key) {
    if (!variable_global_exists("ui_theme_cache")) scr_ui_theme_apply();
    return global.ui_theme_cache[_key];
}
