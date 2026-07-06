#!/bin/bash
# ==================== Core management functions ====================

# Fallbacks (normally exported by defaults.sh; ensure standalone sourcing still works)
: "${GO_CURRENT_VERSION_FILE:=$HOME/.go_current_version}"
: "${GO_VERSIONS_DIR:=/usr/local}"

# Default mirror list (go.dev first for complete version history; region mirrors for speed)
: "${GO_DOWNLOAD_BASE_URL:=https://go.dev/dl}"
# Always ensure fallback mirrors exist (covers old defaults.sh that only set go.dev)
if [[ -z "$GO_DOWNLOAD_MIRRORS" ]] || [[ " $GO_DOWNLOAD_MIRRORS " != *" mirrors.aliyun.com "* ]]; then
    _DEFAULT_MIRRORS="https://go.dev/dl https://mirrors.aliyun.com/golang https://golang.google.cn/dl"
    GO_DOWNLOAD_MIRRORS="${GO_DOWNLOAD_MIRRORS:+$GO_DOWNLOAD_MIRRORS }$_DEFAULT_MIRRORS"
    # Deduplicate
    _unique=""
    for _m in $GO_DOWNLOAD_MIRRORS; do
        [[ " $_unique " != *" $_m "* ]] && _unique="$_unique $_m"
    done
    GO_DOWNLOAD_MIRRORS="${_unique# }"
fi

# ---------- Show/set download mirrors ----------
# gv-mirror              : show all mirrors
# gv-mirror set <url>    : set as primary mirror
# gv-mirror add <url>    : add mirror to list
gv-mirror() {
    local cmd="${1:-}"
    local url="${2:-}"

    if [[ -z "$cmd" ]]; then
        msg mirror_list
        local i=1
        for m in $GO_DOWNLOAD_MIRRORS; do
            local mark=""
            [[ "$m" == "$GO_DOWNLOAD_BASE_URL" ]] && mark=" ← $(msg mirror_current_mark)"
            echo "  $i. $m$mark"
            ((i++))
        done
        return 0
    fi

    case "$cmd" in
        set)
            if [[ -z "$url" ]]; then
                msg mirror_usage
                msg mirror_example
                return 1
            fi
            _persist_mirrors "$url $GO_DOWNLOAD_MIRRORS"
            GO_DOWNLOAD_BASE_URL="$url"
            msg mirror_set "$url"
            msg mirror_reload
            ;;
        add)
            if [[ -z "$url" ]]; then
                msg mirror_usage
                msg mirror_example
                return 1
            fi
            # Don't add duplicates
            if echo "$GO_DOWNLOAD_MIRRORS" | grep -qF "$url"; then
                msg mirror_already_exists "$url"
                return 0
            fi
            _persist_mirrors "$GO_DOWNLOAD_MIRRORS $url"
            GO_DOWNLOAD_MIRRORS="$GO_DOWNLOAD_MIRRORS $url"
            msg mirror_added "$url"
            msg mirror_reload
            ;;
        *)
            # Assume it's a URL (backward compat: gv-mirror <url>)
            _persist_mirrors "$cmd $GO_DOWNLOAD_MIRRORS"
            GO_DOWNLOAD_BASE_URL="$cmd"
            msg mirror_set "$cmd"
            msg mirror_reload
            ;;
    esac
}

_persist_mirrors() {
    local mirrors="$1"
    local rc_file
    if [[ -n "$ZSH_VERSION" ]]; then rc_file="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        case "$OSTYPE" in
            linux*) rc_file="$HOME/.bashrc" ;;
            *) [[ -f "$HOME/.bash_profile" ]] && rc_file="$HOME/.bash_profile" || rc_file="$HOME/.bashrc" ;;
        esac
    else rc_file="$HOME/.profile"; fi
    # Remove duplicate entries, keep unique in order
    local unique=""
    for m in $mirrors; do
        [[ " $unique " != *" $m "* ]] && unique="$unique $m"
    done
    unique="${unique# }"
    sed -i.bak "/export GO_DOWNLOAD_MIRRORS=/d" "$rc_file" 2>/dev/null || true
    sed -i.bak "/export GO_DOWNLOAD_BASE_URL=/d" "$rc_file" 2>/dev/null || true
    echo "export GO_DOWNLOAD_MIRRORS=\"$unique\"" >> "$rc_file"
    echo "export GO_DOWNLOAD_BASE_URL=\"$(echo "$unique" | awk '{print $1}')\"" >> "$rc_file"
    export GO_DOWNLOAD_MIRRORS="$unique"
    export GO_DOWNLOAD_BASE_URL="$(echo "$unique" | awk '{print $1}')"
}

# ---------- Fetch available Go versions (try all mirrors) ----------
_fetch_go_versions() {
    local mirrors="${GO_DOWNLOAD_MIRRORS:-https://go.dev/dl}"
    for mirror in $mirrors; do
        local result
        # Try HTML page first (has full version history, unlike JSON API which only returns latest 2)
        echo "  \$ curl -sSL ${mirror}/" >&2
        result=$(curl -sSL --connect-timeout 5 "${mirror}/" 2>/dev/null | \
            grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+\.[a-z]' | \
            sed 's/go//; s/\.[a-z]$//' | sort -Vru)
        if [[ -n "$result" ]]; then
            echo "$result"
            echo "  ← ${mirror} (HTML)" >&2
            return 0
        fi
        # Fallback: try JSON API
        echo "  \$ curl -sSL ${mirror}/?mode=json" >&2
        result=$(curl -sSL --connect-timeout 5 "${mirror}/?mode=json" 2>/dev/null | tr -d '[:space:]' | \
            grep -oE '"version":"go[0-9]+\.[0-9]+(\.[0-9]+)?","stable":true' | \
            sed 's/"version":"go//;s/","stable":true//' | sort -Vr)
        if [[ -n "$result" ]]; then
            echo "$result"
            echo "  ← ${mirror} (JSON)" >&2
            return 0
        fi
    done
    return 1
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
    local tmp_file="/tmp/$pkg_name"
    local mirrors="${GO_DOWNLOAD_MIRRORS:-https://go.dev/dl}"

    local downloaded=0
    for mirror in $mirrors; do
        local download_url="$mirror/$pkg_name"
        msg download_start "$download_url"
        echo "  \$ curl -L --connect-timeout 10 --max-time 120 -o $tmp_file $download_url"
        if curl -L --connect-timeout 10 --max-time 120 --progress-bar "$download_url" -o "$tmp_file"; then
            downloaded=1
            echo "  ✅ $(msg download_ok): $mirror" >&2
            break
        fi
        echo "  ⚠️  $(msg download_fallback)" >&2
        rm -f "$tmp_file"
    done

    if [[ $downloaded -eq 0 ]]; then
        msg download_fail
        return 1
    fi

    if [[ "$GO_OS" == "windows" ]]; then
        local tmp_extract="/tmp/go_extract_$$"
        echo "  \$ mkdir -p $tmp_extract"
        mkdir -p "$tmp_extract"
        echo "  \$ cd $tmp_extract && $GO_UNPACK_CMD $tmp_file"
        (cd "$tmp_extract" && $GO_UNPACK_CMD "$tmp_file")
        echo "  \$ mkdir -p $target_dir && mv $tmp_extract/go/* $target_dir/"
        mkdir -p "$target_dir"
        mv "$tmp_extract"/go/* "$target_dir/" 2>/dev/null || mv "$tmp_extract"/* "$target_dir/"
        echo "  \$ rm -rf $tmp_extract"
        rm -rf "$tmp_extract"
    else
        echo "$(msg extract_sudo "$target_dir")"
        echo "  \$ sudo mkdir -p $target_dir"
        sudo mkdir -p "$target_dir"
        echo "  \$ sudo $GO_UNPACK_CMD $tmp_file -C $target_dir --strip-components=1"
        sudo $GO_UNPACK_CMD "$tmp_file" -C "$target_dir" --strip-components=1
    fi
    echo "  \$ rm -f $tmp_file"
    rm -f "$tmp_file"
    msg install_complete "$target_dir"
}

# ---------- Install a specific version ----------
# gv-install               : interactive online selection (major → patch)
# gv-install 1.26           : install latest stable patch for 1.26.x
# gv-install 1.26.4         : install exact version
gv-install() {
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
        local majors i choice
        majors=($(echo "$all_versions" | cut -d. -f1,2 | sort -Vru | uniq))
        msg select_major
        for i in "${!majors[@]}"; do
            echo "  $((i+1)). ${majors[$i]}"
        done
        msg version_prompt
        echo -n "> "
        read -r choice < /dev/tty
        [[ "$choice" =~ ^[qQ]$ ]] && return 0
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
        msg version_prompt
        echo -n "> "
        read -r choice < /dev/tty
        [[ "$choice" =~ ^[qQ]$ ]] && return 0
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
gv-list() {
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
# gv-use <version>          : switch for current shell session only
# gv-use -g <version>       : switch and persist (new terminals inherit it)
gv-use() {
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

# ---------- Show help ----------
gv-help() {
    echo "gv - Go Version Manager"
    echo ""
    msg help_usage
    echo ""
    echo "  gv-install [<version>]  $(msg help_go_install)"
    echo "  gv-use [-g] <version>   $(msg help_go_use)"
    echo "  gv-list                 $(msg help_go_list)"
    echo "  gv-mirror [set|add <url>] $(msg help_go_mirror)"
    echo "  gv-help                 $(msg help_go_help)"
    echo ""
    msg help_config
    echo "  GO_VERSIONS_DIR      $(msg help_config_dir)"
    echo "  DEFAULT_GO_VERSION   $(msg help_config_default)"
    echo "  MIN_GO_VERSION       $(msg help_config_min)"
    echo "  GO_DOWNLOAD_BASE_URL $(msg help_config_mirror)"
    echo ""
    msg help_tips
    echo "  $(msg help_tip1)"
    echo "  $(msg help_tip2)"
    echo "  $(msg help_tip3)"
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
