@echo off

SET "LIB_DIR=%CD%\..\lib\windows_x64"

echo "Compiling Nuklear."
gcc "-c" "nuklear.c" "-o" "nuklear.o"
echo "Building Nuklear static library."
ar "rcs" "libnuklear.a" "nuklear.o"
echo "Copying Nuklear to %LIB_DIR%"
COPY  "libnuklear.a" "%LIB_DIR%/"
echo "Done."