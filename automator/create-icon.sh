#!/usr/bin/env zsh
# Convert image to .icns format for AppleScript apps
# Usage: ./create-icon.sh <image-file> <app-name>
# Example: ./create-icon.sh ~/Downloads/icon.png relink

set -e

SCRIPT_DIR="${0:a:h}"
ICONS_DIR="${SCRIPT_DIR}/icons"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_error() {
	echo "${RED}✗ Error: ${NC}$1" >&2
}

print_success() {
	echo "${GREEN}✓ ${NC}$1"
}

print_info() {
	echo "${CYAN}ℹ ${NC}$1"
}

print_warning() {
	echo "${YELLOW}⚠ ${NC}$1"
}

# Check arguments
if [[ $# -lt 2 ]]; then
	print_error "Usage: $0 <image-file> <app-name>"
	echo ""
	echo "Examples:"
	echo "  $0 ~/Downloads/icon.png relink"
	echo "  $0 ./my-icon.png my-app"
	echo ""
	echo "The image file should be at least 1024x1024 pixels for best results."
	exit 1
fi

IMAGE_FILE="$1"
APP_NAME="$2"

# Validate image file exists
if [[ ! -f "$IMAGE_FILE" ]]; then
	print_error "Image file not found: $IMAGE_FILE"
	exit 1
fi

# Check if sips and iconutil are available
if ! command -v sips &> /dev/null; then
	print_error "sips command not found (required for macOS)"
	exit 1
fi

if ! command -v iconutil &> /dev/null; then
	print_error "iconutil command not found (required for macOS)"
	exit 1
fi

# Create icons directory if it doesn't exist
mkdir -p "$ICONS_DIR"

# Create temporary iconset directory
ICONSET_DIR="${SCRIPT_DIR}/.tmp/${APP_NAME}.iconset"
mkdir -p "$ICONSET_DIR"

print_info "Converting $IMAGE_FILE to ${APP_NAME}.icns"
echo ""

# Get image dimensions
IMAGE_WIDTH=$(sips -g pixelWidth "$IMAGE_FILE" | tail -n1 | awk '{print $2}')
IMAGE_HEIGHT=$(sips -g pixelHeight "$IMAGE_FILE" | tail -n1 | awk '{print $2}')

print_info "Source image: ${IMAGE_WIDTH}x${IMAGE_HEIGHT} pixels"

# Warn if image is too small
if [[ $IMAGE_WIDTH -lt 512 ]] || [[ $IMAGE_HEIGHT -lt 512 ]]; then
	print_warning "Image is smaller than 512x512. Quality may be reduced."
	print_warning "Recommended size: 1024x1024 or larger"
fi

# Generate all required icon sizes
print_info "Generating icon sizes..."

# Standard sizes
sips -z 16 16     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_16x16.png" >/dev/null 2>&1
sips -z 32 32     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_16x16@2x.png" >/dev/null 2>&1
sips -z 32 32     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_32x32.png" >/dev/null 2>&1
sips -z 64 64     "$IMAGE_FILE" --out "$ICONSET_DIR/icon_32x32@2x.png" >/dev/null 2>&1
sips -z 128 128   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_128x128.png" >/dev/null 2>&1
sips -z 256 256   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_128x128@2x.png" >/dev/null 2>&1
sips -z 256 256   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_256x256.png" >/dev/null 2>&1
sips -z 512 512   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_256x256@2x.png" >/dev/null 2>&1
sips -z 512 512   "$IMAGE_FILE" --out "$ICONSET_DIR/icon_512x512.png" >/dev/null 2>&1
sips -z 1024 1024 "$IMAGE_FILE" --out "$ICONSET_DIR/icon_512x512@2x.png" >/dev/null 2>&1

print_success "Generated 10 icon sizes"

# Convert to .icns
OUTPUT_FILE="${ICONS_DIR}/${APP_NAME}.icns"
print_info "Converting to .icns format..."

if iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_FILE" 2>&1; then
	print_success "Created: $OUTPUT_FILE"
else
	print_error "Failed to create .icns file"
	rm -rf "${SCRIPT_DIR}/.tmp"
	exit 1
fi

# Cleanup
rm -rf "${SCRIPT_DIR}/.tmp"

echo ""
print_success "Icon created successfully!"
echo ""
print_info "Next steps:"
echo "  1. Run: ./install.sh --component apps"
echo "  2. The icon will be automatically applied to ${APP_NAME}.app"
echo ""

# Show the icon file
print_info "Icon saved to: $OUTPUT_FILE"
print_info "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
