module nuklear.nuklear_color_picker;
extern(C) @nogc nothrow:
__gshared:

/* ==============================================================
 *
 *                          COLOR PICKER
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_color;
import nuklear.nuklear_button;
import nuklear.nuklear_input;
import nuklear.nuklear_draw;
import nuklear.nuklear_widget;

nk_bool nk_color_picker_behavior(nk_flags* state, const(nk_rect)* bounds, const(nk_rect)* matrix, const(nk_rect)* hue_bar, const(nk_rect)* alpha_bar, nk_colorf* color, const(nk_input)* in_)
{
    float[4] hsva = void;
    nk_bool value_changed = 0;
    nk_bool hsv_changed = 0;

    assert(state);
    assert(matrix);
    assert(hue_bar);
    assert(color);

    /* color matrix */
    nk_colorf_hsva_fv(hsva.ptr, *color);
    if (nk_button_behavior_(state, *matrix, in_, NK_BUTTON_REPEATER)) {
        hsva[1] = nk_saturate((in_.mouse.pos.x - matrix.x) / (matrix.w-1));
        hsva[2] = 1.0f - nk_saturate((in_.mouse.pos.y - matrix.y) / (matrix.h-1));
        value_changed = hsv_changed = 1;
    }
    /* hue bar */
    if (nk_button_behavior_(state, *hue_bar, in_, NK_BUTTON_REPEATER)) {
        hsva[0] = nk_saturate((in_.mouse.pos.y - hue_bar.y) / (hue_bar.h-1));
        value_changed = hsv_changed = 1;
    }
    /* alpha bar */
    if (alpha_bar) {
        if (nk_button_behavior_(state, *alpha_bar, in_, NK_BUTTON_REPEATER)) {
            hsva[3] = 1.0f - nk_saturate((in_.mouse.pos.y - alpha_bar.y) / (alpha_bar.h-1));
            value_changed = 1;
        }
    }

    nk_widget_state_reset(state);
    if (hsv_changed) {
        *color = nk_hsva_colorfv(hsva.ptr);
        *state = NK_WIDGET_STATE_ACTIVE;
    }
    if (value_changed) {
        color.a = hsva[3];
        *state = NK_WIDGET_STATE_ACTIVE;
    }
    /* set color picker widget state */
    if (nk_input_is_mouse_hovering_rect(in_, *bounds))
        *state = NK_WIDGET_STATE_HOVERED;
    if (*state & NK_WIDGET_STATE_HOVER && !nk_input_is_mouse_prev_hovering_rect(in_, *bounds))
        *state |= NK_WIDGET_STATE_ENTERED;
    else if (nk_input_is_mouse_prev_hovering_rect(in_, *bounds))
        *state |= NK_WIDGET_STATE_LEFT;
    return value_changed;
}
void nk_draw_color_picker(nk_command_buffer* o, const(nk_rect)* matrix, const(nk_rect)* hue_bar, const(nk_rect)* alpha_bar, nk_colorf col)
{
    enum nk_color black = {0,0,0,255};
    enum nk_color white = {255, 255, 255, 255};
    enum nk_color black_trans = {0,0,0,0};

    const(float) crosshair_size = 7.0f;
    nk_color temp = void;
    float[4] hsva = void;
    float line_y = void;
    int i = void;

    assert(o);
    assert(matrix);
    assert(hue_bar);

    /* draw hue bar */
    nk_colorf_hsva_fv(hsva.ptr, col);
    for (i = 0; i < 6; ++i) {
        enum nk_color[7] hue_colors = [
            nk_color(255, 0, 0, 255), nk_color(255,255,0,255), nk_color(0,255,0,255), nk_color(0, 255,255,255),
            nk_color(0,0,255,255), nk_color(255, 0, 255, 255), nk_color(255, 0, 0, 255)
        ];
        nk_fill_rect_multi_color(o,
            nk_rect(hue_bar.x, hue_bar.y + cast(float)i * (hue_bar.h/6.0f) + 0.5f,
                hue_bar.w, (hue_bar.h/6.0f) + 0.5f), hue_colors[i], hue_colors[i],
                hue_colors[i+1], hue_colors[i+1]);
    }
    line_y = cast(float)cast(int)(hue_bar.y + hsva[0] * matrix.h + 0.5f);
    nk_stroke_line(o, hue_bar.x-1, line_y, hue_bar.x + hue_bar.w + 2,
        line_y, 1, nk_rgb(255,255,255));

    /* draw alpha bar */
    if (alpha_bar) {
        float alpha = nk_saturate(col.a);
        line_y = cast(float)cast(int)(alpha_bar.y +  (1.0f - alpha) * matrix.h + 0.5f);

        nk_fill_rect_multi_color(o, *alpha_bar, white, white, black, black);
        nk_stroke_line(o, alpha_bar.x-1, line_y, alpha_bar.x + alpha_bar.w + 2,
            line_y, 1, nk_rgb(255,255,255));
    }

    /* draw color matrix */
    temp = nk_hsv_f(hsva[0], 1.0f, 1.0f);
    nk_fill_rect_multi_color(o, *matrix, white, temp, temp, white);
    nk_fill_rect_multi_color(o, *matrix, black_trans, black_trans, black, black);

    /* draw cross-hair */
    {nk_vec2 p = void; float S = hsva[1]; float V = hsva[2];
    p.x = cast(float)cast(int)(matrix.x + S * matrix.w);
    p.y = cast(float)cast(int)(matrix.y + (1.0f - V) * matrix.h);
    nk_stroke_line(o, p.x - crosshair_size, p.y, p.x-2, p.y, 1.0f, white);
    nk_stroke_line(o, p.x + crosshair_size + 1, p.y, p.x+3, p.y, 1.0f, white);
    nk_stroke_line(o, p.x, p.y + crosshair_size + 1, p.x, p.y+3, 1.0f, white);
    nk_stroke_line(o, p.x, p.y - crosshair_size, p.x, p.y-2, 1.0f, white);}
}
nk_bool nk_do_color_picker(nk_flags* state, nk_command_buffer* out_, nk_colorf* col, nk_color_format fmt, nk_rect bounds, nk_vec2 padding, const(nk_input)* in_, const(nk_user_font)* font)
{
    int ret = 0;
    nk_rect matrix = void;
    nk_rect hue_bar = void;
    nk_rect alpha_bar = void;
    float bar_w = void;

    assert(out_);
    assert(col);
    assert(state);
    assert(font);
    if (!out_ || !col || !state || !font)
        return cast(nk_bool)ret;

    bar_w = font.height;
    bounds.x += padding.x;
    bounds.y += padding.x;
    bounds.w -= 2 * padding.x;
    bounds.h -= 2 * padding.y;

    matrix.x = bounds.x;
    matrix.y = bounds.y;
    matrix.h = bounds.h;
    matrix.w = bounds.w - (3 * padding.x + 2 * bar_w);

    hue_bar.w = bar_w;
    hue_bar.y = bounds.y;
    hue_bar.h = matrix.h;
    hue_bar.x = matrix.x + matrix.w + padding.x;

    alpha_bar.x = hue_bar.x + hue_bar.w + padding.x;
    alpha_bar.y = bounds.y;
    alpha_bar.w = bar_w;
    alpha_bar.h = matrix.h;

    ret = nk_color_picker_behavior(state, &bounds, &matrix, &hue_bar,
        (fmt == NK_RGBA) ? &alpha_bar:null, col, in_);
    nk_draw_color_picker(out_, &matrix, &hue_bar, (fmt == NK_RGBA) ? &alpha_bar:null, *col);
    return cast(nk_bool)ret;
}
nk_bool nk_color_pick(nk_context* ctx, nk_colorf* color, nk_color_format fmt)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_style)* config = void;
    const(nk_input)* in_ = void;

    nk_widget_layout_states state = void;
    nk_rect bounds = void;

    assert(ctx);
    assert(color);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !color)
        return 0;

    win = ctx.current;
    config = &ctx.style;
    layout = win.layout;
    state = nk_widget(&bounds, ctx);
    if (!state) return 0;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_color_picker(&ctx.last_widget_state, &win.buffer, color, fmt, bounds,
                nk_vec2(0,0), in_, config.font);
}
nk_colorf nk_color_picker(nk_context* ctx, nk_colorf color, nk_color_format fmt)
{
    nk_color_pick(ctx, &color, fmt);
    return color;
}

