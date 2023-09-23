module nuklear.nuklear_selectable;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              SELECTABLE
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_color;
import nuklear.nuklear_draw;
import nuklear.nuklear_text;
import nuklear.nuklear_button;
import nuklear.nuklear_widget;

void nk_draw_selectable(nk_command_buffer* out_, nk_flags state, const(nk_style_selectable)* style, nk_bool active, const(nk_rect)* bounds, const(nk_rect)* icon, const(nk_image)* img, nk_symbol_type sym, const(char)* string, int len, nk_flags align_, const(nk_user_font)* font)
{
    const(nk_style_item)* background = void;
    nk_text text = void;
    text.padding = style.padding;

    /* select correct colors/images */
    if (!active) {
        if (state & NK_WIDGET_STATE_ACTIVED) {
            background = &style.pressed;
            text.text = style.text_pressed;
        } else if (state & NK_WIDGET_STATE_HOVER) {
            background = &style.hover;
            text.text = style.text_hover;
        } else {
            background = &style.normal;
            text.text = style.text_normal;
        }
    } else {
        if (state & NK_WIDGET_STATE_ACTIVED) {
            background = &style.pressed_active;
            text.text = style.text_pressed_active;
        } else if (state & NK_WIDGET_STATE_HOVER) {
            background = &style.hover_active;
            text.text = style.text_hover_active;
        } else {
            background = &style.normal_active;
            text.text = style.text_normal_active;
        }
    }
    /* draw selectable background and text */
    switch (background.type) {
        case NK_STYLE_ITEM_IMAGE:
            text.background = nk_rgba(0, 0, 0, 0);
            nk_draw_image(out_, *bounds, &background.data.image, nk_white);
            break;
        case NK_STYLE_ITEM_NINE_SLICE:
            text.background = nk_rgba(0, 0, 0, 0);
            nk_draw_nine_slice(out_, *bounds, &background.data.slice, nk_white);
            break;
        case NK_STYLE_ITEM_COLOR:
            text.background = background.data.color;
            nk_fill_rect(out_, *bounds, style.rounding, background.data.color);
            break;
    default: break;}
    if (icon) {
        if (img) nk_draw_image(out_, *icon, img, nk_white);
        else nk_draw_symbol(out_, sym, *icon, text.background, text.text, 1, font);
    }
    nk_widget_text(out_, *bounds, string, len, &text, align_, font);
}
nk_bool nk_do_selectable(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, const(char)* str, int len, nk_flags align_, nk_bool* value, const(nk_style_selectable)* style, const(nk_input)* in_, const(nk_user_font)* font)
{
    int old_value = void;
    nk_rect touch = void;

    assert(state);
    assert(out_);
    assert(str);
    assert(len);
    assert(value);
    assert(style);
    assert(font);

    if (!state || !out_ || !str || !len || !value || !style || !font) return 0;
    old_value = *value;

    /* remove padding */
    touch.x = bounds.x - style.touch_padding.x;
    touch.y = bounds.y - style.touch_padding.y;
    touch.w = bounds.w + style.touch_padding.x * 2;
    touch.h = bounds.h + style.touch_padding.y * 2;

    /* update button */
    if (nk_button_behavior_(state, touch, in_, NK_BUTTON_DEFAULT))
        *value = !(*value);

    /* draw selectable */
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_selectable(out_, *state, style, *value, &bounds, null, null, NK_SYMBOL_NONE, str, len, align_, font);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return old_value != *value;
}
nk_bool nk_do_selectable_image(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, const(char)* str, int len, nk_flags align_, nk_bool* value, const(nk_image)* img, const(nk_style_selectable)* style, const(nk_input)* in_, const(nk_user_font)* font)
{
    nk_bool old_value = void;
    nk_rect touch = void;
    nk_rect icon = void;

    assert(state);
    assert(out_);
    assert(str);
    assert(len);
    assert(value);
    assert(style);
    assert(font);

    if (!state || !out_ || !str || !len || !value || !style || !font) return 0;
    old_value = *value;

    /* toggle behavior */
    touch.x = bounds.x - style.touch_padding.x;
    touch.y = bounds.y - style.touch_padding.y;
    touch.w = bounds.w + style.touch_padding.x * 2;
    touch.h = bounds.h + style.touch_padding.y * 2;
    if (nk_button_behavior_(state, touch, in_, NK_BUTTON_DEFAULT))
        *value = !(*value);

    icon.y = bounds.y + style.padding.y;
    icon.w = icon.h = bounds.h - 2 * style.padding.y;
    if (align_ & NK_TEXT_ALIGN_LEFT) {
        icon.x = (bounds.x + bounds.w) - (2 * style.padding.x + icon.w);
        icon.x = nk_max(icon.x, 0);
    } else icon.x = bounds.x + 2 * style.padding.x;

    icon.x += style.image_padding.x;
    icon.y += style.image_padding.y;
    icon.w -= 2 * style.image_padding.x;
    icon.h -= 2 * style.image_padding.y;

    /* draw selectable */
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_selectable(out_, *state, style, *value, &bounds, &icon, img, NK_SYMBOL_NONE, str, len, align_, font);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return old_value != *value;
}
nk_bool nk_do_selectable_symbol(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, const(char)* str, int len, nk_flags align_, nk_bool* value, nk_symbol_type sym, const(nk_style_selectable)* style, const(nk_input)* in_, const(nk_user_font)* font)
{
    int old_value = void;
    nk_rect touch = void;
    nk_rect icon = void;

    assert(state);
    assert(out_);
    assert(str);
    assert(len);
    assert(value);
    assert(style);
    assert(font);

    if (!state || !out_ || !str || !len || !value || !style || !font) return 0;
    old_value = *value;

    /* toggle behavior */
    touch.x = bounds.x - style.touch_padding.x;
    touch.y = bounds.y - style.touch_padding.y;
    touch.w = bounds.w + style.touch_padding.x * 2;
    touch.h = bounds.h + style.touch_padding.y * 2;
    if (nk_button_behavior_(state, touch, in_, NK_BUTTON_DEFAULT))
        *value = !(*value);

    icon.y = bounds.y + style.padding.y;
    icon.w = icon.h = bounds.h - 2 * style.padding.y;
    if (align_ & NK_TEXT_ALIGN_LEFT) {
        icon.x = (bounds.x + bounds.w) - (2 * style.padding.x + icon.w);
        icon.x = nk_max(icon.x, 0);
    } else icon.x = bounds.x + 2 * style.padding.x;

    icon.x += style.image_padding.x;
    icon.y += style.image_padding.y;
    icon.w -= 2 * style.image_padding.x;
    icon.h -= 2 * style.image_padding.y;

    /* draw selectable */
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_selectable(out_, *state, style, *value, &bounds, &icon, null, sym, str, len, align_, font);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return old_value != *value;
}

nk_bool nk_selectable_text(nk_context* ctx, const(char)* str, int len, nk_flags align_, nk_bool* value)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_widget_layout_states state = void;
    nk_rect bounds = void;

    assert(ctx);
    assert(value);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !value)
        return 0;

    win = ctx.current;
    layout = win.layout;
    style = &ctx.style;

    state = nk_widget(&bounds, ctx);
    if (!state) return false;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_selectable(&ctx.last_widget_state, &win.buffer, bounds,
                str, len, align_, value, &style.selectable, in_, style.font);
}
nk_bool nk_selectable_image_text(nk_context* ctx, nk_image img, const(char)* str, int len, nk_flags align_, nk_bool* value)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_widget_layout_states state = void;
    nk_rect bounds = void;

    assert(ctx);
    assert(value);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !value)
        return 0;

    win = ctx.current;
    layout = win.layout;
    style = &ctx.style;

    state = nk_widget(&bounds, ctx);
    if (!state) return false;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_selectable_image(&ctx.last_widget_state, &win.buffer, bounds,
                str, len, align_, value, &img, &style.selectable, in_, style.font);
}
nk_bool nk_selectable_symbol_text(nk_context* ctx, nk_symbol_type sym, const(char)* str, int len, nk_flags align_, nk_bool* value)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;
    const(nk_style)* style = void;

    nk_widget_layout_states state = void;
    nk_rect bounds = void;

    assert(ctx);
    assert(value);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout || !value)
        return 0;

    win = ctx.current;
    layout = win.layout;
    style = &ctx.style;

    state = nk_widget(&bounds, ctx);
    if (!state) return false;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_selectable_symbol(&ctx.last_widget_state, &win.buffer, bounds,
                str, len, align_, value, sym, &style.selectable, in_, style.font);
}
nk_bool nk_selectable_symbol_label(nk_context* ctx, nk_symbol_type sym, const(char)* title, nk_flags align_, nk_bool* value)
{
    return nk_selectable_symbol_text(ctx, sym, title, nk_strlen(title), align_, value);
}
nk_bool nk_select_text(nk_context* ctx, const(char)* str, int len, nk_flags align_, nk_bool value)
{
    nk_selectable_text(ctx, str, len, align_, &value);return value;
}
nk_bool nk_selectable_label(nk_context* ctx, const(char)* str, nk_flags align_, nk_bool* value)
{
    return nk_selectable_text(ctx, str, nk_strlen(str), align_, value);
}
nk_bool nk_selectable_image_label(nk_context* ctx, nk_image img, const(char)* str, nk_flags align_, nk_bool* value)
{
    return nk_selectable_image_text(ctx, img, str, nk_strlen(str), align_, value);
}
nk_bool nk_select_label(nk_context* ctx, const(char)* str, nk_flags align_, nk_bool value)
{
    nk_selectable_text(ctx, str, nk_strlen(str), align_, &value);return value;
}
nk_bool nk_select_image_label(nk_context* ctx, nk_image img, const(char)* str, nk_flags align_, nk_bool value)
{
    nk_selectable_image_text(ctx, img, str, nk_strlen(str), align_, &value);return value;
}
nk_bool nk_select_image_text(nk_context* ctx, nk_image img, const(char)* str, int len, nk_flags align_, nk_bool value)
{
    nk_selectable_image_text(ctx, img, str, len, align_, &value);return value;
}
nk_bool nk_select_symbol_text(nk_context* ctx, nk_symbol_type sym, const(char)* title, int title_len, nk_flags align_, nk_bool value)
{
    nk_selectable_symbol_text(ctx, sym, title, title_len, align_, &value);return value;
}
nk_bool nk_select_symbol_label(nk_context* ctx, nk_symbol_type sym, const(char)* title, nk_flags align_, nk_bool value)
{
    return nk_select_symbol_text(ctx, sym, title, nk_strlen(title), align_, value);
}

