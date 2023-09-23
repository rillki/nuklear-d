module nuklear.nuklear_color;
extern(C) @nogc nothrow:
__gshared:

/* ==============================================================
 *
 *                          COLOR
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

int nk_parse_hex(const(char)* p, int length)
{
    int i = 0;
    int len = 0;
    while (len < length) {
        i <<= 4;
        if (p[len] >= 'a' && p[len] <= 'f')
            i += ((p[len] - 'a') + 10);
        else if (p[len] >= 'A' && p[len] <= 'F')
            i += ((p[len] - 'A') + 10);
        else i += (p[len] - '0');
        len++;
    }
    return i;
}
nk_color nk_rgba(int r, int g, int b, int a)
{
    nk_color ret = void;
    ret.r = cast(nk_byte)nk_clamp(0, r, 255);
    ret.g = cast(nk_byte)nk_clamp(0, g, 255);
    ret.b = cast(nk_byte)nk_clamp(0, b, 255);
    ret.a = cast(nk_byte)nk_clamp(0, a, 255);
    return ret;
}
nk_color nk_rgb_hex(const(char)* rgb)
{
    nk_color col = void;
    const(char)* c = rgb;
    if (*c == '#') c++;
    col.r = cast(nk_byte)nk_parse_hex(c, 2);
    col.g = cast(nk_byte)nk_parse_hex(c+2, 2);
    col.b = cast(nk_byte)nk_parse_hex(c+4, 2);
    col.a = 255;
    return col;
}
nk_color nk_rgba_hex(const(char)* rgb)
{
    nk_color col = void;
    const(char)* c = rgb;
    if (*c == '#') c++;
    col.r = cast(nk_byte)nk_parse_hex(c, 2);
    col.g = cast(nk_byte)nk_parse_hex(c+2, 2);
    col.b = cast(nk_byte)nk_parse_hex(c+4, 2);
    col.a = cast(nk_byte)nk_parse_hex(c+6, 2);
    return col;
}
void nk_color_hex_rgba(char* output, nk_color col)
{
    output[0] = cast(char)nk_to_hex((col.r & 0xF0) >> 4);
    output[1] = cast(char)nk_to_hex((col.r & 0x0F));
    output[2] = cast(char)nk_to_hex((col.g & 0xF0) >> 4);
    output[3] = cast(char)nk_to_hex((col.g & 0x0F));
    output[4] = cast(char)nk_to_hex((col.b & 0xF0) >> 4);
    output[5] = cast(char)nk_to_hex((col.b & 0x0F));
    output[6] = cast(char)nk_to_hex((col.a & 0xF0) >> 4);
    output[7] = cast(char)nk_to_hex((col.a & 0x0F));
    output[8] = '\0';
}

void nk_color_hex_rgb(char* output, nk_color col)
{
    output[0] = cast(char)nk_to_hex((col.r & 0xF0) >> 4);
    output[1] = cast(char)nk_to_hex((col.r & 0x0F));
    output[2] = cast(char)nk_to_hex((col.g & 0xF0) >> 4);
    output[3] = cast(char)nk_to_hex((col.g & 0x0F));
    output[4] = cast(char)nk_to_hex((col.b & 0xF0) >> 4);
    output[5] = cast(char)nk_to_hex((col.b & 0x0F));
    output[6] = '\0';
}
nk_color nk_rgba_iv(const(int)* c)
{
    return nk_rgba(c[0], c[1], c[2], c[3]);
}
nk_color nk_rgba_bv(const(nk_byte)* c)
{
    return nk_rgba(c[0], c[1], c[2], c[3]);
}
nk_color nk_rgb(int r, int g, int b)
{
    nk_color ret = void;
    ret.r = cast(nk_byte)nk_clamp(0, r, 255);
    ret.g = cast(nk_byte)nk_clamp(0, g, 255);
    ret.b = cast(nk_byte)nk_clamp(0, b, 255);
    ret.a = cast(nk_byte)255;
    return ret;
}
nk_color nk_rgb_iv(const(int)* c)
{
    return nk_rgb(c[0], c[1], c[2]);
}
nk_color nk_rgb_bv(const(nk_byte)* c)
{
    return nk_rgb(c[0], c[1], c[2]);
}
nk_color nk_rgba_u32(nk_uint in_)
{
    nk_color ret = void;
    ret.r = (in_ & 0xFF);
    ret.g = ((in_ >> 8) & 0xFF);
    ret.b = ((in_ >> 16) & 0xFF);
    ret.a = cast(nk_byte)((in_ >> 24) & 0xFF);
    return ret;
}
nk_color nk_rgba_f(float r, float g, float b, float a)
{
    nk_color ret = void;
    ret.r = cast(nk_byte)(nk_saturate(r) * 255.0f);
    ret.g = cast(nk_byte)(nk_saturate(g) * 255.0f);
    ret.b = cast(nk_byte)(nk_saturate(b) * 255.0f);
    ret.a = cast(nk_byte)(nk_saturate(a) * 255.0f);
    return ret;
}
nk_color nk_rgba_fv(const(float)* c)
{
    return nk_rgba_f(c[0], c[1], c[2], c[3]);
}
nk_color nk_rgba_cf(nk_colorf c)
{
    return nk_rgba_f(c.r, c.g, c.b, c.a);
}
nk_color nk_rgb_f(float r, float g, float b)
{
    nk_color ret = void;
    ret.r = cast(nk_byte)(nk_saturate(r) * 255.0f);
    ret.g = cast(nk_byte)(nk_saturate(g) * 255.0f);
    ret.b = cast(nk_byte)(nk_saturate(b) * 255.0f);
    ret.a = 255;
    return ret;
}
nk_color nk_rgb_fv(const(float)* c)
{
    return nk_rgb_f(c[0], c[1], c[2]);
}
nk_color nk_rgb_cf(nk_colorf c)
{
    return nk_rgb_f(c.r, c.g, c.b);
}
nk_color nk_hsv(int h, int s, int v)
{
    return nk_hsva(h, s, v, 255);
}
nk_color nk_hsv_iv(const(int)* c)
{
    return nk_hsv(c[0], c[1], c[2]);
}
nk_color nk_hsv_bv(const(nk_byte)* c)
{
    return nk_hsv(c[0], c[1], c[2]);
}
nk_color nk_hsv_f(float h, float s, float v)
{
    return nk_hsva_f(h, s, v, 1.0f);
}
nk_color nk_hsv_fv(const(float)* c)
{
    return nk_hsv_f(c[0], c[1], c[2]);
}
nk_color nk_hsva(int h, int s, int v, int a)
{
    float hf = (cast(float)nk_clamp(0, h, 255)) / 255.0f;
    float sf = (cast(float)nk_clamp(0, s, 255)) / 255.0f;
    float vf = (cast(float)nk_clamp(0, v, 255)) / 255.0f;
    float af = (cast(float)nk_clamp(0, a, 255)) / 255.0f;
    return nk_hsva_f(hf, sf, vf, af);
}
nk_color nk_hsva_iv(const(int)* c)
{
    return nk_hsva(c[0], c[1], c[2], c[3]);
}
nk_color nk_hsva_bv(const(nk_byte)* c)
{
    return nk_hsva(c[0], c[1], c[2], c[3]);
}
nk_colorf nk_hsva_colorf(float h, float s, float v, float a)
{
    int i = void;
    float p = void, q = void, t = void, f = void;
    nk_colorf out_ = {0,0,0,0};
    if (s <= 0.0f) {
        out_.r = v; out_.g = v; out_.b = v; out_.a = a;
        return out_;
    }
    h = h / (60.0f/360.0f);
    i = cast(int)h;
    f = h - cast(float)i;
    p = v * (1.0f - s);
    q = v * (1.0f - (s * f));
    t = v * (1.0f - s * (1.0f - f));

    switch (i) {
    case 0: default: out_.r = v; out_.g = t; out_.b = p; break;
    case 1: out_.r = q; out_.g = v; out_.b = p; break;
    case 2: out_.r = p; out_.g = v; out_.b = t; break;
    case 3: out_.r = p; out_.g = q; out_.b = v; break;
    case 4: out_.r = t; out_.g = p; out_.b = v; break;
    case 5: out_.r = v; out_.g = p; out_.b = q; break;}
    out_.a = a;
    return out_;
}
nk_colorf nk_hsva_colorfv(float* c)
{
    return nk_hsva_colorf(c[0], c[1], c[2], c[3]);
}
nk_color nk_hsva_f(float h, float s, float v, float a)
{
    nk_colorf c = nk_hsva_colorf(h, s, v, a);
    return nk_rgba_f(c.r, c.g, c.b, c.a);
}
nk_color nk_hsva_fv(const(float)* c)
{
    return nk_hsva_f(c[0], c[1], c[2], c[3]);
}
nk_uint nk_color_u32(nk_color in_)
{
    nk_uint out_ = cast(nk_uint)in_.r;
    out_ |= (cast(nk_uint)in_.g << 8);
    out_ |= (cast(nk_uint)in_.b << 16);
    out_ |= (cast(nk_uint)in_.a << 24);
    return out_;
}
void nk_color_f(float* r, float* g, float* b, float* a, nk_color in_)
{
    enum float s = 1.0f/255.0f;
    *r = cast(float)in_.r * s;
    *g = cast(float)in_.g * s;
    *b = cast(float)in_.b * s;
    *a = cast(float)in_.a * s;
}
void nk_color_fv(float* c, nk_color in_)
{
    nk_color_f(&c[0], &c[1], &c[2], &c[3], in_);
}
nk_colorf nk_color_cf(nk_color in_)
{
    nk_colorf o = void;
    nk_color_f(&o.r, &o.g, &o.b, &o.a, in_);
    return o;
}
void nk_color_d(double* r, double* g, double* b, double* a, nk_color in_)
{
    enum double s = 1.0/255.0;
    *r = cast(double)in_.r * s;
    *g = cast(double)in_.g * s;
    *b = cast(double)in_.b * s;
    *a = cast(double)in_.a * s;
}
void nk_color_dv(double* c, nk_color in_)
{
    nk_color_d(&c[0], &c[1], &c[2], &c[3], in_);
}
void nk_color_hsv_f(float* out_h, float* out_s, float* out_v, nk_color in_)
{
    float a = void;
    nk_color_hsva_f(out_h, out_s, out_v, &a, in_);
}
void nk_color_hsv_fv(float* out_, nk_color in_)
{
    float a = void;
    nk_color_hsva_f(&out_[0], &out_[1], &out_[2], &a, in_);
}
void nk_colorf_hsva_f(float* out_h, float* out_s, float* out_v, float* out_a, nk_colorf in_)
{
    float chroma = void;
    float K = 0.0f;
    if (in_.g < in_.b) {
        const(float) t = in_.g; in_.g = in_.b; in_.b = t;
        K = -1.0f;
    }
    if (in_.r < in_.g) {
        const(float) t = in_.r; in_.r = in_.g; in_.g = t;
        K = -2.0f/6.0f - K;
    }
    chroma = in_.r - ((in_.g < in_.b) ? in_.g: in_.b);
    *out_h = nk_abs(K + (in_.g - in_.b)/(6.0f * chroma + 1e-20f));
    *out_s = chroma / (in_.r + 1e-20f);
    *out_v = in_.r;
    *out_a = in_.a;

}
void nk_colorf_hsva_fv(float* hsva, nk_colorf in_)
{
    nk_colorf_hsva_f(&hsva[0], &hsva[1], &hsva[2], &hsva[3], in_);
}
void nk_color_hsva_f(float* out_h, float* out_s, float* out_v, float* out_a, nk_color in_)
{
    nk_colorf col = void;
    nk_color_f(&col.r,&col.g,&col.b,&col.a, in_);
    nk_colorf_hsva_f(out_h, out_s, out_v, out_a, col);
}
void nk_color_hsva_fv(float* out_, nk_color in_)
{
    nk_color_hsva_f(&out_[0], &out_[1], &out_[2], &out_[3], in_);
}
void nk_color_hsva_i(int* out_h, int* out_s, int* out_v, int* out_a, nk_color in_)
{
    float h = void, s = void, v = void, a = void;
    nk_color_hsva_f(&h, &s, &v, &a, in_);
    *out_h = cast(nk_byte)(h * 255.0f);
    *out_s = cast(nk_byte)(s * 255.0f);
    *out_v = cast(nk_byte)(v * 255.0f);
    *out_a = cast(nk_byte)(a * 255.0f);
}
void nk_color_hsva_iv(int* out_, nk_color in_)
{
    nk_color_hsva_i(&out_[0], &out_[1], &out_[2], &out_[3], in_);
}
void nk_color_hsva_bv(nk_byte* out_, nk_color in_)
{
    int[4] tmp = void;
    nk_color_hsva_i(&tmp[0], &tmp[1], &tmp[2], &tmp[3], in_);
    out_[0] = cast(nk_byte)tmp[0];
    out_[1] = cast(nk_byte)tmp[1];
    out_[2] = cast(nk_byte)tmp[2];
    out_[3] = cast(nk_byte)tmp[3];
}
void nk_color_hsva_b(nk_byte* h, nk_byte* s, nk_byte* v, nk_byte* a, nk_color in_)
{
    int[4] tmp = void;
    nk_color_hsva_i(&tmp[0], &tmp[1], &tmp[2], &tmp[3], in_);
    *h = cast(nk_byte)tmp[0];
    *s = cast(nk_byte)tmp[1];
    *v = cast(nk_byte)tmp[2];
    *a = cast(nk_byte)tmp[3];
}
void nk_color_hsv_i(int* out_h, int* out_s, int* out_v, nk_color in_)
{
    int a = void;
    nk_color_hsva_i(out_h, out_s, out_v, &a, in_);
}
void nk_color_hsv_b(nk_byte* out_h, nk_byte* out_s, nk_byte* out_v, nk_color in_)
{
    int[4] tmp = void;
    nk_color_hsva_i(&tmp[0], &tmp[1], &tmp[2], &tmp[3], in_);
    *out_h = cast(nk_byte)tmp[0];
    *out_s = cast(nk_byte)tmp[1];
    *out_v = cast(nk_byte)tmp[2];
}
void nk_color_hsv_iv(int* out_, nk_color in_)
{
    nk_color_hsv_i(&out_[0], &out_[1], &out_[2], in_);
}
void nk_color_hsv_bv(nk_byte* out_, nk_color in_)
{
    int[4] tmp = void;
    nk_color_hsv_i(&tmp[0], &tmp[1], &tmp[2], in_);
    out_[0] = cast(nk_byte)tmp[0];
    out_[1] = cast(nk_byte)tmp[1];
    out_[2] = cast(nk_byte)tmp[2];
}
