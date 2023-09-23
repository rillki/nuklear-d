module nuklear.stb_truetype;
extern(C) @nogc nothrow:
__gshared:

import core.stdc.stdlib;
import core.stdc.math;

public import nuklear.stb_internal;

struct stbtt__buf {
   ubyte* data;
   int cursor;
   int size;
}

struct stbtt_bakedchar {
   ushort x0, y0, x1, y1;
   float xoff = 0, yoff = 0, xadvance = 0;
}

struct stbtt_aligned_quad {
   float x0 = 0, y0 = 0, s0 = 0, t0 = 0;
   float x1 = 0, y1 = 0, s1 = 0, t1 = 0;
}

struct stbtt_packedchar {
   ushort x0, y0, x1, y1;
   float xoff = 0, yoff = 0, xadvance = 0;
   float xoff2 = 0, yoff2 = 0;
}

struct stbtt_pack_range {
   float font_size = 0;
   int first_unicode_codepoint_in_range;
   int* array_of_unicode_codepoints;
   int num_chars;
   stbtt_packedchar* chardata_for_range;
   ubyte h_oversample, v_oversample;
}

struct stbtt_pack_context {
   void* user_allocator_context;
   void* pack_info;
   int width;
   int height;
   int stride_in_bytes;
   int padding;
   int skip_missing;
   uint h_oversample, v_oversample;
   ubyte* pixels;
   void* nodes;
}

struct stbtt_fontinfo
{
   void* userdata;
   ubyte* data;
   int fontstart;

   int numGlyphs;

   int loca, head, glyf, hhea, hmtx, kern, gpos, svg;
   int index_map;
   int indexToLocFormat;

   stbtt__buf cff;
   stbtt__buf charstrings;
   stbtt__buf gsubrs;
   stbtt__buf subrs;
   stbtt__buf fontdicts;
   stbtt__buf fdselect;
}

struct stbtt_kerningentry {
   int glyph1;
   int glyph2;
   int advance;
}

enum {
   STBTT_vmove=1,
   STBTT_vline,
   STBTT_vcurve,
   STBTT_vcubic
}

struct stbtt_vertex {
   short x, y, cx, cy, cx1, cy1;
   ubyte type, padding;
}

struct stbtt__bitmap {
   int w, h, stride;
   ubyte* pixels;
}

enum {
   STBTT_PLATFORM_ID_UNICODE =0,
   STBTT_PLATFORM_ID_MAC =1,
   STBTT_PLATFORM_ID_ISO =2,
   STBTT_PLATFORM_ID_MICROSOFT =3
}

enum {
   STBTT_UNICODE_EID_UNICODE_1_0 =0,
   STBTT_UNICODE_EID_UNICODE_1_1 =1,
   STBTT_UNICODE_EID_ISO_10646 =2,
   STBTT_UNICODE_EID_UNICODE_2_0_BMP=3,
   STBTT_UNICODE_EID_UNICODE_2_0_FULL=4
}

enum {
   STBTT_MS_EID_SYMBOL =0,
   STBTT_MS_EID_UNICODE_BMP =1,
   STBTT_MS_EID_SHIFTJIS =2,
   STBTT_MS_EID_UNICODE_FULL =10
}

enum {
   STBTT_MAC_EID_ROMAN =0, STBTT_MAC_EID_ARABIC =4,
   STBTT_MAC_EID_JAPANESE =1, STBTT_MAC_EID_HEBREW =5,
   STBTT_MAC_EID_CHINESE_TRAD =2, STBTT_MAC_EID_GREEK =6,
   STBTT_MAC_EID_KOREAN =3, STBTT_MAC_EID_RUSSIAN =7
}

enum {

   STBTT_MS_LANG_ENGLISH =0x0409, STBTT_MS_LANG_ITALIAN =0x0410,
   STBTT_MS_LANG_CHINESE =0x0804, STBTT_MS_LANG_JAPANESE =0x0411,
   STBTT_MS_LANG_DUTCH =0x0413, STBTT_MS_LANG_KOREAN =0x0412,
   STBTT_MS_LANG_FRENCH =0x040c, STBTT_MS_LANG_RUSSIAN =0x0419,
   STBTT_MS_LANG_GERMAN =0x0407, STBTT_MS_LANG_SPANISH =0x0409,
   STBTT_MS_LANG_HEBREW =0x040d, STBTT_MS_LANG_SWEDISH =0x041D
}

enum {
   STBTT_MAC_LANG_ENGLISH =0 , STBTT_MAC_LANG_JAPANESE =11,
   STBTT_MAC_LANG_ARABIC =12, STBTT_MAC_LANG_KOREAN =23,
   STBTT_MAC_LANG_DUTCH =4 , STBTT_MAC_LANG_RUSSIAN =32,
   STBTT_MAC_LANG_FRENCH =1 , STBTT_MAC_LANG_SPANISH =6 ,
   STBTT_MAC_LANG_GERMAN =2 , STBTT_MAC_LANG_SWEDISH =5 ,
   STBTT_MAC_LANG_HEBREW =10, STBTT_MAC_LANG_CHINESE_SIMPLIFIED =33,
   STBTT_MAC_LANG_ITALIAN =3 , STBTT_MAC_LANG_CHINESE_TRAD =19
}

alias stbtt_uint8 = ubyte;
alias stbtt_int8 = char;
alias stbtt_uint16 = ushort;
alias stbtt_int16 = short;
alias stbtt_uint32 = uint;
alias stbtt_int32 = int;


alias stbtt__check_size32 = char[stbtt_int32.sizeof==4 ? 1 : -1];
alias stbtt__check_size16 = char[stbtt_int16.sizeof==2 ? 1 : -1];

alias stbtt__test_oversample_pow2 = int[(8 & (8 -1)) == 0 ? 1 : -1];

stbtt_uint8 stbtt__buf_get8(stbtt__buf* b)
{
   if (b.cursor >= b.size)
      return 0;
   return b.data[b.cursor++];
}

stbtt_uint8 stbtt__buf_peek8(stbtt__buf* b)
{
   if (b.cursor >= b.size)
      return 0;
   return b.data[b.cursor];
}

void stbtt__buf_seek(stbtt__buf* b, int o)
{
   assert(!(o > b.size || o < 0));
   b.cursor = (o > b.size || o < 0) ? b.size : o;
}

void stbtt__buf_skip(stbtt__buf* b, int o)
{
   stbtt__buf_seek(b, b.cursor + o);
}

stbtt_uint32 stbtt__buf_get(stbtt__buf* b, int n)
{
   stbtt_uint32 v = 0;
   int i = void;
   assert(n >= 1 && n <= 4);
   for (i = 0; i < n; i++)
      v = (v << 8) | stbtt__buf_get8(b);
   return v;
}

stbtt__buf stbtt__new_buf(const(void)* p, size_t size)
{
   stbtt__buf r = void;
   assert(size < 0x40000000);
   r.data = cast(stbtt_uint8*) p;
   r.size = cast(int) size;
   r.cursor = 0;
   return r;
}




stbtt__buf stbtt__buf_range(const(stbtt__buf)* b, int o, int s)
{
   stbtt__buf r = stbtt__new_buf(null, 0);
   if (o < 0 || s < 0 || o > b.size || s > b.size - o) return r;
   r.data = b.data + o;
   r.size = s;
   return r;
}

stbtt__buf stbtt__cff_get_index(stbtt__buf* b)
{
   int count = void, start = void, offsize = void;
   start = b.cursor;
   count = stbtt__buf_get((b), 2);
   if (count) {
      offsize = stbtt__buf_get8(b);
      assert(offsize >= 1 && offsize <= 4);
      stbtt__buf_skip(b, offsize * count);
      stbtt__buf_skip(b, stbtt__buf_get(b, offsize) - 1);
   }
   return stbtt__buf_range(b, start, b.cursor - start);
}

stbtt_uint32 stbtt__cff_int(stbtt__buf* b)
{
   int b0 = stbtt__buf_get8(b);
   if (b0 >= 32 && b0 <= 246) return b0 - 139;
   else if (b0 >= 247 && b0 <= 250) return (b0 - 247)*256 + stbtt__buf_get8(b) + 108;
   else if (b0 >= 251 && b0 <= 254) return -(b0 - 251)*256 - stbtt__buf_get8(b) - 108;
   else if (b0 == 28) return stbtt__buf_get((b), 2);
   else if (b0 == 29) return stbtt__buf_get((b), 4);
   assert(0);
   return 0;
}

void stbtt__cff_skip_operand(stbtt__buf* b) {
   int v = void, b0 = stbtt__buf_peek8(b);
   assert(b0 >= 28);
   if (b0 == 30) {
      stbtt__buf_skip(b, 1);
      while (b.cursor < b.size) {
         v = stbtt__buf_get8(b);
         if ((v & 0xF) == 0xF || (v >> 4) == 0xF)
            break;
      }
   } else {
      stbtt__cff_int(b);
   }
}

stbtt__buf stbtt__dict_get(stbtt__buf* b, int key)
{
   stbtt__buf_seek(b, 0);
   while (b.cursor < b.size) {
      int start = b.cursor, end = void, op = void;
      while (stbtt__buf_peek8(b) >= 28)
         stbtt__cff_skip_operand(b);
      end = b.cursor;
      op = stbtt__buf_get8(b);
      if (op == 12) op = stbtt__buf_get8(b) | 0x100;
      if (op == key) return stbtt__buf_range(b, start, end-start);
   }
   return stbtt__buf_range(b, 0, 0);
}

void stbtt__dict_get_ints(stbtt__buf* b, int key, int outcount, stbtt_uint32* out_)
{
   int i = void;
   stbtt__buf operands = stbtt__dict_get(b, key);
   for (i = 0; i < outcount && operands.cursor < operands.size; i++)
      out_[i] = stbtt__cff_int(&operands);
}

int stbtt__cff_index_count(stbtt__buf* b)
{
   stbtt__buf_seek(b, 0);
   return stbtt__buf_get((b), 2);
}

stbtt__buf stbtt__cff_index_get(stbtt__buf b, int i)
{
   int count = void, offsize = void, start = void, end = void;
   stbtt__buf_seek(&b, 0);
   count = stbtt__buf_get((&b), 2);
   offsize = stbtt__buf_get8(&b);
   assert(i >= 0 && i < count);
   assert(offsize >= 1 && offsize <= 4);
   stbtt__buf_skip(&b, i*offsize);
   start = stbtt__buf_get(&b, offsize);
   end = stbtt__buf_get(&b, offsize);
   return stbtt__buf_range(&b, 2+(count+1)*offsize+start, end - start);
}
stbtt_uint16 ttUSHORT(stbtt_uint8* p) { return p[0]*256 + p[1]; }
stbtt_int16 ttSHORT(stbtt_uint8* p) { return p[0]*256 + p[1]; }
stbtt_uint32 ttULONG(stbtt_uint8* p) { return (p[0]<<24) + (p[1]<<16) + (p[2]<<8) + p[3]; }
stbtt_int32 ttLONG(stbtt_uint8* p) { return (p[0]<<24) + (p[1]<<16) + (p[2]<<8) + p[3]; }




int stbtt__isfont(stbtt_uint8* font)
{

   if (((font)[0] == ('1') && (font)[1] == (0) && (font)[2] == (0) && (font)[3] == (0))) return 1;
   if (((font)[0] == ("typ1"[0]) && (font)[1] == ("typ1"[1]) && (font)[2] == ("typ1"[2]) && (font)[3] == ("typ1"[3]))) return 1;
   if (((font)[0] == ("OTTO"[0]) && (font)[1] == ("OTTO"[1]) && (font)[2] == ("OTTO"[2]) && (font)[3] == ("OTTO"[3]))) return 1;
   if (((font)[0] == (0) && (font)[1] == (1) && (font)[2] == (0) && (font)[3] == (0))) return 1;
   if (((font)[0] == ("true"[0]) && (font)[1] == ("true"[1]) && (font)[2] == ("true"[2]) && (font)[3] == ("true"[3]))) return 1;
   return 0;
}


stbtt_uint32 stbtt__find_table(stbtt_uint8* data, stbtt_uint32 fontstart, const(char)* tag)
{
   stbtt_int32 num_tables = ttUSHORT(data+fontstart+4);
   stbtt_uint32 tabledir = fontstart + 12;
   stbtt_int32 i = void;
   for (i=0; i < num_tables; ++i) {
      stbtt_uint32 loc = tabledir + 16*i;
      if ((data+loc+0)[0] == (tag[0]) && (data+loc+0)[1].ptr == (tag[1]) && (data+loc+0)[2].ptr == (tag[2]) && (data+loc+0)[3].ptr == (tag[3]))
         return ttULONG(data+loc+8);
   }
   return 0;
}

int stbtt_GetFontOffsetForIndex_internal(ubyte* font_collection, int index)
{

   if (stbtt__isfont(font_collection))
      return index == 0 ? 0 : -1;


   if (((font_collection)[0] == ("ttcf"[0]) && (font_collection)[1] == ("ttcf"[1]) && (font_collection)[2] == ("ttcf"[2]) && (font_collection)[3] == ("ttcf"[3]))) {

      if (ttULONG(font_collection+4) == 0x00010000 || ttULONG(font_collection+4) == 0x00020000) {
         stbtt_int32 n = ttLONG(font_collection+8);
         if (index >= n)
            return -1;
         return ttULONG(font_collection+12+index*4);
      }
   }
   return -1;
}

int stbtt_GetNumberOfFonts_internal(ubyte* font_collection)
{

   if (stbtt__isfont(font_collection))
      return 1;


   if (((font_collection)[0] == ("ttcf"[0]) && (font_collection)[1] == ("ttcf"[1]) && (font_collection)[2] == ("ttcf"[2]) && (font_collection)[3] == ("ttcf"[3]))) {

      if (ttULONG(font_collection+4) == 0x00010000 || ttULONG(font_collection+4) == 0x00020000) {
         return ttLONG(font_collection+8);
      }
   }
   return 0;
}

stbtt__buf stbtt__get_subrs(stbtt__buf cff, stbtt__buf fontdict)
{
   stbtt_uint32 subrsoff = 0; stbtt_uint32[2] private_loc = [ 0, 0 ];
   stbtt__buf pdict = void;
   stbtt__dict_get_ints(&fontdict, 18, 2, private_loc.ptr);
   if (!private_loc[1] || !private_loc[0]) return stbtt__new_buf(null, 0);
   pdict = stbtt__buf_range(&cff, private_loc[1], private_loc[0]);
   stbtt__dict_get_ints(&pdict, 19, 1, &subrsoff);
   if (!subrsoff) return stbtt__new_buf(null, 0);
   stbtt__buf_seek(&cff, private_loc[1]+subrsoff);
   return stbtt__cff_get_index(&cff);
}


int stbtt__get_svg(stbtt_fontinfo* info)
{
   stbtt_uint32 t = void;
   if (info.svg < 0) {
      t = stbtt__find_table(info.data, info.fontstart, "SVG ");
      if (t) {
         stbtt_uint32 offset = ttULONG(info.data + t + 2);
         info.svg = t + offset;
      } else {
         info.svg = 0;
      }
   }
   return info.svg;
}

int stbtt_InitFont_internal(stbtt_fontinfo* info, ubyte* data, int fontstart)
{
   stbtt_uint32 cmap = void, t = void;
   stbtt_int32 i = void, numTables = void;

   info.data = data;
   info.fontstart = fontstart;
   info.cff = stbtt__new_buf(null, 0);

   cmap = stbtt__find_table(data, fontstart, "cmap");
   info.loca = stbtt__find_table(data, fontstart, "loca");
   info.head = stbtt__find_table(data, fontstart, "head");
   info.glyf = stbtt__find_table(data, fontstart, "glyf");
   info.hhea = stbtt__find_table(data, fontstart, "hhea");
   info.hmtx = stbtt__find_table(data, fontstart, "hmtx");
   info.kern = stbtt__find_table(data, fontstart, "kern");
   info.gpos = stbtt__find_table(data, fontstart, "GPOS");

   if (!cmap || !info.head || !info.hhea || !info.hmtx)
      return 0;
   if (info.glyf) {

      if (!info.loca) return 0;
   } else {

      stbtt__buf b = void, topdict = void, topdictidx = void;
      stbtt_uint32 cstype = 2, charstrings = 0, fdarrayoff = 0, fdselectoff = 0;
      stbtt_uint32 cff = void;

      cff = stbtt__find_table(data, fontstart, "CFF ");
      if (!cff) return 0;

      info.fontdicts = stbtt__new_buf(null, 0);
      info.fdselect = stbtt__new_buf(null, 0);


      info.cff = stbtt__new_buf(data+cff, 512*1024*1024);
      b = info.cff;


      stbtt__buf_skip(&b, 2);
      stbtt__buf_seek(&b, stbtt__buf_get8(&b));



      stbtt__cff_get_index(&b);
      topdictidx = stbtt__cff_get_index(&b);
      topdict = stbtt__cff_index_get(topdictidx, 0);
      stbtt__cff_get_index(&b);
      info.gsubrs = stbtt__cff_get_index(&b);

      stbtt__dict_get_ints(&topdict, 17, 1, &charstrings);
      stbtt__dict_get_ints(&topdict, 0x100 | 6, 1, &cstype);
      stbtt__dict_get_ints(&topdict, 0x100 | 36, 1, &fdarrayoff);
      stbtt__dict_get_ints(&topdict, 0x100 | 37, 1, &fdselectoff);
      info.subrs = stbtt__get_subrs(b, topdict);


      if (cstype != 2) return 0;
      if (charstrings == 0) return 0;

      if (fdarrayoff) {

         if (!fdselectoff) return 0;
         stbtt__buf_seek(&b, fdarrayoff);
         info.fontdicts = stbtt__cff_get_index(&b);
         info.fdselect = stbtt__buf_range(&b, fdselectoff, b.size-fdselectoff);
      }

      stbtt__buf_seek(&b, charstrings);
      info.charstrings = stbtt__cff_get_index(&b);
   }

   t = stbtt__find_table(data, fontstart, "maxp");
   if (t)
      info.numGlyphs = ttUSHORT(data+t+4);
   else
      info.numGlyphs = 0xffff;

   info.svg = -1;




   numTables = ttUSHORT(data + cmap + 2);
   info.index_map = 0;
   for (i=0; i < numTables; ++i) {
      stbtt_uint32 encoding_record = cmap + 4 + 8 * i;

      switch(ttUSHORT(data+encoding_record)) {
         case STBTT_PLATFORM_ID_MICROSOFT:
            switch (ttUSHORT(data+encoding_record+2)) {
               case STBTT_MS_EID_UNICODE_BMP:
               case STBTT_MS_EID_UNICODE_FULL:

                  info.index_map = cmap + ttULONG(data+encoding_record+4);
                  break;
            default: break;}
            break;
        case STBTT_PLATFORM_ID_UNICODE:


            info.index_map = cmap + ttULONG(data+encoding_record+4);
            break;
      default: break;}
   }
   if (info.index_map == 0)
      return 0;

   info.indexToLocFormat = ttUSHORT(data+info.head + 50);
   return 1;
}

int stbtt_FindGlyphIndex(const(stbtt_fontinfo)* info, int unicode_codepoint)
{
   stbtt_uint8* data = info.data;
   stbtt_uint32 index_map = info.index_map;

   stbtt_uint16 format = ttUSHORT(data + index_map + 0);
   if (format == 0) {
      stbtt_int32 bytes = ttUSHORT(data + index_map + 2);
      if (unicode_codepoint < bytes-6)
         return (* cast(stbtt_uint8*) (data + index_map + 6 + unicode_codepoint));
      return 0;
   } else if (format == 6) {
      stbtt_uint32 first = ttUSHORT(data + index_map + 6);
      stbtt_uint32 count = ttUSHORT(data + index_map + 8);
      if (cast(stbtt_uint32) unicode_codepoint >= first && cast(stbtt_uint32) unicode_codepoint < first+count)
         return ttUSHORT(data + index_map + 10 + (unicode_codepoint - first)*2);
      return 0;
   } else if (format == 2) {
      assert(0);
      return 0;
   } else if (format == 4) {
      stbtt_uint16 segcount = ttUSHORT(data+index_map+6) >> 1;
      stbtt_uint16 searchRange = ttUSHORT(data+index_map+8) >> 1;
      stbtt_uint16 entrySelector = ttUSHORT(data+index_map+10);
      stbtt_uint16 rangeShift = ttUSHORT(data+index_map+12) >> 1;


      stbtt_uint32 endCount = index_map + 14;
      stbtt_uint32 search = endCount;

      if (unicode_codepoint > 0xffff)
         return 0;



      if (unicode_codepoint >= ttUSHORT(data + search + rangeShift*2))
         search += rangeShift*2;


      search -= 2;
      while (entrySelector) {
         stbtt_uint16 end = void;
         searchRange >>= 1;
         end = ttUSHORT(data + search + searchRange*2);
         if (unicode_codepoint > end)
            search += searchRange*2;
         --entrySelector;
      }
      search += 2;

      {
         stbtt_uint16 offset = void, start = void, last = void;
         stbtt_uint16 item = cast(stbtt_uint16) ((search - endCount) >> 1);

         start = ttUSHORT(data + index_map + 14 + segcount*2 + 2 + 2*item);
         last = ttUSHORT(data + endCount + 2*item);
         if (unicode_codepoint < start || unicode_codepoint > last)
            return 0;

         offset = ttUSHORT(data + index_map + 14 + segcount*6 + 2 + 2*item);
         if (offset == 0)
            return cast(stbtt_uint16) (unicode_codepoint + ttSHORT(data + index_map + 14 + segcount*4 + 2 + 2*item));

         return ttUSHORT(data + offset + (unicode_codepoint-start)*2 + index_map + 14 + segcount*6 + 2 + 2*item);
      }
   } else if (format == 12 || format == 13) {
      stbtt_uint32 ngroups = ttULONG(data+index_map+12);
      stbtt_int32 low = void, high = void;
      low = 0; high = cast(stbtt_int32)ngroups;

      while (low < high) {
         stbtt_int32 mid = low + ((high-low) >> 1);
         stbtt_uint32 start_char = ttULONG(data+index_map+16+mid*12);
         stbtt_uint32 end_char = ttULONG(data+index_map+16+mid*12+4);
         if (cast(stbtt_uint32) unicode_codepoint < start_char)
            high = mid;
         else if (cast(stbtt_uint32) unicode_codepoint > end_char)
            low = mid+1;
         else {
            stbtt_uint32 start_glyph = ttULONG(data+index_map+16+mid*12+8);
            if (format == 12)
               return start_glyph + unicode_codepoint-start_char;
            else
               return start_glyph;
         }
      }
      return 0;
   }

   assert(0);
   return 0;
}

int stbtt_GetCodepointShape(const(stbtt_fontinfo)* info, int unicode_codepoint, stbtt_vertex** vertices)
{
   return stbtt_GetGlyphShape(info, stbtt_FindGlyphIndex(info, unicode_codepoint), vertices);
}

void stbtt_setvertex(stbtt_vertex* v, stbtt_uint8 type, stbtt_int32 x, stbtt_int32 y, stbtt_int32 cx, stbtt_int32 cy)
{
   v.type = type;
   v.x = cast(stbtt_int16) x;
   v.y = cast(stbtt_int16) y;
   v.cx = cast(stbtt_int16) cx;
   v.cy = cast(stbtt_int16) cy;
}

int stbtt__GetGlyfOffset(const(stbtt_fontinfo)* info, int glyph_index)
{
   int g1 = void, g2 = void;

   assert(!info.cff.size);

   if (glyph_index >= info.numGlyphs) return -1;
   if (info.indexToLocFormat >= 2) return -1;

   if (info.indexToLocFormat == 0) {
      g1 = info.glyf + ttUSHORT(info.data + info.loca + glyph_index * 2) * 2;
      g2 = info.glyf + ttUSHORT(info.data + info.loca + glyph_index * 2 + 2) * 2;
   } else {
      g1 = info.glyf + ttULONG (info.data + info.loca + glyph_index * 4);
      g2 = info.glyf + ttULONG (info.data + info.loca + glyph_index * 4 + 4);
   }

   return g1==g2 ? -1 : g1;
}

int stbtt__GetGlyphInfoT2(const(stbtt_fontinfo)* info, int glyph_index, int* x0, int* y0, int* x1, int* y1);

int stbtt_GetGlyphBox(const(stbtt_fontinfo)* info, int glyph_index, int* x0, int* y0, int* x1, int* y1)
{
   if (info.cff.size) {
      stbtt__GetGlyphInfoT2(info, glyph_index, x0, y0, x1, y1);
   } else {
      int g = stbtt__GetGlyfOffset(info, glyph_index);
      if (g < 0) return 0;

      if (x0) *x0 = ttSHORT(info.data + g + 2);
      if (y0) *y0 = ttSHORT(info.data + g + 4);
      if (x1) *x1 = ttSHORT(info.data + g + 6);
      if (y1) *y1 = ttSHORT(info.data + g + 8);
   }
   return 1;
}

int stbtt_GetCodepointBox(const(stbtt_fontinfo)* info, int codepoint, int* x0, int* y0, int* x1, int* y1)
{
   return stbtt_GetGlyphBox(info, stbtt_FindGlyphIndex(info,codepoint), x0,y0,x1,y1);
}

int stbtt_IsGlyphEmpty(const(stbtt_fontinfo)* info, int glyph_index)
{
   stbtt_int16 numberOfContours = void;
   int g = void;
   if (info.cff.size)
      return stbtt__GetGlyphInfoT2(info, glyph_index, null, null, null, null) == 0;
   g = stbtt__GetGlyfOffset(info, glyph_index);
   if (g < 0) return 1;
   numberOfContours = ttSHORT(info.data + g);
   return numberOfContours == 0;
}

int stbtt__close_shape(stbtt_vertex* vertices, int num_vertices, int was_off, int start_off, stbtt_int32 sx, stbtt_int32 sy, stbtt_int32 scx, stbtt_int32 scy, stbtt_int32 cx, stbtt_int32 cy)
{
   if (start_off) {
      if (was_off)
         stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, (cx+scx)>>1, (cy+scy)>>1, cx,cy);
      stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, sx,sy,scx,scy);
   } else {
      if (was_off)
         stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve,sx,sy,cx,cy);
      else
         stbtt_setvertex(&vertices[num_vertices++], STBTT_vline,sx,sy,0,0);
   }
   return num_vertices;
}

int stbtt__GetGlyphShapeTT(const(stbtt_fontinfo)* info, int glyph_index, stbtt_vertex** pvertices)
{
   stbtt_int16 numberOfContours = void;
   stbtt_uint8* endPtsOfContours = void;
   stbtt_uint8* data = info.data;
   stbtt_vertex* vertices = null;
   int num_vertices = 0;
   int g = stbtt__GetGlyfOffset(info, glyph_index);

   *pvertices = null;

   if (g < 0) return 0;

   numberOfContours = ttSHORT(data + g);

   if (numberOfContours > 0) {
      stbtt_uint8 flags = 0, flagcount = void;
      stbtt_int32 ins = void, i = void, j = 0, m = void, n = void, next_move = void, was_off = 0, off = void, start_off = 0;
      stbtt_int32 x = void, y = void, cx = void, cy = void, sx = void, sy = void, scx = void, scy = void;
      stbtt_uint8* points = void;
      endPtsOfContours = (data + g + 10);
      ins = ttUSHORT(data + g + 10 + numberOfContours * 2);
      points = data + g + 10 + numberOfContours * 2 + 2 + ins;

      n = 1+ttUSHORT(endPtsOfContours + numberOfContours*2-2);

      m = n + 2*numberOfContours;
      vertices = cast(stbtt_vertex*) (cast(void)(info.userdata),malloc(m * typeof(vertices[0]).sizeof));
      if (vertices == 0)
         return 0;

      next_move = 0;
      flagcount=0;





      off = m - n;



      for (i=0; i < n; ++i) {
         if (flagcount == 0) {
            flags = *points++;
            if (flags & 8)
               flagcount = *points++;
         } else
            --flagcount;
         vertices[off+i].type = flags;
      }


      x=0;
      for (i=0; i < n; ++i) {
         flags = vertices[off+i].type;
         if (flags & 2) {
            stbtt_int16 dx = *points++;
            x += (flags & 16) ? dx : -dx;
         } else {
            if (!(flags & 16)) {
               x = x + cast(stbtt_int16) (points[0]*256 + points[1]);
               points += cast(stbtt_uint8*) 2;
            }
         }
         vertices[off+i].x = cast(stbtt_int16) x;
      }


      y=0;
      for (i=0; i < n; ++i) {
         flags = vertices[off+i].type;
         if (flags & 4) {
            stbtt_int16 dy = *points++;
            y += (flags & 32) ? dy : -dy;
         } else {
            if (!(flags & 32)) {
               y = y + cast(stbtt_int16) (points[0]*256 + points[1]);
               points += cast(stbtt_uint8*) 2;
            }
         }
         vertices[off+i].y = cast(stbtt_int16) y;
      }


      num_vertices=0;
      sx = sy = cx = cy = scx = scy = 0;
      for (i=0; i < n; ++i) {
         flags = vertices[off+i].type;
         x = cast(stbtt_int16) vertices[off+i].x;
         y = cast(stbtt_int16) vertices[off+i].y;

         if (next_move == i) {
            if (i != 0)
               num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx,sy,scx,scy,cx,cy);


            start_off = !(flags & 1);
            if (start_off) {


               scx = x;
               scy = y;
               if (!(vertices[off+i+1].type & 1)) {

                  sx = (x + cast(stbtt_int32) vertices[off+i+1].x) >> 1;
                  sy = (y + cast(stbtt_int32) vertices[off+i+1].y) >> 1;
               } else {

                  sx = cast(stbtt_int32) vertices[off+i+1].x;
                  sy = cast(stbtt_int32) vertices[off+i+1].y;
                  ++i;
               }
            } else {
               sx = x;
               sy = y;
            }
            stbtt_setvertex(&vertices[num_vertices++], STBTT_vmove,sx,sy,0,0);
            was_off = 0;
            next_move = 1 + ttUSHORT(endPtsOfContours+j*2);
            ++j;
         } else {
            if (!(flags & 1)) {
               if (was_off)
                  stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, (cx+x)>>1, (cy+y)>>1, cx, cy);
               cx = x;
               cy = y;
               was_off = 1;
            } else {
               if (was_off)
                  stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, x,y, cx, cy);
               else
                  stbtt_setvertex(&vertices[num_vertices++], STBTT_vline, x,y,0,0);
               was_off = 0;
            }
         }
      }
      num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx,sy,scx,scy,cx,cy);
   } else if (numberOfContours < 0) {

      int more = 1;
      stbtt_uint8* comp = data + g + 10;
      num_vertices = 0;
      vertices = null;
      while (more) {
         stbtt_uint16 flags = void, gidx = void;
         int comp_num_verts = 0, i = void;
         stbtt_vertex* comp_verts = null, tmp = null;
         float[6] mtx = [1,0,0,1,0,0]; float m = void, n = void;

         flags = ttSHORT(comp); comp+=cast(stbtt_uint8*) 2;
         gidx = ttSHORT(comp); comp+=cast(stbtt_uint8*) 2;

         if (flags & 2) {
            if (flags & 1) {
               mtx[4] = ttSHORT(comp); comp+=cast(stbtt_uint8*) 2;
               mtx[5] = ttSHORT(comp); comp+=cast(stbtt_uint8*) 2;
            } else {
               mtx[4] = (* cast(stbtt_int8*) (comp)); comp+=cast(stbtt_uint8*) 1;
               mtx[5] = (* cast(stbtt_int8*) (comp)); comp+=cast(stbtt_uint8*) 1;
            }
         }
         else {

            assert(0);
         }
         if (flags & (1<<3)) {
            mtx[0] = mtx[3] = ttSHORT(comp)/16384.0f; comp+=cast(stbtt_uint8*) 2;
            mtx[1] = mtx[2] = 0;
         } else if (flags & (1<<6)) {
            mtx[0] = ttSHORT(comp)/16384.0f; comp+=cast(stbtt_uint8*) 2;
            mtx[1] = mtx[2] = 0;
            mtx[3] = ttSHORT(comp)/16384.0f; comp+=cast(stbtt_uint8*) 2;
         } else if (flags & (1<<7)) {
            mtx[0] = ttSHORT(comp)/16384.0f; comp+=cast(stbtt_uint8*) 2;
            mtx[1] = ttSHORT(comp)/16384.0f; comp+=cast(stbtt_uint8*) 2;
            mtx[2] = ttSHORT(comp)/16384.0f; comp+=cast(stbtt_uint8*) 2;
            mtx[3] = ttSHORT(comp)/16384.0f; comp+=cast(stbtt_uint8*) 2;
         }


         m = cast(float) sqrt(mtx[0]*mtx[0] + mtx[1]*mtx[1]);
         n = cast(float) sqrt(mtx[2]*mtx[2] + mtx[3]*mtx[3]);


         comp_num_verts = stbtt_GetGlyphShape(info, gidx, &comp_verts);
         if (comp_num_verts > 0) {

            for (i = 0; i < comp_num_verts; ++i) {
               stbtt_vertex* v = &comp_verts[i];
               short x = void, y = void;
               x=v.x; y=v.y;
               v.x = cast(short)(m * (mtx[0]*x + mtx[2]*y + mtx[4]));
               v.y = cast(short)(n * (mtx[1]*x + mtx[3]*y + mtx[5]));
               x=v.cx; y=v.cy;
               v.cx = cast(short)(m * (mtx[0]*x + mtx[2]*y + mtx[4]));
               v.cy = cast(short)(n * (mtx[1]*x + mtx[3]*y + mtx[5]));
            }

            tmp = cast(stbtt_vertex*)(cast(void)(info.userdata),malloc((num_vertices+comp_num_verts)*stbtt_vertex.sizeof));
            if (!tmp) {
               if (vertices) (cast(void)(info.userdata),free(vertices));
               if (comp_verts) (cast(void)(info.userdata),free(comp_verts));
               return 0;
            }
            if (num_vertices > 0 && vertices) memcpy(tmp, vertices, num_vertices*stbtt_vertex.sizeof);
            memcpy(tmp+num_vertices, comp_verts, comp_num_verts*stbtt_vertex.sizeof);
            if (vertices) (cast(void)(info.userdata),free(vertices));
            vertices = tmp;
            (cast(void)(info.userdata),free(comp_verts));
            num_vertices += comp_num_verts;
         }

         more = flags & (1<<5);
      }
   } else {

   }

   *pvertices = vertices;
   return num_vertices;
}

struct stbtt__csctx {
   int bounds;
   int started;
   float first_x = 0, first_y = 0;
   float x = 0, y = 0;
   stbtt_int32 min_x, max_x, min_y, max_y;

   stbtt_vertex* pvertices;
   int num_vertices;
}



void stbtt__track_vertex(stbtt__csctx* c, stbtt_int32 x, stbtt_int32 y)
{
   if (x > c.max_x || !c.started) c.max_x = x;
   if (y > c.max_y || !c.started) c.max_y = y;
   if (x < c.min_x || !c.started) c.min_x = x;
   if (y < c.min_y || !c.started) c.min_y = y;
   c.started = 1;
}

void stbtt__csctx_v(stbtt__csctx* c, stbtt_uint8 type, stbtt_int32 x, stbtt_int32 y, stbtt_int32 cx, stbtt_int32 cy, stbtt_int32 cx1, stbtt_int32 cy1)
{
   if (c.bounds) {
      stbtt__track_vertex(c, x, y);
      if (type == STBTT_vcubic) {
         stbtt__track_vertex(c, cx, cy);
         stbtt__track_vertex(c, cx1, cy1);
      }
   } else {
      stbtt_setvertex(&c.pvertices[c.num_vertices], type, x, y, cx, cy);
      c.pvertices[c.num_vertices].cx1 = cast(stbtt_int16) cx1;
      c.pvertices[c.num_vertices].cy1 = cast(stbtt_int16) cy1;
   }
   c.num_vertices++;
}

void stbtt__csctx_close_shape(stbtt__csctx* ctx)
{
   if (ctx.first_x != ctx.x || ctx.first_y != ctx.y)
      stbtt__csctx_v(ctx, STBTT_vline, cast(int)ctx.first_x, cast(int)ctx.first_y, 0, 0, 0, 0);
}

void stbtt__csctx_rmove_to(stbtt__csctx* ctx, float dx, float dy)
{
   stbtt__csctx_close_shape(ctx);
   ctx.first_x = ctx.x = ctx.x + dx;
   ctx.first_y = ctx.y = ctx.y + dy;
   stbtt__csctx_v(ctx, STBTT_vmove, cast(int)ctx.x, cast(int)ctx.y, 0, 0, 0, 0);
}

void stbtt__csctx_rline_to(stbtt__csctx* ctx, float dx, float dy)
{
   ctx.x += dx;
   ctx.y += dy;
   stbtt__csctx_v(ctx, STBTT_vline, cast(int)ctx.x, cast(int)ctx.y, 0, 0, 0, 0);
}

void stbtt__csctx_rccurve_to(stbtt__csctx* ctx, float dx1, float dy1, float dx2, float dy2, float dx3, float dy3)
{
   float cx1 = ctx.x + dx1;
   float cy1 = ctx.y + dy1;
   float cx2 = cx1 + dx2;
   float cy2 = cy1 + dy2;
   ctx.x = cx2 + dx3;
   ctx.y = cy2 + dy3;
   stbtt__csctx_v(ctx, STBTT_vcubic, cast(int)ctx.x, cast(int)ctx.y, cast(int)cx1, cast(int)cy1, cast(int)cx2, cast(int)cy2);
}

stbtt__buf stbtt__get_subr(stbtt__buf idx, int n)
{
   int count = stbtt__cff_index_count(&idx);
   int bias = 107;
   if (count >= 33900)
      bias = 32768;
   else if (count >= 1240)
      bias = 1131;
   n += bias;
   if (n < 0 || n >= count)
      return stbtt__new_buf(null, 0);
   return stbtt__cff_index_get(idx, n);
}

stbtt__buf stbtt__cid_get_glyph_subrs(const(stbtt_fontinfo)* info, int glyph_index)
{
   stbtt__buf fdselect = info.fdselect;
   int nranges = void, start = void, end = void, v = void, fmt = void, fdselector = -1, i = void;

   stbtt__buf_seek(&fdselect, 0);
   fmt = stbtt__buf_get8(&fdselect);
   if (fmt == 0) {

      stbtt__buf_skip(&fdselect, glyph_index);
      fdselector = stbtt__buf_get8(&fdselect);
   } else if (fmt == 3) {
      nranges = stbtt__buf_get((&fdselect), 2);
      start = stbtt__buf_get((&fdselect), 2);
      for (i = 0; i < nranges; i++) {
         v = stbtt__buf_get8(&fdselect);
         end = stbtt__buf_get((&fdselect), 2);
         if (glyph_index >= start && glyph_index < end) {
            fdselector = v;
            break;
         }
         start = end;
      }
   }
   if (fdselector == -1) stbtt__new_buf(null, 0);
   return stbtt__get_subrs(info.cff, stbtt__cff_index_get(info.fontdicts, fdselector));
}

int stbtt__run_charstring(const(stbtt_fontinfo)* info, int glyph_index, stbtt__csctx* c)
{
   int in_header = 1, maskbits = 0, subr_stack_height = 0, sp = 0, v = void, i = void, b0 = void;
   int has_subrs = 0, clear_stack = void;
   float[48] s = void;
   stbtt__buf[10] subr_stack = void; stbtt__buf subrs = info.subrs, b = void;
   float f = void;




   b = stbtt__cff_index_get(info.charstrings, glyph_index);
   while (b.cursor < b.size) {
      i = 0;
      clear_stack = 1;
      b0 = stbtt__buf_get8(&b);
      switch (b0) {

      case 0x13:
      case 0x14:
         if (in_header)
            maskbits += (sp / 2);
         in_header = 0;
         stbtt__buf_skip(&b, (maskbits + 7) / 8);
         break;

      case 0x01:
      case 0x03:
      case 0x12:
      case 0x17:
         maskbits += (sp / 2);
         break;

      case 0x15:
         in_header = 0;
         if (sp < 2) return (0);
         stbtt__csctx_rmove_to(c, s[sp-2], s[sp-1]);
         break;
      case 0x04:
         in_header = 0;
         if (sp < 1) return (0);
         stbtt__csctx_rmove_to(c, 0, s[sp-1]);
         break;
      case 0x16:
         in_header = 0;
         if (sp < 1) return (0);
         stbtt__csctx_rmove_to(c, s[sp-1], 0);
         break;

      case 0x05:
         if (sp < 2) return (0);
         for (; i + 1 < sp; i += 2)
            stbtt__csctx_rline_to(c, s[i], s[i+1]);
         break;




      case 0x07:
         if (sp < 1) return (0);
         goto vlineto;
      case 0x06:
         if (sp < 1) return (0);
         for (;;) {
            if (i >= sp) break;
            stbtt__csctx_rline_to(c, s[i], 0);
            i++;
      vlineto:
            if (i >= sp) break;
            stbtt__csctx_rline_to(c, 0, s[i]);
            i++;
         }
         break;

      case 0x1F:
         if (sp < 4) return (0);
         goto hvcurveto;
      case 0x1E:
         if (sp < 4) return (0);
         for (;;) {
            if (i + 3 >= sp) break;
            stbtt__csctx_rccurve_to(c, 0, s[i], s[i+1], s[i+2], s[i+3], (sp - i == 5) ? s[i + 4] : 0.0f);
            i += 4;
      hvcurveto:
            if (i + 3 >= sp) break;
            stbtt__csctx_rccurve_to(c, s[i], 0, s[i+1], s[i+2], (sp - i == 5) ? s[i+4] : 0.0f, s[i+3]);
            i += 4;
         }
         break;

      case 0x08:
         if (sp < 6) return (0);
         for (; i + 5 < sp; i += 6)
            stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
         break;

      case 0x18:
         if (sp < 8) return (0);
         for (; i + 5 < sp - 2; i += 6)
            stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
         if (i + 1 >= sp) return (0);
         stbtt__csctx_rline_to(c, s[i], s[i+1]);
         break;

      case 0x19:
         if (sp < 8) return (0);
         for (; i + 1 < sp - 6; i += 2)
            stbtt__csctx_rline_to(c, s[i], s[i+1]);
         if (i + 5 >= sp) return (0);
         stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
         break;

      case 0x1A:
      case 0x1B:
         if (sp < 4) return (0);
         f = 0.0;
         if (sp & 1) { f = s[i]; i++; }
         for (; i + 3 < sp; i += 4) {
            if (b0 == 0x1B)
               stbtt__csctx_rccurve_to(c, s[i], f, s[i+1], s[i+2], s[i+3], 0.0);
            else
               stbtt__csctx_rccurve_to(c, f, s[i], s[i+1], s[i+2], 0.0, s[i+3]);
            f = 0.0;
         }
         break;

      case 0x0A:
         if (!has_subrs) {
            if (info.fdselect.size)
               subrs = stbtt__cid_get_glyph_subrs(info, glyph_index);
            has_subrs = 1;
         }

      case 0x1D:
         if (sp < 1) return (0);
         v = cast(int) s[--sp];
         if (subr_stack_height >= 10) return (0);
         subr_stack[subr_stack_height++] = b;
         b = stbtt__get_subr(b0 == 0x0A ? subrs : info.gsubrs, v);
         if (b.size == 0) return (0);
         b.cursor = 0;
         clear_stack = 0;
         break;

      case 0x0B:
         if (subr_stack_height <= 0) return (0);
         b = subr_stack[--subr_stack_height];
         clear_stack = 0;
         break;

      case 0x0E:
         stbtt__csctx_close_shape(c);
         return 1;

      case 0x0C: {
         float dx1 = void, dx2 = void, dx3 = void, dx4 = void, dx5 = void, dx6 = void, dy1 = void, dy2 = void, dy3 = void, dy4 = void, dy5 = void, dy6 = void;
         float dx = void, dy = void;
         int b1 = stbtt__buf_get8(&b);
         switch (b1) {


         case 0x22:
            if (sp < 7) return (0);
            dx1 = s[0];
            dx2 = s[1];
            dy2 = s[2];
            dx3 = s[3];
            dx4 = s[4];
            dx5 = s[5];
            dx6 = s[6];
            stbtt__csctx_rccurve_to(c, dx1, 0, dx2, dy2, dx3, 0);
            stbtt__csctx_rccurve_to(c, dx4, 0, dx5, -dy2, dx6, 0);
            break;

         case 0x23:
            if (sp < 13) return (0);
            dx1 = s[0];
            dy1 = s[1];
            dx2 = s[2];
            dy2 = s[3];
            dx3 = s[4];
            dy3 = s[5];
            dx4 = s[6];
            dy4 = s[7];
            dx5 = s[8];
            dy5 = s[9];
            dx6 = s[10];
            dy6 = s[11];

            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
            stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
            break;

         case 0x24:
            if (sp < 9) return (0);
            dx1 = s[0];
            dy1 = s[1];
            dx2 = s[2];
            dy2 = s[3];
            dx3 = s[4];
            dx4 = s[5];
            dx5 = s[6];
            dy5 = s[7];
            dx6 = s[8];
            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, 0);
            stbtt__csctx_rccurve_to(c, dx4, 0, dx5, dy5, dx6, -(dy1+dy2+dy5));
            break;

         case 0x25:
            if (sp < 11) return (0);
            dx1 = s[0];
            dy1 = s[1];
            dx2 = s[2];
            dy2 = s[3];
            dx3 = s[4];
            dy3 = s[5];
            dx4 = s[6];
            dy4 = s[7];
            dx5 = s[8];
            dy5 = s[9];
            dx6 = dy6 = s[10];
            dx = dx1+dx2+dx3+dx4+dx5;
            dy = dy1+dy2+dy3+dy4+dy5;
            if (fabs(dx) > fabs(dy))
               dy6 = -dy;
            else
               dx6 = -dx;
            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
            stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
            break;

         default:
            return (0);
         }
      } break;

      default:
         if (b0 != 255 && b0 != 28 && b0 < 32)
            return (0);


         if (b0 == 255) {
            f = cast(float)cast(stbtt_int32)stbtt__buf_get((&b), 4) / 0x10000;
         } else {
            stbtt__buf_skip(&b, -1);
            f = cast(float)cast(stbtt_int16)stbtt__cff_int(&b);
         }
         if (sp >= 48) return (0);
         s[sp++] = f;
         clear_stack = 0;
         break;
      }
      if (clear_stack) sp = 0;
   }
   return (0);


}

int stbtt__GetGlyphShapeT2(const(stbtt_fontinfo)* info, int glyph_index, stbtt_vertex** pvertices)
{

   stbtt__csctx count_ctx = {1,0, 0,0, 0,0, 0,0,0,0, null, 0};
   stbtt__csctx output_ctx = {0,0, 0,0, 0,0, 0,0,0,0, null, 0};
   if (stbtt__run_charstring(info, glyph_index, &count_ctx)) {
      *pvertices = cast(stbtt_vertex*)(cast(void)(info.userdata),malloc(count_ctx.num_vertices*stbtt_vertex.sizeof));
      output_ctx.pvertices = *pvertices;
      if (stbtt__run_charstring(info, glyph_index, &output_ctx)) {
         assert(output_ctx.num_vertices == count_ctx.num_vertices);
         return output_ctx.num_vertices;
      }
   }
   *pvertices = null;
   return 0;
}

int stbtt__GetGlyphInfoT2(const(stbtt_fontinfo)* info, int glyph_index, int* x0, int* y0, int* x1, int* y1)
{
   stbtt__csctx c = {1,0, 0,0, 0,0, 0,0,0,0, null, 0};
   int r = stbtt__run_charstring(info, glyph_index, &c);
   if (x0) *x0 = r ? c.min_x : 0;
   if (y0) *y0 = r ? c.min_y : 0;
   if (x1) *x1 = r ? c.max_x : 0;
   if (y1) *y1 = r ? c.max_y : 0;
   return r ? c.num_vertices : 0;
}

int stbtt_GetGlyphShape(const(stbtt_fontinfo)* info, int glyph_index, stbtt_vertex** pvertices)
{
   if (!info.cff.size)
      return stbtt__GetGlyphShapeTT(info, glyph_index, pvertices);
   else
      return stbtt__GetGlyphShapeT2(info, glyph_index, pvertices);
}

void stbtt_GetGlyphHMetrics(const(stbtt_fontinfo)* info, int glyph_index, int* advanceWidth, int* leftSideBearing)
{
   stbtt_uint16 numOfLongHorMetrics = ttUSHORT(info.data+info.hhea + 34);
   if (glyph_index < numOfLongHorMetrics) {
      if (advanceWidth) *advanceWidth = ttSHORT(info.data + info.hmtx + 4*glyph_index);
      if (leftSideBearing) *leftSideBearing = ttSHORT(info.data + info.hmtx + 4*glyph_index + 2);
   } else {
      if (advanceWidth) *advanceWidth = ttSHORT(info.data + info.hmtx + 4*(numOfLongHorMetrics-1));
      if (leftSideBearing) *leftSideBearing = ttSHORT(info.data + info.hmtx + 4*numOfLongHorMetrics + 2*(glyph_index - numOfLongHorMetrics));
   }
}

int stbtt_GetKerningTableLength(const(stbtt_fontinfo)* info)
{
   stbtt_uint8* data = info.data + info.kern;


   if (!info.kern)
      return 0;
   if (ttUSHORT(data+2) < 1)
      return 0;
   if (ttUSHORT(data+8) != 1)
      return 0;

   return ttUSHORT(data+10);
}

int stbtt_GetKerningTable(const(stbtt_fontinfo)* info, stbtt_kerningentry* table, int table_length)
{
   stbtt_uint8* data = info.data + info.kern;
   int k = void, length = void;


   if (!info.kern)
      return 0;
   if (ttUSHORT(data+2) < 1)
      return 0;
   if (ttUSHORT(data+8) != 1)
      return 0;

   length = ttUSHORT(data+10);
   if (table_length < length)
      length = table_length;

   for (k = 0; k < length; k++)
   {
      table[k].glyph1 = ttUSHORT(data+18+(k*6));
      table[k].glyph2 = ttUSHORT(data+20+(k*6));
      table[k].advance = ttSHORT(data+22+(k*6));
   }

   return length;
}

int stbtt__GetGlyphKernInfoAdvance(const(stbtt_fontinfo)* info, int glyph1, int glyph2)
{
   stbtt_uint8* data = info.data + info.kern;
   stbtt_uint32 needle = void, straw = void;
   int l = void, r = void, m = void;


   if (!info.kern)
      return 0;
   if (ttUSHORT(data+2) < 1)
      return 0;
   if (ttUSHORT(data+8) != 1)
      return 0;

   l = 0;
   r = ttUSHORT(data+10) - 1;
   needle = glyph1 << 16 | glyph2;
   while (l <= r) {
      m = (l + r) >> 1;
      straw = ttULONG(data+18+(m*6));
      if (needle < straw)
         r = m - 1;
      else if (needle > straw)
         l = m + 1;
      else
         return ttSHORT(data+22+(m*6));
   }
   return 0;
}

stbtt_int32 stbtt__GetCoverageIndex(stbtt_uint8* coverageTable, int glyph)
{
   stbtt_uint16 coverageFormat = ttUSHORT(coverageTable);
   switch (coverageFormat) {
      case 1: {
         stbtt_uint16 glyphCount = ttUSHORT(coverageTable + 2);


         stbtt_int32 l = 0, r = glyphCount-1, m = void;
         int straw = void, needle = glyph;
         while (l <= r) {
            stbtt_uint8* glyphArray = coverageTable + 4;
            stbtt_uint16 glyphID = void;
            m = (l + r) >> 1;
            glyphID = ttUSHORT(glyphArray + 2 * m);
            straw = glyphID;
            if (needle < straw)
               r = m - 1;
            else if (needle > straw)
               l = m + 1;
            else {
               return m;
            }
         }
         break;
      }

      case 2: {
         stbtt_uint16 rangeCount = ttUSHORT(coverageTable + 2);
         stbtt_uint8* rangeArray = coverageTable + 4;


         stbtt_int32 l = 0, r = rangeCount-1, m = void;
         int strawStart = void, strawEnd = void, needle = glyph;
         while (l <= r) {
            stbtt_uint8* rangeRecord = void;
            m = (l + r) >> 1;
            rangeRecord = rangeArray + 6 * m;
            strawStart = ttUSHORT(rangeRecord);
            strawEnd = ttUSHORT(rangeRecord + 2);
            if (needle < strawStart)
               r = m - 1;
            else if (needle > strawEnd)
               l = m + 1;
            else {
               stbtt_uint16 startCoverageIndex = ttUSHORT(rangeRecord + 4);
               return startCoverageIndex + glyph - strawStart;
            }
         }
         break;
      }

      default: return -1;
   }

   return -1;
}

stbtt_int32 stbtt__GetGlyphClass(stbtt_uint8* classDefTable, int glyph)
{
   stbtt_uint16 classDefFormat = ttUSHORT(classDefTable);
   switch (classDefFormat)
   {
      case 1: {
         stbtt_uint16 startGlyphID = ttUSHORT(classDefTable + 2);
         stbtt_uint16 glyphCount = ttUSHORT(classDefTable + 4);
         stbtt_uint8* classDef1ValueArray = classDefTable + 6;

         if (glyph >= startGlyphID && glyph < startGlyphID + glyphCount)
            return cast(stbtt_int32)ttUSHORT(classDef1ValueArray + 2 * (glyph - startGlyphID));
         break;
      }

      case 2: {
         stbtt_uint16 classRangeCount = ttUSHORT(classDefTable + 2);
         stbtt_uint8* classRangeRecords = classDefTable + 4;


         stbtt_int32 l = 0, r = classRangeCount-1, m = void;
         int strawStart = void, strawEnd = void, needle = glyph;
         while (l <= r) {
            stbtt_uint8* classRangeRecord = void;
            m = (l + r) >> 1;
            classRangeRecord = classRangeRecords + 6 * m;
            strawStart = ttUSHORT(classRangeRecord);
            strawEnd = ttUSHORT(classRangeRecord + 2);
            if (needle < strawStart)
               r = m - 1;
            else if (needle > strawEnd)
               l = m + 1;
            else
               return cast(stbtt_int32)ttUSHORT(classRangeRecord + 4);
         }
         break;
      }

      default:
         return -1;
   }


   return 0;
}




stbtt_int32 stbtt__GetGlyphGPOSInfoAdvance(const(stbtt_fontinfo)* info, int glyph1, int glyph2)
{
   stbtt_uint16 lookupListOffset = void;
   stbtt_uint8* lookupList = void;
   stbtt_uint16 lookupCount = void;
   stbtt_uint8* data = void;
   stbtt_int32 i = void, sti = void;

   if (!info.gpos) return 0;

   data = info.data + info.gpos;

   if (ttUSHORT(data+0) != 1) return 0;
   if (ttUSHORT(data+2) != 0) return 0;

   lookupListOffset = ttUSHORT(data+8);
   lookupList = data + lookupListOffset;
   lookupCount = ttUSHORT(lookupList);

   for (i=0; i<lookupCount; ++i) {
      stbtt_uint16 lookupOffset = ttUSHORT(lookupList + 2 + 2 * i);
      stbtt_uint8* lookupTable = lookupList + lookupOffset;

      stbtt_uint16 lookupType = ttUSHORT(lookupTable);
      stbtt_uint16 subTableCount = ttUSHORT(lookupTable + 4);
      stbtt_uint8* subTableOffsets = lookupTable + 6;
      if (lookupType != 2)
         continue;

      for (sti=0; sti<subTableCount; sti++) {
         stbtt_uint16 subtableOffset = ttUSHORT(subTableOffsets + 2 * sti);
         stbtt_uint8* table = lookupTable + subtableOffset;
         stbtt_uint16 posFormat = ttUSHORT(table);
         stbtt_uint16 coverageOffset = ttUSHORT(table + 2);
         stbtt_int32 coverageIndex = stbtt__GetCoverageIndex(table + coverageOffset, glyph1);
         if (coverageIndex == -1) continue;

         switch (posFormat) {
            case 1: {
               stbtt_int32 l = void, r = void, m = void;
               int straw = void, needle = void;
               stbtt_uint16 valueFormat1 = ttUSHORT(table + 4);
               stbtt_uint16 valueFormat2 = ttUSHORT(table + 6);
               if (valueFormat1 == 4 && valueFormat2 == 0) {
                  stbtt_int32 valueRecordPairSizeInBytes = 2;
                  stbtt_uint16 pairSetCount = ttUSHORT(table + 8);
                  stbtt_uint16 pairPosOffset = ttUSHORT(table + 10 + 2 * coverageIndex);
                  stbtt_uint8* pairValueTable = table + pairPosOffset;
                  stbtt_uint16 pairValueCount = ttUSHORT(pairValueTable);
                  stbtt_uint8* pairValueArray = pairValueTable + 2;

                  if (coverageIndex >= pairSetCount) return 0;

                  needle=glyph2;
                  r=pairValueCount-1;
                  l=0;


                  while (l <= r) {
                     stbtt_uint16 secondGlyph = void;
                     stbtt_uint8* pairValue = void;
                     m = (l + r) >> 1;
                     pairValue = pairValueArray + (2 + valueRecordPairSizeInBytes) * m;
                     secondGlyph = ttUSHORT(pairValue);
                     straw = secondGlyph;
                     if (needle < straw)
                        r = m - 1;
                     else if (needle > straw)
                        l = m + 1;
                     else {
                        stbtt_int16 xAdvance = ttSHORT(pairValue + 2);
                        return xAdvance;
                     }
                  }
               } else
                  return 0;
               break;
            }

            case 2: {
               stbtt_uint16 valueFormat1 = ttUSHORT(table + 4);
               stbtt_uint16 valueFormat2 = ttUSHORT(table + 6);
               if (valueFormat1 == 4 && valueFormat2 == 0) {
                  stbtt_uint16 classDef1Offset = ttUSHORT(table + 8);
                  stbtt_uint16 classDef2Offset = ttUSHORT(table + 10);
                  int glyph1class = stbtt__GetGlyphClass(table + classDef1Offset, glyph1);
                  int glyph2class = stbtt__GetGlyphClass(table + classDef2Offset, glyph2);

                  stbtt_uint16 class1Count = ttUSHORT(table + 12);
                  stbtt_uint16 class2Count = ttUSHORT(table + 14);
                  stbtt_uint8* class1Records = void, class2Records = void;
                  stbtt_int16 xAdvance = void;

                  if (glyph1class < 0 || glyph1class >= class1Count) return 0;
                  if (glyph2class < 0 || glyph2class >= class2Count) return 0;

                  class1Records = table + 16;
                  class2Records = class1Records + 2 * (glyph1class * class2Count);
                  xAdvance = ttSHORT(class2Records + 2 * glyph2class);
                  return xAdvance;
               } else
                  return 0;
               break;
            }

            default:
               return 0;
         }
      }
   }

   return 0;
}

int stbtt_GetGlyphKernAdvance(const(stbtt_fontinfo)* info, int g1, int g2)
{
   int xAdvance = 0;

   if (info.gpos)
      xAdvance += stbtt__GetGlyphGPOSInfoAdvance(info, g1, g2);
   else if (info.kern)
      xAdvance += stbtt__GetGlyphKernInfoAdvance(info, g1, g2);

   return xAdvance;
}

int stbtt_GetCodepointKernAdvance(const(stbtt_fontinfo)* info, int ch1, int ch2)
{
   if (!info.kern && !info.gpos)
      return 0;
   return stbtt_GetGlyphKernAdvance(info, stbtt_FindGlyphIndex(info,ch1), stbtt_FindGlyphIndex(info,ch2));
}

void stbtt_GetCodepointHMetrics(const(stbtt_fontinfo)* info, int codepoint, int* advanceWidth, int* leftSideBearing)
{
   stbtt_GetGlyphHMetrics(info, stbtt_FindGlyphIndex(info,codepoint), advanceWidth, leftSideBearing);
}

void stbtt_GetFontVMetrics(const(stbtt_fontinfo)* info, int* ascent, int* descent, int* lineGap)
{
   if (ascent ) *ascent = ttSHORT(info.data+info.hhea + 4);
   if (descent) *descent = ttSHORT(info.data+info.hhea + 6);
   if (lineGap) *lineGap = ttSHORT(info.data+info.hhea + 8);
}

int stbtt_GetFontVMetricsOS2(const(stbtt_fontinfo)* info, int* typoAscent, int* typoDescent, int* typoLineGap)
{
   int tab = stbtt__find_table(info.data, info.fontstart, "OS/2");
   if (!tab)
      return 0;
   if (typoAscent ) *typoAscent = ttSHORT(info.data+tab + 68);
   if (typoDescent) *typoDescent = ttSHORT(info.data+tab + 70);
   if (typoLineGap) *typoLineGap = ttSHORT(info.data+tab + 72);
   return 1;
}

void stbtt_GetFontBoundingBox(const(stbtt_fontinfo)* info, int* x0, int* y0, int* x1, int* y1)
{
   *x0 = ttSHORT(info.data + info.head + 36);
   *y0 = ttSHORT(info.data + info.head + 38);
   *x1 = ttSHORT(info.data + info.head + 40);
   *y1 = ttSHORT(info.data + info.head + 42);
}

float stbtt_ScaleForPixelHeight(const(stbtt_fontinfo)* info, float height)
{
   int fheight = ttSHORT(info.data + info.hhea + 4) - ttSHORT(info.data + info.hhea + 6);
   return cast(float) height / fheight;
}

float stbtt_ScaleForMappingEmToPixels(const(stbtt_fontinfo)* info, float pixels)
{
   int unitsPerEm = ttUSHORT(info.data + info.head + 18);
   return pixels / unitsPerEm;
}

void stbtt_FreeShape(const(stbtt_fontinfo)* info, stbtt_vertex* v)
{
   (cast(void)(info.userdata),free(v));
}

stbtt_uint8* stbtt_FindSVGDoc(const(stbtt_fontinfo)* info, int gl)
{
   int i = void;
   stbtt_uint8* data = info.data;
   stbtt_uint8* svg_doc_list = data + stbtt__get_svg(cast(stbtt_fontinfo*) info);

   int numEntries = ttUSHORT(svg_doc_list);
   stbtt_uint8* svg_docs = svg_doc_list + 2;

   for(i=0; i<numEntries; i++) {
      stbtt_uint8* svg_doc = svg_docs + (12 * i);
      if ((gl >= ttUSHORT(svg_doc)) && (gl <= ttUSHORT(svg_doc + 2)))
         return svg_doc;
   }
   return 0;
}

int stbtt_GetGlyphSVG(const(stbtt_fontinfo)* info, int gl, const(char)** svg)
{
   stbtt_uint8* data = info.data;
   stbtt_uint8* svg_doc = void;

   if (info.svg == 0)
      return 0;

   svg_doc = stbtt_FindSVGDoc(info, gl);
   if (svg_doc != null) {
      *svg = cast(char*) data + info.svg + ttULONG(svg_doc + 4);
      return ttULONG(svg_doc + 8);
   } else {
      return 0;
   }
}

int stbtt_GetCodepointSVG(const(stbtt_fontinfo)* info, int unicode_codepoint, const(char)** svg)
{
   return stbtt_GetGlyphSVG(info, stbtt_FindGlyphIndex(info, unicode_codepoint), svg);
}






void stbtt_GetGlyphBitmapBoxSubpixel(const(stbtt_fontinfo)* font, int glyph, float scale_x, float scale_y, float shift_x, float shift_y, int* ix0, int* iy0, int* ix1, int* iy1)
{
   int x0 = 0, y0 = 0, x1 = void, y1 = void;
   if (!stbtt_GetGlyphBox(font, glyph, &x0,&y0,&x1,&y1)) {

      if (ix0) *ix0 = 0;
      if (iy0) *iy0 = 0;
      if (ix1) *ix1 = 0;
      if (iy1) *iy1 = 0;
   } else {

      if (ix0) *ix0 = (cast(int) floor(x0 * scale_x + shift_x));
      if (iy0) *iy0 = (cast(int) floor(-y1 * scale_y + shift_y));
      if (ix1) *ix1 = (cast(int) ceil(x1 * scale_x + shift_x));
      if (iy1) *iy1 = (cast(int) ceil(-y0 * scale_y + shift_y));
   }
}

void stbtt_GetGlyphBitmapBox(const(stbtt_fontinfo)* font, int glyph, float scale_x, float scale_y, int* ix0, int* iy0, int* ix1, int* iy1)
{
   stbtt_GetGlyphBitmapBoxSubpixel(font, glyph, scale_x, scale_y,0.0f,0.0f, ix0, iy0, ix1, iy1);
}

void stbtt_GetCodepointBitmapBoxSubpixel(const(stbtt_fontinfo)* font, int codepoint, float scale_x, float scale_y, float shift_x, float shift_y, int* ix0, int* iy0, int* ix1, int* iy1)
{
   stbtt_GetGlyphBitmapBoxSubpixel(font, stbtt_FindGlyphIndex(font,codepoint), scale_x, scale_y,shift_x,shift_y, ix0,iy0,ix1,iy1);
}

void stbtt_GetCodepointBitmapBox(const(stbtt_fontinfo)* font, int codepoint, float scale_x, float scale_y, int* ix0, int* iy0, int* ix1, int* iy1)
{
   stbtt_GetCodepointBitmapBoxSubpixel(font, codepoint, scale_x, scale_y,0.0f,0.0f, ix0,iy0,ix1,iy1);
}





struct stbtt__hheap_chunk {
   stbtt__hheap_chunk* next;
}

struct stbtt__hheap {
   stbtt__hheap_chunk* head;
   void* first_free;
   int num_remaining_in_head_chunk;
}

void* stbtt__hheap_alloc(stbtt__hheap* hh, size_t size, void* userdata)
{
   if (hh.first_free) {
      void* p = hh.first_free;
      hh.first_free = * cast(void**) p;
      return p;
   } else {
      if (hh.num_remaining_in_head_chunk == 0) {
         int count = (size < 32 ? 2000 : size < 128 ? 800 : 100);
         stbtt__hheap_chunk* c = cast(stbtt__hheap_chunk*) (cast(void)(userdata),malloc(sizeofcast(stbtt__hheap_chunk) + size * count));
         if (c == null)
            return null;
         c.next = hh.head;
         hh.head = c;
         hh.num_remaining_in_head_chunk = count;
      }
      --hh.num_remaining_in_head_chunk;
      return cast(char*) (hh.head) + sizeofcast(stbtt__hheap_chunk) + size * hh.num_remaining_in_head_chunk;
   }
}

void stbtt__hheap_free(stbtt__hheap* hh, void* p)
{
   *cast(void**) p = hh.first_free;
   hh.first_free = p;
}

void stbtt__hheap_cleanup(stbtt__hheap* hh, void* userdata)
{
   stbtt__hheap_chunk* c = hh.head;
   while (c) {
      stbtt__hheap_chunk* n = c.next;
      (cast(void)(userdata),free(c));
      c = n;
   }
}

struct stbtt__edge {
   float x0 = 0, y0 = 0, x1 = 0, y1 = 0;
   int invert;
}


struct stbtt__active_edge {
   stbtt__active_edge* next;





   float fx = 0, fdx = 0, fdy = 0;
   float direction = 0;
   float sy = 0;
   float ey = 0;



}
stbtt__active_edge* stbtt__new_active(stbtt__hheap* hh, stbtt__edge* e, int off_x, float start_point, void* userdata)
{
   stbtt__active_edge* z = cast(stbtt__active_edge*) stbtt__hheap_alloc(hh, typeof(*z).sizeof, userdata);
   float dxdy = (e.x1 - e.x0) / (e.y1 - e.y0);
   assert(z != null);

   if (!z) return z;
   z.fdx = dxdy;
   z.fdy = dxdy != 0.0f ? (1.0f/dxdy) : 0.0f;
   z.fx = e.x0 + dxdy * (start_point - e.y0);
   z.fx -= off_x;
   z.direction = e.invert ? 1.0f : -1.0f;
   z.sy = e.y0;
   z.ey = e.y1;
   z.next = 0;
   return z;
}
void stbtt__handle_clipped_edge(float* scanline, int x, stbtt__active_edge* e, float x0, float y0, float x1, float y1)
{
   if (y0 == y1) return;
   assert(y0 < y1);
   assert(e.sy <= e.ey);
   if (y0 > e.ey) return;
   if (y1 < e.sy) return;
   if (y0 < e.sy) {
      x0 += (x1-x0) * (e.sy - y0) / (y1-y0);
      y0 = e.sy;
   }
   if (y1 > e.ey) {
      x1 += (x1-x0) * (e.ey - y1) / (y1-y0);
      y1 = e.ey;
   }

   if (x0 == x)
      assert(x1 <= x+1);
   else if (x0 == x+1)
      assert(x1 >= x);
   else if (x0 <= x)
      assert(x1 <= x);
   else if (x0 >= x+1)
      assert(x1 >= x+1);
   else
      assert(x1 >= x && x1 <= x+1);

   if (x0 <= x && x1 <= x)
      scanline[x] += e.direction * (y1-y0);
   else if (x0 >= x+1 && x1 >= x+1)
      {}
   else {
      assert(x0 >= x && x0 <= x+1 && x1 >= x && x1 <= x+1);
      scanline[x] += e.direction * (y1-y0) * (1-((x0-x)+(x1-x))/2);
   }
}

float stbtt__sized_trapezoid_area(float height, float top_width, float bottom_width)
{
   assert(top_width >= 0);
   assert(bottom_width >= 0);
   return (top_width + bottom_width) / 2.0f * height;
}

float stbtt__position_trapezoid_area(float height, float tx0, float tx1, float bx0, float bx1)
{
   return stbtt__sized_trapezoid_area(height, tx1 - tx0, bx1 - bx0);
}

float stbtt__sized_triangle_area(float height, float width)
{
   return height * width / 2;
}

void stbtt__fill_active_edges_new(float* scanline, float* scanline_fill, int len, stbtt__active_edge* e, float y_top)
{
   float y_bottom = y_top+1;

   while (e) {



      assert(e.ey >= y_top);

      if (e.fdx == 0) {
         float x0 = e.fx;
         if (x0 < len) {
            if (x0 >= 0) {
               stbtt__handle_clipped_edge(scanline,cast(int) x0,e, x0,y_top, x0,y_bottom);
               stbtt__handle_clipped_edge(scanline_fill-1,cast(int) x0+1,e, x0,y_top, x0,y_bottom);
            } else {
               stbtt__handle_clipped_edge(scanline_fill-1,0,e, x0,y_top, x0,y_bottom);
            }
         }
      } else {
         float x0 = e.fx;
         float dx = e.fdx;
         float xb = x0 + dx;
         float x_top = void, x_bottom = void;
         float sy0 = void, sy1 = void;
         float dy = e.fdy;
         assert(e.sy <= y_bottom && e.ey >= y_top);




         if (e.sy > y_top) {
            x_top = x0 + dx * (e.sy - y_top);
            sy0 = e.sy;
         } else {
            x_top = x0;
            sy0 = y_top;
         }
         if (e.ey < y_bottom) {
            x_bottom = x0 + dx * (e.ey - y_top);
            sy1 = e.ey;
         } else {
            x_bottom = xb;
            sy1 = y_bottom;
         }

         if (x_top >= 0 && x_bottom >= 0 && x_top < len && x_bottom < len) {


            if (cast(int) x_top == cast(int) x_bottom) {
               float height = void;

               int x = cast(int) x_top;
               height = (sy1 - sy0) * e.direction;
               assert(x >= 0 && x < len);
               scanline[x] += stbtt__position_trapezoid_area(height, x_top, x+1.0f, x_bottom, x+1.0f);
               scanline_fill[x] += height;
            } else {
               int x = void, x1 = void, x2 = void;
               float y_crossing = void, y_final = void, step = void, sign = void, area = void;

               if (x_top > x_bottom) {

                  float t = void;
                  sy0 = y_bottom - (sy0 - y_top);
                  sy1 = y_bottom - (sy1 - y_top);
                  t = sy0, sy0 = sy1, sy1 = t;
                  t = x_bottom, x_bottom = x_top, x_top = t;
                  dx = -dx;
                  dy = -dy;
                  t = x0, x0 = xb, xb = t;
               }
               assert(dy >= 0);
               assert(dx >= 0);

               x1 = cast(int) x_top;
               x2 = cast(int) x_bottom;

               y_crossing = y_top + dy * (x1+1 - x0);


               y_final = y_top + dy * (x2 - x0);
               if (y_crossing > y_bottom)
                  y_crossing = y_bottom;

               sign = e.direction;


               area = sign * (y_crossing-sy0);


               scanline[x1] += stbtt__sized_triangle_area(area, x1+1 - x_top);


               if (y_final > y_bottom) {
                  y_final = y_bottom;
                  dy = (y_final - y_crossing ) / (x2 - (x1+1));
               }
               step = sign * dy * 1;



               for (x = x1+1; x < x2; ++x) {
                  scanline[x] += area + step/2;
                  area += step;
               }
               assert(fabs(area) <= 1.01f);
               assert(sy1 > y_final-0.01f);



               scanline[x2] += area + sign * stbtt__position_trapezoid_area(sy1-y_final, cast(float) x2, x2+1.0f, x_bottom, x2+1.0f);


               scanline_fill[x2] += sign * (sy1-sy0);
            }
         } else {







            int x = void;
            for (x=0; x < len; ++x) {
               float y0 = y_top;
               float x1 = cast(float) (x);
               float x2 = cast(float) (x+1);
               float x3 = xb;
               float y3 = y_bottom;




               float y1 = (x - x0) / dx + y_top;
               float y2 = (x+1 - x0) / dx + y_top;

               if (x0 < x1 && x3 > x2) {
                  stbtt__handle_clipped_edge(scanline,x,e, x0,y0, x1,y1);
                  stbtt__handle_clipped_edge(scanline,x,e, x1,y1, x2,y2);
                  stbtt__handle_clipped_edge(scanline,x,e, x2,y2, x3,y3);
               } else if (x3 < x1 && x0 > x2) {
                  stbtt__handle_clipped_edge(scanline,x,e, x0,y0, x2,y2);
                  stbtt__handle_clipped_edge(scanline,x,e, x2,y2, x1,y1);
                  stbtt__handle_clipped_edge(scanline,x,e, x1,y1, x3,y3);
               } else if (x0 < x1 && x3 > x1) {
                  stbtt__handle_clipped_edge(scanline,x,e, x0,y0, x1,y1);
                  stbtt__handle_clipped_edge(scanline,x,e, x1,y1, x3,y3);
               } else if (x3 < x1 && x0 > x1) {
                  stbtt__handle_clipped_edge(scanline,x,e, x0,y0, x1,y1);
                  stbtt__handle_clipped_edge(scanline,x,e, x1,y1, x3,y3);
               } else if (x0 < x2 && x3 > x2) {
                  stbtt__handle_clipped_edge(scanline,x,e, x0,y0, x2,y2);
                  stbtt__handle_clipped_edge(scanline,x,e, x2,y2, x3,y3);
               } else if (x3 < x2 && x0 > x2) {
                  stbtt__handle_clipped_edge(scanline,x,e, x0,y0, x2,y2);
                  stbtt__handle_clipped_edge(scanline,x,e, x2,y2, x3,y3);
               } else {
                  stbtt__handle_clipped_edge(scanline,x,e, x0,y0, x3,y3);
               }
            }
         }
      }
      e = e.next;
   }
}


void stbtt__rasterize_sorted_edges(stbtt__bitmap* result, stbtt__edge* e, int n, int vsubsample, int off_x, int off_y, void* userdata)
{
   stbtt__hheap hh = { 0, 0, 0 };
   stbtt__active_edge* active = null;
   int y = void, j = 0, i = void;
   float[129] scanline_data = void; float* scanline = void, scanline2 = void;

   cast(void)vsubsample.sizeof;

   if (result.w > 64)
      scanline = cast(float*) (cast(void)(userdata),malloc((result.w*2+1) * float.sizeof));
   else
      scanline = scanline_data;

   scanline2 = scanline + result.w;

   y = off_y;
   e[n].y0 = cast(float) (off_y + result.h) + 1;

   while (j < result.h) {

      float scan_y_top = y + 0.0f;
      float scan_y_bottom = y + 1.0f;
      stbtt__active_edge** step = &active;

      memset(scanline , 0, result.w*typeof(scanline[0]).sizeof);
      memset(scanline2, 0, (result.w+1)*typeof(scanline[0]).sizeof);



      while (*step) {
         stbtt__active_edge* z = *step;
         if (z.ey <= scan_y_top) {
            *step = z.next;
            assert(z.direction);
            z.direction = 0;
            stbtt__hheap_free(&hh, z);
         } else {
            step = &((*step).next);
         }
      }


      while (e.y0 <= scan_y_bottom) {
         if (e.y0 != e.y1) {
            stbtt__active_edge* z = stbtt__new_active(&hh, e, off_x, scan_y_top, userdata);
            if (z != null) {
               if (j == 0 && off_y != 0) {
                  if (z.ey < scan_y_top) {

                     z.ey = scan_y_top;
                  }
               }
               assert(z.ey >= scan_y_top);

               z.next = active;
               active = z;
            }
         }
         ++e;
      }


      if (active)
         stbtt__fill_active_edges_new(scanline, scanline2+1, result.w, active, scan_y_top);

      {
         float sum = 0;
         for (i=0; i < result.w; ++i) {
            float k = void;
            int m = void;
            sum += scanline2[i];
            k = scanline[i] + sum;
            k = cast(float) fabs(k)*255 + 0.5f;
            m = cast(int) k;
            if (m > 255) m = 255;
            result.pixels[j*result.stride + i] = cast(ubyte) m;
         }
      }

      step = &active;
      while (*step) {
         stbtt__active_edge* z = *step;
         z.fx += z.fdx;
         step = &((*step).next);
      }

      ++y;
      ++j;
   }

   stbtt__hheap_cleanup(&hh, userdata);

   if (scanline != scanline_data.ptr)
      (cast(void)(userdata),free(scanline));
}






void stbtt__sort_edges_ins_sort(stbtt__edge* p, int n)
{
   int i = void, j = void;
   for (i=1; i < n; ++i) {
      stbtt__edge t = p[i]; stbtt__edge* a = &t;
      j = i;
      while (j > 0) {
         stbtt__edge* b = &p[j-1];
         int c = ((a).y0 < (b).y0);
         if (!c) break;
         p[j] = p[j-1];
         --j;
      }
      if (i != j)
         p[j] = t;
   }
}

void stbtt__sort_edges_quicksort(stbtt__edge* p, int n)
{

   while (n > 12) {
      stbtt__edge t = void;
      int c01 = void, c12 = void, c = void, m = void, i = void, j = void;


      m = n >> 1;
      c01 = ((&p[0]).y0 < (&p[m]).y0);
      c12 = ((&p[m]).y0 < (&p[n-1]).y0);

      if (c01 != c12) {

         int z = void;
         c = ((&p[0]).y0 < (&p[n-1]).y0);


         z = (c == c12) ? 0 : n-1;
         t = p[z];
         p[z] = p[m];
         p[m] = t;
      }


      t = p[0];
      p[0] = p[m];
      p[m] = t;


      i=1;
      j=n-1;
      for(;;) {


         for (;;++i) {
            if (!((&p[i]).y0 < (&p[0]).y0)) break;
         }
         for (;;--j) {
            if (!((&p[0]).y0 < (&p[j]).y0)) break;
         }

         if (i >= j) break;
         t = p[i];
         p[i] = p[j];
         p[j] = t;

         ++i;
         --j;
      }

      if (j < (n-i)) {
         stbtt__sort_edges_quicksort(p,j);
         p = p+i;
         n = n-i;
      } else {
         stbtt__sort_edges_quicksort(p+i, n-i);
         n = j;
      }
   }
}

void stbtt__sort_edges(stbtt__edge* p, int n)
{
   stbtt__sort_edges_quicksort(p, n);
   stbtt__sort_edges_ins_sort(p, n);
}

struct stbtt__point {
   float x = 0, y = 0;
}

void stbtt__rasterize(stbtt__bitmap* result, stbtt__point* pts, int* wcount, int windings, float scale_x, float scale_y, float shift_x, float shift_y, int off_x, int off_y, int invert, void* userdata)
{
   float y_scale_inv = invert ? -scale_y : scale_y;
   stbtt__edge* e = void;
   int n = void, i = void, j = void, k = void, m = void;



   int vsubsample = 1;






   n = 0;
   for (i=0; i < windings; ++i)
      n += wcount[i];

   e = cast(stbtt__edge*) (cast(void)(userdata),malloc(sizeof(*e) * (n+1)));
   if (e == 0) return;
   n = 0;

   m=0;
   for (i=0; i < windings; ++i) {
      stbtt__point* p = pts + m;
      m += wcount[i];
      j = wcount[i]-1;
      for (k=0; k < wcount[i]; j=k++) {
         int a = k, b = j;

         if (p[j].y == p[k].y)
            continue;

         e[n].invert = 0;
         if (invert ? p[j].y > p[k].y : p[j].y < p[k].y) {
            e[n].invert = 1;
            a=j,b=k;
         }
         e[n].x0 = p[a].x * scale_x + shift_x;
         e[n].y0 = (p[a].y * y_scale_inv + shift_y) * vsubsample;
         e[n].x1 = p[b].x * scale_x + shift_x;
         e[n].y1 = (p[b].y * y_scale_inv + shift_y) * vsubsample;
         ++n;
      }
   }



   stbtt__sort_edges(e, n);


   stbtt__rasterize_sorted_edges(result, e, n, vsubsample, off_x, off_y, userdata);

   (cast(void)(userdata),free(e));
}

void stbtt__add_point(stbtt__point* points, int n, float x, float y)
{
   if (!points) return;
   points[n].x = x;
   points[n].y = y;
}


int stbtt__tesselate_curve(stbtt__point* points, int* num_points, float x0, float y0, float x1, float y1, float x2, float y2, float objspace_flatness_squared, int n)
{

   float mx = (x0 + 2*x1 + x2)/4;
   float my = (y0 + 2*y1 + y2)/4;

   float dx = (x0+x2)/2 - mx;
   float dy = (y0+y2)/2 - my;
   if (n > 16)
      return 1;
   if (dx*dx+dy*dy > objspace_flatness_squared) {
      stbtt__tesselate_curve(points, num_points, x0,y0, (x0+x1)/2.0f,(y0+y1)/2.0f, mx,my, objspace_flatness_squared,n+1);
      stbtt__tesselate_curve(points, num_points, mx,my, (x1+x2)/2.0f,(y1+y2)/2.0f, x2,y2, objspace_flatness_squared,n+1);
   } else {
      stbtt__add_point(points, *num_points,x2,y2);
      *num_points = *num_points+1;
   }
   return 1;
}

void stbtt__tesselate_cubic(stbtt__point* points, int* num_points, float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3, float objspace_flatness_squared, int n)
{

   float dx0 = x1-x0;
   float dy0 = y1-y0;
   float dx1 = x2-x1;
   float dy1 = y2-y1;
   float dx2 = x3-x2;
   float dy2 = y3-y2;
   float dx = x3-x0;
   float dy = y3-y0;
   float longlen = cast(float) (sqrt(dx0*dx0+dy0*dy0)+sqrt(dx1*dx1+dy1*dy1)+sqrt(dx2*dx2+dy2*dy2));
   float shortlen = cast(float) sqrt(dx*dx+dy*dy);
   float flatness_squared = longlen*longlen-shortlen*shortlen;

   if (n > 16)
      return;

   if (flatness_squared > objspace_flatness_squared) {
      float x01 = (x0+x1)/2;
      float y01 = (y0+y1)/2;
      float x12 = (x1+x2)/2;
      float y12 = (y1+y2)/2;
      float x23 = (x2+x3)/2;
      float y23 = (y2+y3)/2;

      float xa = (x01+x12)/2;
      float ya = (y01+y12)/2;
      float xb = (x12+x23)/2;
      float yb = (y12+y23)/2;

      float mx = (xa+xb)/2;
      float my = (ya+yb)/2;

      stbtt__tesselate_cubic(points, num_points, x0,y0, x01,y01, xa,ya, mx,my, objspace_flatness_squared,n+1);
      stbtt__tesselate_cubic(points, num_points, mx,my, xb,yb, x23,y23, x3,y3, objspace_flatness_squared,n+1);
   } else {
      stbtt__add_point(points, *num_points,x3,y3);
      *num_points = *num_points+1;
   }
}


stbtt__point* stbtt_FlattenCurves(stbtt_vertex* vertices, int num_verts, float objspace_flatness, int** contour_lengths, int* num_contours, void* userdata)
{
   stbtt__point* points = null;
   int num_points = 0;

   float objspace_flatness_squared = objspace_flatness * objspace_flatness;
   int i = void, n = 0, start = 0, pass = void;


   for (i=0; i < num_verts; ++i)
      if (vertices[i].type == STBTT_vmove)
         ++n;

   *num_contours = n;
   if (n == 0) return 0;

   *contour_lengths = cast(int*) (cast(void)(userdata),malloc(sizeof(**contour_lengths) * n));

   if (*contour_lengths == 0) {
      *num_contours = 0;
      return 0;
   }


   for (pass=0; pass < 2; ++pass) {
      float x = 0, y = 0;
      if (pass == 1) {
         points = cast(stbtt__point*) (cast(void)(userdata),malloc(num_points * typeof(points[0]).sizeof));
         if (points == null) goto error;
      }
      num_points = 0;
      n= -1;
      for (i=0; i < num_verts; ++i) {
         switch (vertices[i].type) {
            case STBTT_vmove:

               if (n >= 0)
                  (*contour_lengths)[n] = num_points - start;
               ++n;
               start = num_points;

               x = vertices[i].x, y = vertices[i].y;
               stbtt__add_point(points, num_points++, x,y);
               break;
            case STBTT_vline:
               x = vertices[i].x, y = vertices[i].y;
               stbtt__add_point(points, num_points++, x, y);
               break;
            case STBTT_vcurve:
               stbtt__tesselate_curve(points, &num_points, x,y,
                                        vertices[i].cx, vertices[i].cy,
                                        vertices[i].x, vertices[i].y,
                                        objspace_flatness_squared, 0);
               x = vertices[i].x, y = vertices[i].y;
               break;
            case STBTT_vcubic:
               stbtt__tesselate_cubic(points, &num_points, x,y,
                                        vertices[i].cx, vertices[i].cy,
                                        vertices[i].cx1, vertices[i].cy1,
                                        vertices[i].x, vertices[i].y,
                                        objspace_flatness_squared, 0);
               x = vertices[i].x, y = vertices[i].y;
               break;
         default: break;}
      }
      (*contour_lengths)[n] = num_points - start;
   }

   return points;
error:
   (cast(void)(userdata),free(points));
   (cast(void)(userdata),free(*contour_lengths));
   *contour_lengths = 0;
   *num_contours = 0;
   return null;
}

void stbtt_Rasterize(stbtt__bitmap* result, float flatness_in_pixels, stbtt_vertex* vertices, int num_verts, float scale_x, float scale_y, float shift_x, float shift_y, int x_off, int y_off, int invert, void* userdata)
{
   float scale = scale_x > scale_y ? scale_y : scale_x;
   int winding_count = 0;
   int* winding_lengths = null;
   stbtt__point* windings = stbtt_FlattenCurves(vertices, num_verts, flatness_in_pixels / scale, &winding_lengths, &winding_count, userdata);
   if (windings) {
      stbtt__rasterize(result, windings, winding_lengths, winding_count, scale_x, scale_y, shift_x, shift_y, x_off, y_off, invert, userdata);
      (cast(void)(userdata),free(winding_lengths));
      (cast(void)(userdata),free(windings));
   }
}

void stbtt_FreeBitmap(ubyte* bitmap, void* userdata)
{
   (cast(void)(userdata),free(bitmap));
}

ubyte* stbtt_GetGlyphBitmapSubpixel(const(stbtt_fontinfo)* info, float scale_x, float scale_y, float shift_x, float shift_y, int glyph, int* width, int* height, int* xoff, int* yoff)
{
   int ix0 = void, iy0 = void, ix1 = void, iy1 = void;
   stbtt__bitmap gbm = void;
   stbtt_vertex* vertices = void;
   int num_verts = stbtt_GetGlyphShape(info, glyph, &vertices);

   if (scale_x == 0) scale_x = scale_y;
   if (scale_y == 0) {
      if (scale_x == 0) {
         (cast(void)(info.userdata),free(vertices));
         return null;
      }
      scale_y = scale_x;
   }

   stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y, &ix0,&iy0,&ix1,&iy1);


   gbm.w = (ix1 - ix0);
   gbm.h = (iy1 - iy0);
   gbm.pixels = null;

   if (width ) *width = gbm.w;
   if (height) *height = gbm.h;
   if (xoff ) *xoff = ix0;
   if (yoff ) *yoff = iy0;

   if (gbm.w && gbm.h) {
      gbm.pixels = cast(ubyte*) (cast(void)(info.userdata),malloc(gbm.w * gbm.h));
      if (gbm.pixels) {
         gbm.stride = gbm.w;

         stbtt_Rasterize(&gbm, 0.35f, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0, iy0, 1, info.userdata);
      }
   }
   (cast(void)(info.userdata),free(vertices));
   return gbm.pixels;
}

ubyte* stbtt_GetGlyphBitmap(const(stbtt_fontinfo)* info, float scale_x, float scale_y, int glyph, int* width, int* height, int* xoff, int* yoff)
{
   return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y, 0.0f, 0.0f, glyph, width, height, xoff, yoff);
}

void stbtt_MakeGlyphBitmapSubpixel(const(stbtt_fontinfo)* info, ubyte* output, int out_w, int out_h, int out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int glyph)
{
   int ix0 = void, iy0 = void;
   stbtt_vertex* vertices = void;
   int num_verts = stbtt_GetGlyphShape(info, glyph, &vertices);
   stbtt__bitmap gbm = void;

   stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale_x, scale_y, shift_x, shift_y, &ix0,&iy0,0,0);
   gbm.pixels = output;
   gbm.w = out_w;
   gbm.h = out_h;
   gbm.stride = out_stride;

   if (gbm.w && gbm.h)
      stbtt_Rasterize(&gbm, 0.35f, vertices, num_verts, scale_x, scale_y, shift_x, shift_y, ix0,iy0, 1, info.userdata);

   (cast(void)(info.userdata),free(vertices));
}

void stbtt_MakeGlyphBitmap(const(stbtt_fontinfo)* info, ubyte* output, int out_w, int out_h, int out_stride, float scale_x, float scale_y, int glyph)
{
   stbtt_MakeGlyphBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, 0.0f,0.0f, glyph);
}

ubyte* stbtt_GetCodepointBitmapSubpixel(const(stbtt_fontinfo)* info, float scale_x, float scale_y, float shift_x, float shift_y, int codepoint, int* width, int* height, int* xoff, int* yoff)
{
   return stbtt_GetGlyphBitmapSubpixel(info, scale_x, scale_y,shift_x,shift_y, stbtt_FindGlyphIndex(info,codepoint), width,height,xoff,yoff);
}

void stbtt_MakeCodepointBitmapSubpixelPrefilter(const(stbtt_fontinfo)* info, ubyte* output, int out_w, int out_h, int out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int oversample_x, int oversample_y, float* sub_x, float* sub_y, int codepoint)
{
   stbtt_MakeGlyphBitmapSubpixelPrefilter(info, output, out_w, out_h, out_stride, scale_x, scale_y, shift_x, shift_y, oversample_x, oversample_y, sub_x, sub_y, stbtt_FindGlyphIndex(info,codepoint));
}

void stbtt_MakeCodepointBitmapSubpixel(const(stbtt_fontinfo)* info, ubyte* output, int out_w, int out_h, int out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int codepoint)
{
   stbtt_MakeGlyphBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, shift_x, shift_y, stbtt_FindGlyphIndex(info,codepoint));
}

ubyte* stbtt_GetCodepointBitmap(const(stbtt_fontinfo)* info, float scale_x, float scale_y, int codepoint, int* width, int* height, int* xoff, int* yoff)
{
   return stbtt_GetCodepointBitmapSubpixel(info, scale_x, scale_y, 0.0f,0.0f, codepoint, width,height,xoff,yoff);
}

void stbtt_MakeCodepointBitmap(const(stbtt_fontinfo)* info, ubyte* output, int out_w, int out_h, int out_stride, float scale_x, float scale_y, int codepoint)
{
   stbtt_MakeCodepointBitmapSubpixel(info, output, out_w, out_h, out_stride, scale_x, scale_y, 0.0f,0.0f, codepoint);
}







int stbtt_BakeFontBitmap_internal(ubyte* data, int offset, float pixel_height, ubyte* pixels, int pw, int ph, int first_char, int num_chars, stbtt_bakedchar* chardata)
{
   float scale = void;
   int x = void, y = void, bottom_y = void, i = void;
   stbtt_fontinfo f = void;
   f.userdata = null;
   if (!stbtt_InitFont(&f, data, offset))
      return -1;
   memset(pixels, 0, pw*ph);
   x=y=1;
   bottom_y = 1;

   scale = stbtt_ScaleForPixelHeight(&f, pixel_height);

   for (i=0; i < num_chars; ++i) {
      int advance = void, lsb = void, x0 = void, y0 = void, x1 = void, y1 = void, gw = void, gh = void;
      int g = stbtt_FindGlyphIndex(&f, first_char + i);
      stbtt_GetGlyphHMetrics(&f, g, &advance, &lsb);
      stbtt_GetGlyphBitmapBox(&f, g, scale,scale, &x0,&y0,&x1,&y1);
      gw = x1-x0;
      gh = y1-y0;
      if (x + gw + 1 >= pw)
         y = bottom_y, x = 1;
      if (y + gh + 1 >= ph)
         return -i;
      assert(x+gw < pw);
      assert(y+gh < ph);
      stbtt_MakeGlyphBitmap(&f, pixels+x+y*pw, gw,gh,pw, scale,scale, g);
      chardata[i].x0 = cast(stbtt_int16) x;
      chardata[i].y0 = cast(stbtt_int16) y;
      chardata[i].x1 = cast(stbtt_int16) (x + gw);
      chardata[i].y1 = cast(stbtt_int16) (y + gh);
      chardata[i].xadvance = scale * advance;
      chardata[i].xoff = cast(float) x0;
      chardata[i].yoff = cast(float) y0;
      x = x + gw + 1;
      if (y+gh+1 > bottom_y)
         bottom_y = y+gh+1;
   }
   return bottom_y;
}

void stbtt_GetBakedQuad(const(stbtt_bakedchar)* chardata, int pw, int ph, int char_index, float* xpos, float* ypos, stbtt_aligned_quad* q, int opengl_fillrule)
{
   float d3d_bias = opengl_fillrule ? 0 : -0.5f;
   float ipw = 1.0f / pw, iph = 1.0f / ph;
   const(stbtt_bakedchar)* b = chardata + char_index;
   int round_x = (cast(int) floor((*xpos + b.xoff) + 0.5f));
   int round_y = (cast(int) floor((*ypos + b.yoff) + 0.5f));

   q.x0 = round_x + d3d_bias;
   q.y0 = round_y + d3d_bias;
   q.x1 = round_x + b.x1 - b.x0 + d3d_bias;
   q.y1 = round_y + b.y1 - b.y0 + d3d_bias;

   q.s0 = b.x0 * ipw;
   q.t0 = b.y0 * iph;
   q.s1 = b.x1 * ipw;
   q.t1 = b.y1 * iph;

   *xpos += b.xadvance;
}
alias stbrp_coord = int;
struct stbrp_context {
   int width, height;
   int x, y, bottom_y;
}

struct stbrp_node {
   ubyte x;
}

void stbrp_init_target(stbrp_context* con, int pw, int ph, stbrp_node* nodes, int num_nodes)
{
   con.width = pw;
   con.height = ph;
   con.x = 0;
   con.y = 0;
   con.bottom_y = 0;
   cast(void)nodes.sizeof;
   cast(void)num_nodes.sizeof;
}

void stbrp_pack_rects(stbrp_context* con, stbrp_rect* rects, int num_rects)
{
   int i = void;
   for (i=0; i < num_rects; ++i) {
      if (con.x + rects[i].w > con.width) {
         con.x = 0;
         con.y = con.bottom_y;
      }
      if (con.y + rects[i].h > con.height)
         break;
      rects[i].x = con.x;
      rects[i].y = con.y;
      rects[i].was_packed = 1;
      con.x += rects[i].w;
      if (con.y + rects[i].h > con.bottom_y)
         con.bottom_y = con.y + rects[i].h;
   }
   for ( ; i < num_rects; ++i)
      rects[i].was_packed = 0;
}
int stbtt_PackBegin(stbtt_pack_context* spc, ubyte* pixels, int pw, int ph, int stride_in_bytes, int padding, void* alloc_context)
{
   stbrp_context* context = cast(stbrp_context*) (cast(void)(alloc_context),malloc(typeof(*context).sizeof));
   int num_nodes = pw - padding;
   stbrp_node* nodes = cast(stbrp_node*) (cast(void)(alloc_context),malloc(sizeof(*nodes ) * num_nodes));

   if (context == null || nodes == null) {
      if (context != null) (cast(void)(alloc_context),free(context));
      if (nodes != null) (cast(void)(alloc_context),free(nodes));
      return 0;
   }

   spc.user_allocator_context = alloc_context;
   spc.width = pw;
   spc.height = ph;
   spc.pixels = pixels;
   spc.pack_info = context;
   spc.nodes = nodes;
   spc.padding = padding;
   spc.stride_in_bytes = stride_in_bytes != 0 ? stride_in_bytes : pw;
   spc.h_oversample = 1;
   spc.v_oversample = 1;
   spc.skip_missing = 0;

   stbrp_init_target(context, pw-padding, ph-padding, nodes, num_nodes);

   if (pixels)
      memset(pixels, 0, pw*ph);

   return 1;
}

void stbtt_PackEnd(stbtt_pack_context* spc)
{
   (cast(void)(spc.user_allocator_context),free(spc.nodes));
   (cast(void)(spc.user_allocator_context),free(spc.pack_info));
}

void stbtt_PackSetOversampling(stbtt_pack_context* spc, uint h_oversample, uint v_oversample)
{
   assert(h_oversample <= 8);
   assert(v_oversample <= 8);
   if (h_oversample <= 8)
      spc.h_oversample = h_oversample;
   if (v_oversample <= 8)
      spc.v_oversample = v_oversample;
}

void stbtt_PackSetSkipMissingCodepoints(stbtt_pack_context* spc, int skip)
{
   spc.skip_missing = skip;
}



void stbtt__h_prefilter(ubyte* pixels, int w, int h, int stride_in_bytes, uint kernel_width)
{
   ubyte[8] buffer = void;
   int safe_w = w - kernel_width;
   int j = void;
   memset(buffer.ptr, 0, 8);
   for (j=0; j < h; ++j) {
      int i = void;
      uint total = void;
      memset(buffer.ptr, 0, kernel_width);

      total = 0;


      switch (kernel_width) {
         case 2:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i];
               pixels[i] = cast(ubyte) (total / 2);
            }
            break;
         case 3:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i];
               pixels[i] = cast(ubyte) (total / 3);
            }
            break;
         case 4:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i];
               pixels[i] = cast(ubyte) (total / 4);
            }
            break;
         case 5:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i];
               pixels[i] = cast(ubyte) (total / 5);
            }
            break;
         default:
            for (i=0; i <= safe_w; ++i) {
               total += pixels[i] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i];
               pixels[i] = cast(ubyte) (total / kernel_width);
            }
            break;
      }

      for (; i < w; ++i) {
         assert(pixels[i] == 0);
         total -= buffer[i & (8 -1)];
         pixels[i] = cast(ubyte) (total / kernel_width);
      }

      pixels += stride_in_bytes;
   }
}

void stbtt__v_prefilter(ubyte* pixels, int w, int h, int stride_in_bytes, uint kernel_width)
{
   ubyte[8] buffer = void;
   int safe_h = h - kernel_width;
   int j = void;
   memset(buffer.ptr, 0, 8);
   for (j=0; j < w; ++j) {
      int i = void;
      uint total = void;
      memset(buffer.ptr, 0, kernel_width);

      total = 0;


      switch (kernel_width) {
         case 2:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = cast(ubyte) (total / 2);
            }
            break;
         case 3:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = cast(ubyte) (total / 3);
            }
            break;
         case 4:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = cast(ubyte) (total / 4);
            }
            break;
         case 5:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = cast(ubyte) (total / 5);
            }
            break;
         default:
            for (i=0; i <= safe_h; ++i) {
               total += pixels[i*stride_in_bytes] - buffer[i & (8 -1)];
               buffer[(i+kernel_width) & (8 -1)] = pixels[i*stride_in_bytes];
               pixels[i*stride_in_bytes] = cast(ubyte) (total / kernel_width);
            }
            break;
      }

      for (; i < h; ++i) {
         assert(pixels[i*stride_in_bytes] == 0);
         total -= buffer[i & (8 -1)];
         pixels[i*stride_in_bytes] = cast(ubyte) (total / kernel_width);
      }

      pixels += cast(ubyte*) 1;
   }
}

float stbtt__oversample_shift(int oversample)
{
   if (!oversample)
      return 0.0f;





   return cast(float)-(oversample - 1) / (2.0f * cast(float)oversample);
}


int stbtt_PackFontRangesGatherRects(stbtt_pack_context* spc, const(stbtt_fontinfo)* info, stbtt_pack_range* ranges, int num_ranges, stbrp_rect* rects)
{
   int i = void, j = void, k = void;
   int missing_glyph_added = 0;

   k=0;
   for (i=0; i < num_ranges; ++i) {
      float fh = ranges[i].font_size;
      float scale = fh > 0 ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
      ranges[i].h_oversample = cast(ubyte) spc.h_oversample;
      ranges[i].v_oversample = cast(ubyte) spc.v_oversample;
      for (j=0; j < ranges[i].num_chars; ++j) {
         int x0 = void, y0 = void, x1 = void, y1 = void;
         int codepoint = ranges[i].array_of_unicode_codepoints == null ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
         int glyph = stbtt_FindGlyphIndex(info, codepoint);
         if (glyph == 0 && (spc.skip_missing || missing_glyph_added)) {
            rects[k].w = rects[k].h = 0;
         } else {
            stbtt_GetGlyphBitmapBoxSubpixel(info,glyph,
                                            scale * spc.h_oversample,
                                            scale * spc.v_oversample,
                                            0,0,
                                            &x0,&y0,&x1,&y1);
            rects[k].w = cast(stbrp_coord) (x1-x0 + spc.padding + spc.h_oversample-1);
            rects[k].h = cast(stbrp_coord) (y1-y0 + spc.padding + spc.v_oversample-1);
            if (glyph == 0)
               missing_glyph_added = 1;
         }
         ++k;
      }
   }

   return k;
}

void stbtt_MakeGlyphBitmapSubpixelPrefilter(const(stbtt_fontinfo)* info, ubyte* output, int out_w, int out_h, int out_stride, float scale_x, float scale_y, float shift_x, float shift_y, int prefilter_x, int prefilter_y, float* sub_x, float* sub_y, int glyph)
{
   stbtt_MakeGlyphBitmapSubpixel(info,
                                 output,
                                 out_w - (prefilter_x - 1),
                                 out_h - (prefilter_y - 1),
                                 out_stride,
                                 scale_x,
                                 scale_y,
                                 shift_x,
                                 shift_y,
                                 glyph);

   if (prefilter_x > 1)
      stbtt__h_prefilter(output, out_w, out_h, out_stride, prefilter_x);

   if (prefilter_y > 1)
      stbtt__v_prefilter(output, out_w, out_h, out_stride, prefilter_y);

   *sub_x = stbtt__oversample_shift(prefilter_x);
   *sub_y = stbtt__oversample_shift(prefilter_y);
}


int stbtt_PackFontRangesRenderIntoRects(stbtt_pack_context* spc, const(stbtt_fontinfo)* info, stbtt_pack_range* ranges, int num_ranges, stbrp_rect* rects)
{
   int i = void, j = void, k = void, missing_glyph = -1, return_value = 1;


   int old_h_over = spc.h_oversample;
   int old_v_over = spc.v_oversample;

   k = 0;
   for (i=0; i < num_ranges; ++i) {
      float fh = ranges[i].font_size;
      float scale = fh > 0 ? stbtt_ScaleForPixelHeight(info, fh) : stbtt_ScaleForMappingEmToPixels(info, -fh);
      float recip_h = void, recip_v = void, sub_x = void, sub_y = void;
      spc.h_oversample = ranges[i].h_oversample;
      spc.v_oversample = ranges[i].v_oversample;
      recip_h = 1.0f / spc.h_oversample;
      recip_v = 1.0f / spc.v_oversample;
      sub_x = stbtt__oversample_shift(spc.h_oversample);
      sub_y = stbtt__oversample_shift(spc.v_oversample);
      for (j=0; j < ranges[i].num_chars; ++j) {
         stbrp_rect* r = &rects[k];
         if (r.was_packed && r.w != 0 && r.h != 0) {
            stbtt_packedchar* bc = &ranges[i].chardata_for_range[j];
            int advance = void, lsb = void, x0 = void, y0 = void, x1 = void, y1 = void;
            int codepoint = ranges[i].array_of_unicode_codepoints == null ? ranges[i].first_unicode_codepoint_in_range + j : ranges[i].array_of_unicode_codepoints[j];
            int glyph = stbtt_FindGlyphIndex(info, codepoint);
            stbrp_coord pad = cast(stbrp_coord) spc.padding;


            r.x += pad;
            r.y += pad;
            r.w -= pad;
            r.h -= pad;
            stbtt_GetGlyphHMetrics(info, glyph, &advance, &lsb);
            stbtt_GetGlyphBitmapBox(info, glyph,
                                    scale * spc.h_oversample,
                                    scale * spc.v_oversample,
                                    &x0,&y0,&x1,&y1);
            stbtt_MakeGlyphBitmapSubpixel(info,
                                          spc.pixels + r.x + r.y*spc.stride_in_bytes,
                                          r.w - spc.h_oversample+1,
                                          r.h - spc.v_oversample+1,
                                          spc.stride_in_bytes,
                                          scale * spc.h_oversample,
                                          scale * spc.v_oversample,
                                          0,0,
                                          glyph);

            if (spc.h_oversample > 1)
               stbtt__h_prefilter(spc.pixels + r.x + r.y*spc.stride_in_bytes,
                                  r.w, r.h, spc.stride_in_bytes,
                                  spc.h_oversample);

            if (spc.v_oversample > 1)
               stbtt__v_prefilter(spc.pixels + r.x + r.y*spc.stride_in_bytes,
                                  r.w, r.h, spc.stride_in_bytes,
                                  spc.v_oversample);

            bc.x0 = cast(stbtt_int16) r.x;
            bc.y0 = cast(stbtt_int16) r.y;
            bc.x1 = cast(stbtt_int16) (r.x + r.w);
            bc.y1 = cast(stbtt_int16) (r.y + r.h);
            bc.xadvance = scale * advance;
            bc.xoff = cast(float) x0 * recip_h + sub_x;
            bc.yoff = cast(float) y0 * recip_v + sub_y;
            bc.xoff2 = (x0 + r.w) * recip_h + sub_x;
            bc.yoff2 = (y0 + r.h) * recip_v + sub_y;

            if (glyph == 0)
               missing_glyph = j;
         } else if (spc.skip_missing) {
            return_value = 0;
         } else if (r.was_packed && r.w == 0 && r.h == 0 && missing_glyph >= 0) {
            ranges[i].chardata_for_range[j] = ranges[i].chardata_for_range[missing_glyph];
         } else {
            return_value = 0;
         }

         ++k;
      }
   }


   spc.h_oversample = old_h_over;
   spc.v_oversample = old_v_over;

   return return_value;
}

void stbtt_PackFontRangesPackRects(stbtt_pack_context* spc, stbrp_rect* rects, int num_rects)
{
   stbrp_pack_rects(cast(stbrp_context*) spc.pack_info, rects, num_rects);
}

int stbtt_PackFontRanges(stbtt_pack_context* spc, const(ubyte)* fontdata, int font_index, stbtt_pack_range* ranges, int num_ranges)
{
   stbtt_fontinfo info = void;
   int i = void, j = void, n = void, return_value = 1;

   stbrp_rect* rects = void;


   for (i=0; i < num_ranges; ++i)
      for (j=0; j < ranges[i].num_chars; ++j)
         ranges[i].chardata_for_range[j].x0 =
         ranges[i].chardata_for_range[j].y0 =
         ranges[i].chardata_for_range[j].x1 =
         ranges[i].chardata_for_range[j].y1 = 0;

   n = 0;
   for (i=0; i < num_ranges; ++i)
      n += ranges[i].num_chars;

   rects = cast(stbrp_rect*) (cast(void)(spc.user_allocator_context),malloc(sizeof(*rects) * n));
   if (rects == null)
      return 0;

   info.userdata = spc.user_allocator_context;
   stbtt_InitFont(&info, fontdata, stbtt_GetFontOffsetForIndex(fontdata,font_index));

   n = stbtt_PackFontRangesGatherRects(spc, &info, ranges, num_ranges, rects);

   stbtt_PackFontRangesPackRects(spc, rects, n);

   return_value = stbtt_PackFontRangesRenderIntoRects(spc, &info, ranges, num_ranges, rects);

   (cast(void)(spc.user_allocator_context),free(rects));
   return return_value;
}

int stbtt_PackFontRange(stbtt_pack_context* spc, const(ubyte)* fontdata, int font_index, float font_size, int first_unicode_codepoint_in_range, int num_chars_in_range, stbtt_packedchar* chardata_for_range)
{
   stbtt_pack_range range = void;
   range.first_unicode_codepoint_in_range = first_unicode_codepoint_in_range;
   range.array_of_unicode_codepoints = null;
   range.num_chars = num_chars_in_range;
   range.chardata_for_range = chardata_for_range;
   range.font_size = font_size;
   return stbtt_PackFontRanges(spc, fontdata, font_index, &range, 1);
}

void stbtt_GetScaledFontVMetrics(const(ubyte)* fontdata, int index, float size, float* ascent, float* descent, float* lineGap)
{
   int i_ascent = void, i_descent = void, i_lineGap = void;
   float scale = void;
   stbtt_fontinfo info = void;
   stbtt_InitFont(&info, fontdata, stbtt_GetFontOffsetForIndex(fontdata, index));
   scale = size > 0 ? stbtt_ScaleForPixelHeight(&info, size) : stbtt_ScaleForMappingEmToPixels(&info, -size);
   stbtt_GetFontVMetrics(&info, &i_ascent, &i_descent, &i_lineGap);
   *ascent = cast(float) i_ascent * scale;
   *descent = cast(float) i_descent * scale;
   *lineGap = cast(float) i_lineGap * scale;
}

void stbtt_GetPackedQuad(const(stbtt_packedchar)* chardata, int pw, int ph, int char_index, float* xpos, float* ypos, stbtt_aligned_quad* q, int align_to_integer)
{
   float ipw = 1.0f / pw, iph = 1.0f / ph;
   const(stbtt_packedchar)* b = chardata + char_index;

   if (align_to_integer) {
      float x = cast(float) (cast(int) floor((*xpos + b.xoff) + 0.5f));
      float y = cast(float) (cast(int) floor((*ypos + b.yoff) + 0.5f));
      q.x0 = x;
      q.y0 = y;
      q.x1 = x + b.xoff2 - b.xoff;
      q.y1 = y + b.yoff2 - b.yoff;
   } else {
      q.x0 = *xpos + b.xoff;
      q.y0 = *ypos + b.yoff;
      q.x1 = *xpos + b.xoff2;
      q.y1 = *ypos + b.yoff2;
   }

   q.s0 = b.x0 * ipw;
   q.t0 = b.y0 * iph;
   q.s1 = b.x1 * ipw;
   q.t1 = b.y1 * iph;

   *xpos += b.xadvance;
}

int stbtt__ray_intersect_bezier(float* orig, float* ray, float* q0, float* q1, float* q2, float[2]* hits)
{
   float q0perp = q0[1]*ray[0] - q0[0]*ray[1];
   float q1perp = q1[1]*ray[0] - q1[0]*ray[1];
   float q2perp = q2[1]*ray[0] - q2[0]*ray[1];
   float roperp = orig[1]*ray[0] - orig[0]*ray[1];

   float a = q0perp - 2*q1perp + q2perp;
   float b = q1perp - q0perp;
   float c = q0perp - roperp;

   float s0 = 0., s1 = 0.;
   int num_s = 0;

   if (a != 0.0) {
      float discr = b*b - a*c;
      if (discr > 0.0) {
         float rcpna = -1 / a;
         float d = cast(float) sqrt(discr);
         s0 = (b+d) * rcpna;
         s1 = (b-d) * rcpna;
         if (s0 >= 0.0 && s0 <= 1.0)
            num_s = 1;
         if (d > 0.0 && s1 >= 0.0 && s1 <= 1.0) {
            if (num_s == 0) s0 = s1;
            ++num_s;
         }
      }
   } else {


      s0 = c / (-2 * b);
      if (s0 >= 0.0 && s0 <= 1.0)
         num_s = 1;
   }

   if (num_s == 0)
      return 0;
   else {
      float rcp_len2 = 1 / (ray[0]*ray[0] + ray[1]*ray[1]);
      float rayn_x = ray[0] * rcp_len2, rayn_y = ray[1] * rcp_len2;

      float q0d = q0[0]*rayn_x + q0[1]*rayn_y;
      float q1d = q1[0]*rayn_x + q1[1]*rayn_y;
      float q2d = q2[0]*rayn_x + q2[1]*rayn_y;
      float rod = orig[0]*rayn_x + orig[1]*rayn_y;

      float q10d = q1d - q0d;
      float q20d = q2d - q0d;
      float q0rd = q0d - rod;

      hits[0][0] = q0rd + s0*(2.0f - 2.0f*s0)*q10d + s0*s0*q20d;
      hits[0][1] = a*s0+b;

      if (num_s > 1) {
         hits[1][0] = q0rd + s1*(2.0f - 2.0f*s1)*q10d + s1*s1*q20d;
         hits[1][1] = a*s1+b;
         return 2;
      } else {
         return 1;
      }
   }
}

int equal(float* a, float* b)
{
   return (a[0] == b[0] && a[1] == b[1]);
}

int stbtt__compute_crossings_x(float x, float y, int nverts, stbtt_vertex* verts)
{
   int i = void;
   float[2] orig = void, ray = [ 1, 0 ];
   float y_frac = void;
   int winding = 0;


   y_frac = cast(float) fmod(y,1.0f);
   if (y_frac < 0.01f)
      y += 0.01f;
   else if (y_frac > 0.99f)
      y -= 0.01f;

   orig[0] = x;
   orig[1] = y;


   for (i=0; i < nverts; ++i) {
      if (verts[i].type == STBTT_vline) {
         int x0 = cast(int) verts[i-1].x, y0 = cast(int) verts[i-1].y;
         int x1 = cast(int) verts[i ].x, y1 = cast(int) verts[i ].y;
         if (y > ((y0) < (y1) ? (y0) : (y1)) && y < ((y0) < (y1) ? (y1) : (y0)) && x > ((x0) < (x1) ? (x0) : (x1))) {
            float x_inter = (y - y0) / (y1 - y0) * (x1-x0) + x0;
            if (x_inter < x)
               winding += (y0 < y1) ? 1 : -1;
         }
      }
      if (verts[i].type == STBTT_vcurve) {
         int x0 = cast(int) verts[i-1].x, y0 = cast(int) verts[i-1].y;
         int x1 = cast(int) verts[i ].cx, y1 = cast(int) verts[i ].cy;
         int x2 = cast(int) verts[i ].x, y2 = cast(int) verts[i ].y;
         int ax = ((x0) < (((x1) < (x2) ? (x1) : (x2))) ? (x0) : (((x1) < (x2) ? (x1) : (x2)))), ay = ((y0) < (((y1) < (y2) ? (y1) : (y2))) ? (y0) : (((y1) < (y2) ? (y1) : (y2))));
         int by = ((y0) < (((y1) < (y2) ? (y2) : (y1))) ? (((y1) < (y2) ? (y2) : (y1))) : (y0));
         if (y > ay && y < by && x > ax) {
            float[2] q0 = void, q1 = void, q2 = void;
            float[2][2] hits = void;
            q0[0] = cast(float)x0;
            q0[1] = cast(float)y0;
            q1[0] = cast(float)x1;
            q1[1] = cast(float)y1;
            q2[0] = cast(float)x2;
            q2[1] = cast(float)y2;
            if (equal(q0.ptr,q1.ptr) || equal(q1.ptr,q2.ptr)) {
               x0 = cast(int)verts[i-1].x;
               y0 = cast(int)verts[i-1].y;
               x1 = cast(int)verts[i ].x;
               y1 = cast(int)verts[i ].y;
               if (y > ((y0) < (y1) ? (y0) : (y1)) && y < ((y0) < (y1) ? (y1) : (y0)) && x > ((x0) < (x1) ? (x0) : (x1))) {
                  float x_inter = (y - y0) / (y1 - y0) * (x1-x0) + x0;
                  if (x_inter < x)
                     winding += (y0 < y1) ? 1 : -1;
               }
            } else {
               int num_hits = stbtt__ray_intersect_bezier(orig.ptr, ray.ptr, q0.ptr, q1.ptr, q2.ptr, hits.ptr);
               if (num_hits >= 1)
                  if (hits[0][0] < 0)
                     winding += (hits[0][1] < 0 ? -1 : 1);
               if (num_hits >= 2)
                  if (hits[1][0] < 0)
                     winding += (hits[1][1] < 0 ? -1 : 1);
            }
         }
      }
   }
   return winding;
}

float stbtt__cuberoot(float x)
{
   if (x<0)
      return -cast(float) pow(-x,1.0f/3.0f);
   else
      return cast(float) pow(x,1.0f/3.0f);
}


int stbtt__solve_cubic(float a, float b, float c, float* r)
{
   float s = -a / 3;
   float p = b - a*a / 3;
   float q = a * (2*a*a - 9*b) / 27 + c;
   float p3 = p*p*p;
   float d = q*q + 4*p3 / 27;
   if (d >= 0) {
      float z = cast(float) sqrt(d);
      float u = (-q + z) / 2;
      float v = (-q - z) / 2;
      u = stbtt__cuberoot(u);
      v = stbtt__cuberoot(v);
      r[0] = s + u + v;
      return 1;
   } else {
      float u = cast(float) sqrt(-p/3);
      float v = cast(float) acos(-sqrt(-27/p3) * q / 2) / 3;
      float m = cast(float) cos(v);
      float n = cast(float) cos(v-3.141592/2)*1.732050808f;
      r[0] = s + u * 2 * m;
      r[1] = s - u * (m + n);
      r[2] = s - u * (m - n);




      return 3;
   }
}

ubyte* stbtt_GetGlyphSDF(const(stbtt_fontinfo)* info, float scale, int glyph, int padding, ubyte onedge_value, float pixel_dist_scale, int* width, int* height, int* xoff, int* yoff)
{
   float scale_x = scale, scale_y = scale;
   int ix0 = void, iy0 = void, ix1 = void, iy1 = void;
   int w = void, h = void;
   ubyte* data = void;

   if (scale == 0) return null;

   stbtt_GetGlyphBitmapBoxSubpixel(info, glyph, scale, scale, 0.0f,0.0f, &ix0,&iy0,&ix1,&iy1);


   if (ix0 == ix1 || iy0 == iy1)
      return null;

   ix0 -= padding;
   iy0 -= padding;
   ix1 += padding;
   iy1 += padding;

   w = (ix1 - ix0);
   h = (iy1 - iy0);

   if (width ) *width = w;
   if (height) *height = h;
   if (xoff ) *xoff = ix0;
   if (yoff ) *yoff = iy0;


   scale_y = -scale_y;

   {
      int x = void, y = void, i = void, j = void;
      float* precompute = void;
      stbtt_vertex* verts = void;
      int num_verts = stbtt_GetGlyphShape(info, glyph, &verts);
      data = cast(ubyte*) (cast(void)(info.userdata),malloc(w * h));
      precompute = cast(float*) (cast(void)(info.userdata),malloc(num_verts * float.sizeof));

      for (i=0,j=num_verts-1; i < num_verts; j=i++) {
         if (verts[i].type == STBTT_vline) {
            float x0 = verts[i].x*scale_x, y0 = verts[i].y*scale_y;
            float x1 = verts[j].x*scale_x, y1 = verts[j].y*scale_y;
            float dist = cast(float) sqrt((x1-x0)*(x1-x0) + (y1-y0)*(y1-y0));
            precompute[i] = (dist == 0) ? 0.0f : 1.0f / dist;
         } else if (verts[i].type == STBTT_vcurve) {
            float x2 = verts[j].x *scale_x, y2 = verts[j].y *scale_y;
            float x1 = verts[i].cx*scale_x, y1 = verts[i].cy*scale_y;
            float x0 = verts[i].x *scale_x, y0 = verts[i].y *scale_y;
            float bx = x0 - 2*x1 + x2, by = y0 - 2*y1 + y2;
            float len2 = bx*bx + by*by;
            if (len2 != 0.0f)
               precompute[i] = 1.0f / (bx*bx + by*by);
            else
               precompute[i] = 0.0f;
         } else
            precompute[i] = 0.0f;
      }

      for (y=iy0; y < iy1; ++y) {
         for (x=ix0; x < ix1; ++x) {
            float val = void;
            float min_dist = 999999.0f;
            float sx = cast(float) x + 0.5f;
            float sy = cast(float) y + 0.5f;
            float x_gspace = (sx / scale_x);
            float y_gspace = (sy / scale_y);

            int winding = stbtt__compute_crossings_x(x_gspace, y_gspace, num_verts, verts);

            for (i=0; i < num_verts; ++i) {
               float x0 = verts[i].x*scale_x, y0 = verts[i].y*scale_y;

               if (verts[i].type == STBTT_vline && precompute[i] != 0.0f) {
                  float x1 = verts[i-1].x*scale_x, y1 = verts[i-1].y*scale_y;

                  float dist = void, dist2 = (x0-sx)*(x0-sx) + (y0-sy)*(y0-sy);
                  if (dist2 < min_dist*min_dist)
                     min_dist = cast(float) sqrt(dist2);




                  dist = cast(float) fabs((x1-x0)*(y0-sy) - (y1-y0)*(x0-sx)) * precompute[i];
                  assert(i != 0);
                  if (dist < min_dist) {



                     float dx = x1-x0, dy = y1-y0;
                     float px = x0-sx, py = y0-sy;


                     float t = -(px*dx + py*dy) / (dx*dx + dy*dy);
                     if (t >= 0.0f && t <= 1.0f)
                        min_dist = dist;
                  }
               } else if (verts[i].type == STBTT_vcurve) {
                  float x2 = verts[i-1].x *scale_x, y2 = verts[i-1].y *scale_y;
                  float x1 = verts[i ].cx*scale_x, y1 = verts[i ].cy*scale_y;
                  float box_x0 = ((((x0) < (x1) ? (x0) : (x1))) < (x2) ? (((x0) < (x1) ? (x0) : (x1))) : (x2));
                  float box_y0 = ((((y0) < (y1) ? (y0) : (y1))) < (y2) ? (((y0) < (y1) ? (y0) : (y1))) : (y2));
                  float box_x1 = ((((x0) < (x1) ? (x1) : (x0))) < (x2) ? (x2) : (((x0) < (x1) ? (x1) : (x0))));
                  float box_y1 = ((((y0) < (y1) ? (y1) : (y0))) < (y2) ? (y2) : (((y0) < (y1) ? (y1) : (y0))));

                  if (sx > box_x0-min_dist && sx < box_x1+min_dist && sy > box_y0-min_dist && sy < box_y1+min_dist) {
                     int num = 0;
                     float ax = x1-x0, ay = y1-y0;
                     float bx = x0 - 2*x1 + x2, by = y0 - 2*y1 + y2;
                     float mx = x0 - sx, my = y0 - sy;
                     float[3] res = [0.0f,0.0f,0.0f];
                     float px = void, py = void, t = void, it = void, dist2 = void;
                     float a_inv = precompute[i];
                     if (a_inv == 0.0) {
                        float a = 3*(ax*bx + ay*by);
                        float b = 2*(ax*ax + ay*ay) + (mx*bx+my*by);
                        float c = mx*ax+my*ay;
                        if (a == 0.0) {
                           if (b != 0.0) {
                              res[num++] = -c/b;
                           }
                        } else {
                           float discriminant = b*b - 4*a*c;
                           if (discriminant < 0)
                              num = 0;
                           else {
                              float root = cast(float) sqrt(discriminant);
                              res[0] = (-b - root)/(2*a);
                              res[1] = (-b + root)/(2*a);
                              num = 2;
                           }
                        }
                     } else {
                        float b = 3*(ax*bx + ay*by) * a_inv;
                        float c = (2*(ax*ax + ay*ay) + (mx*bx+my*by)) * a_inv;
                        float d = (mx*ax+my*ay) * a_inv;
                        num = stbtt__solve_cubic(b, c, d, res.ptr);
                     }
                     dist2 = (x0-sx)*(x0-sx) + (y0-sy)*(y0-sy);
                     if (dist2 < min_dist*min_dist)
                        min_dist = cast(float) sqrt(dist2);

                     if (num >= 1 && res[0] >= 0.0f && res[0] <= 1.0f) {
                        t = res[0], it = 1.0f - t;
                        px = it*it*x0 + 2*t*it*x1 + t*t*x2;
                        py = it*it*y0 + 2*t*it*y1 + t*t*y2;
                        dist2 = (px-sx)*(px-sx) + (py-sy)*(py-sy);
                        if (dist2 < min_dist * min_dist)
                           min_dist = cast(float) sqrt(dist2);
                     }
                     if (num >= 2 && res[1] >= 0.0f && res[1] <= 1.0f) {
                        t = res[1], it = 1.0f - t;
                        px = it*it*x0 + 2*t*it*x1 + t*t*x2;
                        py = it*it*y0 + 2*t*it*y1 + t*t*y2;
                        dist2 = (px-sx)*(px-sx) + (py-sy)*(py-sy);
                        if (dist2 < min_dist * min_dist)
                           min_dist = cast(float) sqrt(dist2);
                     }
                     if (num >= 3 && res[2] >= 0.0f && res[2] <= 1.0f) {
                        t = res[2], it = 1.0f - t;
                        px = it*it*x0 + 2*t*it*x1 + t*t*x2;
                        py = it*it*y0 + 2*t*it*y1 + t*t*y2;
                        dist2 = (px-sx)*(px-sx) + (py-sy)*(py-sy);
                        if (dist2 < min_dist * min_dist)
                           min_dist = cast(float) sqrt(dist2);
                     }
                  }
               }
            }
            if (winding == 0)
               min_dist = -min_dist;
            val = onedge_value + pixel_dist_scale * min_dist;
            if (val < 0)
               val = 0;
            else if (val > 255)
               val = 255;
            data[(y-iy0)*w+(x-ix0)] = cast(ubyte) val;
         }
      }
      (cast(void)(info.userdata),free(precompute));
      (cast(void)(info.userdata),free(verts));
   }
   return data;
}

ubyte* stbtt_GetCodepointSDF(const(stbtt_fontinfo)* info, float scale, int codepoint, int padding, ubyte onedge_value, float pixel_dist_scale, int* width, int* height, int* xoff, int* yoff)
{
   return stbtt_GetGlyphSDF(info, scale, stbtt_FindGlyphIndex(info, codepoint), padding, onedge_value, pixel_dist_scale, width, height, xoff, yoff);
}

void stbtt_FreeSDF(ubyte* bitmap, void* userdata)
{
   (cast(void)(userdata),free(bitmap));
}







stbtt_int32 stbtt__CompareUTF8toUTF16_bigendian_prefix(stbtt_uint8* s1, stbtt_int32 len1, stbtt_uint8* s2, stbtt_int32 len2)
{
   stbtt_int32 i = 0;


   while (len2) {
      stbtt_uint16 ch = s2[0]*256 + s2[1];
      if (ch < 0x80) {
         if (i >= len1) return -1;
         if (s1[i++] != ch) return -1;
      } else if (ch < 0x800) {
         if (i+1 >= len1) return -1;
         if (s1[i++] != 0xc0 + (ch >> 6)) return -1;
         if (s1[i++] != 0x80 + (ch & 0x3f)) return -1;
      } else if (ch >= 0xd800 && ch < 0xdc00) {
         stbtt_uint32 c = void;
         stbtt_uint16 ch2 = s2[2]*256 + s2[3];
         if (i+3 >= len1) return -1;
         c = ((ch - 0xd800) << 10) + (ch2 - 0xdc00) + 0x10000;
         if (s1[i++] != 0xf0 + (c >> 18)) return -1;
         if (s1[i++] != 0x80 + ((c >> 12) & 0x3f)) return -1;
         if (s1[i++] != 0x80 + ((c >> 6) & 0x3f)) return -1;
         if (s1[i++] != 0x80 + ((c ) & 0x3f)) return -1;
         s2 += 2;
         len2 -= 2;
      } else if (ch >= 0xdc00 && ch < 0xe000) {
         return -1;
      } else {
         if (i+2 >= len1) return -1;
         if (s1[i++] != 0xe0 + (ch >> 12)) return -1;
         if (s1[i++] != 0x80 + ((ch >> 6) & 0x3f)) return -1;
         if (s1[i++] != 0x80 + ((ch ) & 0x3f)) return -1;
      }
      s2 += 2;
      len2 -= 2;
   }
   return i;
}

int stbtt_CompareUTF8toUTF16_bigendian_internal(char* s1, int len1, char* s2, int len2)
{
   return len1 == stbtt__CompareUTF8toUTF16_bigendian_prefix(cast(stbtt_uint8*) s1, len1, cast(stbtt_uint8*) s2, len2);
}



const(char)* stbtt_GetFontNameString(const(stbtt_fontinfo)* font, int* length, int platformID, int encodingID, int languageID, int nameID)
{
   stbtt_int32 i = void, count = void, stringOffset = void;
   stbtt_uint8* fc = font.data;
   stbtt_uint32 offset = font.fontstart;
   stbtt_uint32 nm = stbtt__find_table(fc, offset, "name");
   if (!nm) return null;

   count = ttUSHORT(fc+nm+2);
   stringOffset = nm + ttUSHORT(fc+nm+4);
   for (i=0; i < count; ++i) {
      stbtt_uint32 loc = nm + 6 + 12 * i;
      if (platformID == ttUSHORT(fc+loc+0) && encodingID == ttUSHORT(fc+loc+2)
          && languageID == ttUSHORT(fc+loc+4) && nameID == ttUSHORT(fc+loc+6)) {
         *length = ttUSHORT(fc+loc+8);
         return cast(const(char)*) (fc+stringOffset+ttUSHORT(fc+loc+10));
      }
   }
   return null;
}

int stbtt__matchpair(stbtt_uint8* fc, stbtt_uint32 nm, stbtt_uint8* name, stbtt_int32 nlen, stbtt_int32 target_id, stbtt_int32 next_id)
{
   stbtt_int32 i = void;
   stbtt_int32 count = ttUSHORT(fc+nm+2);
   stbtt_int32 stringOffset = nm + ttUSHORT(fc+nm+4);

   for (i=0; i < count; ++i) {
      stbtt_uint32 loc = nm + 6 + 12 * i;
      stbtt_int32 id = ttUSHORT(fc+loc+6);
      if (id == target_id) {

         stbtt_int32 platform = ttUSHORT(fc+loc+0), encoding = ttUSHORT(fc+loc+2), language = ttUSHORT(fc+loc+4);


         if (platform == 0 || (platform == 3 && encoding == 1) || (platform == 3 && encoding == 10)) {
            stbtt_int32 slen = ttUSHORT(fc+loc+8);
            stbtt_int32 off = ttUSHORT(fc+loc+10);


            stbtt_int32 matchlen = stbtt__CompareUTF8toUTF16_bigendian_prefix(name, nlen, fc+stringOffset+off,slen);
            if (matchlen >= 0) {

               if (i+1 < count && ttUSHORT(fc+loc+12+6) == next_id && ttUSHORT(fc+loc+12) == platform && ttUSHORT(fc+loc+12+2) == encoding && ttUSHORT(fc+loc+12+4) == language) {
                  slen = ttUSHORT(fc+loc+12+8);
                  off = ttUSHORT(fc+loc+12+10);
                  if (slen == 0) {
                     if (matchlen == nlen)
                        return 1;
                  } else if (matchlen < nlen && name[matchlen] == ' ') {
                     ++matchlen;
                     if (stbtt_CompareUTF8toUTF16_bigendian_internal(cast(char*) (name+matchlen), nlen-matchlen, cast(char*)(fc+stringOffset+off),slen))
                        return 1;
                  }
               } else {

                  if (matchlen == nlen)
                     return 1;
               }
            }
         }


      }
   }
   return 0;
}

int stbtt__matches(stbtt_uint8* fc, stbtt_uint32 offset, stbtt_uint8* name, stbtt_int32 flags)
{
   stbtt_int32 nlen = cast(stbtt_int32) strlen(cast(char*) name);
   stbtt_uint32 nm = void, hd = void;
   if (!stbtt__isfont(fc+offset)) return 0;


   if (flags) {
      hd = stbtt__find_table(fc, offset, "head");
      if ((ttUSHORT(fc+hd+44) & 7) != (flags & 7)) return 0;
   }

   nm = stbtt__find_table(fc, offset, "name");
   if (!nm) return 0;

   if (flags) {

      if (stbtt__matchpair(fc, nm, name, nlen, 16, -1)) return 1;
      if (stbtt__matchpair(fc, nm, name, nlen, 1, -1)) return 1;
      if (stbtt__matchpair(fc, nm, name, nlen, 3, -1)) return 1;
   } else {
      if (stbtt__matchpair(fc, nm, name, nlen, 16, 17)) return 1;
      if (stbtt__matchpair(fc, nm, name, nlen, 1, 2)) return 1;
      if (stbtt__matchpair(fc, nm, name, nlen, 3, -1)) return 1;
   }

   return 0;
}

int stbtt_FindMatchingFont_internal(ubyte* font_collection, char* name_utf8, stbtt_int32 flags)
{
   stbtt_int32 i = void;
   for (i=0;;++i) {
      stbtt_int32 off = stbtt_GetFontOffsetForIndex(font_collection, i);
      if (off < 0) return off;
      if (stbtt__matches(cast(stbtt_uint8*) font_collection, off, cast(stbtt_uint8*) name_utf8, flags))
         return off;
   }
}

int stbtt_BakeFontBitmap(const(ubyte)* data, int offset, float pixel_height, ubyte* pixels, int pw, int ph, int first_char, int num_chars, stbtt_bakedchar* chardata)
{
   return stbtt_BakeFontBitmap_internal(cast(ubyte*) data, offset, pixel_height, pixels, pw, ph, first_char, num_chars, chardata);
}

int stbtt_GetFontOffsetForIndex(const(ubyte)* data, int index)
{
   return stbtt_GetFontOffsetForIndex_internal(cast(ubyte*) data, index);
}

int stbtt_GetNumberOfFonts(const(ubyte)* data)
{
   return stbtt_GetNumberOfFonts_internal(cast(ubyte*) data);
}

int stbtt_InitFont(stbtt_fontinfo* info, const(ubyte)* data, int offset)
{
   return stbtt_InitFont_internal(info, cast(ubyte*) data, offset);
}

int stbtt_FindMatchingFont(const(ubyte)* fontdata, const(char)* name, int flags)
{
   return stbtt_FindMatchingFont_internal(cast(ubyte*) fontdata, cast(char*) name, flags);
}

int stbtt_CompareUTF8toUTF16_bigendian(const(char)* s1, int len1, const(char)* s2, int len2)
{
   return stbtt_CompareUTF8toUTF16_bigendian_internal(cast(char*) s1, len1, cast(char*) s2, len2);
}

