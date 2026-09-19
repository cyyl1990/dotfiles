#!/usr/bin/env bash
# ==============================================================================
# WALLPAPER MIME-TYPE SANITIZER (MANIFEST / BATCH EDITION)
# ==============================================================================
# Description: Two-phase strict MIME-type sanitizer. Builds an immutable
#              manifest to prevent filesystem walk race conditions, then
#              batches parsing via libmagic for maximum throughput.
# ==============================================================================

set -Eeuo pipefail
export LC_ALL=C

# --- CONFIGURATION ---
TARGET_DIR="."
DRY_RUN=true
APPLY=false
ALLOWED_DIRS=("$HOME/Pictures" "$HOME/Downloads")

# --- ARGS ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --apply) APPLY=true ;;
        --dry-run) DRY_RUN=true ;;
        -h|--help)
            cat << EOF
Usage: ${0##*/} [OPTIONS] [DIR]
  MIME-type sanitizer: renames image files to their real extension.
  SAFETY: dry-run (preview only) is the default. Pass --apply to rename,
  and only when DIR is inside an allowlisted directory.
Options:
  --apply       Actually rename files
  --dry-run     Preview only (default)
  -h, --help    Show this help
EOF
            exit 0 ;;
        -*) die "Unknown option: $1" ;;
        *) TARGET_DIR="$1" ;;
    esac
    shift
done

[[ "$APPLY" == true ]] && DRY_RUN=false

# --- SAFETY GUARD ---
# Refuse real (applied) renames unless the resolved target is inside an
# allowlisted location. Dry-run preview is always allowed.
in_allowlist() {
    local target base
    target="$(realpath -m "$TARGET_DIR" 2>/dev/null || printf '%s' "$TARGET_DIR")"
    for base in "${ALLOWED_DIRS[@]}"; do
        base="$(realpath -m "$base" 2>/dev/null || printf '%s' "$base")"
        [[ "$target" == "$base" || "$target" == "$base/"* ]] && return 0
    done
    return 1
}

# --- HELPERS ---
log()  { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; }
die()  { err "$*"; exit 1; }

# Dependency check
for cmd in find file xargs mv mktemp realpath; do
    command -v "$cmd" >/dev/null 2>&1 || die "Missing dependency: $cmd"
done

[[ -d "$TARGET_DIR" ]] || die "Target directory does not exist: $TARGET_DIR"

if [[ "$DRY_RUN" == false ]] && ! in_allowlist; then
    die "Refusing to apply outside allowlisted dirs. Allowed: ${ALLOWED_DIRS[*]}"
fi
if [[ "$DRY_RUN" == true ]]; then
    log "DRY RUN - preview only (pass --apply to rename)"
fi

# Prevent find/xargs flag injection
SCAN_ROOT="$TARGET_DIR"
[[ "$SCAN_ROOT" == -* ]] && SCAN_ROOT="./$SCAN_ROOT"

# Temporary files
LOG_FILE=$(mktemp --tmpdir sanitized_wallpapers.XXXXXX.log) || die "mktemp failed"
MANIFEST=$(mktemp --tmpdir sanitized_wallpapers_manifest.XXXXXX.list) || die "mktemp failed"

# Cleanup manifest on exit, keep log
trap 'rm -f -- "$MANIFEST"' EXIT

# Open File Descriptor 3 for high-performance logging (avoids constant open/close I/O)
exec 3>>"$LOG_FILE"

# --- O(1) MIME DICTIONARIES ---
declare -A MIME_EXT_MAP=(
    ["image/jpeg"]="jpg"
    ["image/png"]="png"
    ["image/webp"]="webp"
    ["image/gif"]="gif"
    ["image/avif"]="avif"
    ["image/heic"]="heic"
    ["image/heif"]="heif"
    ["image/jxl"]="jxl"
    ["image/bmp"]="bmp"
    ["image/x-ms-bmp"]="bmp"
    ["image/tiff"]="tiff"
    ["image/svg+xml"]="svg"
)

declare -A MIME_EXT_ALIASES=(
    ["image/jpeg"]="jpg jpeg jpe jfif"
    ["image/heif"]="heif hif"
    ["image/bmp"]="bmp dib"
    ["image/x-ms-bmp"]="bmp dib"
    ["image/tiff"]="tif tiff"
)

# --- METRICS ---
declare -i TOTAL_SCANNED=0
declare -i TOTAL_FIXED=0

log "Phase 1: Building immutable manifest for: $(realpath -- "$TARGET_DIR")"
# -print0 ensures newline/space safety in filenames
find "$SCAN_ROOT" -type f ! -samefile "$LOG_FILE" ! -samefile "$MANIFEST" -print0 > "$MANIFEST"

log "Phase 2: Batch scanning MIME types..."
log "Ledger will be written to: $LOG_FILE"
echo '--------------------------------------------------'

# Process the manifest using xargs to batch calls to 'file'
while IFS= read -r -d '' filepath && IFS= read -r mime_line; do
    ((++TOTAL_SCANNED)) || true

    # Strict string parsing
    mime_type="${mime_line#*:}"
    mime_type="${mime_type//[[:space:]]/}" 

    # Fast O(1) lookup
    if [[ -v "MIME_EXT_MAP[$mime_type]" ]]; then
        canon_ext="${MIME_EXT_MAP[$mime_type]}"
        valid_exts=" ${MIME_EXT_ALIASES[$mime_type]-$canon_ext} "

        filename="${filepath##*/}"
        dirpath="${filepath%/*}"

        case "$filename" in
            .*.*|?*.*)
                ext="${filename##*.}"
                base_name="${filename%.*}"
                ;;
            *)
                ext=""
                base_name="$filename"
                ;;
        esac

        lower_ext="${ext,,}"
        
        # If the file's extension is within the valid aliases, skip it
        [[ "$valid_exts" == *" $lower_ext "* ]] && continue

        dest="${dirpath}/${base_name}.${canon_ext}"
        
        # Skip if the destination is exactly the current file
        [[ "$dest" == "$filepath" ]] && continue

        # Deterministic collision handling
        if [[ -e "$dest" ]]; then
            n=1
            while [[ -e "${dirpath}/${base_name}_${n}.${canon_ext}" ]]; do
                ((++n))
            done
            dest="${dirpath}/${base_name}_${n}.${canon_ext}"
        fi

        # Atomic target rename. mv -T ensures we don't accidentally drop a file into a sub-directory
        if [[ "$DRY_RUN" == true ]]; then
            printf 'Would fix: %q -> %q\n' "$filename" "${dest##*/}"
            printf '[%s] %q -> %q\n' "$mime_type" "$filepath" "$dest" >&3
            ((++TOTAL_FIXED))
        elif mv -T -- "$filepath" "$dest"; then
            printf 'Fixed: %q -> %q\n' "$filename" "${dest##*/}"
            printf '[%s] %q -> %q\n' "$mime_type" "$filepath" "$dest" >&3
            ((++TOTAL_FIXED)) || true
        else
            warn "Failed to rename: $filepath -> $dest"
        fi
    fi
done < <(xargs -0 -a "$MANIFEST" -r file -0 --mime-type --)

echo '--------------------------------------------------'
log "Scan complete."
log "Total scanned: $TOTAL_SCANNED"
log "Total fixed:   $TOTAL_FIXED"
log "Ledger saved:  $LOG_FILE"
[[ "$DRY_RUN" == true ]] && log "DRY RUN - nothing was renamed. Pass --apply to rename."

# Close File Descriptor 3
exec 3>&-
