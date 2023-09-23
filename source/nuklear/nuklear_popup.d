module nuklear.nuklear_popup;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              POPUP
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

nk_bool nk_popup_begin(nk_context* ctx, nk_popup_type type, const(char)* title, nk_flags flags, nk_rect rect)
{
    nk_window* popup = void;
    nk_window* win = void;
    nk_panel* panel = void;

    int title_len = void;
    nk_hash title_hash = void;
    nk_size allocated = void;

    assert(ctx);
    assert(title);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    panel = win.layout;
    assert(!(panel.type & NK_PANEL_SET_POPUP) && "popups are not allowed to have popups");
    cast(void)panel;
    title_len = cast(int)nk_strlen(title);
    title_hash = nk_murmur_hash(title, cast(int)title_len, NK_PANEL_POPUP);

    popup = win.popup.win;
    if (!popup) {
        popup = cast(nk_window*)nk_create_window(ctx);
        popup.parent = win;
        win.popup.win = popup;
        win.popup.active = 0;
        win.popup.type = NK_PANEL_POPUP;
    }

    /* make sure we have correct popup */
    if (win.popup.name != title_hash) {
        if (!win.popup.active) {
            nk_zero(popup, typeof(*popup).sizeof);
            win.popup.name = title_hash;
            win.popup.active = 1;
            win.popup.type = NK_PANEL_POPUP;
        } else return 0;
    }

    /* popup position is local to window */
    ctx.current = popup;
    rect.x += win.layout.clip.x;
    rect.y += win.layout.clip.y;

    /* setup popup data */
    popup.parent = win;
    popup.bounds = rect;
    popup.seq = ctx.seq;
    popup.layout = cast(nk_panel*)nk_create_panel(ctx);
    popup.flags = flags;
    popup.flags |= NK_WINDOW_BORDER;
    if (type == NK_POPUP_DYNAMIC)
        popup.flags |= NK_WINDOW_DYNAMIC;

    popup.buffer = win.buffer;
    nk_start_popup(ctx, win);
    allocated = ctx.memory.allocated;
    nk_push_scissor(&popup.buffer, nk_null_rect);

    if (nk_panel_begin(ctx, title, NK_PANEL_POPUP)) {
        /* popup is running therefore invalidate parent panels */
        nk_panel* root = void;
        root = win.layout;
        while (root) {
            root.flags |= NK_WINDOW_ROM;
            root.flags &= ~cast(nk_flags)NK_WINDOW_REMOVE_ROM;
            root = root.parent;
        }
        win.popup.active = 1;
        popup.layout.offset_x = &popup.scrollbar.x;
        popup.layout.offset_y = &popup.scrollbar.y;
        popup.layout.parent = win.layout;
        return 1;
    } else {
        /* popup was closed/is invalid so cleanup */
        nk_panel* root = void;
        root = win.layout;
        while (root) {
            root.flags |= NK_WINDOW_REMOVE_ROM;
            root = root.parent;
        }
        win.popup.buf.active = 0;
        win.popup.active = 0;
        ctx.memory.allocated = allocated;
        ctx.current = win;
        nk_free_panel(ctx, popup.layout);
        popup.layout = 0;
        return 0;
    }
}
nk_bool nk_nonblock_begin(nk_context* ctx, nk_flags flags, nk_rect body, nk_rect header, nk_panel_type panel_type)
{
    nk_window* popup = void;
    nk_window* win = void;
    nk_panel* panel = void;
    int is_active = nk_true;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    /* popups cannot have popups */
    win = ctx.current;
    panel = win.layout;
    assert(!(panel.type & NK_PANEL_SET_POPUP));
    cast(void)panel;
    popup = win.popup.win;
    if (!popup) {
        /* create window for nonblocking popup */
        popup = cast(nk_window*)nk_create_window(ctx);
        popup.parent = win;
        win.popup.win = popup;
        win.popup.type = panel_type;
        nk_command_buffer_init(&popup.buffer, &ctx.memory, NK_CLIPPING_ON);
    } else {
        /* close the popup if user pressed outside or in the header */
        int pressed = void, in_body = void, in_header = void;
version (NK_BUTTON_TRIGGER_ON_RELEASE) {
        pressed = nk_input_is_mouse_released(&ctx.input, NK_BUTTON_LEFT);
} else {
        pressed = nk_input_is_mouse_pressed(&ctx.input, NK_BUTTON_LEFT);
}
        in_body = nk_input_is_mouse_hovering_rect(&ctx.input, body);
        in_header = nk_input_is_mouse_hovering_rect(&ctx.input, header);
        if (pressed && (!in_body || in_header))
            is_active = nk_false;
    }
    win.popup.header = header;

    if (!is_active) {
        /* remove read only mode from all parent panels */
        nk_panel* root = win.layout;
        while (root) {
            root.flags |= NK_WINDOW_REMOVE_ROM;
            root = root.parent;
        }
        return is_active;
    }
    popup.bounds = body;
    popup.parent = win;
    popup.layout = cast(nk_panel*)nk_create_panel(ctx);
    popup.flags = flags;
    popup.flags |= NK_WINDOW_BORDER;
    popup.flags |= NK_WINDOW_DYNAMIC;
    popup.seq = ctx.seq;
    win.popup.active = 1;
    assert(popup.layout);

    nk_start_popup(ctx, win);
    popup.buffer = win.buffer;
    nk_push_scissor(&popup.buffer, nk_null_rect);
    ctx.current = popup;

    nk_panel_begin(ctx, 0, panel_type);
    win.buffer = popup.buffer;
    popup.layout.parent = win.layout;
    popup.layout.offset_x = &popup.scrollbar.x;
    popup.layout.offset_y = &popup.scrollbar.y;

    /* set read only mode to all parent panels */
    {nk_panel* root = void;
    root = win.layout;
    while (root) {
        root.flags |= NK_WINDOW_ROM;
        root = root.parent;
    }}
    return is_active;
}
void nk_popup_close(nk_context* ctx)
{
    nk_window* popup = void;
    assert(ctx);
    if (!ctx || !ctx.current) return;

    popup = ctx.current;
    assert(popup.parent);
    assert(popup.layout.type & NK_PANEL_SET_POPUP);
    popup.flags |= NK_WINDOW_HIDDEN;
}
void nk_popup_end(nk_context* ctx)
{
    nk_window* win = void;
    nk_window* popup = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    popup = ctx.current;
    if (!popup.parent) return;
    win = popup.parent;
    if (popup.flags & NK_WINDOW_HIDDEN) {
        nk_panel* root = void;
        root = win.layout;
        while (root) {
            root.flags |= NK_WINDOW_REMOVE_ROM;
            root = root.parent;
        }
        win.popup.active = 0;
    }
    nk_push_scissor(&popup.buffer, nk_null_rect);
    nk_end(ctx);

    win.buffer = popup.buffer;
    nk_finish_popup(ctx, win);
    ctx.current = win;
    nk_push_scissor(&win.buffer, win.layout.clip);
}
void nk_popup_get_scroll(nk_context* ctx, nk_uint* offset_x, nk_uint* offset_y)
{
    nk_window* popup = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    popup = ctx.current;
    if (offset_x)
      *offset_x = popup.scrollbar.x;
    if (offset_y)
      *offset_y = popup.scrollbar.y;
}
void nk_popup_set_scroll(nk_context* ctx, nk_uint offset_x, nk_uint offset_y)
{
    nk_window* popup = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    popup = ctx.current;
    popup.scrollbar.x = offset_x;
    popup.scrollbar.y = offset_y;
}

