if (keyboard_check_pressed(ord("J"))) {
    if (!is_open) {
        scr_journal_open();
    } else {
        scr_journal_close();
    }
}

if (is_open) {
    // Fade cover from 1.0 → 0.3 over 60 steps on open
    if (codex_cover_alpha > 0.3) {
        codex_cover_alpha = max(0.3, codex_cover_alpha - (0.7 / 60));
    }

    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        current_page = max(0, current_page - 1);
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        current_page = min(total_pages - 1, current_page + 1);
    }
    if (keyboard_check_pressed(vk_escape)) {
        scr_journal_close();
    }
}
