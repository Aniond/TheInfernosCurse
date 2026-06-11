---
name: ui-theme
description: The game UI theme standard for The Inferno's Curse — four corruption-reactive palettes (Clean/Troubled/Corrupted/Forgotten) with 60-frame lerp transitions. Never hardcode UI colors; always use scr_ui_theme_get(COLOR_KEY). Use whenever drawing or modifying any in-game UI element.
---

# Game UI Theme — The Inferno's Curse

## Purpose
Governs visual style of ALL in-game UI elements.
Theme shifts automatically with corruption level.
Never hardcode UI colors — always use scr_ui_theme_get()

## The Four Themes

Theme 1 — Florentine Clean (0-49%):
BACKGROUND:    #2C1810
PARCHMENT:     #F4E4C1
TEXT_PRIMARY:  #1A0F00
TEXT_SECONDARY:#5C3D1E
ACCENT:        #C9A227
HIGHLIGHT:     #8B1A1A
BORDER:        #8B6914
CANDLE_GLOW:   #FF9B3D
Mood: Grand, sacred, beautiful.

Theme 2 — Florentine Troubled (50-74%):
BACKGROUND:    #1E1008
PARCHMENT:     #D4C4A1
TEXT_PRIMARY:  #0F0800
TEXT_SECONDARY:#3C2D0E
ACCENT:        #A08217
HIGHLIGHT:     #6B0A0A
BORDER:        #6B5004
CANDLE_GLOW:   #CC7B2D
Mood: Something is wrong. Subtle.

Theme 3 — Florentine Corrupted (75-99%):
BACKGROUND:    #0F0804
PARCHMENT:     #A49471
TEXT_PRIMARY:  #E8D4B0
TEXT_SECONDARY:#8B7355
ACCENT:        #506B14
HIGHLIGHT:     #3B0505
BORDER:        #3B2D04
CANDLE_GLOW:   #8B5B1D
Mood: Clearly disturbing. Wrong colors.

Theme 4 — The Forgotten (100%):
BACKGROUND:    #050402
PARCHMENT:     #1A1810
TEXT_PRIMARY:  #4A3D2A
TEXT_SECONDARY:#2A1F10
ACCENT:        #1A4A0A
HIGHLIGHT:     #1A0202
BORDER:        #0F0D08
CANDLE_GLOW:   #1A4A0A
Mood: The city is swallowed.

## Transition
Lerp colors over 60 frames
when corruption crosses each threshold.
No hard cuts.

## UI Elements
obj_dialogue_box
obj_journal
obj_save_indicator
Entry banners
HUD HP/MP bars
Character sheet
Menu screens

## Rule
Never hardcode UI colors.
Always use scr_ui_theme_get(COLOR_KEY).
