module nuklear.nuklear_page_element;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          PAGE ELEMENT
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_pool;
import nuklear.nuklear_buffer;

nk_page_element* nk_create_page_element(nk_context* ctx)
{
    nk_page_element* elem = void;
    if (ctx.freelist) {
        /* unlink page element from free list */
        elem = ctx.freelist;
        ctx.freelist = elem.next;
    } else if (ctx.use_pool) {
        /* allocate page element from memory pool */
        elem = nk_pool_alloc(&ctx.pool);
        assert(elem);
        if (!elem) return null;
    } else {
        /* allocate new page element from back of fixed size memory buffer */
        enum nk_size size = nk_page_element.sizeof;
        enum nk_size align_ = nk_page_element.alignof;
        elem = cast(nk_page_element*)nk_buffer_alloc(&ctx.memory, NK_BUFFER_BACK, size, align_);
        assert(elem);
        if (!elem) return null;
    }
    nk_zero_struct(*elem);
    elem.next = null;
    elem.prev = null;
    return elem;
}
void nk_link_page_element_into_freelist(nk_context* ctx, nk_page_element* elem)
{
    /* link table into freelist */
    if (!ctx.freelist) {
        ctx.freelist = elem;
    } else {
        elem.next = ctx.freelist;
        ctx.freelist = elem;
    }
}
void nk_free_page_element(nk_context* ctx, nk_page_element* elem)
{
    /* we have a pool so just add to free list */
    if (ctx.use_pool) {
        nk_link_page_element_into_freelist(ctx, elem);
        return;
    }
    /* if possible remove last element from back of fixed memory buffer */
    {void* elem_end = cast(void*)(elem + 1);
    void* buffer_end = cast(nk_byte*)ctx.memory.memory.ptr + ctx.memory.size;
    if (elem_end == buffer_end)
        ctx.memory.size -= nk_page_element.sizeof;
    else nk_link_page_element_into_freelist(ctx, elem);}
}

