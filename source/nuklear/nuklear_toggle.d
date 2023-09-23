module nuklear.nuklear_toggle;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              TOGGLE
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_widget;
import nuklear.nuklear_draw;
import nuklear.nuklear_input;
import nuklear.nuklear_text;
import nuklear.nuklear_button;

nk_bool nk_toggle_behavior(const(nk_input)* in_, nk_rect select, nk_flags* state, nk_bool active)
{
    nk_widget_state_reset(state);
    if (nk_button_behavior_(state, select, in_, NK_BUTTON_DEFAULT)) {
        *state = NK_WIDGET_STATE_ACTIVE;
        active = !active;
    }
    if (*state & NK_WIDGET_STATE_HOVER && !nk_input_is_mouse_prev_hovering_rect(in_, select))
        *state |= NK_WIDGET_STATE_ENTERED;
    else if (nk_input_is_mouse_prev_hovering_rect(in_, select))
        *state |= NK_WIDGET_STATE_LEFT;
    return active;
}
void nk_draw_checkbox(nk_command_buffer* out_, nk_flags state, const(nk_style_toggle)* style, nk_bool active, const(nk_rect)* label, const(nk_rect)* selector, const(nk_rect)* cursors, const(char)* string, int len, const(nk_user_font)* font)
{
    const(nk_style_item)* background = void;
    const(nk_style_item)* cursor = void;
    nk_text text = void;

    /* select correct colors/images */
    if (state & NK_WIDGET_STATE_HOVER) {
        background = &style.hover;
        cursor = &style.cursor_hover;
        text.text = style.text_hover;
    } else if (state & NK_WIDGET_STATE_ACTIVED) {
        background = &style.hover;
        cursor = &style.cursor_hover;
        text.text = style.text_active;
    } else {
        background = &style.normal;
        cursor = &style.cursor_normal;
        text.text = style.text_normal;
    }

    /* draw background and cursor */
    if (background.type == NK_STYLE_ITEM_COLOR) {
        nk_fill_rect(out_, *selector, 0, style.border_color);
        nk_fill_rect(out_, nk_shrink_rect(*selector, style.border), 0, background.data.color);
    } else nk_draw_image(out_, *selector, &background.data.image, nk_white);
    if (active) {
        if (cursor.type == NK_STYLE_ITEM_IMAGE)
            nk_draw_image(out_, *cursors, &cursor.data.image, nk_white);
        else nk_fill_rect(out_, *cursors, 0, cursor.data.color);
    }

    text.padding.x = 0;
    text.padding.y = 0;
    text.background = style.text_background;
    nk_widget_text(out_, *label, string, len, &text, NK_TEXT_LEFT, font);
}
void nk_draw_option(nk_command_buffer* out_, nk_flags state, const(nk_style_toggle)* style, nk_bool active, const(nk_rect)* label, const(nk_rect)* selector, const(nk_rect)* cursors, const(char)* string, int len, const(nk_user_font)* font)
{
    const(nk_style_item)* background = void;
    const(nk_style_item)* cursor = void;
    nk_text text = void;

    /* select correct colors/images */
    if (state & NK_WIDGET_STATE_HOVER) {
        background = &style.hover;
        cursor = &style.cursor_hover;
        text.text = style.text_hover;
    } else if (state & NK_WIDGET_STATE_ACTIVED) {
        background = &style.hover;
        cursor = &style.cursor_hover;
        text.text = style.text_active;
    } else {
        background = &style.normal;
        cursor = &style.cursor_normal;
        text.text = style.text_normal;
    }

    /* draw background and cursor */
    if (background.type == NK_STYLE_ITEM_COLOR) {
        nk_fill_circle(out_, *selector, style.border_color);
        nk_fill_circle(out_, nk_shrink_rect(*selector, style.border), background.data.color);
    } else nk_draw_image(out_, *selector, &background.data.image, nk_white);
    if (active) {
        if (cursor.type == NK_STYLE_ITEM_IMAGE)
            nk_draw_image(out_, *cursors, &cursor.data.image, nk_white);
        else nk_fill_circle(out_, *cursors, cursor.data.color);
    }

    text.padding.x = 0;
    text.padding.y = 0;
    text.background = style.text_background;
    nk_widget_text(out_, *label, string, len, &text, NK_TEXT_LEFT, font);
}
nk_bool nk_do_toggle(nk_flags* state, nk_command_buffer* out_, nk_rect r, nk_bool* active, const(char)* str, int len, nk_toggle_type type, const(nk_style_toggle)* style, const(nk_input)* in_, const(nk_user_font)* font)
{
    int was_active = void;
    nk_rect bounds = void;
    nk_rect select = void;
    nk_rect cursor = void;
    nk_rect label = void;

    assert(style);
    assert(out_);
    assert(font);
    if (!out_ || !style || !font || !active)
        return 0;

    r.w = nk_max(r.w, font.height + 2 * style.padding.x);
    r.h = nk_max(r.h, font.height + 2 * style.padding.y);

    /* add additional touch padding for touch screen devices */
    bounds.x = r.x - style.touch_padding.x;
    bounds.y = r.y - style.touch_padding.y;
    bounds.w = r.w + 2 * style.touch_padding.x;
    bounds.h = r.h + 2 * style.touch_padding.y;

    /* calculate the selector space */
    select.w = font.height;
    select.h = select.w;
    select.y = r.y + r.h/2.0f - select.h/2.0f;
    select.x = r.x;

    /* calculate the bounds of the cursor inside the selector */
    cursor.x = select.x + style.padding.x + style.border;
    cursor.y = select.y + style.padding.y + style.border;
    cursor.w = select.w - (2 * style.padding.x + 2 * style.border);
    cursor.h = select.h - (2 * style.padding.y + 2 * style.border);

    /* label behind the selector */
    label.x = select.x + select.w + style.spacing;
    label.y = select.y;
    label.w = nk_max(r.x + r.w, label.x) - label.x;
    label.h = select.w;

    /* update selector */
    was_active = *active;
    *active = nk_toggle_behavior(in_, bounds, state, *active);

    /* draw selector */
    if (style.draw_begin)
        style.draw_begin(out_, cast(nk_handle)style.userdata);
    if (type == NK_TOGGLE_CHECK) {
        nk_draw_checkbox(out_, *state, style, *active, &label, &select, &cursor, str, len, font);
    } else {
        nk_draw_option(out_, *state, style, *active, &label, &select, &cursor, str, len, font);
    }
    if (style.draw_end)
        style.draw_end(out_, cast(nk_handle)style.userdata);
    return (was_active != *active);
}
/*----------------------------------------------------------------
 *
 *                          CHECKBOX
 *
 * --------------------------------------------------------------*/
nk_bool nk_check_text(nk_context* ctx, const(char)* text, int len, nk_bool active)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return active;

    win = ctx.current;
    style = &ctx.style;
    layout = win.layout;

    state = nk_widget(&bounds, ctx);
    if (!state) return active;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    nk_do_toggle(&ctx.last_widget_state, &win.buffer, bounds, &active,
        text, len, NK_TOGGLE_CHECK, &style.checkbox, in_, style.font);
    return active;
}
uint nk_check_flags_text(nk_context* ctx, const(char)* text, int len, uint flags, uint value)
{
    int old_active = void;
    assert(ctx);
    assert(text);
    if (!ctx || !text) return flags;
    old_active = cast(int)((flags & value) & value);
    if (nk_check_text(ctx, text, len, cast(nk_bool)old_active))
        flags |= value;
    else flags &= ~value;
    return flags;
}
nk_bool nk_checkbox_text(nk_context* ctx, const(char)* text, int len, nk_bool* active)
{
    int old_val = void;
    assert(ctx);
    assert(text);
    assert(active);
    if (!ctx || !text || !active) return 0;
    old_val = *active;
    *active = nk_check_text(ctx, text, len, *active);
    return old_val != *active;
}
nk_bool nk_checkbox_flags_text(nk_context* ctx, const(char)* text, int len, uint* flags, uint value)
{
    nk_bool active = void;
    assert(ctx);
    assert(text);
    assert(flags);
    if (!ctx || !text || !flags) return 0;

    active = cast(int)(cast(nk_bool)(*flags & value) & value);
    if (nk_checkbox_text(ctx, text, len, &active)) {
        if (active) *flags |= value;
        else *flags &= ~value;
        return 1;
    }
    return 0;
}
nk_bool nk_check_label(nk_context* ctx, const(char)* label, nk_bool active)
{
    return nk_check_text(ctx, label, nk_strlen(label), active);
}
uint nk_check_flags_label(nk_context* ctx, const(char)* label, uint flags, uint value)
{
    return nk_check_flags_text(ctx, label, nk_strlen(label), flags, value);
}
nk_bool nk_checkbox_label(nk_context* ctx, const(char)* label, nk_bool* active)
{
    return nk_checkbox_text(ctx, label, nk_strlen(label), active);
}
nk_bool nk_checkbox_flags_label(nk_context* ctx, const(char)* label, uint* flags, uint value)
{
    return nk_checkbox_flags_text(ctx, label, nk_strlen(label), flags, value);
}
/*----------------------------------------------------------------
 *
 *                          OPTION
 *
 * --------------------------------------------------------------*/
nk_bool nk_option_text(nk_context* ctx, const(char)* text, int len, nk_bool is_active)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return is_active;

    win = ctx.current;
    style = &ctx.style;
    layout = win.layout;

    state = nk_widget(&bounds, ctx);
    if (!state) return cast(nk_bool)state;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    nk_do_toggle(&ctx.last_widget_state, &win.buffer, bounds, &is_active,
        text, len, NK_TOGGLE_OPTION, &style.option, in_, style.font);
    return is_active;
}
nk_bool nk_radio_text(nk_context* ctx, const(char)* text, int len, nk_bool* active)
{
    int old_value = void;
    assert(ctx);
    assert(text);
    assert(active);
    if (!ctx || !text || !active) return 0;
    old_value = *active;
    *active = nk_option_text(ctx, text, len, cast(nk_bool)old_value);
    return old_value != *active;
}
nk_bool nk_option_label(nk_context* ctx, const(char)* label, nk_bool active)
{
    return nk_option_text(ctx, label, nk_strlen(label), active);
}
nk_bool nk_radio_label(nk_context* ctx, const(char)* label, nk_bool* active)
{
    return nk_radio_text(ctx, label, nk_strlen(label), active);
}

