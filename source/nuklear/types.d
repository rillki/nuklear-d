module nuklear.types;

@nogc nothrow:
extern(C): __gshared:

/*
 * ==============================================================
 *
 *                          CONSTANTS
 *
 * ===============================================================
 */
enum NK_UNDEFINED = (-1.0f);
enum NK_UTF_INVALID = 0xFFFD /* internal invalid utf8 rune */;
enum NK_UTF_SIZE = 4 /* describes the number of bytes a glyph consists of*/;
enum NK_INPUT_MAX = 16;
enum NK_MAX_NUMBER_BUFFER = 64;
enum NK_SCROLLBAR_HIDING_TIMEOUT = 4.0f;

/*
 * ==============================================================
 *
 *                          HELPER
 *
 * ===============================================================
 */

auto NK_FLAG(T)(T x) { return 1 << x; }
auto NK_MIN(T)(T a, T b) { return a < b ? a : b; } 
auto NK_MAX(T)(T a, T b) { return a < b ? b : a; } 
auto NK_CLAMP(T)(T a, T b) { return NK_MAX(NK_MIN(v,x), i); } 
auto NK_UNIQUE_NAME(string name) { return name ~ __LINE__.stringof; }

enum NK_FILE_LINE = __FILE__ ~ __LINE__.stringof;

version (NK_INCLUDE_STANDARD_VARARGS) {
    public import core.stdc.stdarg;
}

/*
 * ===============================================================
 *
 *                          BASIC
 *
 * ===============================================================
 */
    public import core.stdc.stdint;


version (NK_INCLUDE_FIXED_TYPES) {
    import core.stdc.stdint;
    alias NK_INT8 = int8_t;
    alias NK_UINT8 = uint8_t;
    alias NK_INT16 = int16_t;
    alias NK_UINT16 = uint16_t;
    alias NK_INT32 = int32_t;
    alias NK_UINT32 = uint32_t;
    alias NK_SIZE_TYPE = uintptr_t;
    alias NK_POINTER_TYPE = uintptr_t;
} else {
    alias NK_INT8 = byte;
    alias NK_UINT8 = ubyte;
    alias NK_INT16 = short;
    alias NK_UINT16 = ushort;
    alias NK_INT32 = int;
    alias NK_UINT32 = uint;
    alias NK_SIZE_TYPE = size_t;
    alias NK_POINTER_TYPE = size_t;
}
alias NK_BOOL = bool;

alias nk_char = NK_INT8;
alias nk_uchar = NK_UINT8;
alias nk_byte = NK_UINT8;
alias nk_short = NK_INT16;
alias nk_ushort = NK_UINT16;
alias nk_int = NK_INT32;
alias nk_uint = NK_UINT32;
alias nk_size = NK_SIZE_TYPE;
alias nk_ptr = NK_POINTER_TYPE;
alias nk_bool = NK_BOOL;

alias nk_hash = nk_uint;
alias nk_flags = nk_uint;
alias nk_rune = nk_uint;
alias nk_float = float;

/* Make sure correct type size:
 * This will fire with a negative subscript error if the type sizes
 * are set incorrectly by the compiler, and compile out if not */
static assert(nk_short.sizeof == 2);
static assert(nk_ushort.sizeof == 2);
static assert(nk_uint.sizeof == 4);
static assert(nk_int.sizeof == 4);
static assert(nk_byte.sizeof == 1);
static assert(nk_flags.sizeof >= 4);
static assert(nk_rune.sizeof >= 4);
static assert(nk_size.sizeof >= (void*).sizeof);
static assert(nk_ptr.sizeof >= (void*).sizeof);
static assert(nk_bool.sizeof == bool.sizeof);

/* ============================================================================
 *
 *                                  API
 *
 * =========================================================================== */

enum { nk_false, nk_true }
struct nk_color      { nk_byte r, g, b, a; }
struct nk_colorf     { float r = 0, g = 0, b = 0, a = 0; }
struct nk_vec2       { float x = 0, y = 0; }
struct nk_vec2i      { short x, y; }
struct nk_rect       { float x = 0, y = 0, w = 0, h = 0; }
struct nk_recti      { short x, y, w, h; }

alias nk_glyph = char[NK_UTF_SIZE];
union nk_handle      { void* ptr; int id; }
struct nk_image      { nk_handle handle; nk_ushort w, h; nk_ushort[4] region; }
struct nk_nine_slice { nk_image img; nk_ushort l, t, r, b; }
struct nk_cursor     { nk_image img; nk_vec2 size, offset; }
struct nk_scroll     { nk_uint x, y; }

enum nk_heading      { NK_UP, NK_RIGHT, NK_DOWN, NK_LEFT }
alias NK_UP = nk_heading.NK_UP;
alias NK_RIGHT = nk_heading.NK_RIGHT;
alias NK_DOWN = nk_heading.NK_DOWN;
alias NK_LEFT = nk_heading.NK_LEFT;

enum nk_button_behavior { NK_BUTTON_DEFAULT, NK_BUTTON_REPEATER }
alias NK_BUTTON_DEFAULT = nk_button_behavior.NK_BUTTON_DEFAULT;
alias NK_BUTTON_REPEATER = nk_button_behavior.NK_BUTTON_REPEATER;

enum nk_modify          { NK_FIXED = nk_false, NK_MODIFIABLE = nk_true }
alias NK_FIXED = nk_modify.NK_FIXED;
alias NK_MODIFIABLE = nk_modify.NK_MODIFIABLE;

enum nk_orientation     { NK_VERTICAL, NK_HORIZONTAL }
alias NK_VERTICAL = nk_orientation.NK_VERTICAL;
alias NK_HORIZONTAL = nk_orientation.NK_HORIZONTAL;

enum nk_collapse_states { NK_MINIMIZED = nk_false, NK_MAXIMIZED = nk_true }
alias NK_MINIMIZED = nk_collapse_states.NK_MINIMIZED;
alias NK_MAXIMIZED = nk_collapse_states.NK_MAXIMIZED;

enum nk_show_states     { NK_HIDDEN = nk_false, NK_SHOWN = nk_true }
alias NK_HIDDEN = nk_show_states.NK_HIDDEN;
alias NK_SHOWN = nk_show_states.NK_SHOWN;

enum nk_chart_type      { NK_CHART_LINES, NK_CHART_COLUMN, NK_CHART_MAX }
alias NK_CHART_LINES = nk_chart_type.NK_CHART_LINES;
alias NK_CHART_COLUMN = nk_chart_type.NK_CHART_COLUMN;
alias NK_CHART_MAX = nk_chart_type.NK_CHART_MAX;

enum nk_chart_event     { NK_CHART_HOVERING = 0x01, NK_CHART_CLICKED = 0x02 }
alias NK_CHART_HOVERING = nk_chart_event.NK_CHART_HOVERING;
alias NK_CHART_CLICKED = nk_chart_event.NK_CHART_CLICKED;

enum nk_color_format    { NK_RGB, NK_RGBA } 
alias NK_RGB = nk_color_format.NK_RGB;
alias NK_RGBA = nk_color_format.NK_RGBA;

enum nk_popup_type      { NK_POPUP_STATIC, NK_POPUP_DYNAMIC }
alias NK_POPUP_STATIC = nk_popup_type.NK_POPUP_STATIC;
alias NK_POPUP_DYNAMIC = nk_popup_type.NK_POPUP_DYNAMIC;

enum nk_layout_format   { NK_DYNAMIC, NK_STATIC }
alias NK_DYNAMIC = nk_layout_format.NK_DYNAMIC;
alias NK_STATIC = nk_layout_format.NK_STATIC;

enum nk_tree_type       { NK_TREE_NODE, NK_TREE_TAB }
alias NK_TREE_NODE = nk_tree_type.NK_TREE_NODE;
alias NK_TREE_TAB = nk_tree_type.NK_TREE_TAB;


alias nk_plugin_alloc = void* function(nk_handle, void* old, nk_size);
alias nk_plugin_free = void function(nk_handle, void* old);
alias nk_plugin_filter = nk_bool function(const(nk_text_edit)*, nk_rune unicode);
alias nk_plugin_paste = void function(nk_handle, nk_text_edit*);
alias nk_plugin_copy = void function(nk_handle, const(char)*, int len);

struct nk_allocator {
    nk_handle userdata;
    nk_plugin_alloc alloc;
    nk_plugin_free free;
}

enum nk_symbol_type {
    NK_SYMBOL_NONE,
    NK_SYMBOL_X,
    NK_SYMBOL_UNDERSCORE,
    NK_SYMBOL_CIRCLE_SOLID,
    NK_SYMBOL_CIRCLE_OUTLINE,
    NK_SYMBOL_RECT_SOLID,
    NK_SYMBOL_RECT_OUTLINE,
    NK_SYMBOL_TRIANGLE_UP,
    NK_SYMBOL_TRIANGLE_DOWN,
    NK_SYMBOL_TRIANGLE_LEFT,
    NK_SYMBOL_TRIANGLE_RIGHT,
    NK_SYMBOL_PLUS,
    NK_SYMBOL_MINUS,
    NK_SYMBOL_MAX
}

alias NK_SYMBOL_NONE = nk_symbol_type.NK_SYMBOL_NONE;
alias NK_SYMBOL_X = nk_symbol_type.NK_SYMBOL_X;
alias NK_SYMBOL_UNDERSCORE = nk_symbol_type.NK_SYMBOL_UNDERSCORE;
alias NK_SYMBOL_CIRCLE_SOLID = nk_symbol_type.NK_SYMBOL_CIRCLE_SOLID;
alias NK_SYMBOL_CIRCLE_OUTLINE = nk_symbol_type.NK_SYMBOL_CIRCLE_OUTLINE;
alias NK_SYMBOL_RECT_SOLID = nk_symbol_type.NK_SYMBOL_RECT_SOLID;
alias NK_SYMBOL_RECT_OUTLINE = nk_symbol_type.NK_SYMBOL_RECT_OUTLINE;
alias NK_SYMBOL_TRIANGLE_UP = nk_symbol_type.NK_SYMBOL_TRIANGLE_UP;
alias NK_SYMBOL_TRIANGLE_DOWN = nk_symbol_type.NK_SYMBOL_TRIANGLE_DOWN;
alias NK_SYMBOL_TRIANGLE_LEFT = nk_symbol_type.NK_SYMBOL_TRIANGLE_LEFT;
alias NK_SYMBOL_TRIANGLE_RIGHT = nk_symbol_type.NK_SYMBOL_TRIANGLE_RIGHT;
alias NK_SYMBOL_PLUS = nk_symbol_type.NK_SYMBOL_PLUS;
alias NK_SYMBOL_MINUS = nk_symbol_type.NK_SYMBOL_MINUS;
alias NK_SYMBOL_MAX = nk_symbol_type.NK_SYMBOL_MAX;

/* =============================================================================
 *
 *                                  INPUT
 *
 * =============================================================================*/

enum nk_keys {
    NK_KEY_NONE,
    NK_KEY_SHIFT,
    NK_KEY_CTRL,
    NK_KEY_DEL,
    NK_KEY_ENTER,
    NK_KEY_TAB,
    NK_KEY_BACKSPACE,
    NK_KEY_COPY,
    NK_KEY_CUT,
    NK_KEY_PASTE,
    NK_KEY_UP,
    NK_KEY_DOWN,
    NK_KEY_LEFT,
    NK_KEY_RIGHT,
    /* Shortcuts: text field */
    NK_KEY_TEXT_INSERT_MODE,
    NK_KEY_TEXT_REPLACE_MODE,
    NK_KEY_TEXT_RESET_MODE,
    NK_KEY_TEXT_LINE_START,
    NK_KEY_TEXT_LINE_END,
    NK_KEY_TEXT_START,
    NK_KEY_TEXT_END,
    NK_KEY_TEXT_UNDO,
    NK_KEY_TEXT_REDO,
    NK_KEY_TEXT_SELECT_ALL,
    NK_KEY_TEXT_WORD_LEFT,
    NK_KEY_TEXT_WORD_RIGHT,
    /* Shortcuts: scrollbar */
    NK_KEY_SCROLL_START,
    NK_KEY_SCROLL_END,
    NK_KEY_SCROLL_DOWN,
    NK_KEY_SCROLL_UP,
    NK_KEY_MAX
}
alias NK_KEY_NONE = nk_keys.NK_KEY_NONE;
alias NK_KEY_SHIFT = nk_keys.NK_KEY_SHIFT;
alias NK_KEY_CTRL = nk_keys.NK_KEY_CTRL;
alias NK_KEY_DEL = nk_keys.NK_KEY_DEL;
alias NK_KEY_ENTER = nk_keys.NK_KEY_ENTER;
alias NK_KEY_TAB = nk_keys.NK_KEY_TAB;
alias NK_KEY_BACKSPACE = nk_keys.NK_KEY_BACKSPACE;
alias NK_KEY_COPY = nk_keys.NK_KEY_COPY;
alias NK_KEY_CUT = nk_keys.NK_KEY_CUT;
alias NK_KEY_PASTE = nk_keys.NK_KEY_PASTE;
alias NK_KEY_UP = nk_keys.NK_KEY_UP;
alias NK_KEY_DOWN = nk_keys.NK_KEY_DOWN;
alias NK_KEY_LEFT = nk_keys.NK_KEY_LEFT;
alias NK_KEY_RIGHT = nk_keys.NK_KEY_RIGHT;
alias NK_KEY_TEXT_INSERT_MODE = nk_keys.NK_KEY_TEXT_INSERT_MODE;
alias NK_KEY_TEXT_REPLACE_MODE = nk_keys.NK_KEY_TEXT_REPLACE_MODE;
alias NK_KEY_TEXT_RESET_MODE = nk_keys.NK_KEY_TEXT_RESET_MODE;
alias NK_KEY_TEXT_LINE_START = nk_keys.NK_KEY_TEXT_LINE_START;
alias NK_KEY_TEXT_LINE_END = nk_keys.NK_KEY_TEXT_LINE_END;
alias NK_KEY_TEXT_START = nk_keys.NK_KEY_TEXT_START;
alias NK_KEY_TEXT_END = nk_keys.NK_KEY_TEXT_END;
alias NK_KEY_TEXT_UNDO = nk_keys.NK_KEY_TEXT_UNDO;
alias NK_KEY_TEXT_REDO = nk_keys.NK_KEY_TEXT_REDO;
alias NK_KEY_TEXT_SELECT_ALL = nk_keys.NK_KEY_TEXT_SELECT_ALL;
alias NK_KEY_TEXT_WORD_LEFT = nk_keys.NK_KEY_TEXT_WORD_LEFT;
alias NK_KEY_TEXT_WORD_RIGHT = nk_keys.NK_KEY_TEXT_WORD_RIGHT;
alias NK_KEY_SCROLL_START = nk_keys.NK_KEY_SCROLL_START;
alias NK_KEY_SCROLL_END = nk_keys.NK_KEY_SCROLL_END;
alias NK_KEY_SCROLL_DOWN = nk_keys.NK_KEY_SCROLL_DOWN;
alias NK_KEY_SCROLL_UP = nk_keys.NK_KEY_SCROLL_UP;
alias NK_KEY_MAX = nk_keys.NK_KEY_MAX;

enum nk_buttons {
    NK_BUTTON_LEFT,
    NK_BUTTON_MIDDLE,
    NK_BUTTON_RIGHT,
    NK_BUTTON_DOUBLE,
    NK_BUTTON_MAX
}
alias NK_BUTTON_LEFT = nk_buttons.NK_BUTTON_LEFT;
alias NK_BUTTON_MIDDLE = nk_buttons.NK_BUTTON_MIDDLE;
alias NK_BUTTON_RIGHT = nk_buttons.NK_BUTTON_RIGHT;
alias NK_BUTTON_DOUBLE = nk_buttons.NK_BUTTON_DOUBLE;
alias NK_BUTTON_MAX = nk_buttons.NK_BUTTON_MAX;

/* =============================================================================
 *
 *                                  DRAWING
 *
 * =============================================================================*/

enum nk_anti_aliasing { NK_ANTI_ALIASING_OFF, NK_ANTI_ALIASING_ON }
alias NK_ANTI_ALIASING_OFF = nk_anti_aliasing.NK_ANTI_ALIASING_OFF;
alias NK_ANTI_ALIASING_ON = nk_anti_aliasing.NK_ANTI_ALIASING_ON;

enum nk_convert_result {
    NK_CONVERT_SUCCESS = 0,
    NK_CONVERT_INVALID_PARAM = 1,
    NK_CONVERT_COMMAND_BUFFER_FULL = NK_FLAG(1),
    NK_CONVERT_VERTEX_BUFFER_FULL = NK_FLAG(2),
    NK_CONVERT_ELEMENT_BUFFER_FULL = NK_FLAG(3)
}
alias NK_CONVERT_SUCCESS = nk_convert_result.NK_CONVERT_SUCCESS;
alias NK_CONVERT_INVALID_PARAM = nk_convert_result.NK_CONVERT_INVALID_PARAM;
alias NK_CONVERT_COMMAND_BUFFER_FULL = nk_convert_result.NK_CONVERT_COMMAND_BUFFER_FULL;
alias NK_CONVERT_VERTEX_BUFFER_FULL = nk_convert_result.NK_CONVERT_VERTEX_BUFFER_FULL;
alias NK_CONVERT_ELEMENT_BUFFER_FULL = nk_convert_result.NK_CONVERT_ELEMENT_BUFFER_FULL;

struct nk_draw_null_texture {
    nk_handle texture; /* texture handle to a texture with a white pixel */
    nk_vec2 uv; /* coordinates to a white pixel in the texture  */
}
struct nk_draw_vertex_layout_element;
struct nk_convert_config {
    float global_alpha = 0; /* global alpha value */
    nk_anti_aliasing line_AA; /* line anti-aliasing flag can be turned off if you are tight on memory */
    nk_anti_aliasing shape_AA; /* shape anti-aliasing flag can be turned off if you are tight on memory */
    uint circle_segment_count; /* number of segments used for circles: default to 22 */
    uint arc_segment_count; /* number of segments used for arcs: default to 22 */
    uint curve_segment_count; /* number of segments used for curves: default to 22 */
    nk_draw_null_texture tex_null; /* handle to texture with a white pixel for shape drawing */
    const(nk_draw_vertex_layout_element)* vertex_layout; /* describes the vertex output format and packing */
    nk_size vertex_size; /* sizeof one vertex for vertex packing */
    nk_size vertex_alignment; /* vertex alignment: Can be obtained by NK_ALIGNOF */
}

/* =============================================================================
 *
 *                                  WINDOW
 *
 * ============================================================================= */

enum nk_panel_flags {
    NK_WINDOW_BORDER            = NK_FLAG(0),
    NK_WINDOW_MOVABLE           = NK_FLAG(1),
    NK_WINDOW_SCALABLE          = NK_FLAG(2),
    NK_WINDOW_CLOSABLE          = NK_FLAG(3),
    NK_WINDOW_MINIMIZABLE       = NK_FLAG(4),
    NK_WINDOW_NO_SCROLLBAR      = NK_FLAG(5),
    NK_WINDOW_TITLE             = NK_FLAG(6),
    NK_WINDOW_SCROLL_AUTO_HIDE  = NK_FLAG(7),
    NK_WINDOW_BACKGROUND        = NK_FLAG(8),
    NK_WINDOW_SCALE_LEFT        = NK_FLAG(9),
    NK_WINDOW_NO_INPUT          = NK_FLAG(10)
}
alias NK_WINDOW_BORDER = nk_panel_flags.NK_WINDOW_BORDER;
alias NK_WINDOW_MOVABLE = nk_panel_flags.NK_WINDOW_MOVABLE;
alias NK_WINDOW_SCALABLE = nk_panel_flags.NK_WINDOW_SCALABLE;
alias NK_WINDOW_CLOSABLE = nk_panel_flags.NK_WINDOW_CLOSABLE;
alias NK_WINDOW_MINIMIZABLE = nk_panel_flags.NK_WINDOW_MINIMIZABLE;
alias NK_WINDOW_NO_SCROLLBAR = nk_panel_flags.NK_WINDOW_NO_SCROLLBAR;
alias NK_WINDOW_TITLE = nk_panel_flags.NK_WINDOW_TITLE;
alias NK_WINDOW_SCROLL_AUTO_HIDE = nk_panel_flags.NK_WINDOW_SCROLL_AUTO_HIDE;
alias NK_WINDOW_BACKGROUND = nk_panel_flags.NK_WINDOW_BACKGROUND;
alias NK_WINDOW_SCALE_LEFT = nk_panel_flags.NK_WINDOW_SCALE_LEFT;
alias NK_WINDOW_NO_INPUT = nk_panel_flags.NK_WINDOW_NO_INPUT;

/* =============================================================================
 *
 *                                  LIST VIEW
 *
 * ============================================================================= */

struct nk_list_view {
/* public: */
    int begin, end, count;
/* private: */
    int total_height;
    nk_context* ctx;
    nk_uint* scroll_pointer;
    nk_uint scroll_value;
}

/* =============================================================================
 *
 *                                  WIDGET
 *
 * ============================================================================= */

enum nk_widget_layout_states {
    NK_WIDGET_INVALID, /* The widget cannot be seen and is completely out of view */
    NK_WIDGET_VALID, /* The widget is completely inside the window and can be updated and drawn */
    NK_WIDGET_ROM /* The widget is partially visible and cannot be updated */
}
alias NK_WIDGET_INVALID = nk_widget_layout_states.NK_WIDGET_INVALID;
alias NK_WIDGET_VALID = nk_widget_layout_states.NK_WIDGET_VALID;
alias NK_WIDGET_ROM = nk_widget_layout_states.NK_WIDGET_ROM;

enum nk_widget_states {
    NK_WIDGET_STATE_MODIFIED    = NK_FLAG(1),
    NK_WIDGET_STATE_INACTIVE    = NK_FLAG(2), /* widget is neither active nor hovered */
    NK_WIDGET_STATE_ENTERED     = NK_FLAG(3), /* widget has been hovered on the current frame */
    NK_WIDGET_STATE_HOVER       = NK_FLAG(4), /* widget is being hovered */
    NK_WIDGET_STATE_ACTIVED     = NK_FLAG(5),/* widget is currently activated */
    NK_WIDGET_STATE_LEFT        = NK_FLAG(6), /* widget is from this frame on not hovered anymore */
    NK_WIDGET_STATE_HOVERED     = NK_WIDGET_STATE_HOVER|NK_WIDGET_STATE_MODIFIED, /* widget is being hovered */
    NK_WIDGET_STATE_ACTIVE      = NK_WIDGET_STATE_ACTIVED|NK_WIDGET_STATE_MODIFIED /* widget is currently activated */
}
alias NK_WIDGET_STATE_MODIFIED = nk_widget_states.NK_WIDGET_STATE_MODIFIED;
alias NK_WIDGET_STATE_INACTIVE = nk_widget_states.NK_WIDGET_STATE_INACTIVE;
alias NK_WIDGET_STATE_ENTERED = nk_widget_states.NK_WIDGET_STATE_ENTERED;
alias NK_WIDGET_STATE_HOVER = nk_widget_states.NK_WIDGET_STATE_HOVER;
alias NK_WIDGET_STATE_ACTIVED = nk_widget_states.NK_WIDGET_STATE_ACTIVED;
alias NK_WIDGET_STATE_LEFT = nk_widget_states.NK_WIDGET_STATE_LEFT;
alias NK_WIDGET_STATE_HOVERED = nk_widget_states.NK_WIDGET_STATE_HOVERED;
alias NK_WIDGET_STATE_ACTIVE = nk_widget_states.NK_WIDGET_STATE_ACTIVE;

/* =============================================================================
 *
 *                                  TEXT
 *
 * ============================================================================= */

enum nk_text_align {
    NK_TEXT_ALIGN_LEFT        = 0x01,
    NK_TEXT_ALIGN_CENTERED    = 0x02,
    NK_TEXT_ALIGN_RIGHT       = 0x04,
    NK_TEXT_ALIGN_TOP         = 0x08,
    NK_TEXT_ALIGN_MIDDLE      = 0x10,
    NK_TEXT_ALIGN_BOTTOM      = 0x20
}
alias NK_TEXT_ALIGN_LEFT = nk_text_align.NK_TEXT_ALIGN_LEFT;
alias NK_TEXT_ALIGN_CENTERED = nk_text_align.NK_TEXT_ALIGN_CENTERED;
alias NK_TEXT_ALIGN_RIGHT = nk_text_align.NK_TEXT_ALIGN_RIGHT;
alias NK_TEXT_ALIGN_TOP = nk_text_align.NK_TEXT_ALIGN_TOP;
alias NK_TEXT_ALIGN_MIDDLE = nk_text_align.NK_TEXT_ALIGN_MIDDLE;
alias NK_TEXT_ALIGN_BOTTOM = nk_text_align.NK_TEXT_ALIGN_BOTTOM;

enum nk_text_alignment {
    NK_TEXT_LEFT        = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_LEFT,
    NK_TEXT_CENTERED    = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_CENTERED,
    NK_TEXT_RIGHT       = NK_TEXT_ALIGN_MIDDLE|NK_TEXT_ALIGN_RIGHT
}
alias NK_TEXT_LEFT = nk_text_alignment.NK_TEXT_LEFT;
alias NK_TEXT_CENTERED = nk_text_alignment.NK_TEXT_CENTERED;
alias NK_TEXT_RIGHT = nk_text_alignment.NK_TEXT_RIGHT;

/* =============================================================================
 *
 *                                  TEXT EDIT
 *
 * ============================================================================= */

enum nk_edit_flags {
    NK_EDIT_DEFAULT                 = 0,
    NK_EDIT_READ_ONLY               = NK_FLAG(0),
    NK_EDIT_AUTO_SELECT             = NK_FLAG(1),
    NK_EDIT_SIG_ENTER               = NK_FLAG(2),
    NK_EDIT_ALLOW_TAB               = NK_FLAG(3),
    NK_EDIT_NO_CURSOR               = NK_FLAG(4),
    NK_EDIT_SELECTABLE              = NK_FLAG(5),
    NK_EDIT_CLIPBOARD               = NK_FLAG(6),
    NK_EDIT_CTRL_ENTER_NEWLINE      = NK_FLAG(7),
    NK_EDIT_NO_HORIZONTAL_SCROLL    = NK_FLAG(8),
    NK_EDIT_ALWAYS_INSERT_MODE      = NK_FLAG(9),
    NK_EDIT_MULTILINE               = NK_FLAG(10),
    NK_EDIT_GOTO_END_ON_ACTIVATE    = NK_FLAG(11)
}
alias NK_EDIT_DEFAULT = nk_edit_flags.NK_EDIT_DEFAULT;
alias NK_EDIT_READ_ONLY = nk_edit_flags.NK_EDIT_READ_ONLY;
alias NK_EDIT_AUTO_SELECT = nk_edit_flags.NK_EDIT_AUTO_SELECT;
alias NK_EDIT_SIG_ENTER = nk_edit_flags.NK_EDIT_SIG_ENTER;
alias NK_EDIT_ALLOW_TAB = nk_edit_flags.NK_EDIT_ALLOW_TAB;
alias NK_EDIT_NO_CURSOR = nk_edit_flags.NK_EDIT_NO_CURSOR;
alias NK_EDIT_SELECTABLE = nk_edit_flags.NK_EDIT_SELECTABLE;
alias NK_EDIT_CLIPBOARD = nk_edit_flags.NK_EDIT_CLIPBOARD;
alias NK_EDIT_CTRL_ENTER_NEWLINE = nk_edit_flags.NK_EDIT_CTRL_ENTER_NEWLINE;
alias NK_EDIT_NO_HORIZONTAL_SCROLL = nk_edit_flags.NK_EDIT_NO_HORIZONTAL_SCROLL;
alias NK_EDIT_ALWAYS_INSERT_MODE = nk_edit_flags.NK_EDIT_ALWAYS_INSERT_MODE;
alias NK_EDIT_MULTILINE = nk_edit_flags.NK_EDIT_MULTILINE;
alias NK_EDIT_GOTO_END_ON_ACTIVATE = nk_edit_flags.NK_EDIT_GOTO_END_ON_ACTIVATE;

enum nk_edit_types {
    NK_EDIT_SIMPLE  = NK_EDIT_ALWAYS_INSERT_MODE,
    NK_EDIT_FIELD   = cast(nk_edit_types)(NK_EDIT_SIMPLE|NK_EDIT_SELECTABLE|NK_EDIT_CLIPBOARD),
    NK_EDIT_BOX     = NK_EDIT_ALWAYS_INSERT_MODE| NK_EDIT_SELECTABLE| NK_EDIT_MULTILINE|NK_EDIT_ALLOW_TAB|NK_EDIT_CLIPBOARD,
    NK_EDIT_EDITOR  = NK_EDIT_SELECTABLE|NK_EDIT_MULTILINE|NK_EDIT_ALLOW_TAB| NK_EDIT_CLIPBOARD
}
alias NK_EDIT_SIMPLE = nk_edit_types.NK_EDIT_SIMPLE;
alias NK_EDIT_FIELD = nk_edit_types.NK_EDIT_FIELD;
alias NK_EDIT_BOX = nk_edit_types.NK_EDIT_BOX;
alias NK_EDIT_EDITOR = nk_edit_types.NK_EDIT_EDITOR;

enum nk_edit_events {
    NK_EDIT_ACTIVE      = NK_FLAG(0), /* edit widget is currently being modified */
    NK_EDIT_INACTIVE    = NK_FLAG(1), /* edit widget is not active and is not being modified */
    NK_EDIT_ACTIVATED   = NK_FLAG(2), /* edit widget went from state inactive to state active */
    NK_EDIT_DEACTIVATED = NK_FLAG(3), /* edit widget went from state active to state inactive */
    NK_EDIT_COMMITED    = NK_FLAG(4) /* edit widget has received an enter and lost focus */
}
alias NK_EDIT_ACTIVE = nk_edit_events.NK_EDIT_ACTIVE;
alias NK_EDIT_INACTIVE = nk_edit_events.NK_EDIT_INACTIVE;
alias NK_EDIT_ACTIVATED = nk_edit_events.NK_EDIT_ACTIVATED;
alias NK_EDIT_DEACTIVATED = nk_edit_events.NK_EDIT_DEACTIVATED;
alias NK_EDIT_COMMITED = nk_edit_events.NK_EDIT_COMMITED;

/* =============================================================================
 *
 *                                  STYLE
 *
 * ============================================================================= */

enum nk_style_colors {
    NK_COLOR_TEXT,
    NK_COLOR_WINDOW,
    NK_COLOR_HEADER,
    NK_COLOR_BORDER,
    NK_COLOR_BUTTON,
    NK_COLOR_BUTTON_HOVER,
    NK_COLOR_BUTTON_ACTIVE,
    NK_COLOR_TOGGLE,
    NK_COLOR_TOGGLE_HOVER,
    NK_COLOR_TOGGLE_CURSOR,
    NK_COLOR_SELECT,
    NK_COLOR_SELECT_ACTIVE,
    NK_COLOR_SLIDER,
    NK_COLOR_SLIDER_CURSOR,
    NK_COLOR_SLIDER_CURSOR_HOVER,
    NK_COLOR_SLIDER_CURSOR_ACTIVE,
    NK_COLOR_PROPERTY,
    NK_COLOR_EDIT,
    NK_COLOR_EDIT_CURSOR,
    NK_COLOR_COMBO,
    NK_COLOR_CHART,
    NK_COLOR_CHART_COLOR,
    NK_COLOR_CHART_COLOR_HIGHLIGHT,
    NK_COLOR_SCROLLBAR,
    NK_COLOR_SCROLLBAR_CURSOR,
    NK_COLOR_SCROLLBAR_CURSOR_HOVER,
    NK_COLOR_SCROLLBAR_CURSOR_ACTIVE,
    NK_COLOR_TAB_HEADER,
    NK_COLOR_COUNT
}
alias NK_COLOR_TEXT = nk_style_colors.NK_COLOR_TEXT;
alias NK_COLOR_WINDOW = nk_style_colors.NK_COLOR_WINDOW;
alias NK_COLOR_HEADER = nk_style_colors.NK_COLOR_HEADER;
alias NK_COLOR_BORDER = nk_style_colors.NK_COLOR_BORDER;
alias NK_COLOR_BUTTON = nk_style_colors.NK_COLOR_BUTTON;
alias NK_COLOR_BUTTON_HOVER = nk_style_colors.NK_COLOR_BUTTON_HOVER;
alias NK_COLOR_BUTTON_ACTIVE = nk_style_colors.NK_COLOR_BUTTON_ACTIVE;
alias NK_COLOR_TOGGLE = nk_style_colors.NK_COLOR_TOGGLE;
alias NK_COLOR_TOGGLE_HOVER = nk_style_colors.NK_COLOR_TOGGLE_HOVER;
alias NK_COLOR_TOGGLE_CURSOR = nk_style_colors.NK_COLOR_TOGGLE_CURSOR;
alias NK_COLOR_SELECT = nk_style_colors.NK_COLOR_SELECT;
alias NK_COLOR_SELECT_ACTIVE = nk_style_colors.NK_COLOR_SELECT_ACTIVE;
alias NK_COLOR_SLIDER = nk_style_colors.NK_COLOR_SLIDER;
alias NK_COLOR_SLIDER_CURSOR = nk_style_colors.NK_COLOR_SLIDER_CURSOR;
alias NK_COLOR_SLIDER_CURSOR_HOVER = nk_style_colors.NK_COLOR_SLIDER_CURSOR_HOVER;
alias NK_COLOR_SLIDER_CURSOR_ACTIVE = nk_style_colors.NK_COLOR_SLIDER_CURSOR_ACTIVE;
alias NK_COLOR_PROPERTY = nk_style_colors.NK_COLOR_PROPERTY;
alias NK_COLOR_EDIT = nk_style_colors.NK_COLOR_EDIT;
alias NK_COLOR_EDIT_CURSOR = nk_style_colors.NK_COLOR_EDIT_CURSOR;
alias NK_COLOR_COMBO = nk_style_colors.NK_COLOR_COMBO;
alias NK_COLOR_CHART = nk_style_colors.NK_COLOR_CHART;
alias NK_COLOR_CHART_COLOR = nk_style_colors.NK_COLOR_CHART_COLOR;
alias NK_COLOR_CHART_COLOR_HIGHLIGHT = nk_style_colors.NK_COLOR_CHART_COLOR_HIGHLIGHT;
alias NK_COLOR_SCROLLBAR = nk_style_colors.NK_COLOR_SCROLLBAR;
alias NK_COLOR_SCROLLBAR_CURSOR = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR;
alias NK_COLOR_SCROLLBAR_CURSOR_HOVER = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_HOVER;
alias NK_COLOR_SCROLLBAR_CURSOR_ACTIVE = nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_ACTIVE;
alias NK_COLOR_TAB_HEADER = nk_style_colors.NK_COLOR_TAB_HEADER;
alias NK_COLOR_COUNT = nk_style_colors.NK_COLOR_COUNT;

enum nk_style_cursor {
    NK_CURSOR_ARROW,
    NK_CURSOR_TEXT,
    NK_CURSOR_MOVE,
    NK_CURSOR_RESIZE_VERTICAL,
    NK_CURSOR_RESIZE_HORIZONTAL,
    NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT,
    NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT,
    NK_CURSOR_COUNT
}
alias NK_CURSOR_ARROW = nk_style_cursor.NK_CURSOR_ARROW;
alias NK_CURSOR_TEXT = nk_style_cursor.NK_CURSOR_TEXT;
alias NK_CURSOR_MOVE = nk_style_cursor.NK_CURSOR_MOVE;
alias NK_CURSOR_RESIZE_VERTICAL = nk_style_cursor.NK_CURSOR_RESIZE_VERTICAL;
alias NK_CURSOR_RESIZE_HORIZONTAL = nk_style_cursor.NK_CURSOR_RESIZE_HORIZONTAL;
alias NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT = nk_style_cursor.NK_CURSOR_RESIZE_TOP_LEFT_DOWN_RIGHT;
alias NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT = nk_style_cursor.NK_CURSOR_RESIZE_TOP_RIGHT_DOWN_LEFT;
alias NK_CURSOR_COUNT = nk_style_cursor.NK_CURSOR_COUNT;

/* ===============================================================
 *
 *                          FONT
 *
 * ===============================================================*/

struct nk_user_font_glyph;
alias nk_text_width_f = float function(nk_handle, float h, const(char)*, int len);
alias nk_query_font_glyph_f = void function(nk_handle handle, float font_height, nk_user_font_glyph* glyph, nk_rune codepoint, nk_rune next_codepoint);

version(NK_INCLUDE_VERTEX_BUFFER_OUTPUT) 
{
    struct nk_user_font_glyph {
        nk_vec2[2] uv;
        /* texture coordinates */
        nk_vec2 offset;
        /* offset between top left and glyph */
        float width, height;
        /* size of the glyph  */
        float xadvance;
        /* offset to the next glyph */
    }
}
else version(NK_INCLUDE_SOFTWARE_FONT)
{
    struct nk_user_font_glyph {
        nk_vec2[2] uv;
        /* texture coordinates */
        nk_vec2 offset;
        /* offset between top left and glyph */
        float width, height;
        /* size of the glyph  */
        float xadvance;
        /* offset to the next glyph */
    }
}

struct nk_user_font {
    nk_handle userdata;
    /* user provided font handle */
    float height = 0;
    /* max height of the font */
    nk_text_width_f width;
    /* font string width in pixel callback */
    version (NK_INCLUDE_VERTEX_BUFFER_OUTPUT) {
        nk_query_font_glyph_f query;
        /* font glyph callback to query drawing info */
        nk_handle texture;
        /* texture handle to the used font atlas or texture */
    }
}

version (NK_INCLUDE_FONT_BAKING) {
    enum nk_font_coord_type {
        NK_COORD_UV, /* texture coordinates inside font glyphs are clamped between 0-1 */
        NK_COORD_PIXEL /* texture coordinates inside font glyphs are in absolute pixel */
    }
    alias NK_COORD_UV = nk_font_coord_type.NK_COORD_UV;
    alias NK_COORD_PIXEL = nk_font_coord_type.NK_COORD_PIXEL;


    struct nk_font;
    struct nk_baked_font {
        float height = 0;
        /* height of the font  */
        float ascent = 0, descent = 0;
        /* font glyphs ascent and descent  */
        nk_rune glyph_offset;
        /* glyph array offset inside the font glyph baking output array  */
        nk_rune glyph_count;
        /* number of glyphs of this font inside the glyph baking array output */
        const(nk_rune)* ranges;
        /* font codepoint ranges as pairs of (from/to) and 0 as last element */
    }

    struct nk_font_config {
        nk_font_config* next;
        /* NOTE: only used internally */
        void* ttf_blob;
        /* pointer to loaded TTF file memory block.
        * NOTE: not needed for nk_font_atlas_add_from_memory and nk_font_atlas_add_from_file. */
        nk_size ttf_size;
        /* size of the loaded TTF file memory block
        * NOTE: not needed for nk_font_atlas_add_from_memory and nk_font_atlas_add_from_file. */

        ubyte ttf_data_owned_by_atlas;
        /* used inside font atlas: default to: 0*/
        ubyte merge_mode;
        /* merges this font into the last font */
        ubyte pixel_snap;
        /* align every character to pixel boundary (if true set oversample (1,1)) */
        ubyte oversample_v, oversample_h;
        /* rasterize at high quality for sub-pixel position */
        ubyte[3] padding;

        float size = 0;
        /* baked pixel height of the font */
        nk_font_coord_type coord_type;
        /* texture coordinate format with either pixel or UV coordinates */
        nk_vec2 spacing;
        /* extra pixel spacing between glyphs  */
        const(nk_rune)* range;
        /* list of unicode ranges (2 values per range, zero terminated) */
        nk_baked_font* font;
        /* font to setup in the baking process: NOTE: not needed for font atlas */
        nk_rune fallback_glyph;
        /* fallback glyph to use if a given rune is not found */
        nk_font_config* n;
        nk_font_config* p;
    }

    struct nk_font_glyph {
        nk_rune codepoint;
        float xadvance = 0;
        float x0 = 0, y0 = 0, x1 = 0, y1 = 0, w = 0, h = 0;
        float u0 = 0, v0 = 0, u1 = 0, v1 = 0;
    }

    struct nk_font {
        nk_font* next;
        nk_user_font handle;
        nk_baked_font info;
        float scale = 0;
        nk_font_glyph* glyphs;
        const(nk_font_glyph)* fallback;
        nk_rune fallback_codepoint;
        nk_handle texture;
        nk_font_config* config;
    }

    enum nk_font_atlas_format {
        NK_FONT_ATLAS_ALPHA8,
        NK_FONT_ATLAS_RGBA32
    }
    alias NK_FONT_ATLAS_ALPHA8 = nk_font_atlas_format.NK_FONT_ATLAS_ALPHA8;
    alias NK_FONT_ATLAS_RGBA32 = nk_font_atlas_format.NK_FONT_ATLAS_RGBA32;


    struct nk_font_atlas {
        void* pixel;
        int tex_width;
        int tex_height;

        nk_allocator permanent;
        nk_allocator temporary;

        nk_recti custom;
        nk_cursor[NK_CURSOR_COUNT] cursors;

        int glyph_count;
        nk_font_glyph* glyphs;
        nk_font* default_font;
        nk_font* fonts;
        nk_font_config* config;
        int font_num;
    }
}

/* ==============================================================
 *
 *                          MEMORY BUFFER
 *
 * ===============================================================*/
/*/// ### Memory Buffer
/// A basic (double)-buffer with linear allocation and resetting as only
/// freeing policy. The buffer's main purpose is to control all memory management
/// inside the GUI toolkit and still leave memory control as much as possible in
/// the hand of the user while also making sure the library is easy to use if
/// not as much control is needed.
/// In general all memory inside this library can be provided from the user in
/// three different ways.
/// 
/// The first way and the one providing most control is by just passing a fixed
/// size memory block. In this case all control lies in the hand of the user
/// since he can exactly control where the memory comes from and how much memory
/// the library should consume. Of course using the fixed size API removes the
/// ability to automatically resize a buffer if not enough memory is provided so
/// you have to take over the resizing. While being a fixed sized buffer sounds
/// quite limiting, it is very effective in this library since the actual memory
/// consumption is quite stable and has a fixed upper bound for a lot of cases.
/// 
/// If you don't want to think about how much memory the library should allocate
/// at all time or have a very dynamic UI with unpredictable memory consumption
/// habits but still want control over memory allocation you can use the dynamic
/// allocator based API. The allocator consists of two callbacks for allocating
/// and freeing memory and optional userdata so you can plugin your own allocator.
/// 
/// The final and easiest way can be used by defining
/// NK_INCLUDE_DEFAULT_ALLOCATOR which uses the standard library memory
/// allocation functions malloc and free and takes over complete control over
/// memory in this library.
*/
struct nk_memory_status {
    void* memory;
    uint type;
    nk_size size;
    nk_size allocated;
    nk_size needed;
    nk_size calls;
}

enum nk_allocation_type {
    NK_BUFFER_FIXED,
    NK_BUFFER_DYNAMIC
}
alias NK_BUFFER_FIXED = nk_allocation_type.NK_BUFFER_FIXED;
alias NK_BUFFER_DYNAMIC = nk_allocation_type.NK_BUFFER_DYNAMIC;


enum nk_buffer_allocation_type {
    NK_BUFFER_FRONT,
    NK_BUFFER_BACK,
    NK_BUFFER_MAX
}
alias NK_BUFFER_FRONT = nk_buffer_allocation_type.NK_BUFFER_FRONT;
alias NK_BUFFER_BACK = nk_buffer_allocation_type.NK_BUFFER_BACK;
alias NK_BUFFER_MAX = nk_buffer_allocation_type.NK_BUFFER_MAX;


struct nk_buffer_marker {
    nk_bool active;
    nk_size offset;
}

struct nk_memory {void* ptr;nk_size size;}
struct nk_buffer {
    nk_buffer_marker[NK_BUFFER_MAX] marker;
    /* buffer marker to free a buffer to a certain offset */
    nk_allocator pool;
    /* allocator callback for dynamic buffers */
    nk_allocation_type type;
    /* memory management type */
    nk_memory memory;
    /* memory and size of the current memory block */
    float grow_factor = 0;
    /* growing factor for dynamic memory management */
    nk_size allocated;
    /* total amount of memory allocated */
    nk_size needed;
    /* totally consumed memory given that enough memory is present */
    nk_size calls;
    /* number of allocation calls */
    nk_size size;
    /* current size of the buffer */
}

/* ==============================================================
 *
 *                          STRING
 *
 * ===============================================================*/
/*  Basic string buffer which is only used in context with the text editor
 *  to manage and manipulate dynamic or fixed size string content. This is _NOT_
 *  the default string handling method. The only instance you should have any contact
 *  with this API is if you interact with an `nk_text_edit` object inside one of the
 *  copy and paste functions and even there only for more advanced cases. */
struct nk_str {
    nk_buffer buffer;
    int len; /* in codepoints/runes/glyphs */
}

/*===============================================================
 *
 *                      TEXT EDITOR
 *
 * ===============================================================*/

enum NK_TEXTEDIT_UNDOSTATECOUNT =     99;
enum NK_TEXTEDIT_UNDOCHARCOUNT =      999;

struct nk_clipboard {
    nk_handle userdata;
    nk_plugin_paste paste;
    nk_plugin_copy copy;
}

struct nk_text_undo_record {
   int where;
   short insert_length;
   short delete_length;
   short char_storage;
}

struct nk_text_undo_state {
   nk_text_undo_record[NK_TEXTEDIT_UNDOSTATECOUNT] undo_rec;
   nk_rune[NK_TEXTEDIT_UNDOCHARCOUNT] undo_char;
   short undo_point;
   short redo_point;
   short undo_char_point;
   short redo_char_point;
}

enum nk_text_edit_type {
    NK_TEXT_EDIT_SINGLE_LINE,
    NK_TEXT_EDIT_MULTI_LINE
}
alias NK_TEXT_EDIT_SINGLE_LINE = nk_text_edit_type.NK_TEXT_EDIT_SINGLE_LINE;
alias NK_TEXT_EDIT_MULTI_LINE = nk_text_edit_type.NK_TEXT_EDIT_MULTI_LINE;


enum nk_text_edit_mode {
    NK_TEXT_EDIT_MODE_VIEW,
    NK_TEXT_EDIT_MODE_INSERT,
    NK_TEXT_EDIT_MODE_REPLACE
}
alias NK_TEXT_EDIT_MODE_VIEW = nk_text_edit_mode.NK_TEXT_EDIT_MODE_VIEW;
alias NK_TEXT_EDIT_MODE_INSERT = nk_text_edit_mode.NK_TEXT_EDIT_MODE_INSERT;
alias NK_TEXT_EDIT_MODE_REPLACE = nk_text_edit_mode.NK_TEXT_EDIT_MODE_REPLACE;


struct nk_text_edit {
    nk_clipboard clip;
    nk_str string;
    nk_plugin_filter filter;
    nk_vec2 scrollbar;

    int cursor;
    int select_start;
    int select_end;
    ubyte mode;
    ubyte cursor_at_end_of_line;
    ubyte initialized;
    ubyte has_preferred_x;
    ubyte single_line;
    ubyte active;
    ubyte padding1;
    float preferred_x = 0;
    nk_text_undo_state undo;
}

/* ===============================================================
 *
 *                          DRAWING
 *
 * ===============================================================*/

enum nk_command_type {
    NK_COMMAND_NOP,
    NK_COMMAND_SCISSOR,
    NK_COMMAND_LINE,
    NK_COMMAND_CURVE,
    NK_COMMAND_RECT,
    NK_COMMAND_RECT_FILLED,
    NK_COMMAND_RECT_MULTI_COLOR,
    NK_COMMAND_CIRCLE,
    NK_COMMAND_CIRCLE_FILLED,
    NK_COMMAND_ARC,
    NK_COMMAND_ARC_FILLED,
    NK_COMMAND_TRIANGLE,
    NK_COMMAND_TRIANGLE_FILLED,
    NK_COMMAND_POLYGON,
    NK_COMMAND_POLYGON_FILLED,
    NK_COMMAND_POLYLINE,
    NK_COMMAND_TEXT,
    NK_COMMAND_IMAGE,
    NK_COMMAND_CUSTOM
}
alias NK_COMMAND_NOP = nk_command_type.NK_COMMAND_NOP;
alias NK_COMMAND_SCISSOR = nk_command_type.NK_COMMAND_SCISSOR;
alias NK_COMMAND_LINE = nk_command_type.NK_COMMAND_LINE;
alias NK_COMMAND_CURVE = nk_command_type.NK_COMMAND_CURVE;
alias NK_COMMAND_RECT = nk_command_type.NK_COMMAND_RECT;
alias NK_COMMAND_RECT_FILLED = nk_command_type.NK_COMMAND_RECT_FILLED;
alias NK_COMMAND_RECT_MULTI_COLOR = nk_command_type.NK_COMMAND_RECT_MULTI_COLOR;
alias NK_COMMAND_CIRCLE = nk_command_type.NK_COMMAND_CIRCLE;
alias NK_COMMAND_CIRCLE_FILLED = nk_command_type.NK_COMMAND_CIRCLE_FILLED;
alias NK_COMMAND_ARC = nk_command_type.NK_COMMAND_ARC;
alias NK_COMMAND_ARC_FILLED = nk_command_type.NK_COMMAND_ARC_FILLED;
alias NK_COMMAND_TRIANGLE = nk_command_type.NK_COMMAND_TRIANGLE;
alias NK_COMMAND_TRIANGLE_FILLED = nk_command_type.NK_COMMAND_TRIANGLE_FILLED;
alias NK_COMMAND_POLYGON = nk_command_type.NK_COMMAND_POLYGON;
alias NK_COMMAND_POLYGON_FILLED = nk_command_type.NK_COMMAND_POLYGON_FILLED;
alias NK_COMMAND_POLYLINE = nk_command_type.NK_COMMAND_POLYLINE;
alias NK_COMMAND_TEXT = nk_command_type.NK_COMMAND_TEXT;
alias NK_COMMAND_IMAGE = nk_command_type.NK_COMMAND_IMAGE;
alias NK_COMMAND_CUSTOM = nk_command_type.NK_COMMAND_CUSTOM;


/* command base and header of every command inside the buffer */
struct nk_command {
    nk_command_type type;
    nk_size next;
version (NK_INCLUDE_COMMAND_USERDATA) {
    nk_handle userdata;
}
}

struct nk_command_scissor {
    nk_command header;
    short x, y;
    ushort w, h;
}

struct nk_command_line {
    nk_command header;
    ushort line_thickness;
    nk_vec2i begin;
    nk_vec2i end;
    nk_color color;
}

struct nk_command_curve {
    nk_command header;
    ushort line_thickness;
    nk_vec2i begin;
    nk_vec2i end;
    nk_vec2i[2] ctrl;
    nk_color color;
}

struct nk_command_rect {
    nk_command header;
    ushort rounding;
    ushort line_thickness;
    short x, y;
    ushort w, h;
    nk_color color;
}

struct nk_command_rect_filled {
    nk_command header;
    ushort rounding;
    short x, y;
    ushort w, h;
    nk_color color;
}

struct nk_command_rect_multi_color {
    nk_command header;
    short x, y;
    ushort w, h;
    nk_color left;
    nk_color top;
    nk_color bottom;
    nk_color right;
}

struct nk_command_triangle {
    nk_command header;
    ushort line_thickness;
    nk_vec2i a;
    nk_vec2i b;
    nk_vec2i c;
    nk_color color;
}

struct nk_command_triangle_filled {
    nk_command header;
    nk_vec2i a;
    nk_vec2i b;
    nk_vec2i c;
    nk_color color;
}

struct nk_command_circle {
    nk_command header;
    short x, y;
    ushort line_thickness;
    ushort w, h;
    nk_color color;
}

struct nk_command_circle_filled {
    nk_command header;
    short x, y;
    ushort w, h;
    nk_color color;
}

struct nk_command_arc {
    nk_command header;
    short cx, cy;
    ushort r;
    ushort line_thickness;
    float[2] a = 0;
    nk_color color;
}

struct nk_command_arc_filled {
    nk_command header;
    short cx, cy;
    ushort r;
    float[2] a = 0;
    nk_color color;
}

struct nk_command_polygon {
    nk_command header;
    nk_color color;
    ushort line_thickness;
    ushort point_count;
    nk_vec2i[1] points;
}

struct nk_command_polygon_filled {
    nk_command header;
    nk_color color;
    ushort point_count;
    nk_vec2i[1] points;
}

struct nk_command_polyline {
    nk_command header;
    nk_color color;
    ushort line_thickness;
    ushort point_count;
    nk_vec2i[1] points;
}

struct nk_command_image {
    nk_command header;
    short x, y;
    ushort w, h;
    nk_image img;
    nk_color col;
}

alias nk_command_custom_callback = void function(void* canvas, short x, short y, ushort w, ushort h, nk_handle callback_data);
struct nk_command_custom {
    nk_command header;
    short x, y;
    ushort w, h;
    nk_handle callback_data;
    nk_command_custom_callback callback;
}

struct nk_command_text {
    nk_command header;
    const(nk_user_font)* font;
    nk_color background;
    nk_color foreground;
    short x, y;
    ushort w, h;
    float height = 0;
    int length;
    char[1] string = 0;
}

enum nk_command_clipping {
    NK_CLIPPING_OFF = nk_false,
    NK_CLIPPING_ON = nk_true
}
alias NK_CLIPPING_OFF = nk_command_clipping.NK_CLIPPING_OFF;
alias NK_CLIPPING_ON = nk_command_clipping.NK_CLIPPING_ON;


struct nk_command_buffer {
    nk_buffer* base;
    nk_rect clip;
    int use_clipping;
    nk_handle userdata;
    nk_size begin, end, last;
}

/* ===============================================================
 *
 *                          INPUT
 *
 * ===============================================================*/
struct nk_mouse_button {
    nk_bool down;
    uint clicked;
    nk_vec2 clicked_pos;
}
struct nk_mouse {
    nk_mouse_button[NK_BUTTON_MAX] buttons;
    nk_vec2 pos;
version (NK_BUTTON_TRIGGER_ON_RELEASE) {
    nk_vec2 down_pos;
}
    nk_vec2 prev;
    nk_vec2 delta;
    nk_vec2 scroll_delta;
    ubyte grab;
    ubyte grabbed;
    ubyte ungrab;
}

struct nk_key {
    nk_bool down;
    uint clicked;
}
struct nk_keyboard {
    nk_key[NK_KEY_MAX] keys;
    char[NK_INPUT_MAX] text = 0;
    int text_len;
}

struct nk_input {
    nk_keyboard keyboard;
    nk_mouse mouse;
}

/* ===============================================================
 *
 *                          DRAW LIST
 *
 * ===============================================================*/
version (NK_INCLUDE_VERTEX_BUFFER_OUTPUT) {
    version (NK_UINT_DRAW_INDEX) {
        alias nk_draw_index = nk_uint;
    } else {
        alias nk_draw_index = nk_ushort;
    }

    enum nk_draw_list_stroke {
        NK_STROKE_OPEN = nk_false,
        /* build up path has no connection back to the beginning */
        NK_STROKE_CLOSED = nk_true
        /* build up path has a connection back to the beginning */
    }
    alias NK_STROKE_OPEN = nk_draw_list_stroke.NK_STROKE_OPEN;
    alias NK_STROKE_CLOSED = nk_draw_list_stroke.NK_STROKE_CLOSED;


    enum nk_draw_vertex_layout_attribute {
        NK_VERTEX_POSITION,
        NK_VERTEX_COLOR,
        NK_VERTEX_TEXCOORD,
        NK_VERTEX_ATTRIBUTE_COUNT
    }
    alias NK_VERTEX_POSITION = nk_draw_vertex_layout_attribute.NK_VERTEX_POSITION;
    alias NK_VERTEX_COLOR = nk_draw_vertex_layout_attribute.NK_VERTEX_COLOR;
    alias NK_VERTEX_TEXCOORD = nk_draw_vertex_layout_attribute.NK_VERTEX_TEXCOORD;
    alias NK_VERTEX_ATTRIBUTE_COUNT = nk_draw_vertex_layout_attribute.NK_VERTEX_ATTRIBUTE_COUNT;


    enum nk_draw_vertex_layout_format {
        NK_FORMAT_SCHAR,
        NK_FORMAT_SSHORT,
        NK_FORMAT_SINT,
        NK_FORMAT_UCHAR,
        NK_FORMAT_USHORT,
        NK_FORMAT_UINT,
        NK_FORMAT_FLOAT,
        NK_FORMAT_DOUBLE,

    NK_FORMAT_COLOR_BEGIN,
        NK_FORMAT_R8G8B8 = NK_FORMAT_COLOR_BEGIN,
        NK_FORMAT_R16G15B16,
        NK_FORMAT_R32G32B32,

        NK_FORMAT_R8G8B8A8,
        NK_FORMAT_B8G8R8A8,
        NK_FORMAT_R16G15B16A16,
        NK_FORMAT_R32G32B32A32,
        NK_FORMAT_R32G32B32A32_FLOAT,
        NK_FORMAT_R32G32B32A32_DOUBLE,

        NK_FORMAT_RGB32,
        NK_FORMAT_RGBA32,
        NK_FORMAT_COLOR_END = NK_FORMAT_RGBA32,
        NK_FORMAT_COUNT
    }
    alias NK_FORMAT_SCHAR = nk_draw_vertex_layout_format.NK_FORMAT_SCHAR;
    alias NK_FORMAT_SSHORT = nk_draw_vertex_layout_format.NK_FORMAT_SSHORT;
    alias NK_FORMAT_SINT = nk_draw_vertex_layout_format.NK_FORMAT_SINT;
    alias NK_FORMAT_UCHAR = nk_draw_vertex_layout_format.NK_FORMAT_UCHAR;
    alias NK_FORMAT_USHORT = nk_draw_vertex_layout_format.NK_FORMAT_USHORT;
    alias NK_FORMAT_UINT = nk_draw_vertex_layout_format.NK_FORMAT_UINT;
    alias NK_FORMAT_FLOAT = nk_draw_vertex_layout_format.NK_FORMAT_FLOAT;
    alias NK_FORMAT_DOUBLE = nk_draw_vertex_layout_format.NK_FORMAT_DOUBLE;
    alias NK_FORMAT_COLOR_BEGIN = nk_draw_vertex_layout_format.NK_FORMAT_COLOR_BEGIN;
    alias NK_FORMAT_R8G8B8 = nk_draw_vertex_layout_format.NK_FORMAT_R8G8B8;
    alias NK_FORMAT_R16G15B16 = nk_draw_vertex_layout_format.NK_FORMAT_R16G15B16;
    alias NK_FORMAT_R32G32B32 = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32;
    alias NK_FORMAT_R8G8B8A8 = nk_draw_vertex_layout_format.NK_FORMAT_R8G8B8A8;
    alias NK_FORMAT_B8G8R8A8 = nk_draw_vertex_layout_format.NK_FORMAT_B8G8R8A8;
    alias NK_FORMAT_R16G15B16A16 = nk_draw_vertex_layout_format.NK_FORMAT_R16G15B16A16;
    alias NK_FORMAT_R32G32B32A32 = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32A32;
    alias NK_FORMAT_R32G32B32A32_FLOAT = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32A32_FLOAT;
    alias NK_FORMAT_R32G32B32A32_DOUBLE = nk_draw_vertex_layout_format.NK_FORMAT_R32G32B32A32_DOUBLE;
    alias NK_FORMAT_RGB32 = nk_draw_vertex_layout_format.NK_FORMAT_RGB32;
    alias NK_FORMAT_RGBA32 = nk_draw_vertex_layout_format.NK_FORMAT_RGBA32;
    alias NK_FORMAT_COLOR_END = nk_draw_vertex_layout_format.NK_FORMAT_COLOR_END;
    alias NK_FORMAT_COUNT = nk_draw_vertex_layout_format.NK_FORMAT_COUNT;


    const(nk_draw_vertex_layout_element) NK_VERTEX_LAYOUT_END = { nk_draw_vertex_layout_attribute.NK_VERTEX_ATTRIBUTE_COUNT, nk_draw_vertex_layout_format.NK_FORMAT_COUNT, 0 };
    struct nk_draw_vertex_layout_element {
        nk_draw_vertex_layout_attribute attribute;
        nk_draw_vertex_layout_format format;
        nk_size offset;
    }

    struct nk_draw_command {
        uint elem_count;
        /* number of elements in the current draw batch */
        nk_rect clip_rect;
        /* current screen clipping rectangle */
        nk_handle texture;
        /* current texture to set */
        version (NK_INCLUDE_COMMAND_USERDATA) {
            nk_handle userdata;
        }
    }

    struct nk_draw_list {
        nk_rect clip_rect;
        nk_vec2[12] circle_vtx;
        nk_convert_config config;

        nk_buffer* buffer;
        nk_buffer* vertices;
        nk_buffer* elements;

        uint element_count;
        uint vertex_count;
        uint cmd_count;
        nk_size cmd_offset;

        uint path_count;
        uint path_offset;

        nk_anti_aliasing line_AA;
        nk_anti_aliasing shape_AA;

        version (NK_INCLUDE_COMMAND_USERDATA) {
            nk_handle userdata;
        }
    }
}

/* ===============================================================
 *
 *                          GUI
 *
 * ===============================================================*/
enum nk_style_item_type {
    NK_STYLE_ITEM_COLOR,
    NK_STYLE_ITEM_IMAGE,
    NK_STYLE_ITEM_NINE_SLICE
}
alias NK_STYLE_ITEM_COLOR = nk_style_item_type.NK_STYLE_ITEM_COLOR;
alias NK_STYLE_ITEM_IMAGE = nk_style_item_type.NK_STYLE_ITEM_IMAGE;
alias NK_STYLE_ITEM_NINE_SLICE = nk_style_item_type.NK_STYLE_ITEM_NINE_SLICE;


union nk_style_item_data {
    nk_color color;
    nk_image image;
    nk_nine_slice slice;
}

struct nk_style_item {
    nk_style_item_type type;
    nk_style_item_data data;
}

struct nk_style_text {
    nk_color color;
    nk_vec2 padding;
}

struct nk_style_button {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;

    /* text */
    nk_color text_background;
    nk_color text_normal;
    nk_color text_hover;
    nk_color text_active;
    nk_flags text_alignment;

    /* properties */
    float border = 0;
    float rounding = 0;
    nk_vec2 padding;
    nk_vec2 image_padding;
    nk_vec2 touch_padding;

    /* optional user callbacks */
    nk_handle userdata;
    void function(nk_command_buffer*, nk_handle userdata) draw_begin;
    void function(nk_command_buffer*, nk_handle userdata) draw_end;
}

struct nk_style_toggle {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;

    /* cursor */
    nk_style_item cursor_normal;
    nk_style_item cursor_hover;

    /* text */
    nk_color text_normal;
    nk_color text_hover;
    nk_color text_active;
    nk_color text_background;
    nk_flags text_alignment;

    /* properties */
    nk_vec2 padding;
    nk_vec2 touch_padding;
    float spacing = 0;
    float border = 0;

    /* optional user callbacks */
    nk_handle userdata;
    void function(nk_command_buffer*, nk_handle) draw_begin;
    void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_selectable {
    /* background (inactive) */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item pressed;

    /* background (active) */
    nk_style_item normal_active;
    nk_style_item hover_active;
    nk_style_item pressed_active;

    /* text color (inactive) */
    nk_color text_normal;
    nk_color text_hover;
    nk_color text_pressed;

    /* text color (active) */
    nk_color text_normal_active;
    nk_color text_hover_active;
    nk_color text_pressed_active;
    nk_color text_background;
    nk_flags text_alignment;

    /* properties */
    float rounding = 0;
    nk_vec2 padding;
    nk_vec2 touch_padding;
    nk_vec2 image_padding;

    /* optional user callbacks */
    nk_handle userdata;
    void function(nk_command_buffer*, nk_handle) draw_begin;
    void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_slider {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;

    /* background bar */
    nk_color bar_normal;
    nk_color bar_hover;
    nk_color bar_active;
    nk_color bar_filled;

    /* cursor */
    nk_style_item cursor_normal;
    nk_style_item cursor_hover;
    nk_style_item cursor_active;

    /* properties */
    float border = 0;
    float rounding = 0;
    float bar_height = 0;
    nk_vec2 padding;
    nk_vec2 spacing;
    nk_vec2 cursor_size;

    /* optional buttons */
    int show_buttons;
    nk_style_button inc_button;
    nk_style_button dec_button;
    nk_symbol_type inc_symbol;
    nk_symbol_type dec_symbol;

    /* optional user callbacks */
    nk_handle userdata;
    void function(nk_command_buffer*, nk_handle) draw_begin;
    void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_progress {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;

    /* cursor */
    nk_style_item cursor_normal;
    nk_style_item cursor_hover;
    nk_style_item cursor_active;
    nk_color cursor_border_color;

    /* properties */
    float rounding = 0;
    float border = 0;
    float cursor_border = 0;
    float cursor_rounding = 0;
    nk_vec2 padding;

    /* optional user callbacks */
    nk_handle userdata;
    void function(nk_command_buffer*, nk_handle) draw_begin;
    void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_scrollbar {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;

    /* cursor */
    nk_style_item cursor_normal;
    nk_style_item cursor_hover;
    nk_style_item cursor_active;
    nk_color cursor_border_color;

    /* properties */
    float border = 0;
    float rounding = 0;
    float border_cursor = 0;
    float rounding_cursor = 0;
    nk_vec2 padding;

    /* optional buttons */
    int show_buttons;
    nk_style_button inc_button;
    nk_style_button dec_button;
    nk_symbol_type inc_symbol;
    nk_symbol_type dec_symbol;

    /* optional user callbacks */
    nk_handle userdata;
    void function(nk_command_buffer*, nk_handle) draw_begin;
    void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_edit {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;
    nk_style_scrollbar scrollbar;

    /* cursor  */
    nk_color cursor_normal;
    nk_color cursor_hover;
    nk_color cursor_text_normal;
    nk_color cursor_text_hover;

    /* text (unselected) */
    nk_color text_normal;
    nk_color text_hover;
    nk_color text_active;

    /* text (selected) */
    nk_color selected_normal;
    nk_color selected_hover;
    nk_color selected_text_normal;
    nk_color selected_text_hover;

    /* properties */
    float border = 0;
    float rounding = 0;
    float cursor_size = 0;
    nk_vec2 scrollbar_size;
    nk_vec2 padding;
    float row_padding = 0;
}

struct nk_style_property {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;

    /* text */
    nk_color label_normal;
    nk_color label_hover;
    nk_color label_active;

    /* symbols */
    nk_symbol_type sym_left;
    nk_symbol_type sym_right;

    /* properties */
    float border = 0;
    float rounding = 0;
    nk_vec2 padding;

    nk_style_edit edit;
    nk_style_button inc_button;
    nk_style_button dec_button;

    /* optional user callbacks */
    nk_handle userdata;
    void function(nk_command_buffer*, nk_handle) draw_begin;
    void function(nk_command_buffer*, nk_handle) draw_end;
}

struct nk_style_chart {
    /* colors */
    nk_style_item background;
    nk_color border_color;
    nk_color selected_color;
    nk_color color;

    /* properties */
    float border = 0;
    float rounding = 0;
    nk_vec2 padding;
}

struct nk_style_combo {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;
    nk_color border_color;

    /* label */
    nk_color label_normal;
    nk_color label_hover;
    nk_color label_active;

    /* symbol */
    nk_color symbol_normal;
    nk_color symbol_hover;
    nk_color symbol_active;

    /* button */
    nk_style_button button;
    nk_symbol_type sym_normal;
    nk_symbol_type sym_hover;
    nk_symbol_type sym_active;

    /* properties */
    float border = 0;
    float rounding = 0;
    nk_vec2 content_padding;
    nk_vec2 button_padding;
    nk_vec2 spacing;
}

struct nk_style_tab {
    /* background */
    nk_style_item background;
    nk_color border_color;
    nk_color text;

    /* button */
    nk_style_button tab_maximize_button;
    nk_style_button tab_minimize_button;
    nk_style_button node_maximize_button;
    nk_style_button node_minimize_button;
    nk_symbol_type sym_minimize;
    nk_symbol_type sym_maximize;

    /* properties */
    float border = 0;
    float rounding = 0;
    float indent = 0;
    nk_vec2 padding;
    nk_vec2 spacing;
}

enum nk_style_header_align {
    NK_HEADER_LEFT,
    NK_HEADER_RIGHT
}
alias NK_HEADER_LEFT = nk_style_header_align.NK_HEADER_LEFT;
alias NK_HEADER_RIGHT = nk_style_header_align.NK_HEADER_RIGHT;

struct nk_style_window_header {
    /* background */
    nk_style_item normal;
    nk_style_item hover;
    nk_style_item active;

    /* button */
    nk_style_button close_button;
    nk_style_button minimize_button;
    nk_symbol_type close_symbol;
    nk_symbol_type minimize_symbol;
    nk_symbol_type maximize_symbol;

    /* title */
    nk_color label_normal;
    nk_color label_hover;
    nk_color label_active;

    /* properties */
    nk_style_header_align align_;
    nk_vec2 padding;
    nk_vec2 label_padding;
    nk_vec2 spacing;
}

struct nk_style_window {
    nk_style_window_header header;
    nk_style_item fixed_background;
    nk_color background;

    nk_color border_color;
    nk_color popup_border_color;
    nk_color combo_border_color;
    nk_color contextual_border_color;
    nk_color menu_border_color;
    nk_color group_border_color;
    nk_color tooltip_border_color;
    nk_style_item scaler;

    float border = 0;
    float combo_border = 0;
    float contextual_border = 0;
    float menu_border = 0;
    float group_border = 0;
    float tooltip_border = 0;
    float popup_border = 0;
    float min_row_height_padding = 0;

    float rounding = 0;
    nk_vec2 spacing;
    nk_vec2 scrollbar_size;
    nk_vec2 min_size;

    nk_vec2 padding;
    nk_vec2 group_padding;
    nk_vec2 popup_padding;
    nk_vec2 combo_padding;
    nk_vec2 contextual_padding;
    nk_vec2 menu_padding;
    nk_vec2 tooltip_padding;
}

struct nk_style {
    const(nk_user_font)* font;
    const(nk_cursor)*[NK_CURSOR_COUNT] cursors;
    const(nk_cursor)* cursor_active;
    nk_cursor* cursor_last;
    int cursor_visible;

    nk_style_text text;
    nk_style_button button;
    nk_style_button contextual_button;
    nk_style_button menu_button;
    nk_style_toggle option;
    nk_style_toggle checkbox;
    nk_style_selectable selectable;
    nk_style_slider slider;
    nk_style_progress progress;
    nk_style_property property;
    nk_style_edit edit;
    nk_style_chart chart;
    nk_style_scrollbar scrollh;
    nk_style_scrollbar scrollv;
    nk_style_tab tab;
    nk_style_combo combo;
    nk_style_window window;
}

nk_style_item nk_style_item_color(nk_color);
nk_style_item nk_style_item_image(nk_image img);
nk_style_item nk_style_item_nine_slice(nk_nine_slice slice);
nk_style_item nk_style_item_hide();

/*==============================================================
 *                          PANEL
 * =============================================================*/
enum NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS = 16;

enum NK_CHART_MAX_SLOT = 4;


enum nk_panel_type {
    NK_PANEL_NONE       = 0,
    NK_PANEL_WINDOW     = NK_FLAG(0),
    NK_PANEL_GROUP      = NK_FLAG(1),
    NK_PANEL_POPUP      = NK_FLAG(2),
    NK_PANEL_CONTEXTUAL = NK_FLAG(4),
    NK_PANEL_COMBO      = NK_FLAG(5),
    NK_PANEL_MENU       = NK_FLAG(6),
    NK_PANEL_TOOLTIP    = NK_FLAG(7)
}
alias NK_PANEL_NONE = nk_panel_type.NK_PANEL_NONE;
alias NK_PANEL_WINDOW = nk_panel_type.NK_PANEL_WINDOW;
alias NK_PANEL_GROUP = nk_panel_type.NK_PANEL_GROUP;
alias NK_PANEL_POPUP = nk_panel_type.NK_PANEL_POPUP;
alias NK_PANEL_CONTEXTUAL = nk_panel_type.NK_PANEL_CONTEXTUAL;
alias NK_PANEL_COMBO = nk_panel_type.NK_PANEL_COMBO;
alias NK_PANEL_MENU = nk_panel_type.NK_PANEL_MENU;
alias NK_PANEL_TOOLTIP = nk_panel_type.NK_PANEL_TOOLTIP;

enum nk_panel_set {
    NK_PANEL_SET_NONBLOCK = NK_PANEL_CONTEXTUAL|NK_PANEL_COMBO|NK_PANEL_MENU|NK_PANEL_TOOLTIP,
    NK_PANEL_SET_POPUP = cast(nk_panel_type)(NK_PANEL_SET_NONBLOCK|NK_PANEL_POPUP),
    NK_PANEL_SET_SUB = cast(nk_panel_type)(NK_PANEL_SET_POPUP|NK_PANEL_GROUP)
}
alias NK_PANEL_SET_NONBLOCK = nk_panel_set.NK_PANEL_SET_NONBLOCK;
alias NK_PANEL_SET_POPUP = nk_panel_set.NK_PANEL_SET_POPUP;
alias NK_PANEL_SET_SUB = nk_panel_set.NK_PANEL_SET_SUB;


struct nk_chart_slot {
    nk_chart_type type;
    nk_color color;
    nk_color highlight;
    float min = 0, max = 0, range = 0;
    int count;
    nk_vec2 last;
    int index;
}

struct nk_chart {
    int slot;
    float x = 0, y = 0, w = 0, h = 0;
    nk_chart_slot[NK_CHART_MAX_SLOT] slots;
}

enum nk_panel_row_layout_type {
    NK_LAYOUT_DYNAMIC_FIXED = 0,
    NK_LAYOUT_DYNAMIC_ROW,
    NK_LAYOUT_DYNAMIC_FREE,
    NK_LAYOUT_DYNAMIC,
    NK_LAYOUT_STATIC_FIXED,
    NK_LAYOUT_STATIC_ROW,
    NK_LAYOUT_STATIC_FREE,
    NK_LAYOUT_STATIC,
    NK_LAYOUT_TEMPLATE,
    NK_LAYOUT_COUNT
}
alias NK_LAYOUT_DYNAMIC_FIXED = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC_FIXED;
alias NK_LAYOUT_DYNAMIC_ROW = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC_ROW;
alias NK_LAYOUT_DYNAMIC_FREE = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC_FREE;
alias NK_LAYOUT_DYNAMIC = nk_panel_row_layout_type.NK_LAYOUT_DYNAMIC;
alias NK_LAYOUT_STATIC_FIXED = nk_panel_row_layout_type.NK_LAYOUT_STATIC_FIXED;
alias NK_LAYOUT_STATIC_ROW = nk_panel_row_layout_type.NK_LAYOUT_STATIC_ROW;
alias NK_LAYOUT_STATIC_FREE = nk_panel_row_layout_type.NK_LAYOUT_STATIC_FREE;
alias NK_LAYOUT_STATIC = nk_panel_row_layout_type.NK_LAYOUT_STATIC;
alias NK_LAYOUT_TEMPLATE = nk_panel_row_layout_type.NK_LAYOUT_TEMPLATE;
alias NK_LAYOUT_COUNT = nk_panel_row_layout_type.NK_LAYOUT_COUNT;

struct nk_row_layout {
    nk_panel_row_layout_type type;
    int index;
    float height = 0;
    float min_height = 0;
    int columns;
    const(float)* ratio;
    float item_width = 0;
    float item_height = 0;
    float item_offset = 0;
    float filled = 0;
    nk_rect item;
    int tree_depth;
    float[NK_MAX_LAYOUT_ROW_TEMPLATE_COLUMNS] templates = 0;
}

struct nk_popup_buffer {
    nk_size begin;
    nk_size parent;
    nk_size last;
    nk_size end;
    nk_bool active;
}

struct nk_menu_state {
    float x = 0, y = 0, w = 0, h = 0;
    nk_scroll offset;
}

struct nk_panel {
    nk_panel_type type;
    nk_flags flags;
    nk_rect bounds;
    nk_uint* offset_x;
    nk_uint* offset_y;
    float at_x = 0, at_y = 0, max_x = 0;
    float footer_height = 0;
    float header_height = 0;
    float border = 0;
    uint has_scrolling;
    nk_rect clip;
    nk_menu_state menu;
    nk_row_layout row;
    nk_chart chart;
    nk_command_buffer* buffer;
    nk_panel* parent;
}

/*==============================================================
 *                          WINDOW
 * =============================================================*/
enum NK_WINDOW_MAX_NAME = 64;

enum nk_window_flags {
    NK_WINDOW_PRIVATE       = NK_FLAG(11),
    NK_WINDOW_DYNAMIC       = NK_WINDOW_PRIVATE,
    /* special window type growing up in height while being filled to a certain maximum height */
    NK_WINDOW_ROM           = NK_FLAG(12),
    /* sets window widgets into a read only mode and does not allow input changes */
    NK_WINDOW_NOT_INTERACTIVE = NK_WINDOW_ROM|NK_WINDOW_NO_INPUT,
    /* prevents all interaction caused by input to either window or widgets inside */
    NK_WINDOW_HIDDEN        = NK_FLAG(13),
    /* Hides window and stops any window interaction and drawing */
    NK_WINDOW_CLOSED        = NK_FLAG(14),
    /* Directly closes and frees the window at the end of the frame */
    NK_WINDOW_MINIMIZED     = NK_FLAG(15),
    /* marks the window as minimized */
    NK_WINDOW_REMOVE_ROM    = NK_FLAG(16)
    /* Removes read only mode at the end of the window */
}
alias NK_WINDOW_PRIVATE = nk_window_flags.NK_WINDOW_PRIVATE;
alias NK_WINDOW_DYNAMIC = nk_window_flags.NK_WINDOW_DYNAMIC;
alias NK_WINDOW_ROM = nk_window_flags.NK_WINDOW_ROM;
alias NK_WINDOW_NOT_INTERACTIVE = nk_window_flags.NK_WINDOW_NOT_INTERACTIVE;
alias NK_WINDOW_HIDDEN = nk_window_flags.NK_WINDOW_HIDDEN;
alias NK_WINDOW_CLOSED = nk_window_flags.NK_WINDOW_CLOSED;
alias NK_WINDOW_MINIMIZED = nk_window_flags.NK_WINDOW_MINIMIZED;
alias NK_WINDOW_REMOVE_ROM = nk_window_flags.NK_WINDOW_REMOVE_ROM;


struct nk_popup_state {
    nk_window* win;
    nk_panel_type type;
    nk_popup_buffer buf;
    nk_hash name;
    nk_bool active;
    uint combo_count;
    uint con_count, con_old;
    uint active_con;
    nk_rect header;
}

struct nk_edit_state {
    nk_hash name;
    uint seq;
    uint old;
    int active, prev;
    int cursor;
    int sel_start;
    int sel_end;
    nk_scroll scrollbar;
    ubyte mode;
    ubyte single_line;
}

struct nk_property_state {
    int active, prev;
    char[NK_MAX_NUMBER_BUFFER] buffer = 0;
    int length;
    int cursor;
    int select_start;
    int select_end;
    nk_hash name;
    uint seq;
    uint old;
    int state;
}

struct nk_window {
    uint seq;
    nk_hash name;
    char[NK_WINDOW_MAX_NAME] name_string = 0;
    nk_flags flags;

    nk_rect bounds;
    nk_scroll scrollbar;
    nk_command_buffer buffer;
    nk_panel* layout;
    float scrollbar_hiding_timer = 0;

    /* persistent widget state */
    nk_property_state property;
    nk_popup_state popup;
    nk_edit_state edit;
    uint scrolled;

    nk_table* tables;
    uint table_count;

    /* window list hooks */
    nk_window* next;
    nk_window* prev;
    nk_window* parent;
}

/*==============================================================
 *                          STACK
 * =============================================================*/

enum NK_BUTTON_BEHAVIOR_STACK_SIZE = 8;
enum NK_FONT_STACK_SIZE = 8;
enum NK_STYLE_ITEM_STACK_SIZE = 16;
enum NK_FLOAT_STACK_SIZE = 32;
enum NK_VECTOR_STACK_SIZE = 16;
enum NK_FLAGS_STACK_SIZE = 32;
enum NK_COLOR_STACK_SIZE = 32;

template NK_CONFIGURATION_STACK_TYPE(string prefix, string name, string type)
{
    const char[] NK_CONFIGURATION_STACK_TYPE = "struct nk_config_stack_"~name~"_element {"~
        prefix ~ "_"~type~" *address;" ~
        prefix ~ "_"~type~" old_value;"~
        "}";
}

template NK_CONFIG_STACK(string type, string size)
{
    const char[] NK_CONFIG_STACK = "struct nk_config_stack_"~type~" {"~
        "int head;"~
        "nk_config_stack_"~type~"_element["~size~"] elements;"~
        "}";
}

mixin(NK_CONFIGURATION_STACK_TYPE!("nk", "style_item", "style_item"));
mixin(NK_CONFIGURATION_STACK_TYPE!("nk" ,"float", "float"));
mixin(NK_CONFIGURATION_STACK_TYPE!("nk", "vec2", "vec2"));
mixin(NK_CONFIGURATION_STACK_TYPE!("nk" ,"flags", "flags"));
mixin(NK_CONFIGURATION_STACK_TYPE!("nk", "color", "color"));
mixin(NK_CONFIGURATION_STACK_TYPE!("nk", "user_font", "user_font*"));
mixin(NK_CONFIGURATION_STACK_TYPE!("nk", "button_behavior", "button_behavior"));

mixin(NK_CONFIG_STACK!("style_item", "NK_STYLE_ITEM_STACK_SIZE"));
mixin(NK_CONFIG_STACK!("float", "NK_FLOAT_STACK_SIZE"));
mixin(NK_CONFIG_STACK!("vec2", "NK_VECTOR_STACK_SIZE"));
mixin(NK_CONFIG_STACK!("flags", "NK_FLAGS_STACK_SIZE"));
mixin(NK_CONFIG_STACK!("color", "NK_COLOR_STACK_SIZE"));
mixin(NK_CONFIG_STACK!("user_font", "NK_FONT_STACK_SIZE"));
mixin(NK_CONFIG_STACK!("button_behavior", "NK_BUTTON_BEHAVIOR_STACK_SIZE"));

struct nk_configuration_stacks {
    nk_config_stack_style_item style_items;
    nk_config_stack_float floats;
    nk_config_stack_vec2 vectors;
    nk_config_stack_flags flags;
    nk_config_stack_color colors;
    nk_config_stack_user_font fonts;
    nk_config_stack_button_behavior button_behaviors;
}

/*==============================================================
 *                          CONTEXT
 * =============================================================*/

enum NK_VALUE_PAGE_CAPACITY = (NK_MAX(nk_window.sizeof, nk_panel.sizeof) / nk_uint.sizeof) / 2;

struct nk_table {
    uint seq;
    uint size;
    nk_hash[NK_VALUE_PAGE_CAPACITY] keys;
    nk_uint[NK_VALUE_PAGE_CAPACITY] values;
    nk_table* next, prev;
}

union nk_page_data {
    nk_table tbl;
    nk_panel pan;
    nk_window win;
}

struct nk_page_element {
    nk_page_data data;
    nk_page_element* next;
    nk_page_element* prev;
}

struct nk_page {
    uint size;
    nk_page* next;
    nk_page_element[1] win;
}

struct nk_pool {
    nk_allocator alloc;
    nk_allocation_type type;
    uint page_count;
    nk_page* pages;
    nk_page_element* freelist;
    uint capacity;
    nk_size size;
    nk_size cap;
}

struct nk_context {
/* public: can be accessed freely */
    nk_input input;
    nk_style style;
    nk_buffer memory;
    nk_clipboard clip;
    nk_flags last_widget_state;
    nk_button_behavior button_behavior;
    nk_configuration_stacks stacks;
    float delta_time_seconds = 0;

/* private:
    should only be accessed if you
    know what you are doing */
version (NK_INCLUDE_VERTEX_BUFFER_OUTPUT) {
    nk_draw_list draw_list;
}
version (NK_INCLUDE_COMMAND_USERDATA) {
    nk_handle userdata;
}
    /* text editor objects are quite big because of an internal
     * undo/redo stack. Therefore it does not make sense to have one for
     * each window for temporary use cases, so I only provide *one* instance
     * for all windows. This works because the content is cleared anyway */
    nk_text_edit text_edit;
    /* draw buffer used for overlay drawing operation like cursor */
    nk_command_buffer overlay;

    /* windows */
    int build;
    int use_pool;
    nk_pool pool;
    nk_window* begin;
    nk_window* end;
    nk_window* active;
    nk_window* current;
    nk_page_element* freelist;
    uint count;
    uint seq;
}

/* ==============================================================
 *                          MATH
 * =============================================================== */
enum NK_PI = 3.141592654f;
enum NK_MAX_FLOAT_PRECISION = 2;

auto NK_UNUSED(T)(T x) { cast(void)x; }
auto NK_SATURATE(T)(T x) { return NK_MAX(0, NK_MIN(1.0f, x)); }
auto NK_LEN(T)(T a) { return a.sizeof / a[0].sizeof; }
auto NK_ABS(T)(T a) { return ((a) < 0) ? -(a) : (a); }
auto NK_BETWEEN(T)(T x, T a, T b) { return (a) <= (x) && (x) < (b); }
auto NK_INBOX(T)(T px, T py, T x, T y, T w, T h) { return NK_BETWEEN(px,x,x+w) && NK_BETWEEN(py,y,y+h); }
auto NK_INTERSECT(T)(T x0, T y0, T w0, T h0, T x1, T y1, T w1, T h1) { return ((x1 < (x0 + w0)) && (x0 < (x1 + w1)) && (y1 < (y0 + h0)) && (y0 < (y1 + h1))); }
auto NK_CONTAINS(T)(T x, T y, T w, T h, T bx, T by, T bw, T bh) { return NK_INBOX(x,y, bx, by, bw, bh) && NK_INBOX(x+w,y+h, bx, by, bw, bh); }
auto nk_vec2_sub(T)(T a, T b) { return nk_vec2(a.x - b.x, a.y - b.y); }
auto nk_vec2_add(T)(T a, T b) { return nk_vec2(a.x + b.x, a.y + b.y); }
auto nk_vec2_len_sqr(T)(T a) { return a.x * a.x + a.y * a.y; }
auto nk_vec2_muls(T, V)(T a, V t) { return nk_vec2((a).x * (t), (a).y * (t)); }
auto nk_ptr_add(T, P, I)(T t, P p, I i) { return cast(t*)cast(void*)(cast(nk_byte*)p + i); }
auto nk_ptr_add_const(T, P, I)(T t, P p, I i) { return cast(const t*)(cast(const void*)(cast(const nk_byte*)p + i)); }
void nk_zero_struct(T)(T s) { nk_zero(&s, s.sizeof); }

/* ==============================================================
 *                          ALIGNMENT
 * =============================================================== */
/* Pointer to Integer type conversion for pointer alignment */

auto NK_UINT_TO_PTR(T)(T x) { return cast(void*)(NK_SIZE_TYPE)(x); }
auto NK_PTR_TO_UINT(T)(T x) { return cast(NK_SIZE_TYPE)(x); }

auto NK_ALIGN_PTR(T, M)(T x, M mask) { return NK_UINT_TO_PTR((NK_PTR_TO_UINT(cast(nk_byte*)(x) + (mask-1)) & ~(mask-1))); }
auto NK_ALIGN_PTR_BACK(T, M)(T x, M mask) { return (NK_UINT_TO_PTR((NK_PTR_TO_UINT(cast(nk_byte*)(x)) & ~(mask-1)))); }
auto NK_OFFSETOF(T, M)(T st, M m) { return (cast(nk_ptr)&((cast(st*)0).m)); }

auto NK_ALIGNOF(T)(T t) { 
    struct A {char c; t _h;}
    A a;
    return NK_OFFSETOF(a, a._h); 
}

auto NK_CONTAINER_OF(P, T, M)(P ptr, T type, M member) {
    return cast(T*)(cast(void*)(cast(char*)(1 ? (ptr): &(cast(T*)0).member) - NK_OFFSETOF(type, member)));
}
