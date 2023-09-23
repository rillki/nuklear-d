module nuklear.nuklear_string;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              STRING
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_buffer;
import nuklear.nuklear_utf8;

version (NK_INCLUDE_DEFAULT_ALLOCATOR) {
    void nk_str_init_default(nk_str* str)
    {
        nk_allocator alloc = void;
        alloc.userdata.ptr = null;
        alloc.alloc = &nk_malloc;
        alloc.free = &nk_mfree;
        nk_buffer_init(&str.buffer, &alloc, 32);
        str.len = 0;
    }
}

void nk_str_init(nk_str* str, const(nk_allocator)* alloc, nk_size size)
{
    nk_buffer_init(&str.buffer, alloc, size);
    str.len = 0;
}
void nk_str_init_fixed(nk_str* str, void* memory, nk_size size)
{
    nk_buffer_init_fixed(&str.buffer, memory, size);
    str.len = 0;
}
int nk_str_append_text_char(nk_str* s, const(char)* str, int len)
{
    char* mem = void;
    assert(s);
    assert(str);
    if (!s || !str || !len) return 0;
    mem = cast(char*)nk_buffer_alloc(&s.buffer, NK_BUFFER_FRONT, cast(nk_size)len * char.sizeof, 0);
    if (!mem) return 0;
    nk_memcopy(mem, str, cast(nk_size)len * char.sizeof);
    s.len += nk_utf_len(str, len);
    return len;
}
int nk_str_append_str_char(nk_str* s, const(char)* str)
{
    return nk_str_append_text_char(s, str, nk_strlen(str));
}
int nk_str_append_text_utf8(nk_str* str, const(char)* text, int len)
{
    int i = 0;
    int byte_len = 0;
    nk_rune unicode = void;
    if (!str || !text || !len) return 0;
    for (i = 0; i < len; ++i)
        byte_len += nk_utf_decode(text+byte_len, &unicode, 4);
    nk_str_append_text_char(str, text, byte_len);
    return len;
}
int nk_str_append_str_utf8(nk_str* str, const(char)* text)
{
    int byte_len = 0;
    int num_runes = 0;
    int glyph_len = 0;
    nk_rune unicode = void;
    if (!str || !text) return 0;

    glyph_len = byte_len = nk_utf_decode(text+byte_len, &unicode, 4);
    while (unicode != '\0' && glyph_len) {
        glyph_len = nk_utf_decode(text+byte_len, &unicode, 4);
        byte_len += glyph_len;
        num_runes++;
    }
    nk_str_append_text_char(str, text, byte_len);
    return num_runes;
}
int nk_str_append_text_runes(nk_str* str, const(nk_rune)* text, int len)
{
    int i = 0;
    int byte_len = 0;
    nk_glyph glyph = void;

    assert(str);
    if (!str || !text || !len) return 0;
    for (i = 0; i < len; ++i) {
        byte_len = nk_utf_encode(text[i], glyph.ptr, NK_UTF_SIZE);
        if (!byte_len) break;
        nk_str_append_text_char(str, glyph.ptr, byte_len);
    }
    return len;
}
int nk_str_append_str_runes(nk_str* str, const(nk_rune)* runes)
{
    int i = 0;
    nk_glyph glyph = void;
    int byte_len = void;
    assert(str);
    if (!str || !runes) return 0;
    while (runes[i] != '\0') {
        byte_len = nk_utf_encode(runes[i], glyph.ptr, NK_UTF_SIZE);
        nk_str_append_text_char(str, glyph.ptr, byte_len);
        i++;
    }
    return i;
}
int nk_str_insert_at_char(nk_str* s, int pos, const(char)* str, int len)
{
    int i = void;
    void* mem = void;
    char* src = void;
    char* dst = void;

    int copylen = void;
    assert(s);
    assert(str);
    assert(len >= 0);
    if (!s || !str || !len || cast(nk_size)pos > s.buffer.allocated) return 0;
    if ((s.buffer.allocated + cast(nk_size)len >= s.buffer.memory.size) &&
        (s.buffer.type == NK_BUFFER_FIXED)) return 0;

    copylen = cast(int)s.buffer.allocated - pos;
    if (!copylen) {
        nk_str_append_text_char(s, str, len);
        return 1;
    }
    mem = nk_buffer_alloc(&s.buffer, NK_BUFFER_FRONT, cast(nk_size)len * char.sizeof, 0);
    if (!mem) return 0;

    /* memmove */
    assert((cast(int)pos + cast(int)len + (cast(int)copylen - 1)) >= 0);
    assert((cast(int)pos + (cast(int)copylen - 1)) >= 0);
    dst = nk_ptr_add!char(s.buffer.memory.ptr, pos + len + (copylen - 1));
    src = nk_ptr_add!char(s.buffer.memory.ptr, pos + (copylen-1));
    for (i = 0; i < copylen; ++i) *dst-- = *src--;
    mem = nk_ptr_add!void(s.buffer.memory.ptr, pos);
    nk_memcopy(mem, str, cast(nk_size)len * char.sizeof);
    s.len = nk_utf_len(cast(char*)s.buffer.memory.ptr, cast(int)s.buffer.allocated);
    return 1;
}
int nk_str_insert_at_rune(nk_str* str, int pos, const(char)* cstr, int len)
{
    int glyph_len = void;
    nk_rune unicode = void;
    const(char)* begin = void;
    const(char)* buffer = void;

    assert(str);
    assert(cstr);
    assert(len);
    if (!str || !cstr || !len) return 0;
    begin = nk_str_at_rune(str, pos, &unicode, &glyph_len);
    if (!str.len)
        return nk_str_append_text_char(str, cstr, len);
    buffer = nk_str_get_const(str);
    if (!begin) return 0;
    return nk_str_insert_at_char(str, cast(int)(begin - buffer), cstr, len);
}
int nk_str_insert_text_char(nk_str* str, int pos, const(char)* text, int len)
{
    return nk_str_insert_text_utf8(str, pos, text, len);
}
int nk_str_insert_str_char(nk_str* str, int pos, const(char)* text)
{
    return nk_str_insert_text_utf8(str, pos, text, nk_strlen(text));
}
int nk_str_insert_text_utf8(nk_str* str, int pos, const(char)* text, int len)
{
    int i = 0;
    int byte_len = 0;
    nk_rune unicode = void;

    assert(str);
    assert(text);
    if (!str || !text || !len) return 0;
    for (i = 0; i < len; ++i)
        byte_len += nk_utf_decode(text+byte_len, &unicode, 4);
    nk_str_insert_at_rune(str, pos, text, byte_len);
    return len;
}
int nk_str_insert_str_utf8(nk_str* str, int pos, const(char)* text)
{
    int byte_len = 0;
    int num_runes = 0;
    int glyph_len = 0;
    nk_rune unicode = void;
    if (!str || !text) return 0;

    glyph_len = byte_len = nk_utf_decode(text+byte_len, &unicode, 4);
    while (unicode != '\0' && glyph_len) {
        glyph_len = nk_utf_decode(text+byte_len, &unicode, 4);
        byte_len += glyph_len;
        num_runes++;
    }
    nk_str_insert_at_rune(str, pos, text, byte_len);
    return num_runes;
}
int nk_str_insert_text_runes(nk_str* str, int pos, const(nk_rune)* runes, int len)
{
    int i = 0;
    int byte_len = 0;
    nk_glyph glyph = void;

    assert(str);
    if (!str || !runes || !len) return 0;
    for (i = 0; i < len; ++i) {
        byte_len = nk_utf_encode(runes[i], glyph.ptr, NK_UTF_SIZE);
        if (!byte_len) break;
        nk_str_insert_at_rune(str, pos+i, glyph.ptr, byte_len);
    }
    return len;
}
int nk_str_insert_str_runes(nk_str* str, int pos, const(nk_rune)* runes)
{
    int i = 0;
    nk_glyph glyph = void;
    int byte_len = void;
    assert(str);
    if (!str || !runes) return 0;
    while (runes[i] != '\0') {
        byte_len = nk_utf_encode(runes[i], glyph.ptr, NK_UTF_SIZE);
        nk_str_insert_at_rune(str, pos+i, glyph.ptr, byte_len);
        i++;
    }
    return i;
}
void nk_str_remove_chars(nk_str* s, int len)
{
    assert(s);
    assert(len >= 0);
    if (!s || len < 0 || cast(nk_size)len > s.buffer.allocated) return;
    assert((cast(int)s.buffer.allocated - cast(int)len) >= 0);
    s.buffer.allocated -= cast(nk_size)len;
    s.len = nk_utf_len(cast(char*)s.buffer.memory.ptr, cast(int)s.buffer.allocated);
}
void nk_str_remove_runes(nk_str* str, int len)
{
    int index = void;
    const(char)* begin = void;
    const(char)* end = void;
    nk_rune unicode = void;

    assert(str);
    assert(len >= 0);
    if (!str || len < 0) return;
    if (len >= str.len) {
        str.len = 0;
        return;
    }

    index = str.len - len;
    begin = nk_str_at_rune(str, index, &unicode, &len);
    end = cast(const(char)*)str.buffer.memory.ptr + str.buffer.allocated;
    nk_str_remove_chars(str, cast(int)(end-begin)+1);
}
void nk_str_delete_chars(nk_str* s, int pos, int len)
{
    assert(s);
    if (!s || !len || cast(nk_size)pos > s.buffer.allocated ||
        cast(nk_size)(pos + len) > s.buffer.allocated) return;

    if (cast(nk_size)(pos + len) < s.buffer.allocated) {
        /* memmove */
        char* dst = nk_ptr_add!char(s.buffer.memory.ptr, pos);
        char* src = nk_ptr_add!char(s.buffer.memory.ptr, pos + len);
        nk_memcopy(dst, src, s.buffer.allocated - cast(nk_size)(pos + len));
        assert((cast(int)s.buffer.allocated - cast(int)len) >= 0);
        s.buffer.allocated -= cast(nk_size)len;
    } else nk_str_remove_chars(s, len);
    s.len = nk_utf_len(cast(char*)s.buffer.memory.ptr, cast(int)s.buffer.allocated);
}
void nk_str_delete_runes(nk_str* s, int pos, int len)
{
    char* temp = void;
    nk_rune unicode = void;
    char* begin = void;
    char* end = void;
    int unused = void;

    assert(s);
    assert(s.len >= pos + len);
    if (s.len < pos + len)
        len = nk_clamp(0, (s.len - pos), s.len);
    if (!len) return;

    temp = cast(char*)s.buffer.memory.ptr;
    begin = nk_str_at_rune(s, pos, &unicode, &unused);
    if (!begin) return;
    s.buffer.memory.ptr = begin;
    end = nk_str_at_rune(s, len, &unicode, &unused);
    s.buffer.memory.ptr = temp;
    if (!end) return;
    nk_str_delete_chars(s, cast(int)(begin - temp), cast(int)(end - begin));
}
char* nk_str_at_char(nk_str* s, int pos)
{
    assert(s);
    if (!s || pos > cast(int)s.buffer.allocated) return null;
    return nk_ptr_add!char(s.buffer.memory.ptr, pos);
}
char* nk_str_at_rune(nk_str* str, int pos, nk_rune* unicode, int* len)
{
    int i = 0;
    int src_len = 0;
    int glyph_len = 0;
    char* text = void;
    int text_len = void;

    assert(str);
    assert(unicode);
    assert(len);

    if (!str || !unicode || !len) return null;
    if (pos < 0) {
        *unicode = 0;
        *len = 0;
        return null;
    }

    text = cast(char*)str.buffer.memory.ptr;
    text_len = cast(int)str.buffer.allocated;
    glyph_len = nk_utf_decode(text, unicode, text_len);
    while (glyph_len) {
        if (i == pos) {
            *len = glyph_len;
            break;
        }

        i++;
        src_len = src_len + glyph_len;
        glyph_len = nk_utf_decode(text + src_len, unicode, text_len - src_len);
    }
    if (i != pos) return null;
    return text + src_len;
}
const(char)* nk_str_at_char_const(const(nk_str)* s, int pos)
{
    assert(s);
    if (!s || pos > cast(int)s.buffer.allocated) return null;
    return nk_ptr_add!char(s.buffer.memory.ptr, pos);
}
const(char)* nk_str_at_const(const(nk_str)* str, int pos, nk_rune* unicode, int* len)
{
    int i = 0;
    int src_len = 0;
    int glyph_len = 0;
    char* text = void;
    int text_len = void;

    assert(str);
    assert(unicode);
    assert(len);

    if (!str || !unicode || !len) return null;
    if (pos < 0) {
        *unicode = 0;
        *len = 0;
        return null;
    }

    text = cast(char*)str.buffer.memory.ptr;
    text_len = cast(int)str.buffer.allocated;
    glyph_len = nk_utf_decode(text, unicode, text_len);
    while (glyph_len) {
        if (i == pos) {
            *len = glyph_len;
            break;
        }

        i++;
        src_len = src_len + glyph_len;
        glyph_len = nk_utf_decode(text + src_len, unicode, text_len - src_len);
    }
    if (i != pos) return null;
    return text + src_len;
}
nk_rune nk_str_rune_at(const(nk_str)* str, int pos)
{
    int len = void;
    nk_rune unicode = 0;
    nk_str_at_const(str, pos, &unicode, &len);
    return unicode;
}
char* nk_str_get(nk_str* s)
{
    assert(s);
    if (!s || !s.len || !s.buffer.allocated) return null;
    return cast(char*)s.buffer.memory.ptr;
}
const(char)* nk_str_get_const(const(nk_str)* s)
{
    assert(s);
    if (!s || !s.len || !s.buffer.allocated) return null;
    return cast(const(char)*)s.buffer.memory.ptr;
}
int nk_str_len(nk_str* s)
{
    assert(s);
    if (!s || !s.len || !s.buffer.allocated) return 0;
    return s.len;
}
int nk_str_len_char(nk_str* s)
{
    assert(s);
    if (!s || !s.len || !s.buffer.allocated) return 0;
    return cast(int)s.buffer.allocated;
}
void nk_str_clear(nk_str* str)
{
    assert(str);
    nk_buffer_clear(&str.buffer);
    str.len = 0;
}
void nk_str_free(nk_str* str)
{
    assert(str);
    nk_buffer_free(&str.buffer);
    str.len = 0;
}

