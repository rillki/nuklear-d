module nuklear.nuklear_buffer;
extern(C) @nogc nothrow:
__gshared:

/* ==============================================================
 *
 *                          BUFFER
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

version (NK_INCLUDE_DEFAULT_ALLOCATOR) {
    import core.stdc.stdlib;

    void* nk_malloc(nk_handle unused, void* old, nk_size size)
    {
        cast(void)(unused);
        cast(void)(old);
        return malloc(size);
    }

    void nk_mfree(nk_handle unused, void* ptr)
    {
        cast(void)(unused);
        free(ptr);
    }

    void nk_buffer_init_default(nk_buffer* buffer)
    {
        nk_allocator alloc = void;
        alloc.userdata.ptr = null;
        alloc.alloc = &nk_malloc;
        alloc.free = &nk_mfree;
        nk_buffer_init(buffer, &alloc, NK_BUFFER_DEFAULT_INITIAL_SIZE);
    }
}

void nk_buffer_init(nk_buffer* b, const(nk_allocator)* a, nk_size initial_size)
{
    assert(b);
    assert(a);
    assert(initial_size);
    if (!b || !a || !initial_size) return;

    nk_zero(b, typeof(*b).sizeof);
    b.type = NK_BUFFER_DYNAMIC;
    b.memory.ptr = a.alloc(cast(nk_handle)a.userdata, null, initial_size);
    b.memory.size = initial_size;
    b.size = initial_size;
    b.grow_factor = 2.0f;
    b.pool = cast(nk_allocator)*a;
}

void nk_buffer_init_fixed(nk_buffer* b, void* m, nk_size size)
{
    assert(b);
    assert(m);
    assert(size);
    if (!b || !m || !size) return;

    nk_zero(b, typeof(*b).sizeof);
    b.type = NK_BUFFER_FIXED;
    b.memory.ptr = m;
    b.memory.size = size;
    b.size = size;
}

void* nk_buffer_align(void* unaligned, nk_size align_, nk_size* alignment, nk_buffer_allocation_type type)
{
    void* memory = null;
    switch (type) {
    default:
    case NK_BUFFER_MAX:
    case NK_BUFFER_FRONT:
        if (align_) {
            memory = nk_align_ptr(unaligned, align_);
            *alignment = cast(nk_size)(cast(nk_byte*)memory - cast(nk_byte*)unaligned);
        } else {
            memory = unaligned;
            *alignment = 0;
        }
        break;
    case NK_BUFFER_BACK:
        if (align_) {
            memory = nk_align_ptr_back(unaligned, align_);
            *alignment = cast(nk_size)(cast(nk_byte*)unaligned - cast(nk_byte*)memory);
        } else {
            memory = unaligned;
            *alignment = 0;
        }
        break;
    }
    return memory;
}

void* nk_buffer_realloc(nk_buffer* b, nk_size capacity, nk_size* size)
{
    void* temp = void;
    nk_size buffer_size = void;

    assert(b);
    assert(size);
    if (!b || !size || !b.pool.alloc || !b.pool.free)
        return null;

    buffer_size = b.memory.size;
    temp = b.pool.alloc(b.pool.userdata, b.memory.ptr, capacity);
    assert(temp);
    if (!temp) return null;

    *size = capacity;
    if (temp != b.memory.ptr) {
        nk_memcopy(temp, b.memory.ptr, buffer_size);
        b.pool.free(b.pool.userdata, b.memory.ptr);
    }

    if (b.size == buffer_size) {
        /* no back buffer so just set correct size */
        b.size = capacity;
        return temp;
    } else {
        /* copy back buffer to the end of the new buffer */
        void* dst = void, src = void;
        nk_size back_size = void;
        back_size = buffer_size - b.size;
        dst = nk_ptr_add!void(temp, capacity - back_size);
        src = nk_ptr_add!void(temp, b.size);
        nk_memcopy(dst, src, back_size);
        b.size = capacity - back_size;
    }
    return temp;
}

void* nk_buffer_alloc(nk_buffer* b, nk_buffer_allocation_type type, nk_size size, nk_size align_)
{
    int full = void;
    nk_size alignment = void;
    void* unaligned = void;
    void* memory = void;

    assert(b);
    assert(size);
    if (!b || !size) return null;
    b.needed += size;

    /* calculate total size with needed alignment + size */
    if (type == NK_BUFFER_FRONT)
        unaligned = nk_ptr_add!void(b.memory.ptr, b.allocated);
    else unaligned = nk_ptr_add!void(b.memory.ptr, b.size - size);
    memory = nk_buffer_align(unaligned, align_, &alignment, type);

    /* check if buffer has enough memory*/
    if (type == NK_BUFFER_FRONT)
        full = ((b.allocated + size + alignment) > b.size);
    else full = ((b.size - nk_min(b.size,(size + alignment))) <= b.allocated);

    if (full) {
        nk_size capacity = void;
        if (b.type != NK_BUFFER_DYNAMIC)
            return null;
        assert(b.pool.alloc && b.pool.free);
        if (b.type != NK_BUFFER_DYNAMIC || !b.pool.alloc || !b.pool.free)
            return null;

        /* buffer is full so allocate bigger buffer if dynamic */
        capacity = cast(nk_size)(cast(float)b.memory.size * b.grow_factor);
        capacity = nk_max(capacity, nk_round_up_pow2(cast(nk_uint)(b.allocated + size)));
        b.memory.ptr = nk_buffer_realloc(b, capacity, &b.memory.size);
        if (!b.memory.ptr) return null;

        /* align newly allocated pointer */
        if (type == NK_BUFFER_FRONT)
            unaligned = nk_ptr_add!void(b.memory.ptr, b.allocated);
        else unaligned = nk_ptr_add!void(b.memory.ptr, b.size - size);
        memory = nk_buffer_align(unaligned, align_, &alignment, type);
    }
    if (type == NK_BUFFER_FRONT)
        b.allocated += size + alignment;
    else b.size -= (size + alignment);
    b.needed += alignment;
    b.calls++;
    return memory;
}

void nk_buffer_push(nk_buffer* b, nk_buffer_allocation_type type, const(void)* memory, nk_size size, nk_size align_)
{
    void* mem = nk_buffer_alloc(b, type, size, align_);
    if (!mem) return;
    nk_memcopy(mem, memory, size);
}

void nk_buffer_mark(nk_buffer* buffer, nk_buffer_allocation_type type)
{
    assert(buffer);
    if (!buffer) return;
    buffer.marker[type].active = nk_true;
    if (type == NK_BUFFER_BACK)
        buffer.marker[type].offset = buffer.size;
    else buffer.marker[type].offset = buffer.allocated;
}

void nk_buffer_reset(nk_buffer* buffer, nk_buffer_allocation_type type)
{
    assert(buffer);
    if (!buffer) return;
    if (type == NK_BUFFER_BACK) {
        /* reset back buffer either back to marker or empty */
        buffer.needed -= (buffer.memory.size - buffer.marker[type].offset);
        if (buffer.marker[type].active)
            buffer.size = buffer.marker[type].offset;
        else buffer.size = buffer.memory.size;
        buffer.marker[type].active = nk_false;
    } else {
        /* reset front buffer either back to back marker or empty */
        buffer.needed -= (buffer.allocated - buffer.marker[type].offset);
        if (buffer.marker[type].active)
            buffer.allocated = buffer.marker[type].offset;
        else buffer.allocated = 0;
        buffer.marker[type].active = nk_false;
    }
}

void nk_buffer_clear(nk_buffer* b)
{
    assert(b);
    if (!b) return;
    b.allocated = 0;
    b.size = b.memory.size;
    b.calls = 0;
    b.needed = 0;
}

void nk_buffer_free(nk_buffer* b)
{
    assert(b);
    if (!b || !b.memory.ptr) return;
    if (b.type == NK_BUFFER_FIXED) return;
    if (!b.pool.free) return;
    assert(b.pool.free);
    b.pool.free(b.pool.userdata, b.memory.ptr);
}

void nk_buffer_info(nk_memory_status* s, nk_buffer* b)
{
    assert(b);
    assert(s);
    if (!s || !b) return;
    s.allocated = b.allocated;
    s.size =  b.memory.size;
    s.needed = b.needed;
    s.memory = b.memory.ptr;
    s.calls = b.calls;
}

void* nk_buffer_memory(nk_buffer* buffer)
{
    assert(buffer);
    if (!buffer) return null;
    return buffer.memory.ptr;
}

const(void)* nk_buffer_memory_const(const(nk_buffer)* buffer)
{
    assert(buffer);
    if (!buffer) return null;
    return buffer.memory.ptr;
}

nk_size nk_buffer_total(nk_buffer* buffer)
{
    assert(buffer);
    if (!buffer) return 0;
    return buffer.memory.size;
}

