#!/bin/bash
# ==================== User configuration template for gv ====================
# This file is overwritten by install.sh with user-specified values.
# You can also edit it manually after installation (~/.go-version-manager/defaults.sh).

if [[ "$OSTYPE" == *"msys"* || "$OSTYPE" == *"cygwin"* ]]; then
    export GO_VERSIONS_DIR="${GO_VERSIONS_DIR:-$HOME/.go-versions}"
else
    export GO_VERSIONS_DIR="${GO_VERSIONS_DIR:-/usr/local}"
fi
export GO_CURRENT_VERSION_FILE="$HOME/.go_current_version"
export GO_DOWNLOAD_BASE_URL="${GO_DOWNLOAD_BASE_URL:-https://go.dev/dl}"
export DEFAULT_GO_VERSION="${DEFAULT_GO_VERSION:-1.26.4}"
export MIN_GO_VERSION="${MIN_GO_VERSION:-1.21}"

# Detect operating system
detect_os() {
    case "$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "darwin" ;;
        cygwin*|msys*|mingw*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}
export GO_OS=$(detect_os)

# Detect architecture
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64) echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        *) echo "amd64" ;;
    esac
}
export GO_ARCH=$(detect_arch)

# Package extension and unpack command
if [[ "$GO_OS" == "windows" ]]; then
    export GO_PKG_EXT=".zip"
    export GO_UNPACK_CMD="unzip -q"
    if ! command -v unzip &>/dev/null; then
        if command -v 7z &>/dev/null; then
            export GO_UNPACK_CMD="7z x -y"
        else
            echo "⚠️  unzip not found, please install unzip or 7z"
        fi
    fi
else
    export GO_PKG_EXT=".tar.gz"
    export GO_UNPACK_CMD="tar -xzf"
fi
