module nuklear.nuklear_slider;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              SLIDER
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_widget;
import nuklear.nuklear_input;
import nuklear.nuklear_draw;
import nuklear.nuklear_button;

float nk_slider_behavior(nk_flags* state, nk_rect* logical_cursor, nk_rect* visual_cursor, nk_input* in_, nk_rect bounds, float slider_min, float slider_max, float slider_value, float slider_step, float slider_steps)
{
    int left_mouse_down = void;
    int left_mouse_click_in_cursor = void;

    /* check if visual cursor is being dragged */
    nk_widget_state_reset(state);
    left_mouse_down = in_ && in_.mouse.buttons[NK_BUTTON_LEFT].down;
    left_mouse_click_in_cursor = in_ && nk_input_has_mouse_click_down_in_rect(in_,
            NK_BUTTON_LEFT, *visual_cursor, nk_true);

    if (left_mouse_down && left_mouse_click_in_cursor) {
        float ratio = 0;
        const(float) d = in_.mouse.pos.x - (visual_cursor.x+visual_cursor.w*0.5f);
        const(float) pxstep = bounds.w / slider_steps;

        /* only update value if the next slider step is reached */
        *state = NK_WIDGET_STATE_ACTIVE;
        if (nk_abs(d) >= pxstep) {
            const(float) steps = cast(float)(cast(int)(nk_abs(d) / pxstep));
            slider_value += (d > 0) ? (slider_step*steps) : -(slider_step*steps);
            slider_value = nk_clamp(slider_min, slider_value, slider_max);
            ratio = (slider_value - slider_min)/slider_step;
            logical_cursor.x = bounds.x + (logical_cursor.w * ratio);
            in_.mouse.buttons[NK_BUTTON_LEFT].clicked_pos.x = logical_cursor.x;
        }
    }

    /* slider widget state */
    if (nk_input_is_mouse_hovering_rect(in_, bounds))
        *state = NK_WIDGET_STATE_HOVERED;
    if (*state & NK_WIDGET_STATE_HOVER &&
        !nk_input_is_mouse_prev_hovering_rect(in_, bounds))
        *state |= NK_WIDGET_STATE_ENTERED;
    else if (nk_input_is_mouse_prev_hovering_rect(in_, bounds))
        *state |= NK_WIDGET_STATE_LEFT;
    return slider_value;
}
void nk_draw_slider(nk_command_buffer* out_, nk_flags state, const(nk_style_slider)* style, const(nk_rect)* bounds, const(nk_rect)* visual_cursor, float min, float value, float max)
{
    nk_rect fill = void;
    nk_rect bar = void;
    const(nk_style_item)* background = void;

    /* select correct slider images/colors */
    nk_color bar_color = void;
    const(nk_style_item)* cursor = void;

    cast(void)(min);
    cast(void)(max);
    cast(void)(value);

    if (state & NK_WIDGET_STATE_ACTIVED) {
        background = &style.active;
        bar_color = style.bar_active;
        cursor = &style.cursor_active;
    } else if (state & NK_WIDGET_STATE_HOVER) {
        background = &style.hover;
        bar_color = style.bar_hover;
        cursor = &style.cursor_hover;
    } else {
        background = &style.normal;
        bar_color = style.bar_normal;
        cursor = &style.cursor_normal;
    }
    /* calculate slider background bar */
    bar.x = bounds.x;
    bar.y = (visual_cursor.y + visual_cursor.h/2) - bounds.h/12;
    bar.w = bounds.w;
    bar.h = bounds.h/6;

    /* filled background bar style */
    fill.w = (visual_cursor.x + (visual_cursor.w/2.0f)) - bar.x;
    fill.x = bar.x;
    fill.y = bar.y;
    fill.h = bar.h;

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

    /* draw slider bar */
    nk_fill_rect(out_, bar, style.rounding, bar_color);
    nk_fill_rect(out_, fill, style.rounding, style.bar_filled);

    /* draw cursor */
    if (cursor.type == NK_STYLE_ITEM_IMAGE)
        nk_draw_image(out_, *visual_cursor, &cursor.data.image, nk_white);
    else
        nk_fill_circle(out_, *visual_cursor, cursor.data.color);
}
float nk_do_slider(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, float min, float val, float max, float step, const(nk_style_slider)* style, nk_input* in_, const(nk_user_font)* font)
{
    float slider_range = void;
    float slider_min = void;
    float slider_max = void;
    float slider_value = void;
    float slider_steps = void;
    float cursor_offset = void;

    nk_rect visual_cursor = void;
    nk_rect logical_cursor = void;

    assert(style);
    assert(out_);
    if (!out_ || !style)
        return 0;

    /* remove padding from slider bounds */
    bounds.x = bounds.x + style.padding.x;
    bounds.y = bounds.y + style.padding.y;
    bounds.h = nk_max(bounds.h, 2*style.padding.y);
    bounds.w = nk_max(bounds.w, 2*style.padding.x + style.cursor_size.x);
    bounds.w -= 2 * style.padding.x;
    bounds.h -= 2 * style.padding.y;

    /* optional buttons */
    if (style.show_buttons) {
        nk_flags ws = void;
        nk_rect button = void;
        button.y = bounds.y;
        button.w = bounds.h;
        button.h = bounds.h;

        /* decrement button */
        button.x = bounds.x;
        if (nk_do_button_symbol(&ws, out_, button, style.dec_symbol, NK_BUTTON_DEFAULT,
            &style.dec_button, in_, font))
            val -= step;

        /* increment button */
        button.x = (bounds.x + bounds.w) - button.w;
        if (nk_do_button_symbol(&ws, out_, button, style.inc_symbol, NK_BUTTON_DEFAULT,
            &style.inc_button, in_, font))
            val += step;

        bounds.x = bounds.x + button.w + style.spacing.x;
        bounds.w = bounds.w - (2*button.w + 2*style.spacing.x);
    }

    /* remove one cursor size to support visual cursor */
    bounds.x += style.cursor_size.x*0.5f;
    bounds.w -= style.cursor_size.x;

    /* make sure the provided values are correct */
    slider_max = nk_max(min, max);
    slider_min = nk_min(min, max);
    slider_value = nk_clamp(slider_min, val, slider_max);
    slider_range = slider_max - slider_min;
    slider_steps = slider_range / step;
    cursor_offset = (slider_value - slider_min) / step;

    /* calculate cursor
    Basically you have two cursors. One for visual representation and interaction
    and one for updating the actual cursor value. */
    logical_cursor.h = bounds.h;
    logical_cursor.w = bounds.w / slider_steps;
    logical_cursor.x = bounds.x + (logical_cursor.w * cursor_offset);
    logical_cursor.y = bounds.y;

    visual_cursor.h = style.cursor_size.y;
    visual_cursor.w = style.cursor_size.x;
    visual_cursor.y = (bounds.y + bounds.h*0.5f) - visual_cursor.h*0.5f;
    visual_cursor.x = logical_cursor.x - visual_cursor.w*0.5f;

    slider_value = nk_slider_behavior(state, &logical_cursor, &visual_cursor,
        in_, bounds, slider_min, slider_max, slider_value, step, slider_steps);
    visual_cursor.x = logical_cursor.x - visual_cursor.w*0.5f;

    /* draw slider */
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_slider(out_, *state, style, &bounds, &visual_cursor, slider_min, slider_value, slider_max);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return slider_value;
}
nk_bool nk_slider_float(nk_context* ctx, float min_value, float* value, float max_value, float value_step)
{
    nk_window* win = void;
    nk_panel* layout = void;
    nk_input* in_ = void;
    const(nk_style)* style = void;

    int ret = 0;
    float old_value = void;
    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    assert(value);
    if (!ctx || !ctx.current || !ctx.current.layout || !value)
        return cast(nk_bool)ret;

    win = ctx.current;
    style = &ctx.style;
    layout = win.layout;

    state = nk_widget(&bounds, ctx);
    if (!state) return cast(nk_bool)ret;
    in_ = (/*state == NK_WIDGET_ROM || */ layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;

    old_value = *value;
    *value = nk_do_slider(&ctx.last_widget_state, &win.buffer, bounds, min_value,
                old_value, max_value, value_step, &style.slider, in_, style.font);
    return (old_value > *value || old_value < *value);
}
float nk_slide_float(nk_context* ctx, float min, float val, float max, float step)
{
    nk_slider_float(ctx, min, &val, max, step); return val;
}
int nk_slide_int(nk_context* ctx, int min, int val, int max, int step)
{
    float value = cast(float)val;
    nk_slider_float(ctx, cast(float)min, &value, cast(float)max, cast(float)step);
    return cast(int)value;
}
nk_bool nk_slider_int(nk_context* ctx, int min, int* val, int max, int step)
{
    int ret = void;
    float value = cast(float)*val;
    ret = nk_slider_float(ctx, cast(float)min, &value, cast(float)max, cast(float)step);
    *val =  cast(int)value;
    return cast(nk_bool)ret;
}

