#!/usr/bin/env sh
# Build a self-contained setup.sh bundle to stdout.
# Order: setup/lib/*.sh -> setup/modules/*.sh -> setup/setup.sh
# Output is deterministic and includes section markers.

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SETUP_DIR="$ROOT_DIR/setup"

ENTRY="$SETUP_DIR/setup.sh"
LIB_DIR="$SETUP_DIR/lib"
MOD_DIR="$SETUP_DIR/modules"

die() { printf '%s\n' "[build] error: $*" >&2; exit 1; }
warn() { printf '%s\n' "[build] warn: $*" >&2; }

[ -r "$ENTRY" ] || die "missing entrypoint: setup/setup.sh"

# Deterministic list helper: prints existing files matching a glob, sorted.
list_sorted() {
    # Usage: list_sorted "/path/glob/*.sh"
    # If no match, print nothing.
    set +e
    for f in $1; do
        [ -f "$f" ] && printf '%s\n' "$f"
    done | LC_ALL=C sort
    set -e
}

# Best-effort: detect top-level "exit" statements (ignoring comments/blank lines).
check_no_toplevel_exit() {
    file="$1"

    # Remove:
    #  - blank lines
    #  - full-line comments
    #  - inline comments (best effort)
    #
    # Then flag lines that start with optional whitespace + exit [digit]...
    # This is intentionally conservative.
    if sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$file" \
        | grep -nE '^[[:space:]]*exit([[:space:]]+|$)' >/dev/null 2>&1
    then
        die "found top-level 'exit' in $file (modules/libs must not call exit at top-level)"
    fi
}

# Compute build SHA if available
BUILD_SHA=""
if command -v git >/dev/null 2>&1 && [ -d "$ROOT_DIR/.git" ]; then
    # If this fails, keep empty
    BUILD_SHA="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || true)"
fi

# Collect files
LIB_FILES="$(list_sorted "$LIB_DIR/*.sh" || true)"
MOD_FILES="$(list_sorted "$MOD_DIR/*.sh" || true)"

# Validate files (entry + all libs/modules)
check_no_toplevel_exit "$ENTRY"
for f in $LIB_FILES $MOD_FILES; do
    check_no_toplevel_exit "$f"
done

# Emit bundle
cat <<EOF
#!/usr/bin/env sh
# This file is GENERATED. Do not edit by hand.
# Source: $ROOT_DIR
# Build SHA: ${BUILD_SHA}

set -eu

SETUP_BUILD_SHA='${BUILD_SHA}'

EOF

emit_file() {
    path="$1"
    rel="${path#"$ROOT_DIR"/}"

    printf '%s\n' "# --- file: $rel ---"
    cat "$path"

    # Ensure a newline after each file chunk
    printf '\n'
}

# lib -> modules -> entry
for f in $LIB_FILES; do
    emit_file "$f"
done

for f in $MOD_FILES; do
    emit_file "$f"
done

emit_file "$ENTRY"

# Ensure output ends with newline (already does, but keep explicit)
printf '\n'
