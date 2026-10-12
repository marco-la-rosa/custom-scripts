#!/usr/bin/env bash
set -e
sudo install -m 755 -o root -g root "$(dirname "$(readlink -f "$0")")"/root-scripts/*.sh /usr/local/bin/
echo "Script root installati in /usr/local/bin"
