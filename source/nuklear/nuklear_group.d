module nuklear.nuklear_group;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          GROUP
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_panel;
import nuklear.nuklear_layout;
import nuklear.nuklear_draw;
import nuklear.nuklear_window;
import nuklear.nuklear_table;

nk_bool nk_group_scrolled_offset_begin(nk_context* ctx, nk_uint* x_offset, nk_uint* y_offset, const(char)* title, nk_flags flags)
{
    nk_rect bounds = void;
    nk_window panel = void;
    nk_window* win = void;

    win = ctx.current;
    nk_panel_alloc_space(&bounds, ctx);
    {const(nk_rect)* c = &win.layout.clip;
    if (!nk_intersect(c.x, c.y, c.w, c.h, bounds.x, bounds.y, bounds.w, bounds.h) &&
        !(flags & NK_WINDOW_MOVABLE)) {
        return 0;
    }}
    if (win.flags & NK_WINDOW_ROM)
        flags |= NK_WINDOW_ROM;

    /* initialize a fake window to create the panel from */
    nk_zero(&panel, panel.sizeof);
    panel.bounds = bounds;
    panel.flags = flags;
    panel.scrollbar.x = *x_offset;
    panel.scrollbar.y = *y_offset;
    panel.buffer = win.buffer;
    panel.layout = cast(nk_panel*)nk_create_panel(ctx);
    ctx.current = &panel;
    nk_panel_begin(ctx, (flags & NK_WINDOW_TITLE) ? title: null, NK_PANEL_GROUP);

    win.buffer = panel.buffer;
    win.buffer.clip = panel.layout.clip;
    panel.layout.offset_x = x_offset;
    panel.layout.offset_y = y_offset;
    panel.layout.parent = win.layout;
    win.layout = panel.layout;

    ctx.current = win;
    if ((panel.layout.flags & NK_WINDOW_CLOSED) ||
        (panel.layout.flags & NK_WINDOW_MINIMIZED))
    {
        nk_flags f = panel.layout.flags;
        nk_group_scrolled_end(ctx);
        if (f & NK_WINDOW_CLOSED)
            return cast(nk_bool)NK_WINDOW_CLOSED;
        if (f & NK_WINDOW_MINIMIZED)
            return cast(nk_bool)NK_WINDOW_MINIMIZED;
    }
    return 1;
}
void nk_group_scrolled_end(nk_context* ctx)
{
    nk_window* win = void;
    nk_panel* parent = void;
    nk_panel* g = void;

    nk_rect clip = void;
    nk_window pan = void;
    nk_vec2 panel_padding = void;

    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return;

    /* make sure nk_group_begin was called correctly */
    assert(ctx.current);
    win = ctx.current;
    assert(win.layout);
    g = win.layout;
    assert(g.parent);
    parent = g.parent;

    /* dummy window */
    nk_zero_struct(pan);
    panel_padding = nk_panel_get_padding(&ctx.style, NK_PANEL_GROUP);
    pan.bounds.y = g.bounds.y - (g.header_height + g.menu.h);
    pan.bounds.x = g.bounds.x - panel_padding.x;
    pan.bounds.w = g.bounds.w + 2 * panel_padding.x;
    pan.bounds.h = g.bounds.h + g.header_height + g.menu.h;
    if (g.flags & NK_WINDOW_BORDER) {
        pan.bounds.x -= g.border;
        pan.bounds.y -= g.border;
        pan.bounds.w += 2*g.border;
        pan.bounds.h += 2*g.border;
    }
    if (!(g.flags & NK_WINDOW_NO_SCROLLBAR)) {
        pan.bounds.w += ctx.style.window.scrollbar_size.x;
        pan.bounds.h += ctx.style.window.scrollbar_size.y;
    }
    pan.scrollbar.x = *g.offset_x;
    pan.scrollbar.y = *g.offset_y;
    pan.flags = g.flags;
    pan.buffer = win.buffer;
    pan.layout = g;
    pan.parent = win;
    ctx.current = &pan;

    /* make sure group has correct clipping rectangle */
    nk_unify(&clip, &parent.clip, pan.bounds.x, pan.bounds.y,
        pan.bounds.x + pan.bounds.w, pan.bounds.y + pan.bounds.h + panel_padding.x);
    nk_push_scissor(&pan.buffer, clip);
    nk_end(ctx);

    win.buffer = pan.buffer;
    nk_push_scissor(&win.buffer, parent.clip);
    ctx.current = win;
    win.layout = parent;
    g.bounds = pan.bounds;
    return;
}
nk_bool nk_group_scrolled_begin(nk_context* ctx, nk_scroll* scroll, const(char)* title, nk_flags flags)
{
    return nk_group_scrolled_offset_begin(ctx, &scroll.x, &scroll.y, title, flags);
}
nk_bool nk_group_begin_titled(nk_context* ctx, const(char)* id, const(char)* title, nk_flags flags)
{
    int id_len = void;
    nk_hash id_hash = void;
    nk_window* win = void;
    nk_uint* x_offset = void;
    nk_uint* y_offset = void;

    assert(ctx);
    assert(id);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !id)
        return 0;

    /* find persistent group scrollbar value */
    win = ctx.current;
    id_len = cast(int)nk_strlen(id);
    id_hash = nk_murmur_hash(id, cast(int)id_len, NK_PANEL_GROUP);
    x_offset = nk_find_value(win, id_hash);
    if (!x_offset) {
        x_offset = nk_add_value(ctx, win, id_hash, 0);
        y_offset = nk_add_value(ctx, win, id_hash+1, 0);

        assert(x_offset);
        assert(y_offset);
        if (!x_offset || !y_offset) return 0;
        *x_offset = *y_offset = 0;
    } else y_offset = nk_find_value(win, id_hash+1);
    return nk_group_scrolled_offset_begin(ctx, x_offset, y_offset, title, flags);
}
nk_bool nk_group_begin(nk_context* ctx, const(char)* title, nk_flags flags)
{
    return nk_group_begin_titled(ctx, title, title, flags);
}
void nk_group_end(nk_context* ctx)
{
    nk_group_scrolled_end(ctx);
}
void nk_group_get_scroll(nk_context* ctx, const(char)* id, nk_uint* x_offset, nk_uint* y_offset)
{
    int id_len = void;
    nk_hash id_hash = void;
    nk_window* win = void;
    nk_uint* x_offset_ptr = void;
    nk_uint* y_offset_ptr = void;

    assert(ctx);
    assert(id);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !id)
        return;

    /* find persistent group scrollbar value */
    win = ctx.current;
    id_len = cast(int)nk_strlen(id);
    id_hash = nk_murmur_hash(id, cast(int)id_len, NK_PANEL_GROUP);
    x_offset_ptr = nk_find_value(win, id_hash);
    if (!x_offset_ptr) {
        x_offset_ptr = nk_add_value(ctx, win, id_hash, 0);
        y_offset_ptr = nk_add_value(ctx, win, id_hash+1, 0);

        assert(x_offset_ptr);
        assert(y_offset_ptr);
        if (!x_offset_ptr || !y_offset_ptr) return;
        *x_offset_ptr = *y_offset_ptr = 0;
    } else y_offset_ptr = nk_find_value(win, id_hash+1);
    if (x_offset)
      *x_offset = *x_offset_ptr;
    if (y_offset)
      *y_offset = *y_offset_ptr;
}
void nk_group_set_scroll(nk_context* ctx, const(char)* id, nk_uint x_offset, nk_uint y_offset)
{
    int id_len = void;
    nk_hash id_hash = void;
    nk_window* win = void;
    nk_uint* x_offset_ptr = void;
    nk_uint* y_offset_ptr = void;

    assert(ctx);
    assert(id);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !id)
        return;

    /* find persistent group scrollbar value */
    win = ctx.current;
    id_len = cast(int)nk_strlen(id);
    id_hash = nk_murmur_hash(id, cast(int)id_len, NK_PANEL_GROUP);
    x_offset_ptr = nk_find_value(win, id_hash);
    if (!x_offset_ptr) {
        x_offset_ptr = nk_add_value(ctx, win, id_hash, 0);
        y_offset_ptr = nk_add_value(ctx, win, id_hash+1, 0);

        assert(x_offset_ptr);
        assert(y_offset_ptr);
        if (!x_offset_ptr || !y_offset_ptr) return;
        *x_offset_ptr = *y_offset_ptr = 0;
    } else y_offset_ptr = nk_find_value(win, id_hash+1);
    *x_offset_ptr = x_offset;
    *y_offset_ptr = y_offset;
}
