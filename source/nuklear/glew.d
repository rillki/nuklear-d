module nuklear.glew;

import bindbc.opengl;

extern(C):
__gshared:

enum {
    GLEW_OK = 0,
}

GLenum glewInit();

