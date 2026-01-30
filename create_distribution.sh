#!/bin/bash
# Complete project packaging and distribution script
# Creates a ready-to-distribute archive of mksfx

set -e

echo "╔═══════════════════════════════════════════════════════╗"
echo "║  mksfx Project Packaging & Distribution              ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"
PROJECT_NAME="mksfx-1.0.0"

echo "📍 Project directory: $PROJECT_DIR"
echo ""

# Step 1: Verify structure
echo "Step 1: Verifying project structure..."
if [ ! -f "mksfx.gemspec" ]; then
  echo "❌ Error: mksfx.gemspec not found!"
  echo "Run this script from the mksfx project root"
  exit 1
fi
echo "✅ Project structure verified"
echo ""

# Step 2: Clean build artifacts
echo "Step 2: Cleaning build artifacts..."
rm -f *.gem
rm -rf pkg/
echo "✅ Cleaned"
echo ""

# Step 3: Create distribution archive
echo "Step 3: Creating distribution archive..."
cd ..
tar -czf "${PROJECT_NAME}.tar.gz" \
  --exclude='mksfx/.git' \
  --exclude='mksfx/.bundle' \
  --exclude='mksfx/vendor' \
  --exclude='mksfx/*.gem' \
  --exclude='mksfx/pkg' \
  --exclude='mksfx/*.tar.gz' \
  --exclude='mksfx/.DS_Store' \
  mksfx/

echo "✅ Archive created: ${PROJECT_NAME}.tar.gz"
echo ""

# Step 4: Show details
echo "Archive details:"
ls -lh "${PROJECT_NAME}.tar.gz"
echo ""

# Step 5: Verify archive
echo "Archive contents (first 30 files):"
tar -tzf "${PROJECT_NAME}.tar.gz" | head -30
echo "..."
total_files=$(tar -tzf "${PROJECT_NAME}.tar.gz" | wc -l)
echo ""
echo "Total files in archive: $total_files"
echo ""

# Step 6: Create checksum
echo "Generating checksum..."
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${PROJECT_NAME}.tar.gz" > "${PROJECT_NAME}.tar.gz.sha256"
  cat "${PROJECT_NAME}.tar.gz.sha256"
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "${PROJECT_NAME}.tar.gz" > "${PROJECT_NAME}.tar.gz.sha256"
  cat "${PROJECT_NAME}.tar.gz.sha256"
fi
echo ""

# Step 7: Instructions
echo "╔═══════════════════════════════════════════════════════╗"
echo "║  📦 Distribution Package Ready!                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "Created files:"
echo "  - ${PROJECT_NAME}.tar.gz"
echo "  - ${PROJECT_NAME}.tar.gz.sha256"
echo ""
echo "To distribute:"
echo "  1. Upload to GitHub releases"
echo "  2. Share via any file transfer method"
echo "  3. Publish to RubyGems: gem push ${PROJECT_NAME}.gem"
echo ""
echo "Recipients can extract with:"
echo "  tar -xzf ${PROJECT_NAME}.tar.gz"
echo "  cd mksfx"
echo "  bundle install"
echo "  bundle exec rake install_local"
echo ""
echo "Or install from source:"
echo "  tar -xzf ${PROJECT_NAME}.tar.gz"
echo "  cd mksfx"
echo "  gem build mksfx.gemspec"
echo "  gem install mksfx-1.0.0.gem"
echo ""

# Return to project directory
cd "$PROJECT_DIR"

echo "✅ Packaging complete!"
