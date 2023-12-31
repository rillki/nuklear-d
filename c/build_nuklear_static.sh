#!/bin/bash

LIB_DIR="../lib"

# check if directory exists
if [ ! -d "$LIB_DIR" ]; then
    echo "Creating lib/ directory."
    mkdir -p ../lib/osx ../lib/linux ../lib/windows_x64
else
    exit 0
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LIB_DIR="../lib/linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    LIB_DIR="../lib/osx"
elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    LIB_DIR="../lib/windows_x64"
else
    echo "Error: uknown platform!"
fi

echo "Compiling Nuklear."
gcc -c nuklear.c -o nuklear.o -O2

echo "Building Nuklear static library."
ar rcs libnuklear.a nuklear.o 

echo "Copying Nuklear to $LIB_DIR"
cp libnuklear.a $LIB_DIR/

echo "Done."

