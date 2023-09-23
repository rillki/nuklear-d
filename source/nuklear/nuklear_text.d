module nuklear.nuklear_text;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              TEXT
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_panel;
import nuklear.nuklear_draw;
import nuklear.nuklear_layout;
import nuklear.nuklear_color;

void nk_widget_text(nk_command_buffer* o, nk_rect b, const(char)* string, int len, const(nk_text)* t, nk_flags a, const(nk_user_font)* f)
{
    nk_rect label = void;
    float text_width = void;

    assert(o);
    assert(t);
    if (!o || !t) return;

    b.h = nk_max(b.h, 2 * t.padding.y);
    label.x = 0; label.w = 0;
    label.y = b.y + t.padding.y;
    label.h = nk_min(f.height, b.h - 2 * t.padding.y);

    text_width = f.width(cast(nk_handle)f.userdata, f.height, cast(const(char)*)string, len);
    text_width += (2.0f * t.padding.x);

    /* align in x-axis */
    if (a & NK_TEXT_ALIGN_LEFT) {
        label.x = b.x + t.padding.x;
        label.w = nk_max(0, b.w - 2 * t.padding.x);
    } else if (a & NK_TEXT_ALIGN_CENTERED) {
        label.w = nk_max(1, 2 * t.padding.x + cast(float)text_width);
        label.x = (b.x + t.padding.x + ((b.w - 2 * t.padding.x) - label.w) / 2);
        label.x = nk_max(b.x + t.padding.x, label.x);
        label.w = nk_min(b.x + b.w, label.x + label.w);
        if (label.w >= label.x) label.w -= label.x;
    } else if (a & NK_TEXT_ALIGN_RIGHT) {
        label.x = nk_max(b.x + t.padding.x, (b.x + b.w) - (2 * t.padding.x + cast(float)text_width));
        label.w = cast(float)text_width + 2 * t.padding.x;
    } else return;

    /* align in y-axis */
    if (a & NK_TEXT_ALIGN_MIDDLE) {
        label.y = b.y + b.h/2.0f - cast(float)f.height/2.0f;
        label.h = nk_max(b.h/2.0f, b.h - (b.h/2.0f + f.height/2.0f));
    } else if (a & NK_TEXT_ALIGN_BOTTOM) {
        label.y = b.y + b.h - f.height;
        label.h = f.height;
    }
    nk_draw_text(o, label, cast(const(char)*)string, len, f, t.background, t.text);
}
void nk_widget_text_wrap(nk_command_buffer* o, nk_rect b, const(char)* string, int len, const(nk_text)* t, const(nk_user_font)* f)
{
    float width = void;
    int glyphs = 0;
    int fitting = 0;
    int done = 0;
    nk_rect line = void;
    nk_text text = void;
    nk_rune[1] seperator = [' '];

    assert(o);
    assert(t);
    if (!o || !t) return;

    text.padding = nk_vec2(0,0);
    text.background = t.background;
    text.text = t.text;

    b.w = nk_max(b.w, 2 * t.padding.x);
    b.h = nk_max(b.h, 2 * t.padding.y);
    b.h = b.h - 2 * t.padding.y;

    line.x = b.x + t.padding.x;
    line.y = b.y + t.padding.y;
    line.w = b.w - 2 * t.padding.x;
    line.h = 2 * t.padding.y + f.height;

    fitting = nk_text_clamp(f, string, len, line.w, &glyphs, &width, seperator.ptr, seperator.length);
    while (done < len) {
        if (!fitting || line.y + line.h >= (b.y + b.h)) break;
        nk_widget_text(o, line, &string[done], fitting, &text, NK_TEXT_LEFT, f);
        done += fitting;
        line.y += f.height + 2 * t.padding.y;
        fitting = nk_text_clamp(f, &string[done], len - done, line.w, &glyphs, &width, seperator.ptr, (seperator.length));
    }
}
void nk_text_colored(nk_context* ctx, const(char)* str, int len, nk_flags alignment, nk_color color)
{
    nk_window* win = void;
    const(nk_style)* style = void;

    nk_vec2 item_padding = void;
    nk_rect bounds = void;
    nk_text text = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout) return;

    win = ctx.current;
    style = &ctx.style;
    nk_panel_alloc_space(&bounds, ctx);
    item_padding = style.text.padding;

    text.padding.x = item_padding.x;
    text.padding.y = item_padding.y;
    text.background = style.window.background;
    text.text = color;
    nk_widget_text(&win.buffer, bounds, str, len, &text, alignment, style.font);
}
void nk_text_wrap_colored(nk_context* ctx, const(char)* str, int len, nk_color color)
{
    nk_window* win = void;
    const(nk_style)* style = void;

    nk_vec2 item_padding = void;
    nk_rect bounds = void;
    nk_text text = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout) return;

    win = ctx.current;
    style = &ctx.style;
    nk_panel_alloc_space(&bounds, ctx);
    item_padding = style.text.padding;

    text.padding.x = item_padding.x;
    text.padding.y = item_padding.y;
    text.background = style.window.background;
    text.text = color;
    nk_widget_text_wrap(&win.buffer, bounds, str, len, &text, style.font);
}
version (NK_INCLUDE_STANDARD_VARARGS) {
    import core.stdc.stdarg;
    
    void nk_labelf_colored(nk_context* ctx, nk_flags flags, nk_color color, const(char)* fmt, ...)
    {
        va_list args = void;
        va_start(args, fmt);
        nk_labelfv_colored(ctx, flags, color, fmt, args);
        va_end(args);
    }
    void nk_labelf_colored_wrap(nk_context* ctx, nk_color color, const(char)* fmt, ...)
    {
        va_list args = void;
        va_start(args, fmt);
        nk_labelfv_colored_wrap(ctx, color, fmt, args);
        va_end(args);
    }
    void nk_labelf(nk_context* ctx, nk_flags flags, const(char)* fmt, ...)
    {
        va_list args = void;
        va_start(args, fmt);
        nk_labelfv(ctx, flags, fmt, args);
        va_end(args);
    }
    void nk_labelf_wrap(nk_context* ctx, const(char)* fmt, ...)
    {
        va_list args = void;
        va_start(args, fmt);
        nk_labelfv_wrap(ctx, fmt, args);
        va_end(args);
    }
    void nk_labelfv_colored(nk_context* ctx, nk_flags flags, nk_color color, const(char)* fmt, va_list args)
    {
        char[256] buf = void;
        nk_strfmt(buf.ptr, (buf.length), fmt, args);
        nk_label_colored(ctx, buf.ptr, flags, color);
    }

    void nk_labelfv_colored_wrap(nk_context* ctx, nk_color color, const(char)* fmt, va_list args)
    {
        char[256] buf = void;
        nk_strfmt(buf.ptr, buf.length, fmt, args);
        nk_label_colored_wrap(ctx, buf.ptr, color);
    }

    void nk_labelfv(nk_context* ctx, nk_flags flags, const(char)* fmt, va_list args)
    {
        char[256] buf = void;
        nk_strfmt(buf.ptr, buf.length, fmt, args);
        nk_label(ctx, buf.ptr, flags);
    }

    void nk_labelfv_wrap(nk_context* ctx, const(char)* fmt, va_list args)
    {
        char[256] buf = void;
        nk_strfmt(buf.ptr, buf.length, fmt, args);
        nk_label_wrap(ctx, buf.ptr);
    }

    void nk_value_bool(nk_context* ctx, const(char)* prefix, int value)
    {
        nk_labelf(ctx, NK_TEXT_LEFT, "%s: %s", prefix, ((value) ? cast(char*)"true": cast(char*)"false"));
    }
    void nk_value_int(nk_context* ctx, const(char)* prefix, int value)
    {
        nk_labelf(ctx, NK_TEXT_LEFT, "%s: %d", prefix, value);
    }
    void nk_value_uint(nk_context* ctx, const(char)* prefix, uint value)
    {
        nk_labelf(ctx, NK_TEXT_LEFT, "%s: %u", prefix, value);
    }
    void nk_value_float(nk_context* ctx, const(char)* prefix, float value)
    {
        double double_value = cast(double)value;
        nk_labelf(ctx, NK_TEXT_LEFT, "%s: %.3f", prefix, double_value);
    }
    void nk_value_color_byte(nk_context* ctx, const(char)* p, nk_color c)
    {
        nk_labelf(ctx, NK_TEXT_LEFT, "%s: (%d, %d, %d, %d)", p, c.r, c.g, c.b, c.a);
    }
    void nk_value_color_float(nk_context* ctx, const(char)* p, nk_color color)
    {
        double[4] c = void; nk_color_dv(c.ptr, color);
        nk_labelf(ctx, NK_TEXT_LEFT, "%s: (%.2f, %.2f, %.2f, %.2f)",
            p, c[0], c[1], c[2], c[3]);
    }
    void nk_value_color_hex(nk_context* ctx, const(char)* prefix, nk_color color)
    {
        char[16] hex = void;
        nk_color_hex_rgba(hex.ptr, color);
        nk_labelf(ctx, NK_TEXT_LEFT, "%s: %s", prefix, hex.ptr);
    }
}

void nk_text_(nk_context* ctx, const(char)* str, int len, nk_flags alignment)
{
    assert(ctx);
    if (!ctx) return;
    nk_text_colored(ctx, str, len, alignment, ctx.style.text.color);
}
void nk_text_wrap(nk_context* ctx, const(char)* str, int len)
{
    assert(ctx);
    if (!ctx) return;
    nk_text_wrap_colored(ctx, str, len, ctx.style.text.color);
}
void nk_label(nk_context* ctx, const(char)* str, nk_flags alignment)
{
    nk_text_(ctx, str, nk_strlen(str), alignment);
}
void nk_label_colored(nk_context* ctx, const(char)* str, nk_flags align_, nk_color color)
{
    nk_text_colored(ctx, str, nk_strlen(str), align_, color);
}
void nk_label_wrap(nk_context* ctx, const(char)* str)
{
    nk_text_wrap(ctx, str, nk_strlen(str));
}
void nk_label_colored_wrap(nk_context* ctx, const(char)* str, nk_color color)
{
    nk_text_wrap_colored(ctx, str, nk_strlen(str), color);
}

