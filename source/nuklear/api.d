module nuklear.api;

public {
    import nuklear.nuklear_9slice;
    import nuklear.nuklear_buffer;
    import nuklear.nuklear_button;
    import nuklear.nuklear_chart;
    import nuklear.nuklear_color;
    import nuklear.nuklear_color_picker;
    import nuklear.nuklear_combo;
    import nuklear.nuklear_context;
    import nuklear.nuklear_contextual;
    import nuklear.nuklear_draw;
    import nuklear.nuklear_edit;
    import nuklear.nuklear_font;
    import nuklear.nuklear_group;
    import nuklear.nuklear_image;
    import nuklear.nuklear_input;
    import nuklear.nuklear_layout;
    import nuklear.nuklear_page_element;
    import nuklear.nuklear_panel;
    import nuklear.nuklear_pool;
    import nuklear.nuklear_popup;
    import nuklear.nuklear_progress;
    import nuklear.nuklear_property;
    import nuklear.nuklear_scrollbar;
    import nuklear.nuklear_selectable;
    import nuklear.nuklear_slider;
    import nuklear.nuklear_string;
    import nuklear.nuklear_style;
    import nuklear.nuklear_table;
    import nuklear.nuklear_text_editor;
    import nuklear.nuklear_text;
    import nuklear.nuklear_toggle;
    import nuklear.nuklear_tooltip;
    import nuklear.nuklear_tree;
    import nuklear.nuklear_types;
    import nuklear.nuklear_utf8;
    import nuklear.nuklear_util;
    import nuklear.nuklear_vertex;
    import nuklear.nuklear_widget;
    import nuklear.nuklear_window;
}

// import nuklear.nuklear_types;
// import nuklear.nuklear_util;
// import nuklear.style;
// version(NK_INCLUDE_STANDARD_VARARGS) import core.stdc.stdarg;

// version(NK_INCLUDE_DEFAULT_ALLOCATOR) 
// {
//     bool nk_init_default(nk_context* ctx, const(nk_user_font)* font) 
//     {
//         nk_allocator alloc;
//         alloc.userdata.ptr = null;
//         alloc.alloc = &nk_malloc;
//         alloc.free = &nk_mfree;
//         return nk_init(ctx, &alloc, font);
//     }
// }

// void nk_setup(nk_context *ctx, const(nk_user_font)* font)
// {
//     assert(ctx);
//     if (!ctx) return;
//     nk_zero_struct(*ctx);
//     nk_style_default(ctx);
//     ctx.seq = 1;
//     if (font) ctx.style.font = font;
//     version(NK_INCLUDE_VERTEX_BUFFER_OUTPUT) nk_draw_list_init(&ctx.draw_list);
// }

// bool nk_init_fixed(nk_context* ctx, void* memory, nk_size size, const(nk_user_font)* font)
// {
//     assert(memory);
//     if (!memory) return 0;
//     nk_setup(ctx, font);
//     nk_buffer_init_fixed(&ctx.memory, memory, size);
//     ctx.use_pool = nk_false;
//     return 1;
// }

// bool nk_init(nk_context* ctx, nk_allocator* alloc, const(nk_user_font)* font)
// {
//     assert(alloc);
//     if (!alloc) return 0;
//     nk_setup(ctx, font);
//     nk_buffer_init(&ctx.memory, alloc, NK_DEFAULT_COMMAND_BUFFER_SIZE);
//     nk_pool_init(&ctx.pool, alloc, NK_POOL_DEFAULT_CAPACITY);
//     ctx.use_pool = nk_true;
//     return 1;
// }

// void nk_pool_init(nk_pool *pool, nk_allocator *alloc, uint capacity)
// {
//     assert(capacity >= 1);
//     nk_zero(pool, (*pool).sizeof);
//     pool.alloc = *alloc;
//     pool.capacity = capacity;
//     pool.type = NK_BUFFER_DYNAMIC;
//     pool.pages = null;
// }

// void nk_pool_init_fixed(nk_pool *pool, void *memory, nk_size size)
// {
//     nk_zero(pool, (*pool).sizeof);
//     assert(size >= nk_page.sizeof);
//     if (size < nk_page.sizeof) return;
//     /* first nk_page_element is embedded in_ nk_page, additional elements follow in_ adjacent space */
//     pool.capacity = cast(uint)(1 + (size - nk_page.sizeof) / nk_page_element.sizeof);
//     pool.pages = cast(nk_page*)memory;
//     pool.type = NK_BUFFER_FIXED;
//     pool.size = size;
// }

// bool nk_init_custom(nk_context* ctx, nk_buffer* cmds, nk_buffer* pool, const(nk_user_font)* font)
// {
//     assert(cmds);
//     assert(pool);
//     if (!cmds || !pool) return 0;

//     nk_setup(ctx, font);
//     ctx.memory = *cmds;
//     if (pool.type == NK_BUFFER_FIXED) {
//         /* take memory from buffer and alloc fixed pool */
//         nk_pool_init_fixed(&ctx.pool, pool.memory.ptr, pool.memory.size);
//     } else {
//         /* create dynamic pool from buffer allocator */
//         nk_allocator *alloc = &pool.pool;
//         nk_pool_init(&ctx.pool, alloc, NK_POOL_DEFAULT_CAPACITY);
//     }
//     ctx.use_pool = nk_true;
//     return 1;
// }

// void nk_link_page_element_into_freelist(nk_context *ctx, nk_page_element *elem)
// {
//     /* link table into freelist */
//     if (!ctx.freelist) {
//         ctx.freelist = elem;
//     } else {
//         elem.next = ctx.freelist;
//         ctx.freelist = elem;
//     }
// }

// void nk_free_page_element(nk_context *ctx, nk_page_element *elem)
// {
//     /* we have a pool so just add to free list */
//     if (ctx.use_pool) {
//         nk_link_page_element_into_freelist(ctx, elem);
//         return;
//     }
//     /* if possible remove last element from back of fixed memory buffer */
//     {
//         void* elem_end = cast(void*)(elem + 1);
//         void* buffer_end = cast(nk_byte*)ctx.memory.memory.ptr + ctx.memory.size;
//         if (elem_end == buffer_end)
//             ctx.memory.size -= nk_page_element.sizeof;
//         else nk_link_page_element_into_freelist(ctx, elem);
//     }
// }

// void nk_remove_table(nk_window *win, nk_table *tbl)
// {
//     if (win.tables == tbl)
//         win.tables = tbl.next;
//     if (tbl.next)
//         tbl.next.prev = tbl.prev;
//     if (tbl.prev)
//         tbl.prev.next = tbl.next;
//     tbl.next = null;
//     tbl.prev = null;
// }

// void nk_free_table(nk_context *ctx, nk_table *tbl)
// {
//     nk_page_data *pd = nk_container_of!(nk_page_data, "tbl")(tbl);
//     nk_page_element *pe = nk_container_of!(nk_page_element, "data")(pd);
//     nk_free_page_element(ctx, pe);
// }

// void nk_free_window(nk_context *ctx, nk_window *win)
// {
//     /* unlink windows from list */
//     nk_table *it = win.tables;
//     if (win.popup.win) {
//         nk_free_window(ctx, win.popup.win);
//         win.popup.win = null;
//     }
//     win.next = null;
//     win.prev = null;

//     while (it) {
//         /*free window state tables */
//         nk_table *n = it.next;
//         nk_remove_table(win, it);
//         nk_free_table(ctx, it);
//         if (it == win.tables)
//             win.tables = n;
//         it = n;
//     }

//     /* link windows into freelist */
//     {
//         nk_page_data *pd = nk_container_of!(nk_page_data, "win")(win);
//         nk_page_element *pe = nk_container_of!(nk_page_element, "data")(pd);
//         nk_free_page_element(ctx, pe);
//     }
// }

// void nk_remove_window(nk_context *ctx, nk_window *win) 
// {
//     if (win == ctx.begin || win == ctx.end) {
//         if (win == ctx.begin) {
//             ctx.begin = win.next;
//             if (win.next)
//                 win.next.prev = null;
//         }
//         if (win == ctx.end) {
//             ctx.end = win.prev;
//             if (win.prev)
//                 win.prev.next = null;
//         }
//     } else {
//         if (win.next)
//             win.next.prev = win.prev;
//         if (win.prev)
//             win.prev.next = win.next;
//     }
//     if (win == ctx.active || !ctx.active) {
//         ctx.active = ctx.end;
//         if (ctx.end)
//             ctx.end.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
//     }
//     win.next = null;
//     win.prev = null;
//     ctx.count--;
// }

// void nk_clear(nk_context* ctx)
// {
//     nk_window *iter;
//     nk_window *next;
//     assert(ctx);

//     if (!ctx) return;
//     if (ctx.use_pool)
//         nk_buffer_clear(&ctx.memory);
//     else nk_buffer_reset(&ctx.memory, NK_BUFFER_FRONT);

//     ctx.build = 0;
//     ctx.memory.calls = 0;
//     ctx.last_widget_state = 0;
//     ctx.style.cursor_active = ctx.style.cursors[NK_CURSOR_ARROW];
//     nk_memset(&ctx.overlay, 0, ctx.overlay.sizeof);

//     /* garbage collector */
//     iter = ctx.begin;
//     while (iter) {
//         /* make sure valid minimized windows do not get removed */
//         if ((iter.flags & NK_WINDOW_MINIMIZED) &&
//             !(iter.flags & NK_WINDOW_CLOSED) &&
//             iter.seq == ctx.seq) {
//             iter = iter.next;
//             continue;
//         }
//         /* remove hotness from hidden or closed windows*/
//         if (((iter.flags & NK_WINDOW_HIDDEN) ||
//             (iter.flags & NK_WINDOW_CLOSED)) &&
//             iter == ctx.active) {
//             ctx.active = iter.prev;
//             ctx.end = iter.prev;
//             if (!ctx.end)
//                 ctx.begin = null;
//             if (ctx.active)
//                 ctx.active.flags &= ~cast(uint)NK_WINDOW_ROM;
//         }
//         /* free unused popup windows */
//         if (iter.popup.win && iter.popup.win.seq != ctx.seq) {
//             nk_free_window(ctx, iter.popup.win);
//             iter.popup.win = null;
//         }
//         /* remove unused window state tables */
//         {
//             nk_table* n, it = iter.tables;
//             while (it) {
//                 n = it.next;
//                 if (it.seq != ctx.seq) {
//                     nk_remove_table(iter, it);
//                     nk_zero(it, nk_page_data.sizeof);
//                     nk_free_table(ctx, it);
//                     if (it == iter.tables)
//                         iter.tables = n;
//                 } it = n;
//             }
//         }
//         /* window itself is not used anymore so free */
//         if (iter.seq != ctx.seq || iter.flags & NK_WINDOW_CLOSED) {
//             next = iter.next;
//             nk_remove_window(ctx, iter);
//             nk_free_window(ctx, iter);
//             iter = next;
//         } else iter = iter.next;
//     }
//     ctx.seq++;
// }

// void nk_pool_free(nk_pool *pool)
// {
//     nk_page *iter;
//     if (!pool) return;
//     iter = pool.pages;
//     if (pool.type == NK_BUFFER_FIXED) return;
//     while (iter) {
//         nk_page *next = iter.next;
//         pool.alloc.free(pool.alloc.userdata, iter);
//         iter = next;
//     }
// }

// void nk_free(nk_context* ctx)
// {
//     assert(ctx);
//     if (!ctx) return;
//     nk_buffer_free(&ctx.memory);
//     if (ctx.use_pool)
//         nk_pool_free(&ctx.pool);

//     nk_zero(&ctx.input, ctx.input.sizeof);
//     nk_zero(&ctx.style, ctx.style.sizeof);
//     nk_zero(&ctx.memory, ctx.memory.sizeof);

//     ctx.seq = 0;
//     ctx.build = 0;
//     ctx.begin = null;
//     ctx.end = null;
//     ctx.active = null;
//     ctx.current = null;
//     ctx.freelist = null;
//     ctx.count = 0;
// }

// version(NK_INCLUDE_COMMAND_USERDATA) {
//     void nk_set_user_data(nk_context* ctx, nk_handle handle)
//     {
//         if (!ctx) return;
//         ctx.userdata = handle;
//         if (ctx.current)
//             ctx.current.buffer.userdata = handle;
//     }
// }

// void nk_input_begin(nk_context* ctx)
// {
//     int i;
//     nk_input *in_;
//     assert(ctx);
//     if (!ctx) return;
//     in_ = &ctx.input;
//     for (i = 0; i < NK_BUTTON_MAX; ++i)
//         in_.mouse.buttons[i].clicked = 0;

//     in_.keyboard.text_len = 0;
//     in_.mouse.scroll_delta = nk_vec2(0,0);
//     in_.mouse.prev.x = in_.mouse.pos.x;
//     in_.mouse.prev.y = in_.mouse.pos.y;
//     in_.mouse.delta.x = 0;
//     in_.mouse.delta.y = 0;
//     for (i = 0; i < NK_KEY_MAX; i++)
//         in_.keyboard.keys[i].clicked = 0;
// }

// void nk_input_motion(nk_context* ctx, int x, int y)
// {
//     nk_input *in_;
//     assert(ctx);
//     if (!ctx) return;
//     in_ = &ctx.input;
//     in_.mouse.pos.x = cast(float)x;
//     in_.mouse.pos.y = cast(float)y;
//     in_.mouse.delta.x = in_.mouse.pos.x - in_.mouse.prev.x;
//     in_.mouse.delta.y = in_.mouse.pos.y - in_.mouse.prev.y;
// }

// void nk_input_key(nk_context* ctx, nk_keys key, bool down)
// {
//     nk_input *in_;
//     assert(ctx);
//     if (!ctx) return;
//     in_ = &ctx.input;
//     version(NK_KEYSTATE_BASED_INPUT) {
//         if (in_.keyboard.keys[key].down != down)
//             in_.keyboard.keys[key].clicked++;
//     } else {
//         in_.keyboard.keys[key].clicked++;
//     }
//     in_.keyboard.keys[key].down = down;
// }

// void nk_input_button(nk_context* ctx, nk_buttons id, int x, int y, bool down)
// {
//     nk_mouse_button *btn;
//     nk_input *in_;
//     assert(ctx);
//     if (!ctx) return;
//     in_ = &ctx.input;
//     if (in_.mouse.buttons[id].down == down) return;

//     btn = &in_.mouse.buttons[id];
//     btn.clicked_pos.x = cast(float)x;
//     btn.clicked_pos.y = cast(float)y;
//     btn.down = down;
//     btn.clicked++;

//     /* Fix Click-Drag for touch events. */
//     in_.mouse.delta.x = 0;
//     in_.mouse.delta.y = 0;
//     version(NK_BUTTON_TRIGGER_ON_RELEASE) {
//         if (down == 1 && id == NK_BUTTON_LEFT)
//         {
//             in_.mouse.down_pos.x = btn.clicked_pos.x;
//             in_.mouse.down_pos.y = btn.clicked_pos.y;
//         }
//     }
// }

// void nk_input_scroll(nk_context* ctx, nk_vec2 val)
// {
//     assert(ctx);
//     if (!ctx) return;
//     ctx.input.mouse.scroll_delta.x += val.x;
//     ctx.input.mouse.scroll_delta.y += val.y;
// }

// void nk_input_char(nk_context* ctx, char c)
// {
//     nk_glyph glyph;
//     assert(ctx);
//     if (!ctx) return;
//     glyph[0] = c;
//     nk_input_glyph(ctx, glyph.ptr);
// }

// void nk_input_glyph(nk_context* ctx, const(char)* glyph)
// {
//     int len = 0;
//     nk_rune unicode;
//     nk_input *in_;

//     assert(ctx);
//     if (!ctx) return;
//     in_ = &ctx.input;

//     len = nk_utf_decode(glyph, &unicode, NK_UTF_SIZE);
//     if (len && ((in_.keyboard.text_len + len) < NK_INPUT_MAX)) {
//         nk_utf_encode(unicode, &in_.keyboard.text[in_.keyboard.text_len],
//             NK_INPUT_MAX - in_.keyboard.text_len);
//         in_.keyboard.text_len += len;
//     }
// }

// void nk_input_unicode(nk_context* ctx, nk_rune unicode)
// {
//     nk_glyph rune;
//     assert(ctx);
//     if (!ctx) return;
//     nk_utf_encode(unicode, rune.ptr, NK_UTF_SIZE);
//     nk_input_glyph(ctx, rune.ptr);
// }

// void nk_input_end(nk_context* ctx)
// {
//     nk_input *in_;
//     assert(ctx);
//     if (!ctx) return;
//     in_ = &ctx.input;
//     if (in_.mouse.grab)
//         in_.mouse.grab = 0;
//     if (in_.mouse.ungrab) {
//         in_.mouse.grabbed = 0;
//         in_.mouse.ungrab = 0;
//         in_.mouse.grab = 0;
//     }
// }

// void nk_command_buffer_init(nk_command_buffer *cb, nk_buffer *b, nk_command_clipping clip)
// {
//     assert(cb);
//     assert(b);
//     if (!cb || !b) return;
//     cb.base = b;
//     cb.use_clipping = cast(int)clip;
//     cb.begin = b.allocated;
//     cb.end = b.allocated;
//     cb.last = b.allocated;
// }

// void nk_start_buffer(nk_context *ctx, nk_command_buffer *buffer)
// {
//     assert(ctx);
//     assert(buffer);
//     if (!ctx || !buffer) return;
//     buffer.begin = ctx.memory.allocated;
//     buffer.end = buffer.begin;
//     buffer.last = buffer.begin;
//     buffer.clip = nk_null_rect;
// }

// void nk_finish_buffer(nk_context *ctx, nk_command_buffer *buffer)
// {
//     assert(ctx);
//     assert(buffer);
//     if (!ctx || !buffer) return;
//     buffer.end = ctx.memory.allocated;
// }

// // checkpoint
// void nk_build(nk_context *ctx)
// {
//     nk_window *it = null;
//     nk_command *cmd = null;
//     nk_byte *buffer = null;

//     /* draw cursor overlay */
//     if (!ctx.style.cursor_active)
//         ctx.style.cursor_active = ctx.style.cursors[NK_CURSOR_ARROW];
//     if (ctx.style.cursor_active && !ctx.input.mouse.grabbed && ctx.style.cursor_visible) {
//         nk_rect mouse_bounds;
//         const(nk_cursor)* cursor = ctx.style.cursor_active;
//         nk_command_buffer_init(&ctx.overlay, &ctx.memory, NK_CLIPPING_OFF);
//         nk_start_buffer(ctx, &ctx.overlay);

//         mouse_bounds.x = ctx.input.mouse.pos.x - cursor.offset.x;
//         mouse_bounds.y = ctx.input.mouse.pos.y - cursor.offset.y;
//         mouse_bounds.w = cursor.size.x;
//         mouse_bounds.h = cursor.size.y;

//         nk_draw_image(&ctx.overlay, mouse_bounds, &cursor.img, nk_white);
//         nk_finish_buffer(ctx, &ctx.overlay);
//     }
//     /* build one big draw command list out of all window buffers */
//     it = ctx.begin;
//     buffer = cast(nk_byte*)ctx.memory.memory.ptr;
//     while (it != null) {
//         nk_window *next = it.next;
//         if (it.buffer.last == it.buffer.begin || (it.flags & NK_WINDOW_HIDDEN)||
//             it.seq != ctx.seq)
//             goto cont;

//         cmd = nk_ptr_add!nk_command(buffer, it.buffer.last);
//         while (next && ((next.buffer.last == next.buffer.begin) ||
//             (next.flags & NK_WINDOW_HIDDEN) || next.seq != ctx.seq))
//             next = next.next; /* skip empty command buffers */

//         if (next) cmd.next = next.buffer.begin;
//         cont: it = next;
//     }
//     /* append all popup draw commands into lists */
//     it = ctx.begin;
//     while (it != null) {
//         nk_window *next = it.next;
//         nk_popup_buffer *buf;
//         if (!it.popup.buf.active)
//             goto skip;

//         buf = &it.popup.buf;
//         cmd.next = buf.begin;
//         cmd = nk_ptr_add!nk_command(buffer, buf.last);
//         buf.active = nk_false;
//         skip: it = next;
//     }
//     if (cmd) {
//         /* append overlay commands */
//         if (ctx.overlay.end != ctx.overlay.begin)
//             cmd.next = ctx.overlay.begin;
//         else cmd.next = ctx.memory.allocated;
//     }
// }

// const(nk_command)* nk__begin(nk_context* ctx)
// {
//     nk_window *iter;
//     nk_byte *buffer;
//     assert(ctx);
//     if (!ctx) return null;
//     if (!ctx.count) return null;

//     buffer = cast(nk_byte*)ctx.memory.memory.ptr;
//     if (!ctx.build) {
//         nk_build(ctx);
//         ctx.build = nk_true;
//     }
//     iter = ctx.begin;
//     while (iter && ((iter.buffer.begin == iter.buffer.end) ||
//         (iter.flags & NK_WINDOW_HIDDEN) || iter.seq != ctx.seq))
//         iter = iter.next;
//     if (!iter) return null;
//     return nk_ptr_add_const!nk_command(buffer, iter.buffer.begin);
// }

// const(nk_command)* nk__next(nk_context* ctx, const(nk_command)* cmd)
// {
//     nk_byte *buffer;
//     const(nk_command)* next;
//     assert(ctx);
//     if (!ctx || !cmd || !ctx.count) return null;
//     if (cmd.next >= ctx.memory.allocated) return null;
//     buffer = cast(nk_byte*)ctx.memory.memory.ptr;
//     next = nk_ptr_add_const!nk_command(buffer, cmd.next);
//     return next;
// }

// version(NK_INCLUDE_VERTEX_BUFFER_OUTPUT) {
//     nk_draw_command* nk_draw_list_push_command(nk_draw_list* list, nk_rect clip, nk_handle texture)
//     {
//         enum nk_size cmd_align = nk_draw_command.alignof;
//         enum nk_size cmd_size = nk_draw_command.sizeof;
//         nk_draw_command* cmd;

//         assert(list);
//         cmd = cast(nk_draw_command*)nk_buffer_alloc(list.buffer, NK_BUFFER_BACK, cmd_size, cmd_align);

//         if (!cmd) return null;
//         if (!list.cmd_count) {
//             nk_byte* memory = cast(nk_byte*)nk_buffer_memory(list.buffer);
//             nk_size total = nk_buffer_total(list.buffer);
//             memory = nk_ptr_add!nk_byte(memory, total);
//             list.cmd_offset = cast(nk_size)(memory - cast(nk_byte*)cmd);
//         }

//         cmd.elem_count = 0;
//         cmd.clip_rect = clip;
//         cmd.texture = texture;
//         version (NK_INCLUDE_COMMAND_USERDATA) {
//             cmd.userdata = list.userdata;
//         }

//         list.cmd_count++;
//         list.clip_rect = clip;
//         return cmd;
//     }

//     nk_draw_command* nk_draw_list_command_last(nk_draw_list* list)
//     {
//         void* memory;
//         nk_size size;
//         nk_draw_command* cmd;
//         assert(list.cmd_count);

//         memory = nk_buffer_memory(list.buffer);
//         size = nk_buffer_total(list.buffer);
//         cmd = nk_ptr_add!nk_draw_command(memory, size - list.cmd_offset);
//         return (cmd - (list.cmd_count-1));
//     }

//     void nk_draw_list_add_clip(nk_draw_list* list, nk_rect rect)
//     {
//         assert(list);
//         if (!list) return;
//         if (!list.cmd_count) {
//             nk_draw_list_push_command(list, rect, list.config.tex_null.texture);
//         } else {
//             nk_draw_command* prev = nk_draw_list_command_last(list);
//             if (prev.elem_count == 0)
//                 prev.clip_rect = rect;
//             nk_draw_list_push_command(list, rect, prev.texture);
//         }
//     }

//     nk_flags nk_convert(nk_context* ctx, nk_buffer* cmds, nk_buffer* vertices, nk_buffer* elements, const(nk_convert_config)* config)
//     {
//         nk_flags res = NK_CONVERT_SUCCESS;
//         const(nk_command)* cmd;
//         assert(ctx);
//         assert(cmds);
//         assert(vertices);
//         assert(elements);
//         assert(config);
//         assert(config.vertex_layout);
//         assert(config.vertex_size);
//         if (!ctx || !cmds || !vertices || !elements || !config || !config.vertex_layout)
//             return NK_CONVERT_INVALID_PARAM;

//         nk_draw_list_setup(&ctx.draw_list, config, cmds, vertices, elements, config.line_AA, config.shape_AA);
        
//         for (cmd = nk__begin(ctx); cmd != null; cmd = nk__next(ctx, cmd))
//         {
//             version (NK_INCLUDE_COMMAND_USERDATA) ctx.draw_list.userdata = cmd.userdata;

//             switch (cmd.type) {
//             case NK_COMMAND_NOP: break;
//             case NK_COMMAND_SCISSOR: {
//                 const(nk_command_scissor)* s = cast(const(nk_command_scissor)*) cmd;
//                 nk_draw_list_add_clip(&ctx.draw_list, nk_rect(s.x, s.y, s.w, s.h));
//             } break;
//             case NK_COMMAND_LINE: {
//                 const(nk_command_line)* l = cast(const(nk_command_line)*) cmd;
//                 nk_draw_list_stroke_line(&ctx.draw_list, nk_vec2(l.begin.x, l.begin.y),
//                     nk_vec2(l.end.x, l.end.y), l.color, l.line_thickness);
//             } break;
//             case NK_COMMAND_CURVE: {
//                 const(nk_command_curve)* q = cast(const(nk_command_curve)*) cmd;
//                 nk_draw_list_stroke_curve(&ctx.draw_list, nk_vec2(q.begin.x, q.begin.y),
//                     nk_vec2(q.ctrl[0].x, q.ctrl[0].y), nk_vec2(q.ctrl[1].x,
//                     q.ctrl[1].y), nk_vec2(q.end.x, q.end.y), q.color,
//                     config.curve_segment_count, q.line_thickness);
//             } break;
//             case NK_COMMAND_RECT: {
//                 const(nk_command_rect)* r = cast(const(nk_command_rect)*) cmd;
//                 nk_draw_list_stroke_rect(&ctx.draw_list, nk_rect(r.x, r.y, r.w, r.h),
//                     r.color, cast(float)r.rounding, r.line_thickness);
//             } break;
//             case NK_COMMAND_RECT_FILLED: {
//                 const(nk_command_rect_filled)* r = cast(const(nk_command_rect_filled)*) cmd;
//                 nk_draw_list_fill_rect(&ctx.draw_list, nk_rect(r.x, r.y, r.w, r.h),
//                     r.color, cast(float)r.rounding);
//             } break;
//             case NK_COMMAND_RECT_MULTI_COLOR: {
//                 const(nk_command_rect_multi_color)* r = cast(const(nk_command_rect_multi_color)*) cmd;
//                 nk_draw_list_fill_rect_multi_color(&ctx.draw_list, nk_rect(r.x, r.y, r.w, r.h),
//                     r.left, r.top, r.right, r.bottom);
//             } break;
//             case NK_COMMAND_CIRCLE: {
//                 const(nk_command_circle)* c = cast(const(nk_command_circle)*) cmd;
//                 nk_draw_list_stroke_circle(&ctx.draw_list, nk_vec2(cast(float)c.x + cast(float)c.w/2,
//                     cast(float)c.y + cast(float)c.h/2), cast(float)c.w/2, c.color,
//                     config.circle_segment_count, c.line_thickness);
//             } break;
//             case NK_COMMAND_CIRCLE_FILLED: {
//                 const(nk_command_circle_filled)* c = cast(const(nk_command_circle_filled )*) cmd;
//                 nk_draw_list_fill_circle(&ctx.draw_list, nk_vec2(cast(float)c.x + cast(float)c.w/2,
//                     cast(float)c.y + cast(float)c.h/2), cast(float)c.w/2, c.color,
//                     config.circle_segment_count);
//             } break;
//             case NK_COMMAND_ARC: {
//                 const(nk_command_arc)* c = cast(const(nk_command_arc)*) cmd;
//                 nk_draw_list_path_line_to(&ctx.draw_list, nk_vec2(c.cx, c.cy));
//                 nk_draw_list_path_arc_to(&ctx.draw_list, nk_vec2(c.cx, c.cy), c.r,
//                     c.a[0], c.a[1], config.arc_segment_count);
//                 nk_draw_list_path_stroke(&ctx.draw_list, c.color, NK_STROKE_CLOSED, c.line_thickness);
//             } break;
//             case NK_COMMAND_ARC_FILLED: {
//                 const(nk_command_arc_filled)* c = cast(const(nk_command_arc_filled)*) cmd;
//                 nk_draw_list_path_line_to(&ctx.draw_list, nk_vec2(c.cx, c.cy));
//                 nk_draw_list_path_arc_to(&ctx.draw_list, nk_vec2(c.cx, c.cy), c.r,
//                     c.a[0], c.a[1], config.arc_segment_count);
//                 nk_draw_list_path_fill(&ctx.draw_list, c.color);
//             } break;
//             case NK_COMMAND_TRIANGLE: {
//                 const(nk_command_triangle)* t = cast(const(nk_command_triangle)*) cmd;
//                 nk_draw_list_stroke_triangle(&ctx.draw_list, nk_vec2(t.a.x, t.a.y),
//                     nk_vec2(t.b.x, t.b.y), nk_vec2(t.c.x, t.c.y), t.color,
//                     t.line_thickness);
//             } break;
//             case NK_COMMAND_TRIANGLE_FILLED: {
//                 const(nk_command_triangle_filled)* t = cast(const(nk_command_triangle_filled)*) cmd;
//                 nk_draw_list_fill_triangle(&ctx.draw_list, nk_vec2(t.a.x, t.a.y),
//                     nk_vec2(t.b.x, t.b.y), nk_vec2(t.c.x, t.c.y), t.color);
//             } break;
//             case NK_COMMAND_POLYGON: {
//                 int i;
//                 const(nk_command_polygon)* p = cast(const(nk_command_polygon)*) cmd;
//                 for (i = 0; i < p.point_count; ++i) {
//                     nk_vec2 pnt = nk_vec2(cast(float)p.points[i].x, cast(float)p.points[i].y);
//                     nk_draw_list_path_line_to(&ctx.draw_list, pnt);
//                 }
//                 nk_draw_list_path_stroke(&ctx.draw_list, p.color, NK_STROKE_CLOSED, p.line_thickness);
//             } break;
//             case NK_COMMAND_POLYGON_FILLED: {
//                 int i;
//                 const(nk_command_polygon_filled)* p = cast(const(nk_command_polygon_filled)*) cmd;
//                 for (i = 0; i < p.point_count; ++i) {
//                     nk_vec2 pnt = nk_vec2(cast(float)p.points[i].x, cast(float)p.points[i].y);
//                     nk_draw_list_path_line_to(&ctx.draw_list, pnt);
//                 }
//                 nk_draw_list_path_fill(&ctx.draw_list, p.color);
//             } break;
//             case NK_COMMAND_POLYLINE: {
//                 int i;
//                 const(nk_command_polyline)* p = cast(const(nk_command_polyline)*) cmd;
//                 for (i = 0; i < p.point_count; ++i) {
//                     nk_vec2 pnt = nk_vec2(cast(float)p.points[i].x, cast(float)p.points[i].y);
//                     nk_draw_list_path_line_to(&ctx.draw_list, pnt);
//                 }
//                 nk_draw_list_path_stroke(&ctx.draw_list, p.color, NK_STROKE_OPEN, p.line_thickness);
//             } break;
//             case NK_COMMAND_TEXT: {
//                 const(nk_command_text)* t = cast(const(nk_command_text)*) cmd;
//                 nk_draw_list_add_text(&ctx.draw_list, t.font, nk_rect(t.x, t.y, t.w, t.h),
//                     t.string.ptr, t.length, t.height, t.foreground);
//             } break;
//             case NK_COMMAND_IMAGE: {
//                 const(nk_command_image)* i = cast(const(nk_command_image)*) cmd;
//                 nk_draw_list_add_image(&ctx.draw_list, cast(nk_image)i.img, nk_rect(i.x, i.y, i.w, i.h), i.col);
//             } break;
//             case NK_COMMAND_CUSTOM: {
//                 const(nk_command_custom)* c = cast(const(nk_command_custom)*) cmd;
//                 c.callback(&ctx.draw_list, c.x, c.y, c.w, c.h, cast(nk_handle)c.callback_data);
//             } break;
//             default: break;
//             }
//         }
//         res |= (cmds.needed > cmds.allocated + (cmds.memory.size - cmds.size)) ? NK_CONVERT_COMMAND_BUFFER_FULL: 0;
//         res |= (vertices.needed > vertices.allocated) ? NK_CONVERT_VERTEX_BUFFER_FULL: 0;
//         res |= (elements.needed > elements.allocated) ? NK_CONVERT_ELEMENT_BUFFER_FULL: 0;
//         return res;
//     }

//     const(nk_draw_command)* nk__draw_begin(const(nk_context)* ctx, const(nk_buffer)* buffer)
//     {
//         return nk__draw_list_begin(&ctx.draw_list, buffer);
//     }

//     const(nk_draw_command)* nk__draw_end(const(nk_context)* ctx, const(nk_buffer)* buffer)
//     {
//         return nk__draw_list_end(&ctx.draw_list, buffer);
//     }

//     const(nk_draw_command)* nk__draw_next(const(nk_draw_command)* cmd, const(nk_buffer)* buffer, const(nk_context)* ctx)
//     {
//         return nk__draw_list_next(cmd, buffer, &ctx.draw_list);
//     }
// }

// bool nk_begin(nk_context* ctx, const(char)* title, nk_rect bounds, nk_flags flags)
// {
//     return nk_begin_titled(ctx, title, title, bounds, flags);
// }

// void nk_start(nk_context *ctx, nk_window *win)
// {
//     assert(ctx);
//     assert(win);
//     nk_start_buffer(ctx, &win.buffer);
// }

// nk_window* nk_find_window(nk_context *ctx, nk_hash hash, const(char)* name)
// {
//     nk_window* iter;
//     iter = ctx.begin;
//     while (iter) {
//         assert(iter != iter.next);
//         if (iter.name == hash) {
//             int max_len = nk_strlen(iter.name_string.ptr);
//             if (!nk_stricmpn(iter.name_string.ptr, name, max_len))
//                 return iter;
//         }
//         iter = iter.next;
//     }
//     return null;
// }

// nk_page_element* nk_pool_alloc(nk_pool *pool)
// {
//     if (!pool.pages || pool.pages.size >= pool.capacity) {
//         /* allocate new page */
//         nk_page *page;
//         if (pool.type == NK_BUFFER_FIXED) {
//             assert(pool.pages);
//             if (!pool.pages) return null;
//             assert(pool.pages.size < pool.capacity);
//             return null;
//         } else {
//             nk_size size = nk_page.sizeof;
//             size += (pool.capacity - 1) * nk_page_element.sizeof;
//             page = cast(nk_page*)pool.alloc.alloc(pool.alloc.userdata, null, size);
//             page.next = pool.pages;
//             pool.pages = page;
//             page.size = 0;
//         }
//     } return &pool.pages.win[pool.pages.size++];
// }

// nk_page_element* nk_create_page_element(nk_context *ctx)
// {
//     nk_page_element *elem;
//     if (ctx.freelist) {
//         /* unlink page element from free list */
//         elem = ctx.freelist;
//         ctx.freelist = elem.next;
//     } else if (ctx.use_pool) {
//         /* allocate page element from memory pool */
//         elem = nk_pool_alloc(&ctx.pool);
//         assert(elem);
//         if (!elem) return null;
//     } else {
//         /* allocate new page element from back of fixed size memory buffer */
//         enum nk_size size = nk_page_element.sizeof;
//         enum nk_size align_ = nk_page_element.alignof;
//         elem = cast(nk_page_element*)nk_buffer_alloc(&ctx.memory, NK_BUFFER_BACK, size, align_);
//         assert(elem);
//         if (!elem) return null;
//     }
//     nk_zero_struct(*elem);
//     elem.next = null;
//     elem.prev = null;
//     return elem;
// }

// void* nk_create_window(nk_context *ctx)
// {
//     nk_page_element *elem;
//     elem = nk_create_page_element(ctx);
//     if (!elem) return null;
//     elem.data.win.seq = ctx.seq;
//     return &elem.data.win;
// }

// void nk_insert_window(nk_context *ctx, nk_window *win, nk_window_insert_location loc)
// {
//     const(nk_window)* iter;
//     assert(ctx);
//     assert(win);
//     if (!win || !ctx) return;

//     iter = ctx.begin;
//     while (iter) {
//         assert(iter != iter.next);
//         assert(iter != win);
//         if (iter == win) return;
//         iter = iter.next;
//     }

//     if (!ctx.begin) {
//         win.next = null;
//         win.prev = null;
//         ctx.begin = win;
//         ctx.end = win;
//         ctx.count = 1;
//         return;
//     }
//     if (loc == NK_INSERT_BACK) {
//         nk_window *end;
//         end = ctx.end;
//         end.flags |= NK_WINDOW_ROM;
//         end.next = win;
//         win.prev = ctx.end;
//         win.next = null;
//         ctx.end = win;
//         ctx.active = ctx.end;
//         ctx.end.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
//     } else {
//         /*ctx.end.flags |= NK_WINDOW_ROM;*/
//         ctx.begin.prev = win;
//         win.next = ctx.begin;
//         win.prev = null;
//         ctx.begin = win;
//         ctx.begin.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
//     }
//     ctx.count++;
// }

// void* nk_create_panel(nk_context* ctx)
// {
//     nk_page_element* elem;
//     elem = nk_create_page_element(ctx);
//     if (!elem) return null;
//     nk_zero_struct(*elem);
//     return &elem.data.pan;
// }

// nk_vec2 nk_panel_get_padding(const(nk_style)* style, nk_panel_type type)
// {
//     switch (type) {
//     default:
//     case NK_PANEL_WINDOW: return style.window.padding;
//     case NK_PANEL_GROUP: return style.window.group_padding;
//     case NK_PANEL_POPUP: return style.window.popup_padding;
//     case NK_PANEL_CONTEXTUAL: return style.window.contextual_padding;
//     case NK_PANEL_COMBO: return style.window.combo_padding;
//     case NK_PANEL_MENU: return style.window.menu_padding;
//     case NK_PANEL_TOOLTIP: return style.window.menu_padding;}
// }

// nk_bool nk_panel_has_header(nk_flags flags, const(char)* title)
// {
//     nk_bool active = 0;
//     active = cast(bool)(flags & (NK_WINDOW_CLOSABLE|NK_WINDOW_MINIMIZABLE));
//     active = active || (flags & NK_WINDOW_TITLE);
//     active = active && !(flags & NK_WINDOW_HIDDEN) && title;
//     return active;
// }

// float nk_panel_get_border(const(nk_style)* style, nk_flags flags, nk_panel_type type)
// {
//     if (flags & NK_WINDOW_BORDER) {
//         switch (type) {
//             default:
//             case NK_PANEL_WINDOW: return style.window.border;
//             case NK_PANEL_GROUP: return style.window.group_border;
//             case NK_PANEL_POPUP: return style.window.popup_border;
//             case NK_PANEL_CONTEXTUAL: return style.window.contextual_border;
//             case NK_PANEL_COMBO: return style.window.combo_border;
//             case NK_PANEL_MENU: return style.window.menu_border;
//             case NK_PANEL_TOOLTIP: return style.window.menu_border;
//         }
//     } else return 0;
// }

// nk_rect nk_shrink_rect(nk_rect r, float amount)
// {
//     nk_rect res = void;
//     r.w = nk_max(r.w, 2 * amount);
//     r.h = nk_max(r.h, 2 * amount);
//     res.x = r.x + amount;
//     res.y = r.y + amount;
//     res.w = r.w - 2 * amount;
//     res.h = r.h - 2 * amount;
//     return res;
// }

// nk_bool nk_panel_begin(nk_context* ctx, const(char)* title, nk_panel_type panel_type)
// {
//     nk_input* in_;
//     nk_window* win;
//     nk_panel* layout;
//     nk_command_buffer* out_;
//     const(nk_style)* style;
//     const(nk_user_font)* font;

//     nk_vec2 scrollbar_size;
//     nk_vec2 panel_padding;

//     assert(ctx);
//     assert(ctx.current);
//     assert(ctx.current.layout);
//     if (!ctx || !ctx.current || !ctx.current.layout) return 0;
//     nk_zero(ctx.current.layout, typeof(*ctx.current.layout).sizeof);
//     if ((ctx.current.flags & NK_WINDOW_HIDDEN) || (ctx.current.flags & NK_WINDOW_CLOSED)) {
//         nk_zero(ctx.current.layout, nk_panel.sizeof);
//         ctx.current.layout.type = panel_type;
//         return 0;
//     }
//     /* pull state into local stack */
//     style = &ctx.style;
//     font = style.font;
//     win = ctx.current;
//     layout = win.layout;
//     out_ = &win.buffer;
//     in_ = (win.flags & NK_WINDOW_NO_INPUT) ? null: &ctx.input;
//     version (NK_INCLUDE_COMMAND_USERDATA) {
//         win.buffer.userdata = ctx.userdata;
//     }
//     /* pull style configuration into local stack */
//     scrollbar_size = style.window.scrollbar_size;
//     panel_padding = nk_panel_get_padding(style, panel_type);

//     /* window movement */
//     if ((win.flags & NK_WINDOW_MOVABLE) && !(win.flags & NK_WINDOW_ROM)) {
//         nk_bool left_mouse_down;
//         uint left_mouse_clicked;
//         int left_mouse_click_in_cursor;

//         /* calculate draggable window space */
//         nk_rect header;
//         header.x = win.bounds.x;
//         header.y = win.bounds.y;
//         header.w = win.bounds.w;
//         if (nk_panel_has_header(win.flags, title)) {
//             header.h = font.height + 2.0f * style.window.header.padding.y;
//             header.h += 2.0f * style.window.header.label_padding.y;
//         } else header.h = panel_padding.y;

//         /* window movement by dragging */
//         left_mouse_down = in_.mouse.buttons[NK_BUTTON_LEFT].down;
//         left_mouse_clicked = in_.mouse.buttons[NK_BUTTON_LEFT].clicked;
//         left_mouse_click_in_cursor = nk_input_has_mouse_click_down_in_rect(in_,
//             NK_BUTTON_LEFT, header, nk_true);
//         if (left_mouse_down && left_mouse_click_in_cursor && !left_mouse_clicked) {
//             win.bounds.x = win.bounds.x + in_.mouse.delta.x;
//             win.bounds.y = win.bounds.y + in_.mouse.delta.y;
//             in_.mouse.buttons[NK_BUTTON_LEFT].clicked_pos.x += in_.mouse.delta.x;
//             in_.mouse.buttons[NK_BUTTON_LEFT].clicked_pos.y += in_.mouse.delta.y;
//             ctx.style.cursor_active = ctx.style.cursors[NK_CURSOR_MOVE];
//         }
//     }

//     /* setup panel */
//     layout.type = panel_type;
//     layout.flags = win.flags;
//     layout.bounds = win.bounds;
//     layout.bounds.x += panel_padding.x;
//     layout.bounds.w -= 2*panel_padding.x;
//     if (win.flags & NK_WINDOW_BORDER) {
//         layout.border = nk_panel_get_border(style, win.flags, panel_type);
//         layout.bounds = nk_shrink_rect(layout.bounds, layout.border);
//     } else layout.border = 0;
//     layout.at_y = layout.bounds.y;
//     layout.at_x = layout.bounds.x;
//     layout.max_x = 0;
//     layout.header_height = 0;
//     layout.footer_height = 0;
//     nk_layout_reset_min_row_height(ctx);
//     layout.row.index = 0;
//     layout.row.columns = 0;
//     layout.row.ratio = null;
//     layout.row.item_width = 0;
//     layout.row.tree_depth = 0;
//     layout.row.height = panel_padding.y;
//     layout.has_scrolling = nk_true;
//     if (!(win.flags & NK_WINDOW_NO_SCROLLBAR))
//         layout.bounds.w -= scrollbar_size.x;
//     if (!nk_panel_is_nonblock(panel_type)) {
//         layout.footer_height = 0;
//         if (!(win.flags & NK_WINDOW_NO_SCROLLBAR) || win.flags & NK_WINDOW_SCALABLE)
//             layout.footer_height = scrollbar_size.y;
//         layout.bounds.h -= layout.footer_height;
//     }

//     /* panel header */
//     if (nk_panel_has_header(win.flags, title))
//     {
//         nk_text text;
//         nk_rect header;
//         const(nk_style_item)* background = null;

//         /* calculate header bounds */
//         header.x = win.bounds.x;
//         header.y = win.bounds.y;
//         header.w = win.bounds.w;
//         header.h = font.height + 2.0f * style.window.header.padding.y;
//         header.h += (2.0f * style.window.header.label_padding.y);

//         /* shrink panel by header */
//         layout.header_height = header.h;
//         layout.bounds.y += header.h;
//         layout.bounds.h -= header.h;
//         layout.at_y += header.h;

//         /* select correct header background and text color */
//         if (ctx.active == win) {
//             background = &style.window.header.active;
//             text.text = style.window.header.label_active;
//         } else if (nk_input_is_mouse_hovering_rect(&ctx.input, header)) {
//             background = &style.window.header.hover;
//             text.text = style.window.header.label_hover;
//         } else {
//             background = &style.window.header.normal;
//             text.text = style.window.header.label_normal;
//         }

//         /* draw header background */
//         header.h += 1.0f;

//         switch(background.type) {
//             case NK_STYLE_ITEM_IMAGE:
//                 text.background = nk_rgba(0,0,0,0);
//                 nk_draw_image(&win.buffer, header, &background.data.image, nk_white);
//                 break;
//             case NK_STYLE_ITEM_NINE_SLICE:
//                 text.background = nk_rgba(0, 0, 0, 0);
//                 nk_draw_nine_slice(&win.buffer, header, &background.data.slice, nk_white);
//                 break;
//             case NK_STYLE_ITEM_COLOR:
//                 text.background = background.data.color;
//                 nk_fill_rect(out_, header, 0, background.data.color);
//                 break;
//         default: break;}

//         /* window close button */
//         {nk_rect button;
//         button.y = header.y + style.window.header.padding.y;
//         button.h = header.h - 2 * style.window.header.padding.y;
//         button.w = button.h;
//         if (win.flags & NK_WINDOW_CLOSABLE) {
//             nk_flags ws = 0;
//             if (style.window.header.align_ == NK_HEADER_RIGHT) {
//                 button.x = (header.w + header.x) - (button.w + style.window.header.padding.x);
//                 header.w -= button.w + style.window.header.spacing.x + style.window.header.padding.x;
//             } else {
//                 button.x = header.x + style.window.header.padding.x;
//                 header.x += button.w + style.window.header.spacing.x + style.window.header.padding.x;
//             }

//             if (nk_do_button_symbol(&ws, &win.buffer, button,
//                 style.window.header.close_symbol, NK_BUTTON_DEFAULT,
//                 &style.window.header.close_button, in_, style.font) && !(win.flags & NK_WINDOW_ROM))
//             {
//                 layout.flags |= NK_WINDOW_HIDDEN;
//                 layout.flags &= cast(nk_flags)~NK_WINDOW_MINIMIZED;
//             }
//         }

//         /* window minimize button */
//         if (win.flags & NK_WINDOW_MINIMIZABLE) {
//             nk_flags ws = 0;
//             if (style.window.header.align_ == NK_HEADER_RIGHT) {
//                 button.x = (header.w + header.x) - button.w;
//                 if (!(win.flags & NK_WINDOW_CLOSABLE)) {
//                     button.x -= style.window.header.padding.x;
//                     header.w -= style.window.header.padding.x;
//                 }
//                 header.w -= button.w + style.window.header.spacing.x;
//             } else {
//                 button.x = header.x;
//                 header.x += button.w + style.window.header.spacing.x + style.window.header.padding.x;
//             }
//             if (nk_do_button_symbol(&ws, &win.buffer, button, (layout.flags & NK_WINDOW_MINIMIZED)?
//                 style.window.header.maximize_symbol: style.window.header.minimize_symbol,
//                 NK_BUTTON_DEFAULT, &style.window.header.minimize_button, in_, style.font) && !(win.flags & NK_WINDOW_ROM))
//                 layout.flags = (layout.flags & NK_WINDOW_MINIMIZED) ?
//                     layout.flags & cast(nk_flags)~NK_WINDOW_MINIMIZED:
//                     layout.flags | NK_WINDOW_MINIMIZED;
//         }}

//         {/* window header title */
//         int text_len = nk_strlen(title);
//         nk_rect label = {0,0,0,0};
//         float t = font.width(font.userdata, font.height, title, text_len);
//         text.padding = nk_vec2(0,0);

//         label.x = header.x + style.window.header.padding.x;
//         label.x += style.window.header.label_padding.x;
//         label.y = header.y + style.window.header.label_padding.y;
//         label.h = font.height + 2 * style.window.header.label_padding.y;
//         label.w = t + 2 * style.window.header.spacing.x;
//         label.w = NK_CLAMP(0, label.w, header.x + header.w - label.x);
//         nk_widget_text(out_, label, cast(const(char)*)title, text_len, &text, NK_TEXT_LEFT, font);}
//     }

//     /* draw window background */
//     if (!(layout.flags & NK_WINDOW_MINIMIZED) && !(layout.flags & NK_WINDOW_DYNAMIC)) {
//         nk_rect body;
//         body.x = win.bounds.x;
//         body.w = win.bounds.w;
//         body.y = (win.bounds.y + layout.header_height);
//         body.h = (win.bounds.h - layout.header_height);

//         switch(style.window.fixed_background.type) {
//             case NK_STYLE_ITEM_IMAGE:
//                 nk_draw_image(out_, body, &style.window.fixed_background.data.image, nk_white);
//                 break;
//             case NK_STYLE_ITEM_NINE_SLICE:
//                 nk_draw_nine_slice(out_, body, &style.window.fixed_background.data.slice, nk_white);
//                 break;
//             case NK_STYLE_ITEM_COLOR:
//                 nk_fill_rect(out_, body, 0, style.window.fixed_background.data.color);
//                 break;
//         default: break;}
//     }

//     /* set clipping rectangle */
//     {nk_rect clip;
//     layout.clip = layout.bounds;
//     nk_unify(&clip, &win.buffer.clip, layout.clip.x, layout.clip.y,
//         layout.clip.x + layout.clip.w, layout.clip.y + layout.clip.h);
//     nk_push_scissor(out_, clip);
//     layout.clip = clip;}
//     return !(layout.flags & NK_WINDOW_HIDDEN) && !(layout.flags & NK_WINDOW_MINIMIZED);
// }

// bool nk_begin_titled(nk_context* ctx, const(char)* name, const(char)* title, nk_rect bounds, nk_flags flags)
// {
//     nk_window *win;
//     nk_style *style;
//     nk_hash name_hash;
//     int name_len;
//     int ret = 0;

//     assert(ctx);
//     assert(name);
//     assert(title);
//     assert(ctx.style.font && ctx.style.font.width && "if this triggers you forgot to add a font");
//     assert(!ctx.current && "if this triggers you missed a `nk_end` call");
//     if (!ctx || ctx.current || !title || !name)
//         return 0;

//     /* find or create window */
//     style = &ctx.style;
//     name_len = cast(int)nk_strlen(name);
//     name_hash = nk_murmur_hash(name, cast(int)name_len, NK_WINDOW_TITLE);
//     win = nk_find_window(ctx, name_hash, name);
//     if (!win) {
//         /* create new window */
//         nk_size name_length = cast(nk_size)name_len;
//         win = cast(nk_window*)nk_create_window(ctx);
//         assert(win);
//         if (!win) return 0;

//         if (flags & NK_WINDOW_BACKGROUND)
//             nk_insert_window(ctx, win, NK_INSERT_FRONT);
//         else nk_insert_window(ctx, win, NK_INSERT_BACK);
//         nk_command_buffer_init(&win.buffer, &ctx.memory, NK_CLIPPING_ON);

//         win.flags = flags;
//         win.bounds = bounds;
//         win.name = name_hash;
//         name_length = nk_min(name_length, NK_WINDOW_MAX_NAME-1);
//         nk_memcopy(win.name_string, name, name_length);
//         win.name_string[name_length] = 0;
//         win.popup.win = 0;
//         if (!ctx.active)
//             ctx.active = win;
//     } else {
//         /* update window */
//         win.flags &= ~(nk_flags)(NK_WINDOW_PRIVATE-1);
//         win.flags |= flags;
//         if (!(win.flags & (NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE)))
//             win.bounds = bounds;
//         /* If this assert triggers you either:
//          *
//          * I.) Have more than one window with the same name or
//          * II.) You forgot to actually draw the window.
//          *      More specific you did not call `nk_clear` (nk_clear will be
//          *      automatically called for you if you are using one of the
//          *      provided demo backends). */
//         assert(win.seq != ctx.seq);
//         win.seq = ctx.seq;
//         if (!ctx.active && !(win.flags & NK_WINDOW_HIDDEN)) {
//             ctx.active = win;
//             ctx.end = win;
//         }
//     }
//     if (win.flags & NK_WINDOW_HIDDEN) {
//         ctx.current = win;
//         win.layout = 0;
//         return 0;
//     } else nk_start(ctx, win);

//     /* window overlapping */
//     if (!(win.flags & NK_WINDOW_HIDDEN) && !(win.flags & NK_WINDOW_NO_INPUT))
//     {
//         int inpanel, ishovered;
//         nk_window *iter = win;
//         float h = ctx.style.font.height + 2.0f * style.window.header.padding.y +
//             (2.0f * style.window.header.label_padding.y);
//         nk_rect win_bounds = (!(win.flags & NK_WINDOW_MINIMIZED))?
//             win.bounds: nk_rect(win.bounds.x, win.bounds.y, win.bounds.w, h);

//         /* activate window if hovered and no other window is overlapping this window */
//         inpanel = nk_input_has_mouse_click_down_in_rect(&ctx.input, NK_BUTTON_LEFT, win_bounds, nk_true);
//         inpanel = inpanel && ctx.input.mouse.buttons[NK_BUTTON_LEFT].clicked;
//         ishovered = nk_input_is_mouse_hovering_rect(&ctx.input, win_bounds);
//         if ((win != ctx.active) && ishovered && !ctx.input.mouse.buttons[NK_BUTTON_LEFT].down) {
//             iter = win.next;
//             while (iter) {
//                 nk_rect iter_bounds = (!(iter.flags & NK_WINDOW_MINIMIZED))?
//                     iter.bounds: nk_rect(iter.bounds.x, iter.bounds.y, iter.bounds.w, h);
//                 if (nk_intersect(win_bounds.x, win_bounds.y, win_bounds.w, win_bounds.h,
//                     iter_bounds.x, iter_bounds.y, iter_bounds.w, iter_bounds.h) &&
//                     (!(iter.flags & NK_WINDOW_HIDDEN)))
//                     break;

//                 if (iter.popup.win && iter.popup.active && !(iter.flags & NK_WINDOW_HIDDEN) &&
//                     nk_intersect(win.bounds.x, win_bounds.y, win_bounds.w, win_bounds.h,
//                     iter.popup.win.bounds.x, iter.popup.win.bounds.y,
//                     iter.popup.win.bounds.w, iter.popup.win.bounds.h))
//                     break;
//                 iter = iter.next;
//             }
//         }

//         /* activate window if clicked */
//         if (iter && inpanel && (win != ctx.end)) {
//             iter = win.next;
//             while (iter) {
//                 /* try to find a panel with higher priority in the same position */
//                 nk_rect iter_bounds = (!(iter.flags & NK_WINDOW_MINIMIZED))?
//                 iter.bounds: nk_rect(iter.bounds.x, iter.bounds.y, iter.bounds.w, h);
//                 if (nk_inbox(ctx.input.mouse.pos.x, ctx.input.mouse.pos.y,
//                     iter_bounds.x, iter_bounds.y, iter_bounds.w, iter_bounds.h) &&
//                     !(iter.flags & NK_WINDOW_HIDDEN))
//                     break;
//                 if (iter.popup.win && iter.popup.active && !(iter.flags & NK_WINDOW_HIDDEN) &&
//                     nk_intersect(win_bounds.x, win_bounds.y, win_bounds.w, win_bounds.h,
//                     iter.popup.win.bounds.x, iter.popup.win.bounds.y,
//                     iter.popup.win.bounds.w, iter.popup.win.bounds.h))
//                     break;
//                 iter = iter.next;
//             }
//         }
//         if (iter && !(win.flags & NK_WINDOW_ROM) && (win.flags & NK_WINDOW_BACKGROUND)) {
//             win.flags |= cast(nk_flags)NK_WINDOW_ROM;
//             iter.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
//             ctx.active = iter;
//             if (!(iter.flags & NK_WINDOW_BACKGROUND)) {
//                 /* current window is active in that position so transfer to top
//                  * at the highest priority in stack */
//                 nk_remove_window(ctx, iter);
//                 nk_insert_window(ctx, iter, NK_INSERT_BACK);
//             }
//         } else {
//             if (!iter && ctx.end != win) {
//                 if (!(win.flags & NK_WINDOW_BACKGROUND)) {
//                     /* current window is active in that position so transfer to top
//                      * at the highest priority in stack */
//                     nk_remove_window(ctx, win);
//                     nk_insert_window(ctx, win, NK_INSERT_BACK);
//                 }
//                 win.flags &= ~cast(nk_flags)NK_WINDOW_ROM;
//                 ctx.active = win;
//             }
//             if (ctx.end != win && !(win.flags & NK_WINDOW_BACKGROUND))
//                 win.flags |= NK_WINDOW_ROM;
//         }
//     }
//     win.layout = cast(nk_panel*)nk_create_panel(ctx);
//     ctx.current = win;
//     ret = nk_panel_begin(ctx, title, NK_PANEL_WINDOW);
//     win.layout.offset_x = &win.scrollbar.x;
//     win.layout.offset_y = &win.scrollbar.y;
//     return ret;
// }

// void nk_end(nk_context* ctx);
// nk_window* nk_window_find(nk_context* ctx, const(char)* name);
// nk_rect nk_window_get_bounds(const(nk_context)* ctx);
// nk_vec2 nk_window_get_position(const(nk_context)* ctx);
// nk_vec2 nk_window_get_size(const(nk_context)*);
// float nk_window_get_width(const(nk_context)*);
// float nk_window_get_height(const(nk_context)*);
// nk_panel* nk_window_get_panel(nk_context*);
// nk_rect nk_window_get_content_region(nk_context*);
// nk_vec2 nk_window_get_content_region_min(nk_context*);
// nk_vec2 nk_window_get_content_region_max(nk_context*);
// nk_vec2 nk_window_get_content_region_size(nk_context*);
// nk_command_buffer* nk_window_get_canvas(nk_context*);
// void nk_window_get_scroll(nk_context*, nk_uint* offset_x, nk_uint* offset_y); // 4.01.0
// bool nk_window_has_focus(const(nk_context)*);
// bool nk_window_is_hovered(nk_context*);
// bool nk_window_is_collapsed(nk_context* ctx, const(char)* name);
// bool nk_window_is_closed(nk_context*, const(char)*);
// bool nk_window_is_hidden(nk_context*, const(char)*);
// bool nk_window_is_active(nk_context*, const(char)*);
// bool nk_window_is_any_hovered(nk_context*);
// bool nk_item_is_any_active(nk_context*);
// void nk_window_set_bounds(nk_context*, const(char)* name, nk_rect bounds);
// void nk_window_set_position(nk_context*, const(char)* name, nk_vec2 pos);
// void nk_window_set_size(nk_context*, const(char)* name, nk_vec2);
// void nk_window_set_focus(nk_context*, const(char)* name);
// void nk_window_set_scroll(nk_context*, nk_uint offset_x, nk_uint offset_y); // 4.01.0
// void nk_window_close(nk_context* ctx, const(char)* name);
// void nk_window_collapse(nk_context*, const(char)* name, nk_collapse_states state);
// void nk_window_collapse_if(nk_context*, const(char)* name, nk_collapse_states, int cond);
// void nk_window_show(nk_context*, const(char)* name, nk_show_states);
// void nk_window_show_if(nk_context*, const(char)* name, nk_show_states, int cond);
// void nk_layout_set_min_row_height(nk_context*, float height);
// void nk_layout_reset_min_row_height(nk_context*);
// nk_rect nk_layout_widget_bounds(nk_context*);
// float nk_layout_ratio_from_pixel(nk_context*, float pixel_width);
// void nk_layout_row_dynamic(nk_context* ctx, float height, int cols);
// void nk_layout_row_static(nk_context* ctx, float height, int item_width, int cols);
// void nk_layout_row_begin(nk_context* ctx, nk_layout_format fmt, float row_height, int cols);
// void nk_layout_row_push(nk_context*, float value);
// void nk_layout_row_end(nk_context*);
// void nk_layout_row(nk_context*, nk_layout_format, float height, int cols, const(float)* ratio);
// void nk_layout_row_template_begin(nk_context*, float row_height);
// void nk_layout_row_template_push_dynamic(nk_context*);
// void nk_layout_row_template_push_variable(nk_context*, float min_width);
// void nk_layout_row_template_push_static(nk_context*, float width);
// void nk_layout_row_template_end(nk_context*);
// void nk_layout_space_begin(nk_context*, nk_layout_format, float height, int widget_count);
// void nk_layout_space_push(nk_context*, nk_rect bounds);
// void nk_layout_space_end(nk_context*);
// nk_rect nk_layout_space_bounds(nk_context*);
// nk_vec2 nk_layout_space_to_screen(nk_context*, nk_vec2);
// nk_vec2 nk_layout_space_to_local(nk_context*, nk_vec2);
// nk_rect nk_layout_space_rect_to_screen(nk_context*, nk_rect);
// nk_rect nk_layout_space_rect_to_local(nk_context*, nk_rect);
// void nk_spacer(nk_context*);
// bool nk_group_begin(nk_context*, const(char)* title, nk_flags);
// bool nk_group_begin_titled(nk_context*, const(char)* name, const(char)* title, nk_flags);
// void nk_group_end(nk_context*);
// bool nk_group_scrolled_offset_begin(nk_context*, nk_uint* x_offset, nk_uint* y_offset, const(char)* title, nk_flags flags);
// bool nk_group_scrolled_begin(nk_context*, nk_scroll* off, const(char)* title, nk_flags);
// void nk_group_scrolled_end(nk_context*);
// void nk_group_get_scroll(nk_context*, const(char)* id, nk_uint *x_offset, nk_uint *y_offset); // 4.01.0
// void nk_group_set_scroll(nk_context*, const(char)* id, nk_uint x_offset, nk_uint y_offset); // 4.01.0
// bool nk_tree_push_hashed(nk_context*, nk_tree_type, const(char)* title, nk_collapse_states initial_state, const(char)* hash, int len, int seed);
// bool nk_tree_image_push_hashed(nk_context*, nk_tree_type, nk_image, const(char)* title, nk_collapse_states initial_state, const(char)* hash, int len, int seed);
// void nk_tree_pop(nk_context*);
// bool nk_tree_state_push(nk_context*, nk_tree_type, const(char)* title, nk_collapse_states* state);
// bool nk_tree_state_image_push(nk_context*, nk_tree_type, nk_image, const(char)* title, nk_collapse_states* state);
// void nk_tree_state_pop(nk_context*);
// bool nk_tree_element_push_hashed(nk_context*, nk_tree_type, const(char)* title, nk_collapse_states initial_state, int* selected, const(char)* hash, int len, int seed);
// bool nk_tree_element_image_push_hashed(nk_context*, nk_tree_type, nk_image, const(char)* title, nk_collapse_states initial_state, int* selected, const(char)* hash, int len, int seed);
// void nk_tree_element_pop(nk_context*);
// bool nk_list_view_begin(nk_context*, nk_list_view* out_, const(char)* id, nk_flags, int row_height, int row_count);
// void nk_list_view_end(nk_list_view*);
// nk_widget_layout_states nk_widget(nk_rect*, const(nk_context)*);
// nk_widget_layout_states nk_widget_fitting(nk_rect*, nk_context*, nk_vec2);
// nk_rect nk_widget_bounds(nk_context*);
// nk_vec2 nk_widget_position(nk_context*);
// nk_vec2 nk_widget_size(nk_context*);
// float nk_widget_width(nk_context*);
// float nk_widget_height(nk_context*);
// bool nk_widget_is_hovered(nk_context*);
// bool nk_widget_is_mouse_clicked(nk_context*, nk_buttons);
// bool nk_widget_has_mouse_click_down(nk_context*, nk_buttons, bool down);
// void nk_spacing(nk_context*, int cols);
// void nk_text(nk_context*, const(char)*, int, nk_flags);
// void nk_text_colored(nk_context*, const(char)*, int, nk_flags, nk_color);
// void nk_text_wrap(nk_context*, const(char)*, int);
// void nk_text_wrap_colored(nk_context*, const(char)*, int, nk_color);
// void nk_label(nk_context*, const(char)*, nk_flags align__);
// void nk_label_colored(nk_context*, const(char)*, nk_flags align__, nk_color);
// void nk_label_wrap(nk_context*, const(char)*);
// void nk_label_colored_wrap(nk_context*, const(char)*, nk_color);
// pragma(mangle, "nk_image")
//     void nk_image_(nk_context*, nk_image);
// void nk_image_color(nk_context*, nk_image, nk_color);
// version(NK_INCLUDE_STANDARD_VARARGS) {
//     void nk_labelf(nk_context*, nk_flags, const(char)*, ...);
//     void nk_labelf_colored(nk_context*, nk_flags, nk_color, const(char)*, ...);
//     void nk_labelf_wrap(nk_context*, const(char)*, ...);
//     void nk_labelf_colored_wrap(nk_context*, nk_color, const(char)*, ...);
//     void nk_labelfv(nk_context*, nk_flags, const(char)*, va_list);
//     void nk_labelfv_colored(nk_context*, nk_flags, nk_color, const(char)*, va_list);
//     void nk_labelfv_wrap(nk_context*, const(char)*, va_list);
//     void nk_labelfv_colored_wrap(nk_context*, nk_color, const(char)*, va_list);
//     void nk_value_bool(nk_context*, const(char)* prefix, int);
//     void nk_value_int(nk_context*, const(char)* prefix, int);
//     void nk_value_uint(nk_context*, const(char)* prefix, uint);
//     void nk_value_float(nk_context*, const(char)* prefix, float);
//     void nk_value_color_byte(nk_context*, const(char)* prefix, nk_color);
//     void nk_value_color_float(nk_context*, const(char)* prefix, nk_color);
//     void nk_value_color_hex(nk_context*, const(char)* prefix, nk_color);
// }
// bool nk_button_text(nk_context*, const(char)* title, int len);
// bool nk_button_label(nk_context*, const(char)* title);
// bool nk_button_color(nk_context*, nk_color);
// bool nk_button_symbol(nk_context*, nk_symbol_type);
// bool nk_button_image(nk_context*, nk_image img);
// bool nk_button_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags text_alignment);
// bool nk_button_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_ment);
// bool nk_button_image_label(nk_context*, nk_image img, const(char)*, nk_flags text_alignment);
// bool nk_button_image_text(nk_context*, nk_image img, const(char)*, int, nk_flags align_ment);
// bool nk_button_text_styled(nk_context*, const(nk_style_button)*, const(char)* title, int len);
// bool nk_button_label_styled(nk_context*, const(nk_style_button)*, const(char)* title);
// bool nk_button_symbol_styled(nk_context*, const(nk_style_button)*, nk_symbol_type);
// bool nk_button_image_styled(nk_context*, const(nk_style_button)*, nk_image img);
// bool nk_button_symbol_text_styled(nk_context*, const(nk_style_button)*, nk_symbol_type, const(char)*, int, nk_flags align_ment);
// bool nk_button_symbol_label_styled(nk_context* ctx, const(nk_style_button)* style, nk_symbol_type symbol, const(char)* title, nk_flags align_);
// bool nk_button_image_label_styled(nk_context*, const(nk_style_button)*, nk_image img, const(char)*, nk_flags text_alignment);
// bool nk_button_image_text_styled(nk_context*, const(nk_style_button)*, nk_image img, const(char)*, int, nk_flags align_ment);
// void nk_button_set_behavior(nk_context*, nk_button_behavior);
// bool nk_button_push_behavior(nk_context*, nk_button_behavior);
// bool nk_button_pop_behavior(nk_context*);
// bool nk_check_label(nk_context*, const(char)*, bool active);
// bool nk_check_text(nk_context*, const(char)*, int, bool active);
// uint nk_check_flags_label(nk_context*, const(char)*, uint flags, uint value);
// uint nk_check_flags_text(nk_context*, const(char)*, int, uint flags, uint value);
// bool nk_checkbox_label(nk_context*, const(char)*, bool* active);
// bool nk_checkbox_text(nk_context*, const(char)*, int, bool* active);
// bool nk_checkbox_flags_label(nk_context*, const(char)*, uint* flags, uint value);
// bool nk_checkbox_flags_text(nk_context*, const(char)*, int, uint* flags, uint value);
// bool nk_radio_label(nk_context*, const(char)*, bool* active);
// bool nk_radio_text(nk_context*, const(char)*, int, bool* active);
// bool nk_option_label(nk_context*, const(char)*, bool active);
// bool nk_option_text(nk_context*, const(char)*, int, bool active);
// bool nk_selectable_label(nk_context*, const(char)*, nk_flags align_, bool* value);
// bool nk_selectable_text(nk_context*, const(char)*, int, nk_flags align_, bool* value);
// bool nk_selectable_image_label(nk_context*, nk_image, const(char)*, nk_flags align_, bool* value);
// bool nk_selectable_image_text(nk_context*, nk_image, const(char)*, int, nk_flags align_, bool* value);
// bool nk_selectable_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags align_, bool* value);
// bool nk_selectable_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_, bool* value);
// bool nk_select_label(nk_context*, const(char)*, nk_flags align_, bool value);
// bool nk_select_text(nk_context*, const(char)*, int, nk_flags align_, bool value);
// bool nk_select_image_label(nk_context*, nk_image, const(char)*, nk_flags align_, bool value);
// bool nk_select_image_text(nk_context*, nk_image, const(char)*, int, nk_flags align_, bool value);
// bool nk_select_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags align_, bool value);
// bool nk_select_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_, bool value);
// float nk_slide_float(nk_context*, float min, float val, float max, float step);
// int nk_slide_int(nk_context*, int min, int val, int max, int step);
// bool nk_slider_float(nk_context*, float min, float* val, float max, float step);
// bool nk_slider_int(nk_context*, int min, int* val, int max, int step);
// bool nk_progress(nk_context*, nk_size* cur, nk_size max, bool modifyable);
// nk_size nk_prog(nk_context*, nk_size cur, nk_size max, bool modifyable);
// nk_colorf nk_color_picker(nk_context*, nk_colorf, nk_color_format);
// int nk_color_pick(nk_context*, nk_colorf*, nk_color_format);
// void nk_property_int(nk_context*, const(char)* name, int min, int* val, int max, int step, float inc_per_pixel);
// void nk_property_float(nk_context*, const(char)* name, float min, float* val, float max, float step, float inc_per_pixel);
// void nk_property_double(nk_context*, const(char)* name, double min, double* val, double max, double step, float inc_per_pixel);
// int nk_propertyi(nk_context*, const(char)* name, int min, int val, int max, int step, float inc_per_pixel);
// float nk_propertyf(nk_context*, const(char)* name, float min, float val, float max, float step, float inc_per_pixel);
// double nk_propertyd(nk_context*, const(char)* name, double min, double val, double max, double step, float inc_per_pixel);
// nk_flags nk_edit_string(nk_context*, nk_flags, char* buffer, int* len, int max, nk_plugin_filter);
// nk_flags nk_edit_string_zero_terminated(nk_context*, nk_flags, char* buffer, int max, nk_plugin_filter);
// nk_flags nk_edit_buffer(nk_context*, nk_flags, nk_text_edit*, nk_plugin_filter);
// void nk_edit_focus(nk_context*, nk_flags flags);
// void nk_edit_unfocus(nk_context*);
// bool nk_chart_begin(nk_context*, nk_chart_type, int num, float min, float max);
// bool nk_chart_begin_colored(nk_context*, nk_chart_type, nk_color, nk_color active, int num, float min, float max);
// void nk_chart_add_slot(nk_context* ctx, const(nk_chart_type), int count, float min_value, float max_value);
// void nk_chart_add_slot_colored(nk_context* ctx, const(nk_chart_type), nk_color, nk_color active, int count, float min_value, float max_value);
// nk_flags nk_chart_push(nk_context*, float);
// nk_flags nk_chart_push_slot(nk_context*, float, int);
// void nk_chart_end(nk_context*);
// void nk_plot(nk_context*, nk_chart_type, const(float)* values, int count, int offset);
// void nk_plot_function(nk_context*, nk_chart_type, void *userdata, float function(void* user, int index), int count, int offset);
// bool nk_popup_begin(nk_context*, nk_popup_type, const(char)*, nk_flags, nk_rect bounds);
// void nk_popup_close(nk_context*);
// void nk_popup_end(nk_context*);
// void nk_popup_get_scroll(nk_context*, nk_uint *offset_x, nk_uint *offset_y); // 4.01.0
// void nk_popup_set_scroll(nk_context*, nk_uint offset_x, nk_uint offset_y); // 4.01.0
// int nk_combo(nk_context*, const(char)** items, int count, int selected, int item_height, nk_vec2 size);
// void nk_combo_separator(nk_context*, const(char)* items_separated_by_separator, int separator, int selected, int count, int item_height, nk_vec2 size);
// void nk_combo_string(nk_context*, const(char)* items_separated_by_zeros, int selected, int count, int item_height, nk_vec2 size);
// void nk_combo_callback(nk_context*, void function(void*, int, const(char) **), void *userdata, int selected, int count, int item_height, nk_vec2 size);
// void nk_combobox(nk_context*, const(char)** items, int count, int* selected, int item_height, nk_vec2 size);
// void nk_combobox_string(nk_context*, const(char)* items_separated_by_zeros, int* selected, int count, int item_height, nk_vec2 size);
// void nk_combobox_separator(nk_context*, const(char)* items_separated_by_separator, int separator, int* selected, int count, int item_height, nk_vec2 size);
// void nk_combobox_callback(nk_context*, void function(void*, int, const(char) **), void*, int *selected, int count, int item_height, nk_vec2 size);
// bool nk_combo_begin_text(nk_context*, const(char)* selected, int, nk_vec2 size);
// bool nk_combo_begin_label(nk_context*, const(char)* selected, nk_vec2 size);
// bool nk_combo_begin_color(nk_context*, nk_color color, nk_vec2 size);
// bool nk_combo_begin_symbol(nk_context*, nk_symbol_type, nk_vec2 size);
// bool nk_combo_begin_symbol_label(nk_context*, const(char)* selected, nk_symbol_type, nk_vec2 size);
// bool nk_combo_begin_symbol_text(nk_context*, const(char)* selected, int, nk_symbol_type, nk_vec2 size);
// bool nk_combo_begin_image(nk_context*, nk_image img, nk_vec2 size);
// bool nk_combo_begin_image_label(nk_context*, const(char)* selected, nk_image, nk_vec2 size);
// bool nk_combo_begin_image_text(nk_context*, const(char)* selected, int, nk_image, nk_vec2 size);
// bool nk_combo_item_label(nk_context*, const(char)*, nk_flags align_ment);
// bool nk_combo_item_text(nk_context*, const(char)*, int, nk_flags align_ment);
// bool nk_combo_item_image_label(nk_context*, nk_image, const(char)*, nk_flags align_ment);
// bool nk_combo_item_image_text(nk_context*, nk_image, const(char)*, int, nk_flags align_ment);
// bool nk_combo_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags align_ment);
// bool nk_combo_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_ment);
// void nk_combo_close(nk_context*);
// void nk_combo_end(nk_context*);
// bool nk_contextual_begin(nk_context*, nk_flags, nk_vec2, nk_rect trigger_bounds);
// bool nk_contextual_item_text(nk_context*, const(char)*, int, nk_flags align_);
// bool nk_contextual_item_label(nk_context*, const(char)*, nk_flags align_);
// bool nk_contextual_item_image_label(nk_context*, nk_image, const(char)*, nk_flags align_ment);
// bool nk_contextual_item_image_text(nk_context*, nk_image, const(char)*, int len, nk_flags align_ment);
// bool nk_contextual_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags align_ment);
// bool nk_contextual_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_ment);
// void nk_contextual_close(nk_context*);
// void nk_contextual_end(nk_context*);
// void nk_tooltip(nk_context*, const(char)*);
// version(NK_INCLUDE_STANDARD_VARARGS) {
//     void nk_tooltipf(nk_context*, const(char)*, ...);
//     void nk_tooltipfv(nk_context*, const(char)*, va_list);
// }
// bool nk_tooltip_begin(nk_context*, float width);
// void nk_tooltip_end(nk_context*);
// void nk_menubar_begin(nk_context*);
// void nk_menubar_end(nk_context*);
// bool nk_menu_begin_text(nk_context*, const(char)* title, int title_len, nk_flags align_, nk_vec2 size);
// bool nk_menu_begin_label(nk_context*, const(char)*, nk_flags align_, nk_vec2 size);
// bool nk_menu_begin_image(nk_context*, const(char)*, nk_image, nk_vec2 size);
// bool nk_menu_begin_image_text(nk_context*, const(char)*, int, nk_flags align_, nk_image, nk_vec2 size);
// bool nk_menu_begin_image_label(nk_context*, const(char)*, nk_flags align_, nk_image, nk_vec2 size);
// bool nk_menu_begin_symbol(nk_context*, const(char)*, nk_symbol_type, nk_vec2 size);
// bool nk_menu_begin_symbol_text(nk_context*, const(char)*, int, nk_flags align_, nk_symbol_type, nk_vec2 size);
// bool nk_menu_begin_symbol_label(nk_context*, const(char)*, nk_flags align_, nk_symbol_type, nk_vec2 size);
// bool nk_menu_item_text(nk_context*, const(char)*, int, nk_flags align_);
// bool nk_menu_item_label(nk_context*, const(char)*, nk_flags align_ment);
// bool nk_menu_item_image_label(nk_context*, nk_image, const(char)*, nk_flags align_ment);
// bool nk_menu_item_image_text(nk_context*, nk_image, const(char)*, int len, nk_flags align_ment);
// bool nk_menu_item_symbol_text(nk_context*, nk_symbol_type, const(char)*, int, nk_flags align_ment);
// bool nk_menu_item_symbol_label(nk_context*, nk_symbol_type, const(char)*, nk_flags align_ment);
// void nk_menu_close(nk_context*);
// void nk_menu_end(nk_context*);

// void nk_style_default(nk_context* ctx)
// {
//     nk_style_from_table(ctx, null);
// }

// void nk_style_from_table(nk_context* ctx, const(nk_color)* table)
// {

//     nk_style *style;
//     nk_style_text *text;
//     nk_style_button *button;
//     nk_style_toggle *toggle;
//     nk_style_selectable *select;
//     nk_style_slider *slider;
//     nk_style_progress *prog;
//     nk_style_scrollbar *scroll;
//     nk_style_edit *edit;
//     nk_style_property *property;
//     nk_style_combo *combo;
//     nk_style_chart *chart;
//     nk_style_tab *tab;
//     nk_style_window *win;

//     assert(ctx);
//     if (!ctx) return;
//     style = &ctx.style;
//     table = (!table) ? nk_default_color_style.ptr : table;

//     /* default text */
//     text = &style.text;
//     text.color = table[NK_COLOR_TEXT];
//     text.padding = nk_vec2(0,0);

//     /* default button */
//     button = &style.button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_BUTTON]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_BUTTON_HOVER]);
//     button.active          = nk_style_item_color(table[NK_COLOR_BUTTON_ACTIVE]);
//     button.border_color    = table[NK_COLOR_BORDER];
//     button.text_background = table[NK_COLOR_BUTTON];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(2.0f,2.0f);
//     button.image_padding   = nk_vec2(0.0f,0.0f);
//     button.touch_padding   = nk_vec2(0.0f, 0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 1.0f;
//     button.rounding        = 4.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;

//     /* contextual button */
//     button = &style.contextual_button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_BUTTON_HOVER]);
//     button.active          = nk_style_item_color(table[NK_COLOR_BUTTON_ACTIVE]);
//     button.border_color    = table[NK_COLOR_WINDOW];
//     button.text_background = table[NK_COLOR_WINDOW];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(2.0f,2.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;

//     /* menu button */
//     button = &style.menu_button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     button.active          = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     button.border_color    = table[NK_COLOR_WINDOW];
//     button.text_background = table[NK_COLOR_WINDOW];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(2.0f,2.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 1.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;

//     /* checkbox toggle */
//     toggle = &style.checkbox;
//     nk_zero_struct(*toggle);
//     toggle.normal          = nk_style_item_color(table[NK_COLOR_TOGGLE]);
//     toggle.hover           = nk_style_item_color(table[NK_COLOR_TOGGLE_HOVER]);
//     toggle.active          = nk_style_item_color(table[NK_COLOR_TOGGLE_HOVER]);
//     toggle.cursor_normal   = nk_style_item_color(table[NK_COLOR_TOGGLE_CURSOR]);
//     toggle.cursor_hover    = nk_style_item_color(table[NK_COLOR_TOGGLE_CURSOR]);
//     toggle.userdata        = nk_handle_ptr(null);
//     toggle.text_background = table[NK_COLOR_WINDOW];
//     toggle.text_normal     = table[NK_COLOR_TEXT];
//     toggle.text_hover      = table[NK_COLOR_TEXT];
//     toggle.text_active     = table[NK_COLOR_TEXT];
//     toggle.padding         = nk_vec2(2.0f, 2.0f);
//     toggle.touch_padding   = nk_vec2(0,0);
//     toggle.border_color    = nk_rgba(0,0,0,0);
//     toggle.border          = 0.0f;
//     toggle.spacing         = 4;

//     /* option toggle */
//     toggle = &style.option;
//     nk_zero_struct(*toggle);
//     toggle.normal          = nk_style_item_color(table[NK_COLOR_TOGGLE]);
//     toggle.hover           = nk_style_item_color(table[NK_COLOR_TOGGLE_HOVER]);
//     toggle.active          = nk_style_item_color(table[NK_COLOR_TOGGLE_HOVER]);
//     toggle.cursor_normal   = nk_style_item_color(table[NK_COLOR_TOGGLE_CURSOR]);
//     toggle.cursor_hover    = nk_style_item_color(table[NK_COLOR_TOGGLE_CURSOR]);
//     toggle.userdata        = nk_handle_ptr(null);
//     toggle.text_background = table[NK_COLOR_WINDOW];
//     toggle.text_normal     = table[NK_COLOR_TEXT];
//     toggle.text_hover      = table[NK_COLOR_TEXT];
//     toggle.text_active     = table[NK_COLOR_TEXT];
//     toggle.padding         = nk_vec2(3.0f, 3.0f);
//     toggle.touch_padding   = nk_vec2(0,0);
//     toggle.border_color    = nk_rgba(0,0,0,0);
//     toggle.border          = 0.0f;
//     toggle.spacing         = 4;

//     /* selectable */
//     select = &style.selectable;
//     nk_zero_struct(*select);
//     select.normal          = nk_style_item_color(table[NK_COLOR_SELECT]);
//     select.hover           = nk_style_item_color(table[NK_COLOR_SELECT]);
//     select.pressed         = nk_style_item_color(table[NK_COLOR_SELECT]);
//     select.normal_active   = nk_style_item_color(table[NK_COLOR_SELECT_ACTIVE]);
//     select.hover_active    = nk_style_item_color(table[NK_COLOR_SELECT_ACTIVE]);
//     select.pressed_active  = nk_style_item_color(table[NK_COLOR_SELECT_ACTIVE]);
//     select.text_normal     = table[NK_COLOR_TEXT];
//     select.text_hover      = table[NK_COLOR_TEXT];
//     select.text_pressed    = table[NK_COLOR_TEXT];
//     select.text_normal_active  = table[NK_COLOR_TEXT];
//     select.text_hover_active   = table[NK_COLOR_TEXT];
//     select.text_pressed_active = table[NK_COLOR_TEXT];
//     select.padding         = nk_vec2(2.0f,2.0f);
//     select.image_padding   = nk_vec2(2.0f,2.0f);
//     select.touch_padding   = nk_vec2(0,0);
//     select.userdata        = nk_handle_ptr(null);
//     select.rounding        = 0.0f;
//     select.draw_begin      = null;
//     select.draw_end        = null;

//     /* slider */
//     slider = &style.slider;
//     nk_zero_struct(*slider);
//     slider.normal          = nk_style_item_hide();
//     slider.hover           = nk_style_item_hide();
//     slider.active          = nk_style_item_hide();
//     slider.bar_normal      = table[NK_COLOR_SLIDER];
//     slider.bar_hover       = table[NK_COLOR_SLIDER];
//     slider.bar_active      = table[NK_COLOR_SLIDER];
//     slider.bar_filled      = table[NK_COLOR_SLIDER_CURSOR];
//     slider.cursor_normal   = nk_style_item_color(table[NK_COLOR_SLIDER_CURSOR]);
//     slider.cursor_hover    = nk_style_item_color(table[NK_COLOR_SLIDER_CURSOR_HOVER]);
//     slider.cursor_active   = nk_style_item_color(table[NK_COLOR_SLIDER_CURSOR_ACTIVE]);
//     slider.inc_symbol      = NK_SYMBOL_TRIANGLE_RIGHT;
//     slider.dec_symbol      = NK_SYMBOL_TRIANGLE_LEFT;
//     slider.cursor_size     = nk_vec2(16,16);
//     slider.padding         = nk_vec2(2,2);
//     slider.spacing         = nk_vec2(2,2);
//     slider.userdata        = nk_handle_ptr(null);
//     slider.show_buttons    = nk_false;
//     slider.bar_height      = 8;
//     slider.rounding        = 0;
//     slider.draw_begin      = null;
//     slider.draw_end        = null;

//     /* slider buttons */
//     button = &style.slider.inc_button;
//     button.normal          = nk_style_item_color(nk_rgb(40,40,40));
//     button.hover           = nk_style_item_color(nk_rgb(42,42,42));
//     button.active          = nk_style_item_color(nk_rgb(44,44,44));
//     button.border_color    = nk_rgb(65,65,65);
//     button.text_background = nk_rgb(40,40,40);
//     button.text_normal     = nk_rgb(175,175,175);
//     button.text_hover      = nk_rgb(175,175,175);
//     button.text_active     = nk_rgb(175,175,175);
//     button.padding         = nk_vec2(8.0f,8.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 1.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;
//     style.slider.dec_button = style.slider.inc_button;

//     /* progressbar */
//     prog = &style.progress;
//     nk_zero_struct(*prog);
//     prog.normal            = nk_style_item_color(table[NK_COLOR_SLIDER]);
//     prog.hover             = nk_style_item_color(table[NK_COLOR_SLIDER]);
//     prog.active            = nk_style_item_color(table[NK_COLOR_SLIDER]);
//     prog.cursor_normal     = nk_style_item_color(table[NK_COLOR_SLIDER_CURSOR]);
//     prog.cursor_hover      = nk_style_item_color(table[NK_COLOR_SLIDER_CURSOR_HOVER]);
//     prog.cursor_active     = nk_style_item_color(table[NK_COLOR_SLIDER_CURSOR_ACTIVE]);
//     prog.border_color      = nk_rgba(0,0,0,0);
//     prog.cursor_border_color = nk_rgba(0,0,0,0);
//     prog.userdata          = nk_handle_ptr(null);
//     prog.padding           = nk_vec2(4,4);
//     prog.rounding          = 0;
//     prog.border            = 0;
//     prog.cursor_rounding   = 0;
//     prog.cursor_border     = 0;
//     prog.draw_begin        = null;
//     prog.draw_end          = null;

//     /* scrollbars */
//     scroll = &style.scrollh;
//     nk_zero_struct(*scroll);
//     scroll.normal          = nk_style_item_color(table[NK_COLOR_SCROLLBAR]);
//     scroll.hover           = nk_style_item_color(table[NK_COLOR_SCROLLBAR]);
//     scroll.active          = nk_style_item_color(table[NK_COLOR_SCROLLBAR]);
//     scroll.cursor_normal   = nk_style_item_color(table[NK_COLOR_SCROLLBAR_CURSOR]);
//     scroll.cursor_hover    = nk_style_item_color(table[NK_COLOR_SCROLLBAR_CURSOR_HOVER]);
//     scroll.cursor_active   = nk_style_item_color(table[NK_COLOR_SCROLLBAR_CURSOR_ACTIVE]);
//     scroll.dec_symbol      = NK_SYMBOL_CIRCLE_SOLID;
//     scroll.inc_symbol      = NK_SYMBOL_CIRCLE_SOLID;
//     scroll.userdata        = nk_handle_ptr(null);
//     scroll.border_color    = table[NK_COLOR_SCROLLBAR];
//     scroll.cursor_border_color = table[NK_COLOR_SCROLLBAR];
//     scroll.padding         = nk_vec2(0,0);
//     scroll.show_buttons    = nk_false;
//     scroll.border          = 0;
//     scroll.rounding        = 0;
//     scroll.border_cursor   = 0;
//     scroll.rounding_cursor = 0;
//     scroll.draw_begin      = null;
//     scroll.draw_end        = null;
//     style.scrollv = style.scrollh;

//     /* scrollbars buttons */
//     button = &style.scrollh.inc_button;
//     button.normal          = nk_style_item_color(nk_rgb(40,40,40));
//     button.hover           = nk_style_item_color(nk_rgb(42,42,42));
//     button.active          = nk_style_item_color(nk_rgb(44,44,44));
//     button.border_color    = nk_rgb(65,65,65);
//     button.text_background = nk_rgb(40,40,40);
//     button.text_normal     = nk_rgb(175,175,175);
//     button.text_hover      = nk_rgb(175,175,175);
//     button.text_active     = nk_rgb(175,175,175);
//     button.padding         = nk_vec2(4.0f,4.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 1.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;
//     style.scrollh.dec_button = style.scrollh.inc_button;
//     style.scrollv.inc_button = style.scrollh.inc_button;
//     style.scrollv.dec_button = style.scrollh.inc_button;

//     /* edit */
//     edit = &style.edit;
//     nk_zero_struct(*edit);
//     edit.normal            = nk_style_item_color(table[NK_COLOR_EDIT]);
//     edit.hover             = nk_style_item_color(table[NK_COLOR_EDIT]);
//     edit.active            = nk_style_item_color(table[NK_COLOR_EDIT]);
//     edit.cursor_normal     = table[NK_COLOR_TEXT];
//     edit.cursor_hover      = table[NK_COLOR_TEXT];
//     edit.cursor_text_normal= table[NK_COLOR_EDIT];
//     edit.cursor_text_hover = table[NK_COLOR_EDIT];
//     edit.border_color      = table[NK_COLOR_BORDER];
//     edit.text_normal       = table[NK_COLOR_TEXT];
//     edit.text_hover        = table[NK_COLOR_TEXT];
//     edit.text_active       = table[NK_COLOR_TEXT];
//     edit.selected_normal   = table[NK_COLOR_TEXT];
//     edit.selected_hover    = table[NK_COLOR_TEXT];
//     edit.selected_text_normal  = table[NK_COLOR_EDIT];
//     edit.selected_text_hover   = table[NK_COLOR_EDIT];
//     edit.scrollbar_size    = nk_vec2(10,10);
//     edit.scrollbar         = style.scrollv;
//     edit.padding           = nk_vec2(4,4);
//     edit.row_padding       = 2;
//     edit.cursor_size       = 4;
//     edit.border            = 1;
//     edit.rounding          = 0;

//     /* property */
//     property = &style.property;
//     nk_zero_struct(*property);
//     property.normal        = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     property.hover         = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     property.active        = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     property.border_color  = table[NK_COLOR_BORDER];
//     property.label_normal  = table[NK_COLOR_TEXT];
//     property.label_hover   = table[NK_COLOR_TEXT];
//     property.label_active  = table[NK_COLOR_TEXT];
//     property.sym_left      = NK_SYMBOL_TRIANGLE_LEFT;
//     property.sym_right     = NK_SYMBOL_TRIANGLE_RIGHT;
//     property.userdata      = nk_handle_ptr(null);
//     property.padding       = nk_vec2(4,4);
//     property.border        = 1;
//     property.rounding      = 10;
//     property.draw_begin    = null;
//     property.draw_end      = null;

//     /* property buttons */
//     button = &style.property.dec_button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     button.active          = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     button.border_color    = nk_rgba(0,0,0,0);
//     button.text_background = table[NK_COLOR_PROPERTY];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(0.0f,0.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;
//     style.property.inc_button = style.property.dec_button;

//     /* property edit */
//     edit = &style.property.edit;
//     nk_zero_struct(*edit);
//     edit.normal            = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     edit.hover             = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     edit.active            = nk_style_item_color(table[NK_COLOR_PROPERTY]);
//     edit.border_color      = nk_rgba(0,0,0,0);
//     edit.cursor_normal     = table[NK_COLOR_TEXT];
//     edit.cursor_hover      = table[NK_COLOR_TEXT];
//     edit.cursor_text_normal= table[NK_COLOR_EDIT];
//     edit.cursor_text_hover = table[NK_COLOR_EDIT];
//     edit.text_normal       = table[NK_COLOR_TEXT];
//     edit.text_hover        = table[NK_COLOR_TEXT];
//     edit.text_active       = table[NK_COLOR_TEXT];
//     edit.selected_normal   = table[NK_COLOR_TEXT];
//     edit.selected_hover    = table[NK_COLOR_TEXT];
//     edit.selected_text_normal  = table[NK_COLOR_EDIT];
//     edit.selected_text_hover   = table[NK_COLOR_EDIT];
//     edit.padding           = nk_vec2(0,0);
//     edit.cursor_size       = 8;
//     edit.border            = 0;
//     edit.rounding          = 0;

//     /* chart */
//     chart = &style.chart;
//     nk_zero_struct(*chart);
//     chart.background       = nk_style_item_color(table[NK_COLOR_CHART]);
//     chart.border_color     = table[NK_COLOR_BORDER];
//     chart.selected_color   = table[NK_COLOR_CHART_COLOR_HIGHLIGHT];
//     chart.color            = table[NK_COLOR_CHART_COLOR];
//     chart.padding          = nk_vec2(4,4);
//     chart.border           = 0;
//     chart.rounding         = 0;

//     /* combo */
//     combo = &style.combo;
//     combo.normal           = nk_style_item_color(table[NK_COLOR_COMBO]);
//     combo.hover            = nk_style_item_color(table[NK_COLOR_COMBO]);
//     combo.active           = nk_style_item_color(table[NK_COLOR_COMBO]);
//     combo.border_color     = table[NK_COLOR_BORDER];
//     combo.label_normal     = table[NK_COLOR_TEXT];
//     combo.label_hover      = table[NK_COLOR_TEXT];
//     combo.label_active     = table[NK_COLOR_TEXT];
//     combo.sym_normal       = NK_SYMBOL_TRIANGLE_DOWN;
//     combo.sym_hover        = NK_SYMBOL_TRIANGLE_DOWN;
//     combo.sym_active       = NK_SYMBOL_TRIANGLE_DOWN;
//     combo.content_padding  = nk_vec2(4,4);
//     combo.button_padding   = nk_vec2(0,4);
//     combo.spacing          = nk_vec2(4,0);
//     combo.border           = 1;
//     combo.rounding         = 0;

//     /* combo button */
//     button = &style.combo.button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_COMBO]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_COMBO]);
//     button.active          = nk_style_item_color(table[NK_COLOR_COMBO]);
//     button.border_color    = nk_rgba(0,0,0,0);
//     button.text_background = table[NK_COLOR_COMBO];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(2.0f,2.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;

//     /* tab */
//     tab = &style.tab;
//     tab.background         = nk_style_item_color(table[NK_COLOR_TAB_HEADER]);
//     tab.border_color       = table[NK_COLOR_BORDER];
//     tab.text               = table[NK_COLOR_TEXT];
//     tab.sym_minimize       = NK_SYMBOL_TRIANGLE_RIGHT;
//     tab.sym_maximize       = NK_SYMBOL_TRIANGLE_DOWN;
//     tab.padding            = nk_vec2(4,4);
//     tab.spacing            = nk_vec2(4,4);
//     tab.indent             = 10.0f;
//     tab.border             = 1;
//     tab.rounding           = 0;

//     /* tab button */
//     button = &style.tab.tab_minimize_button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_TAB_HEADER]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_TAB_HEADER]);
//     button.active          = nk_style_item_color(table[NK_COLOR_TAB_HEADER]);
//     button.border_color    = nk_rgba(0,0,0,0);
//     button.text_background = table[NK_COLOR_TAB_HEADER];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(2.0f,2.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;
//     style.tab.tab_maximize_button =*button;

//     /* node button */
//     button = &style.tab.node_minimize_button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     button.active          = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     button.border_color    = nk_rgba(0,0,0,0);
//     button.text_background = table[NK_COLOR_TAB_HEADER];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(2.0f,2.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;
//     style.tab.node_maximize_button =*button;

//     /* window header */
//     win = &style.window;
//     win.header.align_ = NK_HEADER_RIGHT;
//     win.header.close_symbol = NK_SYMBOL_X;
//     win.header.minimize_symbol = NK_SYMBOL_MINUS;
//     win.header.maximize_symbol = NK_SYMBOL_PLUS;
//     win.header.normal = nk_style_item_color(table[NK_COLOR_HEADER]);
//     win.header.hover = nk_style_item_color(table[NK_COLOR_HEADER]);
//     win.header.active = nk_style_item_color(table[NK_COLOR_HEADER]);
//     win.header.label_normal = table[NK_COLOR_TEXT];
//     win.header.label_hover = table[NK_COLOR_TEXT];
//     win.header.label_active = table[NK_COLOR_TEXT];
//     win.header.label_padding = nk_vec2(4,4);
//     win.header.padding = nk_vec2(4,4);
//     win.header.spacing = nk_vec2(0,0);

//     /* window header close button */
//     button = &style.window.header.close_button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_HEADER]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_HEADER]);
//     button.active          = nk_style_item_color(table[NK_COLOR_HEADER]);
//     button.border_color    = nk_rgba(0,0,0,0);
//     button.text_background = table[NK_COLOR_HEADER];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(0.0f,0.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;

//     /* window header minimize button */
//     button = &style.window.header.minimize_button;
//     nk_zero_struct(*button);
//     button.normal          = nk_style_item_color(table[NK_COLOR_HEADER]);
//     button.hover           = nk_style_item_color(table[NK_COLOR_HEADER]);
//     button.active          = nk_style_item_color(table[NK_COLOR_HEADER]);
//     button.border_color    = nk_rgba(0,0,0,0);
//     button.text_background = table[NK_COLOR_HEADER];
//     button.text_normal     = table[NK_COLOR_TEXT];
//     button.text_hover      = table[NK_COLOR_TEXT];
//     button.text_active     = table[NK_COLOR_TEXT];
//     button.padding         = nk_vec2(0.0f,0.0f);
//     button.touch_padding   = nk_vec2(0.0f,0.0f);
//     button.userdata        = nk_handle_ptr(null);
//     button.text_alignment  = NK_TEXT_CENTERED;
//     button.border          = 0.0f;
//     button.rounding        = 0.0f;
//     button.draw_begin      = null;
//     button.draw_end        = null;

//     /* window */
//     win.background = table[NK_COLOR_WINDOW];
//     win.fixed_background = nk_style_item_color(table[NK_COLOR_WINDOW]);
//     win.border_color = table[NK_COLOR_BORDER];
//     win.popup_border_color = table[NK_COLOR_BORDER];
//     win.combo_border_color = table[NK_COLOR_BORDER];
//     win.contextual_border_color = table[NK_COLOR_BORDER];
//     win.menu_border_color = table[NK_COLOR_BORDER];
//     win.group_border_color = table[NK_COLOR_BORDER];
//     win.tooltip_border_color = table[NK_COLOR_BORDER];
//     win.scaler = nk_style_item_color(table[NK_COLOR_TEXT]);

//     win.rounding = 0.0f;
//     win.spacing = nk_vec2(4,4);
//     win.scrollbar_size = nk_vec2(10,10);
//     win.min_size = nk_vec2(64,64);

//     win.combo_border = 1.0f;
//     win.contextual_border = 1.0f;
//     win.menu_border = 1.0f;
//     win.group_border = 1.0f;
//     win.tooltip_border = 1.0f;
//     win.popup_border = 1.0f;
//     win.border = 2.0f;
//     win.min_row_height_padding = 8;

//     win.padding = nk_vec2(4,4);
//     win.group_padding = nk_vec2(4,4);
//     win.popup_padding = nk_vec2(4,4);
//     win.combo_padding = nk_vec2(4,4);
//     win.contextual_padding = nk_vec2(4,4);
//     win.menu_padding = nk_vec2(4,4);
//     win.tooltip_padding = nk_vec2(4,4);
// }

// void nk_style_load_cursor(nk_context*, nk_style_cursor, const(nk_cursor)*);
// void nk_style_load_all_cursors(nk_context*, nk_cursor*);
// const(char)* nk_style_get_color_by_name(nk_style_colors);
// void nk_style_set_font(nk_context*, const(nk_user_font)*);
// bool nk_style_set_cursor(nk_context*, nk_style_cursor);
// void nk_style_show_cursor(nk_context*);
// void nk_style_hide_cursor(nk_context*);
// bool nk_style_push_font(nk_context*, const(nk_user_font)*);
// bool nk_style_push_float(nk_context*, float*, float);
// bool nk_style_push_vec2(nk_context*, nk_vec2*, nk_vec2);
// bool nk_style_push_style_item(nk_context*, nk_style_item*, nk_style_item);
// bool nk_style_push_flags(nk_context*, nk_flags*, nk_flags);
// bool nk_style_push_color(nk_context*, nk_color*, nk_color);
// bool nk_style_pop_font(nk_context*);
// bool nk_style_pop_float(nk_context*);
// bool nk_style_pop_vec2(nk_context*);
// bool nk_style_pop_style_item(nk_context*);
// bool nk_style_pop_flags(nk_context*);
// bool nk_style_pop_color(nk_context*);
// nk_color nk_rgb(int r, int g, int b);
// nk_color nk_rgb_iv(const(int)* rgb);
// nk_color nk_rgb_bv(const(nk_byte)* rgb);
// nk_color nk_rgb_f(float r, float g, float b);
// nk_color nk_rgb_fv(const(float)* rgb);
// nk_color nk_rgb_cf(nk_colorf c);
// nk_color nk_rgb_hex(const(char)* rgb);

// nk_color nk_rgba(int r, int g, int b, int a) 
// {
//     nk_color ret;
//     ret.r = cast(nk_byte)nk_clamp(0, r, 255);
//     ret.g = cast(nk_byte)nk_clamp(0, g, 255);
//     ret.b = cast(nk_byte)nk_clamp(0, b, 255);
//     ret.a = cast(nk_byte)nk_clamp(0, a, 255);
//     return ret;
// }

// nk_color nk_rgba_u32(nk_uint);
// nk_color nk_rgba_iv(const(int)* rgba);
// nk_color nk_rgba_bv(const(nk_byte)* rgba);
// nk_color nk_rgba_f(float r, float g, float b, float a);
// nk_color nk_rgba_fv(const(float)* rgba);
// nk_color nk_rgba_cf(nk_colorf c);
// nk_color nk_rgba_hex(const(char)* rgb);
// nk_colorf nk_hsva_colorf(float h, float s, float v, float a);
// nk_colorf nk_hsva_colorfv(float* c);
// void nk_colorf_hsva_f(float* out_h, float* out_s, float* out_v, float* out_a, nk_colorf in_);
// void nk_colorf_hsva_fv(float* hsva, nk_colorf in_);
// nk_color nk_hsv(int h, int s, int v);
// nk_color nk_hsv_iv(const(int)* hsv);
// nk_color nk_hsv_bv(const(nk_byte)* hsv);
// nk_color nk_hsv_f(float h, float s, float v);
// nk_color nk_hsv_fv(const(float)* hsv);
// nk_color nk_hsva(int h, int s, int v, int a);
// nk_color nk_hsva_iv(const(int)* hsva);
// nk_color nk_hsva_bv(const(nk_byte)* hsva);
// nk_color nk_hsva_f(float h, float s, float v, float a);
// nk_color nk_hsva_fv(const(float)* hsva);
// void nk_color_f(float* r, float* g, float* b, float* a, nk_color);
// void nk_color_fv(float* rgba_out, nk_color);
// nk_colorf nk_color_cf(nk_color);
// void nk_color_d(double* r, double* g, double* b, double* a, nk_color);
// void nk_color_dv(double* rgba_out, nk_color);
// nk_uint nk_color_u32(nk_color);
// void nk_color_hex_rgba(char* output, nk_color);
// void nk_color_hex_rgb(char* output, nk_color);
// void nk_color_hsv_i(int* out_h, int* out_s, int* out_v, nk_color);
// void nk_color_hsv_b(nk_byte* out_h, nk_byte* out_s, nk_byte* out_v, nk_color);
// void nk_color_hsv_iv(int* hsv_out, nk_color);
// void nk_color_hsv_bv(nk_byte* hsv_out, nk_color);
// void nk_color_hsv_f(float* out_h, float* out_s, float* out_v, nk_color);
// void nk_color_hsv_fv(float* hsv_out, nk_color);
// void nk_color_hsva_i(int* h, int* s, int* v, int* a, nk_color);
// void nk_color_hsva_b(nk_byte* h, nk_byte* s, nk_byte* v, nk_byte* a, nk_color);
// void nk_color_hsva_iv(int* hsva_out, nk_color);
// void nk_color_hsva_bv(nk_byte* hsva_out, nk_color);
// void nk_color_hsva_f(float* out_h, float* out_s, float* out_v, float* out_a, nk_color);
// void nk_color_hsva_fv(float* hsva_out, nk_color);
// nk_handle nk_handle_ptr(void*);
// nk_handle nk_handle_id(int);
// nk_image nk_image_handle(nk_handle);
// nk_image nk_image_ptr(void*);
// nk_image nk_image_id(int);
// bool nk_image_is_subimage(const(nk_image)* img);
// nk_image nk_subimage_ptr(void*, ushort w, ushort h, nk_rect sub_region);
// nk_image nk_subimage_id(int, ushort w, ushort h, nk_rect sub_region);
// nk_image nk_subimage_handle(nk_handle, ushort w, ushort h, nk_rect sub_region);
// //slice here


// nk_nine_slice nk_nine_slice_handle(nk_handle, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b);
// nk_nine_slice nk_nine_slice_ptr(void*, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b);
// nk_nine_slice nk_nine_slice_id(int, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b);
// int nk_nine_slice_is_sub9slice(const(nk_nine_slice)* img);
// nk_nine_slice nk_sub9slice_ptr(void*, nk_ushort w, nk_ushort h, nk_rect sub_region, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b);
// nk_nine_slice nk_sub9slice_id(int, nk_ushort w, nk_ushort h, nk_rect sub_region, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b);
// nk_nine_slice nk_sub9slice_handle(nk_handle, nk_ushort w, nk_ushort h, nk_rect sub_region, nk_ushort l, nk_ushort t, nk_ushort r, nk_ushort b);

// nk_hash nk_murmur_hash(const(void)* key, int len, nk_hash seed)
// {
//     void NK_ROTL(T)(T x, T r) { return ((x) << (r) | ((x) >> (32 - r))); }

//     nk_uint h1 = seed;
//     nk_uint k1;
//     const(nk_byte)* data = cast(const(nk_byte)*)key;
//     const(nk_byte)* keyptr = data;
//     nk_byte* k1ptr;
//     const int bsize = k1.sizeof;
//     const int nblocks = len/4;

//     const nk_uint c1 = 0xcc9e2d51;
//     const nk_uint c2 = 0x1b873593;
//     const(nk_byte)* tail;
//     int i;

//     /* body */
//     if (!key) return 0;
//     for (i = 0; i < nblocks; ++i, keyptr += bsize) {
//         k1ptr = cast(nk_byte*)&k1;
//         k1ptr[0] = keyptr[0];
//         k1ptr[1] = keyptr[1];
//         k1ptr[2] = keyptr[2];
//         k1ptr[3] = keyptr[3];

//         k1 *= c1;
//         k1 = NK_ROTL(k1,15);
//         k1 *= c2;

//         h1 ^= k1;
//         h1 = NK_ROTL(h1,13);
//         h1 = h1*5+0xe6546b64;
//     }

//     /* tail */
//     tail = cast(const(nk_byte)*)(data + nblocks*4);
//     k1 = 0;
//     switch (len & 3) {
//         case 3: k1 ^= cast(nk_uint)(tail[2] << 16); /* fallthrough */
//         case 2: k1 ^= cast(nk_uint)(tail[1] << 8u); /* fallthrough */
//         case 1: k1 ^= tail[0];
//             k1 *= c1;
//             k1 = NK_ROTL(k1,15);
//             k1 *= c2;
//             h1 ^= k1;
//             break;
//         default: break;
//     }

//     /* finalization */
//     h1 ^= cast(nk_uint)len;
//     /* fmix32 */
//     h1 ^= h1 >> 16;
//     h1 *= 0x85ebca6b;
//     h1 ^= h1 >> 13;
//     h1 *= 0xc2b2ae35;
//     h1 ^= h1 >> 16;

//     return h1;
// }

// void nk_triangle_from_direction(nk_vec2* result, nk_rect r, float pad_x, float pad_y, nk_heading);
// pragma(mangle, "nk_vec2")
//     nk_vec2 nk_vec2_(float x, float y);
// pragma(mangle, "nk_vec2i")
//     nk_vec2 nk_vec2i_(int x, int y);
// nk_vec2 nk_vec2v(const(float)* xy);
// nk_vec2 nk_vec2iv(const(int)* xy);
// nk_rect nk_get_null_rect();
// pragma(mangle, "nk_rect")
//     nk_rect nk_rect_(float x, float y, float w, float h);
// nk_rect nk_recti(int x, int y, int w, int h);
// nk_rect nk_recta(nk_vec2 pos, nk_vec2 size);
// nk_rect nk_rectv(const(float)* xywh);
// nk_rect nk_rectiv(const(int)* xywh);
// nk_vec2 nk_rect_pos(nk_rect);
// nk_vec2 nk_rect_size(nk_rect);

// int nk_strlen(const(char)* str)
// {
//     int siz = 0;
//     assert(str);
//     while (str && *str++ != '\0') siz++;
//     return siz;
// }

// int nk_stricmp(const(char)* s1, const(char)* s2)
// {
//     nk_int c1,c2,d;
//     do {
//         c1 = *s1++;
//         c2 = *s2++;
//         d = c1 - c2;
//         while (d) {
//             if (c1 <= 'Z' && c1 >= 'A') {
//                 d += ('a' - 'A');
//                 if (!d) break;
//             }
//             if (c2 <= 'Z' && c2 >= 'A') {
//                 d -= ('a' - 'A');
//                 if (!d) break;
//             }
//             return ((d >= 0) << 1) - 1;
//         }
//     } while (c1);
//     return 0;
// }

// int nk_stricmpn(const(char)* s1, const(char)* s2, int n)
// {
//     int c1,c2,d;
//     assert(n >= 0);
//     do {
//         c1 = *s1++;
//         c2 = *s2++;
//         if (!n--) return 0;

//         d = c1 - c2;
//         while (d) {
//             if (c1 <= 'Z' && c1 >= 'A') {
//                 d += ('a' - 'A');
//                 if (!d) break;
//             }
//             if (c2 <= 'Z' && c2 >= 'A') {
//                 d -= ('a' - 'A');
//                 if (!d) break;
//             }
//             return ((d >= 0) << 1) - 1;
//         }
//     } while (c1);
//     return 0;
// }

// int nk_strtoi(const(char)* str, const(char)** endptr)
// {
//     int neg = 1;
//     const(char)* p = str;
//     int value = 0;

//     assert(str);
//     if (!str) return 0;

//     /* skip whitespace */
//     while (*p == ' ') p++;
//     if (*p == '-') {
//         neg = -1;
//         p++;
//     }
//     while (*p && *p >= '0' && *p <= '9') {
//         value = value * 10 + cast(int) (*p - '0');
//         p++;
//     }
//     if (endptr)
//         *endptr = p;
//     return neg*value;
// }

// float nk_strtof(const(char)* str, const(char)** endptr)
// {
//     float float_value;
//     double double_value;
//     double_value = nk_strtod(str, endptr);
//     float_value = cast(float)double_value;
//     return float_value;
// }

// double nk_strtod(const(char)* str, const(char)** endptr)
// {
//     double m;
//     double neg = 1.0;
//     const char *p = str;
//     double value = 0;
//     double number = 0;

//     assert(str);
//     if (!str) return 0;

//     /* skip whitespace */
//     while (*p == ' ') p++;
//     if (*p == '-') {
//         neg = -1.0;
//         p++;
//     }

//     while (*p && *p != '.' && *p != 'e') {
//         value = value * 10.0 + cast(double) (*p - '0');
//         p++;
//     }

//     if (*p == '.') {
//         p++;
//         for(m = 0.1; *p && *p != 'e'; p++ ) {
//             value = value + cast(double) (*p - '0') * m;
//             m *= 0.1;
//         }
//     }
//     if (*p == 'e') {
//         int i, pow, div;
//         p++;
//         if (*p == '-') {
//             div = nk_true;
//             p++;
//         } else if (*p == '+') {
//             div = nk_false;
//             p++;
//         } else div = nk_false;

//         for (pow = 0; *p; p++)
//             pow = pow * 10 + cast(int) (*p - '0');

//         for (m = 1.0, i = 0; i < pow; i++)
//             m *= 10.0;

//         if (div)
//             value /= m;
//         else value *= m;
//     }
//     number = value * neg;
//     if (endptr)
//         *endptr = p;
//     return number;
// }

// int nk_str_match_star(int c, const(char)* regexp, const(char)* text)
// {
//     do {/* a '* matches zero or more instances */
//         if (nk_str_match_here(regexp, text))
//             return 1;
//     } while (*text != '\0' && (*text++ == c || c == '.'));
//     return 0;
// }

// int nk_str_match_here(const(char)* regexp, const(char)* text)
// {
//     if (regexp[0] == '\0')
//         return 1;
//     if (regexp[1] == '*')
//         return nk_str_match_star(regexp[0], regexp+2, text);
//     if (regexp[0] == '$' && regexp[1] == '\0')
//         return *text == '\0';
//     if (*text!='\0' && (regexp[0]=='.' || regexp[0]==*text))
//         return nk_str_match_here(regexp+1, text+1);
//     return 0;
// }

// int nk_strfilter(const(char)* text, const(char)* regexp)
// {
//     /*
//     c    matches any literal character c
//     .    matches any single character
//     ^    matches the beginning of the input string
//     $    matches the end of the input string
//     *    matches zero or more occurrences of the previous character*/
//     if (regexp[0] == '^')
//         return nk_str_match_here(regexp+1, text);
//     do {    /* must look even if string is empty */
//         if (nk_str_match_here(regexp, text))
//             return 1;
//     } while (*text++ != '\0');
//     return 0;
// }

// int nk_strmatch_fuzzy_string(const(char)* str, const(char)* pattern, int* out_score);
// int nk_strmatch_fuzzy_text(const(char)* txt, int txt_len, const(char)* pattern, int* out_score);
// int nk_utf_decode(const(char)*, nk_rune*, int);

// int nk_utf_validate(nk_rune *u, int i)
// {
//     assert(u);
//     if (!u) return 0;
//     if (!nk_between(*u, nk_utfmin[i], nk_utfmax[i]) ||
//          nk_between(*u, 0xD800, 0xDFFF))
//             *u = NK_UTF_INVALID;
//     for (i = 1; *u > nk_utfmax[i]; ++i) {}
//     return i;
// }

// char nk_utf_encode_byte(nk_rune u, int i)
// {
//     return cast(char)((nk_utfbyte[i]) | (cast(nk_byte)u & ~nk_utfmask[i]));
// }

// int nk_utf_encode(nk_rune u, char* c, int clen)
// {
//     int len, i;
//     len = nk_utf_validate(&u, 0);
//     if (clen < len || !len || len > NK_UTF_SIZE)
//         return 0;

//     for (i = len - 1; i != 0; --i) {
//         c[i] = nk_utf_encode_byte(u, 0);
//         u >>= 6;
//     }
//     c[0] = nk_utf_encode_byte(u, len);
//     return len;
// }

// int nk_utf_len(const(char)*, int byte_len);
// const(char)* nk_utf_at(const(char)* buffer, int length, int index, nk_rune* unicode, int* len);
// version(NK_INCLUDE_FONT_BAKING) {
//     const(nk_rune)* nk_font_default_glyph_ranges();
//     const(nk_rune)* nk_font_chinese_glyph_ranges();
//     const(nk_rune)* nk_font_cyrillic_glyph_ranges();
//     const(nk_rune)* nk_font_korean_glyph_ranges();
//     version(NK_INCLUDE_DEFAULT_ALLOCATOR) {
//         void nk_font_atlas_init_default(nk_font_atlas*);
//     }
//     void nk_font_atlas_init(nk_font_atlas*, nk_allocator*);
//     void nk_font_atlas_init_custom(nk_font_atlas*, nk_allocator* persistent, nk_allocator* transient);
//     void nk_font_atlas_begin(nk_font_atlas*);
//     pragma(mangle, "nk_font_config")
//         nk_font_config nk_font_config_(float pixel_height);
//     nk_font* nk_font_atlas_add(nk_font_atlas*, const(nk_font_config)*);
//     version(NK_INCLUDE_DEFAULT_FONT) {
//         nk_font* nk_font_atlas_add_default(nk_font_atlas*, float height, const(nk_font_config)*);
//     }
//     nk_font* nk_font_atlas_add_from_memory(nk_font_atlas* atlas, void* memory, nk_size size, float height, const(nk_font_config)* config);
//     version(NK_INCLUDE_STANDARD_IO) {
//         nk_font* nk_font_atlas_add_from_file(nk_font_atlas* atlas, const(char)* file_path, float height, const(nk_font_config)*);
//     }
//     nk_font* nk_font_atlas_add_compressed(nk_font_atlas*, void* memory, nk_size size, float height, const(nk_font_config)*);
//     nk_font* nk_font_atlas_add_compressed_base85(nk_font_atlas*, const(char)* data, float height, const(nk_font_config)* config);
//     const(void)* nk_font_atlas_bake(nk_font_atlas*, int* width, int* height, nk_font_atlas_format);
//     void nk_font_atlas_end(nk_font_atlas*, nk_handle tex, nk_draw_null_texture*);
//     const(nk_font_glyph)* nk_font_find_glyph(nk_font*, nk_rune unicode);
//     void nk_font_atlas_cleanup(nk_font_atlas* atlas);
//     void nk_font_atlas_clear(nk_font_atlas*);
// }
// version(NK_INCLUDE_DEFAULT_ALLOCATOR) {
//     void nk_buffer_init_default(nk_buffer*);
// }
// void nk_buffer_init(nk_buffer*, const(nk_allocator)*, nk_size size);

// void nk_buffer_init_fixed(nk_buffer* b, void* m, nk_size size) 
// {
//     assert(b);
//     assert(m);
//     assert(size);
//     if (!b || !m || !size) return;

//     nk_zero(b, (*b).sizeof);
//     b.type = NK_BUFFER_FIXED;
//     b.memory.ptr = m;
//     b.memory.size = size;
//     b.size = size;
// }

// void nk_buffer_info(nk_memory_status*, nk_buffer*);
// void nk_buffer_push(nk_buffer*, nk_buffer_allocation_type type, const(void)* memory, nk_size size, nk_size align_);
// void nk_buffer_mark(nk_buffer*, nk_buffer_allocation_type type);

// void nk_buffer_reset(nk_buffer* buffer, nk_buffer_allocation_type type)
// {
//     assert(buffer);
//     if (!buffer) return;
//     if (type == NK_BUFFER_BACK) {
//         /* reset back buffer either back to marker or empty */
//         buffer.needed -= (buffer.memory.size - buffer.marker[type].offset);
//         if (buffer.marker[type].active)
//             buffer.size = buffer.marker[type].offset;
//         else buffer.size = buffer.memory.size;
//         buffer.marker[type].active = nk_false;
//     } else {
//         /* reset front buffer either back to back marker or empty */
//         buffer.needed -= (buffer.allocated - buffer.marker[type].offset);
//         if (buffer.marker[type].active)
//             buffer.allocated = buffer.marker[type].offset;
//         else buffer.allocated = 0;
//         buffer.marker[type].active = nk_false;
//     }
// }

// void nk_buffer_clear(nk_buffer* b)
// {
//     assert(b);
//     if (!b) return;
//     b.allocated = 0;
//     b.size = b.memory.size;
//     b.calls = 0;
//     b.needed = 0;
// }

// void nk_buffer_free(nk_buffer* b)
// {
//     assert(b);
//     if (!b || !b.memory.ptr) return;
//     if (b.type == NK_BUFFER_FIXED) return;
//     if (!b.pool.free) return;
//     assert(b.pool.free);
//     b.pool.free(b.pool.userdata, b.memory.ptr);
// }

// void* nk_buffer_memory(nk_buffer* buffer)
// {
//     assert(buffer);
//     if (!buffer) return null;
//     return buffer.memory.ptr;
// }

// const(void)* nk_buffer_memory_const(const(nk_buffer)* buffer)
// {
//     assert(buffer);
//     if (!buffer) return null;
//     return buffer.memory.ptr;
// }

// nk_size nk_buffer_total(nk_buffer* buffer)
// {
//     assert(buffer);
//     if (!buffer) return null;
//     return buffer.memory.size;
// }

// version(NK_INCLUDE_DEFAULT_ALLOCATOR) {
//     void nk_str_init_default(nk_str*);
// }
// void nk_str_init(nk_str*, const(nk_allocator)*, nk_size size);
// void nk_str_init_fixed(nk_str*, void* memory, nk_size size);
// void nk_str_clear(nk_str*);
// void nk_str_free(nk_str*);
// int nk_str_append_text_char(nk_str*, const(char)*, int);
// int nk_str_append_str_char(nk_str*, const(char)*);
// int nk_str_append_text_utf8(nk_str*, const(char)*, int);
// int nk_str_append_str_utf8(nk_str*, const(char)*);
// int nk_str_append_text_runes(nk_str*, const(nk_rune)*, int);
// int nk_str_append_str_runes(nk_str*, const(nk_rune)*);
// int nk_str_insert_at_char(nk_str*, int pos, const(char)*, int);
// int nk_str_insert_at_rune(nk_str*, int pos, const(char)*, int);
// int nk_str_insert_text_char(nk_str*, int pos, const(char)*, int);
// int nk_str_insert_str_char(nk_str*, int pos, const(char)*);
// int nk_str_insert_text_utf8(nk_str*, int pos, const(char)*, int);
// int nk_str_insert_str_utf8(nk_str*, int pos, const(char)*);
// int nk_str_insert_text_runes(nk_str*, int pos, const(nk_rune)*, int);
// int nk_str_insert_str_runes(nk_str*, int pos, const(nk_rune)*);
// void nk_str_remove_chars(nk_str*, int len);
// void nk_str_remove_runes(nk_str* str, int len);
// void nk_str_delete_chars(nk_str*, int pos, int len);
// void nk_str_delete_runes(nk_str*, int pos, int len);
// char* nk_str_at_char(nk_str*, int pos);
// char* nk_str_at_rune(nk_str*, int pos, nk_rune* unicode, int* len);
// nk_rune nk_str_rune_at(const(nk_str)*, int pos);
// const(char)* nk_str_at_char_const(const(nk_str)*, int pos);
// const(char)* nk_str_at_const(const(nk_str)*, int pos, nk_rune* unicode, int* len);
// char* nk_str_get(nk_str*);
// const(char)* nk_str_get_const(const(nk_str)*);
// int nk_str_len(nk_str*);
// int nk_str_len_char(nk_str*);
// bool nk_filter_default(const(nk_text_edit)*, nk_rune unicode);
// bool nk_filter_ascii(const(nk_text_edit)*, nk_rune unicode);
// bool nk_filter_float(const(nk_text_edit)*, nk_rune unicode);
// bool nk_filter_decimal(const(nk_text_edit)*, nk_rune unicode);
// bool nk_filter_hex(const(nk_text_edit)*, nk_rune unicode);
// bool nk_filter_oct(const(nk_text_edit)*, nk_rune unicode);
// bool nk_filter_binary(const(nk_text_edit)*, nk_rune unicode);

// auto nk_filter_default_fptr = &nk_filter_default;
// auto nk_filter_ascii_fptr   = &nk_filter_ascii;
// auto nk_filter_float_fptr   = &nk_filter_float;
// auto nk_filter_decimal_fptr = &nk_filter_decimal;
// auto nk_filter_hex_fptr     = &nk_filter_hex;
// auto nk_filter_oct_fptr     = &nk_filter_oct;
// auto nk_filter_binary_fptr  = &nk_filter_binary;

// version(NK_INCLUDE_DEFAULT_ALLOCATOR) {
//     void nk_textedit_init_default(nk_text_edit*);
// }
// void nk_textedit_init(nk_text_edit*, nk_allocator*, nk_size size);
// void nk_textedit_init_fixed(nk_text_edit*, void* memory, nk_size size);
// void nk_textedit_free(nk_text_edit*);
// void nk_textedit_text(nk_text_edit*, const(char)*, int total_len);
// void nk_textedit_delete(nk_text_edit*, int where, int len);
// void nk_textedit_delete_selection(nk_text_edit*);
// void nk_textedit_select_all(nk_text_edit*);
// bool nk_textedit_cut(nk_text_edit*);
// bool nk_textedit_paste(nk_text_edit*, const(char)*, int len);
// void nk_textedit_undo(nk_text_edit*);
// void nk_textedit_redo(nk_text_edit*);
// void nk_stroke_line(nk_command_buffer* b, float x0, float y0, float x1, float y1, float line_thickness, nk_color);
// void nk_stroke_curve(nk_command_buffer*, float, float, float, float, float, float, float, float, float line_thickness, nk_color);
// void nk_stroke_rect(nk_command_buffer*, nk_rect, float rounding, float line_thickness, nk_color);
// void nk_stroke_circle(nk_command_buffer*, nk_rect, float line_thickness, nk_color);
// void nk_stroke_arc(nk_command_buffer*, float cx, float cy, float radius, float a_min, float a_max, float line_thickness, nk_color);
// void nk_stroke_triangle(nk_command_buffer*, float, float, float, float, float, float, float line_thichness, nk_color);
// void nk_stroke_polyline(nk_command_buffer*, float* points, int point_count, float line_thickness, nk_color col);
// void nk_stroke_polygon(nk_command_buffer*, float*, int point_count, float line_thickness, nk_color);
// void nk_fill_rect(nk_command_buffer*, nk_rect, float rounding, nk_color);
// void nk_fill_rect_multi_color(nk_command_buffer*, nk_rect, nk_color left, nk_color top, nk_color right, nk_color bottom);
// void nk_fill_circle(nk_command_buffer*, nk_rect, nk_color);
// void nk_fill_arc(nk_command_buffer*, float cx, float cy, float radius, float a_min, float a_max, nk_color);
// void nk_fill_triangle(nk_command_buffer*, float x0, float y0, float x1, float y1, float x2, float y2, nk_color);
// void nk_fill_polygon(nk_command_buffer*, float*, int point_count, nk_color);

// void* nk_buffer_align(void *unaligned, nk_size align_, nk_size *alignment, nk_buffer_allocation_type type)
// {
//     void* memory = null;
//     switch (type) {
//         default:
//         case NK_BUFFER_MAX:
//         case NK_BUFFER_FRONT:
//             if (align_) {
//                 memory = nk_align_ptr(unaligned, align_);
//                 *alignment = cast(nk_size)(cast(nk_byte*)memory - cast(nk_byte*)unaligned);
//             } else {
//                 memory = unaligned;
//                 *alignment = 0;
//             }
//             break;
//         case NK_BUFFER_BACK:
//             if (align_) {
//                 memory = nk_align_ptr_back(unaligned, align_);
//                 *alignment = cast(nk_size)(cast(nk_byte*)unaligned - cast(nk_byte*)memory);
//             } else {
//                 memory = unaligned;
//                 *alignment = 0;
//             }
//             break;
//     }
//     return memory;
// }

// void* nk_buffer_realloc(nk_buffer *b, nk_size capacity, nk_size *size)
// {
//     void *temp;
//     nk_size buffer_size;

//     assert(b);
//     assert(size);
//     if (!b || !size || !b.pool.alloc || !b.pool.free)
//         return null;

//     buffer_size = b.memory.size;
//     temp = b.pool.alloc(b.pool.userdata, b.memory.ptr, capacity);
//     assert(temp);
//     if (!temp) return null;

//     *size = capacity;
//     if (temp != b.memory.ptr) {
//         nk_memcopy(temp, b.memory.ptr, buffer_size);
//         b.pool.free(b.pool.userdata, b.memory.ptr);
//     }

//     if (b.size == buffer_size) {
//         /* no back buffer so just set correct size */
//         b.size = capacity;
//         return temp;
//     } else {
//         /* copy back buffer to the end of the new buffer */
//         void* dst, src;
//         nk_size back_size;
//         back_size = buffer_size - b.size;
//         dst = nk_ptr_add!void(temp, capacity - back_size);
//         src = nk_ptr_add!void(temp, b.size);
//         nk_memcopy(dst, src, back_size);
//         b.size = capacity - back_size;
//     }
//     return temp;
// }

// nk_uint nk_round_up_pow2(nk_uint v)
// {
//     v--;
//     v |= v >> 1;
//     v |= v >> 2;
//     v |= v >> 4;
//     v |= v >> 8;
//     v |= v >> 16;
//     v++;
//     return v;
// }

// void* nk_buffer_alloc(nk_buffer *b, nk_buffer_allocation_type type, nk_size size, nk_size align_)
// {
//     int full;
//     nk_size alignment;
//     void *unaligned;
//     void *memory;

//     assert(b);
//     assert(size);
//     if (!b || !size) return null;
//     b.needed += size;

//     /* calculate total size with needed alignment + size */
//     if (type == NK_BUFFER_FRONT)
//         unaligned = nk_ptr_add!void(b.memory.ptr, b.allocated);
//     else unaligned = nk_ptr_add!void(b.memory.ptr, b.size - size);
//     memory = nk_buffer_align(unaligned, align_, &alignment, type);

//     /* check if buffer has enough memory*/
//     if (type == NK_BUFFER_FRONT)
//         full = ((b.allocated + size + alignment) > b.size);
//     else full = ((b.size - nk_min(b.size,(size + alignment))) <= b.allocated);

//     if (full) {
//         nk_size capacity;
//         if (b.type != NK_BUFFER_DYNAMIC)
//             return null;
//         assert(b.pool.alloc && b.pool.free);
//         if (b.type != NK_BUFFER_DYNAMIC || !b.pool.alloc || !b.pool.free)
//             return null;

//         /* buffer is full so allocate bigger buffer if dynamic */
//         capacity = cast(nk_size)(cast(float)b.memory.size * b.grow_factor);
//         capacity = nk_max(capacity, nk_round_up_pow2(cast(nk_uint)(b.allocated + size)));
//         b.memory.ptr = nk_buffer_realloc(b, capacity, &b.memory.size);
//         if (!b.memory.ptr) return null;

//         /* align_ newly allocated pointer */
//         if (type == NK_BUFFER_FRONT)
//             unaligned = nk_ptr_add!void(b.memory.ptr, b.allocated);
//         else unaligned = nk_ptr_add!void(b.memory.ptr, b.size - size);
//         memory = nk_buffer_align(unaligned, align_, &alignment, type);
//     }
//     if (type == NK_BUFFER_FRONT)
//         b.allocated += size + alignment;
//     else b.size -= (size + alignment);
//     b.needed += alignment;
//     b.calls++;
//     return memory;
// }

// void* nk_command_buffer_push(nk_command_buffer* b, nk_command_type t, nk_size size)
// {
//     const nk_size align_ = nk_command.alignof;
//     nk_command *cmd;
//     nk_size alignment;
//     void *unaligned;
//     void *memory;

//     assert(b);
//     assert(b.base);
//     if (!b) return null;
//     cmd = cast(nk_command*)nk_buffer_alloc(b.base,NK_BUFFER_FRONT,size,align_);
//     if (!cmd) return null;

//     /* make sure the offset to the next command is aligned */
//     b.last = cast(nk_size)(cast(nk_byte*) cmd - cast(nk_byte*)b.base.memory.ptr);
//     unaligned = cast(nk_byte*)cmd + size;
//     memory = nk_align_ptr(unaligned, align_);
//     alignment = cast(nk_size)(cast(nk_byte*)memory - cast(nk_byte*)unaligned);
//     version(NK_ZERO_COMMAND_MEMORY) {
//         nk_memset(cmd, 0, size + alignment);
//     }

//     cmd.type = t;
//     cmd.next = b.base.allocated + alignment;
//     version(NK_INCLUDE_COMMAND_USERDATA) {
//         cmd.userdata = b.userdata;
//     }
//     b.end = cmd.next;
//     return cmd;
// }

// void nk_draw_image(nk_command_buffer* b, nk_rect r, const(nk_image)* img, nk_color col)
// {
//     nk_command_image *cmd;
//     assert(b);
//     if (!b) return;
//     if (b.use_clipping) {
//         const nk_rect *c = &b.clip;
//         if (c.w == 0 || c.h == 0 || !nk_intersect(r.x, r.y, r.w, r.h, c.x, c.y, c.w, c.h))
//             return;
//     }

//     cmd = cast(nk_command_image*)nk_command_buffer_push(b, NK_COMMAND_IMAGE, (*cmd).sizeof);
//     if (!cmd) return;
//     cmd.x = cast(short)r.x;
//     cmd.y = cast(short)r.y;
//     cmd.w = cast(ushort)nk_max(0, r.w);
//     cmd.h = cast(ushort)nk_max(0, r.h);
//     cmd.img = cast(nk_image)*img;
//     cmd.col = col;
// }

// void nk_draw_text(nk_command_buffer*, nk_rect, const(char)* text, int len, const(nk_user_font)*, nk_color, nk_color);
// void nk_push_scissor(nk_command_buffer*, nk_rect);
// void nk_push_custom(nk_command_buffer*, nk_rect, nk_command_custom_callback, nk_handle usr);
// bool nk_input_has_mouse_click(const(nk_input)*, nk_buttons);
// bool nk_input_has_mouse_click_in_rect(const(nk_input)*, nk_buttons, nk_rect);
// bool nk_input_has_mouse_click_in_button_rect(const(nk_input)*, nk_buttons, nk_rect);
// bool nk_input_has_mouse_click_down_in_rect(const(nk_input)*, nk_buttons, nk_rect, bool down);
// bool nk_input_is_mouse_click_in_rect(const(nk_input)*, nk_buttons, nk_rect);
// bool nk_input_is_mouse_click_down_in_rect(const(nk_input)* i, nk_buttons id, nk_rect b, bool down);
// bool nk_input_any_mouse_click_in_rect(const(nk_input)*, nk_rect);
// bool nk_input_is_mouse_prev_hovering_rect(const(nk_input)*, nk_rect);
// bool nk_input_is_mouse_hovering_rect(const(nk_input)*, nk_rect);
// bool nk_input_mouse_clicked(const(nk_input)*, nk_buttons, nk_rect);
// bool nk_input_is_mouse_down(const(nk_input)*, nk_buttons);
// bool nk_input_is_mouse_pressed(const(nk_input)*, nk_buttons);
// bool nk_input_is_mouse_released(const(nk_input)*, nk_buttons);
// bool nk_input_is_key_pressed(const(nk_input)*, nk_keys);
// bool nk_input_is_key_released(const(nk_input)*, nk_keys);
// bool nk_input_is_key_down(const(nk_input)*, nk_keys);
// version(NK_INCLUDE_VERTEX_BUFFER_OUTPUT) {
//     void nk_draw_list_init(nk_draw_list*);

//     void nk_draw_list_setup(nk_draw_list* canvas, const(nk_convert_config)* config, nk_buffer* cmds, nk_buffer* vertices, nk_buffer* elements, nk_anti_aliasing line_aa, nk_anti_aliasing shape_aa)
//     {
//         assert(canvas);
//         assert(config);
//         assert(cmds);
//         assert(vertices);
//         assert(elements);
//         if (!canvas || !config || !cmds || !vertices || !elements)
//             return;

//         canvas.buffer = cmds;
//         canvas.config = *config;
//         canvas.elements = elements;
//         canvas.vertices = vertices;
//         canvas.line_AA = line_aa;
//         canvas.shape_AA = shape_aa;
//         canvas.clip_rect = nk_null_rect;

//         canvas.cmd_offset = 0;
//         canvas.element_count = 0;
//         canvas.vertex_count = 0;
//         canvas.cmd_offset = 0;
//         canvas.cmd_count = 0;
//         canvas.path_count = 0;
//     }

//     const(nk_draw_command)* nk__draw_list_begin(const(nk_draw_list)* canvas, const(nk_buffer)* buffer)
//     {
//         nk_byte *memory;
//         nk_size offset;
//         const(nk_draw_command)* cmd;

//         assert(buffer);
//         if (!buffer || !buffer.size || !canvas.cmd_count)
//             return null;

//         memory = cast(nk_byte*)buffer.memory.ptr;
//         offset = buffer.memory.size - canvas.cmd_offset;
//         cmd = nk_ptr_add!nk_draw_command(memory, offset);
//         return cmd;
//     }

//     const(nk_draw_command)* nk__draw_list_next(const(nk_draw_command)* cmd, const(nk_buffer)* buffer, const(nk_draw_list)* canvas)
//     {
//         const(nk_draw_command)* end;
//         assert(buffer);
//         assert(canvas);
//         if (!cmd || !buffer || !canvas)
//             return 0;

//         end = nk__draw_list_end(canvas, buffer);
//         if (cmd <= end) return null;
//         return (cmd-1);
//     }

//     const(nk_draw_command)* nk__draw_list_end(const(nk_draw_list)* canvas, const(nk_buffer)* buffer)
//     {
//         nk_size size;
//         nk_size offset;
//         nk_byte *memory;
//         const(nk_draw_command)* end;

//         assert(buffer);
//         assert(canvas);
//         if (!buffer || !canvas)
//             return null;

//         memory = cast(nk_byte*)buffer.memory.ptr;
//         size = buffer.memory.size;
//         offset = size - canvas.cmd_offset;
//         end = nk_ptr_add!nk_draw_command(memory, offset);
//         end -= (canvas.cmd_count-1);
//         return end;
//     }

//     void nk_draw_list_path_clear(nk_draw_list* list)
//     {
//         assert(list);
//         if (!list) return;
//         nk_buffer_reset(list.buffer, NK_BUFFER_FRONT);
//         list.path_count = 0;
//         list.path_offset = 0;
//     }

//     void nk_draw_list_push_image(nk_draw_list* list, nk_handle texture)
//     {
//         assert(list);
//         if (!list) return;
//         version (NK_INCLUDE_COMMAND_USERDATA) {
//             if (!list.cmd_count) {
//                 nk_draw_list_push_command(list, nk_null_rect, texture);
//             } else {
//                 nk_draw_command* prev = nk_draw_list_command_last(list);
//                 if (prev.elem_count == 0) {
//                     prev.texture = texture;
//                     prev.userdata = list.userdata;
//                 } else if (prev.texture.id != texture.id || prev.userdata.id != list.userdata.id) {
//                     nk_draw_list_push_command(list, prev.clip_rect, texture);
//                 }
//             }
//         } else {
//             if (!list.cmd_count) {
//                 nk_draw_list_push_command(list, nk_null_rect, texture);
//             } else {
//                 nk_draw_command* prev = nk_draw_list_command_last(list);
//                 if (prev.elem_count == 0) {
//                     prev.texture = texture;
//                 } else if (prev.texture.id != texture.id) {
//                     nk_draw_list_push_command(list, prev.clip_rect, texture);
//                 }
//             }
//         }
//     }

//     void nk_draw_list_path_line_to(nk_draw_list* list, nk_vec2 pos)
//     {
//         nk_vec2* points = null;
//         nk_draw_command* cmd = null;
//         assert(list);
//         if (!list) return;
//         if (!list.cmd_count)
//             nk_draw_list_add_clip(list, nk_null_rect);

//         cmd = nk_draw_list_command_last(list);
//         if (cmd && cmd.texture.ptr != list.config.tex_null.texture.ptr)
//             nk_draw_list_push_image(list, list.config.tex_null.texture);

//         points = nk_draw_list_alloc_path(list, 1);
//         if (!points) return;
//         points[0] = pos;
//     }

//     void nk_draw_list_path_arc_to_fast(nk_draw_list*, nk_vec2 center, float radius, int a_min, int a_max);
//     void nk_draw_list_path_arc_to(nk_draw_list*, nk_vec2 center, float radius, float a_min, float a_max, uint segments);
//     void nk_draw_list_path_rect_to(nk_draw_list*, nk_vec2 a, nk_vec2 b, float rounding);
//     void nk_draw_list_path_curve_to(nk_draw_list*, nk_vec2 p2, nk_vec2 p3, nk_vec2 p4, uint num_segments);
//     void nk_draw_list_path_fill(nk_draw_list*, nk_color);
//     void nk_draw_list_path_stroke(nk_draw_list*, nk_color, nk_draw_list_stroke closed, float thickness);
//     void nk_draw_list_stroke_line(nk_draw_list*, nk_vec2 a, nk_vec2 b, nk_color, float thickness);
//     void nk_draw_list_stroke_rect(nk_draw_list*, nk_rect rect, nk_color, float rounding, float thickness);
//     void nk_draw_list_stroke_triangle(nk_draw_list*, nk_vec2 a, nk_vec2 b, nk_vec2 c, nk_color, float thickness);
//     void nk_draw_list_stroke_circle(nk_draw_list*, nk_vec2 center, float radius, nk_color, uint segs, float thickness);
//     void nk_draw_list_stroke_curve(nk_draw_list*, nk_vec2 p0, nk_vec2 cp0, nk_vec2 cp1, nk_vec2 p1, nk_color, uint segments, float thickness);
//     void nk_draw_list_stroke_poly_line(nk_draw_list*, const(nk_vec2)* pnts, const(uint) cnt, nk_color, nk_draw_list_stroke, float thickness, nk_anti_aliasing);
//     void nk_draw_list_fill_rect(nk_draw_list*, nk_rect rect, nk_color, float rounding);
//     void nk_draw_list_fill_rect_multi_color(nk_draw_list*, nk_rect rect, nk_color left, nk_color top, nk_color right, nk_color bottom);
//     void nk_draw_list_fill_triangle(nk_draw_list*, nk_vec2 a, nk_vec2 b, nk_vec2 c, nk_color);
//     void nk_draw_list_fill_circle(nk_draw_list*, nk_vec2 center, float radius, nk_color col, uint segs);
//     void nk_draw_list_fill_poly_convex(nk_draw_list*, const(nk_vec2)* points, const(uint) count, nk_color, nk_anti_aliasing);
//     void nk_draw_list_add_image(nk_draw_list*, nk_image texture, nk_rect rect, nk_color);
//     void nk_draw_list_add_text(nk_draw_list*, const(nk_user_font)*, nk_rect, const(char)* text, int len, float font_height, nk_color);
//     version(NK_INCLUDE_COMMAND_USERDATA) {
//         void nk_draw_list_push_userdata(nk_draw_list*, nk_handle userdata);
//     }
// }
// nk_style_item nk_style_item_image(nk_image img);
// nk_style_item nk_style_item_color(nk_color);
// nk_style_item nk_style_item_nine_slice(nk_nine_slice slice);
// nk_style_item nk_style_item_hide();
