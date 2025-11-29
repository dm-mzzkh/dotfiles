#!/bin/bash

# MP4 to GIF Converter
# Converts MP4 videos to high-quality GIFs using FFmpeg's palette generation technique
# Created by: Feng Pan (https://github.com/pflovv)

# Default directories
INPUT_DIR="./input/"
OUTPUT_DIR="./output/"
FPS=24
SCALE="iw:ih"  # Original size by default

# Function to display usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -i, --input DIR    Set input directory (default: ./input/)"
    echo "  -o, --output DIR   Set output directory (default: ./output/)"
    echo "  -f, --fps NUM      Set frames per second (default: 24)"
    echo "  -s, --scale VAL    Set scale (default: original size, example: 320:-1)"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -i ~/videos/ -o ~/gifs/ -f 15 -s 480:-1"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            INPUT_DIR="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--fps)
            FPS="$2"
            shift 2
            ;;
        -s|--scale)
            SCALE="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Ensure directories have trailing slashes
[[ "${INPUT_DIR}" != */ ]] && INPUT_DIR="${INPUT_DIR}/"
[[ "${OUTPUT_DIR}" != */ ]] && OUTPUT_DIR="${OUTPUT_DIR}/"

# Verify FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: FFmpeg is not installed. Please install FFmpeg and try again."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Check if input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist."
    exit 1
fi

# Check if there are MP4 files to process
mp4_count=$(find "$INPUT_DIR" -name "*.mp4" | wc -l)
if [ "$mp4_count" -eq 0 ]; then
    echo "No MP4 files found in '$INPUT_DIR'"
    exit 0
fi

echo "Starting conversion of $mp4_count MP4 files..."
echo "Settings: FPS=$FPS, Scale=$SCALE"

# Counter for progress tracking
current=0
total=$mp4_count

# Loop over all MP4 files in the input directory
for file in "$INPUT_DIR"*.mp4; do
    # Skip if no files match the pattern
    [ -e "$file" ] || continue
    
    # Get the base name of the file without the extension
    base_name=$(basename "$file" .mp4)
    current=$((current + 1))
    
    echo "[$current/$total] Converting: $base_name.mp4"
    
    # Temporary palette file
    palette="${OUTPUT_DIR}${base_name}_palette.png"

    # Generate a palette
    if ! ffmpeg -i "$file" -vf "fps=$FPS,scale=$SCALE:flags=lanczos,palettegen" -y "$palette" 2>/dev/null; then
        echo "  Error generating palette for $base_name.mp4"
        continue
    fi

    # Use the palette to create a high-quality GIF
    if ! ffmpeg -i "$file" -i "$palette" -lavfi "fps=$FPS,scale=$SCALE:flags=lanczos [x]; [x][1:v] paletteuse=dither=bayer" -y "${OUTPUT_DIR}${base_name}.gif" 2>/dev/null; then
        echo "  Error creating GIF for $base_name.mp4"
        rm -f "$palette"
        continue
    fi

    # Get file sizes for comparison
    mp4_size=$(du -h "$file" | cut -f1)
    gif_size=$(du -h "${OUTPUT_DIR}${base_name}.gif" | cut -f1)
    
    echo "  Completed: $base_name.mp4 ($mp4_size) → $base_name.gif ($gif_size)"
    
    # Remove temporary palette file
    rm -f "$palette"
done

echo "Conversion completed! All GIFs saved to $OUTPUT_DIR"
