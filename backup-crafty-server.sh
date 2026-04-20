#!/bin/bash

# uploading variables
set -a
source .env
set +a

# if it doesn't already exist
mkdir -p "$BACKUP_DIR"

# compress directory
tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"

# keeping only the most recent 4 files
ls -tp "$BACKUP_DIR"/server_eb4d6826_backup_*.tar.gz | grep -v '/$' | tail -n +5 | xargs -r rm --
