module nuklear.stb_rect_pack;
extern(C) @nogc nothrow:
__gshared:

public import nuklear.stb_internal;

enum
{
   STBRP_HEURISTIC_Skyline_default=0,
   STBRP_HEURISTIC_Skyline_BL_sortHeight = STBRP_HEURISTIC_Skyline_default,
   STBRP_HEURISTIC_Skyline_BF_sortHeight
}

enum
{
   STBRP__INIT_skyline = 1
}

void stbrp_setup_heuristic(stbrp_context* context, int heuristic)
{
   switch (context.init_mode) {
      case STBRP__INIT_skyline:
         assert(heuristic == STBRP_HEURISTIC_Skyline_BL_sortHeight || heuristic == STBRP_HEURISTIC_Skyline_BF_sortHeight);
         context.heuristic = heuristic;
         break;
      default:
         assert(0);
   }
}

void stbrp_setup_allow_out_of_mem(stbrp_context* context, int allow_out_of_mem)
{
   if (allow_out_of_mem)
      context.align_ = 1;
   else {
      context.align_ = (context.width + context.num_nodes-1) / context.num_nodes;
   }
}

void stbrp_init_target(stbrp_context* context, int width, int height, stbrp_node* nodes, int num_nodes)
{
   int i = void;
   for (i=0; i < num_nodes-1; ++i)
      nodes[i].next = &nodes[i+1];
   nodes[i].next = null;
   context.init_mode = STBRP__INIT_skyline;
   context.heuristic = STBRP_HEURISTIC_Skyline_default;
   context.free_head = &nodes[0];
   context.active_head = &context.extra[0];
   context.width = width;
   context.height = height;
   context.num_nodes = num_nodes;
   stbrp_setup_allow_out_of_mem(context, 0);


   context.extra[0].x = 0;
   context.extra[0].y = 0;
   context.extra[0].next = &context.extra[1];
   context.extra[1].x = cast(stbrp_coord) width;
   context.extra[1].y = (1<<30);
   context.extra[1].next = null;
}

int stbrp__skyline_find_min_y(stbrp_context* c, stbrp_node* first, int x0, int width, int* pwaste)
{
   stbrp_node* node = first;
   int x1 = x0 + width;
   int min_y = void, visited_width = void, waste_area = void;

   cast(void)c.sizeof;
   assert(first.x <= x0);
   assert(node.next.x > x0);
   assert(node.x <= x0);

   min_y = 0;
   waste_area = 0;
   visited_width = 0;
   while (node.x < x1) {
      if (node.y > min_y) {
         waste_area += visited_width * (node.y - min_y);
         min_y = node.y;

         if (node.x < x0)
            visited_width += node.next.x - x0;
         else
            visited_width += node.next.x - node.x;
      } else {

         int under_width = node.next.x - node.x;
         if (under_width + visited_width > width)
            under_width = width - visited_width;
         waste_area += under_width * (min_y - node.y);
         visited_width += under_width;
      }
      node = node.next;
   }

   *pwaste = waste_area;
   return min_y;
}

struct stbrp__findresult {
   int x, y;
   stbrp_node** prev_link;
}

stbrp__findresult stbrp__skyline_find_best_pos(stbrp_context* c, int width, int height)
{
   int best_waste = (1<<30), best_x = void, best_y = (1 << 30);
   stbrp__findresult fr = void;
   stbrp_node** prev = void; stbrp_node* node = void, tail = void; stbrp_node** best = null;

   width = (width + c.align_ - 1);
   width -= width % c.align_;
   assert(width % c.align_ == 0);

   if (width > c.width || height > c.height) {
      fr.prev_link = null;
      fr.x = fr.y = 0;
      return fr;
   }

   node = c.active_head;
   prev = &c.active_head;
   while (node.x + width <= c.width) {
      int y = void, waste = void;
      y = stbrp__skyline_find_min_y(c, node, node.x, width, &waste);
      if (c.heuristic == STBRP_HEURISTIC_Skyline_BL_sortHeight) {

         if (y < best_y) {
            best_y = y;
            best = prev;
         }
      } else {

         if (y + height <= c.height) {

            if (y < best_y || (y == best_y && waste < best_waste)) {
               best_y = y;
               best_waste = waste;
               best = prev;
            }
         }
      }
      prev = &node.next;
      node = node.next;
   }

   best_x = (best == null) ? 0 : (*best).x;
   if (c.heuristic == STBRP_HEURISTIC_Skyline_BF_sortHeight) {
      tail = c.active_head;
      node = c.active_head;
      prev = &c.active_head;

      while (tail.x < width)
         tail = tail.next;
      while (tail) {
         int xpos = tail.x - width;
         int y = void, waste = void;
         assert(xpos >= 0);

         while (node.next.x <= xpos) {
            prev = &node.next;
            node = node.next;
         }
         assert(node.next.x > xpos && node.x <= xpos);
         y = stbrp__skyline_find_min_y(c, node, xpos, width, &waste);
         if (y + height <= c.height) {
            if (y <= best_y) {
               if (y < best_y || waste < best_waste || (waste==best_waste && xpos < best_x)) {
                  best_x = xpos;
                  assert(y <= best_y);
                  best_y = y;
                  best_waste = waste;
                  best = prev;
               }
            }
         }
         tail = tail.next;
      }
   }

   fr.prev_link = best;
   fr.x = best_x;
   fr.y = best_y;
   return fr;
}

stbrp__findresult stbrp__skyline_pack_rectangle(stbrp_context* context, int width, int height)
{
   stbrp__findresult res = stbrp__skyline_find_best_pos(context, width, height);
   stbrp_node* node = void, cur = void;

   if (res.prev_link == null || res.y + height > context.height || context.free_head == null) {
      res.prev_link = null;
      return res;
   }

   node = context.free_head;
   node.x = cast(stbrp_coord) res.x;
   node.y = cast(stbrp_coord) (res.y + height);

   context.free_head = node.next;

   cur = *res.prev_link;
   if (cur.x < res.x) {

      stbrp_node* next = cur.next;
      cur.next = node;
      cur = next;
   } else {
      *res.prev_link = node;
   }

   while (cur.next && cur.next.x <= res.x + width) {
      stbrp_node* next = cur.next;

      cur.next = context.free_head;
      context.free_head = cur;
      cur = next;
   }

   node.next = cur;

   if (cur.x < res.x + width)
      cur.x = cast(stbrp_coord) (res.x + width);
   return res;
}

int rect_height_compare(const(void)* a, const(void)* b)
{
   const(stbrp_rect)* p = cast(const(stbrp_rect)*) a;
   const(stbrp_rect)* q = cast(const(stbrp_rect)*) b;
   if (p.h > q.h)
      return -1;
   if (p.h < q.h)
      return 1;
   return (p.w > q.w) ? -1 : (p.w < q.w);
}

int rect_original_order(const(void)* a, const(void)* b)
{
   const(stbrp_rect)* p = cast(const(stbrp_rect)*) a;
   const(stbrp_rect)* q = cast(const(stbrp_rect)*) b;
   return (p.was_packed < q.was_packed) ? -1 : (p.was_packed > q.was_packed);
}

int stbrp_pack_rects_rp(stbrp_context* context, stbrp_rect* rects, int num_rects)
{
   int i = void, all_rects_packed = 1;


   for (i=0; i < num_rects; ++i) {
      rects[i].was_packed = i;
   }

   qsort(rects, num_rects, typeof(rects[0]).sizeof, &rect_height_compare);

   for (i=0; i < num_rects; ++i) {
      if (rects[i].w == 0 || rects[i].h == 0) {
         rects[i].x = rects[i].y = 0;
      } else {
         stbrp__findresult fr = stbrp__skyline_pack_rectangle(context, rects[i].w, rects[i].h);
         if (fr.prev_link) {
            rects[i].x = cast(stbrp_coord) fr.x;
            rects[i].y = cast(stbrp_coord) fr.y;
         } else {
            rects[i].x = rects[i].y = 0x7fffffff;
         }
      }
   }

   qsort(rects, num_rects, typeof(rects[0]).sizeof, &rect_original_order);

   for (i=0; i < num_rects; ++i) {
      rects[i].was_packed = !(rects[i].x == 0x7fffffff && rects[i].y == 0x7fffffff);
      if (!rects[i].was_packed)
         all_rects_packed = 0;
   }

   return all_rects_packed;
}

