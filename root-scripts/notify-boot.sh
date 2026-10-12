#!/usr/bin/env bash

ENV_FILE="${NECRONOMICON_ENV:-/etc/necronomicon.env}"
if [[ -r "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE"; set +a
fi

MESSAGE="🟢Il *Necronomicon* è al tuo servizio.🟢"

if [[ -n "${TELEGRAM_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]]; then
    for i in 1 2 3 4 5; do
        if curl -sf --max-time 15 -X POST \
            "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
            --data-urlencode chat_id="$TELEGRAM_CHAT_ID" \
            --data-urlencode parse_mode="Markdown" \
            --data-urlencode text="$MESSAGE" > /dev/null; then
            break
        fi
        sleep 10
    done
fi

exit 0
