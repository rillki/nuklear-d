# nuklear-d
This project provides D static bindings to Nuklear GUI library.

### Library
Add library to your project using DUB:
```
dub add nuklear-d
```
At this point, you can safely build your project. No more configurations are needed, if your goal is to get it running quickly. `nuklear-d` has pre-configured flags enabled to allow for most common functionality. In case you would like to tinker, read below.

### Configuration flags
By default `nuklear-d` uses the following set of flags:
```
"versions": [
    "NK_INCLUDE_FIXED_TYPES",
    "NK_INCLUDE_STANDARD_IO",
    "NK_INCLUDE_STANDARD_VARARGS",
    "NK_INCLUDE_DEFAULT_ALLOCATOR",
    "NK_INCLUDE_VERTEX_BUFFER_OUTPUT",
    "NK_INCLUDE_FONT_BAKING",
    "NK_INCLUDE_DEFAULT_FONT",
    "NK_KEYSTATE_BASED_INPUT"
]
```

Here is the full list available flags:
```
NK_INCLUDE_FIXED_TYPES
NK_INCLUDE_DEFAULT_ALLOCATOR
NK_INCLUDE_STANDARD_IO
NK_INCLUDE_STANDARD_VARARGS
NK_INCLUDE_VERTEX_BUFFER_OUTPUT
NK_INCLUDE_FONT_BAKING
NK_INCLUDE_DEFAULT_FONT
NK_INCLUDE_COMMAND_USERDATA
NK_BUTTON_TRIGGER_ON_RELEASE
NK_ZERO_COMMAND_MEMORY
NK_UINT_DRAW_INDEX
```

### Modifying configuration flags
To modify the configuration flags, follow these 3 steps:

1. `git clone https://github.com/rillki/nuklear-d.git`
2. Modify `dub.{json, sdl}` configuation flags.
3. Modify  `c/nuklear.c` configuration flags.
4. Execute `build_nuklear_static.{sh, bat}` to build the static library with your custom flags enabled.
5. Inside your project's `dub.{json, sdl}` find the `dependencies` section and modify:
```
"dependencies": {
    // change this
    "nuklear-d": "version",

    // to this
    "nuklear-d": {"path": "path_to_nuklear_d"}
},
```

That's it. 

**NOTE**: You can also work inside `nuklear-d`. In this case, skip step 5.

## LICENSE
This code is using the Public Domain license as suggested by [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear/blob/master/src/LICENSE).


