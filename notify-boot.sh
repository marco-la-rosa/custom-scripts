#!/bin/bash

# uploading variables
set -a
source .env
set +a


TOKEN="$TELEGRAM_TOKEN"
CHAT_ID="$TELEGRAM_CHAT_ID"

MESSAGE="🟢Il *Necronomicon* è al tuo servizio.🟢"

curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage \
    -d chat_id="$CHAT_ID" \
    -d parse_mode="Markdown" \
    -d text="$MESSAGE"

