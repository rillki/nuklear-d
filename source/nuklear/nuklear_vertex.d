module nuklear.nuklear_vertex;
extern(C) @nogc nothrow:
__gshared:

/* ===============================================================
 *
 *                              VERTEX
 *
 * ===============================================================*/

import nuklear.nuklear_types;
import nuklear.nuklear_util;
import nuklear.nuklear_buffer;
import nuklear.nuklear_color;
import nuklear.nuklear_utf8;
import nuklear.nuklear_image;
import nuklear.nuklear_context;
import nuklear.nuklear_layout;

version (NK_INCLUDE_VERTEX_BUFFER_OUTPUT) {
    void nk_draw_list_init(nk_draw_list* list)
    {
        nk_size i = 0;
        assert(list);
        if (!list) return;
        nk_zero(list, typeof(*list).sizeof);
        for (i = 0; i < list.circle_vtx.length; ++i) {
            const(float) a = (cast(float)i / cast(float)(list.circle_vtx.length)) * 2 * NK_PI;
            list.circle_vtx[i].x = cast(float)nk_cos(a);
            list.circle_vtx[i].y = cast(float)nk_sin(a);
        }
    }
    void nk_draw_list_setup(nk_draw_list* canvas, const(nk_convert_config)* config, nk_buffer* cmds, nk_buffer* vertices, nk_buffer* elements, nk_anti_aliasing line_aa, nk_anti_aliasing shape_aa)
    {
        assert(canvas);
        assert(config);
        assert(cmds);
        assert(vertices);
        assert(elements);
        if (!canvas || !config || !cmds || !vertices || !elements)
            return;

        canvas.buffer = cmds;
        canvas.config = cast(nk_convert_config)(*config);
        canvas.elements = elements;
        canvas.vertices = vertices;
        canvas.line_AA = line_aa;
        canvas.shape_AA = shape_aa;
        canvas.clip_rect = nk_null_rect;

        canvas.cmd_offset = 0;
        canvas.element_count = 0;
        canvas.vertex_count = 0;
        canvas.cmd_offset = 0;
        canvas.cmd_count = 0;
        canvas.path_count = 0;
    }
    const(nk_draw_command)* nk__draw_list_begin(const(nk_draw_list)* canvas, const(nk_buffer)* buffer)
    {
        nk_byte* memory = void;
        nk_size offset = void;
        const(nk_draw_command)* cmd = void;

        assert(buffer);
        if (!buffer || !buffer.size || !canvas.cmd_count)
            return null;

        memory = cast(nk_byte*)buffer.memory.ptr;
        offset = buffer.memory.size - canvas.cmd_offset;
        cmd = nk_ptr_add!(const nk_draw_command)(memory, offset);
        return cmd;
    }
    const(nk_draw_command)* nk__draw_list_end(const(nk_draw_list)* canvas, const(nk_buffer)* buffer)
    {
        nk_size size = void;
        nk_size offset = void;
        nk_byte* memory = void;
        const(nk_draw_command)* end = void;

        assert(buffer);
        assert(canvas);
        if (!buffer || !canvas)
            return null;

        memory = cast(nk_byte*)buffer.memory.ptr;
        size = buffer.memory.size;
        offset = size - canvas.cmd_offset;
        end = nk_ptr_add!(const nk_draw_command)(memory, offset);
        end -= (canvas.cmd_count-1);
        return end;
    }
    const(nk_draw_command)* nk__draw_list_next(const(nk_draw_command)* cmd, const(nk_buffer)* buffer, const(nk_draw_list)* canvas)
    {
        const(nk_draw_command)* end = void;
        assert(buffer);
        assert(canvas);
        if (!cmd || !buffer || !canvas)
            return null;

        end = nk__draw_list_end(canvas, buffer);
        if (cmd <= end) return null;
        return (cmd-1);
    }
    nk_vec2* nk_draw_list_alloc_path(nk_draw_list* list, int count)
    {
        nk_vec2* points = void;
        enum nk_size point_align = nk_vec2.alignof;
        enum nk_size point_size = nk_vec2.sizeof;
        points = cast(nk_vec2*)
            nk_buffer_alloc(list.buffer, NK_BUFFER_FRONT,
                            point_size * cast(nk_size)count, point_align);

        if (!points) return null;
        if (!list.path_offset) {
            void* memory = nk_buffer_memory(list.buffer);
            list.path_offset = cast(uint)(cast(nk_byte*)points - cast(nk_byte*)memory);
        }
        list.path_count += cast(uint)count;
        return points;
    }
    nk_vec2 nk_draw_list_path_last(nk_draw_list* list)
    {
        void* memory = void;
        nk_vec2* point = void;
        assert(list.path_count);
        memory = nk_buffer_memory(list.buffer);
        point = nk_ptr_add!nk_vec2(memory, list.path_offset);
        point += (list.path_count-1);
        return *point;
    }
    nk_draw_command* nk_draw_list_push_command(nk_draw_list* list, nk_rect clip, nk_handle texture)
    {
        enum nk_size cmd_align = nk_draw_command.alignof;
        enum nk_size cmd_size = nk_draw_command.sizeof;
        nk_draw_command* cmd = void;

        assert(list);
        cmd = cast(nk_draw_command*)
            nk_buffer_alloc(list.buffer, NK_BUFFER_BACK, cmd_size, cmd_align);

        if (!cmd) return null;
        if (!list.cmd_count) {
            nk_byte* memory = cast(nk_byte*)nk_buffer_memory(list.buffer);
            nk_size total = nk_buffer_total(list.buffer);
            memory = nk_ptr_add!nk_byte(memory, total);
            list.cmd_offset = cast(nk_size)(memory - cast(nk_byte*)cmd);
        }

        cmd.elem_count = 0;
        cmd.clip_rect = clip;
        cmd.texture = texture;
        version (NK_INCLUDE_COMMAND_USERDATA) {
            cmd.userdata = list.userdata;
        }

        list.cmd_count++;
        list.clip_rect = clip;
        return cmd;
    }
    nk_draw_command* nk_draw_list_command_last(nk_draw_list* list)
    {
        void* memory = void;
        nk_size size = void;
        nk_draw_command* cmd = void;
        assert(list.cmd_count);

        memory = nk_buffer_memory(list.buffer);
        size = nk_buffer_total(list.buffer);
        cmd = nk_ptr_add!nk_draw_command(memory, size - list.cmd_offset);
        return (cmd - (list.cmd_count-1));
    }
    void nk_draw_list_add_clip(nk_draw_list* list, nk_rect rect)
    {
        assert(list);
        if (!list) return;
        if (!list.cmd_count) {
            nk_draw_list_push_command(list, rect, list.config.tex_null.texture);
        } else {
            nk_draw_command* prev = nk_draw_list_command_last(list);
            if (prev.elem_count == 0)
                prev.clip_rect = rect;
            nk_draw_list_push_command(list, rect, prev.texture);
        }
    }
    void nk_draw_list_push_image(nk_draw_list* list, nk_handle texture)
    {
        assert(list);
        if (!list) return;
        version (NK_INCLUDE_COMMAND_USERDATA) {
            if (!list.cmd_count) {
                nk_draw_list_push_command(list, nk_null_rect, texture);
            } else {
                nk_draw_command* prev = nk_draw_list_command_last(list);
                if (prev.elem_count == 0) {
                    prev.texture = texture;
                    prev.userdata = list.userdata;
                } else if (prev.texture.id != texture.id || prev.userdata.id != list.userdata.id) {
                    nk_draw_list_push_command(list, prev.clip_rect, texture);
                }
            }
        } else {
            if (!list.cmd_count) {
                nk_draw_list_push_command(list, nk_null_rect, texture);
            } else {
                nk_draw_command* prev = nk_draw_list_command_last(list);
                if (prev.elem_count == 0) {
                    prev.texture = texture;
                } else if (prev.texture.id != texture.id) {
                    nk_draw_list_push_command(list, prev.clip_rect, texture);
                }
            }
        }
    }
    version (NK_INCLUDE_COMMAND_USERDATA) {
        void nk_draw_list_push_userdata(nk_draw_list* list, nk_handle userdata)
        {
            list.userdata = userdata;
        }
    }
    void* nk_draw_list_alloc_vertices(nk_draw_list* list, nk_size count)
    {
        void* vtx = void;
        assert(list);
        if (!list) return null;
        vtx = nk_buffer_alloc(list.vertices, NK_BUFFER_FRONT,
            list.config.vertex_size*count, list.config.vertex_alignment);
        if (!vtx) return null;
        list.vertex_count += cast(uint)count;

        /* This assert triggers because your are drawing a lot of stuff and nuklear
        * defined `nk_draw_index` as `nk_ushort` to safe space be default.
        *
        * So you reached the maximum number of indices or rather vertexes.
        * To solve this issue please change typedef `nk_draw_index` to `nk_uint`
        * and don't forget to specify the new element size in your drawing
        * backend (OpenGL, DirectX, ...). For example in OpenGL for `glDrawElements`
        * instead of specifying `GL_UNSIGNED_SHORT` you have to define `GL_UNSIGNED_INT`.
        * Sorry for the inconvenience. */
        if(nk_draw_index.sizeof==2) assert((list.vertex_count < ushort.max &&
            "To many vertices for 16-bit vertex indices. Please read comment above on how to solve this problem"));
        return vtx;
    }
    nk_draw_index* nk_draw_list_alloc_elements(nk_draw_list* list, nk_size count)
    {
        nk_draw_index* ids = void;
        nk_draw_command* cmd = void;
        enum nk_size elem_align = nk_draw_index.alignof;
        enum nk_size elem_size = nk_draw_index.sizeof;
        assert(list);
        if (!list) return null;

        ids = cast(nk_draw_index*)
            nk_buffer_alloc(list.elements, NK_BUFFER_FRONT, elem_size*count, elem_align);
        if (!ids) return null;
        cmd = nk_draw_list_command_last(list);
        list.element_count += cast(uint)count;
        cmd.elem_count += cast(uint)count;
        return ids;
    }
    int nk_draw_vertex_layout_element_is_end_of_layout(const(nk_draw_vertex_layout_element)* element)
    {
        return (element.attribute == NK_VERTEX_ATTRIBUTE_COUNT ||
                element.format == NK_FORMAT_COUNT);
    }
    void nk_draw_vertex_color(void* attr, const(float)* vals, nk_draw_vertex_layout_format format)
    {
        /* if this triggers you tried to provide a value format for a color */
        float[4] val = void;
        assert(format >= NK_FORMAT_COLOR_BEGIN);
        assert(format <= NK_FORMAT_COLOR_END);
        if (format < NK_FORMAT_COLOR_BEGIN || format > NK_FORMAT_COLOR_END) return;

        val[0] = nk_saturate(vals[0]);
        val[1] = nk_saturate(vals[1]);
        val[2] = nk_saturate(vals[2]);
        val[3] = nk_saturate(vals[3]);

        switch (format) {
        default: assert(0 && "Invalid vertex layout color format"); // break;
        case NK_FORMAT_R8G8B8A8:
        case NK_FORMAT_R8G8B8: {
            nk_color col = nk_rgba_fv(val.ptr);
            nk_memcopy(attr, &col.r, col.sizeof);
        } break;
        case NK_FORMAT_B8G8R8A8: {
            nk_color col = nk_rgba_fv(val.ptr);
            nk_color bgra = nk_rgba(col.b, col.g, col.r, col.a);
            nk_memcopy(attr, &bgra, bgra.sizeof);
        } break;
        case NK_FORMAT_R16G15B16: {
            nk_ushort[3] col = void;
            col[0] = cast(nk_ushort)(val[0]*cast(float)ushort.max);
            col[1] = cast(nk_ushort)(val[1]*cast(float)ushort.max);
            col[2] = cast(nk_ushort)(val[2]*cast(float)ushort.max);
            nk_memcopy(attr, col.ptr, col.sizeof);
        } break;
        case NK_FORMAT_R16G15B16A16: {
            nk_ushort[4] col = void;
            col[0] = cast(nk_ushort)(val[0]*cast(float)ushort.max);
            col[1] = cast(nk_ushort)(val[1]*cast(float)ushort.max);
            col[2] = cast(nk_ushort)(val[2]*cast(float)ushort.max);
            col[3] = cast(nk_ushort)(val[3]*cast(float)ushort.max);
            nk_memcopy(attr, col.ptr, col.sizeof);
        } break;
        case NK_FORMAT_R32G32B32: {
            nk_uint[3] col = void;
            col[0] = cast(nk_uint)(val[0]*cast(float)uint.max);
            col[1] = cast(nk_uint)(val[1]*cast(float)uint.max);
            col[2] = cast(nk_uint)(val[2]*cast(float)uint.max);
            nk_memcopy(attr, col.ptr, col.sizeof);
        } break;
        case NK_FORMAT_R32G32B32A32: {
            nk_uint[4] col = void;
            col[0] = cast(nk_uint)(val[0]*cast(float)uint.max);
            col[1] = cast(nk_uint)(val[1]*cast(float)uint.max);
            col[2] = cast(nk_uint)(val[2]*cast(float)uint.max);
            col[3] = cast(nk_uint)(val[3]*cast(float)uint.max);
            nk_memcopy(attr, col.ptr, col.sizeof);
        } break;
        case NK_FORMAT_R32G32B32A32_FLOAT:
            nk_memcopy(attr, val.ptr, float.sizeof *4);
            break;
        case NK_FORMAT_R32G32B32A32_DOUBLE: {
            double[4] col = void;
            col[0] = cast(double)val[0];
            col[1] = cast(double)val[1];
            col[2] = cast(double)val[2];
            col[3] = cast(double)val[3];
            nk_memcopy(attr, col.ptr, col.sizeof);
        } break;
        case NK_FORMAT_RGB32:
        case NK_FORMAT_RGBA32: {
            nk_color col = nk_rgba_fv(val.ptr);
            nk_uint color = nk_color_u32(col);
            nk_memcopy(attr, &color, color.sizeof);
        } break; }
    }
    void nk_draw_vertex_element(void* dst, const(float)* values, int value_count, nk_draw_vertex_layout_format format)
    {
        int value_index = void;
        void* attribute = dst;
        /* if this triggers you tried to provide a color format for a value */
        assert(format < NK_FORMAT_COLOR_BEGIN);
        if (format >= NK_FORMAT_COLOR_BEGIN && format <= NK_FORMAT_COLOR_END) return;
        for (value_index = 0; value_index < value_count; ++value_index) {
            switch (format) {
            default: assert(0 && "invalid vertex layout format"); // break;
            case NK_FORMAT_SCHAR: {
                char value = cast(char)nk_clamp(cast(float)byte.min, values[value_index], cast(float)byte.max);
                nk_memcopy(attribute, &value, value.sizeof);
                attribute = cast(void*)(cast(char*)attribute + char.sizeof);
            } break;
            case NK_FORMAT_SSHORT: {
                nk_short value = cast(nk_short)nk_clamp(cast(float)short.min, values[value_index], cast(float)short.max);
                nk_memcopy(attribute, &value, value.sizeof);
                attribute = cast(void*)(cast(char*)attribute + value.sizeof);
            } break;
            case NK_FORMAT_SINT: {
                nk_int value = cast(nk_int)nk_clamp(cast(float)int.min, values[value_index], cast(float)int.max);
                nk_memcopy(attribute, &value, value.sizeof);
                attribute = cast(void*)(cast(char*)attribute + nk_int.sizeof);
            } break;
            case NK_FORMAT_UCHAR: {
                ubyte value = cast(ubyte)nk_clamp(cast(float)ubyte.min, values[value_index], cast(float)ubyte.max);
                nk_memcopy(attribute, &value, value.sizeof);
                attribute = cast(void*)(cast(char*)attribute + ubyte.sizeof);
            } break;
            case NK_FORMAT_USHORT: {
                nk_ushort value = cast(nk_ushort)nk_clamp(cast(float)ushort.min, values[value_index], cast(float)ushort.max);
                nk_memcopy(attribute, &value, value.sizeof);
                attribute = cast(void*)(cast(char*)attribute + value.sizeof);
                } break;
            case NK_FORMAT_UINT: {
                nk_uint value = cast(nk_uint)nk_clamp(cast(float)uint.min, values[value_index], cast(float)uint.max);
                nk_memcopy(attribute, &value, value.sizeof);
                attribute = cast(void*)(cast(char*)attribute + nk_uint.sizeof);
            } break;
            case NK_FORMAT_FLOAT:
                nk_memcopy(attribute, &values[value_index], typeof(values[value_index]).sizeof);
                attribute = cast(void*)(cast(char*)attribute + float.sizeof);
                break;
            case NK_FORMAT_DOUBLE: {
                double value = cast(double)values[value_index];
                nk_memcopy(attribute, &value, value.sizeof);
                attribute = cast(void*)(cast(char*)attribute + double.sizeof);
                } break;
            }
        }
    }
    void* nk_draw_vertex(void* dst, const(nk_convert_config)* config, nk_vec2 pos, nk_vec2 uv, nk_colorf color)
    {
        void* result = cast(void*)(cast(char*)dst + config.vertex_size);
        const(nk_draw_vertex_layout_element)* elem_iter = config.vertex_layout;
        while (!nk_draw_vertex_layout_element_is_end_of_layout(elem_iter)) {
            void* address = cast(void*)(cast(char*)dst + elem_iter.offset);
            switch (elem_iter.attribute) {
            case NK_VERTEX_ATTRIBUTE_COUNT:
            default: assert(0 && "wrong element attribute"); // break;
            case NK_VERTEX_POSITION: nk_draw_vertex_element(address, &pos.x, 2, elem_iter.format); break;
            case NK_VERTEX_TEXCOORD: nk_draw_vertex_element(address, &uv.x, 2, elem_iter.format); break;
            case NK_VERTEX_COLOR: nk_draw_vertex_color(address, &color.r, elem_iter.format); break;
            }
            elem_iter++;
        }
        return result;
    }
    void nk_draw_list_stroke_poly_line(nk_draw_list* list, const(nk_vec2)* points, const(uint) points_count, nk_color color, nk_draw_list_stroke closed, float thickness, nk_anti_aliasing aliasing)
    {
        nk_size count = void;
        int thick_line = void;
        nk_colorf col = void;
        nk_colorf col_trans = void;
        assert(list);
        if (!list || points_count < 2) return;

        color.a = cast(nk_byte)(cast(float)color.a * list.config.global_alpha);
        count = points_count;
        if (!closed) count = points_count-1;
        thick_line = thickness > 1.0f;

    version (NK_INCLUDE_COMMAND_USERDATA) {
        nk_draw_list_push_userdata(list, list.userdata);
    }

        color.a = cast(nk_byte)(cast(float)color.a * list.config.global_alpha);
        nk_color_fv(&col.r, color);
        col_trans = col;
        col_trans.a = 0;

        if (aliasing == NK_ANTI_ALIASING_ON) {
            /* ANTI-ALIASED STROKE */
            const(float) AA_SIZE = 1.0f;
            enum nk_size pnt_align = nk_vec2.alignof;
            enum nk_size pnt_size = nk_vec2.sizeof;

            /* allocate vertices and elements  */
            nk_size i1 = 0;
            nk_size vertex_offset = void;
            nk_size index = list.vertex_count;

            const(nk_size) idx_count = (thick_line) ?  (count * 18) : (count * 12);
            const(nk_size) vtx_count = (thick_line) ? (points_count * 4): (points_count *3);

            void* vtx = nk_draw_list_alloc_vertices(list, vtx_count);
            nk_draw_index* ids = nk_draw_list_alloc_elements(list, idx_count);

            nk_size size = void;
            nk_vec2* normals = void, temp = void;
            if (!vtx || !ids) return;

            /* temporary allocate normals + points */
            vertex_offset = cast(nk_size)(cast(nk_byte*)vtx - cast(nk_byte*)list.vertices.memory.ptr);
            nk_buffer_mark(list.vertices, NK_BUFFER_FRONT);
            size = pnt_size * ((thick_line) ? 5 : 3) * points_count;
            normals = cast(nk_vec2*) nk_buffer_alloc(list.vertices, NK_BUFFER_FRONT, size, pnt_align);
            if (!normals) return;
            temp = normals + points_count;

            /* make sure vertex pointer is still correct */
            vtx = cast(void*)(cast(nk_byte*)list.vertices.memory.ptr + vertex_offset);

            /* calculate normals */
            for (i1 = 0; i1 < count; ++i1) {
                const(nk_size) i2 = ((i1 + 1) == points_count) ? 0 : (i1 + 1);
                nk_vec2 diff = nk_vec2_sub(points[i2], points[i1]);
                float len = void;

                /* vec2 inverted length  */
                len = nk_vec2_len_sqr(diff);
                if (len != 0.0f)
                    len = nk_inv_sqrt(len);
                else len = 1.0f;

                diff = nk_vec2_muls(diff, len);
                normals[i1].x = diff.y;
                normals[i1].y = -diff.x;
            }

            if (!closed)
                normals[points_count-1] = normals[points_count-2];

            if (!thick_line) {
                nk_size idx1 = void, i = void;
                if (!closed) {
                    nk_vec2 d = void;
                    temp[0] = nk_vec2_add(points[0], nk_vec2_muls(normals[0], AA_SIZE));
                    temp[1] = nk_vec2_sub(points[0], nk_vec2_muls(normals[0], AA_SIZE));
                    d = nk_vec2_muls(normals[points_count-1], AA_SIZE);
                    temp[(points_count-1) * 2 + 0] = nk_vec2_add(points[points_count-1], d);
                    temp[(points_count-1) * 2 + 1] = nk_vec2_sub(points[points_count-1], d);
                }

                /* fill elements */
                idx1 = index;
                for (i1 = 0; i1 < count; i1++) {
                    nk_vec2 dm = void;
                    float dmr2 = void;
                    nk_size i2 = ((i1 + 1) == points_count) ? 0 : (i1 + 1);
                    nk_size idx2 = ((i1+1) == points_count) ? index: (idx1 + 3);

                    /* average normals */
                    dm = nk_vec2_muls(nk_vec2_add(normals[i1], normals[i2]), 0.5f);
                    dmr2 = dm.x * dm.x + dm.y* dm.y;
                    if (dmr2 > 0.000001f) {
                        float scale = 1.0f/dmr2;
                        scale = nk_min(100.0f, scale);
                        dm = nk_vec2_muls(dm, scale);
                    }

                    dm = nk_vec2_muls(dm, AA_SIZE);
                    temp[i2*2+0] = nk_vec2_add(points[i2], dm);
                    temp[i2*2+1] = nk_vec2_sub(points[i2], dm);

                    ids[0] = cast(nk_draw_index)(idx2 + 0); ids[1] = cast(nk_draw_index)(idx1+0);
                    ids[2] = cast(nk_draw_index)(idx1 + 2); ids[3] = cast(nk_draw_index)(idx1+2);
                    ids[4] = cast(nk_draw_index)(idx2 + 2); ids[5] = cast(nk_draw_index)(idx2+0);
                    ids[6] = cast(nk_draw_index)(idx2 + 1); ids[7] = cast(nk_draw_index)(idx1+1);
                    ids[8] = cast(nk_draw_index)(idx1 + 0); ids[9] = cast(nk_draw_index)(idx1+0);
                    ids[10]= cast(nk_draw_index)(idx2 + 0); ids[11]= cast(nk_draw_index)(idx2+1);
                    ids += 12;
                    idx1 = idx2;
                }

                /* fill vertices */
                for (i = 0; i < points_count; ++i) {
                    const(nk_vec2) uv = list.config.tex_null.uv;
                    vtx = nk_draw_vertex(vtx, &list.config, points[i], uv, col);
                    vtx = nk_draw_vertex(vtx, &list.config, temp[i*2+0], uv, col_trans);
                    vtx = nk_draw_vertex(vtx, &list.config, temp[i*2+1], uv, col_trans);
                }
            } else {
                nk_size idx1 = void, i = void;
                const(float) half_inner_thickness = (thickness - AA_SIZE) * 0.5f;
                if (!closed) {
                    nk_vec2 d1 = nk_vec2_muls(normals[0], half_inner_thickness + AA_SIZE);
                    nk_vec2 d2 = nk_vec2_muls(normals[0], half_inner_thickness);

                    temp[0] = nk_vec2_add(points[0], d1);
                    temp[1] = nk_vec2_add(points[0], d2);
                    temp[2] = nk_vec2_sub(points[0], d2);
                    temp[3] = nk_vec2_sub(points[0], d1);

                    d1 = nk_vec2_muls(normals[points_count-1], half_inner_thickness + AA_SIZE);
                    d2 = nk_vec2_muls(normals[points_count-1], half_inner_thickness);

                    temp[(points_count-1)*4+0] = nk_vec2_add(points[points_count-1], d1);
                    temp[(points_count-1)*4+1] = nk_vec2_add(points[points_count-1], d2);
                    temp[(points_count-1)*4+2] = nk_vec2_sub(points[points_count-1], d2);
                    temp[(points_count-1)*4+3] = nk_vec2_sub(points[points_count-1], d1);
                }

                /* add all elements */
                idx1 = index;
                for (i1 = 0; i1 < count; ++i1) {
                    nk_vec2 dm_out = void, dm_in = void;
                    const(nk_size) i2 = ((i1+1) == points_count) ? 0: (i1 + 1);
                    nk_size idx2 = ((i1+1) == points_count) ? index: (idx1 + 4);

                    /* average normals */
                    nk_vec2 dm = nk_vec2_muls(nk_vec2_add(normals[i1], normals[i2]), 0.5f);
                    float dmr2 = dm.x * dm.x + dm.y* dm.y;
                    if (dmr2 > 0.000001f) {
                        float scale = 1.0f/dmr2;
                        scale = nk_min(100.0f, scale);
                        dm = nk_vec2_muls(dm, scale);
                    }

                    dm_out = nk_vec2_muls(dm, ((half_inner_thickness) + AA_SIZE));
                    dm_in = nk_vec2_muls(dm, half_inner_thickness);
                    temp[i2*4+0] = nk_vec2_add(points[i2], dm_out);
                    temp[i2*4+1] = nk_vec2_add(points[i2], dm_in);
                    temp[i2*4+2] = nk_vec2_sub(points[i2], dm_in);
                    temp[i2*4+3] = nk_vec2_sub(points[i2], dm_out);

                    /* add indexes */
                    ids[0] = cast(nk_draw_index)(idx2 + 1); ids[1] = cast(nk_draw_index)(idx1+1);
                    ids[2] = cast(nk_draw_index)(idx1 + 2); ids[3] = cast(nk_draw_index)(idx1+2);
                    ids[4] = cast(nk_draw_index)(idx2 + 2); ids[5] = cast(nk_draw_index)(idx2+1);
                    ids[6] = cast(nk_draw_index)(idx2 + 1); ids[7] = cast(nk_draw_index)(idx1+1);
                    ids[8] = cast(nk_draw_index)(idx1 + 0); ids[9] = cast(nk_draw_index)(idx1+0);
                    ids[10]= cast(nk_draw_index)(idx2 + 0); ids[11] = cast(nk_draw_index)(idx2+1);
                    ids[12]= cast(nk_draw_index)(idx2 + 2); ids[13] = cast(nk_draw_index)(idx1+2);
                    ids[14]= cast(nk_draw_index)(idx1 + 3); ids[15] = cast(nk_draw_index)(idx1+3);
                    ids[16]= cast(nk_draw_index)(idx2 + 3); ids[17] = cast(nk_draw_index)(idx2+2);
                    ids += 18;
                    idx1 = idx2;
                }

                /* add vertices */
                for (i = 0; i < points_count; ++i) {
                    const(nk_vec2) uv = list.config.tex_null.uv;
                    vtx = nk_draw_vertex(vtx, &list.config, temp[i*4+0], uv, col_trans);
                    vtx = nk_draw_vertex(vtx, &list.config, temp[i*4+1], uv, col);
                    vtx = nk_draw_vertex(vtx, &list.config, temp[i*4+2], uv, col);
                    vtx = nk_draw_vertex(vtx, &list.config, temp[i*4+3], uv, col_trans);
                }
            }
            /* free temporary normals + points */
            nk_buffer_reset(list.vertices, NK_BUFFER_FRONT);
        } else {
            /* NON ANTI-ALIASED STROKE */
            nk_size i1 = 0;
            nk_size idx = list.vertex_count;
            const(nk_size) idx_count = count * 6;
            const(nk_size) vtx_count = count * 4;
            void* vtx = nk_draw_list_alloc_vertices(list, vtx_count);
            nk_draw_index* ids = nk_draw_list_alloc_elements(list, idx_count);
            if (!vtx || !ids) return;

            for (i1 = 0; i1 < count; ++i1) {
                float dx = void, dy = void;
                const(nk_vec2) uv = list.config.tex_null.uv;
                const(nk_size) i2 = ((i1+1) == points_count) ? 0 : i1 + 1;
                const(nk_vec2) p1 = points[i1];
                const(nk_vec2) p2 = points[i2];
                nk_vec2 diff = nk_vec2_sub(p2, p1);
                float len = void;

                /* vec2 inverted length  */
                len = nk_vec2_len_sqr(diff);
                if (len != 0.0f)
                    len = nk_inv_sqrt(len);
                else len = 1.0f;
                diff = nk_vec2_muls(diff, len);

                /* add vertices */
                dx = diff.x * (thickness * 0.5f);
                dy = diff.y * (thickness * 0.5f);

                vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(p1.x + dy, p1.y - dx), uv, col);
                vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(p2.x + dy, p2.y - dx), uv, col);
                vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(p2.x - dy, p2.y + dx), uv, col);
                vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(p1.x - dy, p1.y + dx), uv, col);

                ids[0] = cast(nk_draw_index)(idx+0); ids[1] = cast(nk_draw_index)(idx+1);
                ids[2] = cast(nk_draw_index)(idx+2); ids[3] = cast(nk_draw_index)(idx+0);
                ids[4] = cast(nk_draw_index)(idx+2); ids[5] = cast(nk_draw_index)(idx+3);

                ids += 6;
                idx += 4;
            }
        }
    }
    void nk_draw_list_fill_poly_convex(nk_draw_list* list, const(nk_vec2)* points, const(uint) points_count, nk_color color, nk_anti_aliasing aliasing)
    {
        nk_colorf col = void;
        nk_colorf col_trans = void;

        enum nk_size pnt_align = nk_vec2.alignof;
        enum nk_size pnt_size = nk_vec2.sizeof;
        assert(list);
        if (!list || points_count < 3) return;

        version (NK_INCLUDE_COMMAND_USERDATA) {
            nk_draw_list_push_userdata(list, list.userdata);
        }

        color.a = cast(nk_byte)(cast(float)color.a * list.config.global_alpha);
        nk_color_fv(&col.r, color);
        col_trans = col;
        col_trans.a = 0;

        if (aliasing == NK_ANTI_ALIASING_ON) {
            nk_size i = 0;
            nk_size i0 = 0;
            nk_size i1 = 0;

            const(float) AA_SIZE = 1.0f;
            nk_size vertex_offset = 0;
            nk_size index = list.vertex_count;

            const(nk_size) idx_count = (points_count-2)*3 + points_count*6;
            const(nk_size) vtx_count = (points_count*2);

            void* vtx = nk_draw_list_alloc_vertices(list, vtx_count);
            nk_draw_index* ids = nk_draw_list_alloc_elements(list, idx_count);

            nk_size size = 0;
            nk_vec2* normals = null;
            uint vtx_inner_idx = cast(uint)(index + 0);
            uint vtx_outer_idx = cast(uint)(index + 1);
            if (!vtx || !ids) return;

            /* temporary allocate normals */
            vertex_offset = cast(nk_size)(cast(nk_byte*)vtx - cast(nk_byte*)list.vertices.memory.ptr);
            nk_buffer_mark(list.vertices, NK_BUFFER_FRONT);
            size = pnt_size * points_count;
            normals = cast(nk_vec2*) nk_buffer_alloc(list.vertices, NK_BUFFER_FRONT, size, pnt_align);
            if (!normals) return;
            vtx = cast(void*)(cast(nk_byte*)list.vertices.memory.ptr + vertex_offset);

            /* add elements */
            for (i = 2; i < points_count; i++) {
                ids[0] = cast(nk_draw_index)(vtx_inner_idx);
                ids[1] = cast(nk_draw_index)(vtx_inner_idx + ((i-1) << 1));
                ids[2] = cast(nk_draw_index)(vtx_inner_idx + (i << 1));
                ids += 3;
            }

            /* compute normals */
            for (i0 = points_count-1, i1 = 0; i1 < points_count; i0 = i1++) {
                nk_vec2 p0 = points[i0];
                nk_vec2 p1 = points[i1];
                nk_vec2 diff = nk_vec2_sub(p1, p0);

                /* vec2 inverted length  */
                float len = nk_vec2_len_sqr(diff);
                if (len != 0.0f)
                    len = nk_inv_sqrt(len);
                else len = 1.0f;
                diff = nk_vec2_muls(diff, len);

                normals[i0].x = diff.y;
                normals[i0].y = -diff.x;
            }

            /* add vertices + indexes */
            for (i0 = points_count-1, i1 = 0; i1 < points_count; i0 = i1++) {
                const(nk_vec2) uv = list.config.tex_null.uv;
                nk_vec2 n0 = normals[i0];
                nk_vec2 n1 = normals[i1];
                nk_vec2 dm = nk_vec2_muls(nk_vec2_add(n0, n1), 0.5f);
                float dmr2 = dm.x*dm.x + dm.y*dm.y;
                if (dmr2 > 0.000001f) {
                    float scale = 1.0f / dmr2;
                    scale = nk_min(scale, 100.0f);
                    dm = nk_vec2_muls(dm, scale);
                }
                dm = nk_vec2_muls(dm, AA_SIZE * 0.5f);

                /* add vertices */
                vtx = nk_draw_vertex(vtx, &list.config, nk_vec2_sub(points[i1], dm), uv, col);
                vtx = nk_draw_vertex(vtx, &list.config, nk_vec2_add(points[i1], dm), uv, col_trans);

                /* add indexes */
                ids[0] = cast(nk_draw_index)(vtx_inner_idx+(i1<<1));
                ids[1] = cast(nk_draw_index)(vtx_inner_idx+(i0<<1));
                ids[2] = cast(nk_draw_index)(vtx_outer_idx+(i0<<1));
                ids[3] = cast(nk_draw_index)(vtx_outer_idx+(i0<<1));
                ids[4] = cast(nk_draw_index)(vtx_outer_idx+(i1<<1));
                ids[5] = cast(nk_draw_index)(vtx_inner_idx+(i1<<1));
                ids += 6;
            }
            /* free temporary normals + points */
            nk_buffer_reset(list.vertices, NK_BUFFER_FRONT);
        } else {
            nk_size i = 0;
            nk_size index = list.vertex_count;
            const(nk_size) idx_count = (points_count-2)*3;
            const(nk_size) vtx_count = points_count;
            void* vtx = nk_draw_list_alloc_vertices(list, vtx_count);
            nk_draw_index* ids = nk_draw_list_alloc_elements(list, idx_count);

            if (!vtx || !ids) return;
            for (i = 0; i < vtx_count; ++i)
                vtx = nk_draw_vertex(vtx, &list.config, points[i], list.config.tex_null.uv, col);
            for (i = 2; i < points_count; ++i) {
                ids[0] = cast(nk_draw_index)index;
                ids[1] = cast(nk_draw_index)(index+ i - 1);
                ids[2] = cast(nk_draw_index)(index+i);
                ids += 3;
            }
        }
    }
    void nk_draw_list_path_clear(nk_draw_list* list)
    {
        assert(list);
        if (!list) return;
        nk_buffer_reset(list.buffer, NK_BUFFER_FRONT);
        list.path_count = 0;
        list.path_offset = 0;
    }
    void nk_draw_list_path_line_to(nk_draw_list* list, nk_vec2 pos)
    {
        nk_vec2* points = null;
        nk_draw_command* cmd = null;
        assert(list);
        if (!list) return;
        if (!list.cmd_count)
            nk_draw_list_add_clip(list, nk_null_rect);

        cmd = nk_draw_list_command_last(list);
        if (cmd && cmd.texture.ptr != list.config.tex_null.texture.ptr)
            nk_draw_list_push_image(list, list.config.tex_null.texture);

        points = nk_draw_list_alloc_path(list, 1);
        if (!points) return;
        points[0] = pos;
    }
    void nk_draw_list_path_arc_to_fast(nk_draw_list* list, nk_vec2 center, float radius, int a_min, int a_max)
    {
        int a = 0;
        assert(list);
        if (!list) return;
        if (a_min <= a_max) {
            for (a = a_min; a <= a_max; a++) {
                const(nk_vec2) c = list.circle_vtx[cast(nk_size)a % (list.circle_vtx.length)];
                const(float) x = center.x + c.x * radius;
                const(float) y = center.y + c.y * radius;
                nk_draw_list_path_line_to(list, nk_vec2(x, y));
            }
        }
    }
    void nk_draw_list_path_arc_to(nk_draw_list* list, nk_vec2 center, float radius, float a_min, float a_max, uint segments)
    {
        uint i = 0;
        assert(list);
        if (!list) return;
        if (radius == 0.0f) return;

        /*  This algorithm for arc drawing relies on these two trigonometric identities[1]:
                sin(a + b) = sin(a) * cos(b) + cos(a) * sin(b)
                cos(a + b) = cos(a) * cos(b) - sin(a) * sin(b)

            Two coordinates (x, y) of a point on a circle centered on
            the origin can be written in polar form as:
                x = r * cos(a)
                y = r * sin(a)
            where r is the radius of the circle,
                a is the angle between (x, y) and the origin.

            This allows us to rotate the coordinates around the
            origin by an angle b using the following transformation:
                x' = r * cos(a + b) = x * cos(b) - y * sin(b)
                y' = r * sin(a + b) = y * cos(b) + x * sin(b)

            [1] https://en.wikipedia.org/wiki/List_of_trigonometric_identities#Angle_sum_and_difference_identities
        */
        {const(float) d_angle = (a_max - a_min) / cast(float)segments;
        const(float) sin_d = cast(float)nk_sin(d_angle);
        const(float) cos_d = cast(float)nk_cos(d_angle);

        float cx = cast(float)nk_cos(a_min) * radius;
        float cy = cast(float)nk_sin(a_min) * radius;
        for(i = 0; i <= segments; ++i) {
            float new_cx = void, new_cy = void;
            const(float) x = center.x + cx;
            const(float) y = center.y + cy;
            nk_draw_list_path_line_to(list, nk_vec2(x, y));

            new_cx = cx * cos_d - cy * sin_d;
            new_cy = cy * cos_d + cx * sin_d;
            cx = new_cx;
            cy = new_cy;
        }}
    }
    void nk_draw_list_path_rect_to(nk_draw_list* list, nk_vec2 a, nk_vec2 b, float rounding)
    {
        float r = void;
        assert(list);
        if (!list) return;
        r = rounding;
        r = nk_min(r, ((b.x-a.x) < 0) ? -(b.x-a.x): (b.x-a.x));
        r = nk_min(r, ((b.y-a.y) < 0) ? -(b.y-a.y): (b.y-a.y));

        if (r == 0.0f) {
            nk_draw_list_path_line_to(list, a);
            nk_draw_list_path_line_to(list, nk_vec2(b.x,a.y));
            nk_draw_list_path_line_to(list, b);
            nk_draw_list_path_line_to(list, nk_vec2(a.x,b.y));
        } else {
            nk_draw_list_path_arc_to_fast(list, nk_vec2(a.x + r, a.y + r), r, 6, 9);
            nk_draw_list_path_arc_to_fast(list, nk_vec2(b.x - r, a.y + r), r, 9, 12);
            nk_draw_list_path_arc_to_fast(list, nk_vec2(b.x - r, b.y - r), r, 0, 3);
            nk_draw_list_path_arc_to_fast(list, nk_vec2(a.x + r, b.y - r), r, 3, 6);
        }
    }
    void nk_draw_list_path_curve_to(nk_draw_list* list, nk_vec2 p2, nk_vec2 p3, nk_vec2 p4, uint num_segments)
    {
        float t_step = void;
        uint i_step = void;
        nk_vec2 p1 = void;

        assert(list);
        assert(list.path_count);
        if (!list || !list.path_count) return;
        num_segments = nk_max(num_segments, 1);

        p1 = nk_draw_list_path_last(list);
        t_step = 1.0f/cast(float)num_segments;
        for (i_step = 1; i_step <= num_segments; ++i_step) {
            float t = t_step * cast(float)i_step;
            float u = 1.0f - t;
            float w1 = u*u*u;
            float w2 = 3*u*u*t;
            float w3 = 3*u*t*t;
            float w4 = t * t *t;
            float x = w1 * p1.x + w2 * p2.x + w3 * p3.x + w4 * p4.x;
            float y = w1 * p1.y + w2 * p2.y + w3 * p3.y + w4 * p4.y;
            nk_draw_list_path_line_to(list, nk_vec2(x,y));
        }
    }
    void nk_draw_list_path_fill(nk_draw_list* list, nk_color color)
    {
        nk_vec2* points = void;
        assert(list);
        if (!list) return;
        points = cast(nk_vec2*)nk_buffer_memory(list.buffer);
        nk_draw_list_fill_poly_convex(list, points, list.path_count, color, list.config.shape_AA);
        nk_draw_list_path_clear(list);
    }
    void nk_draw_list_path_stroke(nk_draw_list* list, nk_color color, nk_draw_list_stroke closed, float thickness)
    {
        nk_vec2* points = void;
        assert(list);
        if (!list) return;
        points = cast(nk_vec2*)nk_buffer_memory(list.buffer);
        nk_draw_list_stroke_poly_line(list, points, list.path_count, color,
            closed, thickness, list.config.line_AA);
        nk_draw_list_path_clear(list);
    }
    void nk_draw_list_stroke_line(nk_draw_list* list, nk_vec2 a, nk_vec2 b, nk_color col, float thickness)
    {
        assert(list);
        if (!list || !col.a) return;
        if (list.line_AA == NK_ANTI_ALIASING_ON) {
            nk_draw_list_path_line_to(list, a);
            nk_draw_list_path_line_to(list, b);
        } else {
            nk_draw_list_path_line_to(list, nk_vec2_sub(a,nk_vec2(0.5f,0.5f)));
            nk_draw_list_path_line_to(list, nk_vec2_sub(b,nk_vec2(0.5f,0.5f)));
        }
        nk_draw_list_path_stroke(list,  col, NK_STROKE_OPEN, thickness);
    }
    void nk_draw_list_fill_rect(nk_draw_list* list, nk_rect rect, nk_color col, float rounding)
    {
        assert(list);
        if (!list || !col.a) return;

        if (list.line_AA == NK_ANTI_ALIASING_ON) {
            nk_draw_list_path_rect_to(list, nk_vec2(rect.x, rect.y),
                nk_vec2(rect.x + rect.w, rect.y + rect.h), rounding);
        } else {
            nk_draw_list_path_rect_to(list, nk_vec2(rect.x-0.5f, rect.y-0.5f),
                nk_vec2(rect.x + rect.w, rect.y + rect.h), rounding);
        } nk_draw_list_path_fill(list,  col);
    }
    void nk_draw_list_stroke_rect(nk_draw_list* list, nk_rect rect, nk_color col, float rounding, float thickness)
    {
        assert(list);
        if (!list || !col.a) return;
        if (list.line_AA == NK_ANTI_ALIASING_ON) {
            nk_draw_list_path_rect_to(list, nk_vec2(rect.x, rect.y),
                nk_vec2(rect.x + rect.w, rect.y + rect.h), rounding);
        } else {
            nk_draw_list_path_rect_to(list, nk_vec2(rect.x-0.5f, rect.y-0.5f),
                nk_vec2(rect.x + rect.w, rect.y + rect.h), rounding);
        } nk_draw_list_path_stroke(list,  col, NK_STROKE_CLOSED, thickness);
    }
    void nk_draw_list_fill_rect_multi_color(nk_draw_list* list, nk_rect rect, nk_color left, nk_color top, nk_color right, nk_color bottom)
    {
        void* vtx = void;
        nk_colorf col_left = void, col_top = void;
        nk_colorf col_right = void, col_bottom = void;
        nk_draw_index* idx = void;
        nk_draw_index index = void;

        nk_color_fv(&col_left.r, left);
        nk_color_fv(&col_right.r, right);
        nk_color_fv(&col_top.r, top);
        nk_color_fv(&col_bottom.r, bottom);

        assert(list);
        if (!list) return;

        nk_draw_list_push_image(list, list.config.tex_null.texture);
        index = cast(nk_draw_index)list.vertex_count;
        vtx = nk_draw_list_alloc_vertices(list, 4);
        idx = nk_draw_list_alloc_elements(list, 6);
        if (!vtx || !idx) return;

        idx[0] = cast(nk_draw_index)(index+0); idx[1] = cast(nk_draw_index)(index+1);
        idx[2] = cast(nk_draw_index)(index+2); idx[3] = cast(nk_draw_index)(index+0);
        idx[4] = cast(nk_draw_index)(index+2); idx[5] = cast(nk_draw_index)(index+3);

        vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(rect.x, rect.y), list.config.tex_null.uv, col_left);
        vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(rect.x + rect.w, rect.y), list.config.tex_null.uv, col_top);
        vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(rect.x + rect.w, rect.y + rect.h), list.config.tex_null.uv, col_right);
        vtx = nk_draw_vertex(vtx, &list.config, nk_vec2(rect.x, rect.y + rect.h), list.config.tex_null.uv, col_bottom);
    }
    void nk_draw_list_fill_triangle(nk_draw_list* list, nk_vec2 a, nk_vec2 b, nk_vec2 c, nk_color col)
    {
        assert(list);
        if (!list || !col.a) return;
        nk_draw_list_path_line_to(list, a);
        nk_draw_list_path_line_to(list, b);
        nk_draw_list_path_line_to(list, c);
        nk_draw_list_path_fill(list, col);
    }
    void nk_draw_list_stroke_triangle(nk_draw_list* list, nk_vec2 a, nk_vec2 b, nk_vec2 c, nk_color col, float thickness)
    {
        assert(list);
        if (!list || !col.a) return;
        nk_draw_list_path_line_to(list, a);
        nk_draw_list_path_line_to(list, b);
        nk_draw_list_path_line_to(list, c);
        nk_draw_list_path_stroke(list, col, NK_STROKE_CLOSED, thickness);
    }
    void nk_draw_list_fill_circle(nk_draw_list* list, nk_vec2 center, float radius, nk_color col, uint segs)
    {
        float a_max = void;
        assert(list);
        if (!list || !col.a) return;
        a_max = NK_PI * 2.0f * (cast(float)segs - 1.0f) / cast(float)segs;
        nk_draw_list_path_arc_to(list, center, radius, 0.0f, a_max, segs);
        nk_draw_list_path_fill(list, col);
    }
    void nk_draw_list_stroke_circle(nk_draw_list* list, nk_vec2 center, float radius, nk_color col, uint segs, float thickness)
    {
        float a_max = void;
        assert(list);
        if (!list || !col.a) return;
        a_max = NK_PI * 2.0f * (cast(float)segs - 1.0f) / cast(float)segs;
        nk_draw_list_path_arc_to(list, center, radius, 0.0f, a_max, segs);
        nk_draw_list_path_stroke(list, col, NK_STROKE_CLOSED, thickness);
    }
    void nk_draw_list_stroke_curve(nk_draw_list* list, nk_vec2 p0, nk_vec2 cp0, nk_vec2 cp1, nk_vec2 p1, nk_color col, uint segments, float thickness)
    {
        assert(list);
        if (!list || !col.a) return;
        nk_draw_list_path_line_to(list, p0);
        nk_draw_list_path_curve_to(list, cp0, cp1, p1, segments);
        nk_draw_list_path_stroke(list, col, NK_STROKE_OPEN, thickness);
    }
    void nk_draw_list_push_rect_uv(nk_draw_list* list, nk_vec2 a, nk_vec2 c, nk_vec2 uva, nk_vec2 uvc, nk_color color)
    {
        void* vtx = void;
        nk_vec2 uvb = void;
        nk_vec2 uvd = void;
        nk_vec2 b = void;
        nk_vec2 d = void;

        nk_colorf col = void;
        nk_draw_index* idx = void;
        nk_draw_index index = void;
        assert(list);
        if (!list) return;

        nk_color_fv(&col.r, color);
        uvb = nk_vec2(uvc.x, uva.y);
        uvd = nk_vec2(uva.x, uvc.y);
        b = nk_vec2(c.x, a.y);
        d = nk_vec2(a.x, c.y);

        index = cast(nk_draw_index)list.vertex_count;
        vtx = nk_draw_list_alloc_vertices(list, 4);
        idx = nk_draw_list_alloc_elements(list, 6);
        if (!vtx || !idx) return;

        idx[0] = cast(nk_draw_index)(index+0); idx[1] = cast(nk_draw_index)(index+1);
        idx[2] = cast(nk_draw_index)(index+2); idx[3] = cast(nk_draw_index)(index+0);
        idx[4] = cast(nk_draw_index)(index+2); idx[5] = cast(nk_draw_index)(index+3);

        vtx = nk_draw_vertex(vtx, &list.config, a, uva, col);
        vtx = nk_draw_vertex(vtx, &list.config, b, uvb, col);
        vtx = nk_draw_vertex(vtx, &list.config, c, uvc, col);
        vtx = nk_draw_vertex(vtx, &list.config, d, uvd, col);
    }
    void nk_draw_list_add_image(nk_draw_list* list, nk_image texture, nk_rect rect, nk_color color)
    {
        assert(list);
        if (!list) return;
        /* push new command with given texture */
        nk_draw_list_push_image(list, texture.handle);
        if (nk_image_is_subimage(&texture)) {
            /* add region inside of the texture  */
            nk_vec2[2] uv = void;
            uv[0].x = cast(float)texture.region[0]/cast(float)texture.w;
            uv[0].y = cast(float)texture.region[1]/cast(float)texture.h;
            uv[1].x = cast(float)(texture.region[0] + texture.region[2])/cast(float)texture.w;
            uv[1].y = cast(float)(texture.region[1] + texture.region[3])/cast(float)texture.h;
            nk_draw_list_push_rect_uv(list, nk_vec2(rect.x, rect.y),
                nk_vec2(rect.x + rect.w, rect.y + rect.h),  uv[0], uv[1], color);
        } else nk_draw_list_push_rect_uv(list, nk_vec2(rect.x, rect.y),
                nk_vec2(rect.x + rect.w, rect.y + rect.h),
                nk_vec2(0.0f, 0.0f), nk_vec2(1.0f, 1.0f),color);
    }
    void nk_draw_list_add_text(nk_draw_list* list, const(nk_user_font)* font, nk_rect rect, const(char)* text, int len, float font_height, nk_color fg)
    {
        float x = 0;
        int text_len = 0;
        nk_rune unicode = 0;
        nk_rune next = 0;
        int glyph_len = 0;
        int next_glyph_len = 0;
        nk_user_font_glyph g = void;

        assert(list);
        if (!list || !len || !text) return;
        if (!nk_intersect(rect.x, rect.y, rect.w, rect.h,
            list.clip_rect.x, list.clip_rect.y, list.clip_rect.w, list.clip_rect.h)) return;

        nk_draw_list_push_image(list, cast(nk_handle)font.texture);
        x = rect.x;
        glyph_len = nk_utf_decode(text, &unicode, len);
        if (!glyph_len) return;

        /* draw every glyph image */
        fg.a = cast(nk_byte)(cast(float)fg.a * list.config.global_alpha);
        while (text_len < len && glyph_len) {
            float gx = void, gy = void, gh = void, gw = void;
            float char_width = 0;
            if (unicode == NK_UTF_INVALID) break;

            /* query currently drawn glyph information */
            next_glyph_len = nk_utf_decode(text + text_len + glyph_len, &next, cast(int)len - text_len);
            font.query(cast(nk_handle)font.userdata, font_height, &g, unicode,
                        (next == NK_UTF_INVALID) ? '\0' : next);

            /* calculate and draw glyph drawing rectangle and image */
            gx = x + g.offset.x;
            gy = rect.y + g.offset.y;
            gw = g.width; gh = g.height;
            char_width = g.xadvance;
            nk_draw_list_push_rect_uv(list, nk_vec2(gx,gy), nk_vec2(gx + gw, gy+ gh),
                g.uv[0], g.uv[1], fg);

            /* offset next glyph */
            text_len += glyph_len;
            x += char_width;
            glyph_len = next_glyph_len;
            unicode = next;
        }
    }
    nk_flags nk_convert(nk_context* ctx, nk_buffer* cmds, nk_buffer* vertices, nk_buffer* elements, const(nk_convert_config)* config)
    {
        nk_flags res = NK_CONVERT_SUCCESS;
        const(nk_command)* cmd = void;
        assert(ctx);
        assert(cmds);
        assert(vertices);
        assert(elements);
        assert(config);
        assert(config.vertex_layout);
        assert(config.vertex_size);
        if (!ctx || !cmds || !vertices || !elements || !config || !config.vertex_layout)
            return NK_CONVERT_INVALID_PARAM;

        nk_draw_list_setup(&ctx.draw_list, config, cmds, vertices, elements,
            config.line_AA, config.shape_AA);
        for((cmd) = nk__begin(ctx); (cmd) != null; (cmd) = nk__next(ctx,cmd))
        {
            version (NK_INCLUDE_COMMAND_USERDATA) {
                    ctx.draw_list.userdata = cmd.userdata;
            }
            switch (cmd.type) {
            case NK_COMMAND_NOP: break;
            case NK_COMMAND_SCISSOR: {
                const(nk_command_scissor)* s = cast(const(nk_command_scissor)*)cmd;
                nk_draw_list_add_clip(&ctx.draw_list, nk_rect(s.x, s.y, s.w, s.h));
            } break;
            case NK_COMMAND_LINE: {
                const(nk_command_line)* l = cast(const(nk_command_line)*)cmd;
                nk_draw_list_stroke_line(&ctx.draw_list, nk_vec2(l.begin.x, l.begin.y),
                    nk_vec2(l.end.x, l.end.y), l.color, l.line_thickness);
            } break;
            case NK_COMMAND_CURVE: {
                const(nk_command_curve)* q = cast(const(nk_command_curve)*)cmd;
                nk_draw_list_stroke_curve(&ctx.draw_list, nk_vec2(q.begin.x, q.begin.y),
                    nk_vec2(q.ctrl[0].x, q.ctrl[0].y), nk_vec2(q.ctrl[1].x,
                    q.ctrl[1].y), nk_vec2(q.end.x, q.end.y), q.color,
                    config.curve_segment_count, q.line_thickness);
            } break;
            case NK_COMMAND_RECT: {
                const(nk_command_rect)* r = cast(const(nk_command_rect)*)cmd;
                nk_draw_list_stroke_rect(&ctx.draw_list, nk_rect(r.x, r.y, r.w, r.h),
                    r.color, cast(float)r.rounding, r.line_thickness);
            } break;
            case NK_COMMAND_RECT_FILLED: {
                const(nk_command_rect_filled)* r = cast(const(nk_command_rect_filled)*)cmd;
                nk_draw_list_fill_rect(&ctx.draw_list, nk_rect(r.x, r.y, r.w, r.h),
                    r.color, cast(float)r.rounding);
            } break;
            case NK_COMMAND_RECT_MULTI_COLOR: {
                const(nk_command_rect_multi_color)* r = cast(const(nk_command_rect_multi_color)*)cmd;
                nk_draw_list_fill_rect_multi_color(&ctx.draw_list, nk_rect(r.x, r.y, r.w, r.h),
                    r.left, r.top, r.right, r.bottom);
            } break;
            case NK_COMMAND_CIRCLE: {
                const(nk_command_circle)* c = cast(const(nk_command_circle)*)cmd;
                nk_draw_list_stroke_circle(&ctx.draw_list, nk_vec2(cast(float)c.x + cast(float)c.w/2,
                    cast(float)c.y + cast(float)c.h/2), cast(float)c.w/2, c.color,
                    config.circle_segment_count, c.line_thickness);
            } break;
            case NK_COMMAND_CIRCLE_FILLED: {
                const(nk_command_circle_filled)* c = cast(const(nk_command_circle_filled)*)cmd;
                nk_draw_list_fill_circle(&ctx.draw_list, nk_vec2(cast(float)c.x + cast(float)c.w/2,
                    cast(float)c.y + cast(float)c.h/2), cast(float)c.w/2, c.color,
                    config.circle_segment_count);
            } break;
            case NK_COMMAND_ARC: {
                const(nk_command_arc)* c = cast(const(nk_command_arc)*)cmd;
                nk_draw_list_path_line_to(&ctx.draw_list, nk_vec2(c.cx, c.cy));
                nk_draw_list_path_arc_to(&ctx.draw_list, nk_vec2(c.cx, c.cy), c.r,
                    c.a[0], c.a[1], config.arc_segment_count);
                nk_draw_list_path_stroke(&ctx.draw_list, c.color, NK_STROKE_CLOSED, c.line_thickness);
            } break;
            case NK_COMMAND_ARC_FILLED: {
                const(nk_command_arc_filled)* c = cast(const(nk_command_arc_filled)*)cmd;
                nk_draw_list_path_line_to(&ctx.draw_list, nk_vec2(c.cx, c.cy));
                nk_draw_list_path_arc_to(&ctx.draw_list, nk_vec2(c.cx, c.cy), c.r,
                    c.a[0], c.a[1], config.arc_segment_count);
                nk_draw_list_path_fill(&ctx.draw_list, c.color);
            } break;
            case NK_COMMAND_TRIANGLE: {
                const(nk_command_triangle)* t = cast(const(nk_command_triangle)*)cmd;
                nk_draw_list_stroke_triangle(&ctx.draw_list, nk_vec2(t.a.x, t.a.y),
                    nk_vec2(t.b.x, t.b.y), nk_vec2(t.c.x, t.c.y), t.color,
                    t.line_thickness);
            } break;
            case NK_COMMAND_TRIANGLE_FILLED: {
                const(nk_command_triangle_filled)* t = cast(const(nk_command_triangle_filled)*)cmd;
                nk_draw_list_fill_triangle(&ctx.draw_list, nk_vec2(t.a.x, t.a.y),
                    nk_vec2(t.b.x, t.b.y), nk_vec2(t.c.x, t.c.y), t.color);
            } break;
            case NK_COMMAND_POLYGON: {
                int i = void;
                const(nk_command_polygon)* p = cast(const(nk_command_polygon)*)cmd;
                for (i = 0; i < p.point_count; ++i) {
                    nk_vec2 pnt = nk_vec2(cast(float)p.points[i].x, cast(float)p.points[i].y);
                    nk_draw_list_path_line_to(&ctx.draw_list, pnt);
                }
                nk_draw_list_path_stroke(&ctx.draw_list, p.color, NK_STROKE_CLOSED, p.line_thickness);
            } break;
            case NK_COMMAND_POLYGON_FILLED: {
                int i = void;
                const(nk_command_polygon_filled)* p = cast(const(nk_command_polygon_filled)*)cmd;
                for (i = 0; i < p.point_count; ++i) {
                    nk_vec2 pnt = nk_vec2(cast(float)p.points[i].x, cast(float)p.points[i].y);
                    nk_draw_list_path_line_to(&ctx.draw_list, pnt);
                }
                nk_draw_list_path_fill(&ctx.draw_list, p.color);
            } break;
            case NK_COMMAND_POLYLINE: {
                int i = void;
                const(nk_command_polyline)* p = cast(const(nk_command_polyline)*)cmd;
                for (i = 0; i < p.point_count; ++i) {
                    nk_vec2 pnt = nk_vec2(cast(float)p.points[i].x, cast(float)p.points[i].y);
                    nk_draw_list_path_line_to(&ctx.draw_list, pnt);
                }
                nk_draw_list_path_stroke(&ctx.draw_list, p.color, NK_STROKE_OPEN, p.line_thickness);
            } break;
            case NK_COMMAND_TEXT: {
                const(nk_command_text)* t = cast(const(nk_command_text)*)cmd;
                nk_draw_list_add_text(&ctx.draw_list, t.font, nk_rect(t.x, t.y, t.w, t.h),
                    t.string.ptr, t.length, t.height, t.foreground);
            } break;
            case NK_COMMAND_IMAGE: {
                const(nk_command_image)* i = cast(const(nk_command_image)*)cmd;
                nk_draw_list_add_image(&ctx.draw_list, cast(nk_image)i.img, nk_rect(i.x, i.y, i.w, i.h), i.col);
            } break;
            case NK_COMMAND_CUSTOM: {
                const(nk_command_custom)* c = cast(const(nk_command_custom)*)cmd;
                c.callback(&ctx.draw_list, c.x, c.y, c.w, c.h, cast(nk_handle)c.callback_data);
            } break;
            default: break;
            }
        }
        res |= (cmds.needed > cmds.allocated + (cmds.memory.size - cmds.size)) ? NK_CONVERT_COMMAND_BUFFER_FULL: 0;
        res |= (vertices.needed > vertices.allocated) ? NK_CONVERT_VERTEX_BUFFER_FULL: 0;
        res |= (elements.needed > elements.allocated) ? NK_CONVERT_ELEMENT_BUFFER_FULL: 0;
        return res;
    }
    const(nk_draw_command)* nk__draw_begin(const(nk_context)* ctx, const(nk_buffer)* buffer)
    {
        return nk__draw_list_begin(&ctx.draw_list, buffer);
    }
    const(nk_draw_command)* nk__draw_end(const(nk_context)* ctx, const(nk_buffer)* buffer)
    {
        return nk__draw_list_end(&ctx.draw_list, buffer);
    }
    const(nk_draw_command)* nk__draw_next(const(nk_draw_command)* cmd, const(nk_buffer)* buffer, const(nk_context)* ctx)
    {
        return nk__draw_list_next(cmd, buffer, &ctx.draw_list);
    }
}

