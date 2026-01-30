#!/bin/bash
# Initialize git repository for mksfx

set -e

cd "$(dirname "$0")"

echo "Initializing git repository..."
echo ""

# Initialize git if not already initialized
if [ ! -d .git ]; then
  git init
  echo "✅ Git repository initialized"
else
  echo "ℹ️  Git repository already exists"
fi

# Add all files
git add .

echo ""
echo "Files staged for commit:"
git status --short

echo ""
echo "Ready to commit. Run:"
echo "  git commit -m 'Initial commit: mksfx v1.0.0'"
echo "  git branch -M main"
echo "  git remote add origin https://github.com/YOUR_USERNAME/mksfx.git"
echo "  git push -u origin main"
