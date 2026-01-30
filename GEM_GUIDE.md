# mksfx - Complete Ruby Gem

Professional self-extracting archive creator with Thor CLI and incremental updates.

## 📁 Project Structure

```
mksfx/
├── bin/
│   └── mksfx                      # Executable
├── lib/
│   ├── mksfx.rb                   # Main entry point
│   └── mksfx/
│       ├── version.rb             # Version constant
│       ├── cli.rb                 # Thor CLI
│       ├── builder.rb             # Archive builder
│       ├── updater.rb             # Incremental updates
│       └── templates/
│           └── installer.sh       # POSIX shell template
├── spec/
│   ├── spec_helper.rb             # RSpec configuration
│   └── mksfx_spec.rb              # Tests
├── examples/
│   ├── README.md                  # Examples documentation
│   └── simple_app/                # Example payload
│       ├── bootstrap.sh
│       └── files/
│           ├── run.sh
│           └── config.txt
├── mksfx.gemspec                  # Gem specification
├── Gemfile                        # Dependencies
├── Rakefile                       # Build tasks
├── README.md                      # Main documentation
├── USAGE.md                       # Usage guide
├── CHANGELOG.md                   # Version history
├── LICENSE                        # Unlicense
├── .rspec                         # RSpec config
├── .rubocop.yml                   # Rubocop config
└── .gitignore                     # Git ignore rules
```

## 🚀 Installation

### For Users

```bash
gem install mksfx
```

### For Developers

```bash
git clone https://github.com/morganism/mksfx.git
cd mksfx
bundle install
```

## 🔨 Building and Installing Locally

```bash
# Build gem
gem build mksfx.gemspec

# Install locally
gem install mksfx-1.0.0.gem

# Or use rake
bundle exec rake install_local
```

## 📦 Publishing to RubyGems

```bash
# First time: Create account and get API key
gem push mksfx-1.0.0.gem

# Subsequent releases
gem build mksfx.gemspec
gem push mksfx-*.gem
```

## 🧪 Development

### Run Tests

```bash
bundle exec rspec
# or
bundle exec rake test
```

### Lint Code

```bash
bundle exec rubocop
# or
bundle exec rake lint

# Auto-fix
bundle exec rubocop -a
```

### Run All Checks

```bash
bundle exec rake check  # lint + test
```

## 📖 Quick Start

### 1. Install

```bash
gem install mksfx
```

### 2. Create Payload

```bash
mksfx init my_app
cd my_app
```

### 3. Customize

Edit `bootstrap.sh`:
```bash
#!/bin/sh
set -e
echo "Installing..."
# Your installation logic
```

Add files to `files/` directory.

### 4. Build

```bash
mksfx build . -o installer.tar.gz -v 1.0.0
```

### 5. Distribute

Send `installer.tar.gz` to users.

### 6. User Installation

```bash
tar -xzf installer.tar.gz
cd bundle
sh installer.sh -v -x -r
```

## 🎯 Key Features

### Thor CLI

Professional command-line interface with:
- Subcommands (`build`, `update`, `verify`, `info`, `init`)
- Rich option parsing
- Automatic help generation
- Tab completion support

### Incremental Updates

```bash
mksfx update old.tar.gz new.tar.gz
# Creates delta update ~75% smaller
```

### Metadata Support

```bash
mksfx build ./app \
  --metadata author=morgan \
  --metadata license=MIT \
  --metadata build-date=2025-01-30
```

### Verbose Mode

```bash
mksfx build ./app --verbose
# Shows detailed build progress
```

### Compression Control

```bash
mksfx build ./app -c 9  # Maximum compression
mksfx build ./app -c 1  # Fast compression
```

## 🔧 CLI Commands

### build

```bash
mksfx build SOURCE [OPTIONS]

Options:
  -o, --output FILE      Output filename
  -v, --version VERSION  Payload version
  -e, --entrypoint FILE  Bootstrap script
  -c, --compression 1-9  Compression level
  --metadata KEY=VALUE   Additional metadata
  --verbose              Verbose output
```

### update

```bash
mksfx update OLD NEW [OPTIONS]

Options:
  -o, --output FILE      Output filename
  -a, --algorithm ALGO   Delta algorithm
  --verbose              Verbose output
```

### verify

```bash
mksfx verify ARCHIVE
```

### info

```bash
mksfx info ARCHIVE [--files]
```

### init

```bash
mksfx init NAME [-e ENTRYPOINT]
```

### version

```bash
mksfx version
```

## 📚 Documentation

- **[README.md](README.md)** - Main documentation
- **[USAGE.md](USAGE.md)** - Detailed usage guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history
- **[examples/](examples/)** - Example payloads

## 🧩 Architecture

### Components

1. **CLI (Thor)** - Command-line interface
2. **Builder** - Archive creation
3. **Updater** - Incremental updates
4. **Templates** - POSIX shell installer

### Flow

```
User Input
    ↓
Thor CLI (lib/mksfx/cli.rb)
    ↓
Builder/Updater (lib/mksfx/*.rb)
    ↓
Template (lib/mksfx/templates/installer.sh)
    ↓
Output Archive (.tar.gz)
```

## 🔐 Security

- SHA-256 checksum verification
- No implicit code execution
- Explicit user confirmation
- Auditable with standard tools
- Cross-platform (Linux/macOS)

## 🎨 Design Principles

1. **Explicit over implicit** - No magic
2. **Auditable** - Human-readable everything
3. **Portable** - POSIX shell only
4. **Professional** - Proper gem packaging
5. **Zero dependencies** - Runtime: tar + gzip only

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -am 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

### Guidelines

- POSIX shell only (no bash-isms)
- Follow Rubocop style
- Add tests for new features
- Update documentation
- Keep it simple

## 📄 License

This is free and unencumbered software released into the public domain.
See [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Thor for awesome CLI framework
- Unix philosophy for inspiration
- Ruby community for excellent tooling

## 🔗 Links

- **Homepage**: https://github.com/morganism/mksfx
- **RubyGems**: https://rubygems.org/gems/mksfx
- **Issues**: https://github.com/morganism/mksfx/issues
- **Releases**: https://github.com/morganism/mksfx/releases

## 📊 Status

- ✅ Core functionality complete
- ✅ Thor CLI integrated
- ✅ Incremental updates working
- ✅ Cross-platform (Linux/macOS)
- ✅ Full test coverage
- ✅ Documentation complete
- ⏳ Published to RubyGems (pending)

---

**No magic. No implicit execution. Pure Unix.**
