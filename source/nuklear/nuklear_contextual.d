module nuklear.nuklear_contextual;
extern(C) @nogc nothrow:
__gshared:

/* ==============================================================
 *
 *                          CONTEXTUAL
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_input;
import nuklear.nuklear_popup;
import nuklear.nuklear_text;
import nuklear.nuklear_widget;
import nuklear.nuklear_button;
import nuklear.nuklear_panel;

nk_bool nk_contextual_begin(nk_context* ctx, nk_flags flags, nk_vec2 size, nk_rect trigger_bounds)
{
    nk_window* win = void;
    nk_window* popup = void;
    nk_rect body = void;

    nk_rect null_rect = {-1,-1,0,0};
    int is_clicked = 0;
    int is_open = 0;
    int ret = 0;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    ++win.popup.con_count;
    if (ctx.current != ctx.active)
        return 0;

    /* check if currently active contextual is active */
    popup = win.popup.win;
    is_open = (popup && win.popup.type == NK_PANEL_CONTEXTUAL);
    is_clicked = nk_input_mouse_clicked(&ctx.input, NK_BUTTON_RIGHT, trigger_bounds);
    if (win.popup.active_con && win.popup.con_count != win.popup.active_con)
        return 0;
    if (!is_open && win.popup.active_con)
        win.popup.active_con = 0;
    if (!is_open && !is_clicked)
        return 0;

    /* calculate contextual position on click */
    win.popup.active_con = win.popup.con_count;
    if (is_clicked) {
        body.x = ctx.input.mouse.pos.x;
        body.y = ctx.input.mouse.pos.y;
    } else {
        body.x = popup.bounds.x;
        body.y = popup.bounds.y;
    }
    body.w = size.x;
    body.h = size.y;

    /* start nonblocking contextual popup */
    ret = nk_nonblock_begin(ctx, flags|NK_WINDOW_NO_SCROLLBAR, body,
            null_rect, NK_PANEL_CONTEXTUAL);
    if (ret) win.popup.type = NK_PANEL_CONTEXTUAL;
    else {
        win.popup.active_con = 0;
        win.popup.type = NK_PANEL_NONE;
        if (win.popup.win)
            win.popup.win.flags = 0;
    }
    return cast(nk_bool)ret;
}
nk_bool nk_contextual_item_text(nk_context* ctx, const(char)* text, int len, nk_flags alignment)
{
    nk_window* win = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    style = &ctx.style;
    state = nk_widget_fitting(&bounds, ctx, style.contextual_button.padding);
    if (!state) return nk_false;

    in_ = (state == NK_WIDGET_ROM || win.layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    if (nk_do_button_text(&ctx.last_widget_state, &win.buffer, bounds,
        text, len, alignment, NK_BUTTON_DEFAULT, &style.contextual_button, in_, style.font)) {
        nk_contextual_close(ctx);
        return nk_true;
    }
    return nk_false;
}
nk_bool nk_contextual_item_label(nk_context* ctx, const(char)* label, nk_flags align_)
{
    return nk_contextual_item_text(ctx, label, nk_strlen(label), align_);
}
nk_bool nk_contextual_item_image_text(nk_context* ctx, nk_image img, const(char)* text, int len, nk_flags align_)
{
    nk_window* win = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    style = &ctx.style;
    state = nk_widget_fitting(&bounds, ctx, style.contextual_button.padding);
    if (!state) return nk_false;

    in_ = (state == NK_WIDGET_ROM || win.layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    if (nk_do_button_text_image(&ctx.last_widget_state, &win.buffer, bounds,
        img, text, len, align_, NK_BUTTON_DEFAULT, &style.contextual_button, style.font, in_)){
        nk_contextual_close(ctx);
        return nk_true;
    }
    return nk_false;
}
nk_bool nk_contextual_item_image_label(nk_context* ctx, nk_image img, const(char)* label, nk_flags align_)
{
    return nk_contextual_item_image_text(ctx, img, label, nk_strlen(label), align_);
}
nk_bool nk_contextual_item_symbol_text(nk_context* ctx, nk_symbol_type symbol, const(char)* text, int len, nk_flags align_)
{
    nk_window* win = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    style = &ctx.style;
    state = nk_widget_fitting(&bounds, ctx, style.contextual_button.padding);
    if (!state) return nk_false;

    in_ = (state == NK_WIDGET_ROM || win.layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    if (nk_do_button_text_symbol(&ctx.last_widget_state, &win.buffer, bounds,
        symbol, text, len, align_, NK_BUTTON_DEFAULT, &style.contextual_button, style.font, in_)) {
        nk_contextual_close(ctx);
        return nk_true;
    }
    return nk_false;
}
nk_bool nk_contextual_item_symbol_label(nk_context* ctx, nk_symbol_type symbol, const(char)* text, nk_flags align_)
{
    return nk_contextual_item_symbol_text(ctx, symbol, text, nk_strlen(text), align_);
}
void nk_contextual_close(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout) return;
    nk_popup_close(ctx);
}
void nk_contextual_end(nk_context* ctx)
{
    nk_window* popup = void;
    nk_panel* panel = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return;

    popup = ctx.current;
    panel = popup.layout;
    assert(popup.parent);
    assert(panel.type & NK_PANEL_SET_POPUP);
    if (panel.flags & NK_WINDOW_DYNAMIC) {
        /* Close behavior
        This is a bit of a hack solution since we do not know before we end our popup
        how big it will be. We therefore do not directly know when a
        click outside the non-blocking popup must close it at that direct frame.
        Instead it will be closed in the next frame.*/
        nk_rect body = {0,0,0,0};
        if (panel.at_y < (panel.bounds.y + panel.bounds.h)) {
            nk_vec2 padding = nk_panel_get_padding(&ctx.style, panel.type);
            body = panel.bounds;
            body.y = (panel.at_y + panel.footer_height + panel.border + padding.y + panel.row.height);
            body.h = (panel.bounds.y + panel.bounds.h) - body.y;
        }
        {int pressed = nk_input_is_mouse_pressed(&ctx.input, NK_BUTTON_LEFT);
        int in_body = nk_input_is_mouse_hovering_rect(&ctx.input, body);
        if (pressed && in_body)
            popup.flags |= NK_WINDOW_HIDDEN;
        }
    }
    if (popup.flags & NK_WINDOW_HIDDEN)
        popup.seq = 0;
    nk_popup_end(ctx);
    return;
}

