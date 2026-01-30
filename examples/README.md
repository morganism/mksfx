# mksfx Examples

This directory contains example payloads demonstrating different use cases.

## simple_app

Basic application deployment example.

### Build

```bash
mksfx build examples/simple_app -o simple_app-installer.tar.gz
```

### Test

```bash
tar -xzf simple_app-installer.tar.gz
cd bundle
sh installer.sh --verify
sh installer.sh --extract
sh installer.sh --run
```

### What It Does

1. Creates `/opt/simple_app` directory
2. Copies application files
3. Sets executable permissions
4. Provides a simple runner script

## Creating Your Own

Use `mksfx init` to create a new payload:

```bash
mksfx init my_app
cd my_app
# Edit bootstrap.sh
# Add files to files/
mksfx build . -o my_app-installer.tar.gz
```
