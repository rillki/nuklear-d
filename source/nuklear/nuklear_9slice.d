module nuklear.nuklear_9slice;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          9-SLICE
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

nk_nine_slice nk_sub9slice_ptr(void* ptr, nk_ushort w, nk_ushort h, nk_rect rgn, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b)
{
    nk_nine_slice s = void;
    nk_image* i = &s.img;
    nk_zero(&s, s.sizeof);
    i.handle.ptr = ptr;
    i.w = w; i.h = h;
    i.region[0] = cast(nk_ushort)rgn.x;
    i.region[1] = cast(nk_ushort)rgn.y;
    i.region[2] = cast(nk_ushort)rgn.w;
    i.region[3] = cast(nk_ushort)rgn.h;
    s.l = l; s.t = t; s.r = r; s.b = b;
    return s;
}

nk_nine_slice nk_sub9slice_id(int id, nk_ushort w, nk_ushort h, nk_rect rgn, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b)
{
    nk_nine_slice s = void;
    nk_image* i = &s.img;
    nk_zero(&s, s.sizeof);
    i.handle.id = id;
    i.w = w; i.h = h;
    i.region[0] = cast(nk_ushort)rgn.x;
    i.region[1] = cast(nk_ushort)rgn.y;
    i.region[2] = cast(nk_ushort)rgn.w;
    i.region[3] = cast(nk_ushort)rgn.h;
    s.l = l; s.t = t; s.r = r; s.b = b;
    return s;
}

nk_nine_slice nk_sub9slice_handle(nk_handle handle, nk_ushort w, nk_ushort h, nk_rect rgn, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b)
{
    nk_nine_slice s = void;
    nk_image* i = &s.img;
    nk_zero(&s, s.sizeof);
    i.handle = handle;
    i.w = w; i.h = h;
    i.region[0] = cast(nk_ushort)rgn.x;
    i.region[1] = cast(nk_ushort)rgn.y;
    i.region[2] = cast(nk_ushort)rgn.w;
    i.region[3] = cast(nk_ushort)rgn.h;
    s.l = l; s.t = t; s.r = r; s.b = b;
    return s;
}

nk_nine_slice nk_nine_slice_handle(nk_handle handle, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b)
{
    nk_nine_slice s = void;
    nk_image* i = &s.img;
    nk_zero(&s, s.sizeof);
    i.handle = handle;
    i.w = 0; i.h = 0;
    i.region[0] = 0;
    i.region[1] = 0;
    i.region[2] = 0;
    i.region[3] = 0;
    s.l = l; s.t = t; s.r = r; s.b = b;
    return s;
}

nk_nine_slice nk_nine_slice_ptr(void* ptr, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b)
{
    nk_nine_slice s = void;
    nk_image* i = &s.img;
    nk_zero(&s, s.sizeof);
    assert(ptr);
    i.handle.ptr = ptr;
    i.w = 0; i.h = 0;
    i.region[0] = 0;
    i.region[1] = 0;
    i.region[2] = 0;
    i.region[3] = 0;
    s.l = l; s.t = t; s.r = r; s.b = b;
    return s;
}

nk_nine_slice nk_nine_slice_id(int id, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b)
{
    nk_nine_slice s = void;
    nk_image* i = &s.img;
    nk_zero(&s, s.sizeof);
    i.handle.id = id;
    i.w = 0; i.h = 0;
    i.region[0] = 0;
    i.region[1] = 0;
    i.region[2] = 0;
    i.region[3] = 0;
    s.l = l; s.t = t; s.r = r; s.b = b;
    return s;
}

int nk_nine_slice_is_sub9slice(const(nk_nine_slice)* slice)
{
    assert(slice);
    return !(slice.img.w == 0 && slice.img.h == 0);
}


