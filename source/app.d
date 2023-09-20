module app;

extern(C) @nogc 
void error_callback(int e, const(char)* d) nothrow { 
    import core.stdc.stdio: printf; 
    printf("Error %d: %s\n", e, d); 
}

void main() {
    import std.stdio: writeln;
    import libloader;
    import bindbc.glfw;
    import bindbc.opengl;
    import nuklear;
    import nuklear.glew;

    // nuklear constants
    enum MAX_VERTEX_BUFFER = 512 * 1024;
    enum MAX_ELEMENT_BUFFER = 128 * 1024;

    // window constants
    enum wWidth = 720;
    enum wHeight = 420;
    enum wTitle = "D/GLFW/OpenGL project";

    // platform
    nk_glfw glfw;
    GLFWwindow* win;
    int width, height;
    nk_context* ctx;
    nk_colorf bg;

    // load GLFW
    if(!load_glfw()) {
        writeln("Failed to load GLFW library!");
        return;
    }

    // setup glfw
    glfwSetErrorCallback(&error_callback);
    if(!glfwInit()) {
        writeln("Failed to initialize GLFW library!");
        return;
    }
    scope(exit) { glfwTerminate(); }

    // --- 3. set default window hints and create an OpenGL context
    glfwWindowHint(GLFW_SAMPLES, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    version(OSX) {
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, true);
    }

    // create an actual window and attach current context
    win = glfwCreateWindow(wWidth, wHeight, wTitle, null, null);
    if(win is null) {
        writeln("Failed to create a GLFW window!");
        return;
    }
    scope(exit) { glfwDestroyWindow(win); win = null; }

    // attach current context to GLFW window
    glfwMakeContextCurrent(win);
    glfwGetWindowSize(win, &width, &height);

    // --- 3. load OpenGL library
    if(!load_opengl()) {        
        writeln("Failed to load OpenGL library!");
        return;
    }

    glViewport(0, 0, wWidth, wHeight);
    auto val = glewInit();
    if (val != GLEW_OK) {
        writeln( "Failed to setup GLEW: ", val);
        // return;
    }
    glfwSetInputMode(win, GLFW_STICKY_KEYS, true);
    glfwSwapInterval(1);

    ctx = nk_glfw3_init(&glfw, win, NK_GLFW3_INSTALL_CALLBACKS);
    scope(exit) { nk_glfw3_shutdown(&glfw); }
    {
        nk_font_atlas *atlas;
        nk_glfw3_font_stash_begin(&glfw, &atlas);
        /*struct nk_font *droid = nk_font_atlas_add_from_file(atlas, "../../../extra_font/DroidSans.ttf", 14, 0);*/
        nk_glfw3_font_stash_end(&glfw);
        /*nk_style_set_font(ctx, &droid->handle);*/
    }

    bg.r = 0.10f, bg.g = 0.18f, bg.b = 0.24f, bg.a = 1.0f;
    import std.string: toStringz;
    char[64] buffer = "hello, world";
    int buffer_len = cast(int)buffer.length;
    while(!glfwWindowShouldClose(win)) {
        // PROCESS EVENTS
        glfwPollEvents();
        if(glfwGetKey(win, GLFW_KEY_Q) == GLFW_PRESS) {
            break;
        }
        nk_glfw3_new_frame(&glfw);
        
        // GUI
        if (nk_begin(ctx, "Demo", nk_rect(50, 50, 230, 250), 
            NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_SCALABLE | NK_WINDOW_MINIMIZABLE | NK_WINDOW_TITLE)
        ) {
            enum {EASY, HARD}
            static int op = EASY;
            static int property = 20;
            nk_layout_row_static(ctx, 30, 80, 1);
            if (nk_button_label(ctx, "button"))
                writeln("button pressed");

            nk_layout_row_dynamic(ctx, 30, 2);
            if (nk_option_label(ctx, "easy", op == EASY)) op = EASY;
            if (nk_option_label(ctx, "hard", op == HARD)) op = HARD;

            nk_layout_row_dynamic(ctx, 25, 1);
            nk_property_int(ctx, "Compression:", 0, &property, 100, 10, 1);

            nk_layout_row_dynamic(ctx, 20, 1);
            nk_label(ctx, "background:", NK_TEXT_LEFT);
            nk_layout_row_dynamic(ctx, 25, 1);
            if (nk_combo_begin_color(ctx, nk_rgb_cf(bg), nk_vec2(nk_widget_width(ctx),400))) {
                nk_layout_row_dynamic(ctx, 120, 1);
                bg = nk_color_picker(ctx, bg, NK_RGBA);
                nk_layout_row_dynamic(ctx, 25, 1);
                bg.r = nk_propertyf(ctx, "#R:", 0, bg.r, 1.0f, 0.01f,0.005f);
                bg.g = nk_propertyf(ctx, "#G:", 0, bg.g, 1.0f, 0.01f,0.005f);
                bg.b = nk_propertyf(ctx, "#B:", 0, bg.b, 1.0f, 0.01f,0.005f);
                bg.a = nk_propertyf(ctx, "#A:", 0, bg.a, 1.0f, 0.01f,0.005f);
                nk_combo_end(ctx);
            }
        }
        nk_end(ctx);

        // render
        glfwGetWindowSize(win, &width, &height);
        glViewport(0, 0, width, height);
        glClear(GL_COLOR_BUFFER_BIT);
        glClearColor(bg.r, bg.g, bg.b, bg.a);
        nk_glfw3_render(&glfw, NK_ANTI_ALIASING_ON, MAX_VERTEX_BUFFER, MAX_ELEMENT_BUFFER);
        glfwSwapBuffers(win);
    }
}


