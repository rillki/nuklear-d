module nuklear.nuklear_tooltip;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              TOOLTIP
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_popup;
import nuklear.nuklear_layout;
import nuklear.nuklear_text;

nk_bool nk_tooltip_begin(nk_context* ctx, float width)
{
    int x = void, y = void, w = void, h = void;
    nk_window* win = void;
    const(nk_input)* in_ = void;
    nk_rect bounds = void;
    int ret = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    /* make sure that no nonblocking popup is currently active */
    win = ctx.current;
    in_ = &ctx.input;
    if (win.popup.win && (win.popup.type & NK_PANEL_SET_NONBLOCK))
        return 0;

    w = nk_iceilf(width);
    h = nk_iceilf(nk_null_rect.h);
    x = nk_ifloorf(in_.mouse.pos.x + 1) - cast(int)win.layout.clip.x;
    y = nk_ifloorf(in_.mouse.pos.y + 1) - cast(int)win.layout.clip.y;

    bounds.x = cast(float)x;
    bounds.y = cast(float)y;
    bounds.w = cast(float)w;
    bounds.h = cast(float)h;

    ret = nk_popup_begin(ctx, NK_POPUP_DYNAMIC,
        "__##Tooltip##__", NK_WINDOW_NO_SCROLLBAR|NK_WINDOW_BORDER, bounds);
    if (ret) win.layout.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
    win.popup.type = NK_PANEL_TOOLTIP;
    ctx.current.layout.type = NK_PANEL_TOOLTIP;
    return cast(nk_bool)ret;
}

void nk_tooltip_end(nk_context* ctx)
{
    assert(ctx);
    assert(ctx.current);
    if (!ctx || !ctx.current) return;
    ctx.current.seq--;
    nk_popup_close(ctx);
    nk_popup_end(ctx);
}
void nk_tooltip(nk_context* ctx, const(char)* text)
{
    const(nk_style)* style = void;
    nk_vec2 padding = void;

    int text_len = void;
    float text_width = void;
    float text_height = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    assert(text);
    if (!ctx || !ctx.current || !ctx.current.layout || !text)
        return;

    /* fetch configuration data */
    style = &ctx.style;
    padding = style.window.padding;

    /* calculate size of the text and tooltip */
    text_len = nk_strlen(text);
    text_width = style.font.width(cast(nk_handle)style.font.userdata,
                    style.font.height, text, text_len);
    text_width += (4 * padding.x);
    text_height = (style.font.height + 2 * padding.y);

    /* execute tooltip and fill with text */
    if (nk_tooltip_begin(ctx, cast(float)text_width)) {
        nk_layout_row_dynamic(ctx, cast(float)text_height, 1);
        nk_text_(ctx, text, text_len, NK_TEXT_LEFT);
        nk_tooltip_end(ctx);
    }
}
version (NK_INCLUDE_STANDARD_VARARGS) {
    import core.stdc.stdarg;
    void nk_tooltipf(nk_context* ctx, const(char)* fmt, ...)
    {
        va_list args = void;
        va_start(args, fmt);
        nk_tooltipfv(ctx, fmt, args);
        va_end(args);
    }
    void nk_tooltipfv(nk_context* ctx, const(char)* fmt, va_list args)
    {
        char[256] buf = void;
        nk_strfmt(buf.ptr, buf.length, fmt, args);
        nk_tooltip(ctx, buf.ptr);
    }
}

