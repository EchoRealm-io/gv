#!/bin/bash
# gv - Go Version Manager - One‑line installer (cross‑platform, interactive)

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Detect shell config file
detect_rc_file() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        if [[ -f "$HOME/.bash_profile" ]]; then
            echo "$HOME/.bash_profile"
        else
            echo "$HOME/.bashrc"
        fi
    else
        echo "$HOME/.profile"
    fi
}

INSTALL_DIR="$HOME/.go-version-manager"
mkdir -p "$INSTALL_DIR"

# Copy source files
cp -r src/* "$INSTALL_DIR/"

echo "=== gv (Go Version Manager) Installation ==="
echo "Press Enter to accept default values."

# Detect OS default installation directory
detect_os_default_dir() {
    case "$OSTYPE" in
        linux*)   echo "/usr/local" ;;
        darwin*)  echo "/usr/local" ;;
        cygwin*|msys*|mingw*) echo "$HOME/.go-versions" ;;
        *)        echo "/usr/local" ;;
    esac
}
default_install_dir=$(detect_os_default_dir)
read -p "Go installation directory (default: $default_install_dir): " user_install_dir
user_install_dir=${user_install_dir:-$default_install_dir}

default_default_version="1.26.4"
read -p "Default Go version (when no go.mod, default: $default_default_version): " user_default_version
user_default_version=${user_default_version:-$default_default_version}

default_min_version="1.17"
read -p "Minimum Go version (auto-upgrade below this, default: $default_min_version): " user_min_version
user_min_version=${user_min_version:-$default_min_version}

# Detect region-appropriate default mirror
detect_region_mirror() {
    local lang="${LANG:-$LC_ALL}"
    case "$lang" in
        zh_CN*) echo "https://golang.google.cn/dl" ;;
        *)      echo "https://go.dev/dl" ;;
    esac
}
default_mirror=$(detect_region_mirror)
read -p "Download mirror URL (default: $default_mirror): " user_mirror
user_mirror=${user_mirror:-$default_mirror}

# Write user config to defaults.sh
cat > "$INSTALL_DIR/defaults.sh" << EOF
#!/bin/bash
# ==================== User configuration for gv ====================
export GO_VERSIONS_DIR="$user_install_dir"
export GO_CURRENT_VERSION_FILE="\$HOME/.go_current_version"
export GO_DOWNLOAD_BASE_URL="$user_mirror"
export DEFAULT_GO_VERSION="$user_default_version"
export MIN_GO_VERSION="$user_min_version"

# Detect operating system
detect_os() {
    case "\$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "darwin" ;;
        cygwin*|msys*|mingw*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}
export GO_OS=\$(detect_os)

# Detect architecture
detect_arch() {
    local arch=\$(uname -m)
    case "\$arch" in
        x86_64|amd64) echo "amd64" ;;
        arm64|aarch64) echo "arm64" ;;
        *) echo "amd64" ;;
    esac
}
export GO_ARCH=\$(detect_arch)

# Package extension and unpack command
if [[ "\$GO_OS" == "windows" ]]; then
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
EOF

echo -e "${GREEN}✅ Configuration saved to $INSTALL_DIR/defaults.sh${NC}"

RC_FILE=$(detect_rc_file)

# Append source lines if not already present
if ! grep -q "source $INSTALL_DIR/defaults.sh" "$RC_FILE" 2>/dev/null; then
    echo "source $INSTALL_DIR/defaults.sh" >> "$RC_FILE"
    echo "source $INSTALL_DIR/i18n.sh" >> "$RC_FILE"
    echo "source $INSTALL_DIR/core.sh" >> "$RC_FILE"
fi

# Create wrapper (~/bin/go)
mkdir -p "$HOME/bin"
cp "$INSTALL_DIR/wrapper.sh" "$HOME/bin/go"
chmod +x "$HOME/bin/go"

# Ensure ~/bin is at the front of PATH
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$RC_FILE" 2>/dev/null; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$RC_FILE"
fi

echo -e "${GREEN}✅ Installation complete!${NC}"
echo "Please run the following to apply changes:"
echo "    source $RC_FILE"
echo "Or restart your terminal."
echo ""
echo "You can now use: go-install, switch_go_version, go-list, go-set-mirror"
