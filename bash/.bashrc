#
# ~/.bashrc
#

eval "$(starship init bash)"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
source /usr/share/nvm/init-nvm.sh

export FIREFOX_PATH=/usr/bin/zen-browser

export PATH="$HOME/.local/bin:$PATH"

# SSH agent (gcr-ssh-agent.socket, from gnome-keyring): holds the unlocked
# key so git asks for the passphrase once per login instead of every push.
if [[ -z "$SSH_AUTH_SOCK" && -S "$XDG_RUNTIME_DIR/gcr/ssh" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
fi
