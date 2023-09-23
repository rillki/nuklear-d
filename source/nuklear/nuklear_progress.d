module nuklear.nuklear_progress;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          PROGRESS
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

nk_size nk_progress_behavior(nk_flags* state, nk_input* in_, nk_rect r, nk_rect cursor, nk_size max, nk_size value, nk_bool modifiable)
{
    int left_mouse_down = 0;
    int left_mouse_click_in_cursor = 0;

    nk_widget_state_reset(state);
    if (!in_ || !modifiable) return value;
    left_mouse_down = in_ && in_.mouse.buttons[NK_BUTTON_LEFT].down;
    left_mouse_click_in_cursor = in_ && nk_input_has_mouse_click_down_in_rect(in_,
            NK_BUTTON_LEFT, cursor, nk_true);
    if (nk_input_is_mouse_hovering_rect(in_, r))
        *state = NK_WIDGET_STATE_HOVERED;

    if (in_ && left_mouse_down && left_mouse_click_in_cursor) {
        if (left_mouse_down && left_mouse_click_in_cursor) {
            float ratio = NK_MAX(0, cast(float)(in_.mouse.pos.x - cursor.x)) / cast(float)cursor.w;
            value = cast(nk_size)NK_CLAMP(0, cast(float)max * ratio, cast(float)max);
            in_.mouse.buttons[NK_BUTTON_LEFT].clicked_pos.x = cursor.x + cursor.w/2.0f;
            *state |= NK_WIDGET_STATE_ACTIVE;
        }
    }
    /* set progressbar widget state */
    if (*state & NK_WIDGET_STATE_HOVER && !nk_input_is_mouse_prev_hovering_rect(in_, r))
        *state |= NK_WIDGET_STATE_ENTERED;
    else if (nk_input_is_mouse_prev_hovering_rect(in_, r))
        *state |= NK_WIDGET_STATE_LEFT;
    return value;
}
void nk_draw_progress(nk_command_buffer* out_, nk_flags state, const(nk_style_progress)* style, const(nk_rect)* bounds, const(nk_rect)* scursor, nk_size value, nk_size max)
{
    const(nk_style_item)* background = void;
    const(nk_style_item)* cursor = void;

    cast(void)(max);
    cast(void)(value);

    /* select correct colors/images to draw */
    if (state & NK_WIDGET_STATE_ACTIVED) {
        background = &style.active;
        cursor = &style.cursor_active;
    } else if (state & NK_WIDGET_STATE_HOVER){
        background = &style.hover;
        cursor = &style.cursor_hover;
    } else {
        background = &style.normal;
        cursor = &style.cursor_normal;
    }

    /* draw background */
    switch(background.type) {
        case NK_STYLE_ITEM_IMAGE:
            nk_draw_image(out_, *bounds, &background.data.image, nk_white);
            break;
        case NK_STYLE_ITEM_NINE_SLICE:
            nk_draw_nine_slice(out_, *bounds, &background.data.slice, nk_white);
            break;
        case NK_STYLE_ITEM_COLOR:
            nk_fill_rect(out_, *bounds, style.rounding, background.data.color);
            nk_stroke_rect(out_, *bounds, style.rounding, style.border, style.border_color);
            break;
    default: break;}

    /* draw cursor */
    switch(cursor.type) {
        case NK_STYLE_ITEM_IMAGE:
            nk_draw_image(out_, *scursor, &cursor.data.image, nk_white);
            break;
        case NK_STYLE_ITEM_NINE_SLICE:
            nk_draw_nine_slice(out_, *scursor, &cursor.data.slice, nk_white);
            break;
        case NK_STYLE_ITEM_COLOR:
            nk_fill_rect(out_, *scursor, style.rounding, cursor.data.color);
            nk_stroke_rect(out_, *scursor, style.rounding, style.border, style.border_color);
            break;
    default: break;}
}
nk_size nk_do_progress(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, nk_size value, nk_size max, nk_bool modifiable, const(nk_style_progress)* style, nk_input* in_)
{
    float prog_scale = void;
    nk_size prog_value = void;
    nk_rect cursor = void;

    assert(style);
    assert(out_);
    if (!out_ || !style) return 0;

    /* calculate progressbar cursor */
    cursor.w = NK_MAX(bounds.w, 2 * style.padding.x + 2 * style.border);
    cursor.h = NK_MAX(bounds.h, 2 * style.padding.y + 2 * style.border);
    cursor = nk_pad_rect(bounds, nk_vec2(style.padding.x + style.border, style.padding.y + style.border));
    prog_scale = cast(float)value / cast(float)max;

    /* update progressbar */
    prog_value = NK_MIN(value, max);
    prog_value = nk_progress_behavior(state, in_, bounds, cursor,max, prog_value, modifiable);
    cursor.w = cursor.w * prog_scale;

    /* draw progressbar */
    if (style.draw_begin) style.draw_begin(out_, style.userdata);
    nk_draw_progress(out_, *state, style, &bounds, &cursor, value, max);
    if (style.draw_end) style.draw_end(out_, style.userdata);
    return prog_value;
}
nk_bool nk_progress(nk_context* ctx, nk_size* cur, nk_size max, nk_bool is_modifyable)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_style)* style = void;
    nk_input* in_ = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;
    nk_size old_value = void;

    assert(ctx);
    assert(cur);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !cur)
        return 0;

    win = ctx.current;
    style = &ctx.style;
    layout = win.layout;
    state = nk_widget(&bounds, ctx);
    if (!state) return 0;

    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? 0 : &ctx.input;
    old_value = *cur;
    *cur = nk_do_progress(&ctx.last_widget_state, &win.buffer, bounds,
            *cur, max, is_modifyable, &style.progress, in_);
    return (*cur != old_value);
}
nk_size nk_prog(nk_context* ctx, nk_size cur, nk_size max, nk_bool modifyable)
{
    nk_progress(ctx, &cur, max, modifyable);
    return cur;
}

