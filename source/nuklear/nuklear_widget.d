module nuklear.nuklear_widget;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              WIDGET
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

void nk_widget_state_reset(S)(S *s) {
    if ((*s) & NK_WIDGET_STATE_MODIFIED)
        (*s) = NK_WIDGET_STATE_INACTIVE|NK_WIDGET_STATE_MODIFIED;
    else (*s) = NK_WIDGET_STATE_INACTIVE;
}

nk_rect nk_widget_bounds(nk_context* ctx)
{
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return nk_rect(0,0,0,0);
    nk_layout_peek(&bounds, ctx);
    return bounds;
}
nk_vec2 nk_widget_position(nk_context* ctx)
{
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return nk_vec2(0,0);

    nk_layout_peek(&bounds, ctx);
    return nk_vec2(bounds.x, bounds.y);
}
nk_vec2 nk_widget_size(nk_context* ctx)
{
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return nk_vec2(0,0);

    nk_layout_peek(&bounds, ctx);
    return nk_vec2(bounds.w, bounds.h);
}
float nk_widget_width(nk_context* ctx)
{
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return 0;

    nk_layout_peek(&bounds, ctx);
    return bounds.w;
}
float nk_widget_height(nk_context* ctx)
{
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current)
        return 0;

    nk_layout_peek(&bounds, ctx);
    return bounds.h;
}
nk_bool nk_widget_is_hovered(nk_context* ctx)
{
    nk_rect c = void, v = void;
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current || ctx.active != ctx.current)
        return 0;

    c = ctx.current.layout.clip;
    c.x = cast(float)(cast(int)c.x);
    c.y = cast(float)(cast(int)c.y);
    c.w = cast(float)(cast(int)c.w);
    c.h = cast(float)(cast(int)c.h);

    nk_layout_peek(&bounds, ctx);
    nk_unify(&v, &c, bounds.x, bounds.y, bounds.x + bounds.w, bounds.y + bounds.h);
    if (!nk_intersect(c.x, c.y, c.w, c.h, bounds.x, bounds.y, bounds.w, bounds.h))
        return 0;
    return nk_input_is_mouse_hovering_rect(&ctx.input, bounds);
}
nk_bool nk_widget_is_mouse_clicked(nk_context* ctx, nk_buttons btn)
{
    nk_rect c = void, v = void;
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current || ctx.active != ctx.current)
        return 0;

    c = ctx.current.layout.clip;
    c.x = cast(float)(cast(int)c.x);
    c.y = cast(float)(cast(int)c.y);
    c.w = cast(float)(cast(int)c.w);
    c.h = cast(float)(cast(int)c.h);

    nk_layout_peek(&bounds, ctx);
    nk_unify(&v, &c, bounds.x, bounds.y, bounds.x + bounds.w, bounds.y + bounds.h);
    if (!nk_intersect(c.x, c.y, c.w, c.h, bounds.x, bounds.y, bounds.w, bounds.h))
        return 0;
    return nk_input_mouse_clicked(&ctx.input, btn, bounds);
}
nk_bool nk_widget_has_mouse_click_down(nk_context* ctx, nk_buttons btn, nk_bool down)
{
    nk_rect c = void, v = void;
    nk_rect bounds = void;
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current || ctx.active != ctx.current)
        return 0;

    c = ctx.current.layout.clip;
    c.x = cast(float)(cast(int)c.x);
    c.y = cast(float)(cast(int)c.y);
    c.w = cast(float)(cast(int)c.w);
    c.h = cast(float)(cast(int)c.h);

    nk_layout_peek(&bounds, ctx);
    nk_unify(&v, &c, bounds.x, bounds.y, bounds.x + bounds.w, bounds.y + bounds.h);
    if (!nk_intersect(c.x, c.y, c.w, c.h, bounds.x, bounds.y, bounds.w, bounds.h))
        return 0;
    return nk_input_has_mouse_click_down_in_rect(&ctx.input, btn, bounds, down);
}
nk_widget_layout_states nk_widget(nk_rect* bounds, const(nk_context)* ctx)
{
    nk_rect c = void, v = void;
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return NK_WIDGET_INVALID;

    /* allocate space and check if the widget needs to be updated and drawn */
    nk_panel_alloc_space(bounds, ctx);
    win = ctx.current;
    layout = win.layout;
    in_ = &ctx.input;
    c = layout.clip;

    /*  if one of these triggers you forgot to add an `if` condition around either
        a window, group, popup, combobox or contextual menu `begin` and `end` block.
        Example:
            if (nk_begin(...) {...} nk_end(...); or
            if (nk_group_begin(...) { nk_group_end(...);} */
    assert(!(layout.flags & NK_WINDOW_MINIMIZED));
    assert(!(layout.flags & NK_WINDOW_HIDDEN));
    assert(!(layout.flags & NK_WINDOW_CLOSED));

    /* need to convert to int here to remove floating point errors */
    bounds.x = cast(float)(cast(int)bounds.x);
    bounds.y = cast(float)(cast(int)bounds.y);
    bounds.w = cast(float)(cast(int)bounds.w);
    bounds.h = cast(float)(cast(int)bounds.h);

    c.x = cast(float)(cast(int)c.x);
    c.y = cast(float)(cast(int)c.y);
    c.w = cast(float)(cast(int)c.w);
    c.h = cast(float)(cast(int)c.h);

    nk_unify(&v, &c, bounds.x, bounds.y, bounds.x + bounds.w, bounds.y + bounds.h);
    if (!nk_intersect(c.x, c.y, c.w, c.h, bounds.x, bounds.y, bounds.w, bounds.h))
        return NK_WIDGET_INVALID;
    if (!NK_INBOX(in_.mouse.pos.x, in_.mouse.pos.y, v.x, v.y, v.w, v.h))
        return NK_WIDGET_ROM;
    return NK_WIDGET_VALID;
}
nk_widget_layout_states nk_widget_fitting(nk_rect* bounds, nk_context* ctx, nk_vec2 item_padding)
{
    /* update the bounds to stand without padding  */
    nk_widget_layout_states state = void;
    NK_UNUSED(item_padding);

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return NK_WIDGET_INVALID;

    state = nk_widget(bounds, ctx);
    return state;
}
void nk_spacing(nk_context* ctx, int cols)
{
    nk_window* win = void;
    nk_panel* layout = void;
    nk_rect none = void;
    int i = void, index = void, rows = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    /* spacing over row boundaries */
    win = ctx.current;
    layout = win.layout;
    index = (layout.row.index + cols) % layout.row.columns;
    rows = (layout.row.index + cols) / layout.row.columns;
    if (rows) {
        for (i = 0; i < rows; ++i)
            nk_panel_alloc_row(ctx, win);
        cols = index;
    }
    /* non table layout need to allocate space */
    if (layout.row.type != NK_LAYOUT_DYNAMIC_FIXED &&
        layout.row.type != NK_LAYOUT_STATIC_FIXED) {
        for (i = 0; i < cols; ++i)
            nk_panel_alloc_space(&none, ctx);
    } layout.row.index = index;
}

