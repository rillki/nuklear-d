module nuklear.glfw;

import core.stdc.string;
import core.stdc.stdlib;
import core.stdc.math;
import core.stdc.stdio;

import bindbc.glfw;
import bindbc.opengl;
import nuklear;

extern(C) nothrow:
__gshared:

enum nk_glfw_init_state {
    NK_GLFW3_DEFAULT = 0,
    NK_GLFW3_INSTALL_CALLBACKS
}
enum NK_GLFW3_DEFAULT = nk_glfw_init_state.NK_GLFW3_DEFAULT;
enum NK_GLFW3_INSTALL_CALLBACKS = nk_glfw_init_state.NK_GLFW3_INSTALL_CALLBACKS;

enum NK_GLFW_TEXT_MAX = 256;

struct nk_glfw_device {
    nk_buffer cmds;
    nk_draw_null_texture tex_null;
    GLuint vbo, vao, ebo;
    GLuint prog;
    GLuint vert_shdr;
    GLuint frag_shdr;
    GLint attrib_pos;
    GLint attrib_uv;
    GLint attrib_col;
    GLint uniform_tex;
    GLint uniform_proj;
    GLuint font_tex;
}

struct nk_glfw {
    GLFWwindow *win;
    int width, height;
    int display_width, display_height;
    nk_glfw_device ogl;
    nk_context ctx;
    nk_font_atlas atlas;
    nk_vec2 fb_scale;
    uint[NK_GLFW_TEXT_MAX] text;
    int text_len;
    nk_vec2 scroll;
    double last_button_click;
    int is_double_click_down;
    nk_vec2 double_click_pos;
}

enum NK_GLFW_DOUBLE_CLICK_LO = 0.02;
enum NK_GLFW_DOUBLE_CLICK_HI = 0.2;

struct nk_glfw_vertex {
    float[2] position;
    float[2] uv;
    nk_byte[4] col;
}

version(OSX) {
    enum NK_SHADER_VERSION = "#version 150\n";
} else {
    enum NK_SHADER_VERSION = "#version 300 es\n";
}

void nk_glfw3_device_create(nk_glfw* glfw)
{
    GLint status;
    version (OSX) {
        const(GLchar)* vertex_shader =
        q{
            #version 150
            uniform mat4 ProjMtx;
            in vec2 Position;
            in vec2 TexCoord;
            in vec4 Color;
            out vec2 Frag_UV;
            out vec4 Frag_Color;
            void main() {
                Frag_UV = TexCoord;
                Frag_Color = Color;
                gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
            }
        };

        const(GLchar)* fragment_shader =
        q{
            #version 150
            precision mediump float;
            uniform sampler2D Texture;
            in vec2 Frag_UV;
            in vec4 Frag_Color;
            out vec4 Out_Color;
            void main(){
                Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
            }
        };
    } else {
        const(GLchar)* vertex_shader =
        q{
            #version 300 es
            uniform mat4 ProjMtx;
            in vec2 Position;
            in vec2 TexCoord;
            in vec4 Color;
            out vec2 Frag_UV;
            out vec4 Frag_Color;
            void main() {
                Frag_UV = TexCoord;
                Frag_Color = Color;
                gl_Position = ProjMtx * vec4(Position.xy, 0, 1);
            }
        };

        const(GLchar)* fragment_shader =
        q{
            #version 300 es
            precision mediump float;
            uniform sampler2D Texture;
            in vec2 Frag_UV;
            in vec4 Frag_Color;
            out vec4 Out_Color;
            void main(){
                Out_Color = Frag_Color * texture(Texture, Frag_UV.st);
            }
        };
    }
    
    nk_glfw_device *dev = &glfw.ogl;
    nk_buffer_init_default(&dev.cmds);
    dev.prog = glCreateProgram();
    dev.vert_shdr = glCreateShader(GL_VERTEX_SHADER);
    dev.frag_shdr = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(dev.vert_shdr, 1, &vertex_shader, null);
    glShaderSource(dev.frag_shdr, 1, &fragment_shader, null);
    glCompileShader(dev.vert_shdr);
    glCompileShader(dev.frag_shdr);
    glGetShaderiv(dev.vert_shdr, GL_COMPILE_STATUS, &status);
    assert(status == GL_TRUE);
    glGetShaderiv(dev.frag_shdr, GL_COMPILE_STATUS, &status);
    assert(status == GL_TRUE);
    glAttachShader(dev.prog, dev.vert_shdr);
    glAttachShader(dev.prog, dev.frag_shdr);
    glLinkProgram(dev.prog);
    glGetProgramiv(dev.prog, GL_LINK_STATUS, &status);
    assert(status == GL_TRUE);

    dev.uniform_tex = glGetUniformLocation(dev.prog, "Texture");
    dev.uniform_proj = glGetUniformLocation(dev.prog, "ProjMtx");
    dev.attrib_pos = glGetAttribLocation(dev.prog, "Position");
    dev.attrib_uv = glGetAttribLocation(dev.prog, "TexCoord");
    dev.attrib_col = glGetAttribLocation(dev.prog, "Color");

    {
        /* buffer setup */
        GLsizei vs = nk_glfw_vertex.sizeof;
        size_t vp = nk_glfw_vertex.position.offsetof;
        size_t vt = nk_glfw_vertex.uv.offsetof;
        size_t vc = nk_glfw_vertex.col.offsetof;

        glGenBuffers(1, &dev.vbo);
        glGenBuffers(1, &dev.ebo);
        glGenVertexArrays(1, &dev.vao);
        
        glBindVertexArray(dev.vao);
        glBindBuffer(GL_ARRAY_BUFFER, dev.vbo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, dev.ebo);

        glEnableVertexAttribArray(cast(GLuint)dev.attrib_pos);
        glEnableVertexAttribArray(cast(GLuint)dev.attrib_uv);
        glEnableVertexAttribArray(cast(GLuint)dev.attrib_col);

        glVertexAttribPointer(cast(GLuint)dev.attrib_pos, 2, GL_FLOAT, GL_FALSE, vs, cast(void*)vp);
        glVertexAttribPointer(cast(GLuint)dev.attrib_uv, 2, GL_FLOAT, GL_FALSE, vs, cast(void*)vt);
        glVertexAttribPointer(cast(GLuint)dev.attrib_col, 4, GL_UNSIGNED_BYTE, GL_TRUE, vs, cast(void*)vc);
    }

    glBindTexture(GL_TEXTURE_2D, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

void nk_glfw3_device_upload_atlas(nk_glfw* glfw, const void *image, int width, int height)
{
    nk_glfw_device *dev = &glfw.ogl;
    glGenTextures(1, &dev.font_tex);
    glBindTexture(GL_TEXTURE_2D, dev.font_tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, cast(GLsizei)width, cast(GLsizei)height, 0,
                GL_RGBA, GL_UNSIGNED_BYTE, image);
}

void nk_glfw3_device_destroy(nk_glfw* glfw)
{
    nk_glfw_device *dev = &glfw.ogl;
    glDetachShader(dev.prog, dev.vert_shdr);
    glDetachShader(dev.prog, dev.frag_shdr);
    glDeleteShader(dev.vert_shdr);
    glDeleteShader(dev.frag_shdr);
    glDeleteProgram(dev.prog);
    glDeleteTextures(1, &dev.font_tex);
    glDeleteBuffers(1, &dev.vbo);
    glDeleteBuffers(1, &dev.ebo);
    nk_buffer_free(&dev.cmds);
}

void nk_glfw3_render(nk_glfw* glfw, nk_anti_aliasing AA, int max_vertex_buffer, int max_element_buffer)
{
    nk_glfw_device *dev = &glfw.ogl;
    nk_buffer vbuf, ebuf;
    GLfloat[4][4] ortho = [
        [2.0f, 0.0f, 0.0f, 0.0f],
        [0.0f,-2.0f, 0.0f, 0.0f],
        [0.0f, 0.0f,-1.0f, 0.0f],
        [-1.0f,1.0f, 0.0f, 1.0f],
    ];
    ortho[0][0] /= cast(GLfloat)glfw.width;
    ortho[1][1] /= cast(GLfloat)glfw.height;

    /* setup global state */
    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_CULL_FACE);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_SCISSOR_TEST);
    glActiveTexture(GL_TEXTURE0);

    /* setup program */
    glUseProgram(dev.prog);
    glUniform1i(dev.uniform_tex, 0);
    glUniformMatrix4fv(dev.uniform_proj, 1, GL_FALSE, &ortho[0][0]);
    glViewport(0, 0, cast(GLsizei)glfw.display_width, cast(GLsizei)glfw.display_height);
    {
        /* convert from command queue into draw list and draw to screen */
        const(nk_draw_command) *cmd = null;
        void* vertices, elements;
        nk_size offset = 0;

        /* allocate vertex and element buffer */
        glBindVertexArray(dev.vao);
        glBindBuffer(GL_ARRAY_BUFFER, dev.vbo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, dev.ebo);

        glBufferData(GL_ARRAY_BUFFER, max_vertex_buffer, null, GL_STREAM_DRAW);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, max_element_buffer, null, GL_STREAM_DRAW);

        /* load draw vertices & elements directly into vertex + element buffer */
        vertices = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
        elements = glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);
        {
            /* fill convert configuration */
            nk_convert_config config;
            static const(nk_draw_vertex_layout_element)[4] vertex_layout = [
                {NK_VERTEX_POSITION, NK_FORMAT_FLOAT, nk_glfw_vertex.position.offsetof},
                {NK_VERTEX_TEXCOORD, NK_FORMAT_FLOAT, nk_glfw_vertex.uv.offsetof},
                {NK_VERTEX_COLOR, NK_FORMAT_R8G8B8A8, nk_glfw_vertex.col.offsetof},
                NK_VERTEX_LAYOUT_END
            ];
            memset(&config, 0, config.sizeof);
            config.vertex_layout = vertex_layout.ptr;
            config.vertex_size = nk_glfw_vertex.sizeof;
            config.vertex_alignment = nk_glfw_vertex.alignof;
            config.tex_null = dev.tex_null;
            config.circle_segment_count = 22;
            config.curve_segment_count = 22;
            config.arc_segment_count = 22;
            config.global_alpha = 1.0f;
            config.shape_AA = AA;
            config.line_AA = AA;

            /* setup buffers to load vertices and elements */
            nk_buffer_init_fixed(&vbuf, vertices, cast(size_t)max_vertex_buffer);
            nk_buffer_init_fixed(&ebuf, elements, cast(size_t)max_element_buffer);
            nk_convert(&glfw.ctx, &dev.cmds, &vbuf, &ebuf, &config);
        }
        glUnmapBuffer(GL_ARRAY_BUFFER);
        glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

        /* iterate over and execute each draw command */
        nk_draw_foreach(&glfw.ctx, &dev.cmds, (cmd)
        {
            if (!cmd.elem_count) return;
            glBindTexture(GL_TEXTURE_2D, cast(GLuint)cmd.texture.id);
            glScissor(
                cast(GLint)(cmd.clip_rect.x * glfw.fb_scale.x),
                cast(GLint)((glfw.height - cast(GLint)(cmd.clip_rect.y + cmd.clip_rect.h)) * glfw.fb_scale.y),
                cast(GLint)(cmd.clip_rect.w * glfw.fb_scale.x),
                cast(GLint)(cmd.clip_rect.h * glfw.fb_scale.y));
            glDrawElements(GL_TRIANGLES, cast(GLsizei)cmd.elem_count, GL_UNSIGNED_SHORT, cast(const(void)*) offset);
            offset += cmd.elem_count * nk_draw_index.sizeof;
        });
        nk_clear(&glfw.ctx);
        nk_buffer_clear(&dev.cmds);
    }

    /* default OpenGL state */
    glUseProgram(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glDisable(GL_BLEND);
    glDisable(GL_SCISSOR_TEST);
}

void nk_glfw3_char_callback(GLFWwindow *win, uint codepoint)
{
    nk_glfw* glfw = cast(nk_glfw*)glfwGetWindowUserPointer(win);
    if (glfw.text_len < NK_GLFW_TEXT_MAX)
        glfw.text[glfw.text_len++] = codepoint;
}

void nk_gflw3_scroll_callback(GLFWwindow *win, double xoff, double yoff)
{
    nk_glfw* glfw = cast(nk_glfw*)glfwGetWindowUserPointer(win);
    cast(void)xoff;
    glfw.scroll.x += cast(float)xoff;
    glfw.scroll.y += cast(float)yoff;
}

void nk_glfw3_mouse_button_callback(GLFWwindow* win, int button, int action, int mods)
{
    nk_glfw* glfw = cast(nk_glfw*)glfwGetWindowUserPointer(win);
    double x, y;
    cast(void)mods;
    if (button != GLFW_MOUSE_BUTTON_LEFT) return;
    glfwGetCursorPos(win, &x, &y);
    if (action == GLFW_PRESS)  {
        double dt = glfwGetTime() - glfw.last_button_click;
        if (dt > NK_GLFW_DOUBLE_CLICK_LO && dt < NK_GLFW_DOUBLE_CLICK_HI) {
            glfw.is_double_click_down = nk_true;
            glfw.double_click_pos = nk_vec2(cast(float)x, cast(float)y);
        }
        glfw.last_button_click = glfwGetTime();
    } else glfw.is_double_click_down = nk_false;
}

@nogc
void nk_glfw3_clipboard_paste(nk_handle usr, nk_text_edit *edit)
{
    nk_glfw* glfw = cast(nk_glfw*)usr.ptr;
    const(char)* text = glfwGetClipboardString(glfw.win);
    if (text) nk_textedit_paste(edit, text, nk_strlen(text));
    cast(void)usr;
}

@nogc
void nk_glfw3_clipboard_copy(nk_handle usr, const char *text, int len) 
{
    nk_glfw* glfw = cast(nk_glfw*)usr.ptr;
    char* str = null;
    if (!len) return;
    str = cast(char*)malloc(cast(size_t)len+1);
    if (!str) return;
    memcpy(str, text, cast(size_t)len);
    str[len] = '\0';
    glfwSetClipboardString(glfw.win, str);
    free(str);
}

nk_context* nk_glfw3_init(nk_glfw* glfw, GLFWwindow *win, nk_glfw_init_state init_state)
{
    glfwSetWindowUserPointer(win, glfw);
    glfw.win = win;
    if (init_state == NK_GLFW3_INSTALL_CALLBACKS) {
        glfwSetScrollCallback(win, &nk_gflw3_scroll_callback);
        glfwSetCharCallback(win, &nk_glfw3_char_callback);
        glfwSetMouseButtonCallback(win, &nk_glfw3_mouse_button_callback);
    }
    nk_init_default(&glfw.ctx, null);
    glfw.ctx.clip.copy = &nk_glfw3_clipboard_copy;
    glfw.ctx.clip.paste = &nk_glfw3_clipboard_paste;
    glfw.ctx.clip.userdata = nk_handle_ptr(&glfw);
    glfw.last_button_click = 0;
    nk_glfw3_device_create(glfw);

    glfw.is_double_click_down = nk_false;
    glfw.double_click_pos = nk_vec2(0, 0);

    return &glfw.ctx;
}

void nk_glfw3_font_stash_begin(nk_glfw* glfw, nk_font_atlas **atlas)
{
    nk_font_atlas_init_default(&glfw.atlas);
    nk_font_atlas_begin(&glfw.atlas);
    *atlas = &glfw.atlas;
}

void nk_glfw3_font_stash_end(nk_glfw* glfw)
{
    const(void)* image; int w, h;
    image = nk_font_atlas_bake(&glfw.atlas, &w, &h, NK_FONT_ATLAS_RGBA32);
    nk_glfw3_device_upload_atlas(glfw, image, w, h);
    nk_font_atlas_end(&glfw.atlas, nk_handle_id(cast(int)glfw.ogl.font_tex), &glfw.ogl.tex_null);
    if (glfw.atlas.default_font)
        nk_style_set_font(&glfw.ctx, &glfw.atlas.default_font.handle);
}

void nk_glfw3_new_frame(nk_glfw* glfw)
{
    int i;
    double x, y;
    nk_context *ctx = &glfw.ctx;
    GLFWwindow *win = glfw.win;

    glfwGetWindowSize(win, &glfw.width, &glfw.height);
    glfwGetFramebufferSize(win, &glfw.display_width, &glfw.display_height);
    glfw.fb_scale.x = cast(float)glfw.display_width/cast(float)glfw.width;
    glfw.fb_scale.y = cast(float)glfw.display_height/cast(float)glfw.height;

    nk_input_begin(ctx);
    for (i = 0; i < glfw.text_len; ++i)
        nk_input_unicode(ctx, glfw.text[i]);

    version (NK_GLFW_GL3_MOUSE_GRABBING) {
        /* optional grabbing behavior */
        if (ctx.input.mouse.grab)
            glfwSetInputMode(glfw.win, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
        else if (ctx.input.mouse.ungrab)
            glfwSetInputMode(glfw.win, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
    }

    nk_input_key(ctx, NK_KEY_DEL, glfwGetKey(win, GLFW_KEY_DELETE) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_ENTER, glfwGetKey(win, GLFW_KEY_ENTER) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_TAB, glfwGetKey(win, GLFW_KEY_TAB) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_BACKSPACE, glfwGetKey(win, GLFW_KEY_BACKSPACE) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_UP, glfwGetKey(win, GLFW_KEY_UP) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_DOWN, glfwGetKey(win, GLFW_KEY_DOWN) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_TEXT_START, glfwGetKey(win, GLFW_KEY_HOME) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_TEXT_END, glfwGetKey(win, GLFW_KEY_END) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_SCROLL_START, glfwGetKey(win, GLFW_KEY_HOME) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_SCROLL_END, glfwGetKey(win, GLFW_KEY_END) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_SCROLL_DOWN, glfwGetKey(win, GLFW_KEY_PAGE_DOWN) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_SCROLL_UP, glfwGetKey(win, GLFW_KEY_PAGE_UP) == GLFW_PRESS);
    nk_input_key(ctx, NK_KEY_SHIFT, glfwGetKey(win, GLFW_KEY_LEFT_SHIFT) == GLFW_PRESS||
                                    glfwGetKey(win, GLFW_KEY_RIGHT_SHIFT) == GLFW_PRESS);

    if (glfwGetKey(win, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS ||
        glfwGetKey(win, GLFW_KEY_RIGHT_CONTROL) == GLFW_PRESS) {
        nk_input_key(ctx, NK_KEY_COPY, glfwGetKey(win, GLFW_KEY_C) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_PASTE, glfwGetKey(win, GLFW_KEY_V) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_CUT, glfwGetKey(win, GLFW_KEY_X) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_TEXT_UNDO, glfwGetKey(win, GLFW_KEY_Z) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_TEXT_REDO, glfwGetKey(win, GLFW_KEY_R) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_TEXT_WORD_LEFT, glfwGetKey(win, GLFW_KEY_LEFT) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_TEXT_WORD_RIGHT, glfwGetKey(win, GLFW_KEY_RIGHT) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_TEXT_LINE_START, glfwGetKey(win, GLFW_KEY_B) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_TEXT_LINE_END, glfwGetKey(win, GLFW_KEY_E) == GLFW_PRESS);
    } else {
        nk_input_key(ctx, NK_KEY_LEFT, glfwGetKey(win, GLFW_KEY_LEFT) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_RIGHT, glfwGetKey(win, GLFW_KEY_RIGHT) == GLFW_PRESS);
        nk_input_key(ctx, NK_KEY_COPY, 0);
        nk_input_key(ctx, NK_KEY_PASTE, 0);
        nk_input_key(ctx, NK_KEY_CUT, 0);
        nk_input_key(ctx, NK_KEY_SHIFT, 0);
    }

    glfwGetCursorPos(win, &x, &y);
    nk_input_motion(ctx, cast(int)x, cast(int)y);
    version (NK_GLFW_GL3_MOUSE_GRABBING) {
        if (ctx.input.mouse.grabbed) {
            glfwSetCursorPos(glfw.win, ctx.input.mouse.prev.x, ctx.input.mouse.prev.y);
            ctx.input.mouse.pos.x = ctx.input.mouse.prev.x;
            ctx.input.mouse.pos.y = ctx.input.mouse.prev.y;
        }
    }

    nk_input_button(ctx, NK_BUTTON_LEFT, cast(int)x, cast(int)y, glfwGetMouseButton(win, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS);
    nk_input_button(ctx, NK_BUTTON_MIDDLE, cast(int)x, cast(int)y, glfwGetMouseButton(win, GLFW_MOUSE_BUTTON_MIDDLE) == GLFW_PRESS);
    nk_input_button(ctx, NK_BUTTON_RIGHT, cast(int)x, cast(int)y, glfwGetMouseButton(win, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS);
    nk_input_button(ctx, NK_BUTTON_DOUBLE, cast(int)glfw.double_click_pos.x, cast(int)glfw.double_click_pos.y, cast(bool)glfw.is_double_click_down);
    nk_input_scroll(ctx, glfw.scroll);
    nk_input_end(&glfw.ctx);
    glfw.text_len = 0;
    glfw.scroll = nk_vec2(0,0);
}

void nk_glfw3_shutdown(nk_glfw* glfw)
{
    nk_font_atlas_clear(&glfw.atlas);
    nk_free(&glfw.ctx);
    nk_glfw3_device_destroy(glfw);
    memset(glfw, 0, nk_glfw.sizeof);
}









