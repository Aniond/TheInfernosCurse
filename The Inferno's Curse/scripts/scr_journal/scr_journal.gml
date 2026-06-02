function scr_journal_open() {
    with (obj_journal) {
        is_open     = true;
        total_pages = ds_list_size(journal_entries);
        if (total_pages > 0) {
            current_page = total_pages - 1;
        }
    }
    global.input_locked = true;
}

function scr_journal_close() {
    with (obj_journal) {
        is_open = false;
    }
    global.input_locked = false;
}
