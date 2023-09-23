module nuklear.nuklear_window;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              WINDOW
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_page_element;
import nuklear.nuklear_table;
import nuklear.nuklear_buffer;
import nuklear.nuklear_draw;
import nuklear.nuklear_context;
import nuklear.nuklear_input;
import nuklear.nuklear_panel;

void* nk_create_window(nk_context* ctx)
{
    nk_page_element* elem = void;
    elem = nk_create_page_element(ctx);
    if (!elem) return null;
    elem.data.win.seq = ctx.seq;
    return &elem.data.win;
}
void nk_free_window(nk_context* ctx, nk_window* win)
{
    /* unlink windows from list */
    nk_table* it = win.tables;
    if (win.popup.win) {
        nk_free_window(ctx, win.popup.win);
        win.popup.win = null;
    }
    win.next = null;
    win.prev = null;

    while (it) {
        /*free window state tables */
        nk_table* n = it.next;
        nk_remove_table(win, it);
        nk_free_table(ctx, it);
        if (it == win.tables)
            win.tables = n;
        it = n;
    }

    /* link windows into freelist */
    {nk_page_data* pd = nk_container_of!(nk_page_data, "win")(win);
    nk_page_element* pe = nk_container_of!(nk_page_element, "data")(pd);
    nk_free_page_element(ctx, pe);}
}
nk_window* nk_find_window(nk_context* ctx, nk_hash hash, const(char)* name)
{
    nk_window* iter = void;
    iter = ctx.begin;
    while (iter) {
        assert(iter != iter.next);
        if (iter.name == hash) {
            int max_len = nk_strlen(iter.name_string.ptr);
            if (!nk_stricmpn(iter.name_string.ptr, name, max_len))
                return iter;
        }
        iter = iter.next;
    }
    return null;
}
void nk_insert_window(nk_context* ctx, nk_window* win, nk_window_insert_location loc)
{
    const(nk_window)* iter = void;
    assert(ctx);
    assert(win);
    if (!win || !ctx) return;

    iter = ctx.begin;
    while (iter) {
        assert(iter != iter.next);
        assert(iter != win);
        if (iter == win) return;
        iter = iter.next;
    }

    if (!ctx.begin) {
        win.next = null;
        win.prev = null;
        ctx.begin = win;
        ctx.end = win;
        ctx.count = 1;
        return;
    }
    if (loc == NK_INSERT_BACK) {
        nk_window* end = void;
        end = ctx.end;
        end.flags |= NK_WINDOW_ROM;
        end.next = win;
        win.prev = ctx.end;
        win.next = null;
        ctx.end = win;
        ctx.active = ctx.end;
        ctx.end.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
    } else {
        /*ctx->end->flags |= NK_WINDOW_ROM;*/
        ctx.begin.prev = win;
        win.next = ctx.begin;
        win.prev = null;
        ctx.begin = win;
        ctx.begin.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
    }
    ctx.count++;
}
void nk_remove_window(nk_context* ctx, nk_window* win)
{
    if (win == ctx.begin || win == ctx.end) {
        if (win == ctx.begin) {
            ctx.begin = win.next;
            if (win.next)
                win.next.prev = null;
        }
        if (win == ctx.end) {
            ctx.end = win.prev;
            if (win.prev)
                win.prev.next = null;
        }
    } else {
        if (win.next)
            win.next.prev = win.prev;
        if (win.prev)
            win.prev.next = win.next;
    }
    if (win == ctx.active || !ctx.active) {
        ctx.active = ctx.end;
        if (ctx.end)
            ctx.end.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
    }
    win.next = null;
    win.prev = null;
    ctx.count--;
}
nk_bool nk_begin(nk_context* ctx, const(char)* title, nk_rect bounds, nk_flags flags)
{
    return nk_begin_titled(ctx, title, title, bounds, flags);
}
nk_bool nk_begin_titled(nk_context* ctx, const(char)* name, const(char)* title, nk_rect bounds, nk_flags flags)
{
    nk_window* win = void;
    nk_style* style = void;
    nk_hash name_hash = void;
    int name_len = void;
    int ret = 0;

    assert(ctx);
    assert(name);
    assert(title);
    assert(ctx.style.font && ctx.style.font.width && "if this triggers you forgot to add a font");
    assert(!ctx.current && "if this triggers you missed a `nk_end` call");
    if (!ctx || ctx.current || !title || !name)
        return 0;

    /* find or create window */
    style = &ctx.style;
    name_len = cast(int)nk_strlen(name);
    name_hash = nk_murmur_hash(name, cast(int)name_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, name_hash, name);
    if (!win) {
        /* create new window */
        nk_size name_length = cast(nk_size)name_len;
        win = cast(nk_window*)nk_create_window(ctx);
        assert(win);
        if (!win) return 0;

        if (flags & NK_WINDOW_BACKGROUND)
            nk_insert_window(ctx, win, NK_INSERT_FRONT);
        else nk_insert_window(ctx, win, NK_INSERT_BACK);
        nk_command_buffer_init(&win.buffer, &ctx.memory, NK_CLIPPING_ON);

        win.flags = flags;
        win.bounds = bounds;
        win.name = name_hash;
        name_length = nk_min(name_length, NK_WINDOW_MAX_NAME-1);
        nk_memcopy(win.name_string.ptr, name, name_length);
        win.name_string[name_length] = 0;
        win.popup.win = null;
        if (!ctx.active)
            ctx.active = win;
    } else {
        /* update window */
        win.flags &= ~cast(nk_flags)(NK_WINDOW_PRIVATE-1);
        win.flags |= flags;
        if (!(win.flags & (NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE)))
            win.bounds = bounds;
        /* If this assert triggers you either:
         *
         * I.) Have more than one window with the same name or
         * II.) You forgot to actually draw the window.
         *      More specific you did not call `nk_clear` (nk_clear will be
         *      automatically called for you if you are using one of the
         *      provided demo backends). */
        assert(win.seq != ctx.seq);
        win.seq = ctx.seq;
        if (!ctx.active && !(win.flags & NK_WINDOW_HIDDEN)) {
            ctx.active = win;
            ctx.end = win;
        }
    }
    if (win.flags & NK_WINDOW_HIDDEN) {
        ctx.current = win;
        win.layout = null;
        return 0;
    } else nk_start(ctx, win);

    /* window overlapping */
    if (!(win.flags & NK_WINDOW_HIDDEN) && !(win.flags & NK_WINDOW_NO_INPUT))
    {
        int inpanel = void, ishovered = void;
        nk_window* iter = win;
        float h = ctx.style.font.height + 2.0f * style.window.header.padding.y +
            (2.0f * style.window.header.label_padding.y);
        nk_rect win_bounds = (!(win.flags & NK_WINDOW_MINIMIZED))?
            win.bounds: nk_rect(win.bounds.x, win.bounds.y, win.bounds.w, h);

        /* activate window if hovered and no other window is overlapping this window */
        inpanel = nk_input_has_mouse_click_down_in_rect(&ctx.input, NK_BUTTON_LEFT, win_bounds, nk_true);
        inpanel = inpanel && ctx.input.mouse.buttons[NK_BUTTON_LEFT].clicked;
        ishovered = nk_input_is_mouse_hovering_rect(&ctx.input, win_bounds);
        if ((win != ctx.active) && ishovered && !ctx.input.mouse.buttons[NK_BUTTON_LEFT].down) {
            iter = win.next;
            while (iter) {
                nk_rect iter_bounds = (!(iter.flags & NK_WINDOW_MINIMIZED))?
                    iter.bounds: nk_rect(iter.bounds.x, iter.bounds.y, iter.bounds.w, h);
                if (nk_intersect(win_bounds.x, win_bounds.y, win_bounds.w, win_bounds.h,
                    iter_bounds.x, iter_bounds.y, iter_bounds.w, iter_bounds.h) &&
                    (!(iter.flags & NK_WINDOW_HIDDEN)))
                    break;

                if (iter.popup.win && iter.popup.active && !(iter.flags & NK_WINDOW_HIDDEN) &&
                    nk_intersect(win.bounds.x, win_bounds.y, win_bounds.w, win_bounds.h,
                    iter.popup.win.bounds.x, iter.popup.win.bounds.y,
                    iter.popup.win.bounds.w, iter.popup.win.bounds.h))
                    break;
                iter = iter.next;
            }
        }

        /* activate window if clicked */
        if (iter && inpanel && (win != ctx.end)) {
            iter = win.next;
            while (iter) {
                /* try to find a panel with higher priority in the same position */
                nk_rect iter_bounds = (!(iter.flags & NK_WINDOW_MINIMIZED))?
                iter.bounds: nk_rect(iter.bounds.x, iter.bounds.y, iter.bounds.w, h);
                if (nk_inbox(ctx.input.mouse.pos.x, ctx.input.mouse.pos.y,
                    iter_bounds.x, iter_bounds.y, iter_bounds.w, iter_bounds.h) &&
                    !(iter.flags & NK_WINDOW_HIDDEN))
                    break;
                if (iter.popup.win && iter.popup.active && !(iter.flags & NK_WINDOW_HIDDEN) &&
                    nk_intersect(win_bounds.x, win_bounds.y, win_bounds.w, win_bounds.h,
                    iter.popup.win.bounds.x, iter.popup.win.bounds.y,
                    iter.popup.win.bounds.w, iter.popup.win.bounds.h))
                    break;
                iter = iter.next;
            }
        }
        if (iter && !(win.flags & NK_WINDOW_ROM) && (win.flags & NK_WINDOW_BACKGROUND)) {
            win.flags |= cast(nk_flags)NK_WINDOW_ROM;
            iter.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
            ctx.active = iter;
            if (!(iter.flags & NK_WINDOW_BACKGROUND)) {
                /* current window is active in that position so transfer to top
                 * at the highest priority in stack */
                nk_remove_window(ctx, iter);
                nk_insert_window(ctx, iter, NK_INSERT_BACK);
            }
        } else {
            if (!iter && ctx.end != win) {
                if (!(win.flags & NK_WINDOW_BACKGROUND)) {
                    /* current window is active in that position so transfer to top
                     * at the highest priority in stack */
                    nk_remove_window(ctx, win);
                    nk_insert_window(ctx, win, NK_INSERT_BACK);
                }
                win.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
                ctx.active = win;
            }
            if (ctx.end != win && !(win.flags & NK_WINDOW_BACKGROUND))
                win.flags |= NK_WINDOW_ROM;
        }
    }
    win.layout = cast(nk_panel*)nk_create_panel(ctx);
    ctx.current = win;
    ret = nk_panel_begin(ctx, title, NK_PANEL_WINDOW);
    win.layout.offset_x = &win.scrollbar.x;
    win.layout.offset_y = &win.scrollbar.y;
    return cast(nk_bool)ret;
}
void nk_end(nk_context* ctx)
{
    nk_panel* layout = void;
    assert(ctx);
    assert(ctx.current && "if this triggers you forgot to call `nk_begin`");
    if (!ctx || !ctx.current)
        return;

    layout = ctx.current.layout;
    if (!layout || (layout.type == NK_PANEL_WINDOW && (ctx.current.flags & NK_WINDOW_HIDDEN))) {
        ctx.current = null;
        return;
    }
    nk_panel_end(ctx);
    nk_free_panel(ctx, ctx.current.layout);
    ctx.current = null;
}
nk_rect nk_window_get_bounds(const(nk_context)* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return nk_rect(0,0,0,0);
    return ctx.current.bounds;
}
nk_vec2 nk_window_get_position(const(nk_context)* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return nk_vec2(0,0);
    return nk_vec2(ctx.current.bounds.x, ctx.current.bounds.y);
}
nk_vec2 nk_window_get_size(const(nk_context)* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return nk_vec2(0,0);
    return nk_vec2(ctx.current.bounds.w, ctx.current.bounds.h);
}
float nk_window_get_width(const(nk_context)* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return 0;
    return ctx.current.bounds.w;
}
float nk_window_get_height(const(nk_context)* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return 0;
    return ctx.current.bounds.h;
}
nk_rect nk_window_get_content_region(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return nk_rect(0,0,0,0);
    return ctx.current.layout.clip;
}
nk_vec2 nk_window_get_content_region_min(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current) return nk_vec2(0,0);
    return nk_vec2(ctx.current.layout.clip.x, ctx.current.layout.clip.y);
}
nk_vec2 nk_window_get_content_region_max(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current) return nk_vec2(0,0);
    return nk_vec2(ctx.current.layout.clip.x + ctx.current.layout.clip.w,
        ctx.current.layout.clip.y + ctx.current.layout.clip.h);
}
nk_vec2 nk_window_get_content_region_size(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current) return nk_vec2(0,0);
    return nk_vec2(ctx.current.layout.clip.w, ctx.current.layout.clip.h);
}
nk_command_buffer* nk_window_get_canvas(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current) return null;
    return &ctx.current.buffer;
}
nk_panel* nk_window_get_panel(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return null;
    return ctx.current.layout;
}
void nk_window_get_scroll(nk_context* ctx, nk_uint* offset_x, nk_uint* offset_y)
{
    nk_window* win = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return ;
    win = ctx.current;
    if (offset_x)
      *offset_x = win.scrollbar.x;
    if (offset_y)
      *offset_y = win.scrollbar.y;
}
nk_bool nk_window_has_focus(const(nk_context)* ctx)
{
    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current) return 0;
    return ctx.current == ctx.active;
}
nk_bool nk_window_is_hovered(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current || (ctx.current.flags & NK_WINDOW_HIDDEN))
        return 0;
    else {
        nk_rect actual_bounds = ctx.current.bounds;
        if (ctx.begin.flags & NK_WINDOW_MINIMIZED) {
            actual_bounds.h = ctx.current.layout.header_height;
        }
        return nk_input_is_mouse_hovering_rect(&ctx.input, actual_bounds);
    }
}
nk_bool nk_window_is_any_hovered(nk_context* ctx)
{
    nk_window* iter = void;
    assert(ctx);
    if (!ctx) return 0;
    iter = ctx.begin;
    while (iter) {
        /* check if window is being hovered */
        if(!(iter.flags & NK_WINDOW_HIDDEN)) {
            /* check if window popup is being hovered */
            if (iter.popup.active && iter.popup.win && nk_input_is_mouse_hovering_rect(&ctx.input, iter.popup.win.bounds))
                return 1;

            if (iter.flags & NK_WINDOW_MINIMIZED) {
                nk_rect header = iter.bounds;
                header.h = ctx.style.font.height + 2 * ctx.style.window.header.padding.y;
                if (nk_input_is_mouse_hovering_rect(&ctx.input, header))
                    return 1;
            } else if (nk_input_is_mouse_hovering_rect(&ctx.input, iter.bounds)) {
                return 1;
            }
        }
        iter = iter.next;
    }
    return 0;
}
nk_bool nk_item_is_any_active(nk_context* ctx)
{
    int any_hovered = nk_window_is_any_hovered(ctx);
    int any_active = (ctx.last_widget_state & NK_WIDGET_STATE_MODIFIED);
    return any_hovered || any_active;
}
nk_bool nk_window_is_collapsed(nk_context* ctx, const(char)* name)
{
    int title_len = void;
    nk_hash title_hash = void;
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return 0;

    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, title_hash, name);
    if (!win) return 0;
    return cast(nk_bool)(win.flags & NK_WINDOW_MINIMIZED);
}
nk_bool nk_window_is_closed(nk_context* ctx, const(char)* name)
{
    int title_len = void;
    nk_hash title_hash = void;
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return 1;

    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, title_hash, name);
    if (!win) return 1;
    return cast(nk_bool)(win.flags & NK_WINDOW_CLOSED);
}
nk_bool nk_window_is_hidden(nk_context* ctx, const(char)* name)
{
    int title_len = void;
    nk_hash title_hash = void;
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return 1;

    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, title_hash, name);
    if (!win) return 1;
    return cast(nk_bool)(win.flags & NK_WINDOW_HIDDEN);
}
nk_bool nk_window_is_active(nk_context* ctx, const(char)* name)
{
    int title_len = void;
    nk_hash title_hash = void;
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return 0;

    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, title_hash, name);
    if (!win) return 0;
    return win == ctx.active;
}
nk_window* nk_window_find(nk_context* ctx, const(char)* name)
{
    int title_len = void;
    nk_hash title_hash = void;
    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    return nk_find_window(ctx, title_hash, name);
}
void nk_window_close(nk_context* ctx, const(char)* name)
{
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return;
    win = nk_window_find(ctx, name);
    if (!win) return;
    assert(ctx.current != win && "You cannot close a currently active window");
    if (ctx.current == win) return;
    win.flags |= NK_WINDOW_HIDDEN;
    win.flags |= NK_WINDOW_CLOSED;
}
void nk_window_set_bounds(nk_context* ctx, const(char)* name, nk_rect bounds)
{
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return;
    win = nk_window_find(ctx, name);
    if (!win) return;
    assert(ctx.current != win && "You cannot update a currently in procecss window");
    win.bounds = bounds;
}
void nk_window_set_position(nk_context* ctx, const(char)* name, nk_vec2 pos)
{
    nk_window* win = nk_window_find(ctx, name);
    if (!win) return;
    win.bounds.x = pos.x;
    win.bounds.y = pos.y;
}
void nk_window_set_size(nk_context* ctx, const(char)* name, nk_vec2 size)
{
    nk_window* win = nk_window_find(ctx, name);
    if (!win) return;
    win.bounds.w = size.x;
    win.bounds.h = size.y;
}
void nk_window_set_scroll(nk_context* ctx, nk_uint offset_x, nk_uint offset_y)
{
    nk_window* win = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return;
    win = ctx.current;
    win.scrollbar.x = offset_x;
    win.scrollbar.y = offset_y;
}
void nk_window_collapse(nk_context* ctx, const(char)* name, nk_collapse_states c)
{
    int title_len = void;
    nk_hash title_hash = void;
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return;

    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, title_hash, name);
    if (!win) return;
    if (c == NK_MINIMIZED)
        win.flags |= NK_WINDOW_MINIMIZED;
    else win.flags &= ~cast(nk_flags)NK_WINDOW_MINIMIZED;
}
void nk_window_collapse_if(nk_context* ctx, const(char)* name, nk_collapse_states c, int cond)
{
    assert(ctx);
    if (!ctx || !cond) return;
    nk_window_collapse(ctx, name, c);
}
void nk_window_show(nk_context* ctx, const(char)* name, nk_show_states s)
{
    int title_len = void;
    nk_hash title_hash = void;
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return;

    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, title_hash, name);
    if (!win) return;
    if (s == NK_HIDDEN) {
        win.flags |= NK_WINDOW_HIDDEN;
    } else win.flags &= ~cast(nk_flags)NK_WINDOW_HIDDEN;
}
void nk_window_show_if(nk_context* ctx, const(char)* name, nk_show_states s, int cond)
{
    assert(ctx);
    if (!ctx || !cond) return;
    nk_window_show(ctx, name, s);
}

void nk_window_set_focus(nk_context* ctx, const(char)* name)
{
    int title_len = void;
    nk_hash title_hash = void;
    nk_window* win = void;
    assert(ctx);
    if (!ctx) return;

    title_len = cast(int)nk_strlen(name);
    title_hash = nk_murmur_hash(name, cast(int)title_len, NK_WINDOW_TITLE);
    win = nk_find_window(ctx, title_hash, name);
    if (win && ctx.end != win) {
        nk_remove_window(ctx, win);
        nk_insert_window(ctx, win, NK_INSERT_BACK);
    }
    ctx.active = win;
}

