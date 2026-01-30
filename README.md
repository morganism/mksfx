# mksfx - Make Self-Extracting Archives

[![Gem Version](https://badge.fury.io/rb/mksfx.svg)](https://badge.fury.io/rb/mksfx)
[![License](https://img.shields.io/badge/license-Unlicense-blue.svg)](https://unlicense.org/)

**No magic. No implicit execution. Pure Unix.**

Create portable, auditable self-extracting archives with POSIX shell installers that work on Linux and macOS with zero runtime dependencies beyond standard Unix tools.

## Features

- ✅ **POSIX Shell Installer** - Cross-platform (Linux/macOS)
- 🔐 **SHA-256 Verification** - Integrity checking built-in
- 📦 **Zero Dependencies** - Only needs tar, gzip, and sha256sum/shasum
- 🎯 **Explicit Execution** - No code runs without user confirmation
- 📝 **Human-Readable** - Inspect everything with standard tools
- 🔄 **Incremental Updates** - Generate delta updates between versions
- 🛠️ **Thor CLI** - Powerful command-line interface
- 📊 **Verbose Mode** - See exactly what's happening

## Installation

```bash
gem install mksfx
```

Or add to your Gemfile:

```ruby
gem 'mksfx'
```

## Quick Start

### 1. Create a payload directory

```bash
mksfx init my_app
```

This creates:
```
my_app/
├── bootstrap.sh    # Installation script
├── files/          # Your application files
└── README.md       # Documentation
```

### 2. Add your files

```bash
cd my_app
echo "config data" > files/config.txt
# Add your application files to files/
```

### 3. Build the self-extracting archive

```bash
mksfx build . -o my_app-installer.tar.gz
```

Output:
```
✅ Self-extracting archive created!

  📦 Output: my_app-installer.tar.gz
  📊 Size: 1.2 KB
  🔐 Checksum: abc123def456...
  📝 Version: 1.0.0

Verify and extract:
  tar -tzf my_app-installer.tar.gz        # Inspect
  tar -xzf my_app-installer.tar.gz        # Extract
  cd bundle && sh installer.sh -h         # Help
```

### 4. Distribute to users

Users receive a single `.tar.gz` file and can:

```bash
# Inspect (recommended first step)
tar -tzf my_app-installer.tar.gz
tar -xzf my_app-installer.tar.gz
cat bundle/installer.sh  # Review the installer

# Verify integrity
cd bundle
sh installer.sh --verify

# Extract payload
sh installer.sh --extract

# Run installation (requires confirmation)
sh installer.sh --run

# Or do everything at once
sh installer.sh -v -x -r

# Interactive menu (default)
sh installer.sh
```

## CLI Commands

### `mksfx build` - Create archive

```bash
mksfx build SOURCE [OPTIONS]

Options:
  -o, --output FILE      Output filename (default: installer.tar.gz)
  -v, --version VERSION  Payload version (default: 1.0.0)
  -e, --entrypoint FILE  Bootstrap script (default: bootstrap.sh)
  -c, --compression 1-9  Compression level (default: 9)
  --metadata KEY=VALUE   Additional metadata
  --verbose              Verbose output

Examples:
  mksfx build ./my_app
  mksfx build ./my_app -o app-v2.1.tar.gz -v 2.1.0
  mksfx build ./my_app --metadata author=morgan
```

### `mksfx update` - Create incremental update

```bash
mksfx update OLD_ARCHIVE NEW_ARCHIVE [OPTIONS]

Options:
  -o, --output FILE       Output filename (auto-generated if not specified)
  -a, --algorithm ALGO    Delta algorithm (default: auto)
  --verbose               Verbose output

Examples:
  mksfx update app-v1.0.tar.gz app-v2.0.tar.gz
  mksfx update app-v1.0.tar.gz app-v2.0.tar.gz -o update.tar.gz
```

Output:
```
✅ Incremental update created!

  📦 Output: update-1.0-to-2.0.tar.gz
  📊 Size: 234 KB
  📉 Savings: 76% vs full archive
  🔄 Old: 1.0.0 → New: 2.0.0
```

### `mksfx verify` - Verify archive integrity

```bash
mksfx verify ARCHIVE

Examples:
  mksfx verify installer.tar.gz
  mksfx verify installer.tar.gz --verbose
```

### `mksfx info` - Show archive information

```bash
mksfx info ARCHIVE [OPTIONS]

Options:
  --files    Show file listing

Examples:
  mksfx info installer.tar.gz
  mksfx info installer.tar.gz --files
```

### `mksfx init` - Initialize payload structure

```bash
mksfx init NAME [OPTIONS]

Options:
  -e, --entrypoint FILE  Bootstrap script name (default: bootstrap.sh)

Examples:
  mksfx init my_app
  mksfx init my_app --entrypoint install.sh
```

### `mksfx version` - Show version

```bash
mksfx version
```

## Installer Usage

The generated `installer.sh` supports:

```bash
sh installer.sh [OPTIONS]

OPTIONS:
  -v, --verify    Verify payload checksum
  -x, --extract   Extract payload to ./payload
  -r, --run       Execute bootstrap.sh (requires confirmation)
  -m, --menu      Interactive menu (default)
  -f, --force     Force overwrite on extract
  -h, --help      Show help

ENVIRONMENT:
  DESTDIR         Extraction directory (default: current directory)

EXAMPLES:
  sh installer.sh -v              # Verify only
  sh installer.sh -x              # Extract only
  sh installer.sh -v -x -r        # Full install
  DESTDIR=/opt sh installer.sh -x # Extract to /opt
```

## Bootstrap Script Examples

### Simple Installation

```bash
#!/bin/sh
set -e

echo "Installing MyApp..."

# Extract files
for f in files/*.tar.gz; do
  tar -xzf "$f" -C /opt/myapp
done

# Set permissions
chmod +x /opt/myapp/bin/*

echo "✅ Installation complete"
```

### Multi-Stage Installation

```bash
#!/bin/sh
set -e

stage() {
  echo ""
  echo "▶ Stage $1: $2"
  echo "──────────────────────"
}

stage 1 "Verify Prerequisites"
command -v docker >/dev/null || { echo "Docker required"; exit 1; }

stage 2 "Extract Application"
tar -xzf files/app.tar.gz -C /opt

stage 3 "Configure"
./files/configure.sh

stage 4 "Start Services"
systemctl enable myapp
systemctl start myapp

echo "✅ Installation complete"
```

### Rollback-Safe Deployment

```bash
#!/bin/sh
set -e

APP_DIR="/opt/myapp"
BACKUP_DIR="/opt/myapp.backup.$(date +%Y%m%d_%H%M%S)"

# Backup current version
if [ -d "$APP_DIR" ]; then
  mv "$APP_DIR" "$BACKUP_DIR"
fi

# Install new version
mkdir -p "$APP_DIR"
tar -xzf files/app.tar.gz -C "$APP_DIR"

# Test new version
if ! /opt/myapp/bin/healthcheck; then
  echo "✗ Health check failed, rolling back..."
  rm -rf "$APP_DIR"
  mv "$BACKUP_DIR" "$APP_DIR"
  exit 1
fi

echo "✅ Installation successful"
echo "Rollback available at: $BACKUP_DIR"
```

## Platform Compatibility

| Platform | Status | Checksum Tool |
|----------|--------|---------------|
| Linux (GNU) | ✅ Full | `sha256sum` |
| macOS (BSD) | ✅ Full | `shasum -a 256` |
| FreeBSD | ✅ Expected | `shasum` |
| OpenBSD | ⚠️ Untested | `shasum` |
| Windows/WSL | ✅ Should work | Linux tools |
| Windows Native | ❌ No | POSIX required |

## Architecture

### Bundle Structure

```
installer_bundle.tar.gz
└── bundle/
    ├── installer.sh           # POSIX shell installer
    └── payload.tar.gz         # Your files + MANIFEST
        └── payload/
            ├── bootstrap.sh   # Installation script
            ├── files/         # Application files
            └── MANIFEST       # Version, checksum, metadata
```

### MANIFEST Format

```
Payload-Version: 1.0.0
Payload-Checksum: SHA256:abc123...
Bootstrap-Entrypoint: bootstrap.sh
Author: Morgan
Build-Date: 2025-01-30
```

## Security Model

### What Gets Verified
- ✅ Payload checksum matches embedded value (SHA-256)
- ✅ Extraction only writes to specified directory
- ✅ Bootstrap execution requires explicit user confirmation

### What's NOT Done Implicitly
- ❌ No code execution during verification
- ❌ No extraction during verification
- ❌ No bootstrap execution during extraction
- ❌ No automatic overwrites (requires `--force`)

## Development

```bash
# Clone repository
git clone https://github.com/morganism/mksfx.git
cd mksfx

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Build gem
gem build mksfx.gemspec

# Install locally
gem install mksfx-1.0.0.gem

# Lint
bundle exec rubocop
```

## Comparison to Alternatives

| Feature | mksfx | makeself | curl\|sh | Docker |
|---------|-------|----------|----------|--------|
| Human-readable installer | ✅ | ❌ Binary | ❌ Remote | ❌ Images |
| Checksum verification | ✅ | ✅ | ❌ | ✅ |
| No implicit execution | ✅ | ❌ Auto | ❌ Immediate | ❌ Pulls |
| POSIX-only | ✅ | ❌ Bash | ❌ curl | ❌ docker |
| Auditable | ✅ tar/gzip | ❌ Binary | ❌ Remote | ❌ Layers |
| Incremental updates | ✅ | ❌ | ❌ | ✅ |
| Ruby gem | ✅ | ❌ | ❌ | ❌ |

## Why mksfx?

1. **Auditable**: Everything is inspectable with standard Unix tools
2. **Portable**: Works anywhere with POSIX shell + tar + gzip
3. **Safe**: Explicit user confirmation before code execution
4. **Professional**: Thor CLI, proper gem packaging, semantic versioning
5. **Incremental**: Generate small delta updates between versions
6. **Zero Dependencies**: No runtime dependencies beyond POSIX

## Contributing

This is Unix. Keep it simple:
- POSIX shell only (no bash-isms)
- Standard tools only (tar, gzip, sha256sum)
- Explicit over implicit
- Auditable over convenient
- Fail-safe over fail-fast

## License

This is free and unencumbered software released into the public domain. See [UNLICENSE](LICENSE) for details.

## See Also

- [`tar(1)`](https://linux.die.net/man/1/tar) - archive files
- [`gzip(1)`](https://linux.die.net/man/1/gzip) - compress files
- [`sh(1)`](https://linux.die.net/man/1/sh) - POSIX shell
- [`sha256sum(1)`](https://linux.die.net/man/1/sha256sum), [`shasum(1)`](https://linux.die.net/man/1/shasum) - checksum utilities
- [Thor](http://whatisthor.com/) - CLI toolkit
