module nuklear.stb_internal;
extern(C) @nogc nothrow:
__gshared:

alias stbrp_coord = int;

struct stbrp_rect
{
   int id;
   stbrp_coord w, h;
   stbrp_coord x, y;
   int was_packed;
}

