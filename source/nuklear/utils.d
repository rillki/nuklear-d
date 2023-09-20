module nuklear.utils;
extern(C) @nogc nothrow:

import nuklear.types;
import core.stdc.stdlib;

pragma(inline, true) 
{
    auto nk_min(T)(T a, T b) { return a < b ? a : b; }
    auto nk_max(T)(T a, T b) { return a < b ? b : a; }
    auto nk_clamp(T)(T i, T v, T x) { return nk_max(nk_min(v, x), i); }
    void nk_zero_struct(S)(S s) { nk_zero(&s, s.sizeof); }
    void nk_zero(void *ptr, nk_size size)
    {
        assert(ptr);
        nk_memset(ptr, 0, size);
    }
    auto nk_container_of(P, T, M)(P ptr, T type, M member) 
    {
        return cast(T*)(cast(void*)(cast(char*)(1 ? (ptr): &(cast(T*)0).member) - type.member.offsetof));
    }
}

void* nk_malloc(nk_handle unused, void* old, nk_size size)
{
    cast(void)(unused);
    cast(void)(old);
    return malloc(size);
}

void nk_mfree(nk_handle unused, void *ptr)
{
    cast(void)(unused);
    free(ptr);
}

void nk_memset(void *ptr, int c0, nk_size size)
{
    alias nk_word = uint;
    enum nk_wsize = nk_word.sizeof;
    enum nk_wmask = (nk_wsize - 1);

    nk_byte *dst = cast(nk_byte*)ptr;
    uint c = 0;
    nk_size t = 0;

    if ((c = cast(nk_byte)c0) != 0) {
        c = (c << 8) | c; /* at least 16-bits  */
        if (uint.sizeof > 2)
            c = (c << 16) | c; /* at least 32-bits*/
    }

    /* too small of a word count */
    dst = cast(nk_byte*)ptr;
    if (size < 3 * nk_wsize) {
        while (size--) *dst++ = cast(nk_byte)c0;
        return;
    }

    /* align destination */
    if ((t = cast(nk_size)(dst) & nk_wmask) != 0) {
        t = nk_wsize -t;
        size -= t;
        do {
            *dst++ = cast(nk_byte)c0;
        } while (--t != 0);
    }

    /* fill word */
    t = size / nk_wsize;
    do {
        *(cast(nk_word*)(cast(void*)dst)) = c;
        dst += nk_wsize;
    } while (--t != 0);

    /* fill trailing bytes */
    t = (size & nk_wmask);
    if (t != 0) {
        do {
            *dst++ = cast(nk_byte)c0;
        } while (--t != 0);
    }
}
