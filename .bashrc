#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

[[ $- == *i* ]] && bind -f ~/.inputrc

if command -v eza &> /dev/null; then
  alias ls="eza -lh --group-directories-first --icons=auto"
  alias lsa="ls -a"
  alias lt="eza --tree --level=2 --long --icons --git"
  alias lta="lt -a"
fi

alias grep='grep --color=auto'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias update='/usr/local/bin/update_server.sh'
alias shutdown='/usr/local/bin/autoshutdown.sh'


PS1='[\u@\h \W]\$ '

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

eval "$(starship init bash)"

check_raid_and_docker() {
    echo
    echo "Il Necronomicon è al tuo servizio, Marco."
    echo -e "\e[3m«Non è morto ciò che può attendere in eterno, e in strani eoni anche la morte può morire.»\e[0m"
    echo
    echo "── RAID STATUS ───────────────────────────"

    local mdstat=$(cat /proc/mdstat)

    if echo "$mdstat" | grep -q "\[2/2\]" && echo "$mdstat" | grep -q "\[UU\]"; then
        echo "Ho chiesto a Chtulhu. Il RAID è operativo."
# ✓
    else
        echo "RAID PROBLEMI ✗"
        echo "$mdstat"
    fi

    echo
    echo "── DOCKER STATUS ─────────────────────────"

    local down=$(docker ps --filter "status=running" --format '{{.Names}}' | sort)
    local all=$(docker ps -a --format '{{.Names}}' | sort)

    # find container down
    local not_running=$(comm -23 <(printf "%s\n" $all) <(printf "%s\n" $down))

    if [ -z "$not_running" ]; then
        echo "Ho chiesto a Nyarlathotep. I container sono tutti operativi."
    else
        echo "Container NON in esecuzione ✗:"
        echo "$not_running"
    fi
}

check_raid_and_docker

