#!/bin/bash
# ==================== Core management functions ====================

# Fallbacks (normally exported by defaults.sh; ensure standalone sourcing still works)
: "${GO_CURRENT_VERSION_FILE:=$HOME/.go_current_version}"
: "${GO_VERSIONS_DIR:=/usr/local}"

# ---------- Show/set download mirror ----------
go-mirror() {
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

# ---------- Fetch available Go versions from the mirror ----------
_fetch_go_versions() {
    local url="${GO_DOWNLOAD_BASE_URL}/?mode=json"
    curl -sSL "$url" 2>/dev/null | tr -d '[:space:]' | \
        grep -oE '"version":"go[0-9]+\.[0-9]+(\.[0-9]+)?","stable":true' | \
        sed 's/"version":"go//;s/","stable":true//' | sort -Vr
}

# ---------- Internal: download and extract a Go release ----------
_go_install_version() {
    local version="$1"
    local target_dir="$GO_VERSIONS_DIR/go$version"

    if [[ -d "$target_dir" ]]; then
        msg version_installed "$version" "$target_dir"
        return 0
    fi

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

    if [[ "$GO_OS" == "windows" ]]; then
        local tmp_extract="/tmp/go_extract_$$"
        mkdir -p "$tmp_extract"
        (cd "$tmp_extract" && $GO_UNPACK_CMD "$tmp_file")
        mkdir -p "$target_dir"
        mv "$tmp_extract"/go/* "$target_dir/" 2>/dev/null || mv "$tmp_extract"/* "$target_dir/"
        rm -rf "$tmp_extract"
    else
        echo "$(msg extract_sudo "$target_dir")"
        sudo mkdir -p "$target_dir"
        sudo $GO_UNPACK_CMD "$tmp_file" -C "$target_dir" --strip-components=1
    fi
    rm -f "$tmp_file"
    msg install_complete "$target_dir"
}

# ---------- Install a specific version ----------
# go-install               : interactive online selection (major → patch)
# go-install 1.26           : install latest stable patch for 1.26.x
# go-install 1.26.4         : install exact version
go-install() {
    local version="${1#go}"
    local latest

    # Full version given (X.Y.Z) — install directly
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        _go_install_version "$version"
        return $?
    fi

    # Major.minor given (X.Y) — find latest patch and install
    if [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
        msg fetch_version_list
        local all_versions
        all_versions="$(_fetch_go_versions)"
        if [[ -z "$all_versions" ]]; then
            msg fetch_version_fail
            return 1
        fi
        latest=$(echo "$all_versions" | grep "^${version}\." | head -1)
        if [[ -z "$latest" ]]; then
            msg version_invalid
            return 1
        fi
        msg latest_found "$latest"
        _go_install_version "$latest"
        return $?
    fi

    # No version given — interactive online selection
    if [[ -z "$version" ]]; then
        msg fetch_version_list
        local all_versions
        all_versions="$(_fetch_go_versions)"
        if [[ -z "$all_versions" ]]; then
            msg fetch_version_fail
            return 1
        fi

        # Step 1: pick major.minor
        local majors i
        majors=($(echo "$all_versions" | cut -d. -f1,2 | sort -Vru | uniq))
        msg select_major
        for i in "${!majors[@]}"; do
            echo "  $((i+1)). ${majors[$i]}"
        done
        read -r -p "$(msg version_prompt) " choice < /dev/tty
        if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#majors[@]} )); then
            msg version_invalid
            return 1
        fi
        local selected_major="${majors[$((choice-1))]}"

        # Step 2: pick patch for that major.minor
        local patches
        patches=($(echo "$all_versions" | grep "^${selected_major}\."))
        msg select_patch "$selected_major"
        for i in "${!patches[@]}"; do
            echo "  $((i+1)). ${patches[$i]}"
        done
        read -r -p "$(msg version_prompt) " choice < /dev/tty
        if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#patches[@]} )); then
            msg version_invalid
            return 1
        fi
        _go_install_version "${patches[$((choice-1))]}"
        return $?
    fi

    msg go_install_usage
    return 1
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
# go-use <version>          : switch for current shell session only
# go-use -g <version>       : switch and persist (new terminals inherit it)
go-use() {
    local persistent=0
    local version=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -g|--global) persistent=1; shift ;;
            --) shift; version="${1:-}"; break ;;
            -*) msg switch_usage; return 1 ;;
            *) version="$1"; shift ;;
        esac
    done
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
    if [[ $persistent -eq 1 ]]; then
        echo "$version" > "$GO_CURRENT_VERSION_FILE"
        msg switch_persisted "$version"
    else
        msg switch_success "$version"
    fi
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
