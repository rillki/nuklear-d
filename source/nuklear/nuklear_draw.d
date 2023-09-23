module nuklear.nuklear_draw;
extern(C) @nogc nothrow:
__gshared:

/* ==============================================================
 *
 *                          DRAW
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_buffer;

void nk_command_buffer_init(nk_command_buffer* cb, nk_buffer* b, nk_command_clipping clip)
{
    assert(cb);
    assert(b);
    if (!cb || !b) return;
    cb.base = b;
    cb.use_clipping = cast(int)clip;
    cb.begin = b.allocated;
    cb.end = b.allocated;
    cb.last = b.allocated;
}
void nk_command_buffer_reset(nk_command_buffer* b)
{
    assert(b);
    if (!b) return;
    b.begin = 0;
    b.end = 0;
    b.last = 0;
    b.clip = nk_null_rect;
version (NK_INCLUDE_COMMAND_USERDATA) {
    b.userdata.ptr = 0;
}
}
void* nk_command_buffer_push(nk_command_buffer* b, nk_command_type t, nk_size size)
{
    enum nk_size align_ = nk_command.alignof;
    nk_command* cmd = void;
    nk_size alignment = void;
    void* unaligned = void;
    void* memory = void;

    assert(b);
    assert(b.base);
    if (!b) return null;
    cmd = cast(nk_command*)nk_buffer_alloc(b.base,NK_BUFFER_FRONT,size,align_);
    if (!cmd) return null;

    /* make sure the offset to the next command is aligned */
    b.last = cast(nk_size)(cast(nk_byte*)cmd - cast(nk_byte*)b.base.memory.ptr);
    unaligned = cast(nk_byte*)cmd + size;
    memory = nk_align_ptr(unaligned, align_);
    alignment = cast(nk_size)(cast(nk_byte*)memory - cast(nk_byte*)unaligned);
version (NK_ZERO_COMMAND_MEMORY) {
    NK_MEMSET(cmd, 0, size + alignment);
}

    cmd.type = t;
    cmd.next = b.base.allocated + alignment;
version (NK_INCLUDE_COMMAND_USERDATA) {
    cmd.userdata = b.userdata;
}
    b.end = cmd.next;
    return cmd;
}
void nk_push_scissor(nk_command_buffer* b, nk_rect r)
{
    nk_command_scissor* cmd = void;
    assert(b);
    if (!b) return;

    b.clip.x = r.x;
    b.clip.y = r.y;
    b.clip.w = r.w;
    b.clip.h = r.h;
    cmd = cast(nk_command_scissor*)
        nk_command_buffer_push(b, NK_COMMAND_SCISSOR, typeof(*cmd).sizeof);

    if (!cmd) return;
    cmd.x = cast(short)r.x;
    cmd.y = cast(short)r.y;
    cmd.w = cast(ushort)nk_max(0, r.w);
    cmd.h = cast(ushort)nk_max(0, r.h);
}
void nk_stroke_line(nk_command_buffer* b, float x0, float y0, float x1, float y1, float line_thickness, nk_color c)
{
    nk_command_line* cmd = void;
    assert(b);
    if (!b || line_thickness <= 0) return;
    cmd = cast(nk_command_line*)
        nk_command_buffer_push(b, NK_COMMAND_LINE, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.line_thickness = cast(ushort)line_thickness;
    cmd.begin.x = cast(short)x0;
    cmd.begin.y = cast(short)y0;
    cmd.end.x = cast(short)x1;
    cmd.end.y = cast(short)y1;
    cmd.color = c;
}
void nk_stroke_curve(nk_command_buffer* b, float ax, float ay, float ctrl0x, float ctrl0y, float ctrl1x, float ctrl1y, float bx, float by, float line_thickness, nk_color col)
{
    nk_command_curve* cmd = void;
    assert(b);
    if (!b || col.a == 0 || line_thickness <= 0) return;

    cmd = cast(nk_command_curve*)
        nk_command_buffer_push(b, NK_COMMAND_CURVE, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.line_thickness = cast(ushort)line_thickness;
    cmd.begin.x = cast(short)ax;
    cmd.begin.y = cast(short)ay;
    cmd.ctrl[0].x = cast(short)ctrl0x;
    cmd.ctrl[0].y = cast(short)ctrl0y;
    cmd.ctrl[1].x = cast(short)ctrl1x;
    cmd.ctrl[1].y = cast(short)ctrl1y;
    cmd.end.x = cast(short)bx;
    cmd.end.y = cast(short)by;
    cmd.color = col;
}
void nk_stroke_rect(nk_command_buffer* b, nk_rect rect, float rounding, float line_thickness, nk_color c)
{
    nk_command_rect* cmd = void;
    assert(b);
    if (!b || c.a == 0 || rect.w == 0 || rect.h == 0 || line_thickness <= 0) return;
    if (b.use_clipping) {
        const(nk_rect)* clip = &b.clip;
        if (!nk_intersect(rect.x, rect.y, rect.w, rect.h,
            clip.x, clip.y, clip.w, clip.h)) return;
    }
    cmd = cast(nk_command_rect*)
        nk_command_buffer_push(b, NK_COMMAND_RECT, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.rounding = cast(ushort)rounding;
    cmd.line_thickness = cast(ushort)line_thickness;
    cmd.x = cast(short)rect.x;
    cmd.y = cast(short)rect.y;
    cmd.w = cast(ushort)nk_max(0, rect.w);
    cmd.h = cast(ushort)nk_max(0, rect.h);
    cmd.color = c;
}
void nk_fill_rect(nk_command_buffer* b, nk_rect rect, float rounding, nk_color c)
{
    nk_command_rect_filled* cmd = void;
    assert(b);
    if (!b || c.a == 0 || rect.w == 0 || rect.h == 0) return;
    if (b.use_clipping) {
        const(nk_rect)* clip = &b.clip;
        if (!nk_intersect(rect.x, rect.y, rect.w, rect.h,
            clip.x, clip.y, clip.w, clip.h)) return;
    }

    cmd = cast(nk_command_rect_filled*)
        nk_command_buffer_push(b, NK_COMMAND_RECT_FILLED, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.rounding = cast(ushort)rounding;
    cmd.x = cast(short)rect.x;
    cmd.y = cast(short)rect.y;
    cmd.w = cast(ushort)nk_max(0, rect.w);
    cmd.h = cast(ushort)nk_max(0, rect.h);
    cmd.color = c;
}
void nk_fill_rect_multi_color(nk_command_buffer* b, nk_rect rect, nk_color left, nk_color top, nk_color right, nk_color bottom)
{
    nk_command_rect_multi_color* cmd = void;
    assert(b);
    if (!b || rect.w == 0 || rect.h == 0) return;
    if (b.use_clipping) {
        const(nk_rect)* clip = &b.clip;
        if (!nk_intersect(rect.x, rect.y, rect.w, rect.h,
            clip.x, clip.y, clip.w, clip.h)) return;
    }

    cmd = cast(nk_command_rect_multi_color*)
        nk_command_buffer_push(b, NK_COMMAND_RECT_MULTI_COLOR, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.x = cast(short)rect.x;
    cmd.y = cast(short)rect.y;
    cmd.w = cast(ushort)nk_max(0, rect.w);
    cmd.h = cast(ushort)nk_max(0, rect.h);
    cmd.left = left;
    cmd.top = top;
    cmd.right = right;
    cmd.bottom = bottom;
}
void nk_stroke_circle(nk_command_buffer* b, nk_rect r, float line_thickness, nk_color c)
{
    nk_command_circle* cmd = void;
    if (!b || r.w == 0 || r.h == 0 || line_thickness <= 0) return;
    if (b.use_clipping) {
        const(nk_rect)* clip = &b.clip;
        if (!nk_intersect(r.x, r.y, r.w, r.h, clip.x, clip.y, clip.w, clip.h))
            return;
    }

    cmd = cast(nk_command_circle*)
        nk_command_buffer_push(b, NK_COMMAND_CIRCLE, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.line_thickness = cast(ushort)line_thickness;
    cmd.x = cast(short)r.x;
    cmd.y = cast(short)r.y;
    cmd.w = cast(ushort)nk_max(r.w, 0);
    cmd.h = cast(ushort)nk_max(r.h, 0);
    cmd.color = c;
}
void nk_fill_circle(nk_command_buffer* b, nk_rect r, nk_color c)
{
    nk_command_circle_filled* cmd = void;
    assert(b);
    if (!b || c.a == 0 || r.w == 0 || r.h == 0) return;
    if (b.use_clipping) {
        const(nk_rect)* clip = &b.clip;
        if (!nk_intersect(r.x, r.y, r.w, r.h, clip.x, clip.y, clip.w, clip.h))
            return;
    }

    cmd = cast(nk_command_circle_filled*)
        nk_command_buffer_push(b, NK_COMMAND_CIRCLE_FILLED, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.x = cast(short)r.x;
    cmd.y = cast(short)r.y;
    cmd.w = cast(ushort)nk_max(r.w, 0);
    cmd.h = cast(ushort)nk_max(r.h, 0);
    cmd.color = c;
}
void nk_stroke_arc(nk_command_buffer* b, float cx, float cy, float radius, float a_min, float a_max, float line_thickness, nk_color c)
{
    nk_command_arc* cmd = void;
    if (!b || c.a == 0 || line_thickness <= 0) return;
    cmd = cast(nk_command_arc*)
        nk_command_buffer_push(b, NK_COMMAND_ARC, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.line_thickness = cast(ushort)line_thickness;
    cmd.cx = cast(short)cx;
    cmd.cy = cast(short)cy;
    cmd.r = cast(ushort)radius;
    cmd.a[0] = a_min;
    cmd.a[1] = a_max;
    cmd.color = c;
}
void nk_fill_arc(nk_command_buffer* b, float cx, float cy, float radius, float a_min, float a_max, nk_color c)
{
    nk_command_arc_filled* cmd = void;
    assert(b);
    if (!b || c.a == 0) return;
    cmd = cast(nk_command_arc_filled*)
        nk_command_buffer_push(b, NK_COMMAND_ARC_FILLED, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.cx = cast(short)cx;
    cmd.cy = cast(short)cy;
    cmd.r = cast(ushort)radius;
    cmd.a[0] = a_min;
    cmd.a[1] = a_max;
    cmd.color = c;
}
void nk_stroke_triangle(nk_command_buffer* b, float x0, float y0, float x1, float y1, float x2, float y2, float line_thickness, nk_color c)
{
    nk_command_triangle* cmd = void;
    assert(b);
    if (!b || c.a == 0 || line_thickness <= 0) return;
    if (b.use_clipping) {
        const(nk_rect)* clip = &b.clip;
        if (!nk_inbox(x0, y0, clip.x, clip.y, clip.w, clip.h) &&
            !nk_inbox(x1, y1, clip.x, clip.y, clip.w, clip.h) &&
            !nk_inbox(x2, y2, clip.x, clip.y, clip.w, clip.h))
            return;
    }

    cmd = cast(nk_command_triangle*)
        nk_command_buffer_push(b, NK_COMMAND_TRIANGLE, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.line_thickness = cast(ushort)line_thickness;
    cmd.a.x = cast(short)x0;
    cmd.a.y = cast(short)y0;
    cmd.b.x = cast(short)x1;
    cmd.b.y = cast(short)y1;
    cmd.c.x = cast(short)x2;
    cmd.c.y = cast(short)y2;
    cmd.color = c;
}
void nk_fill_triangle(nk_command_buffer* b, float x0, float y0, float x1, float y1, float x2, float y2, nk_color c)
{
    nk_command_triangle_filled* cmd = void;
    assert(b);
    if (!b || c.a == 0) return;
    if (!b) return;
    if (b.use_clipping) {
        const(nk_rect)* clip = &b.clip;
        if (!nk_inbox(x0, y0, clip.x, clip.y, clip.w, clip.h) &&
            !nk_inbox(x1, y1, clip.x, clip.y, clip.w, clip.h) &&
            !nk_inbox(x2, y2, clip.x, clip.y, clip.w, clip.h))
            return;
    }

    cmd = cast(nk_command_triangle_filled*)
        nk_command_buffer_push(b, NK_COMMAND_TRIANGLE_FILLED, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.a.x = cast(short)x0;
    cmd.a.y = cast(short)y0;
    cmd.b.x = cast(short)x1;
    cmd.b.y = cast(short)y1;
    cmd.c.x = cast(short)x2;
    cmd.c.y = cast(short)y2;
    cmd.color = c;
}
void nk_stroke_polygon(nk_command_buffer* b, float* points, int point_count, float line_thickness, nk_color col)
{
    int i = void;
    nk_size size = 0;
    nk_command_polygon* cmd = void;

    assert(b);
    if (!b || col.a == 0 || line_thickness <= 0) return;
    size = typeof(*cmd).sizeof + short.sizeof * 2 * cast(nk_size)point_count;
    cmd = cast(nk_command_polygon*) nk_command_buffer_push(b, NK_COMMAND_POLYGON, size);
    if (!cmd) return;
    cmd.color = col;
    cmd.line_thickness = cast(ushort)line_thickness;
    cmd.point_count = cast(ushort)point_count;
    for (i = 0; i < point_count; ++i) {
        cmd.points[i].x = cast(short)points[i*2];
        cmd.points[i].y = cast(short)points[i*2+1];
    }
}
void nk_fill_polygon(nk_command_buffer* b, float* points, int point_count, nk_color col)
{
    int i = void;
    nk_size size = 0;
    nk_command_polygon_filled* cmd = void;

    assert(b);
    if (!b || col.a == 0) return;
    size = typeof(*cmd).sizeof + short.sizeof * 2 * cast(nk_size)point_count;
    cmd = cast(nk_command_polygon_filled*)
        nk_command_buffer_push(b, NK_COMMAND_POLYGON_FILLED, size);
    if (!cmd) return;
    cmd.color = col;
    cmd.point_count = cast(ushort)point_count;
    for (i = 0; i < point_count; ++i) {
        cmd.points[i].x = cast(short)points[i*2+0];
        cmd.points[i].y = cast(short)points[i*2+1];
    }
}
void nk_stroke_polyline(nk_command_buffer* b, float* points, int point_count, float line_thickness, nk_color col)
{
    int i = void;
    nk_size size = 0;
    nk_command_polyline* cmd = void;

    assert(b);
    if (!b || col.a == 0 || line_thickness <= 0) return;
    size = typeof(*cmd).sizeof + short.sizeof * 2 * cast(nk_size)point_count;
    cmd = cast(nk_command_polyline*) nk_command_buffer_push(b, NK_COMMAND_POLYLINE, size);
    if (!cmd) return;
    cmd.color = col;
    cmd.point_count = cast(ushort)point_count;
    cmd.line_thickness = cast(ushort)line_thickness;
    for (i = 0; i < point_count; ++i) {
        cmd.points[i].x = cast(short)points[i*2];
        cmd.points[i].y = cast(short)points[i*2+1];
    }
}
void nk_draw_image(nk_command_buffer* b, nk_rect r, const(nk_image)* img, nk_color col)
{
    nk_command_image* cmd = void;
    assert(b);
    if (!b) return;
    if (b.use_clipping) {
        const(nk_rect)* c = &b.clip;
        if (c.w == 0 || c.h == 0 || !nk_intersect(r.x, r.y, r.w, r.h, c.x, c.y, c.w, c.h))
            return;
    }

    cmd = cast(nk_command_image*)
        nk_command_buffer_push(b, NK_COMMAND_IMAGE, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.x = cast(short)r.x;
    cmd.y = cast(short)r.y;
    cmd.w = cast(ushort)nk_max(0, r.w);
    cmd.h = cast(ushort)nk_max(0, r.h);
    cmd.img = cast(nk_image)*img;
    cmd.col = col;
}
void nk_draw_nine_slice(nk_command_buffer* b, nk_rect r, const(nk_nine_slice)* slc, nk_color col)
{
    nk_image img = void;
    const(nk_image)* slcimg = cast(const(nk_image)*)slc;
    nk_ushort rgnX = void, rgnY = void, rgnW = void, rgnH = void;
    rgnX = slcimg.region[0];
    rgnY = slcimg.region[1];
    rgnW = slcimg.region[2];
    rgnH = slcimg.region[3];

    /* top-left */
    img.handle = cast(nk_handle)slcimg.handle;
    img.w = slcimg.w;
    img.h = slcimg.h;
    img.region[0] = rgnX;
    img.region[1] = rgnY;
    img.region[2] = slc.l;
    img.region[3] = slc.t;

    nk_draw_image(b,
        nk_rect(r.x, r.y, cast(float)slc.l, cast(float)slc.t),
        &img, col);

enum string IMG_RGN(string x, string y, string w, string h) = `img.region[0] = cast(nk_ushort)(` ~ x ~ `); img.region[1] = cast(nk_ushort)(` ~ y ~ `); img.region[2] = cast(nk_ushort)(` ~ w ~ `); img.region[3] = cast(nk_ushort)(` ~ h ~ `);`;

    /* top-center */
    mixin(IMG_RGN!(`rgnX + slc.l`, `rgnY`, `rgnW - slc.l - slc.r`, `slc.t`));
    nk_draw_image(b,
        nk_rect(r.x + cast(float)slc.l, r.y, cast(float)(r.w - slc.l - slc.r), cast(float)slc.t),
        &img, col);

    /* top-right */
    mixin(IMG_RGN!(`rgnX + rgnW - slc.r`, `rgnY`, `slc.r`, `slc.t`));
    nk_draw_image(b,
        nk_rect(r.x + r.w - cast(float)slc.r, r.y, cast(float)slc.r, cast(float)slc.t),
        &img, col);

    /* center-left */
    mixin(IMG_RGN!(`rgnX`, `rgnY + slc.t`, `slc.l`, `rgnH - slc.t - slc.b`));
    nk_draw_image(b,
        nk_rect(r.x, r.y + cast(float)slc.t, cast(float)slc.l, cast(float)(r.h - slc.t - slc.b)),
        &img, col);

    /* center */
    mixin(IMG_RGN!(`rgnX + slc.l`, `rgnY + slc.t`, `rgnW - slc.l - slc.r`, `rgnH - slc.t - slc.b`));
    nk_draw_image(b,
        nk_rect(r.x + cast(float)slc.l, r.y + cast(float)slc.t, cast(float)(r.w - slc.l - slc.r), cast(float)(r.h - slc.t - slc.b)),
        &img, col);

    /* center-right */
    mixin(IMG_RGN!(`rgnX + rgnW - slc.r`, `rgnY + slc.t`, `slc.r`, `rgnH - slc.t - slc.b`));
    nk_draw_image(b,
        nk_rect(r.x + r.w - cast(float)slc.r, r.y + cast(float)slc.t, cast(float)slc.r, cast(float)(r.h - slc.t - slc.b)),
        &img, col);

    /* bottom-left */
    mixin(IMG_RGN!(`rgnX`, `rgnY + rgnH - slc.b`, `slc.l`, `slc.b`));
    nk_draw_image(b,
        nk_rect(r.x, r.y + r.h - cast(float)slc.b, cast(float)slc.l, cast(float)slc.b),
        &img, col);

    /* bottom-center */
    mixin(IMG_RGN!(`rgnX + slc.l`, `rgnY + rgnH - slc.b`, `rgnW - slc.l - slc.r`, `slc.b`));
    nk_draw_image(b,
        nk_rect(r.x + cast(float)slc.l, r.y + r.h - cast(float)slc.b, cast(float)(r.w - slc.l - slc.r), cast(float)slc.b),
        &img, col);

    /* bottom-right */
    mixin(IMG_RGN!(`rgnX + rgnW - slc.r`, `rgnY + rgnH - slc.b`, `slc.r`, `slc.b`));
    nk_draw_image(b,
        nk_rect(r.x + r.w - cast(float)slc.r, r.y + r.h - cast(float)slc.b, cast(float)slc.r, cast(float)slc.b),
        &img, col);

}
void nk_push_custom(nk_command_buffer* b, nk_rect r, nk_command_custom_callback cb, nk_handle usr)
{
    nk_command_custom* cmd = void;
    assert(b);
    if (!b) return;
    if (b.use_clipping) {
        const(nk_rect)* c = &b.clip;
        if (c.w == 0 || c.h == 0 || !nk_intersect(r.x, r.y, r.w, r.h, c.x, c.y, c.w, c.h))
            return;
    }

    cmd = cast(nk_command_custom*)
        nk_command_buffer_push(b, NK_COMMAND_CUSTOM, typeof(*cmd).sizeof);
    if (!cmd) return;
    cmd.x = cast(short)r.x;
    cmd.y = cast(short)r.y;
    cmd.w = cast(ushort)nk_max(0, r.w);
    cmd.h = cast(ushort)nk_max(0, r.h);
    cmd.callback_data = usr;
    cmd.callback = cb;
}
void nk_draw_text(nk_command_buffer* b, nk_rect r, const(char)* string, int length, const(nk_user_font)* font, nk_color bg, nk_color fg)
{
    float text_width = 0;
    nk_command_text* cmd = void;

    assert(b);
    assert(font);
    if (!b || !string || !length || (bg.a == 0 && fg.a == 0)) return;
    if (b.use_clipping) {
        const(nk_rect)* c = &b.clip;
        if (c.w == 0 || c.h == 0 || !nk_intersect(r.x, r.y, r.w, r.h, c.x, c.y, c.w, c.h))
            return;
    }

    /* make sure text fits inside bounds */
    text_width = font.width(cast(nk_handle)font.userdata, font.height, string, length);
    if (text_width > r.w){
        int glyphs = 0;
        float txt_width = cast(float)text_width;
        length = nk_text_clamp(font, string, length, r.w, &glyphs, &txt_width, null, 0);
    }

    if (!length) return;
    cmd = cast(nk_command_text*)
        nk_command_buffer_push(b, NK_COMMAND_TEXT, typeof(*cmd).sizeof + cast(nk_size)(length + 1));
    if (!cmd) return;
    cmd.x = cast(short)r.x;
    cmd.y = cast(short)r.y;
    cmd.w = cast(ushort)r.w;
    cmd.h = cast(ushort)r.h;
    cmd.background = bg;
    cmd.foreground = fg;
    cmd.font = font;
    cmd.length = length;
    cmd.height = font.height;
    nk_memcopy(cmd.string.ptr, string, cast(nk_size)length);
    cmd.string[length] = '\0';
}

