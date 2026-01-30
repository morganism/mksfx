# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-30

### Added
- Initial release of mksfx
- Thor-based CLI with subcommands
- `build` command to create self-extracting archives
- `update` command for incremental updates
- `verify` command for integrity checking
- `info` command to show archive details
- `init` command to scaffold new payloads
- POSIX shell installer template
- SHA-256 checksum verification
- Interactive menu mode in installer
- Cross-platform support (Linux/macOS)
- Compression level control (1-9)
- Custom metadata support
- Verbose mode for debugging
- Comprehensive documentation
- RSpec test suite
- Rubocop linting configuration
- Examples directory

### Features
- No runtime dependencies beyond POSIX + tar/gzip
- Explicit user confirmation before code execution
- Force overwrite protection
- Environment variable support (DESTDIR)
- Human-readable installer scripts
- Automatic platform detection (sha256sum vs shasum)
- File-level delta updates
- Version tracking in MANIFEST

### Security
- SHA-256 integrity verification
- No implicit code execution
- Tamper detection
- Explicit confirmation prompts
- Auditable with standard Unix tools

## [Unreleased]

### Planned
- Binary diff support (bsdiff/xdelta)
- Digital signature verification
- Multi-architecture support
- Web-based verification tool
- Docker image generation
- Automated testing in CI/CD
- Performance benchmarks
- Extended documentation

[1.0.0]: https://github.com/morganism/mksfx/releases/tag/v1.0.0
