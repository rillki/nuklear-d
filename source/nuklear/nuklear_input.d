module nuklear.nuklear_input;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          INPUT
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

void nk_input_begin(nk_context* ctx)
{
    int i = void;
    nk_input* in_ = void;
    assert(ctx);
    if (!ctx) return;
    in_ = &ctx.input;
    for (i = 0; i < NK_BUTTON_MAX; ++i)
        in_.mouse.buttons[i].clicked = 0;

    in_.keyboard.text_len = 0;
    in_.mouse.scroll_delta = nk_vec2(0,0);
    in_.mouse.prev.x = in_.mouse.pos.x;
    in_.mouse.prev.y = in_.mouse.pos.y;
    in_.mouse.delta.x = 0;
    in_.mouse.delta.y = 0;
    for (i = 0; i < NK_KEY_MAX; i++)
        in_.keyboard.keys[i].clicked = 0;
}
void nk_input_end(nk_context* ctx)
{
    nk_input* in_ = void;
    assert(ctx);
    if (!ctx) return;
    in_ = &ctx.input;
    if (in_.mouse.grab)
        in_.mouse.grab = 0;
    if (in_.mouse.ungrab) {
        in_.mouse.grabbed = 0;
        in_.mouse.ungrab = 0;
        in_.mouse.grab = 0;
    }
}
void nk_input_motion(nk_context* ctx, int x, int y)
{
    nk_input* in_ = void;
    assert(ctx);
    if (!ctx) return;
    in_ = &ctx.input;
    in_.mouse.pos.x = cast(float)x;
    in_.mouse.pos.y = cast(float)y;
    in_.mouse.delta.x = in_.mouse.pos.x - in_.mouse.prev.x;
    in_.mouse.delta.y = in_.mouse.pos.y - in_.mouse.prev.y;
}
void nk_input_key(nk_context* ctx, nk_keys key, nk_bool down)
{
    nk_input* in_ = void;
    assert(ctx);
    if (!ctx) return;
    in_ = &ctx.input;
version (NK_KEYSTATE_BASED_INPUT) {
    if (in_.keyboard.keys[key].down != down)
        in_.keyboard.keys[key].clicked++;
} else {
    in_.keyboard.keys[key].clicked++;
}
    in_.keyboard.keys[key].down = down;
}
void nk_input_button(nk_context* ctx, nk_buttons id, int x, int y, nk_bool down)
{
    nk_mouse_button* btn = void;
    nk_input* in_ = void;
    assert(ctx);
    if (!ctx) return;
    in_ = &ctx.input;
    if (in_.mouse.buttons[id].down == down) return;

    btn = &in_.mouse.buttons[id];
    btn.clicked_pos.x = cast(float)x;
    btn.clicked_pos.y = cast(float)y;
    btn.down = down;
    btn.clicked++;

    /* Fix Click-Drag for touch events. */
    in_.mouse.delta.x = 0;
    in_.mouse.delta.y = 0;
version (NK_BUTTON_TRIGGER_ON_RELEASE) {
    if (down == 1 && id == NK_BUTTON_LEFT)
    {
        in_.mouse.down_pos.x = btn.clicked_pos.x;
        in_.mouse.down_pos.y = btn.clicked_pos.y;
    }
}
}
void nk_input_scroll(nk_context* ctx, nk_vec2 val)
{
    assert(ctx);
    if (!ctx) return;
    ctx.input.mouse.scroll_delta.x += val.x;
    ctx.input.mouse.scroll_delta.y += val.y;
}
void nk_input_glyph(nk_context* ctx, const(nk_glyph) glyph)
{
    int len = 0;
    nk_rune unicode = void;
    nk_input* in_ = void;

    assert(ctx);
    if (!ctx) return;
    in_ = &ctx.input;

    len = nk_utf_decode(glyph, &unicode, NK_UTF_SIZE);
    if (len && ((in_.keyboard.text_len + len) < NK_INPUT_MAX)) {
        nk_utf_encode(unicode, &in_.keyboard.text[in_.keyboard.text_len],
            NK_INPUT_MAX - in_.keyboard.text_len);
        in_.keyboard.text_len += len;
    }
}
void nk_input_char(nk_context* ctx, char c)
{
    nk_glyph glyph = void;
    assert(ctx);
    if (!ctx) return;
    glyph[0] = c;
    nk_input_glyph(ctx, glyph);
}
void nk_input_unicode(nk_context* ctx, nk_rune unicode)
{
    nk_glyph rune = void;
    assert(ctx);
    if (!ctx) return;
    nk_utf_encode(unicode, rune, NK_UTF_SIZE);
    nk_input_glyph(ctx, rune);
}
nk_bool nk_input_has_mouse_click(const(nk_input)* i, nk_buttons id)
{
    const(nk_mouse_button)* btn = void;
    if (!i) return nk_false;
    btn = &i.mouse.buttons[id];
    return (btn.clicked && btn.down == nk_false) ? nk_true : nk_false;
}
nk_bool nk_input_has_mouse_click_in_rect(const(nk_input)* i, nk_buttons id, nk_rect b)
{
    const(nk_mouse_button)* btn = void;
    if (!i) return nk_false;
    btn = &i.mouse.buttons[id];
    if (!nk_inbox(btn.clicked_pos.x,btn.clicked_pos.y,b.x,b.y,b.w,b.h))
        return nk_false;
    return nk_true;
}
nk_bool nk_input_has_mouse_click_in_button_rect(const(nk_input)* i, nk_buttons id, nk_rect b)
{
    const(nk_mouse_button)* btn = void;
    if (!i) return nk_false;
    btn = &i.mouse.buttons[id];
    version (NK_BUTTON_TRIGGER_ON_RELEASE) {
        if (!nk_inbox(btn.clicked_pos.x,btn.clicked_pos.y,b.x,b.y,b.w,b.h) || !nk_inbox(i.mouse.down_pos.x,i.mouse.down_pos.y,b.x,b.y,b.w,b.h))
            return nk_false;
    } else {
        if (!nk_inbox(btn.clicked_pos.x,btn.clicked_pos.y,b.x,b.y,b.w,b.h))
            return nk_false;
    }
    return nk_true;
}

nk_bool nk_input_has_mouse_click_down_in_rect(const(nk_input)* i, nk_buttons id, nk_rect b, nk_bool down)
{
    const(nk_mouse_button)* btn = void;
    if (!i) return nk_false;
    btn = &i.mouse.buttons[id];
    return nk_input_has_mouse_click_in_rect(i, id, b) && (btn.down == down);
}
nk_bool nk_input_is_mouse_click_in_rect(const(nk_input)* i, nk_buttons id, nk_rect b)
{
    const(nk_mouse_button)* btn = void;
    if (!i) return nk_false;
    btn = &i.mouse.buttons[id];
    return (nk_input_has_mouse_click_down_in_rect(i, id, b, nk_false) &&
            btn.clicked) ? nk_true : nk_false;
}
nk_bool nk_input_is_mouse_click_down_in_rect(const(nk_input)* i, nk_buttons id, nk_rect b, nk_bool down)
{
    const(nk_mouse_button)* btn = void;
    if (!i) return nk_false;
    btn = &i.mouse.buttons[id];
    return (nk_input_has_mouse_click_down_in_rect(i, id, b, down) &&
            btn.clicked) ? nk_true : nk_false;
}
nk_bool nk_input_any_mouse_click_in_rect(const(nk_input)* in_, nk_rect b)
{
    int i = void, down = 0;
    for (i = 0; i < NK_BUTTON_MAX; ++i)
        down = down || nk_input_is_mouse_click_in_rect(in_, cast(nk_buttons)i, b);
    return down;
}
nk_bool nk_input_is_mouse_hovering_rect(const(nk_input)* i, nk_rect rect)
{
    if (!i) return nk_false;
    return nk_inbox(i.mouse.pos.x, i.mouse.pos.y, rect.x, rect.y, rect.w, rect.h);
}
nk_bool nk_input_is_mouse_prev_hovering_rect(const(nk_input)* i, nk_rect rect)
{
    if (!i) return nk_false;
    return nk_inbox(i.mouse.prev.x, i.mouse.prev.y, rect.x, rect.y, rect.w, rect.h);
}
nk_bool nk_input_mouse_clicked(const(nk_input)* i, nk_buttons id, nk_rect rect)
{
    if (!i) return nk_false;
    if (!nk_input_is_mouse_hovering_rect(i, rect)) return nk_false;
    return nk_input_is_mouse_click_in_rect(i, id, rect);
}
nk_bool nk_input_is_mouse_down(const(nk_input)* i, nk_buttons id)
{
    if (!i) return nk_false;
    return i.mouse.buttons[id].down;
}
nk_bool nk_input_is_mouse_pressed(const(nk_input)* i, nk_buttons id)
{
    const(nk_mouse_button)* b = void;
    if (!i) return nk_false;
    b = &i.mouse.buttons[id];
    if (b.down && b.clicked)
        return nk_true;
    return nk_false;
}
nk_bool nk_input_is_mouse_released(const(nk_input)* i, nk_buttons id)
{
    if (!i) return nk_false;
    return (!i.mouse.buttons[id].down && i.mouse.buttons[id].clicked);
}
nk_bool nk_input_is_key_pressed(const(nk_input)* i, nk_keys key)
{
    const(nk_key)* k = void;
    if (!i) return nk_false;
    k = &i.keyboard.keys[key];
    if ((k.down && k.clicked) || (!k.down && k.clicked >= 2))
        return nk_true;
    return nk_false;
}
nk_bool nk_input_is_key_released(const(nk_input)* i, nk_keys key)
{
    const(nk_key)* k = void;
    if (!i) return nk_false;
    k = &i.keyboard.keys[key];
    if ((!k.down && k.clicked) || (k.down && k.clicked >= 2))
        return nk_true;
    return nk_false;
}
nk_bool nk_input_is_key_down(const(nk_input)* i, nk_keys key)
{
    const(nk_key)* k = void;
    if (!i) return nk_false;
    k = &i.keyboard.keys[key];
    if (k.down) return nk_true;
    return nk_false;
}

