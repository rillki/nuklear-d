module nuklear.nuklear_property;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              PROPERTY
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_input;
import nuklear.nuklear_button;
import nuklear.nuklear_widget;
import nuklear.nuklear_text;
import nuklear.nuklear_draw;
import nuklear.nuklear_color;
import nuklear.nuklear_edit;
import nuklear.nuklear_utf8;
import nuklear.nuklear_text_editor;

void nk_drag_behavior(nk_flags* state, const(nk_input)* in_, nk_rect drag, nk_property_variant* variant, float inc_per_pixel)
{
    int left_mouse_down = in_ && in_.mouse.buttons[NK_BUTTON_LEFT].down;
    int left_mouse_click_in_cursor = in_ &&
        nk_input_has_mouse_click_down_in_rect(in_, NK_BUTTON_LEFT, drag, nk_true);

    nk_widget_state_reset(state);
    if (nk_input_is_mouse_hovering_rect(in_, drag))
        *state = NK_WIDGET_STATE_HOVERED;

    if (left_mouse_down && left_mouse_click_in_cursor) {
        float delta = void, pixels = void;
        pixels = in_.mouse.delta.x;
        delta = pixels * inc_per_pixel;
        switch (variant.kind) {
        default: break;
        case NK_PROPERTY_INT:
            variant.value.i = variant.value.i + cast(int)delta;
            variant.value.i = nk_clamp(variant.min_value.i, variant.value.i, variant.max_value.i);
            break;
        case NK_PROPERTY_FLOAT:
            variant.value.f = variant.value.f + cast(float)delta;
            variant.value.f = nk_clamp(variant.min_value.f, variant.value.f, variant.max_value.f);
            break;
        case NK_PROPERTY_DOUBLE:
            variant.value.d = variant.value.d + cast(double)delta;
            variant.value.d = nk_clamp(variant.min_value.d, variant.value.d, variant.max_value.d);
            break;
        }
        *state = NK_WIDGET_STATE_ACTIVE;
    }
    if (*state & NK_WIDGET_STATE_HOVER && !nk_input_is_mouse_prev_hovering_rect(in_, drag))
        *state |= NK_WIDGET_STATE_ENTERED;
    else if (nk_input_is_mouse_prev_hovering_rect(in_, drag))
        *state |= NK_WIDGET_STATE_LEFT;
}
void nk_property_behavior(nk_flags* ws, const(nk_input)* in_, nk_rect property, nk_rect label, nk_rect edit, nk_rect empty, int* state, nk_property_variant* variant, float inc_per_pixel)
{
    nk_widget_state_reset(ws);
    if (in_ && *state == NK_PROPERTY_DEFAULT) {
        if (nk_button_behavior_(ws, edit, in_, NK_BUTTON_DEFAULT))
            *state = NK_PROPERTY_EDIT;
        else if (nk_input_is_mouse_click_down_in_rect(in_, NK_BUTTON_LEFT, label, nk_true))
            *state = NK_PROPERTY_DRAG;
        else if (nk_input_is_mouse_click_down_in_rect(in_, NK_BUTTON_LEFT, empty, nk_true))
            *state = NK_PROPERTY_DRAG;
    }
    if (*state == NK_PROPERTY_DRAG) {
        nk_drag_behavior(ws, in_, property, variant, inc_per_pixel);
        if (!(*ws & NK_WIDGET_STATE_ACTIVED)) *state = NK_PROPERTY_DEFAULT;
    }
}
void nk_draw_property(nk_command_buffer* out_, const(nk_style_property)* style, const(nk_rect)* bounds, const(nk_rect)* label, nk_flags state, const(char)* name, int len, const(nk_user_font)* font)
{
    nk_text text = void;
    const(nk_style_item)* background = void;

    /* select correct background and text color */
    if (state & NK_WIDGET_STATE_ACTIVED) {
        background = &style.active;
        text.text = style.label_active;
    } else if (state & NK_WIDGET_STATE_HOVER) {
        background = &style.hover;
        text.text = style.label_hover;
    } else {
        background = &style.normal;
        text.text = style.label_normal;
    }

    /* draw background */
    switch(background.type) {
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
            nk_stroke_rect(out_, *bounds, style.rounding, style.border, background.data.color);
            break;
    default: break;}

    /* draw label */
    text.padding = nk_vec2(0,0);
    nk_widget_text(out_, *label, name, len, &text, NK_TEXT_CENTERED, font);
}
void nk_do_property(nk_flags* ws, nk_command_buffer* out_, nk_rect property, const(char)* name, nk_property_variant* variant, float inc_per_pixel, char* buffer, int* len, int* state, int* cursor, int* select_begin, int* select_end, const(nk_style_property)* style, nk_property_filter filter, nk_input* in_, const(nk_user_font)* font, nk_text_edit* text_edit, nk_button_behavior behavior)
{
    const(nk_plugin_filter)[2] filters = [
        &nk_filter_decimal,
        &nk_filter_float
    ];
    nk_bool active = void, old = void;
    int num_len = 0, name_len = void;
    char[NK_MAX_NUMBER_BUFFER] string = void;
    float size = void;

    char* dst = null;
    int* length = void;

    nk_rect left = void;
    nk_rect right = void;
    nk_rect label = void;
    nk_rect edit = void;
    nk_rect empty = void;

    /* left decrement button */
    left.h = font.height/2;
    left.w = left.h;
    left.x = property.x + style.border + style.padding.x;
    left.y = property.y + style.border + property.h/2.0f - left.h/2;

    /* text label */
    name_len = nk_strlen(name);
    size = font.width(cast(nk_handle)font.userdata, font.height, name, name_len);
    label.x = left.x + left.w + style.padding.x;
    label.w = cast(float)size + 2 * style.padding.x;
    label.y = property.y + style.border + style.padding.y;
    label.h = property.h - (2 * style.border + 2 * style.padding.y);

    /* right increment button */
    right.y = left.y;
    right.w = left.w;
    right.h = left.h;
    right.x = property.x + property.w - (right.w + style.padding.x);

    /* edit */
    if (*state == NK_PROPERTY_EDIT) {
        size = font.width(cast(nk_handle)font.userdata, font.height, buffer, *len);
        size += style.edit.cursor_size;
        length = len;
        dst = buffer;
    } else {
        switch (variant.kind) {
        default: break;
        case NK_PROPERTY_INT:
            nk_itoa(string.ptr, variant.value.i);
            num_len = nk_strlen(string.ptr);
            break;
        case NK_PROPERTY_FLOAT:
            nk_dtoa(string.ptr, cast(double)variant.value.f);
            num_len = nk_string_float_limit(string.ptr, NK_MAX_FLOAT_PRECISION);
            break;
        case NK_PROPERTY_DOUBLE:
            nk_dtoa(string.ptr, variant.value.d);
            num_len = nk_string_float_limit(string.ptr, NK_MAX_FLOAT_PRECISION);
            break;
        }
        size = font.width(cast(nk_handle)font.userdata, font.height, string.ptr, num_len);
        dst = string.ptr;
        length = &num_len;
    }

    edit.w =  cast(float)size + 2 * style.padding.x;
    edit.w = nk_min(edit.w, right.x - (label.x + label.w));
    edit.x = right.x - (edit.w + style.padding.x);
    edit.y = property.y + style.border;
    edit.h = property.h - (2 * style.border);

    /* empty left space activator */
    empty.w = edit.x - (label.x + label.w);
    empty.x = label.x + label.w;
    empty.y = property.y;
    empty.h = property.h;

    /* update property */
    old = (*state == NK_PROPERTY_EDIT);
    nk_property_behavior(ws, in_, property, label, edit, empty, state, variant, inc_per_pixel);

    /* draw property */
    if (style.draw_begin) style.draw_begin(out_, cast(nk_handle)style.userdata);
    nk_draw_property(out_, style, &property, &label, *ws, name, name_len, font);
    if (style.draw_end) style.draw_end(out_, cast(nk_handle)style.userdata);

    /* execute right button  */
    if (nk_do_button_symbol(ws, out_, left, style.sym_left, behavior, &style.dec_button, in_, font)) {
        switch (variant.kind) {
        default: break;
        case NK_PROPERTY_INT:
            variant.value.i = nk_clamp(variant.min_value.i, variant.value.i - variant.step.i, variant.max_value.i); break;
        case NK_PROPERTY_FLOAT:
            variant.value.f = nk_clamp(variant.min_value.f, variant.value.f - variant.step.f, variant.max_value.f); break;
        case NK_PROPERTY_DOUBLE:
            variant.value.d = nk_clamp(variant.min_value.d, variant.value.d - variant.step.d, variant.max_value.d); break;
        }
    }
    /* execute left button  */
    if (nk_do_button_symbol(ws, out_, right, style.sym_right, behavior, &style.inc_button, in_, font)) {
        switch (variant.kind) {
        default: break;
        case NK_PROPERTY_INT:
            variant.value.i = nk_clamp(variant.min_value.i, variant.value.i + variant.step.i, variant.max_value.i); break;
        case NK_PROPERTY_FLOAT:
            variant.value.f = nk_clamp(variant.min_value.f, variant.value.f + variant.step.f, variant.max_value.f); break;
        case NK_PROPERTY_DOUBLE:
            variant.value.d = nk_clamp(variant.min_value.d, variant.value.d + variant.step.d, variant.max_value.d); break;
        }
    }
    if (old != NK_PROPERTY_EDIT && (*state == NK_PROPERTY_EDIT)) {
        /* property has been activated so setup buffer */
        nk_memcopy(buffer, dst, cast(nk_size)(*length));
        *cursor = nk_utf_len(buffer, *length);
        *len = *length;
        length = len;
        dst = buffer;
        active = 0;
    } else active = (*state == NK_PROPERTY_EDIT);

    /* execute and run text edit field */
    nk_textedit_clear_state(text_edit, NK_TEXT_EDIT_SINGLE_LINE, filters[filter]);
    text_edit.active = cast(ubyte)active;
    text_edit.string.len = *length;
    text_edit.cursor = nk_clamp(0, *cursor, *length);
    text_edit.select_start = nk_clamp(0,*select_begin, *length);
    text_edit.select_end = nk_clamp(0,*select_end, *length);
    text_edit.string.buffer.allocated = cast(nk_size)*length;
    text_edit.string.buffer.memory.size = NK_MAX_NUMBER_BUFFER;
    text_edit.string.buffer.memory.ptr = dst;
    text_edit.string.buffer.size = NK_MAX_NUMBER_BUFFER;
    text_edit.mode = NK_TEXT_EDIT_MODE_INSERT;
    nk_do_edit(ws, out_, edit, NK_EDIT_FIELD|NK_EDIT_AUTO_SELECT,
        filters[filter], text_edit, &style.edit, (*state == NK_PROPERTY_EDIT) ? in_: null, font);

    *length = text_edit.string.len;
    *cursor = text_edit.cursor;
    *select_begin = text_edit.select_start;
    *select_end = text_edit.select_end;
    if (text_edit.active && nk_input_is_key_pressed(in_, NK_KEY_ENTER))
        text_edit.active = nk_false;

    if (active && !text_edit.active) {
        /* property is now not active so convert edit text to value*/
        *state = NK_PROPERTY_DEFAULT;
        buffer[*len] = '\0';
        switch (variant.kind) {
        default: break;
        case NK_PROPERTY_INT:
            variant.value.i = nk_strtoi(buffer, null);
            variant.value.i = nk_clamp(variant.min_value.i, variant.value.i, variant.max_value.i);
            break;
        case NK_PROPERTY_FLOAT:
            nk_string_float_limit(buffer, NK_MAX_FLOAT_PRECISION);
            variant.value.f = nk_strtof(buffer, null);
            variant.value.f = nk_clamp(variant.min_value.f, variant.value.f, variant.max_value.f);
            break;
        case NK_PROPERTY_DOUBLE:
            nk_string_float_limit(buffer, NK_MAX_FLOAT_PRECISION);
            variant.value.d = nk_strtod(buffer, null);
            variant.value.d = nk_clamp(variant.min_value.d, variant.value.d, variant.max_value.d);
            break;
        }
    }
}
nk_property_variant nk_property_variant_int(int value, int min_value, int max_value, int step)
{
    nk_property_variant result = void;
    result.kind = NK_PROPERTY_INT;
    result.value.i = value;
    result.min_value.i = min_value;
    result.max_value.i = max_value;
    result.step.i = step;
    return result;
}
nk_property_variant nk_property_variant_float(float value, float min_value, float max_value, float step)
{
    nk_property_variant result = void;
    result.kind = NK_PROPERTY_FLOAT;
    result.value.f = value;
    result.min_value.f = min_value;
    result.max_value.f = max_value;
    result.step.f = step;
    return result;
}
nk_property_variant nk_property_variant_double(double value, double min_value, double max_value, double step)
{
    nk_property_variant result = void;
    result.kind = NK_PROPERTY_DOUBLE;
    result.value.d = value;
    result.min_value.d = min_value;
    result.max_value.d = max_value;
    result.step.d = step;
    return result;
}
void nk_property(nk_context* ctx, const(char)* name, nk_property_variant* variant, float inc_per_pixel, const(nk_property_filter) filter)
{
    nk_window* win = void;
    nk_panel* layout = void;
    nk_input* in_ = void;
    const(nk_style)* style = void;

    nk_rect bounds = void;
    nk_widget_layout_states s = void;

    int* state = null;
    nk_hash hash = 0;
    char* buffer = null;
    int* len = null;
    int* cursor = null;
    int* select_begin = null;
    int* select_end = null;
    int old_state = void;

    char[NK_MAX_NUMBER_BUFFER] dummy_buffer = void;
    int dummy_state = NK_PROPERTY_DEFAULT;
    int dummy_length = 0;
    int dummy_cursor = 0;
    int dummy_select_begin = 0;
    int dummy_select_end = 0;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    style = &ctx.style;
    s = nk_widget(&bounds, ctx);
    if (!s) return;

    /* calculate hash from name */
    if (name[0] == '#') {
        hash = nk_murmur_hash(name, cast(int)nk_strlen(name), win.property.seq++);
        name++; /* special number hash */
    } else hash = nk_murmur_hash(name, cast(int)nk_strlen(name), 42);

    /* check if property is currently hot item */
    if (win.property.active && hash == win.property.name) {
        buffer = win.property.buffer.ptr;
        len = &win.property.length;
        cursor = &win.property.cursor;
        state = &win.property.state;
        select_begin = &win.property.select_start;
        select_end = &win.property.select_end;
    } else {
        buffer = dummy_buffer.ptr;
        len = &dummy_length;
        cursor = &dummy_cursor;
        state = &dummy_state;
        select_begin =  &dummy_select_begin;
        select_end = &dummy_select_end;
    }

    /* execute property widget */
    old_state = *state;
    ctx.text_edit.clip = ctx.clip;
    in_ = ((s == NK_WIDGET_ROM && !win.property.active) ||
        layout.flags & NK_WINDOW_ROM) ? null : &ctx.input;
    nk_do_property(&ctx.last_widget_state, &win.buffer, bounds, name,
        variant, inc_per_pixel, buffer, len, state, cursor, select_begin,
        select_end, &style.property, filter, in_, style.font, &ctx.text_edit,
        ctx.button_behavior);

    if (in_ && *state != NK_PROPERTY_DEFAULT && !win.property.active) {
        /* current property is now hot */
        win.property.active = 1;
        nk_memcopy(win.property.buffer.ptr, buffer, cast(nk_size)*len);
        win.property.length = *len;
        win.property.cursor = *cursor;
        win.property.state = *state;
        win.property.name = hash;
        win.property.select_start = *select_begin;
        win.property.select_end = *select_end;
        if (*state == NK_PROPERTY_DRAG) {
            ctx.input.mouse.grab = nk_true;
            ctx.input.mouse.grabbed = nk_true;
        }
    }
    /* check if previously active property is now inactive */
    if (*state == NK_PROPERTY_DEFAULT && old_state != NK_PROPERTY_DEFAULT) {
        if (old_state == NK_PROPERTY_DRAG) {
            ctx.input.mouse.grab = nk_false;
            ctx.input.mouse.grabbed = nk_false;
            ctx.input.mouse.ungrab = nk_true;
        }
        win.property.select_start = 0;
        win.property.select_end = 0;
        win.property.active = 0;
    }
}
void nk_property_int(nk_context* ctx, const(char)* name, int min, int* val, int max, int step, float inc_per_pixel)
{
    nk_property_variant variant = void;
    assert(ctx);
    assert(name);
    assert(val);

    if (!ctx || !ctx.current || !name || !val) return;
    variant = nk_property_variant_int(*val, min, max, step);
    nk_property(ctx, name, &variant, inc_per_pixel, NK_FILTER_INT);
    *val = variant.value.i;
}
void nk_property_float(nk_context* ctx, const(char)* name, float min, float* val, float max, float step, float inc_per_pixel)
{
    nk_property_variant variant = void;
    assert(ctx);
    assert(name);
    assert(val);

    if (!ctx || !ctx.current || !name || !val) return;
    variant = nk_property_variant_float(*val, min, max, step);
    nk_property(ctx, name, &variant, inc_per_pixel, NK_FILTER_FLOAT);
    *val = variant.value.f;
}
void nk_property_double(nk_context* ctx, const(char)* name, double min, double* val, double max, double step, float inc_per_pixel)
{
    nk_property_variant variant = void;
    assert(ctx);
    assert(name);
    assert(val);

    if (!ctx || !ctx.current || !name || !val) return;
    variant = nk_property_variant_double(*val, min, max, step);
    nk_property(ctx, name, &variant, inc_per_pixel, NK_FILTER_FLOAT);
    *val = variant.value.d;
}
int nk_propertyi(nk_context* ctx, const(char)* name, int min, int val, int max, int step, float inc_per_pixel)
{
    nk_property_variant variant = void;
    assert(ctx);
    assert(name);

    if (!ctx || !ctx.current || !name) return val;
    variant = nk_property_variant_int(val, min, max, step);
    nk_property(ctx, name, &variant, inc_per_pixel, NK_FILTER_INT);
    val = variant.value.i;
    return val;
}
float nk_propertyf(nk_context* ctx, const(char)* name, float min, float val, float max, float step, float inc_per_pixel)
{
    nk_property_variant variant = void;
    assert(ctx);
    assert(name);

    if (!ctx || !ctx.current || !name) return val;
    variant = nk_property_variant_float(val, min, max, step);
    nk_property(ctx, name, &variant, inc_per_pixel, NK_FILTER_FLOAT);
    val = variant.value.f;
    return val;
}
double nk_propertyd(nk_context* ctx, const(char)* name, double min, double val, double max, double step, float inc_per_pixel)
{
    nk_property_variant variant = void;
    assert(ctx);
    assert(name);

    if (!ctx || !ctx.current || !name) return val;
    variant = nk_property_variant_double(val, min, max, step);
    nk_property(ctx, name, &variant, inc_per_pixel, NK_FILTER_FLOAT);
    val = variant.value.d;
    return val;
}

