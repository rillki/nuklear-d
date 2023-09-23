module nuklear.nuklear_pool;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              POOL
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

void nk_pool_init(nk_pool* pool, nk_allocator* alloc, uint capacity)
{
    assert(capacity >= 1);
    nk_zero(pool, typeof(*pool).sizeof);
    pool.alloc = *alloc;
    pool.capacity = capacity;
    pool.type = NK_BUFFER_DYNAMIC;
    pool.pages = null;
}
void nk_pool_free(nk_pool* pool)
{
    nk_page* iter = void;
    if (!pool) return;
    iter = pool.pages;
    if (pool.type == NK_BUFFER_FIXED) return;
    while (iter) {
        nk_page* next = iter.next;
        pool.alloc.free(pool.alloc.userdata, iter);
        iter = next;
    }
}
void nk_pool_init_fixed(nk_pool* pool, void* memory, nk_size size)
{
    nk_zero(pool, typeof(*pool).sizeof);
    assert(size >= nk_page.sizeof);
    if (size < nk_page.sizeof) return;
    /* first nk_page_element is embedded in nk_page, additional elements follow in adjacent space */
    pool.capacity = cast(uint)(1 + (size - nk_page.sizeof) / nk_page_element.sizeof);
    pool.pages = cast(nk_page*)memory;
    pool.type = NK_BUFFER_FIXED;
    pool.size = size;
}
nk_page_element* nk_pool_alloc(nk_pool* pool)
{
    if (!pool.pages || pool.pages.size >= pool.capacity) {
        /* allocate new page */
        nk_page* page = void;
        if (pool.type == NK_BUFFER_FIXED) {
            assert(pool.pages);
            if (!pool.pages) return null;
            assert(pool.pages.size < pool.capacity);
            return null;
        } else {
            nk_size size = nk_page.sizeof;
            size += (pool.capacity - 1) * nk_page_element.sizeof;
            page = cast(nk_page*)pool.alloc.alloc(pool.alloc.userdata, null, size);
            page.next = pool.pages;
            pool.pages = page;
            page.size = 0;
        }
    } return &pool.pages.win[pool.pages.size++];
}

