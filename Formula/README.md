# Homebrew Formula for Container

This directory contains the Homebrew formula for installing the `container` tool.

## Installation

### Install from Local Formula

If you have cloned this repository, you can install directly from the local formula:

```bash
brew install --HEAD Formula/container.rb
```

### Install from Homebrew Tap (when available)

Once the formula is published to a Homebrew tap, you can install it with:

```bash
brew tap apple/tap
brew install --HEAD container
```

## Usage

After installation, start the container system service:

```bash
container system start
```

## Upgrading

To upgrade to the latest version:

```bash
brew upgrade container
container system stop
container system start
```

## Uninstalling

To uninstall the container tool:

```bash
brew uninstall container
```

Or use the included uninstall script for a complete removal:

```bash
/usr/local/bin/uninstall-container.sh -d
```

## Requirements

- macOS 15 (Sequoia) or later (macOS 26 recommended)
- Apple Silicon (ARM64) Mac
- Xcode 16.0 or later

## Formula Details

The formula:
- Builds the project from source using Swift Package Manager
- Installs the main `container` CLI and `container-apiserver` binaries
- Installs helper plugin binaries in `libexec`
- Includes plugin configuration files
- Provides the uninstall script

## Contributing

If you encounter issues with the Homebrew formula, please file an issue in the main repository.
