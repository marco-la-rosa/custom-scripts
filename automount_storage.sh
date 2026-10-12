#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
set -a; source "$SCRIPT_DIR/.env"; set +a

exec >> /tmp/automount.log 2>&1
echo "=============================="
echo "START $(date)"

# waiting for ping
until ping -c1 1.1.1.1 &>/dev/null; do
  echo "Rete non pronta..."
  sleep 3
done
echo "Rete OK"

# waiting ssh response
until nc -z "$REMOTE_HOST" 22; do
  echo "SSH remoto non pronto..."
  sleep 3
done
echo "SSH remoto OK"

# creating mountpoint
mkdir -p "$MOUNTPOINT"
if mountpoint -q "$MOUNTPOINT"; then
  echo "Gia montato, esco"
  exit 0
fi

# trying mount
while true; do
  echo "Tento mount sshfs..."

  sshfs "$REMOTE" "$MOUNTPOINT" \
    -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3

  if mountpoint -q "$MOUNTPOINT"; then
    echo "✅ MOUNT RIUSCITO!"
    
    notify-send -i drive-harddisk \
      "Necronomicon" \
      "📦 Storage montato godo"
    
    break
  else
    echo "❌ Mount fallito, ritento tra 5s..."
    sleep 5
  fi
done

echo "FINE $(date)"

