module nuklear.nuklear_table;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              TABLE
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

nk_table* nk_create_table(nk_context* ctx)
{
    nk_page_element* elem = void;
    elem = nk_create_page_element(ctx);
    if (!elem) return 0;
    nk_zero_struct(*elem);
    return &elem.data.tbl;
}
void nk_free_table(nk_context* ctx, nk_table* tbl)
{
    nk_page_data* pd = nk_container_of!(nk_page_data, "tbl")(tbl);
    nk_page_element* pe = nk_container_of!(nk_page_element, "data")(pd);
    nk_free_page_element(ctx, pe);
}
void nk_push_table(nk_window* win, nk_table* tbl)
{
    if (!win.tables) {
        win.tables = tbl;
        tbl.next = 0;
        tbl.prev = 0;
        tbl.size = 0;
        win.table_count = 1;
        return;
    }
    win.tables.prev = tbl;
    tbl.next = win.tables;
    tbl.prev = 0;
    tbl.size = 0;
    win.tables = tbl;
    win.table_count++;
}
void nk_remove_table(nk_window* win, nk_table* tbl)
{
    if (win.tables == tbl)
        win.tables = tbl.next;
    if (tbl.next)
        tbl.next.prev = tbl.prev;
    if (tbl.prev)
        tbl.prev.next = tbl.next;
    tbl.next = 0;
    tbl.prev = 0;
}
nk_uint* nk_add_value(nk_context* ctx, nk_window* win, nk_hash name, nk_uint value)
{
    assert(ctx);
    assert(win);
    if (!win || !ctx) return 0;
    if (!win.tables || win.tables.size >= NK_VALUE_PAGE_CAPACITY) {
        nk_table* tbl = nk_create_table(ctx);
        assert(tbl);
        if (!tbl) return 0;
        nk_push_table(win, tbl);
    }
    win.tables.seq = win.seq;
    win.tables.keys[win.tables.size] = name;
    win.tables.values[win.tables.size] = value;
    return &win.tables.values[win.tables.size++];
}
nk_uint* nk_find_value(nk_window* win, nk_hash name)
{
    nk_table* iter = win.tables;
    while (iter) {
        uint i = 0;
        uint size = iter.size;
        for (i = 0; i < size; ++i) {
            if (iter.keys[i] == name) {
                iter.seq = win.seq;
                return &iter.values[i];
            }
        } size = NK_VALUE_PAGE_CAPACITY;
        iter = iter.next;
    }
    return 0;
}

