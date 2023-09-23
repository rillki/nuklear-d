module nuklear.nuklear_utf8;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              UTF-8
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

static immutable nk_utfbyte = [0x80, 0, 0xC0, 0xE0, 0xF0];
static immutable nk_utfmask = [0xC0, 0x80, 0xE0, 0xF0, 0xF8];
static immutable nk_utfmin = [0, 0, 0x80, 0x800, 0x10000];
static immutable nk_utfmax = [0x10FFFF, 0x7F, 0x7FF, 0xFFFF, 0x10FFFF];

int nk_utf_validate(nk_rune* u, int i)
{
    assert(u);
    if (!u) return 0;
    if (!nk_between(*u, nk_utfmin[i], nk_utfmax[i]) ||
         nk_between(*u, 0xD800, 0xDFFF))
            *u = NK_UTF_INVALID;
    for (i = 1; *u > nk_utfmax[i]; ++i){}
    return i;
}
nk_rune nk_utf_decode_byte(char c, int* i)
{
    assert(i);
    if (!i) return 0;
    for(*i = 0; *i < cast(int)(nk_utfmask.length); ++(*i)) {
        if ((cast(nk_byte)c & nk_utfmask[*i]) == nk_utfbyte[*i])
            return cast(nk_byte)(c & ~nk_utfmask[*i]);
    }
    return 0;
}
int nk_utf_decode(const(char)* c, nk_rune* u, int clen)
{
    int i = void, j = void, len = void, type = 0;
    nk_rune udecoded = void;

    assert(c);
    assert(u);

    if (!c || !u) return 0;
    if (!clen) return 0;
    *u = NK_UTF_INVALID;

    udecoded = nk_utf_decode_byte(c[0], &len);
    if (!nk_between(len, 1, NK_UTF_SIZE))
        return 1;

    for (i = 1, j = 1; i < clen && j < len; ++i, ++j) {
        udecoded = (udecoded << 6) | nk_utf_decode_byte(c[i], &type);
        if (type != 0)
            return j;
    }
    if (j < len)
        return 0;
    *u = udecoded;
    nk_utf_validate(u, len);
    return len;
}
char nk_utf_encode_byte(nk_rune u, int i)
{
    return cast(char)((nk_utfbyte[i]) | (cast(nk_byte)u & ~nk_utfmask[i]));
}
int nk_utf_encode(nk_rune u, char* c, int clen)
{
    int len = void, i = void;
    len = nk_utf_validate(&u, 0);
    if (clen < len || !len || len > NK_UTF_SIZE)
        return 0;

    for (i = len - 1; i != 0; --i) {
        c[i] = nk_utf_encode_byte(u, 0);
        u >>= 6;
    }
    c[0] = nk_utf_encode_byte(u, len);
    return len;
}
int nk_utf_len(const(char)* str, int len)
{
    const(char)* text = void;
    int glyphs = 0;
    int text_len = void;
    int glyph_len = void;
    int src_len = 0;
    nk_rune unicode = void;

    assert(str);
    if (!str || !len) return 0;

    text = str;
    text_len = len;
    glyph_len = nk_utf_decode(text, &unicode, text_len);
    while (glyph_len && src_len < len) {
        glyphs++;
        src_len = src_len + glyph_len;
        glyph_len = nk_utf_decode(text + src_len, &unicode, text_len - src_len);
    }
    return glyphs;
}
const(char)* nk_utf_at(const(char)* buffer, int length, int index, nk_rune* unicode, int* len)
{
    int i = 0;
    int src_len = 0;
    int glyph_len = 0;
    const(char)* text = void;
    int text_len = void;

    assert(buffer);
    assert(unicode);
    assert(len);

    if (!buffer || !unicode || !len) return null;
    if (index < 0) {
        *unicode = NK_UTF_INVALID;
        *len = 0;
        return null;
    }

    text = buffer;
    text_len = length;
    glyph_len = nk_utf_decode(text, unicode, text_len);
    while (glyph_len) {
        if (i == index) {
            *len = glyph_len;
            break;
        }

        i++;
        src_len = src_len + glyph_len;
        glyph_len = nk_utf_decode(text + src_len, unicode, text_len - src_len);
    }
    if (i != index) return null;
    return buffer + src_len;
}

