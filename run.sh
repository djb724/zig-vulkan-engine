#!/bin/bash

# Compile all GLSL shaders to SPIR-V using glslc
SHADER_DIR="shaders"
OUTPUT_DIR="spv"

mkdir -p "$OUTPUT_DIR"

find "$SHADER_DIR" -type f \( -name "*.vert" -o -name "*.frag" -o -name "*.comp" -o -name "*.geom" -o -name "*.tesc" -o -name "*.tese" -o -name "*.mesh" -o -name "*.task" -o -name "*.rgen" -o -name "*.rint" -o -name "*.rahit" -o -name "*.rchit" -o -name "*.rmiss" -o -name "*.rcall" \) | while read -r shader; do
    filename=$(basename "$shader")
    output="$OUTPUT_DIR/${filename}.spv"
    echo "Compiling $shader -> $output"
    if glslc "$shader" -o "$output"; then
        echo "  OK"
    else
        echo "  FAILED: $shader" >&2
    fi
done

zig build run
