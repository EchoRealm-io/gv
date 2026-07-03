#!/bin/bash
# gv - Go Version Manager - One‑line installer (cross‑platform, interactive)

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Detect primary shell config file (for appending gv source lines)
detect_rc_file() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        case "$OSTYPE" in
            linux*) echo "$HOME/.bashrc" ;;
            *)
                if [[ -f "$HOME/.bash_profile" ]]; then
                    echo "$HOME/.bash_profile"
                else
                    echo "$HOME/.bashrc"
                fi
                ;;
        esac
    else
        echo "$HOME/.profile"
    fi
}

# All common shell config files (for scanning old Go settings)
ALL_RC_FILES=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.profile"
)

INSTALL_DIR="$HOME/.go-version-manager"
mkdir -p "$INSTALL_DIR"

# Download source files from GitHub
BASE_URL="https://raw.githubusercontent.com/EchoRealm-io/gv/main/src"
curl -sSL "$BASE_URL/i18n.sh" -o "$INSTALL_DIR/i18n.sh"
curl -sSL "$BASE_URL/core.sh" -o "$INSTALL_DIR/core.sh"
curl -sSL "$BASE_URL/wrapper.sh" -o "$INSTALL_DIR/wrapper.sh"

# Source i18n for localized messages
source "$INSTALL_DIR/i18n.sh"

# ---------- Check for existing Go installation ----------
EXISTING_GO=""
EXISTING_GO_SOURCE=""

# Homebrew (macOS)
if command -v brew &>/dev/null && brew list go &>/dev/null 2>&1; then
    EXISTING_GO="$(brew --prefix go 2>/dev/null || echo '/opt/homebrew/opt/go')"
    EXISTING_GO_SOURCE="Homebrew"
fi

# System-installed Go at common paths
if [[ -z "$EXISTING_GO" ]]; then
    for p in /usr/local/go /usr/lib/go /usr/lib/golang /opt/go /usr/local/opt/go; do
        if [[ -x "$p/bin/go" ]]; then
            EXISTING_GO="$p"
            EXISTING_GO_SOURCE="system-installed"
            break
        fi
    done
fi

# Go binary found in PATH
if [[ -z "$EXISTING_GO" ]] && command -v go &>/dev/null; then
    EXISTING_GO=$(dirname "$(dirname "$(command -v go)")")
    EXISTING_GO_SOURCE="PATH"
fi

if [[ -n "$EXISTING_GO" ]] && [[ -x "$EXISTING_GO/bin/go" ]]; then
    EXISTING_VERSION=$("$EXISTING_GO/bin/go" version 2>/dev/null | grep -oE 'go[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown")
    echo ""
    echo -e "${YELLOW}⚠️  $(msg existing_go_detected)${NC}"
    echo "    $(msg existing_go_path)   : $EXISTING_GO"
    echo "    $(msg existing_go_source) : $EXISTING_GO_SOURCE"
    echo "    $(msg existing_go_version): $EXISTING_VERSION"
    echo ""
    msg existing_go_warn "${GO_VERSIONS_DIR:-/usr/local}"
    echo ""
    if [[ "$EXISTING_GO_SOURCE" == "Homebrew" ]]; then
        msg existing_go_cleanup_brew
    elif [[ "$EXISTING_GO_SOURCE" == "system-installed" ]]; then
        msg existing_go_cleanup_system "$EXISTING_GO"
    else
        msg existing_go_cleanup_path
    fi
    echo ""
    read -p "$(msg existing_go_continue) " continue_install < /dev/tty
    continue_install=${continue_install:-Y}
    if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
        msg existing_go_abort
        exit 0
    fi
    echo ""
fi

msg install_banner
msg install_prompt_defaults

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
read -p "$(msg install_dir_prompt "$default_install_dir") " user_install_dir < /dev/tty
user_install_dir=${user_install_dir:-$default_install_dir}

default_default_version="1.26.4"
read -p "$(msg install_default_version_prompt "$default_default_version") " user_default_version < /dev/tty
user_default_version=${user_default_version:-$default_default_version}

default_min_version="1.21"
read -p "$(msg install_min_version_prompt "$default_min_version") " user_min_version < /dev/tty
user_min_version=${user_min_version:-$default_min_version}

# Detect region-appropriate default mirror
detect_region_mirror() {
    local lang="${LC_ALL:-$LANG}"
    case "$lang" in
        zh_CN*) echo "https://golang.google.cn/dl" ;;
        *)      echo "https://go.dev/dl" ;;
    esac
}
default_mirror=$(detect_region_mirror)
read -p "$(msg install_mirror_prompt "$default_mirror") " user_mirror < /dev/tty
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

echo -e "${GREEN}$(msg install_config_saved "$INSTALL_DIR/defaults.sh")${NC}"

RC_FILE=$(detect_rc_file)

# ---------- Detect and handle old Go installation (scan all common config files) ----------
OLD_FILES=()

for f in "${ALL_RC_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        if grep -qE 'export GOROOT=|GOROOT/bin' "$f" 2>/dev/null; then
            OLD_FILES+=("$f")
        fi
    fi
done

if [[ ${#OLD_FILES[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  $(msg old_config_detected)${NC}"
    for f in "${OLD_FILES[@]}"; do
        echo "    $f"
        grep -nE 'export GOROOT=|GOROOT/bin' "$f" 2>/dev/null | while read line; do
            echo "      $line"
        done
    done
    echo ""
    msg old_config_warn
    read -p "$(msg old_config_prompt) " comment_old < /dev/tty
    comment_old=${comment_old:-Y}

    if [[ "$comment_old" =~ ^[Yy]$ ]]; then
        for f in "${OLD_FILES[@]}"; do
            line_nums=$(grep -nE 'export GOROOT=|GOROOT/bin' "$f" 2>/dev/null | cut -d: -f1 | sort -rn | uniq)
            while IFS= read -r ln; do
                [[ -z "$ln" ]] && continue
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "${ln}s/^export /# (commented by gv) export /" "$f"
                else
                    sed -i "${ln}s/^export /# (commented by gv) export /" "$f"
                fi
            done <<< "$line_nums"
        done
        echo -e "${GREEN}$(msg old_config_commented)${NC}"
        echo ""
        echo -e "${YELLOW}$(msg vscode_hint)${NC}"
        msg vscode_hint_detail "${user_install_dir:-/usr/local}" "${user_default_version:-1.26.4}"
    else
        msg old_config_kept
    fi
fi

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

echo -e "${GREEN}$(msg install_complete_banner)${NC}"
msg install_source_hint
echo "    source $RC_FILE"
msg install_restart_hint
echo ""
msg install_usage_hint "go-install, go-use, go-list, go-mirror"
