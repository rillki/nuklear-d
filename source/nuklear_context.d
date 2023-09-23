module nuklear_context;

/* ==============================================================
 *
 *                          CONTEXT
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

void nk_setup(nk_context* ctx, const(nk_user_font)* font)
{
    assert(ctx);
    if (!ctx) return;
    nk_zero_struct(*ctx);
    nk_style_default(ctx);
    ctx.seq = 1;
    if (font) ctx.style.font = font;
    version (NK_INCLUDE_VERTEX_BUFFER_OUTPUT) {
        nk_draw_list_init(&ctx.draw_list);
    }
}
version (NK_INCLUDE_DEFAULT_ALLOCATOR) {
    nk_bool nk_init_default(nk_context* ctx, const(nk_user_font)* font)
    {
        nk_allocator alloc = void;
        alloc.userdata.ptr = 0;
        alloc.alloc = nk_malloc;
        alloc.free = nk_mfree;
        return nk_init(ctx, &alloc, font);
    }
}
nk_bool nk_init_fixed(nk_context* ctx, void* memory, nk_size size, const(nk_user_font)* font)
{
    assert(memory);
    if (!memory) return 0;
    nk_setup(ctx, font);
    nk_buffer_init_fixed(&ctx.memory, memory, size);
    ctx.use_pool = nk_false;
    return 1;
}
nk_bool nk_init_custom(nk_context* ctx, nk_buffer* cmds, nk_buffer* pool, const(nk_user_font)* font)
{
    assert(cmds);
    assert(pool);
    if (!cmds || !pool) return 0;

    nk_setup(ctx, font);
    ctx.memory = *cmds;
    if (pool.type == NK_BUFFER_FIXED) {
        /* take memory from buffer and alloc fixed pool */
        nk_pool_init_fixed(&ctx.pool, pool.memory.ptr, pool.memory.size);
    } else {
        /* create dynamic pool from buffer allocator */
        nk_allocator* alloc = &pool.pool;
        nk_pool_init(&ctx.pool, alloc, NK_POOL_DEFAULT_CAPACITY);
    }
    ctx.use_pool = nk_true;
    return 1;
}
nk_bool nk_init(nk_context* ctx, nk_allocator* alloc, const(nk_user_font)* font)
{
    assert(alloc);
    if (!alloc) return 0;
    nk_setup(ctx, font);
    nk_buffer_init(&ctx.memory, alloc, NK_DEFAULT_COMMAND_BUFFER_SIZE);
    nk_pool_init(&ctx.pool, alloc, NK_POOL_DEFAULT_CAPACITY);
    ctx.use_pool = nk_true;
    return 1;
}
version (NK_INCLUDE_COMMAND_USERDATA) {
    void nk_set_user_data(nk_context* ctx, nk_handle handle)
    {
        if (!ctx) return;
        ctx.userdata = handle;
        if (ctx.current)
            ctx.current.buffer.userdata = handle;
    }
}
void nk_free(nk_context* ctx)
{
    assert(ctx);
    if (!ctx) return;
    nk_buffer_free(&ctx.memory);
    if (ctx.use_pool)
        nk_pool_free(&ctx.pool);

    nk_zero(&ctx.input, typeof(ctx.input).sizeof);
    nk_zero(&ctx.style, typeof(ctx.style).sizeof);
    nk_zero(&ctx.memory, typeof(ctx.memory).sizeof);

    ctx.seq = 0;
    ctx.build = 0;
    ctx.begin = 0;
    ctx.end = 0;
    ctx.active = 0;
    ctx.current = 0;
    ctx.freelist = 0;
    ctx.count = 0;
}
void nk_clear(nk_context* ctx)
{
    nk_window* iter = void;
    nk_window* next = void;
    assert(ctx);

    if (!ctx) return;
    if (ctx.use_pool)
        nk_buffer_clear(&ctx.memory);
    else nk_buffer_reset(&ctx.memory, NK_BUFFER_FRONT);

    ctx.build = 0;
    ctx.memory.calls = 0;
    ctx.last_widget_state = 0;
    ctx.style.cursor_active = ctx.style.cursors[NK_CURSOR_ARROW];
    nk_memset(&ctx.overlay, 0, typeof(ctx.overlay).sizeof);

    /* garbage collector */
    iter = ctx.begin;
    while (iter) {
        /* make sure valid minimized windows do not get removed */
        if ((iter.flags & NK_WINDOW_MINIMIZED) &&
            !(iter.flags & NK_WINDOW_CLOSED) &&
            iter.seq == ctx.seq) {
            iter = iter.next;
            continue;
        }
        /* remove hotness from hidden or closed windows*/
        if (((iter.flags & NK_WINDOW_HIDDEN) ||
            (iter.flags & NK_WINDOW_CLOSED)) &&
            iter == ctx.active) {
            ctx.active = iter.prev;
            ctx.end = iter.prev;
            if (!ctx.end)
                ctx.begin = 0;
            if (ctx.active)
                ctx.active.flags &= ~cast(uint)NK_WINDOW_ROM;
        }
        /* free unused popup windows */
        if (iter.popup.win && iter.popup.win.seq != ctx.seq) {
            nk_free_window(ctx, iter.popup.win);
            iter.popup.win = 0;
        }
        /* remove unused window state tables */
        {nk_table* n = void, it = iter.tables;
        while (it) {
            n = it.next;
            if (it.seq != ctx.seq) {
                nk_remove_table(iter, it);
                nk_zero(it, nk_page_data.sizeof);
                nk_free_table(ctx, it);
                if (it == iter.tables)
                    iter.tables = n;
            } it = n;
        }}
        /* window itself is not used anymore so free */
        if (iter.seq != ctx.seq || iter.flags & NK_WINDOW_CLOSED) {
            next = iter.next;
            nk_remove_window(ctx, iter);
            nk_free_window(ctx, iter);
            iter = next;
        } else iter = iter.next;
    }
    ctx.seq++;
}
void nk_start_buffer(nk_context* ctx, nk_command_buffer* buffer)
{
    assert(ctx);
    assert(buffer);
    if (!ctx || !buffer) return;
    buffer.begin = ctx.memory.allocated;
    buffer.end = buffer.begin;
    buffer.last = buffer.begin;
    buffer.clip = nk_null_rect;
}
void nk_start(nk_context* ctx, nk_window* win)
{
    assert(ctx);
    assert(win);
    nk_start_buffer(ctx, &win.buffer);
}
void nk_start_popup(nk_context* ctx, nk_window* win)
{
    nk_popup_buffer* buf = void;
    assert(ctx);
    assert(win);
    if (!ctx || !win) return;

    /* save buffer fill state for popup */
    buf = &win.popup.buf;
    buf.begin = win.buffer.end;
    buf.end = win.buffer.end;
    buf.parent = win.buffer.last;
    buf.last = buf.begin;
    buf.active = nk_true;
}
void nk_finish_popup(nk_context* ctx, nk_window* win)
{
    nk_popup_buffer* buf = void;
    assert(ctx);
    assert(win);
    if (!ctx || !win) return;

    buf = &win.popup.buf;
    buf.last = win.buffer.last;
    buf.end = win.buffer.end;
}
void nk_finish_buffer(nk_context* ctx, nk_command_buffer* buffer)
{
    assert(ctx);
    assert(buffer);
    if (!ctx || !buffer) return;
    buffer.end = ctx.memory.allocated;
}
void nk_finish(nk_context* ctx, nk_window* win)
{
    nk_popup_buffer* buf = void;
    nk_command* parent_last = void;
    void* memory = void;

    assert(ctx);
    assert(win);
    if (!ctx || !win) return;
    nk_finish_buffer(ctx, &win.buffer);
    if (!win.popup.buf.active) return;

    buf = &win.popup.buf;
    memory = ctx.memory.memory.ptr;
    parent_last = nk_ptr_add!nk_command(memory, buf.parent);
    parent_last.next = buf.end;
}
void nk_build(nk_context* ctx)
{
    nk_window* it = null;
    nk_command* cmd = null;
    nk_byte* buffer = null;

    /* draw cursor overlay */
    if (!ctx.style.cursor_active)
        ctx.style.cursor_active = ctx.style.cursors[NK_CURSOR_ARROW];
    if (ctx.style.cursor_active && !ctx.input.mouse.grabbed && ctx.style.cursor_visible) {
        nk_rect mouse_bounds = void;
        const(nk_cursor)* cursor = ctx.style.cursor_active;
        nk_command_buffer_init(&ctx.overlay, &ctx.memory, NK_CLIPPING_OFF);
        nk_start_buffer(ctx, &ctx.overlay);

        mouse_bounds.x = ctx.input.mouse.pos.x - cursor.offset.x;
        mouse_bounds.y = ctx.input.mouse.pos.y - cursor.offset.y;
        mouse_bounds.w = cursor.size.x;
        mouse_bounds.h = cursor.size.y;

        nk_draw_image(&ctx.overlay, mouse_bounds, &cursor.img, nk_white);
        nk_finish_buffer(ctx, &ctx.overlay);
    }
    /* build one big draw command list out of all window buffers */
    it = ctx.begin;
    buffer = cast(nk_byte*)ctx.memory.memory.ptr;
    while (it != 0) {
        nk_window* next = it.next;
        if (it.buffer.last == it.buffer.begin || (it.flags & NK_WINDOW_HIDDEN)||
            it.seq != ctx.seq)
            goto cont;

        cmd = nk_ptr_add!nk_command(buffer, it.buffer.last);
        while (next && ((next.buffer.last == next.buffer.begin) ||
            (next.flags & NK_WINDOW_HIDDEN) || next.seq != ctx.seq))
            next = next.next; /* skip empty command buffers */

        if (next) cmd.next = next.buffer.begin;
        cont: it = next;
    }
    /* append all popup draw commands into lists */
    it = ctx.begin;
    while (it != 0) {
        nk_window* next = it.next;
        nk_popup_buffer* buf = void;
        if (!it.popup.buf.active)
            goto skip;

        buf = &it.popup.buf;
        cmd.next = buf.begin;
        cmd = nk_ptr_add!nk_command(buffer, buf.last);
        buf.active = nk_false;
        skip: it = next;
    }
    if (cmd) {
        /* append overlay commands */
        if (ctx.overlay.end != ctx.overlay.begin)
            cmd.next = ctx.overlay.begin;
        else cmd.next = ctx.memory.allocated;
    }
}
const(nk_command)* nk__begin(nk_context* ctx)
{
    nk_window* iter = void;
    nk_byte* buffer = void;
    assert(ctx);
    if (!ctx) return 0;
    if (!ctx.count) return 0;

    buffer = cast(nk_byte*)ctx.memory.memory.ptr;
    if (!ctx.build) {
        nk_build(ctx);
        ctx.build = nk_true;
    }
    iter = ctx.begin;
    while (iter && ((iter.buffer.begin == iter.buffer.end) ||
        (iter.flags & NK_WINDOW_HIDDEN) || iter.seq != ctx.seq))
        iter = iter.next;
    if (!iter) return 0;
    return constnk_ptr_add_const!nk_command(buffer, iter.buffer.begin);
}

const(nk_command)* nk__next(nk_context* ctx, const(nk_command)* cmd)
{
    nk_byte* buffer = void;
    const(nk_command)* next = void;
    assert(ctx);
    if (!ctx || !cmd || !ctx.count) return 0;
    if (cmd.next >= ctx.memory.allocated) return 0;
    buffer = cast(nk_byte*)ctx.memory.memory.ptr;
    next = constnk_ptr_add_const!nk_command(buffer, cmd.next);
    return next;
}

