#!/bin/bash
# ==================== Core management functions ====================

# ---------- Set download mirror ----------
go-set-mirror() {
    local url=$1
    if [[ -z $url ]]; then
        msg mirror_current "$GO_DOWNLOAD_BASE_URL"
        msg mirror_usage
        msg mirror_example
        return 0
    fi
    # Persist to shell config file (~/.bashrc or ~/.zshrc)
    local rc_file
    if [[ -n "$ZSH_VERSION" ]]; then
        rc_file="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        if [[ -f "$HOME/.bash_profile" ]]; then
            rc_file="$HOME/.bash_profile"
        else
            rc_file="$HOME/.bashrc"
        fi
    else
        rc_file="$HOME/.profile"
    fi
    sed -i.bak "/export GO_DOWNLOAD_BASE_URL=/d" "$rc_file" 2>/dev/null || true
    echo "export GO_DOWNLOAD_BASE_URL=\"$url\"" >> "$rc_file"
    export GO_DOWNLOAD_BASE_URL="$url"
    msg mirror_set "$url"
    msg mirror_reload "$rc_file"
}

# ---------- Install a specific version ----------
go-install() {
    local version=$1
    if [[ -z $version ]]; then
        msg go_install_usage
        return 1
    fi

    local target_dir="$GO_VERSIONS_DIR/go$version"
    if [[ -d "$target_dir" ]]; then
        msg version_installed "$version" "$target_dir"
        return 0
    fi

    # Build package name based on OS and architecture
    local os_name="$GO_OS"
    local pkg_name="go$version.$os_name-$GO_ARCH$GO_PKG_EXT"
    local download_url="$GO_DOWNLOAD_BASE_URL/$pkg_name"

    msg download_start "$download_url"

    local tmp_file="/tmp/$pkg_name"
    curl -L "$download_url" -o "$tmp_file" || {
        rm -f "$tmp_file"
        msg download_fail
        return 1
    }

    # Extract to target directory (may require sudo)
    if [[ "$GO_OS" == "windows" ]]; then
        local tmp_extract="/tmp/go_extract_$$"
        mkdir -p "$tmp_extract"
        (cd "$tmp_extract" && $GO_UNPACK_CMD "$tmp_file")
        mkdir -p "$target_dir"
        mv "$tmp_extract"/go/* "$target_dir/" 2>/dev/null || mv "$tmp_extract"/* "$target_dir/"
        rm -rf "$tmp_extract"
        # Re-check: if go/ was stripped and we got the tree directly, we're done
    else
        echo "$(msg extract_sudo "$target_dir")"
        sudo mkdir -p "$target_dir"
        sudo $GO_UNPACK_CMD "$tmp_file" -C "$target_dir" --strip-components=1
    fi
    rm -f "$tmp_file"
    msg install_complete "$target_dir"
}

# ---------- List installed versions ----------
go-list() {
    msg go_list_header
    local current=""
    [[ -f "$GO_CURRENT_VERSION_FILE" ]] && current=$(cat "$GO_CURRENT_VERSION_FILE")
    for dir in "$GO_VERSIONS_DIR"/go[0-9]*; do
        if [[ -d "$dir" ]]; then
            local ver=$(basename "$dir" | sed 's/go//')
            local mark=""
            [[ "$ver" == "$current" ]] && mark="$(msg current_mark)"
            echo "  $ver$mark"
        fi
    done
}

# ---------- Manually switch version ----------
switch_go_version() {
    local version=$1
    version=${version#go}
    if [[ -z $version ]]; then
        msg switch_usage
        return 1
    fi

    local target_dir="$GO_VERSIONS_DIR/go$version"
    if [[ ! -d "$target_dir" ]]; then
        msg version_not_installed "$version"
        return 1
    fi

    if [[ "$GOROOT" == "$target_dir" ]]; then
        msg already_using "$version"
        return 0
    fi

    export GOROOT="$target_dir"
    # Remove any old Go paths from PATH, then prepend new bin
    export PATH="$GOROOT/bin:$(echo "$PATH" | tr ':' '\n' | grep -v "^$GO_VERSIONS_DIR/go[0-9]" | tr '\n' ':' | sed 's/:$//')"
    echo "$version" > "$GO_CURRENT_VERSION_FILE"
    msg switch_success "$version"
    go version
}

# ---------- Auto-load the last used version on shell startup ----------
_auto_load_go_version() {
    if [[ -f "$GO_CURRENT_VERSION_FILE" ]]; then
        local current_version=$(cat "$GO_CURRENT_VERSION_FILE")
        local target_dir="$GO_VERSIONS_DIR/go$current_version"
        if [[ -d "$target_dir" ]]; then
            export GOROOT="$target_dir"
            export PATH="$GOROOT/bin:$(echo "$PATH" | tr ':' '\n' | grep -v "^$GO_VERSIONS_DIR/go[0-9]" | tr '\n' ':' | sed 's/:$//')"
        fi
    fi
}
_auto_load_go_version
