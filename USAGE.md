# mksfx Usage Guide

Complete guide to using mksfx for creating self-extracting archives.

## Table of Contents

1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Commands](#commands)
4. [Workflows](#workflows)
5. [Advanced Usage](#advanced-usage)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

## Installation

### From RubyGems

```bash
gem install mksfx
```

### From Source

```bash
git clone https://github.com/morganism/mksfx.git
cd mksfx
gem build mksfx.gemspec
gem install mksfx-*.gem
```

### Development

```bash
bundle install
bundle exec rake install_local
```

## Quick Start

### 1. Initialize Payload

```bash
mksfx init my_app
```

Creates structure:
```
my_app/
├── bootstrap.sh    # Installation script
├── files/          # Application files
└── README.md
```

### 2. Customize

Edit `bootstrap.sh` with your installation logic:

```bash
#!/bin/sh
set -e

echo "Installing MyApp..."

# Your installation commands here
cp files/* /opt/myapp/
chmod +x /opt/myapp/run.sh

echo "✅ Done"
```

Add your files to `files/` directory.

### 3. Build

```bash
cd my_app
mksfx build . -o installer.tar.gz -v 1.0.0
```

### 4. Distribute

Send `installer.tar.gz` to users.

### 5. User Installation

```bash
tar -xzf installer.tar.gz
cd bundle
sh installer.sh -v -x -r  # verify, extract, run
```

## Commands

### build

Create a self-extracting archive.

```bash
mksfx build SOURCE [OPTIONS]
```

**Options:**
- `-o, --output FILE` - Output filename (default: installer.tar.gz)
- `-v, --version VERSION` - Payload version (default: 1.0.0)
- `-e, --entrypoint FILE` - Bootstrap script (default: bootstrap.sh)
- `-c, --compression 1-9` - Compression level (default: 9)
- `--metadata KEY=VALUE` - Additional metadata
- `--verbose` - Verbose output

**Examples:**

```bash
# Basic
mksfx build ./my_app

# Custom output and version
mksfx build ./my_app -o myapp-v2.1.tar.gz -v 2.1.0

# With metadata
mksfx build ./my_app --metadata author=morgan --metadata license=MIT

# Different entrypoint
mksfx build ./my_app -e install.sh

# Lower compression (faster)
mksfx build ./my_app -c 6

# Verbose mode
mksfx build ./my_app --verbose
```

### update

Create incremental update between versions.

```bash
mksfx update OLD_ARCHIVE NEW_ARCHIVE [OPTIONS]
```

**Options:**
- `-o, --output FILE` - Output filename (auto-generated if omitted)
- `-a, --algorithm ALGO` - Delta algorithm (default: auto)
- `--verbose` - Verbose output

**Examples:**

```bash
# Basic update
mksfx update app-v1.0.tar.gz app-v2.0.tar.gz

# Custom output
mksfx update old.tar.gz new.tar.gz -o patch.tar.gz

# Verbose
mksfx update old.tar.gz new.tar.gz --verbose
```

**Output:**
```
✅ Incremental update created!

  📦 Output: update-1.0-to-2.0.tar.gz
  📊 Size: 234 KB
  📉 Savings: 76% vs full archive
  🔄 Old: 1.0.0 → New: 2.0.0
  
  Files: 5 changed, 2 added, 1 removed
```

### verify

Verify archive integrity.

```bash
mksfx verify ARCHIVE [OPTIONS]
```

**Examples:**

```bash
mksfx verify installer.tar.gz
mksfx verify installer.tar.gz --verbose
```

### info

Show archive information.

```bash
mksfx info ARCHIVE [OPTIONS]
```

**Options:**
- `--files` - Show file listing

**Examples:**

```bash
mksfx info installer.tar.gz
mksfx info installer.tar.gz --files
```

**Output:**
```
Archive Information: installer.tar.gz
────────────────────────────────────────────────────
Version:     1.0.0
Checksum:    abc123def456...
Entrypoint:  bootstrap.sh
Total Size:  1.2 MB
Payload:     1.1 MB
Overhead:    100 KB (8.3%)

Metadata:
  author: morgan
  build-date: 2025-01-30
```

### init

Initialize new payload directory.

```bash
mksfx init NAME [OPTIONS]
```

**Options:**
- `-e, --entrypoint FILE` - Bootstrap script name (default: bootstrap.sh)

**Examples:**

```bash
mksfx init my_app
mksfx init my_app --entrypoint install.sh
```

### version

Show mksfx version.

```bash
mksfx version
```

## Workflows

### Development Workflow

```bash
# 1. Initialize
mksfx init myapp
cd myapp

# 2. Develop
echo "deployment logic" >> bootstrap.sh
cp ~/myapp/* files/

# 3. Build
mksfx build . -o myapp-dev.tar.gz

# 4. Test locally
tar -xzf myapp-dev.tar.gz
cd bundle
sh installer.sh -v -x -r

# 5. Iterate
cd ../../
vim bootstrap.sh
mksfx build . -o myapp-dev.tar.gz --force
```

### Release Workflow

```bash
# 1. Build release
VERSION=$(git describe --tags)
mksfx build ./myapp \
  -o "myapp-${VERSION}.tar.gz" \
  -v "$VERSION" \
  --metadata "git-commit=$(git rev-parse HEAD)" \
  --metadata "build-date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# 2. Verify
mksfx verify "myapp-${VERSION}.tar.gz"

# 3. Tag
git tag -a "v${VERSION}" -m "Release ${VERSION}"

# 4. Upload to releases
gh release create "v${VERSION}" "myapp-${VERSION}.tar.gz"
```

### Update Workflow

```bash
# Create version 2.0
mksfx build ./myapp -o myapp-v2.0.tar.gz -v 2.0.0

# Generate update from 1.0 to 2.0
mksfx update myapp-v1.0.tar.gz myapp-v2.0.tar.gz

# Distribute update
scp update-1.0-to-2.0.tar.gz server:/tmp/

# Apply update on server
tar -xzf update-1.0-to-2.0.tar.gz
cd bundle
PAYLOAD_DIR=/opt/myapp sh update.sh
```

## Advanced Usage

### Custom Metadata

```bash
mksfx build ./myapp \
  --metadata author=morgan \
  --metadata license=MIT \
  --metadata support=support@example.com \
  --metadata docs=https://docs.example.com
```

### Environment-Specific Builds

```bash
# Production
mksfx build ./myapp \
  -o myapp-prod.tar.gz \
  --metadata environment=production \
  --metadata config=prod.conf

# Staging
mksfx build ./myapp \
  -o myapp-staging.tar.gz \
  --metadata environment=staging \
  --metadata config=staging.conf
```

### Multi-Stage Bootstrap

```bash
#!/bin/sh
set -e

stage() {
  echo ""
  echo "▶ Stage $1: $2"
  echo "─────────────────────"
}

stage 1 "Prerequisites"
command -v docker || { echo "Docker required"; exit 1; }

stage 2 "Backup"
[ -d /opt/myapp ] && tar -czf /opt/myapp.backup.tar.gz /opt/myapp

stage 3 "Install"
mkdir -p /opt/myapp
cp -r files/* /opt/myapp/

stage 4 "Configure"
./files/setup.sh

stage 5 "Test"
/opt/myapp/healthcheck || { echo "Health check failed"; exit 1; }

echo "✅ All stages completed"
```

### Rollback Support

```bash
#!/bin/sh
set -e

INSTALL_DIR="/opt/myapp"
BACKUP_DIR="${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
ROLLBACK_SCRIPT="/tmp/rollback-$(date +%Y%m%d_%H%M%S).sh"

# Create rollback script
cat > "$ROLLBACK_SCRIPT" << 'EOF'
#!/bin/sh
set -e
if [ -d "BACKUP_DIR" ]; then
  rm -rf /opt/myapp
  mv BACKUP_DIR /opt/myapp
  echo "✅ Rolled back"
fi
EOF
sed -i "s|BACKUP_DIR|$BACKUP_DIR|g" "$ROLLBACK_SCRIPT"
chmod +x "$ROLLBACK_SCRIPT"

# Backup
[ -d "$INSTALL_DIR" ] && mv "$INSTALL_DIR" "$BACKUP_DIR"

# Install
mkdir -p "$INSTALL_DIR"
cp -r files/* "$INSTALL_DIR"/

# Test
if ! "$INSTALL_DIR/healthcheck"; then
  echo "✗ Failed, rolling back..."
  sh "$ROLLBACK_SCRIPT"
  exit 1
fi

echo "✅ Installed. Rollback: $ROLLBACK_SCRIPT"
```

## Best Practices

### 1. Version Everything

Always specify versions:
```bash
mksfx build ./app -v "$(git describe --tags)"
```

### 2. Include Metadata

```bash
mksfx build ./app \
  --metadata commit="$(git rev-parse HEAD)" \
  --metadata build-date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

### 3. Test in Clean Environment

```bash
docker run --rm -v $(pwd):/work -w /work ubuntu:latest \
  sh -c "tar -xzf installer.tar.gz && cd bundle && sh installer.sh -v -x"
```

### 4. Provide Rollback

Always create rollback scripts in production deployments.

### 5. Log Operations

```bash
#!/bin/sh
set -e

LOG_FILE="/var/log/myapp-install.log"

log() {
  echo "[$(date)] $1" | tee -a "$LOG_FILE"
}

log "Installation started"
# ... installation steps ...
log "Installation completed"
```

### 6. Check Prerequisites

```bash
#!/bin/sh
set -e

# Check prerequisites
for cmd in docker git tar; do
  command -v $cmd >/dev/null || { echo "Missing: $cmd"; exit 1; }
done

# Check disk space
available=$(df -BG / | tail -1 | awk '{print $4}' | sed 's/G//')
[ "$available" -lt 10 ] && { echo "Need 10GB free"; exit 1; }

# Proceed with installation
echo "Prerequisites OK"
```

## Troubleshooting

### Build Errors

**"Source directory not found"**
```bash
# Check path
ls -la /path/to/source

# Use absolute path
mksfx build "$(pwd)/myapp"
```

**"Entrypoint script not found"**
```bash
# Check file exists
ls -la myapp/bootstrap.sh

# Or specify different entrypoint
mksfx build myapp -e install.sh
```

### Installation Errors

**"Checksum mismatch"**
```bash
# Re-download
wget https://example.com/installer.tar.gz

# Verify download
sha256sum installer.tar.gz
```

**"Payload directory already exists"**
```bash
# Use --force
sh installer.sh --extract --force

# Or remove manually
rm -rf payload
sh installer.sh --extract
```

**"Bootstrap script not found"**
```bash
# Extract first
sh installer.sh --extract

# Then run
sh installer.sh --run
```

### Platform Issues

**"No checksum tool found"**

Linux:
```bash
apt-get install coreutils  # Debian/Ubuntu
yum install coreutils      # RHEL/CentOS
```

macOS:
```bash
# Already included - check PATH
which shasum
```

## See Also

- [README.md](README.md) - General documentation
- [examples/](examples/) - Example payloads
- [CHANGELOG.md](CHANGELOG.md) - Version history
