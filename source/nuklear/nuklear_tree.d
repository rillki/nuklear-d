module nuklear.nuklear_tree;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              TREE
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

int nk_tree_state_base(nk_context* ctx, nk_tree_type type, nk_image* img, const(char)* title, nk_collapse_states* state)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_style)* style = void;
    nk_command_buffer* out_ = void;
    const(nk_input)* in_ = void;
    const(nk_style_button)* button = void;
    nk_symbol_type symbol = void;
    float row_height = void;

    nk_vec2 item_spacing = void;
    nk_rect header = {0,0,0,0};
    nk_rect sym = {0,0,0,0};
    nk_text text = void;

    nk_flags ws = 0;
    nk_widget_layout_states widget_state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    /* cache some data */
    win = ctx.current;
    layout = win.layout;
    out_ = &win.buffer;
    style = &ctx.style;
    item_spacing = style.window.spacing;

    /* calculate header bounds and draw background */
    row_height = style.font.height + 2 * style.tab.padding.y;
    nk_layout_set_min_row_height(ctx, row_height);
    nk_layout_row_dynamic(ctx, row_height, 1);
    nk_layout_reset_min_row_height(ctx);

    widget_state = nk_widget(&header, ctx);
    if (type == NK_TREE_TAB) {
        const(nk_style_item)* background = &style.tab.background;

        switch(background.type) {
            case NK_STYLE_ITEM_IMAGE:
                nk_draw_image(out_, header, &background.data.image, nk_white);
                break;
            case NK_STYLE_ITEM_NINE_SLICE:
                nk_draw_nine_slice(out_, header, &background.data.slice, nk_white);
                break;
            case NK_STYLE_ITEM_COLOR:
                nk_fill_rect(out_, header, 0, style.tab.border_color);
                nk_fill_rect(out_, nk_shrink_rect(header, style.tab.border),
                    style.tab.rounding, background.data.color);
                break;
        default: break;}
    } else text.background = style.window.background;

    /* update node state */
    in_ = (!(layout.flags & NK_WINDOW_ROM)) ? &ctx.input: 0;
    in_ = (in_ && widget_state == NK_WIDGET_VALID) ? &ctx.input : 0;
    if (nk_button_behavior(&ws, header, in_, NK_BUTTON_DEFAULT))
        *state = (*state == NK_MAXIMIZED) ? NK_MINIMIZED : NK_MAXIMIZED;

    /* select correct button style */
    if (*state == NK_MAXIMIZED) {
        symbol = style.tab.sym_maximize;
        if (type == NK_TREE_TAB)
            button = &style.tab.tab_maximize_button;
        else button = &style.tab.node_maximize_button;
    } else {
        symbol = style.tab.sym_minimize;
        if (type == NK_TREE_TAB)
            button = &style.tab.tab_minimize_button;
        else button = &style.tab.node_minimize_button;
    }

    {/* draw triangle button */
    sym.w = sym.h = style.font.height;
    sym.y = header.y + style.tab.padding.y;
    sym.x = header.x + style.tab.padding.x;
    nk_do_button_symbol(&ws, &win.buffer, sym, symbol, NK_BUTTON_DEFAULT,
        button, 0, style.font);

    if (img) {
        /* draw optional image icon */
        sym.x = sym.x + sym.w + 4 * item_spacing.x;
        nk_draw_image(&win.buffer, sym, img, nk_white);
        sym.w = style.font.height + style.tab.spacing.x;}
    }

    {/* draw label */
    nk_rect label = void;
    header.w = nk_max(header.w, sym.w + item_spacing.x);
    label.x = sym.x + sym.w + item_spacing.x;
    label.y = sym.y;
    label.w = header.w - (sym.w + item_spacing.y + style.tab.indent);
    label.h = style.font.height;
    text.text = style.tab.text;
    text.padding = nk_vec2(0,0);
    nk_widget_text(out_, label, title, nk_strlen(title), &text,
        NK_TEXT_LEFT, style.font);}

    /* increase x-axis cursor widget position pointer */
    if (*state == NK_MAXIMIZED) {
        layout.at_x = header.x + cast(float)*layout.offset_x + style.tab.indent;
        layout.bounds.w = nk_max(layout.bounds.w, style.tab.indent);
        layout.bounds.w -= (style.tab.indent + style.window.padding.x);
        layout.row.tree_depth++;
        return nk_true;
    } else return nk_false;
}
int nk_tree_base(nk_context* ctx, nk_tree_type type, nk_image* img, const(char)* title, nk_collapse_states initial_state, const(char)* hash, int len, int line)
{
    nk_window* win = ctx.current;
    int title_len = 0;
    nk_hash tree_hash = 0;
    nk_uint* state = null;

    /* retrieve tree state from internal widget state tables */
    if (!hash) {
        title_len = cast(int)nk_strlen(title);
        tree_hash = nk_murmur_hash(title, cast(int)title_len, cast(nk_hash)line);
    } else tree_hash = nk_murmur_hash(hash, len, cast(nk_hash)line);
    state = nk_find_value(win, tree_hash);
    if (!state) {
        state = nk_add_value(ctx, win, tree_hash, 0);
        *state = initial_state;
    }
    return nk_tree_state_base(ctx, type, img, title, cast(nk_collapse_states*)state);
}
nk_bool nk_tree_state_push(nk_context* ctx, nk_tree_type type, const(char)* title, nk_collapse_states* state)
{
    return nk_tree_state_base(ctx, type, 0, title, state);
}
nk_bool nk_tree_state_image_push(nk_context* ctx, nk_tree_type type, nk_image img, const(char)* title, nk_collapse_states* state)
{
    return nk_tree_state_base(ctx, type, &img, title, state);
}
void nk_tree_state_pop(nk_context* ctx)
{
    nk_window* win = null;
    nk_panel* layout = null;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    layout.at_x -= ctx.style.tab.indent + cast(float)*layout.offset_x;
    layout.bounds.w += ctx.style.tab.indent + ctx.style.window.padding.x;
    assert(layout.row.tree_depth);
    layout.row.tree_depth--;
}
nk_bool nk_tree_push_hashed(nk_context* ctx, nk_tree_type type, const(char)* title, nk_collapse_states initial_state, const(char)* hash, int len, int line)
{
    return nk_tree_base(ctx, type, 0, title, initial_state, hash, len, line);
}
nk_bool nk_tree_image_push_hashed(nk_context* ctx, nk_tree_type type, nk_image img, const(char)* title, nk_collapse_states initial_state, const(char)* hash, int len, int seed)
{
    return nk_tree_base(ctx, type, &img, title, initial_state, hash, len, seed);
}
void nk_tree_pop(nk_context* ctx)
{
    nk_tree_state_pop(ctx);
}
int nk_tree_element_image_push_hashed_base(nk_context* ctx, nk_tree_type type, nk_image* img, const(char)* title, int title_len, nk_collapse_states* state, nk_bool* selected)
{
    nk_window* win = void;
    nk_panel* layout = void;
    const(nk_style)* style = void;
    nk_command_buffer* out_ = void;
    const(nk_input)* in_ = void;
    const(nk_style_button)* button = void;
    nk_symbol_type symbol = void;
    float row_height = void;
    nk_vec2 padding = void;

    int text_len = void;
    float text_width = void;

    nk_vec2 item_spacing = void;
    nk_rect header = {0,0,0,0};
    nk_rect sym = {0,0,0,0};

    nk_flags ws = 0;
    nk_widget_layout_states widget_state = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return 0;

    /* cache some data */
    win = ctx.current;
    layout = win.layout;
    out_ = &win.buffer;
    style = &ctx.style;
    item_spacing = style.window.spacing;
    padding = style.selectable.padding;

    /* calculate header bounds and draw background */
    row_height = style.font.height + 2 * style.tab.padding.y;
    nk_layout_set_min_row_height(ctx, row_height);
    nk_layout_row_dynamic(ctx, row_height, 1);
    nk_layout_reset_min_row_height(ctx);

    widget_state = nk_widget(&header, ctx);
    if (type == NK_TREE_TAB) {
        const(nk_style_item)* background = &style.tab.background;

        switch (background.type) {
            case NK_STYLE_ITEM_IMAGE:
                nk_draw_image(out_, header, &background.data.image, nk_white);
                break;
            case NK_STYLE_ITEM_NINE_SLICE:
                nk_draw_nine_slice(out_, header, &background.data.slice, nk_white);
                break;
            case NK_STYLE_ITEM_COLOR:
                nk_fill_rect(out_, header, 0, style.tab.border_color);
                nk_fill_rect(out_, nk_shrink_rect(header, style.tab.border),
                    style.tab.rounding, background.data.color);
                break;
        default: break;}
    }

    in_ = (!(layout.flags & NK_WINDOW_ROM)) ? &ctx.input: 0;
    in_ = (in_ && widget_state == NK_WIDGET_VALID) ? &ctx.input : 0;

    /* select correct button style */
    if (*state == NK_MAXIMIZED) {
        symbol = style.tab.sym_maximize;
        if (type == NK_TREE_TAB)
            button = &style.tab.tab_maximize_button;
        else button = &style.tab.node_maximize_button;
    } else {
        symbol = style.tab.sym_minimize;
        if (type == NK_TREE_TAB)
            button = &style.tab.tab_minimize_button;
        else button = &style.tab.node_minimize_button;
    }
    {/* draw triangle button */
    sym.w = sym.h = style.font.height;
    sym.y = header.y + style.tab.padding.y;
    sym.x = header.x + style.tab.padding.x;
    if (nk_do_button_symbol(&ws, &win.buffer, sym, symbol, NK_BUTTON_DEFAULT, button, in_, style.font))
        *state = (*state == NK_MAXIMIZED) ? NK_MINIMIZED : NK_MAXIMIZED;}

    /* draw label */
    {nk_flags dummy = 0;
    nk_rect label = void;
    /* calculate size of the text and tooltip */
    text_len = nk_strlen(title);
    text_width = style.font.width(style.font.userdata, style.font.height, title, text_len);
    text_width += (4 * padding.x);

    header.w = nk_max(header.w, sym.w + item_spacing.x);
    label.x = sym.x + sym.w + item_spacing.x;
    label.y = sym.y;
    label.w = nk_min(header.w - (sym.w + item_spacing.y + style.tab.indent), text_width);
    label.h = style.font.height;

    if (img) {
        nk_do_selectable_image(&dummy, &win.buffer, label, title, title_len, NK_TEXT_LEFT,
            selected, img, &style.selectable, in_, style.font);
    } else nk_do_selectable(&dummy, &win.buffer, label, title, title_len, NK_TEXT_LEFT,
            selected, &style.selectable, in_, style.font);
    }
    /* increase x-axis cursor widget position pointer */
    if (*state == NK_MAXIMIZED) {
        layout.at_x = header.x + cast(float)*layout.offset_x + style.tab.indent;
        layout.bounds.w = nk_max(layout.bounds.w, style.tab.indent);
        layout.bounds.w -= (style.tab.indent + style.window.padding.x);
        layout.row.tree_depth++;
        return nk_true;
    } else return nk_false;
}
int nk_tree_element_base(nk_context* ctx, nk_tree_type type, nk_image* img, const(char)* title, nk_collapse_states initial_state, nk_bool* selected, const(char)* hash, int len, int line)
{
    nk_window* win = ctx.current;
    int title_len = 0;
    nk_hash tree_hash = 0;
    nk_uint* state = null;

    /* retrieve tree state from internal widget state tables */
    if (!hash) {
        title_len = cast(int)nk_strlen(title);
        tree_hash = nk_murmur_hash(title, cast(int)title_len, cast(nk_hash)line);
    } else tree_hash = nk_murmur_hash(hash, len, cast(nk_hash)line);
    state = nk_find_value(win, tree_hash);
    if (!state) {
        state = nk_add_value(ctx, win, tree_hash, 0);
        *state = initial_state;
    } return nk_tree_element_image_push_hashed_base(ctx, type, img, title,
        nk_strlen(title), cast(nk_collapse_states*)state, selected);
}
nk_bool nk_tree_element_push_hashed(nk_context* ctx, nk_tree_type type, const(char)* title, nk_collapse_states initial_state, nk_bool* selected, const(char)* hash, int len, int seed)
{
    return nk_tree_element_base(ctx, type, 0, title, initial_state, selected, hash, len, seed);
}
nk_bool nk_tree_element_image_push_hashed(nk_context* ctx, nk_tree_type type, nk_image img, const(char)* title, nk_collapse_states initial_state, nk_bool* selected, const(char)* hash, int len, int seed)
{
    return nk_tree_element_base(ctx, type, &img, title, initial_state, selected, hash, len, seed);
}
void nk_tree_element_pop(nk_context* ctx)
{
    nk_tree_state_pop(ctx);
}

