#!/usr/bin/env bash

ENV_FILE="${NECRONOMICON_ENV:-/etc/necronomicon.env}"
if [[ -r "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE"; set +a
fi

MESSAGE="🔴Il *Necronomicon* si deve riposare. Buona notte!🔴"

if [[ -n "${TELEGRAM_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]]; then
    curl -s --max-time 30 -X POST \
        "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        --data-urlencode chat_id="$TELEGRAM_CHAT_ID" \
        --data-urlencode parse_mode="Markdown" \
        --data-urlencode text="$MESSAGE" > /dev/null || true
fi

sleep 2

# /sbin/shutdown -h now
