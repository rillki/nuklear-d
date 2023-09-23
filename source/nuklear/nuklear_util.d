module nuklear.nuklear_util;
extern(C) @nogc nothrow:
__gshared:

import nuklear.nuklear_types;
import nuklear.nuklear_utf8;
import core.stdc.stdlib;
import core.stdc.config: c_long, c_ulong;

/* ===============================================================
 *
 *                              UTIL
 *
 * ===============================================================*/

pragma(inline, true) 
{   
    auto nk_flag(T)(T x) { return 1 << x; }
    auto nk_min(T)(T a, T b) { return a < b ? a : b; }
    auto nk_max(T)(T a, T b) { return a < b ? b : a; }
    auto nk_abs(T)(T a) { return a < 0 ? -a : a; }
    auto nk_frac(T)(T x) { return x - cast(float)cast(int)x; }
    auto nk_clamp(T)(T i, T v, T x) { return nk_max(nk_min(v, x), i); }
    auto nk_saturate(T)(T x) { return nk_max(0, nk_min(1.0f, x)); }
    auto nk_to_hex(T)(T i) { return i <= 9 ? '0' + i: 'A' - 10 + i; }
    auto nk_between(T)(T x, T a, T b) { return a <= x && x < b; }
    auto nk_inbox(T)(T px, T py, T x, T y, T w, T h) { return nk_between(px,x,x+w) && nk_between(py,y,y+h); }
    auto nk_intersect(T)(T x0, T y0, T w0, T h0, T x1, T y1, T w1, T h1) { return (x1 < (x0 + w0)) && (x0 < (x1 + w1)) && (y1 < (y0 + h0)) && (y0 < (y1 + h1)); }
    auto nk_ptr_add(T, P, I)(P p, I i) { return cast(T*)(cast(void*)(cast(nk_byte*)(p) + (i))); }
    auto nk_ptr_add_const(T, P, I)(P p, I i) { return cast(const(T)*)(cast(const(void)*)(cast(const(nk_byte)*)(p) + (i))); }
    auto nk_uint_to_ptr(T)(T x) { return cast(void*)x; }
    auto nk_ptr_to_uint(T)(T x) { return cast(nk_size)x; }
    auto nk_align_ptr(T, M)(T x, M mask) { return nk_uint_to_ptr((nk_ptr_to_uint(cast(nk_byte*)(x) + (mask-1)) & ~(mask-1))); }
    auto nk_align_ptr_back(T, M)(T x, M mask) { return nk_uint_to_ptr((nk_ptr_to_uint(cast(nk_byte*)(x)) & ~(mask-1))); }
    void nk_zero_struct(S)(S s) { nk_zero(&s, s.sizeof); }
    nk_bool nk_is_lower(int c) { return (c >= 'a' && c <= 'z') || (c >= 0xE0 && c <= 0xFF); }
    nk_bool nk_is_upper(int c){ return (c >= 'A' && c <= 'Z') || (c >= 0xC0 && c <= 0xDF); }
    int nk_to_upper(int c) { return (c >= 'a' && c <= 'z') ? (c - ('a' - 'A')) : c; }
    int nk_to_lower(int c) { return (c >= 'A' && c <= 'Z') ? (c - ('a' + 'A')) : c; }
    auto nk_vec2_sub(T)(T a, T b) { return nk_vec2((a).x - (b).x, (a).y - (b).y); }
    auto nk_vec2_add(T)(T a, T b) { return nk_vec2((a).x + (b).x, (a).y + (b).y); }
    auto nk_vec2_len_sqr(T)(T a) { return ((a).x*(a).x+(a).y*(a).y);}
    auto nk_vec2_muls(A, T)(A a, T t) { return nk_vec2((a).x * (t), (a).y * (t));}
    void nk_zero(void *ptr, nk_size size)
    {
        assert(ptr);
        nk_memset(ptr, 0, size);
    }

    auto nk_container_of(T, string member, P)(P ptr)
    {
        return cast(T*)(cast(char*)ptr - __traits(getMember, T, member).offsetof);
    }

    float nk_inv_sqrt(float n)
    {
        float x2;
        const float threehalfs = 1.5f;
        union Conv {nk_uint i; float f;}
        Conv conv;
        conv.f = n;
        x2 = n * 0.5f;
        conv.i = 0x5f375A84 - (conv.i >> 1);
        conv.f = conv.f * (threehalfs - (x2 * conv.f * conv.f));
        return conv.f;
    }

    float nk_sin(float x)
    {
        enum float a0 = +1.91059300966915117e-31f;
        enum float a1 = +1.00086760103908896f;
        enum float a2 = -1.21276126894734565e-2f;
        enum float a3 = -1.38078780785773762e-1f;
        enum float a4 = -2.67353392911981221e-2f;
        enum float a5 = +2.08026600266304389e-2f;
        enum float a6 = -3.03996055049204407e-3f;
        enum float a7 = +1.38235642404333740e-4f;
        return a0 + x*(a1 + x*(a2 + x*(a3 + x*(a4 + x*(a5 + x*(a6 + x*a7))))));
    }

    float nk_cos(float x)
    {
        /* New implementation. Also generated using lolremez. */
        /* Old version significantly deviated from expected results. */
        enum float a0 = 9.9995999154986614e-1f;
        enum float a1 = 1.2548995793001028e-3f;
        enum float a2 = -5.0648546280678015e-1f;
        enum float a3 = 1.2942246466519995e-2f;
        enum float a4 = 2.8668384702547972e-2f;
        enum float a5 = 7.3726485210586547e-3f;
        enum float a6 = -3.8510875386947414e-3f;
        enum float a7 = 4.7196604604366623e-4f;
        enum float a8 = -1.8776444013090451e-5f;
        return a0 + x*(a1 + x*(a2 + x*(a3 + x*(a4 + x*(a5 + x*(a6 + x*(a7 + x*a8)))))));
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

void* nk_memcopy(void* dst0, const(void)* src0, nk_size length)
{
    nk_ptr t;
    char* dst = cast(char*)dst0;
    const(char)* src = cast(const(char)*)src0;
    if (length == 0 || dst == src)
        goto done;
    
    alias nk_word = int;
    enum nk_wsize = nk_word.sizeof;
    enum nk_wmask = nk_wsize - 1;

    if (dst < src) {
        t = cast(nk_ptr)src; /* only need low bits */
        if ((t | cast(nk_ptr)dst) & nk_wmask) {
            if ((t ^ cast(nk_ptr)dst) & nk_wmask || length < nk_wsize)
                t = length;
            else
                t = nk_wsize - (t & nk_wmask);
            length -= t;
            do { *dst++ = *src++; } while (--t);
        }
        t = length / nk_wsize;

        if (t) { 
            do { 
                *cast(nk_word*)cast(void*)dst = *cast(const(nk_word)*)cast(const(void)*)src;
                src += nk_wsize;
                dst += nk_wsize;
            } while (--t);
        }
        t = length & nk_wmask;

        if (t) {
            do { 
                *dst++ = *src++; 
            } while (--t);
        }
    } else {
        src += length;
        dst += length;
        t = cast(nk_ptr)src;
        if ((t | cast(nk_ptr)dst) & nk_wmask) {
            if ((t ^ cast(nk_ptr)dst) & nk_wmask || length <= nk_wsize)
                t = length;
            else
                t &= nk_wmask;
            length -= t;
            do { *--dst = *--src; } while (--t);
        }
        t = length / nk_wsize;

        if (t) {
            do { 
                src -= nk_wsize; 
                dst -= nk_wsize;
                *cast(nk_word*)cast(void*)dst = *cast(const(nk_word)*)cast(const(void)*)src; 
            } while (--t);
        }
        t = length & nk_wmask;

        if (t) {
            do { 
                *--dst = *--src; 
            } while (--t);
        }
    }

done:
    return dst0;
}

int nk_strlen(const(char)* str)
{
    int siz = 0;
    assert(str);
    while (str && *str++ != '\0') siz++;
    return siz;
}
int nk_strtoi(const(char)* str, const(char)** endptr)
{
    int neg = 1;
    const(char)* p = str;
    int value = 0;

    assert(str);
    if (!str) return 0;

    /* skip whitespace */
    while (*p == ' ') p++;
    if (*p == '-') {
        neg = -1;
        p++;
    }
    while (*p && *p >= '0' && *p <= '9') {
        value = value * 10 + cast(int) (*p - '0');
        p++;
    }
    if (endptr)
        *endptr = p;
    return neg*value;
}
double nk_strtod(const(char)* str, const(char)** endptr)
{
    double m = void;
    double neg = 1.0;
    const(char)* p = str;
    double value = 0;
    double number = 0;

    assert(str);
    if (!str) return 0;

    /* skip whitespace */
    while (*p == ' ') p++;
    if (*p == '-') {
        neg = -1.0;
        p++;
    }

    while (*p && *p != '.' && *p != 'e') {
        value = value * 10.0 + cast(double) (*p - '0');
        p++;
    }

    if (*p == '.') {
        p++;
        for(m = 0.1; *p && *p != 'e'; p++ ) {
            value = value + cast(double) (*p - '0') * m;
            m *= 0.1;
        }
    }
    if (*p == 'e') {
        int i = void, pow = void, div = void;
        p++;
        if (*p == '-') {
            div = nk_true;
            p++;
        } else if (*p == '+') {
            div = nk_false;
            p++;
        } else div = nk_false;

        for (pow = 0; *p; p++)
            pow = pow * 10 + cast(int) (*p - '0');

        for (m = 1.0, i = 0; i < pow; i++)
            m *= 10.0;

        if (div)
            value /= m;
        else value *= m;
    }
    number = value * neg;
    if (endptr)
        *endptr = p;
    return number;
}
float nk_strtof(const(char)* str, const(char)** endptr)
{
    float float_value = void;
    double double_value = void;
    double_value = nk_strtod(str, endptr);
    float_value = cast(float)double_value;
    return float_value;
}
int nk_stricmp(const(char)* s1, const(char)* s2)
{
    nk_int c1 = void, c2 = void, d = void;
    do {
        c1 = *s1++;
        c2 = *s2++;
        d = c1 - c2;
        while (d) {
            if (c1 <= 'Z' && c1 >= 'A') {
                d += ('a' - 'A');
                if (!d) break;
            }
            if (c2 <= 'Z' && c2 >= 'A') {
                d -= ('a' - 'A');
                if (!d) break;
            }
            return ((d >= 0) << 1) - 1;
        }
    } while (c1);
    return 0;
}
int nk_stricmpn(const(char)* s1, const(char)* s2, int n)
{
    int c1 = void, c2 = void, d = void;
    assert(n >= 0);
    do {
        c1 = *s1++;
        c2 = *s2++;
        if (!n--) return 0;

        d = c1 - c2;
        while (d) {
            if (c1 <= 'Z' && c1 >= 'A') {
                d += ('a' - 'A');
                if (!d) break;
            }
            if (c2 <= 'Z' && c2 >= 'A') {
                d -= ('a' - 'A');
                if (!d) break;
            }
            return ((d >= 0) << 1) - 1;
        }
    } while (c1);
    return 0;
}
int nk_str_match_here(const(char)* regexp, const(char)* text)
{
    if (regexp[0] == '\0')
        return 1;
    if (regexp[1] == '*')
        return nk_str_match_star(regexp[0], regexp+2, text);
    if (regexp[0] == '$' && regexp[1] == '\0')
        return *text == '\0';
    if (*text!='\0' && (regexp[0]=='.' || regexp[0]==*text))
        return nk_str_match_here(regexp+1, text+1);
    return 0;
}
int nk_str_match_star(int c, const(char)* regexp, const(char)* text)
{
    do {/* a '* matches zero or more instances */
        if (nk_str_match_here(regexp, text))
            return 1;
    } while (*text != '\0' && (*text++ == c || c == '.'));
    return 0;
}
int nk_strfilter(const(char)* text, const(char)* regexp)
{
    /*
    c    matches any literal character c
    .    matches any single character
    ^    matches the beginning of the input string
    $    matches the end of the input string
    *    matches zero or more occurrences of the previous character*/
    if (regexp[0] == '^')
        return nk_str_match_here(regexp+1, text);
    do {    /* must look even if string is empty */
        if (nk_str_match_here(regexp, text))
            return 1;
    } while (*text++ != '\0');
    return 0;
}
int nk_strmatch_fuzzy_text(const(char)* str, int str_len, const(char)* pattern, int* out_score)
{
    /* Returns true if each character in pattern is found sequentially within str
     * if found then out_score is also set. Score value has no intrinsic meaning.
     * Range varies with pattern. Can only compare scores with same search pattern. */

    /* bonus for adjacent matches */
    enum NK_ADJACENCY_BONUS = 5;
    /* bonus if match occurs after a separator */
    enum NK_SEPARATOR_BONUS = 10;
    /* bonus if match is uppercase and prev is lower */
    enum NK_CAMEL_BONUS = 10;
    /* penalty applied for every letter in str before the first match */
    enum NK_LEADING_LETTER_PENALTY = (-3);
    /* maximum penalty for leading letters */
    enum nk_max_LEADING_LETTER_PENALTY = (-9);
    /* penalty for every letter that doesn't matter */
    enum NK_UNMATCHED_LETTER_PENALTY = (-1);

    /* loop variables */
    int score = 0;
    const(char)* pattern_iter = pattern;
    int str_iter = 0;
    int prev_matched = nk_false;
    int prev_lower = nk_false;
    /* true so if first letter match gets separator bonus*/
    int prev_separator = nk_true;

    /* use "best" matched letter if multiple string letters match the pattern */
    const(char)* best_letter = null;
    int best_letter_score = 0;

    /* loop over strings */
    assert(str);
    assert(pattern);
    if (!str || !str_len || !pattern) return 0;
    while (str_iter < str_len)
    {
        const(char) pattern_letter = *pattern_iter;
        const(char) str_letter = str[str_iter];

        int next_match = *pattern_iter != '\0' &&
            nk_to_lower(pattern_letter) == nk_to_lower(str_letter);
        int rematch = best_letter && nk_to_upper(*best_letter) == nk_to_upper(str_letter);

        int advanced = next_match && best_letter;
        int pattern_repeat = best_letter && *pattern_iter != '\0';
        pattern_repeat = pattern_repeat &&
            nk_to_lower(*best_letter) == nk_to_lower(pattern_letter);

        if (advanced || pattern_repeat) {
            score += best_letter_score;
            best_letter = null;
            best_letter_score = 0;
        }

        if (next_match || rematch)
        {
            int new_score = 0;
            /* Apply penalty for each letter before the first pattern match */
            if (pattern_iter == pattern) {
                int count = cast(int)(&str[str_iter] - str);
                int penalty = NK_LEADING_LETTER_PENALTY * count;
                if (penalty < nk_max_LEADING_LETTER_PENALTY)
                    penalty = nk_max_LEADING_LETTER_PENALTY;

                score += penalty;
            }

            /* apply bonus for consecutive bonuses */
            if (prev_matched)
                new_score += NK_ADJACENCY_BONUS;

            /* apply bonus for matches after a separator */
            if (prev_separator)
                new_score += NK_SEPARATOR_BONUS;

            /* apply bonus across camel case boundaries */
            if (prev_lower && nk_is_upper(str_letter))
                new_score += NK_CAMEL_BONUS;

            /* update pattern iter IFF the next pattern letter was matched */
            if (next_match)
                ++pattern_iter;

            /* update best letter in str which may be for a "next" letter or a rematch */
            if (new_score >= best_letter_score) {
                /* apply penalty for now skipped letter */
                if (best_letter != null)
                    score += NK_UNMATCHED_LETTER_PENALTY;

                best_letter = &str[str_iter];
                best_letter_score = new_score;
            }
            prev_matched = nk_true;
        } else {
            score += NK_UNMATCHED_LETTER_PENALTY;
            prev_matched = nk_false;
        }

        /* separators should be more easily defined */
        prev_lower = nk_is_lower(str_letter) != 0;
        prev_separator = str_letter == '_' || str_letter == ' ';

        ++str_iter;
    }

    /* apply score for last match */
    if (best_letter)
        score += best_letter_score;

    /* did not match full pattern */
    if (*pattern_iter != '\0')
        return nk_false;

    if (out_score)
        *out_score = score;
    return nk_true;
}
int nk_strmatch_fuzzy_string(const(char)* str, const(char)* pattern, int* out_score)
{
    return nk_strmatch_fuzzy_text(str, nk_strlen(str), pattern, out_score);
}
int nk_string_float_limit(char* string, int prec)
{
    int dot = 0;
    char* c = string;
    while (*c) {
        if (*c == '.') {
            dot = 1;
            c++;
            continue;
        }
        if (dot == (prec+1)) {
            *c = 0;
            break;
        }
        if (dot > 0) dot++;
        c++;
    }
    return cast(int)(c - string);
}
void nk_strrev_ascii(char* s)
{
    int len = nk_strlen(s);
    int end = len / 2;
    int i = 0;
    char t = void;
    for (; i < end; ++i) {
        t = s[i];
        s[i] = s[len - 1 - i];
        s[len -1 - i] = t;
    }
}
char* nk_itoa(char* s, c_long n)
{
    c_long i = 0;
    if (n == 0) {
        s[i++] = '0';
        s[i] = 0;
        return s;
    }
    if (n < 0) {
        s[i++] = '-';
        n = -n;
    }
    while (n > 0) {
        s[i++] = cast(char)('0' + (n % 10));
        n /= 10;
    }
    s[i] = 0;
    if (s[0] == '-')
        ++s;

    nk_strrev_ascii(s);
    return s;
}

char* nk_dtoa(char* s, double n)
{
    int useExp = 0;
    int digit = 0, m = 0, m1 = 0;
    char* c = s;
    int neg = 0;

    assert(s);
    if (!s) return null;

    if (n == 0.0) {
        s[0] = '0'; s[1] = '\0';
        return s;
    }

    neg = (n < 0);
    if (neg) n = -n;

    /* calculate magnitude */
    m = nk_log10(n);
    useExp = (m >= 14 || (neg && m >= 9) || m <= -9);
    if (neg) *(c++) = '-';

    /* set up for scientific notation */
    if (useExp) {
        if (m < 0)
           m -= 1;
        n = n / cast(double)nk_pow(10.0, m);
        m1 = m;
        m = 0;
    }
    if (m < 1.0) {
        m = 0;
    }

    /* convert the number */
    while (n > NK_FLOAT_PRECISION || m >= 0) {
        double weight = nk_pow(10.0, m);
        if (weight > 0) {
            double t = cast(double)n / weight;
            digit = nk_ifloord(t);
            n -= (cast(double)digit * weight);
            *(c++) = cast(char)('0' + cast(char)digit);
        }
        if (m == 0 && n > 0)
            *(c++) = '.';
        m--;
    }

    if (useExp) {
        /* convert the exponent */
        int i = void, j = void;
        *(c++) = 'e';
        if (m1 > 0) {
            *(c++) = '+';
        } else {
            *(c++) = '-';
            m1 = -m1;
        }
        m = 0;
        while (m1 > 0) {
            *(c++) = cast(char)('0' + cast(char)(m1 % 10));
            m1 /= 10;
            m++;
        }
        c -= m;
        for (i = 0, j = m-1; i<j; i++, j--) {
            /* swap without temporary */
            c[i] ^= c[j];
            c[j] ^= c[i];
            c[i] ^= c[j];
        }
        c += m;
    }
    *(c) = '\0';
    return s;
}

version (NK_INCLUDE_STANDARD_VARARGS) {
    import core.stdc.stdarg;

    int nk_vsnprintf(char* buf, int buf_size, const(char)* fmt, va_list args)
    {
        enum nk_arg_type {
            NK_ARG_TYPE_CHAR,
            NK_ARG_TYPE_SHORT,
            NK_ARG_TYPE_DEFAULT,
            NK_ARG_TYPE_LONG
        }
        alias NK_ARG_TYPE_CHAR = nk_arg_type.NK_ARG_TYPE_CHAR;
        alias NK_ARG_TYPE_SHORT = nk_arg_type.NK_ARG_TYPE_SHORT;
        alias NK_ARG_TYPE_DEFAULT = nk_arg_type.NK_ARG_TYPE_DEFAULT;
        alias NK_ARG_TYPE_LONG = nk_arg_type.NK_ARG_TYPE_LONG;
        
        enum nk_arg_flags {
            NK_ARG_FLAG_LEFT = 0x01,
            NK_ARG_FLAG_PLUS = 0x02,
            NK_ARG_FLAG_SPACE = 0x04,
            NK_ARG_FLAG_NUM = 0x10,
            NK_ARG_FLAG_ZERO = 0x20
        }
        alias NK_ARG_FLAG_LEFT = nk_arg_flags.NK_ARG_FLAG_LEFT;
        alias NK_ARG_FLAG_PLUS = nk_arg_flags.NK_ARG_FLAG_PLUS;
        alias NK_ARG_FLAG_SPACE = nk_arg_flags.NK_ARG_FLAG_SPACE;
        alias NK_ARG_FLAG_NUM = nk_arg_flags.NK_ARG_FLAG_NUM;
        alias NK_ARG_FLAG_ZERO = nk_arg_flags.NK_ARG_FLAG_ZERO;

        char[NK_MAX_NUMBER_BUFFER] number_buffer = void;
        nk_arg_type arg_type = NK_ARG_TYPE_DEFAULT;
        int precision = NK_DEFAULT;
        int width = NK_DEFAULT;
        nk_flags flag = 0;

        int len = 0;
        int result = -1;
        const(char)* iter = fmt;

        assert(buf);
        assert(buf_size);
        if (!buf || !buf_size || !fmt) return 0;
        for (iter = fmt; *iter && len < buf_size; iter++) {
            /* copy all non-format characters */
            while (*iter && (*iter != '%') && (len < buf_size))
                buf[len++] = *iter++;
            if (!(*iter) || len >= buf_size) break;
            iter++;

            /* flag arguments */
            while (*iter) {
                if (*iter == '-') flag |= NK_ARG_FLAG_LEFT;
                else if (*iter == '+') flag |= NK_ARG_FLAG_PLUS;
                else if (*iter == ' ') flag |= NK_ARG_FLAG_SPACE;
                else if (*iter == '#') flag |= NK_ARG_FLAG_NUM;
                else if (*iter == '0') flag |= NK_ARG_FLAG_ZERO;
                else break;
                iter++;
            }

            /* width argument */
            width = NK_DEFAULT;
            if (*iter >= '1' && *iter <= '9') {
                const(char)* end = void;
                width = nk_strtoi(iter, &end);
                if (end == iter)
                    width = -1;
                else iter = end;
            } else if (*iter == '*') {
                width = va_arg!int(args);
                iter++;
            }

            /* precision argument */
            precision = NK_DEFAULT;
            if (*iter == '.') {
                iter++;
                if (*iter == '*') {
                    precision = va_arg!int(args);
                    iter++;
                } else {
                    const(char)* end = void;
                    precision = nk_strtoi(iter, &end);
                    if (end == iter)
                        precision = -1;
                    else iter = end;
                }
            }

            /* length modifier */
            if (*iter == 'h') {
                if (*(iter+1) == 'h') {
                    arg_type = NK_ARG_TYPE_CHAR;
                    iter++;
                } else arg_type = NK_ARG_TYPE_SHORT;
                iter++;
            } else if (*iter == 'l') {
                arg_type = NK_ARG_TYPE_LONG;
                iter++;
            } else arg_type = NK_ARG_TYPE_DEFAULT;

            /* specifier */
            if (*iter == '%') {
                assert(arg_type == NK_ARG_TYPE_DEFAULT);
                assert(precision == NK_DEFAULT);
                assert(width == NK_DEFAULT);
                if (len < buf_size)
                    buf[len++] = '%';
            } else if (*iter == 's') {
                /* string  */
                const(char)* str = va_arg!(const(char)*)(args);
                assert(str != buf && "buffer and argument are not allowed to overlap!");
                assert(arg_type == NK_ARG_TYPE_DEFAULT);
                assert(precision == NK_DEFAULT);
                assert(width == NK_DEFAULT);
                if (str == buf) return -1;
                while (str && *str && len < buf_size)
                    buf[len++] = *str++;
            } else if (*iter == 'n') {
                /* current length callback */
                int* n = va_arg!(int*)(args);
                assert(arg_type == NK_ARG_TYPE_DEFAULT);
                assert(precision == NK_DEFAULT);
                assert(width == NK_DEFAULT);
                if (n) *n = len;
            } else if (*iter == 'c' || *iter == 'i' || *iter == 'd') {
                /* signed integer */
                c_long value = 0;
                const(char)* num_iter = void;
                int num_len = void, num_print = void, padding = void;
                int cur_precision = nk_max(precision, 1);
                int cur_width = nk_max(width, 0);

                /* retrieve correct value type */
                if (arg_type == NK_ARG_TYPE_CHAR)
                    value = cast(char)va_arg!int(args);
                else if (arg_type == NK_ARG_TYPE_SHORT)
                    value = cast(short)va_arg!int(args);
                else if (arg_type == NK_ARG_TYPE_LONG)
                    value = va_arg!long(args);
                else if (*iter == 'c')
                    value = cast(ubyte)va_arg!int(args);
                else value = va_arg!int(args);

                /* convert number to string */
                nk_itoa(number_buffer.ptr, value);
                num_len = nk_strlen(number_buffer.ptr);
                padding = nk_max(cur_width - nk_max(cur_precision, num_len), 0);
                if ((flag & NK_ARG_FLAG_PLUS) || (flag & NK_ARG_FLAG_SPACE))
                    padding = nk_max(padding-1, 0);

                /* fill left padding up to a total of `width` characters */
                if (!(flag & NK_ARG_FLAG_LEFT)) {
                    while (padding-- > 0 && (len < buf_size)) {
                        if ((flag & NK_ARG_FLAG_ZERO) && (precision == NK_DEFAULT))
                            buf[len++] = '0';
                        else buf[len++] = ' ';
                    }
                }

                /* copy string value representation into buffer */
                if ((flag & NK_ARG_FLAG_PLUS) && value >= 0 && len < buf_size)
                    buf[len++] = '+';
                else if ((flag & NK_ARG_FLAG_SPACE) && value >= 0 && len < buf_size)
                    buf[len++] = ' ';

                /* fill up to precision number of digits with '0' */
                num_print = nk_max(cur_precision, num_len);
                while (precision && (num_print > num_len) && (len < buf_size)) {
                    buf[len++] = '0';
                    num_print--;
                }

                /* copy string value representation into buffer */
                num_iter = number_buffer.ptr;
                while (precision && *num_iter && len < buf_size)
                    buf[len++] = *num_iter++;

                /* fill right padding up to width characters */
                if (flag & NK_ARG_FLAG_LEFT) {
                    while ((padding-- > 0) && (len < buf_size))
                        buf[len++] = ' ';
                }
            } else if (*iter == 'o' || *iter == 'x' || *iter == 'X' || *iter == 'u') {
                /* unsigned integer */
                c_ulong value = 0;
                int num_len = 0, num_print = void, padding = 0;
                int cur_precision = nk_max(precision, 1);
                int cur_width = nk_max(width, 0);
                uint base = (*iter == 'o') ? 8: (*iter == 'u')? 10: 16;

                /* print oct/hex/dec value */
                const(char)* upper_output_format = "0123456789ABCDEF";
                const(char)* lower_output_format = "0123456789abcdef";
                const(char)* output_format = (*iter == 'x') ?
                    lower_output_format: upper_output_format;

                /* retrieve correct value type */
                if (arg_type == NK_ARG_TYPE_CHAR)
                    value = cast(ubyte)va_arg!int(args);
                else if (arg_type == NK_ARG_TYPE_SHORT)
                    value = cast(ushort)va_arg!int(args);
                else if (arg_type == NK_ARG_TYPE_LONG)
                    value = va_arg!ulong(args);
                else value = va_arg!uint(args);

                do {
                    /* convert decimal number into hex/oct number */
                    int digit = output_format[value % base];
                    if (num_len < NK_MAX_NUMBER_BUFFER)
                        number_buffer[num_len++] = cast(char)digit;
                    value /= base;
                } while (value > 0);

                num_print = nk_max(cur_precision, num_len);
                padding = nk_max(cur_width - nk_max(cur_precision, num_len), 0);
                if (flag & NK_ARG_FLAG_NUM)
                    padding = nk_max(padding-1, 0);

                /* fill left padding up to a total of `width` characters */
                if (!(flag & NK_ARG_FLAG_LEFT)) {
                    while ((padding-- > 0) && (len < buf_size)) {
                        if ((flag & NK_ARG_FLAG_ZERO) && (precision == NK_DEFAULT))
                            buf[len++] = '0';
                        else buf[len++] = ' ';
                    }
                }

                /* fill up to precision number of digits */
                if (num_print && (flag & NK_ARG_FLAG_NUM)) {
                    if ((*iter == 'o') && (len < buf_size)) {
                        buf[len++] = '0';
                    } else if ((*iter == 'x') && ((len+1) < buf_size)) {
                        buf[len++] = '0';
                        buf[len++] = 'x';
                    } else if ((*iter == 'X') && ((len+1) < buf_size)) {
                        buf[len++] = '0';
                        buf[len++] = 'X';
                    }
                }
                while (precision && (num_print > num_len) && (len < buf_size)) {
                    buf[len++] = '0';
                    num_print--;
                }

                /* reverse number direction */
                while (num_len > 0) {
                    if (precision && (len < buf_size))
                        buf[len++] = number_buffer[num_len-1];
                    num_len--;
                }

                /* fill right padding up to width characters */
                if (flag & NK_ARG_FLAG_LEFT) {
                    while ((padding-- > 0) && (len < buf_size))
                        buf[len++] = ' ';
                }
            } else if (*iter == 'f') {
                /* floating point */
                const(char)* num_iter = void;
                int cur_precision = (precision < 0) ? 6: precision;
                int prefix = void, cur_width = nk_max(width, 0);
                double value = va_arg!double(args);
                int num_len = 0, frac_len = 0, dot = 0;
                int padding = 0;

                assert(arg_type == NK_ARG_TYPE_DEFAULT);
                nk_dtoa(number_buffer.ptr, value);
                num_len = nk_strlen(number_buffer.ptr);

                /* calculate padding */
                num_iter = number_buffer.ptr;
                while (*num_iter && *num_iter != '.')
                    num_iter++;

                prefix = (*num_iter == '.')?cast(int)(num_iter - number_buffer.ptr)+1:0;
                padding = nk_max(cur_width - (prefix + nk_min(cur_precision, num_len - prefix)) , 0);
                if ((flag & NK_ARG_FLAG_PLUS) || (flag & NK_ARG_FLAG_SPACE))
                    padding = nk_max(padding-1, 0);

                /* fill left padding up to a total of `width` characters */
                if (!(flag & NK_ARG_FLAG_LEFT)) {
                    while (padding-- > 0 && (len < buf_size)) {
                        if (flag & NK_ARG_FLAG_ZERO)
                            buf[len++] = '0';
                        else buf[len++] = ' ';
                    }
                }

                /* copy string value representation into buffer */
                num_iter = number_buffer.ptr;
                if ((flag & NK_ARG_FLAG_PLUS) && (value >= 0) && (len < buf_size))
                    buf[len++] = '+';
                else if ((flag & NK_ARG_FLAG_SPACE) && (value >= 0) && (len < buf_size))
                    buf[len++] = ' ';
                while (*num_iter) {
                    if (dot) frac_len++;
                    if (len < buf_size)
                        buf[len++] = *num_iter;
                    if (*num_iter == '.') dot = 1;
                    if (frac_len >= cur_precision) break;
                    num_iter++;
                }

                /* fill number up to precision */
                while (frac_len < cur_precision) {
                    if (!dot && len < buf_size) {
                        buf[len++] = '.';
                        dot = 1;
                    }
                    if (len < buf_size)
                        buf[len++] = '0';
                    frac_len++;
                }

                /* fill right padding up to width characters */
                if (flag & NK_ARG_FLAG_LEFT) {
                    while ((padding-- > 0) && (len < buf_size))
                        buf[len++] = ' ';
                }
            } else {
                /* Specifier not supported: g,G,e,E,p,z */
                assert(0 && "specifier is not supported!");
                // return result;
            }
        }
        buf[(len >= buf_size)?(buf_size-1):len] = 0;
        result = (len >= buf_size)?-1:len;
        return result;
    }
}

int nk_strfmt(char* buf, int buf_size, const(char)* fmt, va_list args)
{
    int result = -1;
    assert(buf);
    assert(buf_size);
    if (!buf || !buf_size || !fmt) return 0;
    version (NK_INCLUDE_STANDARD_IO) {
        result = vsnprintf(buf, cast(nk_size)buf_size, fmt, args);
        result = (result >= buf_size) ? -1: result;
        buf[buf_size-1] = 0;
    } else {
        result = nk_vsnprintf(buf, buf_size, fmt, args);
    }
    return result;
}

nk_hash nk_murmur_hash(const(void)* key, int len, nk_hash seed)
{
    auto NK_ROTL(T)(T x, T r) { return ((x) << (r) | ((x) >> (32 - r))); }

    nk_uint h1 = seed;
    nk_uint k1;
    const(nk_byte)* data = cast(const(nk_byte)*)key;
    const(nk_byte)* keyptr = data;
    nk_byte* k1ptr;
    const int bsize = k1.sizeof;
    const int nblocks = len/4;

    const nk_uint c1 = 0xcc9e2d51;
    const nk_uint c2 = 0x1b873593;
    const(nk_byte)* tail;
    int i;

    /* body */
    if (!key) return 0;
    for (i = 0; i < nblocks; ++i, keyptr += bsize) {
        k1ptr = cast(nk_byte*)&k1;
        k1ptr[0] = keyptr[0];
        k1ptr[1] = keyptr[1];
        k1ptr[2] = keyptr[2];
        k1ptr[3] = keyptr[3];

        k1 *= c1;
        k1 = NK_ROTL(k1,15);
        k1 *= c2;

        h1 ^= k1;
        h1 = NK_ROTL(h1,13);
        h1 = h1*5+0xe6546b64;
    }

    /* tail */
    tail = cast(const(nk_byte)*)(data + nblocks*4);
    k1 = 0;
    switch (len & 3) {
        case 3: k1 ^= cast(nk_uint)(tail[2] << 16); /* fallthrough */
            goto case 2;
        case 2: k1 ^= cast(nk_uint)(tail[1] << 8u); /* fallthrough */
            goto case 1;
        case 1: k1 ^= tail[0];
            k1 *= c1;
            k1 = NK_ROTL(k1,15);
            k1 *= c2;
            h1 ^= k1;
            break;
        default: break;
    }

    /* finalization */
    h1 ^= cast(nk_uint)len;
    /* fmix32 */
    h1 ^= h1 >> 16;
    h1 *= 0x85ebca6b;
    h1 ^= h1 >> 13;
    h1 *= 0xc2b2ae35;
    h1 ^= h1 >> 16;

    return h1;
}

version (NK_INCLUDE_STANDARD_IO) {
    import core.stdc.stdio;
    
    char* nk_file_load(const(char)* path, nk_size* siz, nk_allocator* alloc)
    {
        char* buf = void;
        FILE* fd = void;
        c_long ret = void;

        assert(path);
        assert(siz);
        assert(alloc);
        if (!path || !siz || !alloc)
            return null;

        fd = fopen(path, "rb");
        if (!fd) return null;
        fseek(fd, 0, SEEK_END);
        ret = ftell(fd);
        if (ret < 0) {
            fclose(fd);
            return null;
        }
        *siz = cast(nk_size)ret;
        fseek(fd, 0, SEEK_SET);
        buf = cast(char*)alloc.alloc(alloc.userdata, null, *siz);
        assert(buf);
        if (!buf) {
            fclose(fd);
            return null;
        }
        *siz = cast(nk_size)fread(buf, 1,*siz, fd);
        fclose(fd);
        return buf;
    }
}
int nk_text_clamp(const(nk_user_font)* font, const(char)* text, int text_len, float space, int* glyphs, float* text_width, nk_rune* sep_list, int sep_count)
{
    int i = 0;
    int glyph_len = 0;
    float last_width = 0;
    nk_rune unicode = 0;
    float width = 0;
    int len = 0;
    int g = 0;
    float s = void;

    int sep_len = 0;
    int sep_g = 0;
    float sep_width = 0;
    sep_count = nk_max(sep_count,0);

    glyph_len = nk_utf_decode(text, &unicode, text_len);
    while (glyph_len && (width < space) && (len < text_len)) {
        len += glyph_len;
        s = font.width(cast(nk_handle)font.userdata, font.height, text, len);
        for (i = 0; i < sep_count; ++i) {
            if (unicode != sep_list[i]) continue;
            sep_width = last_width = width;
            sep_g = g+1;
            sep_len = len;
            break;
        }
        if (i == sep_count){
            last_width = sep_width = width;
            sep_g = g+1;
        }
        width = s;
        glyph_len = nk_utf_decode(&text[len], &unicode, text_len - len);
        g++;
    }
    if (len >= text_len) {
        *glyphs = g;
        *text_width = last_width;
        return len;
    } else {
        *glyphs = sep_g;
        *text_width = sep_width;
        return (!sep_len) ? len: sep_len;
    }
}
nk_vec2 nk_text_calculate_text_bounds(const(nk_user_font)* font, const(char)* begin, int byte_len, float row_height, const(char)** remaining, nk_vec2* out_offset, int* glyphs, int op)
{
    float line_height = row_height;
    nk_vec2 text_size = nk_vec2(0,0);
    float line_width = 0.0f;

    float glyph_width = void;
    int glyph_len = 0;
    nk_rune unicode = 0;
    int text_len = 0;
    if (!begin || byte_len <= 0 || !font)
        return nk_vec2(0,row_height);

    glyph_len = nk_utf_decode(begin, &unicode, byte_len);
    if (!glyph_len) return text_size;
    glyph_width = font.width(cast(nk_handle)font.userdata, font.height, begin, glyph_len);

    *glyphs = 0;
    while ((text_len < byte_len) && glyph_len) {
        if (unicode == '\n') {
            text_size.x = nk_max(text_size.x, line_width);
            text_size.y += line_height;
            line_width = 0;
            *glyphs+=1;
            if (op == NK_STOP_ON_NEW_LINE)
                break;

            text_len++;
            glyph_len = nk_utf_decode(begin + text_len, &unicode, byte_len-text_len);
            continue;
        }

        if (unicode == '\r') {
            text_len++;
            *glyphs+=1;
            glyph_len = nk_utf_decode(begin + text_len, &unicode, byte_len-text_len);
            continue;
        }

        *glyphs = *glyphs + 1;
        text_len += glyph_len;
        line_width += cast(float)glyph_width;
        glyph_len = nk_utf_decode(begin + text_len, &unicode, byte_len-text_len);
        glyph_width = font.width(cast(nk_handle)font.userdata, font.height, begin+text_len, glyph_len);
        continue;
    }

    if (text_size.x < line_width)
        text_size.x = line_width;
    if (out_offset)
        *out_offset = nk_vec2(line_width, text_size.y + line_height);
    if (line_width > 0 || text_size.y == 0.0f)
        text_size.y += line_height;
    if (remaining)
        *remaining = begin+text_len;
    return text_size;
}

nk_uint nk_round_up_pow2(nk_uint v)
{
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    return v;
}

double nk_pow(double x, int n)
{
    /*  check the sign of n */
    double r = 1;
    int plus = n >= 0;
    n = (plus) ? n : -n;
    while (n > 0) {
        if ((n & 1) == 1)
            r *= x;
        n /= 2;
        x *= x;
    }
    return plus ? r : 1.0 / r;
}

int nk_ifloord(double x)
{
    x = cast(double)(cast(int)x - ((x < 0.0) ? 1 : 0));
    return cast(int)x;
}

int nk_ifloorf(float x)
{
    x = cast(float)(cast(int)x - ((x < 0.0f) ? 1 : 0));
    return cast(int)x;
}

int nk_iceilf(float x)
{
    if (x >= 0) {
        int i = cast(int)x;
        return (x > i) ? i+1: i;
    } else {
        int t = cast(int)x;
        float r = x - cast(float)t;
        return (r > 0.0f) ? t+1: t;
    }
}

int nk_log10(double n)
{
    int neg = void;
    int ret = void;
    int exp = 0;

    neg = (n < 0) ? 1 : 0;
    ret = (neg) ? cast(int)-n : cast(int)n;
    while ((ret / 10) > 0) {
        ret /= 10;
        exp++;
    }
    if (neg) exp = -exp;
    return exp;
}

nk_rect nk_get_null_rect()
{
    return nk_null_rect;
}

pragma(mangle, "nk_rect")
nk_rect nk_rect_(float x, float y, float w, float h)
{
    nk_rect r = void;
    r.x = x; r.y = y;
    r.w = w; r.h = h;
    return r;
}

nk_rect nk_recti_(int x, int y, int w, int h)
{
    nk_rect r = void;
    r.x = cast(float)x;
    r.y = cast(float)y;
    r.w = cast(float)w;
    r.h = cast(float)h;
    return r;
}

nk_rect nk_recta(nk_vec2 pos, nk_vec2 size)
{
    return nk_rect(pos.x, pos.y, size.x, size.y);
}
nk_rect nk_rectv(const(float)* r)
{
    return nk_rect(r[0], r[1], r[2], r[3]);
}

nk_rect nk_rectiv(const(int)* r)
{
    return nk_recti_(cast(short)r[0], cast(short)r[1], cast(short)r[2], cast(short)r[3]);
}

nk_vec2 nk_rect_pos(nk_rect r)
{
    nk_vec2 ret = void;
    ret.x = r.x; ret.y = r.y;
    return ret;
}

nk_vec2 nk_rect_size(nk_rect r)
{
    nk_vec2 ret = void;
    ret.x = r.w; ret.y = r.h;
    return ret;
}

nk_rect nk_shrink_rect(nk_rect r, float amount)
{
    nk_rect res = void;
    r.w = nk_max(r.w, 2 * amount);
    r.h = nk_max(r.h, 2 * amount);
    res.x = r.x + amount;
    res.y = r.y + amount;
    res.w = r.w - 2 * amount;
    res.h = r.h - 2 * amount;
    return res;
}

nk_rect nk_pad_rect(nk_rect r, nk_vec2 pad)
{
    r.w = nk_max(r.w, 2 * pad.x);
    r.h = nk_max(r.h, 2 * pad.y);
    r.x += pad.x; r.y += pad.y;
    r.w -= 2 * pad.x;
    r.h -= 2 * pad.y;
    return r;
}

pragma(mangle, "nk_vec2")
nk_vec2 nk_vec2_(float x, float y)
{
    nk_vec2 ret = void;
    ret.x = x; ret.y = y;
    return ret;
}

nk_vec2 nk_vec2i(int x, int y)
{
    nk_vec2 ret = void;
    ret.x = cast(float)x;
    ret.y = cast(float)y;
    return ret;
}

nk_vec2 nk_vec2v(const(float)* v)
{
    return nk_vec2(v[0], v[1]);
}

nk_vec2 nk_vec2iv(const(int)* v)
{
    return nk_vec2i(v[0], v[1]);
}

void nk_unify(nk_rect* clip, const(nk_rect)* a, float x0, float y0, float x1, float y1)
{
    assert(a);
    assert(clip);
    clip.x = nk_max(a.x, x0);
    clip.y = nk_max(a.y, y0);
    clip.w = nk_min(a.x + a.w, x1) - clip.x;
    clip.h = nk_min(a.y + a.h, y1) - clip.y;
    clip.w = nk_max(0, clip.w);
    clip.h = nk_max(0, clip.h);
}

void nk_triangle_from_direction(nk_vec2* result, nk_rect r, float pad_x, float pad_y, nk_heading direction)
{
    float w_half = void, h_half = void;
    assert(result);

    r.w = nk_max(2 * pad_x, r.w);
    r.h = nk_max(2 * pad_y, r.h);
    r.w = r.w - 2 * pad_x;
    r.h = r.h - 2 * pad_y;

    r.x = r.x + pad_x;
    r.y = r.y + pad_y;

    w_half = r.w / 2.0f;
    h_half = r.h / 2.0f;

    if (direction == NK_UP) {
        result[0] = nk_vec2(r.x + w_half, r.y);
        result[1] = nk_vec2(r.x + r.w, r.y + r.h);
        result[2] = nk_vec2(r.x, r.y + r.h);
    } else if (direction == NK_RIGHT) {
        result[0] = nk_vec2(r.x, r.y);
        result[1] = nk_vec2(r.x + r.w, r.y + h_half);
        result[2] = nk_vec2(r.x, r.y + r.h);
    } else if (direction == NK_DOWN) {
        result[0] = nk_vec2(r.x, r.y);
        result[1] = nk_vec2(r.x + r.w, r.y);
        result[2] = nk_vec2(r.x + w_half, r.y + r.h);
    } else {
        result[0] = nk_vec2(r.x, r.y + h_half);
        result[1] = nk_vec2(r.x + r.w, r.y);
        result[2] = nk_vec2(r.x + r.w, r.y + r.h);
    }
}

