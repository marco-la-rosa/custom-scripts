#!/usr/bin/env bash

ENV_FILE="${NECRONOMICON_ENV:-/etc/necronomicon.env}"
if [[ -r "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE"; set +a
fi

LOG="/tmp/arch_update_$(date +%F_%T).log"
ERROR=0

echo "--- Necronomicon Update ---" > "$LOG"
date >> "$LOG"
echo >> "$LOG"

# check updates
PACMAN_UPDATES=$(checkupdates 2>/dev/null)
YAY_UPDATES=""

if command -v yay >/dev/null 2>&1; then
    YAY_UPDATES=$(yay -Qua 2>/dev/null)
fi

# pacman update
echo "-- Pacman updating --" >> "$LOG"
if ! sudo pacman -Syu --noconfirm --needed >> "$LOG" 2>&1; then
    ERROR=1
fi

# AUR update
if command -v yay >/dev/null 2>&1; then
    echo -e "\n-- AUR updating --" >> "$LOG"
    if ! yay -Syu --noconfirm >> "$LOG" 2>&1; then
        ERROR=1
    fi
fi

# telegram msg
TOKEN="${TELEGRAM_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"

send_msg() {
    local text="${1:0:3900}"
    # prima con Markdown; se Telegram lo rifiuta, riprova come testo semplice
    if ! curl -sf --max-time 30 -X POST \
        "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        --data-urlencode chat_id="$CHAT_ID" \
        --data-urlencode parse_mode="Markdown" \
        --data-urlencode text="$text" > /dev/null; then
        curl -s --max-time 30 -X POST \
            "https://api.telegram.org/bot${TOKEN}/sendMessage" \
            --data-urlencode chat_id="$CHAT_ID" \
            --data-urlencode text="$text" > /dev/null || true
    fi
}

send_file() {
    curl -s --max-time 120 -X POST \
        "https://api.telegram.org/bot${TOKEN}/sendDocument" \
        -F chat_id="$CHAT_ID" \
        -F document=@"$1" > /dev/null || true
}

if [[ -n "$TOKEN" && -n "$CHAT_ID" ]]; then
    if [[ $ERROR -eq 0 ]]; then
        MSG="La conoscenza del *Necronomicon* è stata ampliata."$'\n'

        if [[ -n "$PACMAN_UPDATES" ]]; then
            MSG+=$'\n'"Nuove conoscenze pacman aggiunte:"$'\n```\n'"$PACMAN_UPDATES"$'\n```\n'
        fi

        if [[ -n "$YAY_UPDATES" ]]; then
            MSG+=$'\n'"Nuove conoscenze AUR aggiunte:"$'\n```\n'"$YAY_UPDATES"$'\n```\n'
        fi

        # se non c'era nulla da aggiornare
        if [[ -z "$PACMAN_UPDATES" && -z "$YAY_UPDATES" ]]; then
            MSG+=$'\n'"Il sapere è già al massimo."
        fi

        send_msg "$MSG"
    else
        send_msg "C'è stato un problema con l'aggiornamento delle conoscenze. Controlla il log."
        send_file "$LOG"
    fi
fi

exit $ERROR
