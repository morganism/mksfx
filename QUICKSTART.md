# 🚀 Quick Start Guide

Get up and running with mksfx in 5 minutes.

## Step 1: Verify Installation

```bash
cd /Users/morgan/data/src/mksfx
chmod +x verify.sh
./verify.sh
```

This checks:
- ✅ All critical files present
- ✅ Ruby installed
- ✅ Correct permissions

## Step 2: Install Dependencies

```bash
bundle install
```

This installs:
- Thor (CLI framework)
- RSpec (testing)
- Rubocop (linting)

## Step 3: Build & Install Locally

```bash
bundle exec rake install_local
```

Or manually:
```bash
gem build mksfx.gemspec
gem install mksfx-1.0.0.gem
```

## Step 4: Test Installation

```bash
mksfx version
# Output: mksfx 1.0.0

mksfx --help
# Shows all available commands
```

## Step 5: Create Your First Archive

```bash
# Initialize a test project
mksfx init test_app
cd test_app

# Customize (optional)
echo "echo 'Hello from mksfx!'" >> bootstrap.sh

# Build
mksfx build . -o test-installer.tar.gz

# Test
tar -xzf test-installer.tar.gz
cd bundle
sh installer.sh -v -x -r
```

## Development Workflow

### Run Tests
```bash
bundle exec rspec
```

### Lint Code
```bash
bundle exec rubocop
```

### Run All Checks
```bash
bundle exec rake check
```

## Package for Distribution

### Create Archive
```bash
chmod +x package.sh
./package.sh
```

This creates `../mksfx-1.0.0.tar.gz` with:
- All source files
- Documentation
- Examples
- Tests

### Initialize Git Repository
```bash
chmod +x init_git.sh
./init_git.sh

# Then commit
git commit -m "Initial commit: mksfx v1.0.0"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/mksfx.git
git push -u origin main
```

## Publishing to RubyGems

### First Time Setup
```bash
# Create RubyGems account at rubygems.org
# Then authenticate
gem signin
```

### Publish
```bash
gem build mksfx.gemspec
gem push mksfx-1.0.0.gem
```

### Update Version
```bash
# Edit lib/mksfx/version.rb
# Update CHANGELOG.md
# Commit changes
git tag -a v1.0.1 -m "Release v1.0.1"
git push --tags

# Rebuild and push
gem build mksfx.gemspec
gem push mksfx-1.0.1.gem
```

## Troubleshooting

### "Cannot find mksfx command"
```bash
# Check installation
gem list mksfx

# Reinstall
bundle exec rake install_local
```

### "Bundle not found"
```bash
gem install bundler
bundle install
```

### "Permission denied"
```bash
# Fix executable permissions
chmod +x bin/mksfx verify.sh package.sh init_git.sh
```

### "Tests failing"
```bash
# Clean and reinstall
rm -f *.gem
bundle install
bundle exec rake install_local
bundle exec rspec
```

## File Structure Summary

```
mksfx/
├── bin/mksfx              # CLI executable
├── lib/mksfx/             # Core library
│   ├── cli.rb            # Thor commands
│   ├── builder.rb        # Archive builder
│   ├── updater.rb        # Incremental updates
│   └── templates/        # POSIX installer
├── spec/                  # RSpec tests
├── examples/              # Usage examples
├── mksfx.gemspec         # Gem specification
├── package.sh            # Create distribution archive
├── verify.sh             # Verify project structure
└── init_git.sh           # Initialize git repo
```

## Next Steps

1. ✅ Verify installation
2. ✅ Install dependencies
3. ✅ Build and test
4. 📦 Create example archives
5. 🚀 Push to GitHub
6. 💎 Publish to RubyGems

## Resources

- **README.md** - Full documentation
- **USAGE.md** - Detailed usage guide
- **GEM_GUIDE.md** - Gem development guide
- **MANIFEST.txt** - File listing
- **examples/** - Working examples

## Support

- 🐛 Issues: Create GitHub issue
- 📧 Email: [Your email]
- 💬 Discussion: GitHub Discussions

---

**No magic. No implicit execution. Pure Unix.** 🚀
