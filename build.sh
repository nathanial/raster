#!/bin/bash
# Build Raster with stb headers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

STB_DIR="native/stb"

# Download stb headers if not present
if [ ! -f "$STB_DIR/stb_image.h" ]; then
    echo "Downloading stb headers..."
    mkdir -p "$STB_DIR"

    STB_BASE="https://raw.githubusercontent.com/nothings/stb/master"

    curl -L -o "$STB_DIR/stb_image.h" "$STB_BASE/stb_image.h"
    curl -L -o "$STB_DIR/stb_image_write.h" "$STB_BASE/stb_image_write.h"
    curl -L -o "$STB_DIR/stb_image_resize2.h" "$STB_BASE/stb_image_resize2.h"

    echo "stb headers downloaded!"
fi

# Build the specified target
TARGET="${1:-Raster}"

echo "Building $TARGET..."
lake build "$TARGET"

if [ "$TARGET" = "Raster" ]; then
    echo "Building raster_native..."
    lake build raster_native
fi

echo "Build complete!"
