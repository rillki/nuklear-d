module libloader;
extern(C) @nogc nothrow:

import bindbc.glfw: GLFWSupport, loadGLFW, glfwSupport;
import bindbc.opengl: GLSupport, loadOpenGL;

import core.stdc.stdio: printf;

/++
    Loads a shared GLFW library

    Returns:
        `true` upon success, `false` otherwise
+/
bool load_glfw() {   
    // set default dll lookup path for Windows
    version(Windows) { 
        import bindbc.loader: setCustomLoaderSearchPath;
        setCustomLoaderSearchPath("libs"); 
    }

    // attempt to load GLFW
    auto ret = loadGLFW();
    if(ret != glfwSupport) {   
        printf(
            ret == GLFWSupport.noLibrary ? "No GLFW library found!\n" : 
            ret == GLFWSupport.badLibrary ? "A newer version of GLFW is needed. Please, upgrade!\n" : 
            "Unknown error! Could not load OpenGL library!\n"
        );
        return false;
    }
    printf("GLFW successfully loaded, version: %d\n", ret);
    
    return true;
}

/++ 
    Loads OpenGL library
    
    Returns:
        `true` upon success, `false` otherwise
+/
bool load_opengl() {
    auto ret = loadOpenGL();

    // error checking
    switch(ret) with(GLSupport) {
        case gl46:
        case gl45:
        case gl44:
        case gl43:
        case gl42:
        case gl41:
        case gl40:
        case gl33:
        case gl32:
        case gl31:
        case gl30:
            printf("OpenGL successfully loaded, version: %d\n", ret);
            return true;
        case badLibrary:
            printf("The version of the GLFW library on your system is too low. Please upgrade.\n");
            break;
        case noContext:
            printf("Create an OpenGL context before attempting to load OpenGL!\n");
            break;
        case noLibrary:
            printf("OpenGL library not found!");
            break;
        default:
            import bindbc.loader: errors;
            printf("Unknown error! Could not load OpenGL library! Error code: %d\n", ret);
            foreach(i, e; errors)
            {
                printf("%2zu: %s | %s\n", i, e.error, e.message);
            }
            break;
    }

    return false;
}



