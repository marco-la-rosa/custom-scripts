#!/bin/bash

# uploading variables
set -a
source .env
set +a


TOKEN="$TELEGRAM_TOKEN"
CHAT_ID="$TELEGRAM_CHAT_ID"

MESSAGE="🔴Il *Necronomicon* si deve riposare. La sua conoscenza non è illimitata. Buona notte!🔴"

# sending me a msg
curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage \
    -d chat_id="$CHAT_ID" \
    -d parse_mode="Markdown" \
    -d text="$MESSAGE"

# 2 sec of pause
sleep 2

# actually shutting down
/sbin/shutdown -h now

