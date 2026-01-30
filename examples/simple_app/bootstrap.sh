#!/bin/sh
# Simple application installation script
# Demonstrates basic mksfx usage

set -e

echo "╔═══════════════════════════════════════════╗"
echo "║  Simple App Installation                  ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-/opt/simple_app}"

echo "📍 Installing to: $INSTALL_DIR"
echo ""

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Extract files
if [ -d "$SCRIPT_DIR/files" ]; then
  echo "📂 Copying files..."
  
  for file in "$SCRIPT_DIR/files"/*; do
    if [ -f "$file" ]; then
      filename=$(basename "$file")
      cp "$file" "$INSTALL_DIR/$filename"
      echo "  ✓ $filename"
    fi
  done
fi

# Set permissions
if [ -f "$INSTALL_DIR/run.sh" ]; then
  chmod +x "$INSTALL_DIR/run.sh"
fi

echo ""
echo "✅ Installation completed successfully!"
echo ""
echo "Next steps:"
echo "  cd $INSTALL_DIR"
echo "  ./run.sh"
echo ""
