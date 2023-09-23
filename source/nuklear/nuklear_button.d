module nuklear.nuklear_button;
extern(C) @nogc nothrow:
__gshared:

/* ==============================================================
 *
 *                          BUTTON
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_text;
import nuklear.nuklear_draw;
import nuklear.nuklear_input;
import nuklear.nuklear_style;
import nuklear.nuklear_widget;

void nk_draw_symbol(nk_command_buffer* out_, nk_symbol_type type, nk_rect content, nk_color background, nk_color foreground, float border_width, const(nk_user_font)* font)
{
    switch (type) {
    case NK_SYMBOL_X:
    case NK_SYMBOL_UNDERSCORE:
    case NK_SYMBOL_PLUS:
    case NK_SYMBOL_MINUS: {
        /* single character text symbol */
        const(char)* X = (type == NK_SYMBOL_X) ? "x":
            (type == NK_SYMBOL_UNDERSCORE) ? "_":
            (type == NK_SYMBOL_PLUS) ? "+": "-";
        nk_text text = void;
        text.padding = nk_vec2(0,0);
        text.background = background;
        text.text = foreground;
        nk_widget_text(out_, content, X, 1, &text, NK_TEXT_CENTERED, font);
    } break;
    case NK_SYMBOL_CIRCLE_SOLID:
    case NK_SYMBOL_CIRCLE_OUTLINE:
    case NK_SYMBOL_RECT_SOLID:
    case NK_SYMBOL_RECT_OUTLINE: {
        /* simple empty/filled shapes */
        if (type == NK_SYMBOL_RECT_SOLID || type == NK_SYMBOL_RECT_OUTLINE) {
            nk_fill_rect(out_, content,  0, foreground);
            if (type == NK_SYMBOL_RECT_OUTLINE)
                nk_fill_rect(out_, nk_shrink_rect(content, border_width), 0, background);
        } else {
            nk_fill_circle(out_, content, foreground);
            if (type == NK_SYMBOL_CIRCLE_OUTLINE)
                nk_fill_circle(out_, nk_shrink_rect(content, 1), background);
        }
    } break;
    case NK_SYMBOL_TRIANGLE_UP:
    case NK_SYMBOL_TRIANGLE_DOWN:
    case NK_SYMBOL_TRIANGLE_LEFT:
    case NK_SYMBOL_TRIANGLE_RIGHT: {
        nk_heading heading = void;
        nk_vec2[3] points = void;
        heading = (type == NK_SYMBOL_TRIANGLE_RIGHT) ? NK_RIGHT :
            (type == NK_SYMBOL_TRIANGLE_LEFT) ? NK_LEFT:
            (type == NK_SYMBOL_TRIANGLE_UP) ? NK_UP: NK_DOWN;
        nk_triangle_from_direction(points.ptr, content, 0, 0, heading);
        nk_fill_triangle(out_, points[0].x, points[0].y, points[1].x, points[1].y,
            points[2].x, points[2].y, foreground);
    } break;
    default:
    case NK_SYMBOL_NONE:
    case NK_SYMBOL_MAX: break;
    }
}

pragma(mangle, "nk_button_behavior")
nk_bool nk_button_behavior_(nk_flags* state, nk_rect r, const(nk_input)* i, nk_button_behavior behavior)
{
    int ret = 0;
    nk_widget_state_reset(state);
    if (!i) return 0;
    if (nk_input_is_mouse_hovering_rect(i, r)) {
        *state = NK_WIDGET_STATE_HOVERED;
        if (nk_input_is_mouse_down(i, NK_BUTTON_LEFT))
            *state = NK_WIDGET_STATE_ACTIVE;
        if (nk_input_has_mouse_click_in_button_rect(i, NK_BUTTON_LEFT, r)) {
            version (NK_BUTTON_TRIGGER_ON_RELEASE) {
                ret = (behavior != NK_BUTTON_DEFAULT) ?
                    nk_input_is_mouse_down(i, NK_BUTTON_LEFT):
                    nk_input_is_mouse_released(i, NK_BUTTON_LEFT);
            } else {
                ret = (behavior != NK_BUTTON_DEFAULT) ?
                    nk_input_is_mouse_down(i, NK_BUTTON_LEFT):
                    nk_input_is_mouse_pressed(i, NK_BUTTON_LEFT);
            }
        }
    }
    if (*state & NK_WIDGET_STATE_HOVER && !nk_input_is_mouse_prev_hovering_rect(i, r))
        *state |= NK_WIDGET_STATE_ENTERED;
    else if (nk_input_is_mouse_prev_hovering_rect(i, r))
        *state |= NK_WIDGET_STATE_LEFT;
    return cast(nk_bool)ret;
}

const(nk_style_item)* nk_draw_button(nk_command_buffer* out_, const(nk_rect)* bounds, nk_flags state, const(nk_style_button)* style)
{
    const(nk_style_item)* background = void;
    if (state & NK_WIDGET_STATE_HOVER)
        background = &style.hover;
    else if (state & NK_WIDGET_STATE_ACTIVED)
        background = &style.active;
    else background = &style.normal;

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
    return background;
}
nk_bool nk_do_button(nk_flags* state, nk_command_buffer* out_, nk_rect r, const(nk_style_button)* style, const(nk_input)* in_, nk_button_behavior behavior, nk_rect* content)
{
    nk_rect bounds = void;
    assert(style);
    assert(state);
    assert(out_);
    if (!out_ || !style)
        return nk_false;

    /* calculate button content space */
    content.x = r.x + style.padding.x + style.border + style.rounding;
    content.y = r.y + style.padding.y + style.border + style.rounding;
    content.w = r.w - (2 * style.padding.x + style.border + style.rounding*2);
    content.h = r.h - (2 * style.padding.y + style.border + style.rounding*2);

    /* execute button behavior */
    bounds.x = r.x - style.touch_padding.x;
    bounds.y = r.y - style.touch_padding.y;
    bounds.w = r.w + 2 * style.touch_padding.x;
    bounds.h = r.h + 2 * style.touch_padding.y;
    return nk_button_behavior_(state, bounds, in_, behavior);
}
void nk_draw_button_text(nk_command_buffer* out_, const(nk_rect)* bounds, const(nk_rect)* content, nk_flags state, const(nk_style_button)* style, const(char)* txt, int len, nk_flags text_alignment, const(nk_user_font)* font)
{
    nk_text text = void;
    const(nk_style_item)* background = void;
    background = nk_draw_button(out_, bounds, state, style);

    /* select correct colors/images */
    if (background.type == NK_STYLE_ITEM_COLOR)
        text.background = background.data.color;
    else text.background = style.text_background;
    if (state & NK_WIDGET_STATE_HOVER)
        text.text = style.text_hover;
    else if (state & NK_WIDGET_STATE_ACTIVED)
        text.text = style.text_active;
    else text.text = style.text_normal;

    text.padding = nk_vec2(0,0);
    nk_widget_text(out_, *content, txt, len, &text, text_alignment, font);
}
nk_bool nk_do_button_text(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, const(char)* string, int len, nk_flags align_, nk_button_behavior behavior, const(nk_style_button)* style, const(nk_input)* in_, const(nk_user_font)* font)
{
    nk_rect content = void;
    int ret = nk_false;

    assert(state);
    assert(style);
    assert(out_);
    assert(string);
    assert(font);
    if (!out_ || !style || !font || !string)
        return nk_false;

    ret = nk_do_button(state, out_, bounds, style, in_, behavior, &content);
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_button_text(out_, &bounds, &content, *state, style, string, len, align_, font);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return cast(nk_bool)ret;
}
void nk_draw_button_symbol(nk_command_buffer* out_, const(nk_rect)* bounds, const(nk_rect)* content, nk_flags state, const(nk_style_button)* style, nk_symbol_type type, const(nk_user_font)* font)
{
    nk_color sym = void, bg = void;
    const(nk_style_item)* background = void;

    /* select correct colors/images */
    background = nk_draw_button(out_, bounds, state, style);
    if (background.type == NK_STYLE_ITEM_COLOR)
        bg = background.data.color;
    else bg = style.text_background;

    if (state & NK_WIDGET_STATE_HOVER)
        sym = style.text_hover;
    else if (state & NK_WIDGET_STATE_ACTIVED)
        sym = style.text_active;
    else sym = style.text_normal;
    nk_draw_symbol(out_, type, *content, bg, sym, 1, font);
}
nk_bool nk_do_button_symbol(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, nk_symbol_type symbol, nk_button_behavior behavior, const(nk_style_button)* style, const(nk_input)* in_, const(nk_user_font)* font)
{
    int ret = void;
    nk_rect content = void;

    assert(state);
    assert(style);
    assert(font);
    assert(out_);
    if (!out_ || !style || !font || !state)
        return nk_false;

    ret = nk_do_button(state, out_, bounds, style, in_, behavior, &content);
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_button_symbol(out_, &bounds, &content, *state, style, symbol, font);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return cast(nk_bool)ret;
}
void nk_draw_button_image(nk_command_buffer* out_, const(nk_rect)* bounds, const(nk_rect)* content, nk_flags state, const(nk_style_button)* style, const(nk_image)* img)
{
    nk_draw_button(out_, bounds, state, style);
    nk_draw_image(out_, *content, img, nk_white);
}
nk_bool nk_do_button_image(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, nk_image img, nk_button_behavior b, const(nk_style_button)* style, const(nk_input)* in_)
{
    int ret = void;
    nk_rect content = void;

    assert(state);
    assert(style);
    assert(out_);
    if (!out_ || !style || !state)
        return nk_false;

    ret = nk_do_button(state, out_, bounds, style, in_, b, &content);
    content.x += style.image_padding.x;
    content.y += style.image_padding.y;
    content.w -= 2 * style.image_padding.x;
    content.h -= 2 * style.image_padding.y;

    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_button_image(out_, &bounds, &content, *state, style, &img);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return cast(nk_bool)ret;
}
void nk_draw_button_text_symbol(nk_command_buffer* out_, const(nk_rect)* bounds, const(nk_rect)* label, const(nk_rect)* symbol, nk_flags state, const(nk_style_button)* style, const(char)* str, int len, nk_symbol_type type, const(nk_user_font)* font)
{
    nk_color sym = void;
    nk_text text = void;
    const(nk_style_item)* background = void;

    /* select correct background colors/images */
    background = nk_draw_button(out_, bounds, state, style);
    if (background.type == NK_STYLE_ITEM_COLOR)
        text.background = background.data.color;
    else text.background = style.text_background;

    /* select correct text colors */
    if (state & NK_WIDGET_STATE_HOVER) {
        sym = style.text_hover;
        text.text = style.text_hover;
    } else if (state & NK_WIDGET_STATE_ACTIVED) {
        sym = style.text_active;
        text.text = style.text_active;
    } else {
        sym = style.text_normal;
        text.text = style.text_normal;
    }

    text.padding = nk_vec2(0,0);
    nk_draw_symbol(out_, type, *symbol, style.text_background, sym, 0, font);
    nk_widget_text(out_, *label, str, len, &text, NK_TEXT_CENTERED, font);
}
nk_bool nk_do_button_text_symbol(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, nk_symbol_type symbol, const(char)* str, int len, nk_flags align_, nk_button_behavior behavior, const(nk_style_button)* style, const(nk_user_font)* font, const(nk_input)* in_)
{
    int ret = void;
    nk_rect tri = {0,0,0,0};
    nk_rect content = void;

    assert(style);
    assert(out_);
    assert(font);
    if (!out_ || !style || !font)
        return nk_false;

    ret = nk_do_button(state, out_, bounds, style, in_, behavior, &content);
    tri.y = content.y + (content.h/2) - font.height/2;
    tri.w = font.height; tri.h = font.height;
    if (align_ & NK_TEXT_ALIGN_LEFT) {
        tri.x = (content.x + content.w) - (2 * style.padding.x + tri.w);
        tri.x = nk_max(tri.x, 0);
    } else tri.x = content.x + 2 * style.padding.x;

    /* draw button */
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_button_text_symbol(out_, &bounds, &content, &tri,
        *state, style, str, len, symbol, font);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return cast(nk_bool)ret;
}
void nk_draw_button_text_image(nk_command_buffer* out_, const(nk_rect)* bounds, const(nk_rect)* label, const(nk_rect)* image, nk_flags state, const(nk_style_button)* style, const(char)* str, int len, const(nk_user_font)* font, const(nk_image)* img)
{
    nk_text text = void;
    const(nk_style_item)* background = void;
    background = nk_draw_button(out_, bounds, state, style);

    /* select correct colors */
    if (background.type == NK_STYLE_ITEM_COLOR)
        text.background = background.data.color;
    else text.background = style.text_background;
    if (state & NK_WIDGET_STATE_HOVER)
        text.text = style.text_hover;
    else if (state & NK_WIDGET_STATE_ACTIVED)
        text.text = style.text_active;
    else text.text = style.text_normal;

    text.padding = nk_vec2(0,0);
    nk_widget_text(out_, *label, str, len, &text, NK_TEXT_CENTERED, font);
    nk_draw_image(out_, *image, img, nk_white);
}
nk_bool nk_do_button_text_image(nk_flags* state, nk_command_buffer* out_, nk_rect bounds, nk_image img, const(char)* str, int len, nk_flags align_, nk_button_behavior behavior, const(nk_style_button)* style, const(nk_user_font)* font, const(nk_input)* in_)
{
    int ret = void;
    nk_rect icon = void;
    nk_rect content = void;

    assert(style);
    assert(state);
    assert(font);
    assert(out_);
    if (!out_ || !font || !style || !str)
        return nk_false;

    ret = nk_do_button(state, out_, bounds, style, in_, behavior, &content);
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

    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_button_text_image(out_, &bounds, &content, &icon, *state, style, str, len, font, &img);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);
    return cast(nk_bool)ret;
}
void nk_button_set_behavior(nk_context* ctx, nk_button_behavior behavior)
{
    assert(ctx);
    if (!ctx) return;
    ctx.button_behavior = behavior;
}
nk_bool nk_button_push_behavior(nk_context* ctx, nk_button_behavior behavior)
{
    nk_config_stack_button_behavior* button_stack = void;
    nk_config_stack_button_behavior_element* element = void;

    assert(ctx);
    if (!ctx) return 0;

    button_stack = &ctx.stacks.button_behaviors;
    assert(button_stack.head < cast(int)button_stack.elements.length);
    if (button_stack.head >= cast(int)button_stack.elements.length)
        return 0;

    element = &button_stack.elements[button_stack.head++];
    element.address = &ctx.button_behavior;
    element.old_value = ctx.button_behavior;
    ctx.button_behavior = behavior;
    return 1;
}
nk_bool nk_button_pop_behavior(nk_context* ctx)
{
    nk_config_stack_button_behavior* button_stack = void;
    nk_config_stack_button_behavior_element* element = void;

    assert(ctx);
    if (!ctx) return 0;

    button_stack = &ctx.stacks.button_behaviors;
    assert(button_stack.head > 0);
    if (button_stack.head < 1)
        return 0;

    element = &button_stack.elements[--button_stack.head];
    *element.address = element.old_value;
    return 1;
}
nk_bool nk_button_text_styled(nk_context* ctx, const(nk_style_button)* style, const(char)* title, int len)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(style);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!style || !ctx || !ctx.current || !ctx.current.layout) return 0;

    win = ctx.current;
    layout = win.layout;
    state = nk_widget(&bounds, ctx);

    if (!state) return 0;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_button_text(&ctx.last_widget_state, &win.buffer, bounds,
                    title, len, style.text_alignment, ctx.button_behavior,
                    style, in_, ctx.style.font);
}
nk_bool nk_button_text(nk_context* ctx, const(char)* title, int len)
{
    assert(ctx);
    if (!ctx) return 0;
    return nk_button_text_styled(ctx, &ctx.style.button, title, len);
}
nk_bool nk_button_label_styled(nk_context* ctx, const(nk_style_button)* style, const(char)* title)
{
    return nk_button_text_styled(ctx, style, title, nk_strlen(title));
}
nk_bool nk_button_label(nk_context* ctx, const(char)* title)
{
    return nk_button_text(ctx, title, nk_strlen(title));
}
nk_bool nk_button_color(nk_context* ctx, nk_color color)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;
    nk_style_button button = void;

    int ret = 0;
    nk_rect bounds = void;
    nk_rect content = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    layout = win.layout;

    state = nk_widget(&bounds, ctx);
    if (!state) return 0;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;

    button = ctx.style.button;
    button.normal = nk_style_item_color(color);
    button.hover = nk_style_item_color(color);
    button.active = nk_style_item_color(color);
    ret = nk_do_button(&ctx.last_widget_state, &win.buffer, bounds,
                &button, in_, ctx.button_behavior, &content);
    nk_draw_button(&win.buffer, &bounds, ctx.last_widget_state, &button);
    return cast(nk_bool)ret;
}
nk_bool nk_button_symbol_styled(nk_context* ctx, const(nk_style_button)* style, nk_symbol_type symbol)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    layout = win.layout;
    state = nk_widget(&bounds, ctx);
    if (!state) return 0;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_button_symbol(&ctx.last_widget_state, &win.buffer, bounds,
            symbol, ctx.button_behavior, style, in_, ctx.style.font);
}
nk_bool nk_button_symbol(nk_context* ctx, nk_symbol_type symbol)
{
    assert(ctx);
    if (!ctx) return 0;
    return nk_button_symbol_styled(ctx, &ctx.style.button, symbol);
}
nk_bool nk_button_image_styled(nk_context* ctx, const(nk_style_button)* style, nk_image img)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    layout = win.layout;

    state = nk_widget(&bounds, ctx);
    if (!state) return 0;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_button_image(&ctx.last_widget_state, &win.buffer, bounds,
                img, ctx.button_behavior, style, in_);
}
nk_bool nk_button_image(nk_context* ctx, nk_image img)
{
    assert(ctx);
    if (!ctx) return 0;
    return nk_button_image_styled(ctx, &ctx.style.button, img);
}
nk_bool nk_button_symbol_text_styled(nk_context* ctx, const(nk_style_button)* style, nk_symbol_type symbol, const(char)* text, int len, nk_flags align_)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    layout = win.layout;

    state = nk_widget(&bounds, ctx);
    if (!state) return 0;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_button_text_symbol(&ctx.last_widget_state, &win.buffer, bounds,
                symbol, text, len, align_, ctx.button_behavior,
                style, ctx.style.font, in_);
}
nk_bool nk_button_symbol_text(nk_context* ctx, nk_symbol_type symbol, const(char)* text, int len, nk_flags align_)
{
    assert(ctx);
    if (!ctx) return 0;
    return nk_button_symbol_text_styled(ctx, &ctx.style.button, symbol, text, len, align_);
}
nk_bool nk_button_symbol_label(nk_context* ctx, nk_symbol_type symbol, const(char)* label, nk_flags align_)
{
    return nk_button_symbol_text(ctx, symbol, label, nk_strlen(label), align_);
}
nk_bool nk_button_symbol_label_styled(nk_context* ctx, const(nk_style_button)* style, nk_symbol_type symbol, const(char)* title, nk_flags align_)
{
    return nk_button_symbol_text_styled(ctx, style, symbol, title, nk_strlen(title), align_);
}
nk_bool nk_button_image_text_styled(nk_context* ctx, const(nk_style_button)* style, nk_image img, const(char)* text, int len, nk_flags align_)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_input)* in_ = void;

    nk_rect bounds = void;
    nk_widget_layout_states state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    win = ctx.current;
    layout = win.layout;

    state = nk_widget(&bounds, ctx);
    if (!state) return 0;
    in_ = (state == NK_WIDGET_ROM || layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    return nk_do_button_text_image(&ctx.last_widget_state, &win.buffer,
            bounds, img, text, len, align_, ctx.button_behavior,
            style, ctx.style.font, in_);
}
nk_bool nk_button_image_text(nk_context* ctx, nk_image img, const(char)* text, int len, nk_flags align_)
{
    return nk_button_image_text_styled(ctx, &ctx.style.button,img, text, len, align_);
}
nk_bool nk_button_image_label(nk_context* ctx, nk_image img, const(char)* label, nk_flags align_)
{
    return nk_button_image_text(ctx, img, label, nk_strlen(label), align_);
}
nk_bool nk_button_image_label_styled(nk_context* ctx, const(nk_style_button)* style, nk_image img, const(char)* label, nk_flags text_alignment)
{
    return nk_button_image_text_styled(ctx, style, img, label, nk_strlen(label), text_alignment);
}
