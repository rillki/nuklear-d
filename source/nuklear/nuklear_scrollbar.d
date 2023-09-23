module nuklear.nuklear_scrollbar;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              SCROLLBAR
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;

float nk_scrollbar_behavior(nk_flags* state, nk_input* in_, int has_scrolling, const(nk_rect)* scroll, const(nk_rect)* cursor, const(nk_rect)* empty0, const(nk_rect)* empty1, float scroll_offset, float target, float scroll_step, nk_orientation o)
{
    nk_flags ws = 0;
    int left_mouse_down = void;
    uint left_mouse_clicked = void;
    int left_mouse_click_in_cursor = void;
    float scroll_delta = void;

    nk_widget_state_reset(state);
    if (!in_) return scroll_offset;

    left_mouse_down = in_.mouse.buttons[NK_BUTTON_LEFT].down;
    left_mouse_clicked = in_.mouse.buttons[NK_BUTTON_LEFT].clicked;
    left_mouse_click_in_cursor = nk_input_has_mouse_click_down_in_rect(in_,
        NK_BUTTON_LEFT, *cursor, nk_true);
    if (nk_input_is_mouse_hovering_rect(in_, *scroll))
        *state = NK_WIDGET_STATE_HOVERED;

    scroll_delta = (o == NK_VERTICAL) ? in_.mouse.scroll_delta.y: in_.mouse.scroll_delta.x;
    if (left_mouse_down && left_mouse_click_in_cursor && !left_mouse_clicked) {
        /* update cursor by mouse dragging */
        float pixel = void, delta = void;
        *state = NK_WIDGET_STATE_ACTIVE;
        if (o == NK_VERTICAL) {
            float cursor_y = void;
            pixel = in_.mouse.delta.y;
            delta = (pixel / scroll.h) * target;
            scroll_offset = nk_clamp(0, scroll_offset + delta, target - scroll.h);
            cursor_y = scroll.y + ((scroll_offset/target) * scroll.h);
            in_.mouse.buttons[NK_BUTTON_LEFT].clicked_pos.y = cursor_y + cursor.h/2.0f;
        } else {
            float cursor_x = void;
            pixel = in_.mouse.delta.x;
            delta = (pixel / scroll.w) * target;
            scroll_offset = nk_clamp(0, scroll_offset + delta, target - scroll.w);
            cursor_x = scroll.x + ((scroll_offset/target) * scroll.w);
            in_.mouse.buttons[NK_BUTTON_LEFT].clicked_pos.x = cursor_x + cursor.w/2.0f;
        }
    } else if ((nk_input_is_key_pressed(in_, NK_KEY_SCROLL_UP) && o == NK_VERTICAL && has_scrolling)||
            nk_button_behavior(&ws, *empty0, in_, NK_BUTTON_DEFAULT)) {
        /* scroll page up by click on empty space or shortcut */
        if (o == NK_VERTICAL)
            scroll_offset = nk_max(0, scroll_offset - scroll.h);
        else scroll_offset = nk_max(0, scroll_offset - scroll.w);
    } else if ((nk_input_is_key_pressed(in_, NK_KEY_SCROLL_DOWN) && o == NK_VERTICAL && has_scrolling) ||
        nk_button_behavior(&ws, *empty1, in_, NK_BUTTON_DEFAULT)) {
        /* scroll page down by click on empty space or shortcut */
        if (o == NK_VERTICAL)
            scroll_offset = nk_min(scroll_offset + scroll.h, target - scroll.h);
        else scroll_offset = nk_min(scroll_offset + scroll.w, target - scroll.w);
    } else if (has_scrolling) {
        if ((scroll_delta < 0 || (scroll_delta > 0))) {
            /* update cursor by mouse scrolling */
            scroll_offset = scroll_offset + scroll_step * (-scroll_delta);
            if (o == NK_VERTICAL)
                scroll_offset = nk_clamp(0, scroll_offset, target - scroll.h);
            else scroll_offset = nk_clamp(0, scroll_offset, target - scroll.w);
        } else if (nk_input_is_key_pressed(in_, NK_KEY_SCROLL_START)) {
            /* update cursor to the beginning  */
            if (o == NK_VERTICAL) scroll_offset = 0;
        } else if (nk_input_is_key_pressed(in_, NK_KEY_SCROLL_END)) {
            /* update cursor to the end */
            if (o == NK_VERTICAL) scroll_offset = target - scroll.h;
        }
    }
    if (*state & NK_WIDGET_STATE_HOVER && !nk_input_is_mouse_prev_hovering_rect(in_, *scroll))
        *state |= NK_WIDGET_STATE_ENTERED;
    else if (nk_input_is_mouse_prev_hovering_rect(in_, *scroll))
        *state |= NK_WIDGET_STATE_LEFT;
    return scroll_offset;
}
void nk_draw_scrollbar(nk_command_buffer* out_, nk_flags state, const(nk_style_scrollbar)* style, const(nk_rect)* bounds, const(nk_rect)* scroll)
{
    const(nk_style_item)* background = void;
    const(nk_style_item)* cursor = void;

    /* select correct colors/images to draw */
    if (state & NK_WIDGET_STATE_ACTIVED) {
        background = &style.active;
        cursor = &style.cursor_active;
    } else if (state & NK_WIDGET_STATE_HOVER) {
        background = &style.hover;
        cursor = &style.cursor_hover;
    } else {
        background = &style.normal;
        cursor = &style.cursor_normal;
    }

    /* draw background */
    switch (background.type) {
        case NK_STYLE_ITEM_IMAGE:
            nk_draw_image(out_, *bounds, &background.data.image, nk_white);
            break;
        case NK_STYLE_ITEM_NINE_SLICE:
            nk_draw_nine_slice(out_, *bounds, &background.data.slice, nk_white);
            break;
        case NK_STYLE_ITEM_COLOR:
            nk_fill_rect(out_, *bounds, style.rounding, background.data.color);
            nk_stroke_rect(out_, *bounds, style.rounding, style.border, style.border_color);
            break;
    default: break;}

    /* draw cursor */
    switch (cursor.type) {
        case NK_STYLE_ITEM_IMAGE:
            nk_draw_image(out_, *scroll, &cursor.data.image, nk_white);
            break;
        case NK_STYLE_ITEM_NINE_SLICE:
            nk_draw_nine_slice(out_, *scroll, &cursor.data.slice, nk_white);
            break;
        case NK_STYLE_ITEM_COLOR:
            nk_fill_rect(out_, *scroll, style.rounding_cursor, cursor.data.color);
            nk_stroke_rect(out_, *scroll, style.rounding_cursor, style.border_cursor, style.cursor_border_color);
            break;
    default: break;}
}
float nk_do_scrollbarv(nk_flags* state, nk_command_buffer* out_, nk_rect scroll, int has_scrolling, float offset, float target, float step, float button_pixel_inc, const(nk_style_scrollbar)* style, nk_input* in_, const(nk_user_font)* font)
{
    nk_rect empty_north = void;
    nk_rect empty_south = void;
    nk_rect cursor = void;

    float scroll_step = void;
    float scroll_offset = void;
    float scroll_off = void;
    float scroll_ratio = void;

    assert(out_);
    assert(style);
    assert(state);
    if (!out_ || !style) return 0;

    scroll.w = nk_max(scroll.w, 1);
    scroll.h = nk_max(scroll.h, 0);
    if (target <= scroll.h) return 0;

    /* optional scrollbar buttons */
    if (style.show_buttons) {
        nk_flags ws = void;
        float scroll_h = void;
        nk_rect button = void;

        button.x = scroll.x;
        button.w = scroll.w;
        button.h = scroll.w;

        scroll_h = nk_max(scroll.h - 2 * button.h,0);
        scroll_step = nk_min(step, button_pixel_inc);

        /* decrement button */
        button.y = scroll.y;
        if (nk_do_button_symbol(&ws, out_, button, style.dec_symbol,
            NK_BUTTON_REPEATER, &style.dec_button, in_, font))
            offset = offset - scroll_step;

        /* increment button */
        button.y = scroll.y + scroll.h - button.h;
        if (nk_do_button_symbol(&ws, out_, button, style.inc_symbol,
            NK_BUTTON_REPEATER, &style.inc_button, in_, font))
            offset = offset + scroll_step;

        scroll.y = scroll.y + button.h;
        scroll.h = scroll_h;
    }

    /* calculate scrollbar constants */
    scroll_step = nk_min(step, scroll.h);
    scroll_offset = nk_clamp(0, offset, target - scroll.h);
    scroll_ratio = scroll.h / target;
    scroll_off = scroll_offset / target;

    /* calculate scrollbar cursor bounds */
    cursor.h = nk_max((scroll_ratio * scroll.h) - (2*style.border + 2*style.padding.y), 0);
    cursor.y = scroll.y + (scroll_off * scroll.h) + style.border + style.padding.y;
    cursor.w = scroll.w - (2 * style.border + 2 * style.padding.x);
    cursor.x = scroll.x + style.border + style.padding.x;

    /* calculate empty space around cursor */
    empty_north.x = scroll.x;
    empty_north.y = scroll.y;
    empty_north.w = scroll.w;
    empty_north.h = nk_max(cursor.y - scroll.y, 0);

    empty_south.x = scroll.x;
    empty_south.y = cursor.y + cursor.h;
    empty_south.w = scroll.w;
    empty_south.h = nk_max((scroll.y + scroll.h) - (cursor.y + cursor.h), 0);

    /* update scrollbar */
    scroll_offset = nk_scrollbar_behavior(state, in_, has_scrolling, &scroll, &cursor,
        &empty_north, &empty_south, scroll_offset, target, scroll_step, NK_VERTICAL);
    scroll_off = scroll_offset / target;
    cursor.y = scroll.y + (scroll_off * scroll.h) + style.border_cursor + style.padding.y;

    /* draw scrollbar */
    if (style.draw_begin) style.draw_begin(out_, style.userdata);
    nk_draw_scrollbar(out_, *state, style, &scroll, &cursor);
    if (style.draw_end) style.draw_end(out_, style.userdata);
    return scroll_offset;
}
float nk_do_scrollbarh(nk_flags* state, nk_command_buffer* out_, nk_rect scroll, int has_scrolling, float offset, float target, float step, float button_pixel_inc, const(nk_style_scrollbar)* style, nk_input* in_, const(nk_user_font)* font)
{
    nk_rect cursor = void;
    nk_rect empty_west = void;
    nk_rect empty_east = void;

    float scroll_step = void;
    float scroll_offset = void;
    float scroll_off = void;
    float scroll_ratio = void;

    assert(out_);
    assert(style);
    if (!out_ || !style) return 0;

    /* scrollbar background */
    scroll.h = nk_max(scroll.h, 1);
    scroll.w = nk_max(scroll.w, 2 * scroll.h);
    if (target <= scroll.w) return 0;

    /* optional scrollbar buttons */
    if (style.show_buttons) {
        nk_flags ws = void;
        float scroll_w = void;
        nk_rect button = void;
        button.y = scroll.y;
        button.w = scroll.h;
        button.h = scroll.h;

        scroll_w = scroll.w - 2 * button.w;
        scroll_step = nk_min(step, button_pixel_inc);

        /* decrement button */
        button.x = scroll.x;
        if (nk_do_button_symbol(&ws, out_, button, style.dec_symbol,
            NK_BUTTON_REPEATER, &style.dec_button, in_, font))
            offset = offset - scroll_step;

        /* increment button */
        button.x = scroll.x + scroll.w - button.w;
        if (nk_do_button_symbol(&ws, out_, button, style.inc_symbol,
            NK_BUTTON_REPEATER, &style.inc_button, in_, font))
            offset = offset + scroll_step;

        scroll.x = scroll.x + button.w;
        scroll.w = scroll_w;
    }

    /* calculate scrollbar constants */
    scroll_step = nk_min(step, scroll.w);
    scroll_offset = nk_clamp(0, offset, target - scroll.w);
    scroll_ratio = scroll.w / target;
    scroll_off = scroll_offset / target;

    /* calculate cursor bounds */
    cursor.w = (scroll_ratio * scroll.w) - (2*style.border + 2*style.padding.x);
    cursor.x = scroll.x + (scroll_off * scroll.w) + style.border + style.padding.x;
    cursor.h = scroll.h - (2 * style.border + 2 * style.padding.y);
    cursor.y = scroll.y + style.border + style.padding.y;

    /* calculate empty space around cursor */
    empty_west.x = scroll.x;
    empty_west.y = scroll.y;
    empty_west.w = cursor.x - scroll.x;
    empty_west.h = scroll.h;

    empty_east.x = cursor.x + cursor.w;
    empty_east.y = scroll.y;
    empty_east.w = (scroll.x + scroll.w) - (cursor.x + cursor.w);
    empty_east.h = scroll.h;

    /* update scrollbar */
    scroll_offset = nk_scrollbar_behavior(state, in_, has_scrolling, &scroll, &cursor,
        &empty_west, &empty_east, scroll_offset, target, scroll_step, NK_HORIZONTAL);
    scroll_off = scroll_offset / target;
    cursor.x = scroll.x + (scroll_off * scroll.w);

    /* draw scrollbar */
    if (style.draw_begin) style.draw_begin(out_, style.userdata);
    nk_draw_scrollbar(out_, *state, style, &scroll, &cursor);
    if (style.draw_end) style.draw_end(out_, style.userdata);
    return scroll_offset;
}

