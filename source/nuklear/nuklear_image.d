module nuklear.nuklear_image;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          IMAGE
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_widget;
import nuklear.nuklear_draw;

nk_handle nk_handle_ptr(void* ptr)
{
    nk_handle handle;
    handle.ptr = ptr;
    return handle;
}
nk_handle nk_handle_id(int id)
{
    nk_handle handle = void;
    nk_zero_struct(handle);
    handle.id = id;
    return handle;
}
nk_image nk_subimage_ptr(void* ptr, nk_ushort w, nk_ushort h, nk_rect r)
{
    nk_image s = void;
    nk_zero(&s, s.sizeof);
    s.handle.ptr = ptr;
    s.w = w; s.h = h;
    s.region[0] = cast(nk_ushort)r.x;
    s.region[1] = cast(nk_ushort)r.y;
    s.region[2] = cast(nk_ushort)r.w;
    s.region[3] = cast(nk_ushort)r.h;
    return s;
}
nk_image nk_subimage_id(int id, nk_ushort w, nk_ushort h, nk_rect r)
{
    nk_image s = void;
    nk_zero(&s, s.sizeof);
    s.handle.id = id;
    s.w = w; s.h = h;
    s.region[0] = cast(nk_ushort)r.x;
    s.region[1] = cast(nk_ushort)r.y;
    s.region[2] = cast(nk_ushort)r.w;
    s.region[3] = cast(nk_ushort)r.h;
    return s;
}
nk_image nk_subimage_handle(nk_handle handle, nk_ushort w, nk_ushort h, nk_rect r)
{
    nk_image s = void;
    nk_zero(&s, s.sizeof);
    s.handle = handle;
    s.w = w; s.h = h;
    s.region[0] = cast(nk_ushort)r.x;
    s.region[1] = cast(nk_ushort)r.y;
    s.region[2] = cast(nk_ushort)r.w;
    s.region[3] = cast(nk_ushort)r.h;
    return s;
}
nk_image nk_image_handle(nk_handle handle)
{
    nk_image s = void;
    nk_zero(&s, s.sizeof);
    s.handle = handle;
    s.w = 0; s.h = 0;
    s.region[0] = 0;
    s.region[1] = 0;
    s.region[2] = 0;
    s.region[3] = 0;
    return s;
}
nk_image nk_image_ptr(void* ptr)
{
    nk_image s = void;
    nk_zero(&s, s.sizeof);
    assert(ptr);
    s.handle.ptr = ptr;
    s.w = 0; s.h = 0;
    s.region[0] = 0;
    s.region[1] = 0;
    s.region[2] = 0;
    s.region[3] = 0;
    return s;
}
nk_image nk_image_id(int id)
{
    nk_image s = void;
    nk_zero(&s, s.sizeof);
    s.handle.id = id;
    s.w = 0; s.h = 0;
    s.region[0] = 0;
    s.region[1] = 0;
    s.region[2] = 0;
    s.region[3] = 0;
    return s;
}
nk_bool nk_image_is_subimage(const(nk_image)* img)
{
    assert(img);
    return !(img.w == 0 && img.h == 0);
}

pragma(mangle, "nk_image")
void nk_image_(nk_context* ctx, nk_image img)
{
    nk_window* win = void;
    nk_rect bounds = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout) return;

    win = ctx.current;
    if (!nk_widget(&bounds, ctx)) return;
    nk_draw_image(&win.buffer, bounds, &img, nk_white);
}
void nk_image_color(nk_context* ctx, nk_image img, nk_color col)
{
    nk_window* win = void;
    nk_rect bounds = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout) return;

    win = ctx.current;
    if (!nk_widget(&bounds, ctx)) return;
    nk_draw_image(&win.buffer, bounds, &img, col);
}

