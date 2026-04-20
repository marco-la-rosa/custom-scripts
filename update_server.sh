#!/bin/bash

set -a
source .env
set +a

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
echo "-- Pacman updating ---" >> "$LOG"
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
TOKEN="$TELEGRAM_TOKEN"
CHAT_ID="$TELEGRAM_CHAT_ID"

send_msg() {
    curl -s -X POST https://api.telegram.org/bot$TOKEN/sendMessage \
         -d chat_id="$CHAT_ID" \
         -d parse_mode="Markdown" \
         -d text="$1" > /dev/null
}

send_file() {
    curl -s -X POST https://api.telegram.org/bot$TOKEN/sendDocument \
         -F chat_id="$CHAT_ID" \
         -F document=@"$1" > /dev/null
}

if [[ "$TOKEN" != "INSERISCI_TOKEN" ]]; then
    if [[ $ERROR -eq 0 ]]; then
	MSG="$(printf "La conoscenza del *Necronomicon* è stata ampliata.\n")"

        if [[ -n "$PACMAN_UPDATES" ]]; then
		MSG+=$(printf "\nNuove conoscenze pacman aggiunte: \n\`\`\`\n%s\n\`\`\`\n" "$PACMAN_UPDATES")
        fi

        if [[ -n "$YAY_UPDATES" ]]; then
		MSG+=$(printf "\nNuove conoscenze AUR aggiunte: \n\`\`\`\n%S\n\`\`\`\n" "YAY_UPDATES")
        fi

        # if there's nothing to update
        if [[ -z "$PACMAN_UPDATES" && -z "$YAY_UPDATES" ]]; then
		MSG+=$(printf "\nIl sapere è già al massimo. \n")
        fi

        send_msg "$MSG"

    else
        send_msg "C'è stato un problema con l'aggiornamento delle conoscenze. Controlla il log."
        send_file "$LOG"
    fi
fi

exit $ERROR

