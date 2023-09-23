module nuklear.nuklear_text_editor;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                          TEXT EDITOR
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_string;
import nuklear.nuklear_text_editor;
import nuklear.nuklear_utf8;

/* stb_textedit.h - v1.8  - public domain - Sean Barrett */
struct nk_text_find {
   float x = 0, y = 0;    /* position of n'th character */
   float height = 0; /* height of line */
   int first_char, length; /* first char of row, and length */
   int prev_first;  /*_ first char of previous row */
}

struct nk_text_edit_row {
   float x0 = 0, x1 = 0;
   /* starting x location, end x location (allows for align=right, etc) */
   float baseline_y_delta = 0;
   /* position of baseline relative to previous row's baseline*/
   float ymin = 0, ymax = 0;
   /* height of row above and below baseline */
   int num_chars;
}

auto NK_TEXT_HAS_SELECTION(S)(S s) { return (s.select_start != s.select_end); }

float nk_textedit_get_width(const(nk_text_edit)* edit, int line_start, int char_id, const(nk_user_font)* font)
{
    int len = 0;
    nk_rune unicode = 0;
    const(char)* str = nk_str_at_const(&edit.string, line_start + char_id, &unicode, &len);
    return font.width(cast(nk_handle)font.userdata, font.height, str, len);
}
void nk_textedit_layout_row(nk_text_edit_row* r, nk_text_edit* edit, int line_start_id, float row_height, const(nk_user_font)* font)
{
    int l = void;
    int glyphs = 0;
    nk_rune unicode = void;
    const(char)* remaining = void;
    int len = nk_str_len_char(&edit.string);
    const(char)* end = nk_str_get_const(&edit.string) + len;
    const(char)* text = nk_str_at_const(&edit.string, line_start_id, &unicode, &l);
    const(nk_vec2) size = nk_text_calculate_text_bounds(font,
        text, cast(int)(end - text), row_height, &remaining, null, &glyphs, NK_STOP_ON_NEW_LINE);

    r.x0 = 0.0f;
    r.x1 = size.x;
    r.baseline_y_delta = size.y;
    r.ymin = 0.0f;
    r.ymax = size.y;
    r.num_chars = glyphs;
}
int nk_textedit_locate_coord(nk_text_edit* edit, float x, float y, const(nk_user_font)* font, float row_height)
{
    nk_text_edit_row r = void;
    int n = edit.string.len;
    float base_y = 0, prev_x = void;
    int i = 0, k = void;

    r.x0 = r.x1 = 0;
    r.ymin = r.ymax = 0;
    r.num_chars = 0;

    /* search rows to find one that straddles 'y' */
    while (i < n) {
        nk_textedit_layout_row(&r, edit, i, row_height, font);
        if (r.num_chars <= 0)
            return n;

        if (i==0 && y < base_y + r.ymin)
            return 0;

        if (y < base_y + r.ymax)
            break;

        i += r.num_chars;
        base_y += r.baseline_y_delta;
    }

    /* below all text, return 'after' last character */
    if (i >= n)
        return n;

    /* check if it's before the beginning of the line */
    if (x < r.x0)
        return i;

    /* check if it's before the end of the line */
    if (x < r.x1) {
        /* search characters in row for one that straddles 'x' */
        k = i;
        prev_x = r.x0;
        for (i=0; i < r.num_chars; ++i) {
            float w = nk_textedit_get_width(edit, k, i, font);
            if (x < prev_x+w) {
                if (x < prev_x+w/2)
                    return k+i;
                else return k+i+1;
            }
            prev_x += w;
        }
        /* shouldn't happen, but if it does, fall through to end-of-line case */
    }

    /* if the last character is a newline, return that.
     * otherwise return 'after' the last character */
    if (nk_str_rune_at(&edit.string, i+r.num_chars-1) == '\n')
        return i+r.num_chars-1;
    else return i+r.num_chars;
}
void nk_textedit_click(nk_text_edit* state, float x, float y, const(nk_user_font)* font, float row_height)
{
    /* API click: on mouse down, move the cursor to the clicked location,
     * and reset the selection */
    state.cursor = nk_textedit_locate_coord(state, x, y, font, row_height);
    state.select_start = state.cursor;
    state.select_end = state.cursor;
    state.has_preferred_x = 0;
}
void nk_textedit_drag(nk_text_edit* state, float x, float y, const(nk_user_font)* font, float row_height)
{
    /* API drag: on mouse drag, move the cursor and selection endpoint
     * to the clicked location */
    int p = nk_textedit_locate_coord(state, x, y, font, row_height);
    if (state.select_start == state.select_end)
        state.select_start = state.cursor;
    state.cursor = state.select_end = p;
}
void nk_textedit_find_charpos(nk_text_find* find, nk_text_edit* state, int n, int single_line, const(nk_user_font)* font, float row_height)
{
    /* find the x/y location of a character, and remember info about the previous
     * row in case we get a move-up event (for page up, we'll have to rescan) */
    nk_text_edit_row r = void;
    int prev_start = 0;
    int z = state.string.len;
    int i = 0, first = void;

    nk_zero_struct(r);
    if (n == z) {
        /* if it's at the end, then find the last line -- simpler than trying to
        explicitly handle this case in the regular code */
        nk_textedit_layout_row(&r, state, 0, row_height, font);
        if (single_line) {
            find.first_char = 0;
            find.length = z;
        } else {
            while (i < z) {
                prev_start = i;
                i += r.num_chars;
                nk_textedit_layout_row(&r, state, i, row_height, font);
            }

            find.first_char = i;
            find.length = r.num_chars;
        }
        find.x = r.x1;
        find.y = r.ymin;
        find.height = r.ymax - r.ymin;
        find.prev_first = prev_start;
        return;
    }

    /* search rows to find the one that straddles character n */
    find.y = 0;

    for(;;) {
        nk_textedit_layout_row(&r, state, i, row_height, font);
        if (n < i + r.num_chars) break;
        prev_start = i;
        i += r.num_chars;
        find.y += r.baseline_y_delta;
    }

    find.first_char = first = i;
    find.length = r.num_chars;
    find.height = r.ymax - r.ymin;
    find.prev_first = prev_start;

    /* now scan to find xpos */
    find.x = r.x0;
    for (i=0; first+i < n; ++i)
        find.x += nk_textedit_get_width(state, first, i, font);
}
void nk_textedit_clamp(nk_text_edit* state)
{
    /* make the selection/cursor state valid if client altered the string */
    int n = state.string.len;
    if (NK_TEXT_HAS_SELECTION(state)) {
        if (state.select_start > n) state.select_start = n;
        if (state.select_end   > n) state.select_end = n;
        /* if clamping forced them to be equal, move the cursor to match */
        if (state.select_start == state.select_end)
            state.cursor = state.select_start;
    }
    if (state.cursor > n) state.cursor = n;
}
void nk_textedit_delete(nk_text_edit* state, int where, int len)
{
    /* delete characters while updating undo */
    nk_textedit_makeundo_delete(state, where, len);
    nk_str_delete_runes(&state.string, where, len);
    state.has_preferred_x = 0;
}
void nk_textedit_delete_selection(nk_text_edit* state)
{
    /* delete the section */
    nk_textedit_clamp(state);
    if (NK_TEXT_HAS_SELECTION(state)) {
        if (state.select_start < state.select_end) {
            nk_textedit_delete(state, state.select_start,
                state.select_end - state.select_start);
            state.select_end = state.cursor = state.select_start;
        } else {
            nk_textedit_delete(state, state.select_end,
                state.select_start - state.select_end);
            state.select_start = state.cursor = state.select_end;
        }
        state.has_preferred_x = 0;
    }
}
void nk_textedit_sortselection(nk_text_edit* state)
{
    /* canonicalize the selection so start <= end */
    if (state.select_end < state.select_start) {
        int temp = state.select_end;
        state.select_end = state.select_start;
        state.select_start = temp;
    }
}
void nk_textedit_move_to_first(nk_text_edit* state)
{
    /* move cursor to first character of selection */
    if (NK_TEXT_HAS_SELECTION(state)) {
        nk_textedit_sortselection(state);
        state.cursor = state.select_start;
        state.select_end = state.select_start;
        state.has_preferred_x = 0;
    }
}
void nk_textedit_move_to_last(nk_text_edit* state)
{
    /* move cursor to last character of selection */
    if (NK_TEXT_HAS_SELECTION(state)) {
        nk_textedit_sortselection(state);
        nk_textedit_clamp(state);
        state.cursor = state.select_end;
        state.select_start = state.select_end;
        state.has_preferred_x = 0;
    }
}
int nk_is_word_boundary(nk_text_edit* state, int idx)
{
    int len = void;
    nk_rune c = void;
    if (idx <= 0) return 1;
    if (!nk_str_at_rune(&state.string, idx, &c, &len)) return 1;
    return (c == ' ' || c == '\t' ||c == 0x3000 || c == ',' || c == ';' ||
            c == '(' || c == ')' || c == '{' || c == '}' || c == '[' || c == ']' ||
            c == '|');
}
int nk_textedit_move_to_word_previous(nk_text_edit* state)
{
   int c = state.cursor - 1;
   while( c >= 0 && !nk_is_word_boundary(state, c))
      --c;

   if( c < 0 )
      c = 0;

   return c;
}
int nk_textedit_move_to_word_next(nk_text_edit* state)
{
   const(int) len = state.string.len;
   int c = state.cursor+1;
   while( c < len && !nk_is_word_boundary(state, c))
      ++c;

   if( c > len )
      c = len;

   return c;
}
void nk_textedit_prep_selection_at_cursor(nk_text_edit* state)
{
    /* update selection and cursor to match each other */
    if (!NK_TEXT_HAS_SELECTION(state))
        state.select_start = state.select_end = state.cursor;
    else state.cursor = state.select_end;
}
nk_bool nk_textedit_cut(nk_text_edit* state)
{
    /* API cut: delete selection */
    if (state.mode == NK_TEXT_EDIT_MODE_VIEW)
        return 0;
    if (NK_TEXT_HAS_SELECTION(state)) {
        nk_textedit_delete_selection(state); /* implicitly clamps */
        state.has_preferred_x = 0;
        return 1;
    }
   return 0;
}
nk_bool nk_textedit_paste(nk_text_edit* state, const(char)* ctext, int len)
{
    /* API paste: replace existing selection with passed-in text */
    int glyphs = void;
    const(char)* text = cast(const(char)*) ctext;
    if (state.mode == NK_TEXT_EDIT_MODE_VIEW) return 0;

    /* if there's a selection, the paste should delete it */
    nk_textedit_clamp(state);
    nk_textedit_delete_selection(state);

    /* try to insert the characters */
    glyphs = nk_utf_len(ctext, len);
    if (nk_str_insert_text_char(&state.string, state.cursor, text, len)) {
        nk_textedit_makeundo_insert(state, state.cursor, glyphs);
        state.cursor += len;
        state.has_preferred_x = 0;
        return 1;
    }
    /* remove the undo since we didn't actually insert the characters */
    if (state.undo.undo_point)
        --state.undo.undo_point;
    return 0;
}
void nk_textedit_text(nk_text_edit* state, const(char)* text, int total_len)
{
    nk_rune unicode = void;
    int glyph_len = void;
    int text_len = 0;

    assert(state);
    assert(text);
    if (!text || !total_len || state.mode == NK_TEXT_EDIT_MODE_VIEW) return;

    glyph_len = nk_utf_decode(text, &unicode, total_len);
    while ((text_len < total_len) && glyph_len)
    {
        /* don't insert a backward delete, just process the event */
        if (unicode == 127) goto next;
        /* can't add newline in single-line mode */
        if (unicode == '\n' && state.single_line) goto next;
        /* filter incoming text */
        if (state.filter && !state.filter(state, unicode)) goto next;

        if (!NK_TEXT_HAS_SELECTION(state) &&
            state.cursor < state.string.len)
        {
            if (state.mode == NK_TEXT_EDIT_MODE_REPLACE) {
                nk_textedit_makeundo_replace(state, state.cursor, 1, 1);
                nk_str_delete_runes(&state.string, state.cursor, 1);
            }
            if (nk_str_insert_text_utf8(&state.string, state.cursor,
                                        text+text_len, 1))
            {
                ++state.cursor;
                state.has_preferred_x = 0;
            }
        } else {
            nk_textedit_delete_selection(state); /* implicitly clamps */
            if (nk_str_insert_text_utf8(&state.string, state.cursor,
                                        text+text_len, 1))
            {
                nk_textedit_makeundo_insert(state, state.cursor, 1);
                state.cursor = nk_min(state.cursor + 1, state.string.len);
                state.has_preferred_x = 0;
            }
        }
        next:
        text_len += glyph_len;
        glyph_len = nk_utf_decode(text + text_len, &unicode, total_len-text_len);
    }
}
void nk_textedit_key(nk_text_edit* state, nk_keys key, int shift_mod, const(nk_user_font)* font, float row_height)
{
retry:
    switch (key)
    {
    case NK_KEY_NONE:
    case NK_KEY_CTRL:
    case NK_KEY_ENTER:
    case NK_KEY_SHIFT:
    case NK_KEY_TAB:
    case NK_KEY_COPY:
    case NK_KEY_CUT:
    case NK_KEY_PASTE:
    case NK_KEY_MAX:
    default: break;
    case NK_KEY_TEXT_UNDO:
         nk_textedit_undo(state);
         state.has_preferred_x = 0;
         break;

    case NK_KEY_TEXT_REDO:
        nk_textedit_redo(state);
        state.has_preferred_x = 0;
        break;

    case NK_KEY_TEXT_SELECT_ALL:
        nk_textedit_select_all(state);
        state.has_preferred_x = 0;
        break;

    case NK_KEY_TEXT_INSERT_MODE:
        if (state.mode == NK_TEXT_EDIT_MODE_VIEW)
            state.mode = NK_TEXT_EDIT_MODE_INSERT;
        break;
    case NK_KEY_TEXT_REPLACE_MODE:
        if (state.mode == NK_TEXT_EDIT_MODE_VIEW)
            state.mode = NK_TEXT_EDIT_MODE_REPLACE;
        break;
    case NK_KEY_TEXT_RESET_MODE:
        if (state.mode == NK_TEXT_EDIT_MODE_INSERT ||
            state.mode == NK_TEXT_EDIT_MODE_REPLACE)
            state.mode = NK_TEXT_EDIT_MODE_VIEW;
        break;

    case NK_KEY_LEFT:
        if (shift_mod) {
            nk_textedit_clamp(state);
            nk_textedit_prep_selection_at_cursor(state);
            /* move selection left */
            if (state.select_end > 0)
                --state.select_end;
            state.cursor = state.select_end;
            state.has_preferred_x = 0;
        } else {
            /* if currently there's a selection,
             * move cursor to start of selection */
            if (NK_TEXT_HAS_SELECTION(state))
                nk_textedit_move_to_first(state);
            else if (state.cursor > 0)
               --state.cursor;
            state.has_preferred_x = 0;
        } break;

    case NK_KEY_RIGHT:
        if (shift_mod) {
            nk_textedit_prep_selection_at_cursor(state);
            /* move selection right */
            ++state.select_end;
            nk_textedit_clamp(state);
            state.cursor = state.select_end;
            state.has_preferred_x = 0;
        } else {
            /* if currently there's a selection,
             * move cursor to end of selection */
            if (NK_TEXT_HAS_SELECTION(state))
                nk_textedit_move_to_last(state);
            else ++state.cursor;
            nk_textedit_clamp(state);
            state.has_preferred_x = 0;
        } break;

    case NK_KEY_TEXT_WORD_LEFT:
        if (shift_mod) {
            if( NK_TEXT_HAS_SELECTION(state) )
            nk_textedit_prep_selection_at_cursor(state);
            state.cursor = nk_textedit_move_to_word_previous(state);
            state.select_end = state.cursor;
            nk_textedit_clamp(state );
        } else {
            if (NK_TEXT_HAS_SELECTION(state))
                nk_textedit_move_to_first(state);
            else {
                state.cursor = nk_textedit_move_to_word_previous(state);
                nk_textedit_clamp(state );
            }
        } break;

    case NK_KEY_TEXT_WORD_RIGHT:
        if (shift_mod) {
            if( NK_TEXT_HAS_SELECTION(state) )
                nk_textedit_prep_selection_at_cursor(state);
            state.cursor = nk_textedit_move_to_word_next(state);
            state.select_end = state.cursor;
            nk_textedit_clamp(state);
        } else {
            if (NK_TEXT_HAS_SELECTION(state))
                nk_textedit_move_to_last(state);
            else {
                state.cursor = nk_textedit_move_to_word_next(state);
                nk_textedit_clamp(state );
            }
        } break;

    case NK_KEY_DOWN: {
        nk_text_find find = void;
        nk_text_edit_row row = void;
        int i = void, sel = shift_mod;

        if (state.single_line) {
            /* on windows, up&down in single-line behave like left&right */
            key = NK_KEY_RIGHT;
            goto retry;
        }

        if (sel)
            nk_textedit_prep_selection_at_cursor(state);
        else if (NK_TEXT_HAS_SELECTION(state))
            nk_textedit_move_to_last(state);

        /* compute current position of cursor point */
        nk_textedit_clamp(state);
        nk_textedit_find_charpos(&find, state, state.cursor, state.single_line,
            font, row_height);

        /* now find character position down a row */
        if (find.length)
        {
            float x = void;
            float goal_x = state.has_preferred_x ? state.preferred_x : find.x;
            int start = find.first_char + find.length;

            state.cursor = start;
            nk_textedit_layout_row(&row, state, state.cursor, row_height, font);
            x = row.x0;

            for (i=0; i < row.num_chars && x < row.x1; ++i) {
                float dx = nk_textedit_get_width(state, start, i, font);
                x += dx;
                if (x > goal_x)
                    break;
                ++state.cursor;
            }
            nk_textedit_clamp(state);

            state.has_preferred_x = 1;
            state.preferred_x = goal_x;
            if (sel)
                state.select_end = state.cursor;
        }
    } break;

    case NK_KEY_UP: {
        nk_text_find find = void;
        nk_text_edit_row row = void;
        int i = void, sel = shift_mod;

        if (state.single_line) {
            /* on windows, up&down become left&right */
            key = NK_KEY_LEFT;
            goto retry;
        }

        if (sel)
            nk_textedit_prep_selection_at_cursor(state);
        else if (NK_TEXT_HAS_SELECTION(state))
            nk_textedit_move_to_first(state);

         /* compute current position of cursor point */
         nk_textedit_clamp(state);
         nk_textedit_find_charpos(&find, state, state.cursor, state.single_line,
                font, row_height);

         /* can only go up if there's a previous row */
         if (find.prev_first != find.first_char) {
            /* now find character position up a row */
            float x = void;
            float goal_x = state.has_preferred_x ? state.preferred_x : find.x;

            state.cursor = find.prev_first;
            nk_textedit_layout_row(&row, state, state.cursor, row_height, font);
            x = row.x0;

            for (i=0; i < row.num_chars && x < row.x1; ++i) {
                float dx = nk_textedit_get_width(state, find.prev_first, i, font);
                x += dx;
                if (x > goal_x)
                    break;
                ++state.cursor;
            }
            nk_textedit_clamp(state);

            state.has_preferred_x = 1;
            state.preferred_x = goal_x;
            if (sel) state.select_end = state.cursor;
         }
      } break;

    case NK_KEY_DEL:
        if (state.mode == NK_TEXT_EDIT_MODE_VIEW)
            break;
        if (NK_TEXT_HAS_SELECTION(state))
            nk_textedit_delete_selection(state);
        else {
            int n = state.string.len;
            if (state.cursor < n)
                nk_textedit_delete(state, state.cursor, 1);
         }
         state.has_preferred_x = 0;
         break;

    case NK_KEY_BACKSPACE:
        if (state.mode == NK_TEXT_EDIT_MODE_VIEW)
            break;
        if (NK_TEXT_HAS_SELECTION(state))
            nk_textedit_delete_selection(state);
        else {
            nk_textedit_clamp(state);
            if (state.cursor > 0) {
                nk_textedit_delete(state, state.cursor-1, 1);
                --state.cursor;
            }
         }
         state.has_preferred_x = 0;
         break;

    case NK_KEY_TEXT_START:
         if (shift_mod) {
            nk_textedit_prep_selection_at_cursor(state);
            state.cursor = state.select_end = 0;
            state.has_preferred_x = 0;
         } else {
            state.cursor = state.select_start = state.select_end = 0;
            state.has_preferred_x = 0;
         }
         break;

    case NK_KEY_TEXT_END:
         if (shift_mod) {
            nk_textedit_prep_selection_at_cursor(state);
            state.cursor = state.select_end = state.string.len;
            state.has_preferred_x = 0;
         } else {
            state.cursor = state.string.len;
            state.select_start = state.select_end = 0;
            state.has_preferred_x = 0;
         }
         break;

    case NK_KEY_TEXT_LINE_START: {
        if (shift_mod) {
            nk_text_find find = void;
           nk_textedit_clamp(state);
            nk_textedit_prep_selection_at_cursor(state);
            if (state.string.len && state.cursor == state.string.len)
                --state.cursor;
            nk_textedit_find_charpos(&find, state,state.cursor, state.single_line,
                font, row_height);
            state.cursor = state.select_end = find.first_char;
            state.has_preferred_x = 0;
        } else {
            nk_text_find find = void;
            if (state.string.len && state.cursor == state.string.len)
                --state.cursor;
            nk_textedit_clamp(state);
            nk_textedit_move_to_first(state);
            nk_textedit_find_charpos(&find, state, state.cursor, state.single_line,
                font, row_height);
            state.cursor = find.first_char;
            state.has_preferred_x = 0;
        }
      } break;

    case NK_KEY_TEXT_LINE_END: {
        if (shift_mod) {
            nk_text_find find = void;
            nk_textedit_clamp(state);
            nk_textedit_prep_selection_at_cursor(state);
            nk_textedit_find_charpos(&find, state, state.cursor, state.single_line,
                font, row_height);
            state.has_preferred_x = 0;
            state.cursor = find.first_char + find.length;
            if (find.length > 0 && nk_str_rune_at(&state.string, state.cursor-1) == '\n')
                --state.cursor;
            state.select_end = state.cursor;
        } else {
            nk_text_find find = void;
            nk_textedit_clamp(state);
            nk_textedit_move_to_first(state);
            nk_textedit_find_charpos(&find, state, state.cursor, state.single_line,
                font, row_height);

            state.has_preferred_x = 0;
            state.cursor = find.first_char + find.length;
            if (find.length > 0 && nk_str_rune_at(&state.string, state.cursor-1) == '\n')
                --state.cursor;
        }} break;
    }
}
void nk_textedit_flush_redo(nk_text_undo_state* state)
{
    state.redo_point = NK_TEXTEDIT_UNDOSTATECOUNT;
    state.redo_char_point = NK_TEXTEDIT_UNDOCHARCOUNT;
}
void nk_textedit_discard_undo(nk_text_undo_state* state)
{
    /* discard the oldest entry in the undo list */
    if (state.undo_point > 0) {
        /* if the 0th undo state has characters, clean those up */
        if (state.undo_rec[0].char_storage >= 0) {
            int n = state.undo_rec[0].insert_length, i = void;
            /* delete n characters from all other records */
            state.undo_char_point = cast(short)(state.undo_char_point - n);
            nk_memcopy(state.undo_char.ptr, state.undo_char.ptr + n,
                cast(nk_size)state.undo_char_point*nk_rune.sizeof);
            for (i=0; i < state.undo_point; ++i) {
                if (state.undo_rec[i].char_storage >= 0)
                state.undo_rec[i].char_storage = cast(short)
                    (state.undo_rec[i].char_storage - n);
            }
        }
        --state.undo_point;
        nk_memcopy(state.undo_rec.ptr, state.undo_rec.ptr+1,
            cast(nk_size)(cast(nk_size)state.undo_point * typeof(state.undo_rec[0]).sizeof));
    }
}
void nk_textedit_discard_redo(nk_text_undo_state* state)
{
/*  discard the oldest entry in the redo list--it's bad if this
    ever happens, but because undo & redo have to store the actual
    characters in different cases, the redo character buffer can
    fill up even though the undo buffer didn't */
    nk_size num = void;
    int k = NK_TEXTEDIT_UNDOSTATECOUNT-1;
    if (state.redo_point <= k) {
        /* if the k'th undo state has characters, clean those up */
        if (state.undo_rec[k].char_storage >= 0) {
            int n = state.undo_rec[k].insert_length, i = void;
            /* delete n characters from all other records */
            state.redo_char_point = cast(short)(state.redo_char_point + n);
            num = cast(nk_size)(NK_TEXTEDIT_UNDOCHARCOUNT - state.redo_char_point);
            nk_memcopy(state.undo_char.ptr + state.redo_char_point,
                state.undo_char.ptr + state.redo_char_point-n, num * char.sizeof);
            for (i = state.redo_point; i < k; ++i) {
                if (state.undo_rec[i].char_storage >= 0) {
                    state.undo_rec[i].char_storage = cast(short)
                        (state.undo_rec[i].char_storage + n);
                }
            }
        }
        ++state.redo_point;
        num = cast(nk_size)(NK_TEXTEDIT_UNDOSTATECOUNT - state.redo_point);
        if (num) nk_memcopy(state.undo_rec.ptr + state.redo_point-1,
            state.undo_rec.ptr + state.redo_point, num * typeof(state.undo_rec[0]).sizeof);
    }
}
nk_text_undo_record* nk_textedit_create_undo_record(nk_text_undo_state* state, int numchars)
{
    /* any time we create a new undo record, we discard redo*/
    nk_textedit_flush_redo(state);

    /* if we have no free records, we have to make room,
     * by sliding the existing records down */
    if (state.undo_point == NK_TEXTEDIT_UNDOSTATECOUNT)
        nk_textedit_discard_undo(state);

    /* if the characters to store won't possibly fit in the buffer,
     * we can't undo */
    if (numchars > NK_TEXTEDIT_UNDOCHARCOUNT) {
        state.undo_point = 0;
        state.undo_char_point = 0;
        return null;
    }

    /* if we don't have enough free characters in the buffer,
     * we have to make room */
    while (state.undo_char_point + numchars > NK_TEXTEDIT_UNDOCHARCOUNT)
        nk_textedit_discard_undo(state);
    return &state.undo_rec[state.undo_point++];
}
nk_rune* nk_textedit_createundo(nk_text_undo_state* state, int pos, int insert_len, int delete_len)
{
    nk_text_undo_record* r = nk_textedit_create_undo_record(state, insert_len);
    if (r == null)
        return null;

    r.where = pos;
    r.insert_length = cast(short) insert_len;
    r.delete_length = cast(short) delete_len;

    if (insert_len == 0) {
        r.char_storage = -1;
        return null;
    } else {
        r.char_storage = state.undo_char_point;
        state.undo_char_point = cast(short)(state.undo_char_point +  insert_len);
        return &state.undo_char[r.char_storage];
    }
}
void nk_textedit_undo(nk_text_edit* state)
{
    nk_text_undo_state* s = &state.undo;
    nk_text_undo_record u = void; nk_text_undo_record* r = void;
    if (s.undo_point == 0)
        return;

    /* we need to do two things: apply the undo record, and create a redo record */
    u = s.undo_rec[s.undo_point-1];
    r = &s.undo_rec[s.redo_point-1];
    r.char_storage = -1;

    r.insert_length = u.delete_length;
    r.delete_length = u.insert_length;
    r.where = u.where;

    if (u.delete_length)
    {
       /*   if the undo record says to delete characters, then the redo record will
            need to re-insert the characters that get deleted, so we need to store
            them.
            there are three cases:
                - there's enough room to store the characters
                - characters stored for *redoing* don't leave room for redo
                - characters stored for *undoing* don't leave room for redo
            if the last is true, we have to bail */
        if (s.undo_char_point + u.delete_length >= NK_TEXTEDIT_UNDOCHARCOUNT) {
            /* the undo records take up too much character space; there's no space
            * to store the redo characters */
            r.insert_length = 0;
        } else {
            int i = void;
            /* there's definitely room to store the characters eventually */
            while (s.undo_char_point + u.delete_length > s.redo_char_point) {
                /* there's currently not enough room, so discard a redo record */
                nk_textedit_discard_redo(s);
                /* should never happen: */
                if (s.redo_point == NK_TEXTEDIT_UNDOSTATECOUNT)
                    return;
            }

            r = &s.undo_rec[s.redo_point-1];
            r.char_storage = cast(short)(s.redo_char_point - u.delete_length);
            s.redo_char_point = cast(short)(s.redo_char_point -  u.delete_length);

            /* now save the characters */
            for (i=0; i < u.delete_length; ++i)
                s.undo_char[r.char_storage + i] =
                    nk_str_rune_at(&state.string, u.where + i);
        }
        /* now we can carry out the deletion */
        nk_str_delete_runes(&state.string, u.where, u.delete_length);
    }

    /* check type of recorded action: */
    if (u.insert_length) {
        /* easy case: was a deletion, so we need to insert n characters */
        nk_str_insert_text_runes(&state.string, u.where,
            &s.undo_char[u.char_storage], u.insert_length);
        s.undo_char_point = cast(short)(s.undo_char_point - u.insert_length);
    }
    state.cursor = cast(short)(u.where + u.insert_length);

    s.undo_point--;
    s.redo_point--;
}
void nk_textedit_redo(nk_text_edit* state)
{
    nk_text_undo_state* s = &state.undo;
    nk_text_undo_record* u = void; nk_text_undo_record r = void;
    if (s.redo_point == NK_TEXTEDIT_UNDOSTATECOUNT)
        return;

    /* we need to do two things: apply the redo record, and create an undo record */
    u = &s.undo_rec[s.undo_point];
    r = s.undo_rec[s.redo_point];

    /* we KNOW there must be room for the undo record, because the redo record
    was derived from an undo record */
    u.delete_length = r.insert_length;
    u.insert_length = r.delete_length;
    u.where = r.where;
    u.char_storage = -1;

    if (r.delete_length) {
        /* the redo record requires us to delete characters, so the undo record
        needs to store the characters */
        if (s.undo_char_point + u.insert_length > s.redo_char_point) {
            u.insert_length = 0;
            u.delete_length = 0;
        } else {
            int i = void;
            u.char_storage = s.undo_char_point;
            s.undo_char_point = cast(short)(s.undo_char_point + u.insert_length);

            /* now save the characters */
            for (i=0; i < u.insert_length; ++i) {
                s.undo_char[u.char_storage + i] =
                    nk_str_rune_at(&state.string, u.where + i);
            }
        }
        nk_str_delete_runes(&state.string, r.where, r.delete_length);
    }

    if (r.insert_length) {
        /* easy case: need to insert n characters */
        nk_str_insert_text_runes(&state.string, r.where,
            &s.undo_char[r.char_storage], r.insert_length);
    }
    state.cursor = r.where + r.insert_length;

    s.undo_point++;
    s.redo_point++;
}
void nk_textedit_makeundo_insert(nk_text_edit* state, int where, int length)
{
    nk_textedit_createundo(&state.undo, where, 0, length);
}
void nk_textedit_makeundo_delete(nk_text_edit* state, int where, int length)
{
    int i = void;
    nk_rune* p = nk_textedit_createundo(&state.undo, where, length, 0);
    if (p) {
        for (i=0; i < length; ++i)
            p[i] = nk_str_rune_at(&state.string, where+i);
    }
}
void nk_textedit_makeundo_replace(nk_text_edit* state, int where, int old_length, int new_length)
{
    int i = void;
    nk_rune* p = nk_textedit_createundo(&state.undo, where, old_length, new_length);
    if (p) {
        for (i=0; i < old_length; ++i)
            p[i] = nk_str_rune_at(&state.string, where+i);
    }
}
void nk_textedit_clear_state(nk_text_edit* state, nk_text_edit_type type, nk_plugin_filter filter)
{
    /* reset the state to default */
   state.undo.undo_point = 0;
   state.undo.undo_char_point = 0;
   state.undo.redo_point = NK_TEXTEDIT_UNDOSTATECOUNT;
   state.undo.redo_char_point = NK_TEXTEDIT_UNDOCHARCOUNT;
   state.select_end = state.select_start = 0;
   state.cursor = 0;
   state.has_preferred_x = 0;
   state.preferred_x = 0;
   state.cursor_at_end_of_line = 0;
   state.initialized = 1;
   state.single_line = cast(ubyte)(type == NK_TEXT_EDIT_SINGLE_LINE);
   state.mode = NK_TEXT_EDIT_MODE_VIEW;
   state.filter = filter;
   state.scrollbar = nk_vec2(0,0);
}
void nk_textedit_init_fixed(nk_text_edit* state, void* memory, nk_size size)
{
    assert(state);
    assert(memory);
    if (!state || !memory || !size) return;
    nk_memset(state, 0, nk_text_edit.sizeof);
    nk_textedit_clear_state(state, NK_TEXT_EDIT_SINGLE_LINE, null);
    nk_str_init_fixed(&state.string, memory, size);
}
void nk_textedit_init(nk_text_edit* state, nk_allocator* alloc, nk_size size)
{
    assert(state);
    assert(alloc);
    if (!state || !alloc) return;
    nk_memset(state, 0, nk_text_edit.sizeof);
    nk_textedit_clear_state(state, NK_TEXT_EDIT_SINGLE_LINE, null);
    nk_str_init(&state.string, alloc, size);
}
version (NK_INCLUDE_DEFAULT_ALLOCATOR) {
void nk_textedit_init_default(nk_text_edit* state)
{
    assert(state);
    if (!state) return;
    nk_memset(state, 0, nk_text_edit.sizeof);
    nk_textedit_clear_state(state, NK_TEXT_EDIT_SINGLE_LINE, null);
    nk_str_init_default(&state.string);
}
}
void nk_textedit_select_all(nk_text_edit* state)
{
    assert(state);
    state.select_start = 0;
    state.select_end = state.string.len;
}
void nk_textedit_free(nk_text_edit* state)
{
    assert(state);
    if (!state) return;
    nk_str_free(&state.string);
}

