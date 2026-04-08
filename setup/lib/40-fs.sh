#!/usr/bin/env sh
# Filesystem helpers: directories, files, idempotent writes.

# Create directory
ensure_dir() {
    local dir="$1"
    local mode="${2:-0755}"
    local owner="${3:-}"

    if [ -d "$dir" ]; then
        _info "Directory already exists: $dir"
        return 0
    fi

    _info "Creating directory: $dir"
    _run mkdir -p "$dir" || _die "Failed to create directory: $dir"

    [ -n "$mode" ] && _run chmod "$mode" "$dir"
    [ -n "$owner" ] && _run chown "$owner" "$dir"
}

# Backup file if exists
backup_file() {
    local file="$1"
    local backup_ext="${2:-.bak}"

    if [ ! -f "$file" ]; then
        return 0
    fi

    local backup="${file}${backup_ext}"
    if [ ! -f "$backup" ]; then
        _info "Backing up: $file -> $backup"
        _run cp "$file" "$backup" || _warn "Failed to backup: $file"
    else
        _info "Backup already exists: $backup"
    fi
}

# Compare files (returns true if identical)
files_equal() {
    local f1="$1"
    local f2="$2"

    if [ ! -f "$f1" ] || [ ! -f "$f2" ]; then
        return 1
    fi

    cmp -s "$f1" "$f2"
}

# Write file (idempotent: only if content differs)
write_file() {
    local file="$1"
    local mode="${2:-0644}"
    local owner="${3:-}"
    local backup="${4:-}"

    # Read content from stdin
    local temp
    temp=$(mktemp) || _die "Failed to create temp file"
    trap "rm -f '$temp'" EXIT

    cat > "$temp"

    # Check if content changed
    if [ -f "$file" ] && files_equal "$file" "$temp"; then
        _info "File unchanged: $file"
        rm -f "$temp"
        return 0
    fi

    # Backup if requested
    if [ -n "$backup" ] && [ -f "$file" ]; then
        backup_file "$file" "$backup"
    fi

    # Ensure parent dir
    local dir
    dir=$(dirname "$file")
    [ -d "$dir" ] || _run mkdir -p "$dir"

    # Write file
    _info "Writing file: $file"
    _run cp "$temp" "$file" || _die "Failed to write file: $file"

    [ -n "$mode" ] && _run chmod "$mode" "$file"
    [ -n "$owner" ] && _run chown "$owner" "$file"

    rm -f "$temp"
}

# Write file from stdin (helper for heredoc usage in modules)
# Usage: write_file_root /etc/... 0644 root:root < file_or_heredoc
write_file_root() {
    local file="$1"
    local mode="${2:-0644}"
    local owner="${3:-root:root}"

    ensure_dir "$(dirname "$file")" 0755 root:root
    write_file "$file" "$mode" "$owner"
}
