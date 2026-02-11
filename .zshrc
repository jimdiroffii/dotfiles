# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Start tmux if not already in tmux.
#zstyle ':z4h:' start-tmux command tmux -u new -A -D -t z4h

# Whether to move prompt to the bottom when zsh starts and on Ctrl+L.
zstyle ':z4h:' prompt-at-bottom 'no'

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'no'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
#zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
#zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
zstyle ':z4h:ssh:phantom' enable 'yes'

# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
# z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'

###
# Determine OS
###
if [[ "$(uname)" == "Darwin" ]]; then
	OS="macos"
elif [[ -f /etc/os-release ]]; then
	. /etc/os-release
	if [[ "$ID" == *debian* ]] || [[ "$ID_LIKE" == *debian* ]]; then
		OS="debian"
	fi
else
	echo -e ".zshrc error. Unknown OS. Some features might not work.\n"
fi

if [[ "$OS" == "macos" ]]; then
    if ! command -v gls &> /dev/null; then
        echo -e "Consider installing 'coreutils' with brew\n"
        # Unset any existing ls alias first
        unalias ls 2>/dev/null || true
        # Custom ls function that mimics --group-directories-first
        function ls() {
            command ls -GC "$@" | awk '
            BEGIN { dirs_count = 0; files_count = 0 }
            /\/$/ { dirs[++dirs_count] = $0; next }
            { files[++files_count] = $0 }
            END {
                for (i = 1; i <= dirs_count; i++) print dirs[i]
                for (i = 1; i <= files_count; i++) print files[i]
            }'
        }
    else
        alias ls='gls -C --color=auto --group-directories-first'
    fi
else
    alias ls='ls -C --color=auto --group-directories-first'
fi

alias ll='ls -FGlAhp'
alias la='ls -ACF'

alias grep='grep --color=auto'

alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'

alias diff='diff --color=auto -u'

# Add flags to existing aliases.
#alias ls="${aliases[ls]:-ls} -A"

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

###
# Git
###
alias gs='git status'
alias gf='git fetch'
alias ga='git add .'
alias gc='git commit -S -m '

###
# Get Public IP
###
if ! command -v curl &> /dev/null; then
	echo -e "Consider installing 'curl'\n"
else
	alias myip='curl ipinfo.io/ip && echo'
	alias myIP='myip'
	alias myIp='myip'
fi

###
# View Open Ports
###
if [[ "$OS" == "macos" ]]; then
	if ! command -v lsof &> /dev/null; then
		echo -e "Consider installing 'lsof'\n"
	else
		alias openports='sudo lsof -iTCP -iUDP -n -P | grep -i "listen"'
	fi
elif [[ "$OS" == "debian" ]]; then
	if ! command -v netstat &> /dev/null; then
		echo -e "Consider installing 'netstat (net-tools)'\n"
	elif ! command -v lsof &> /dev/null; then
		echo -e "Consider installing 'lsof'\n"
	else
		alias openports='sudo netstat -tulpn | grep -i "listen" && echo && sudo lsof -i | grep -i "listen"'
	fi
fi

###
# List directory contents upon 'cd'
###
cd () { builtin cd "$@"; la; }

###
# List user processes
###
my_ps () { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }
alias myps="my_ps"

###
# nvm / node / npm
###
NVM_DIR="$HOME/.nvm"
if [ -d $NVM_DIR ]; then
	export NVM_DIR
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# ------------------------------------------------------------
# Laravel / Composer
# ------------------------------------------------------------
COMPOSER_BIN="$HOME/.config/composer/vendor/bin"
if [ -d $COMPOSER_BIN ]; then
	export PATH="$COMPOSER_BIN:$PATH"
fi

# ------------------------------------------------------------
# Go
# ------------------------------------------------------------
GO_BIN="/usr/local/go/bin"
if [ -d $GO_BIN ]; then
  export PATH="$GO_BIN:$PATH"
fi

# ------------------------------------------------------------
# Rust
# ------------------------------------------------------------
RUST_BIN="$HOME/.cargo/bin"
if [ -d $RUST_BIN ]; then
  export PATH="$RUST_BIN:$PATH"
fi

# ------------------------------------------------------------
# GHCup / Haskell / Cabal
# ------------------------------------------------------------
GHC_BIN="$HOME/.ghcup/bin"
CABAL_BIN="$HOME/.cabal/bin"
if [ -d $GHC_BIN ]; then
  export PATH="$GHC_BIN:$PATH"
fi
if [ -d $CABAL_BIN ]; then
  export PATH="$CABAL_BIN:$PATH"
fi

###
# Configure SSH Agent
###
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
fi

