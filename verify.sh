#!/bin/bash
# Verify mksfx project structure

set -e

echo "╔═══════════════════════════════════════════════╗"
echo "║  mksfx Project Verification                   ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

cd "$(dirname "$0")"

# Check critical files
echo "Checking critical files..."
critical_files=(
  "mksfx.gemspec"
  "Gemfile"
  "Rakefile"
  "bin/mksfx"
  "lib/mksfx.rb"
  "lib/mksfx/cli.rb"
  "lib/mksfx/builder.rb"
  "lib/mksfx/updater.rb"
  "lib/mksfx/version.rb"
  "lib/mksfx/templates/installer.sh"
  "README.md"
  "LICENSE"
)

missing=0
for file in "${critical_files[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ✗ $file (MISSING)"
    missing=$((missing + 1))
  fi
done

echo ""

# Count files
total_files=$(find . -type f | grep -v '.git' | wc -l)
echo "Total files: $total_files"

# Check for Ruby
echo ""
echo "Checking Ruby installation..."
if command -v ruby >/dev/null 2>&1; then
  echo "  ✓ Ruby found: $(ruby --version)"
else
  echo "  ✗ Ruby not found"
  missing=$((missing + 1))
fi

# Check for bundler
if command -v bundle >/dev/null 2>&1; then
  echo "  ✓ Bundler found: $(bundle --version)"
else
  echo "  ✗ Bundler not found (install: gem install bundler)"
fi

# Check permissions
echo ""
echo "Checking executable permissions..."
if [ -x "bin/mksfx" ]; then
  echo "  ✓ bin/mksfx is executable"
else
  echo "  ⚠ bin/mksfx needs +x permission"
  chmod +x bin/mksfx
  echo "  ✓ Fixed: chmod +x bin/mksfx"
fi

echo ""

if [ $missing -eq 0 ]; then
  echo "✅ All checks passed!"
  echo ""
  echo "Next steps:"
  echo "  1. Install dependencies: bundle install"
  echo "  2. Run tests: bundle exec rspec"
  echo "  3. Install locally: bundle exec rake install_local"
  echo "  4. Test: mksfx version"
else
  echo "❌ $missing issue(s) found"
  exit 1
fi
