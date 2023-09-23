module nuklear.nuklear_layout;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          LAYOUT
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_draw;

void nk_layout_set_min_row_height(nk_context* ctx, float height)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    layout.row.min_height = height;
}
void nk_layout_reset_min_row_height(nk_context* ctx)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    layout.row.min_height = ctx.style.font.height;
    layout.row.min_height += ctx.style.text.padding.y*2;
    layout.row.min_height += ctx.style.window.min_row_height_padding*2;
}
float nk_layout_row_calculate_usable_space(const(nk_style)* style, nk_panel_type type, float total_space, int columns)
{
    float panel_spacing = void;
    float panel_space = void;

    nk_vec2 spacing = void;

    cast(void)(type);

    spacing = style.window.spacing;

    /* calculate the usable panel space */
    panel_spacing = cast(float)nk_max(columns - 1, 0) * spacing.x;
    panel_space  = total_space - panel_spacing;
    return panel_space;
}
void nk_panel_layout(const(nk_context)* ctx, nk_window* win, float height, int cols)
{
    nk_panel* layout = void;
    const(nk_style)* style = void;
    nk_command_buffer* out_ = void;

    nk_vec2 item_spacing = void;
    nk_color color = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    /* prefetch some configuration data */
    layout = win.layout;
    style = &ctx.style;
    out_ = &win.buffer;
    color = style.window.background;
    item_spacing = style.window.spacing;

    /*  if one of these triggers you forgot to add an `if` condition around either
        a window, group, popup, combobox or contextual menu `begin` and `end` block.
        Example:
            if (nk_begin(...) {...} nk_end(...); or
            if (nk_group_begin(...) { nk_group_end(...);} */
    assert(!(layout.flags & NK_WINDOW_MINIMIZED));
    assert(!(layout.flags & NK_WINDOW_HIDDEN));
    assert(!(layout.flags & NK_WINDOW_CLOSED));

    /* update the current row and set the current row layout */
    layout.row.index = 0;
    layout.at_y += layout.row.height;
    layout.row.columns = cols;
    if (height == 0.0f)
        layout.row.height = nk_max(height, layout.row.min_height) + item_spacing.y;
    else layout.row.height = height + item_spacing.y;

    layout.row.item_offset = 0;
    if (layout.flags & NK_WINDOW_DYNAMIC) {
        /* draw background for dynamic panels */
        nk_rect background = void;
        background.x = win.bounds.x;
        background.w = win.bounds.w;
        background.y = layout.at_y - 1.0f;
        background.h = layout.row.height + 1.0f;
        nk_fill_rect(out_, background, 0, color);
    }
}
void nk_row_layout(nk_context* ctx, nk_layout_format fmt, float height, int cols, int width)
{
    /* update the current row and set the current row layout */
    nk_window* win = void;
    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    nk_panel_layout(ctx, win, height, cols);
    if (fmt == NK_DYNAMIC)
        win.layout.row.type = NK_LAYOUT_DYNAMIC_FIXED;
    else win.layout.row.type = NK_LAYOUT_STATIC_FIXED;

    win.layout.row.ratio = null;
    win.layout.row.filled = 0;
    win.layout.row.item_offset = 0;
    win.layout.row.item_width = cast(float)width;
}
float nk_layout_ratio_from_pixel(nk_context* ctx, float pixel_width)
{
    nk_window* win = void;
    assert(ctx);
    assert(pixel_width);
    if (!ctx || !ctx.current || !ctx.current.layout) return 0;
    win = ctx.current;
    return nk_clamp(0.0f, pixel_width/win.bounds.x, 1.0f);
}
void nk_layout_row_dynamic(nk_context* ctx, float height, int cols)
{
    nk_row_layout(ctx, NK_DYNAMIC, height, cols, 0);
}
void nk_layout_row_static(nk_context* ctx, float height, int item_width, int cols)
{
    nk_row_layout(ctx, NK_STATIC, height, cols, item_width);
}
void nk_layout_row_begin(nk_context* ctx, nk_layout_format fmt, float row_height, int cols)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    nk_panel_layout(ctx, win, row_height, cols);
    if (fmt == NK_DYNAMIC)
        layout.row.type = NK_LAYOUT_DYNAMIC_ROW;
    else layout.row.type = NK_LAYOUT_STATIC_ROW;

    layout.row.ratio = null;
    layout.row.filled = 0;
    layout.row.item_width = 0;
    layout.row.item_offset = 0;
    layout.row.columns = cols;
}
void nk_layout_row_push(nk_context* ctx, float ratio_or_width)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    assert(layout.row.type == NK_LAYOUT_STATIC_ROW || layout.row.type == NK_LAYOUT_DYNAMIC_ROW);
    if (layout.row.type != NK_LAYOUT_STATIC_ROW && layout.row.type != NK_LAYOUT_DYNAMIC_ROW)
        return;

    if (layout.row.type == NK_LAYOUT_DYNAMIC_ROW) {
        float ratio = ratio_or_width;
        if ((ratio + layout.row.filled) > 1.0f) return;
        if (ratio > 0.0f)
            layout.row.item_width = nk_saturate(ratio);
        else layout.row.item_width = 1.0f - layout.row.filled;
    } else layout.row.item_width = ratio_or_width;
}
void nk_layout_row_end(nk_context* ctx)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    assert(layout.row.type == NK_LAYOUT_STATIC_ROW || layout.row.type == NK_LAYOUT_DYNAMIC_ROW);
    if (layout.row.type != NK_LAYOUT_STATIC_ROW && layout.row.type != NK_LAYOUT_DYNAMIC_ROW)
        return;
    layout.row.item_width = 0;
    layout.row.item_offset = 0;
}
void nk_layout_row(nk_context* ctx, nk_layout_format fmt, float height, int cols, const(float)* ratio)
{
    int i = void;
    int n_undef = 0;
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    nk_panel_layout(ctx, win, height, cols);
    if (fmt == NK_DYNAMIC) {
        /* calculate width of undefined widget ratios */
        float r = 0;
        layout.row.ratio = ratio;
        for (i = 0; i < cols; ++i) {
            if (ratio[i] < 0.0f)
                n_undef++;
            else r += ratio[i];
        }
        r = nk_saturate(1.0f - r);
        layout.row.type = NK_LAYOUT_DYNAMIC;
        layout.row.item_width = (r > 0 && n_undef > 0) ? (r / cast(float)n_undef):0;
    } else {
        layout.row.ratio = ratio;
        layout.row.type = NK_LAYOUT_STATIC;
        layout.row.item_width = 0;
        layout.row.item_offset = 0;
    }
    layout.row.item_offset = 0;
    layout.row.filled = 0;
}
void nk_layout_row_template_begin(nk_context* ctx, float height)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    nk_panel_layout(ctx, win, height, 1);
    layout.row.type = NK_LAYOUT_TEMPLATE;
    layout.row.columns = 0;
    layout.row.ratio = null;
    layout.row.item_width = 0;
    layout.row.item_height = 0;
    layout.row.item_offset = 0;
    layout.row.filled = 0;
    layout.row.item.x = 0;
    layout.row.item.y = 0;
    layout.row.item.w = 0;
    layout.row.item.h = 0;
}
void nk_layout_row_template_push_dynamic(nk_context* ctx)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    assert(layout.row.type == NK_LAYOUT_TEMPLATE);
    assert(layout.row.columns < NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS);
    if (layout.row.type != NK_LAYOUT_TEMPLATE) return;
    if (layout.row.columns >= NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS) return;
    layout.row.templates[layout.row.columns++] = -1.0f;
}
void nk_layout_row_template_push_variable(nk_context* ctx, float min_width)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    assert(layout.row.type == NK_LAYOUT_TEMPLATE);
    assert(layout.row.columns < NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS);
    if (layout.row.type != NK_LAYOUT_TEMPLATE) return;
    if (layout.row.columns >= NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS) return;
    layout.row.templates[layout.row.columns++] = -min_width;
}
void nk_layout_row_template_push_static(nk_context* ctx, float width)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    assert(layout.row.type == NK_LAYOUT_TEMPLATE);
    assert(layout.row.columns < NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS);
    if (layout.row.type != NK_LAYOUT_TEMPLATE) return;
    if (layout.row.columns >= NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS) return;
    layout.row.templates[layout.row.columns++] = width;
}
void nk_layout_row_template_end(nk_context* ctx)
{
    nk_window* win = void;
    nk_panel* layout = void;

    int i = 0;
    int variable_count = 0;
    int min_variable_count = 0;
    float min_fixed_width = 0.0f;
    float total_fixed_width = 0.0f;
    float max_variable_width = 0.0f;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    assert(layout.row.type == NK_LAYOUT_TEMPLATE);
    if (layout.row.type != NK_LAYOUT_TEMPLATE) return;
    for (i = 0; i < layout.row.columns; ++i) {
        float width = layout.row.templates[i];
        if (width >= 0.0f) {
            total_fixed_width += width;
            min_fixed_width += width;
        } else if (width < -1.0f) {
            width = -width;
            total_fixed_width += width;
            max_variable_width = nk_max(max_variable_width, width);
            variable_count++;
        } else {
            min_variable_count++;
            variable_count++;
        }
    }
    if (variable_count) {
        float space = nk_layout_row_calculate_usable_space(&ctx.style, layout.type,
                            layout.bounds.w, layout.row.columns);
        float var_width = (nk_max(space-min_fixed_width,0.0f)) / cast(float)variable_count;
        int enough_space = var_width >= max_variable_width;
        if (!enough_space)
            var_width = (nk_max(space-total_fixed_width,0)) / cast(float)min_variable_count;
        for (i = 0; i < layout.row.columns; ++i) {
            float* width = &layout.row.templates[i];
            *width = (*width >= 0.0f)? *width: (*width < -1.0f && !enough_space)? -(*width): var_width;
        }
    }
}
void nk_layout_space_begin(nk_context* ctx, nk_layout_format fmt, float height, int widget_count)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    nk_panel_layout(ctx, win, height, widget_count);
    if (fmt == NK_STATIC)
        layout.row.type = NK_LAYOUT_STATIC_FREE;
    else layout.row.type = NK_LAYOUT_DYNAMIC_FREE;

    layout.row.ratio = null;
    layout.row.filled = 0;
    layout.row.item_width = 0;
    layout.row.item_offset = 0;
}
void nk_layout_space_end(nk_context* ctx)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    layout.row.item_width = 0;
    layout.row.item_height = 0;
    layout.row.item_offset = 0;
    nk_zero(&layout.row.item, typeof(layout.row.item).sizeof);
}
void nk_layout_space_push(nk_context* ctx, nk_rect rect)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = ctx.current;
    layout = win.layout;
    layout.row.item = rect;
}
nk_rect nk_layout_space_bounds(nk_context* ctx)
{
    nk_rect ret = void;
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    win = ctx.current;
    layout = win.layout;

    ret.x = layout.clip.x;
    ret.y = layout.clip.y;
    ret.w = layout.clip.w;
    ret.h = layout.row.height;
    return ret;
}
nk_rect nk_layout_widget_bounds(nk_context* ctx)
{
    nk_rect ret = void;
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    win = ctx.current;
    layout = win.layout;

    ret.x = layout.at_x;
    ret.y = layout.at_y;
    ret.w = layout.bounds.w - nk_max(layout.at_x - layout.bounds.x,0);
    ret.h = layout.row.height;
    return ret;
}
nk_vec2 nk_layout_space_to_screen(nk_context* ctx, nk_vec2 ret)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    win = ctx.current;
    layout = win.layout;

    ret.x += layout.at_x - cast(float)*layout.offset_x;
    ret.y += layout.at_y - cast(float)*layout.offset_y;
    return ret;
}
nk_vec2 nk_layout_space_to_local(nk_context* ctx, nk_vec2 ret)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    win = ctx.current;
    layout = win.layout;

    ret.x += -layout.at_x + cast(float)*layout.offset_x;
    ret.y += -layout.at_y + cast(float)*layout.offset_y;
    return ret;
}
nk_rect nk_layout_space_rect_to_screen(nk_context* ctx, nk_rect ret)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    win = ctx.current;
    layout = win.layout;

    ret.x += layout.at_x - cast(float)*layout.offset_x;
    ret.y += layout.at_y - cast(float)*layout.offset_y;
    return ret;
}
nk_rect nk_layout_space_rect_to_local(nk_context* ctx, nk_rect ret)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    win = ctx.current;
    layout = win.layout;

    ret.x += -layout.at_x + cast(float)*layout.offset_x;
    ret.y += -layout.at_y + cast(float)*layout.offset_y;
    return ret;
}
void nk_panel_alloc_row(const(nk_context)* ctx, nk_window* win)
{
    nk_panel* layout = win.layout;
    nk_vec2 spacing = ctx.style.window.spacing;
    const(float) row_height = layout.row.height - spacing.y;
    nk_panel_layout(ctx, win, row_height, layout.row.columns);
}
void nk_layout_widget_space(nk_rect* bounds, const(nk_context)* ctx, nk_window* win, int modify)
{
    nk_panel* layout = void;
    const(nk_style)* style = void;

    nk_vec2 spacing = void;

    float item_offset = 0;
    float item_width = 0;
    float item_spacing = 0;
    float panel_space = 0;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    win = cast(nk_window*)ctx.current;
    layout = win.layout;
    style = &ctx.style;
    assert(bounds);

    spacing = style.window.spacing;
    panel_space = nk_layout_row_calculate_usable_space(&ctx.style, layout.type,
                                            layout.bounds.w, layout.row.columns);

    /* calculate the width of one item inside the current layout space */
    switch (layout.row.type) {
    case NK_LAYOUT_DYNAMIC_FIXED: {
        /* scaling fixed size widgets item width */
        float w = nk_max(1.0f,panel_space) / cast(float)layout.row.columns;
        item_offset = cast(float)layout.row.index * w;
        item_width = w + nk_frac(item_offset);
        item_spacing = cast(float)layout.row.index * spacing.x;
    } break;
    case NK_LAYOUT_DYNAMIC_ROW: {
        /* scaling single ratio widget width */
        float w = layout.row.item_width * panel_space;
        item_offset = layout.row.item_offset;
        item_width = w + nk_frac(item_offset);
        item_spacing = 0;

        if (modify) {
            layout.row.item_offset += w + spacing.x;
            layout.row.filled += layout.row.item_width;
            layout.row.index = 0;
        }
    } break;
    case NK_LAYOUT_DYNAMIC_FREE: {
        /* panel width depended free widget placing */
        bounds.x = layout.at_x + (layout.bounds.w * layout.row.item.x);
        bounds.x -= cast(float)*layout.offset_x;
        bounds.y = layout.at_y + (layout.row.height * layout.row.item.y);
        bounds.y -= cast(float)*layout.offset_y;
        bounds.w = layout.bounds.w  * layout.row.item.w + nk_frac(bounds.x);
        bounds.h = layout.row.height * layout.row.item.h + nk_frac(bounds.y);
        return;
    }
    case NK_LAYOUT_DYNAMIC: {
        /* scaling arrays of panel width ratios for every widget */
        float ratio = 0, w = 0;
        assert(layout.row.ratio);
        ratio = (layout.row.ratio[layout.row.index] < 0) ?
            layout.row.item_width : layout.row.ratio[layout.row.index];

        w = (ratio * panel_space);
        item_spacing = cast(float)layout.row.index * spacing.x;
        item_offset = layout.row.item_offset;
        item_width = w + nk_frac(item_offset);

        if (modify) {
            layout.row.item_offset += w;
            layout.row.filled += ratio;
        }
    } break;
    case NK_LAYOUT_STATIC_FIXED: {
        /* non-scaling fixed widgets item width */
        item_width = layout.row.item_width;
        item_offset = cast(float)layout.row.index * item_width;
        item_spacing = cast(float)layout.row.index * spacing.x;
    } break;
    case NK_LAYOUT_STATIC_ROW: {
        /* scaling single ratio widget width */
        item_width = layout.row.item_width;
        item_offset = layout.row.item_offset;
        item_spacing = cast(float)layout.row.index * spacing.x;
        if (modify) layout.row.item_offset += item_width;
    } break;
    case NK_LAYOUT_STATIC_FREE: {
        /* free widget placing */
        bounds.x = layout.at_x + layout.row.item.x;
        bounds.w = layout.row.item.w;
        if (((bounds.x + bounds.w) > layout.max_x) && modify)
            layout.max_x = (bounds.x + bounds.w);
        bounds.x -= cast(float)*layout.offset_x;
        bounds.y = layout.at_y + layout.row.item.y;
        bounds.y -= cast(float)*layout.offset_y;
        bounds.h = layout.row.item.h;
        return;
    }
    case NK_LAYOUT_STATIC: {
        /* non-scaling array of panel pixel width for every widget */
        item_spacing = cast(float)layout.row.index * spacing.x;
        item_width = layout.row.ratio[layout.row.index];
        item_offset = layout.row.item_offset;
        if (modify) layout.row.item_offset += item_width;
    } break;
    case NK_LAYOUT_TEMPLATE: {
        /* stretchy row layout with combined dynamic/static widget width*/
        float w = 0;
        assert(layout.row.index < layout.row.columns);
        assert(layout.row.index < NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS);
        w = layout.row.templates[layout.row.index];
        item_offset = layout.row.item_offset;
        item_width = w + nk_frac(item_offset);
        item_spacing = cast(float)layout.row.index * spacing.x;
        if (modify) layout.row.item_offset += w;
    } break;
        default: assert(0);
    }{}

    /* set the bounds of the newly allocated widget */
    bounds.w = item_width;
    bounds.h = layout.row.height - spacing.y;
    bounds.y = layout.at_y - cast(float)*layout.offset_y;
    bounds.x = layout.at_x + item_offset + item_spacing;
    if (((bounds.x + bounds.w) > layout.max_x) && modify)
        layout.max_x = bounds.x + bounds.w;
    bounds.x -= cast(float)*layout.offset_x;
}
void nk_panel_alloc_space(nk_rect* bounds, const(nk_context)* ctx)
{
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout)
        return;

    /* check if the end of the row has been hit and begin new row if so */
    win = cast(nk_window*)ctx.current;
    layout = win.layout;
    if (layout.row.index >= layout.row.columns)
        nk_panel_alloc_row(ctx, win);

    /* calculate widget position and size */
    nk_layout_widget_space(bounds, ctx, win, nk_true);
    layout.row.index++;
}
void nk_layout_peek(nk_rect* bounds, nk_context* ctx)
{
    float y = void;
    int index = void;
    nk_window* win = void;
    nk_panel* layout = void;

    assert(ctx);
    assert(ctx.current);
    assert(ctx.current.layout);
    if (!ctx || !ctx.current || !ctx.current.layout) {
        *bounds = nk_rect(0,0,0,0);
        return;
    }

    win = ctx.current;
    layout = win.layout;
    y = layout.at_y;
    index = layout.row.index;
    if (layout.row.index >= layout.row.columns) {
        layout.at_y += layout.row.height;
        layout.row.index = 0;
    }
    nk_layout_widget_space(bounds, ctx, win, nk_false);
    if (!layout.row.index) {
        bounds.x -= layout.row.item_offset;
    }
    layout.at_y = y;
    layout.row.index = index;
}
void nk_spacer(nk_context* ctx)
{
    nk_rect dummy_rect = { 0, 0, 0, 0 };
    nk_panel_alloc_space( &dummy_rect, ctx );
}

