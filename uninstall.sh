#!/bin/bash
# gv - Go Version Manager - Uninstaller (cross‑platform, interactive)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/.go-version-manager"

# Source i18n if available
if [[ -f "$INSTALL_DIR/i18n.sh" ]]; then
    source "$INSTALL_DIR/i18n.sh"
else
    # Minimal fallback msg if gv was partially removed
    msg() { case "$1" in
        uninstall_banner) echo "=== gv Uninstall ===" ;;
        uninstall_confirm) echo "This will remove gv and all managed Go versions. Continue? [Y/N]" ;;
        uninstall_abort) echo "Aborted." ;;
        uninstall_found_versions) echo "Installed Go versions found:" ;;
        uninstall_remove_prompt) echo "Remove all Go versions under $arg1? [Y/N]" ;;
        uninstall_removing) echo "Removing" ;;
        uninstall_removed) echo "removed" ;;
        uninstall_cleaning_config) echo "Cleaning shell config..." ;;
        uninstall_clean) echo "Already clean" ;;
        uninstall_done) echo "gv has been uninstalled." ;;
        *) echo "" ;;
    esac; }
fi

# Detect shell config files
ALL_RC_FILES=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.profile")

# Detect GO_VERSIONS_DIR from defaults.sh
GO_VERSIONS_DIR="/usr/local"
if [[ -f "$INSTALL_DIR/defaults.sh" ]]; then
    GO_VERSIONS_DIR=$(grep '^export GO_VERSIONS_DIR=' "$INSTALL_DIR/defaults.sh" 2>/dev/null | cut -d'"' -f2 || echo "/usr/local")
fi

echo ""
msg uninstall_banner
echo ""

# List installed Go versions
versions=()
for d in "$GO_VERSIONS_DIR"/go[0-9]*; do
    if [[ -d "$d" ]]; then
        versions+=("$(basename "$d")")
    fi
done

if [[ ${#versions[@]} -gt 0 ]]; then
    msg uninstall_found_versions
    for v in "${versions[@]}"; do
        echo "    $GO_VERSIONS_DIR/$v"
    done
    echo ""
fi

# Step 1: Remove Go versions
if [[ ${#versions[@]} -gt 0 ]]; then
    msg uninstall_remove_prompt "$GO_VERSIONS_DIR"
    echo -n "> "
    read -r do_remove < /dev/tty
    if [[ "$do_remove" =~ ^[Yy]$ ]]; then
        for v in "${versions[@]}"; do
            echo "$(msg uninstall_removing): $GO_VERSIONS_DIR/$v"
            sudo rm -rf "$GO_VERSIONS_DIR/$v" && echo "  ✅ $v $(msg uninstall_removed)" || echo "  ⚠️  $v failed"
        done
        echo ""
    fi
fi

# Step 2: Remove gv manager files
echo "$(msg uninstall_removing): $INSTALL_DIR"
rm -rf "$INSTALL_DIR" && echo "  ✅ $INSTALL_DIR $(msg uninstall_removed)"
rm -f "$HOME/bin/go" && echo "  ✅ $HOME/bin/go $(msg uninstall_removed)"
rm -f "$HOME/.go_current_version" && echo "  ✅ $HOME/.go_current_version $(msg uninstall_removed)"
echo ""

# Step 3: Clean shell config
msg uninstall_cleaning_config

# Patterns added by gv (source lines, ~/bin PATH)
declare -a GV_PATTERNS=(
    "source $INSTALL_DIR/defaults.sh"
    "source $INSTALL_DIR/i18n.sh"
    "source $INSTALL_DIR/core.sh"
    'export PATH="$HOME/bin:$PATH"'
)

cleaned=0
for f in "${ALL_RC_FILES[@]}"; do
    if [[ -f "$f" ]]; then
        # Remove gv-added lines
        for pattern in "${GV_PATTERNS[@]}"; do
            if grep -qF "$pattern" "$f" 2>/dev/null; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "\|$pattern|d" "$f"
                else
                    sed -i "\|$pattern|d" "$f"
                fi
                cleaned=1
            fi
        done
        # Remove lines commented out by gv from original config
        if grep -q '# (commented by gv)' "$f" 2>/dev/null; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' '/# (commented by gv)/d' "$f"
            else
                sed -i '/# (commented by gv)/d' "$f"
            fi
            cleaned=1
        fi
    fi
done

if [[ $cleaned -eq 1 ]]; then
    echo "  ✅ shell config $(msg uninstall_removed)"
else
    echo "  ✅ shell config $(msg uninstall_clean)"
fi
echo ""

msg uninstall_done
echo ""
msg uninstall_cleanup_note
