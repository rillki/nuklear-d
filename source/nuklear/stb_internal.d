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

struct stbrp_context {
   int width, height;
   union {
      struct {
         int x, y, bottom_y;
      }
      struct {
         int align_;
         int init_mode;
         int heuristic;
         int num_nodes;
         stbrp_node* active_head;
         stbrp_node* free_head;
         stbrp_node[2] extra;
      }
   }
}

struct stbrp_node {
   stbrp_coord x;
   union {
      struct {
         stbrp_coord y;
         stbrp_node* next;
      }
   }
}


