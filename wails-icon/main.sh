#!/bin/bash
set -e

INPUT_IMAGE="$1"
PROJECT_PATH="${2:-.}"

# macOS App Store requires 1024x1024
OUTPUT_SIZE=1024
RADIUS=150  # ~15% of 1024 for macOS style

if [ -z "$INPUT_IMAGE" ]; then
    echo "Usage: wails-icon <input-image> [project-path]"
    exit 1
fi

if [ ! -f "$INPUT_IMAGE" ]; then
    echo "Error: Input image not found: $INPUT_IMAGE"
    exit 1
fi

if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick not found. Install with: brew install imagemagick"
    exit 1
fi

cd "$PROJECT_PATH"

# Get image dimensions
WIDTH=$(magick "$INPUT_IMAGE" -format "%w" info:)
HEIGHT=$(magick "$INPUT_IMAGE" -format "%h" info:)

# Calculate square crop size (smaller dimension)
if [ "$WIDTH" -lt "$HEIGHT" ]; then
    CROP_SIZE=$WIDTH
else
    CROP_SIZE=$HEIGHT
fi

echo "Processing: $INPUT_IMAGE (${WIDTH}x${HEIGHT})"
echo "→ Crop to square: ${CROP_SIZE}x${CROP_SIZE}"
echo "→ Scale to: ${OUTPUT_SIZE}x${OUTPUT_SIZE} (macOS App Store)"
echo "→ Corner radius: ${RADIUS}px"

# 1. Crop to square from center, resize to 1024x1024, apply rounded corners with transparency
magick "$INPUT_IMAGE" \
    -gravity center -crop "${CROP_SIZE}x${CROP_SIZE}+0+0" +repage \
    -resize "${OUTPUT_SIZE}x${OUTPUT_SIZE}" \
    \( -size "${OUTPUT_SIZE}x${OUTPUT_SIZE}" xc:black -fill white \
       -draw "roundrectangle 0,0 ${OUTPUT_SIZE},${OUTPUT_SIZE} ${RADIUS},${RADIUS}" \) \
    -alpha Off -compose CopyOpacity -composite -alpha On \
    PNG32:build/appicon.png

# 2. Generate Windows ICO with multiple sizes
magick build/appicon.png \
    -define icon:auto-resize=256,128,64,48,32,16 \
    build/windows/icon.ico

echo "✓ Generated build/appicon.png (${OUTPUT_SIZE}x${OUTPUT_SIZE}, rounded corners)"
echo "✓ Generated build/windows/icon.ico (multi-size)"
