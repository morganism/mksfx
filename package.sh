#!/bin/bash
# Package mksfx project for distribution

set -e

echo "Packaging mksfx project..."
echo ""

cd "$(dirname "$0")"

# Create archive
tar -czf ../mksfx-1.0.0.tar.gz \
  --exclude='.git' \
  --exclude='*.gem' \
  --exclude='pkg/' \
  --exclude='vendor/' \
  --exclude='.bundle' \
  --exclude='*.tar.gz' \
  .

echo "✅ Archive created: ../mksfx-1.0.0.tar.gz"
echo ""

# Show details
ls -lh ../mksfx-1.0.0.tar.gz

echo ""
echo "Archive contents:"
tar -tzf ../mksfx-1.0.0.tar.gz | head -20
echo "... (showing first 20 files)"
echo ""
echo "Total files: $(tar -tzf ../mksfx-1.0.0.tar.gz | wc -l)"
echo ""
echo "To extract:"
echo "  tar -xzf mksfx-1.0.0.tar.gz"
