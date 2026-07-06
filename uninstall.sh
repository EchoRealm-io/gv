#!/bin/bash
# gv - Go Version Manager - Uninstaller (cross‑platform, interactive)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

INSTALL_DIR="$HOME/.go-version-manager"

# Download latest i18n for up-to-date uninstall messages
TMP_I18N="/tmp/gv-uninstall-i18n-$$.sh"
curl -fsSL "https://raw.githubusercontent.com/EchoRealm-io/gv/main/src/i18n.sh" -o "$TMP_I18N" 2>/dev/null && {
    source "$TMP_I18N"
    rm -f "$TMP_I18N"
} || {
    # Fallback: use local i18n if download fails
    rm -f "$TMP_I18N"
    if [[ -f "$INSTALL_DIR/i18n.sh" ]]; then
        source "$INSTALL_DIR/i18n.sh"
    else
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
            uninstall_cleanup_note) echo "If installed via git clone, you may delete the cloned directory; curl installs leave no local files" ;;
            *) echo "" ;;
        esac; }
    fi
}

# Detect shell config files
ALL_RC_FILES=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.profile")

# Detect GO_VERSIONS_DIR from defaults.sh
GO_VERSIONS_DIR="/usr/local"
if [[ -f "$INSTALL_DIR/defaults.sh" ]]; then
    GO_VERSIONS_DIR=$(grep '^export GO_VERSIONS_DIR=' "$INSTALL_DIR/defaults.sh" 2>/dev/null | cut -d'"' -f2 || echo "/usr/local")
fi

echo ""
echo -e "${YELLOW}$(msg uninstall_banner)${NC}"
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
        echo ""
        for v in "${versions[@]}"; do
            echo "$(msg uninstall_removing): $GO_VERSIONS_DIR/$v"
            sudo rm -rf "$GO_VERSIONS_DIR/$v" && echo -e "  ${GREEN}✅ $v $(msg uninstall_removed)${NC}" || echo -e "  ${RED}⚠️  $v failed${NC}"
        done
        echo ""
    fi
fi

# Step 2: Remove gv manager files
echo "$(msg uninstall_removing) gv files..."
rm -rf "$INSTALL_DIR" && echo -e "  ${GREEN}✅ $INSTALL_DIR${NC}"
rm -f "$HOME/bin/go" && echo -e "  ${GREEN}✅ $HOME/bin/go${NC}"
rm -f "$HOME/.go_current_version" && echo -e "  ${GREEN}✅ $HOME/.go_current_version${NC}"
echo ""

# Step 3: Clean shell config
echo "$(msg uninstall_cleaning_config)"

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
    echo -e "  ${GREEN}✅ shell config $(msg uninstall_removed)${NC}"
else
    echo -e "  ${GREEN}✅ shell config $(msg uninstall_clean)${NC}"
fi
echo ""

echo -e "${GREEN}$(msg uninstall_done)${NC}"
echo ""
msg uninstall_cleanup_note
