#!/bin/bash

# uploading variables
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
set -a; source "$SCRIPT_DIR/.env"; set +a

# if directory doesn't exist yet
mkdir -p "$EXPORT_DIR"

# find img or video
find "$IMMICH_DATA" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.mp4" -o -iname "*.mov" \) | while read FILE; do
    # reads true date from metadata EXIF
    DATE=$(exiftool -d "%Y/%m/%d" -DateTimeOriginal -s3 "$FILE")
    
    # otherwise use modify file date
    if [ -z "$DATE" ]; then
        DATE=$(date -r "$FILE" "+%Y/%m/%d")
    fi

    # making dest directory
    DEST="$EXPORT_DIR/$DATE"
    mkdir -p "$DEST"

    BASENAME=$(basename "$FILE")
    DEST_FILE="$DEST/$BASENAME"

    # creates hard link
    if [ ! -e "$DEST_FILE" ]; then
        ln "$FILE" "$DEST_FILE"
        echo "Link creato: $DEST_FILE"
    fi
done

echo "Struttura leggibile aggiornata in $EXPORT_DIR usando hard link!"

