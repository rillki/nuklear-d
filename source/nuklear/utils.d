module nuklear.utils;
extern(C) @nogc nothrow:

import nuklear.types;
import core.stdc.stdlib;

pragma(inline, true) 
{   
    auto nk_flag(T)(T x) { return 1 << x; }
    auto nk_min(T)(T a, T b) { return a < b ? a : b; }
    auto nk_max(T)(T a, T b) { return a < b ? b : a; }
    auto nk_clamp(T)(T i, T v, T x) { return nk_max(nk_min(v, x), i); }
    auto nk_between(T)(T x, T a, T b) { return a <= x && x < b; }
    auto nk_intersect(T)(T x0, T y0, T w0, T h0, T x1, T y1, T w1, T h1) { return (x1 < (x0 + w0)) && (x0 < (x1 + w1)) && (y1 < (y0 + h0)) && (y0 < (y1 + h1)); }
    auto nk_ptr_add(T, P, I)(T t, P p, I i) { return cast(T*)(cast(void*)(cast(nk_byte*)(p) + (i))); }
    auto nk_ptr_add_const(T, P, I)(T t, P p, I i) { return cast(const(T)*)(cast(const(void)*)(cast(const(nk_byte)*)(p) + (i))); }
    auto nk_uint_to_ptr(T)(T x) { return cast(void*)x; }
    auto nk_ptr_to_uint(T)(T x) { return cast(nk_size)x; }
    auto nk_align_ptr(T, M)(T x, M mask) { return nk_uint_to_ptr((nk_ptr_to_uint(cast(nk_byte*)(x) + (mask-1)) & ~(mask-1))); }
    auto nk_align_ptr_back(T, M)(T x, M mask) { return nk_uint_to_ptr((nk_ptr_to_uint(cast(nk_byte*)(x)) & ~(mask-1))); }
    void nk_zero_struct(S)(S s) { nk_zero(&s, s.sizeof); }
    void nk_zero(void *ptr, nk_size size)
    {
        assert(ptr);
        nk_memset(ptr, 0, size);
    }
    auto nk_container_of(P, T)(P ptr, T type, size_t member_offsetof) 
    {
        return cast(T*)(cast(void*)(cast(char*)(1 ? (ptr) : ptr - member_offsetof)));
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

void*
nk_memcopy(void *dst0, const void *src0, nk_size length)
{
    nk_ptr t;
    char *dst = (char*)dst0;
    const char *src = (const char*)src0;
    if (length == 0 || dst == src)
        goto done;

    #define nk_word int
    #define nk_wsize sizeof(nk_word)
    #define nk_wmask (nk_wsize-1)
    #define NK_TLOOP(s) if (t) NK_TLOOP1(s)
    #define NK_TLOOP1(s) do { s; } while (--t)

    if (dst < src) {
        t = (nk_ptr)src; /* only need low bits */
        if ((t | (nk_ptr)dst) & nk_wmask) {
            if ((t ^ (nk_ptr)dst) & nk_wmask || length < nk_wsize)
                t = length;
            else
                t = nk_wsize - (t & nk_wmask);
            length -= t;
            NK_TLOOP1(*dst++ = *src++);
        }
        t = length / nk_wsize;
        NK_TLOOP(*(nk_word*)(void*)dst = *(const nk_word*)(const void*)src;
            src += nk_wsize; dst += nk_wsize);
        t = length & nk_wmask;
        NK_TLOOP(*dst++ = *src++);
    } else {
        src += length;
        dst += length;
        t = (nk_ptr)src;
        if ((t | (nk_ptr)dst) & nk_wmask) {
            if ((t ^ (nk_ptr)dst) & nk_wmask || length <= nk_wsize)
                t = length;
            else
                t &= nk_wmask;
            length -= t;
            NK_TLOOP1(*--dst = *--src);
        }
        t = length / nk_wsize;
        NK_TLOOP(src -= nk_wsize; dst -= nk_wsize;
            *(nk_word*)(void*)dst = *(const nk_word*)(const void*)src);
        t = length & nk_wmask;
        NK_TLOOP(*--dst = *--src);
    }
    #undef nk_word
    #undef nk_wsize
    #undef nk_wmask
    #undef NK_TLOOP
    #undef NK_TLOOP1
done:
    return (dst0);
}
