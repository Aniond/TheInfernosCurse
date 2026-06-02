if (keyboard_check_pressed(ord("J"))) {
    if (!is_open) {
        scr_journal_open();
    } else {
        scr_journal_close();
    }
}

if (is_open) {
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
