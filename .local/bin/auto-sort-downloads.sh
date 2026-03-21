#!/bin/bash
DOWNLOAD_DIR="$HOME/Downloads"

# 1. Create all designated folders
mkdir -p "$DOWNLOAD_DIR/pdf" \
         "$DOWNLOAD_DIR/images" \
         "$DOWNLOAD_DIR/videos" \
         "$DOWNLOAD_DIR/archives" \
         "$DOWNLOAD_DIR/documents" \
         "$DOWNLOAD_DIR/music" \
         "$DOWNLOAD_DIR/code" \
         "$DOWNLOAD_DIR/datasets" \
         "$DOWNLOAD_DIR/apps" \
         "$DOWNLOAD_DIR/fonts"

# Function to move a file while handling duplicates
move_file() {
    local file="$1"
    local dest_folder="$2"
    local filename=$(basename "$file")
    local dest_path="$dest_folder/$filename"
    local counter=1

    # Check if a file with the same name already exists
    while [ -e "$dest_path" ]; do
        # If it exists, append a number to the filename
        local name="${filename%.*}"
        local ext="${filename##*.}"
        if [ "$name" == "$ext" ]; then # Handle files with no extension
            dest_path="$dest_folder/${name}_$counter"
        else
            dest_path="$dest_folder/${name}_$counter.$ext"
        fi
        counter=$((counter + 1))
    done

    # Move the file to the destination folder with the new name
    mv "$file" "$dest_path"
}

# 2. Sort any files already present in the Downloads folder
sort_existing_files() {
    echo "Sorting existing files in $DOWNLOAD_DIR..."
    find "$DOWNLOAD_DIR" -maxdepth 1 -type f | while read FILE; do
        if [ ! -s "$FILE" ]; then
            continue
        fi

        EXT="${FILE##*.}"
        EXT="${EXT,,}"

        case "$EXT" in
            pdf) move_file "$FILE" "$DOWNLOAD_DIR/pdf/" ;;
            doc|docx|odt|rtf|txt|ppt|pptx|xls|xlsx|ods|odp|odg|epub|md|tex) move_file "$FILE" "$DOWNLOAD_DIR/documents/" ;;
            jpg|jpeg|png|gif|webp|svg|bmp|tiff|tif|ico|heic|raw) move_file "$FILE" "$DOWNLOAD_DIR/images/" ;;
            mp4|mkv|webm|avi|mov|flv|wmv|3gp|ts|vob|m4v) move_file "$FILE" "$DOWNLOAD_DIR/videos/" ;;
            mp3|wav|flac|ogg|aac|wma|m4a|opus|aiff) move_file "$FILE" "$DOWNLOAD_DIR/music/" ;;
            zip|tar|gz|rar|7z|bz2|xz|zst|cab|iso) move_file "$FILE" "$DOWNLOAD_DIR/archives/" ;;
            py|cpp|c|h|hpp|sh|js|ipynb|html|css|ts|jsx|tsx|go|rs|java|rb|php|swift|kt|vue|yaml|yml|toml|r) move_file "$FILE" "$DOWNLOAD_DIR/code/" ;;
            csv|json|xml|sql|tsv|parquet) move_file "$FILE" "$DOWNLOAD_DIR/datasets/" ;;
            appimage|deb|rpm|snap|flatpak) move_file "$FILE" "$DOWNLOAD_DIR/apps/" ;;
            ttf|otf|woff|woff2) move_file "$FILE" "$DOWNLOAD_DIR/fonts/" ;;
        esac
    done
    echo "Existing files sorted."
}

# Handle --sort flag: sort existing files only, then exit
if [ "$1" = "--sort" ] || [ "$1" = "-s" ]; then
    sort_existing_files
    exit 0
fi

sort_existing_files

# 3. Watch for completely written files AND renamed files
inotifywait -m -e close_write,moved_to --format "%w%f" "$DOWNLOAD_DIR" | while read FILE
do
    # Ignore directories and files with size 0
    if [ -d "$FILE" ] || [ ! -s "$FILE" ]; then
        continue
    fi

    # Extract the file extension
    EXT="${FILE##*.}"
    EXT="${EXT,,}"

    # 4. Sort files based on extension
    case "$EXT" in
        pdf) move_file "$FILE" "$DOWNLOAD_DIR/pdf/" ;;
        doc|docx|odt|rtf|txt|ppt|pptx|xls|xlsx|ods|odp|odg|epub|md|tex) move_file "$FILE" "$DOWNLOAD_DIR/documents/" ;;
        jpg|jpeg|png|gif|webp|svg|bmp|tiff|tif|ico|heic|raw) move_file "$FILE" "$DOWNLOAD_DIR/images/" ;;
        mp4|mkv|webm|avi|mov|flv|wmv|3gp|ts|vob|m4v) move_file "$FILE" "$DOWNLOAD_DIR/videos/" ;;
        mp3|wav|flac|ogg|aac|wma|m4a|opus|aiff) move_file "$FILE" "$DOWNLOAD_DIR/music/" ;;
        zip|tar|gz|rar|7z|bz2|xz|zst|cab|iso) move_file "$FILE" "$DOWNLOAD_DIR/archives/" ;;
        py|cpp|c|h|hpp|sh|js|ipynb|html|css|ts|jsx|tsx|go|rs|java|rb|php|swift|kt|vue|yaml|yml|toml|r) move_file "$FILE" "$DOWNLOAD_DIR/code/" ;;
        csv|json|xml|sql|tsv|parquet) move_file "$FILE" "$DOWNLOAD_DIR/datasets/" ;;
        appimage|deb|rpm|snap|flatpak) move_file "$FILE" "$DOWNLOAD_DIR/apps/" ;;
        ttf|otf|woff|woff2) move_file "$FILE" "$DOWNLOAD_DIR/fonts/" ;;
    esac
done
