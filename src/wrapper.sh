#!/bin/bash
# Smart Go wrapper - automatically selects version based on go.mod

MIN_GO_VERSION="${MIN_GO_VERSION:-1.21}"
DEFAULT_GO_VERSION="${DEFAULT_GO_VERSION:-1.26.4}"
if [[ "$OSTYPE" == *"msys"* || "$OSTYPE" == *"cygwin"* ]]; then
    GO_VERSIONS_DIR="${GO_VERSIONS_DIR:-$HOME/.go-versions}"
else
    GO_VERSIONS_DIR="${GO_VERSIONS_DIR:-/usr/local}"
fi

find_go_version() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/go.mod" ]]; then
            version=$(grep -E '^go [0-9]+\.[0-9]+' "$dir/go.mod" | awk '{print $2}')
            if [[ -n "$version" ]]; then
                echo "$version"
                return 0
            fi
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

version_lt_min() {
    local ver="$1"
    local min="$MIN_GO_VERSION"
    local v_major=$(echo "$ver" | cut -d. -f1)
    local v_minor=$(echo "$ver" | cut -d. -f2)
    local m_major=$(echo "$min" | cut -d. -f1)
    local m_minor=$(echo "$min" | cut -d. -f2)
    if (( v_major < m_major )); then
        return 0
    elif (( v_major == m_major && v_minor < m_minor )); then
        return 0
    else
        return 1
    fi
}

find_installed_version() {
    local major_ver="$1"
    local pattern="$GO_VERSIONS_DIR/go$major_ver*"
    local found=$(ls -d $pattern 2>/dev/null | sort -V | tail -n1)
    if [[ -d "$found" && -x "$found/bin/go" ]]; then
        echo "$found"
        return 0
    fi
    return 1
}

version=$(find_go_version)

if [[ -n "$version" ]]; then
    if version_lt_min "$version"; then
        echo "⚠️  go.mod version $version < $MIN_GO_VERSION, auto-upgrading to $MIN_GO_VERSION" >&2
        version="$MIN_GO_VERSION"
    fi

    go_dir="$GO_VERSIONS_DIR/go$version"
    if [[ ! -d "$go_dir" || ! -x "$go_dir/bin/go" ]]; then
        major_ver=$(echo "$version" | cut -d. -f1,2)
        go_dir=$(find_installed_version "$major_ver")
    fi

    if [[ -n "$go_dir" && -x "$go_dir/bin/go" ]]; then
        export GOROOT="$go_dir"
        exec "$go_dir/bin/go" "$@"
    else
        echo "❌ Version $version not installed, run go-install $version" >&2
        default_go="$GO_VERSIONS_DIR/go$DEFAULT_GO_VERSION/bin/go"
        if [[ -x "$default_go" ]]; then
            echo "⚠️  Falling back to default $DEFAULT_GO_VERSION" >&2
            export GOROOT="$GO_VERSIONS_DIR/go$DEFAULT_GO_VERSION"
            exec "$default_go" "$@"
        else
            echo "❌ No usable Go found" >&2
            exit 1
        fi
    fi
else
    default_go="$GO_VERSIONS_DIR/go$DEFAULT_GO_VERSION/bin/go"
    if [[ -x "$default_go" ]]; then
        export GOROOT="$GO_VERSIONS_DIR/go$DEFAULT_GO_VERSION"
        exec "$default_go" "$@"
    else
        echo "❌ No default Go installation" >&2
        exit 1
    fi
fi
