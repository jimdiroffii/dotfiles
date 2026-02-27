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

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

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
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

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

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu

###############################################################################
###############################################################################
#                    Custom Configuration Options                             #
#                                                                             #
#                              Notes                                          #
#                                                                             #
# - Checking for OS type function removed. ZSH includes a variable $OSTYPE    #
#   that performs the detection automatically. Updated conditionals to use    #
#   case statements with this variable to check for MacOS and Linux systems.  #
###############################################################################

###############################################################################
# PATH Extensions
###############################################################################
# Helper function to dynamically and safely construct PATH
add_to_path() {
    if [[ -d "$1" ]]; then
        export PATH="$1:$PATH"
    fi
}

###
# 1. System & Package Managers
###
# Apple Silicon (M-series) Macs
add_to_path "/opt/homebrew/bin"
add_to_path "/opt/homebrew/sbin"

###
# 2. Developer Tools & Languages
###
# Laravel / Composer
add_to_path "$HOME/.config/composer/vendor/bin"
add_to_path "$HOME/.composer/vendor/bin" # Fallback for older composer setups

# Go
add_to_path "/usr/local/go/bin" # System binaries
add_to_path "$HOME/go/bin"      # Workspace binaries (go install)

# Rust
add_to_path "$HOME/.cargo/bin"

# GHCup / Haskell / Cabal
add_to_path "$HOME/.ghcup/bin"
add_to_path "$HOME/.cabal/bin"

###############################################################################
# Universal Dependency Installer
###############################################################################
prompt_install() {
    local cmd_name="$1"
    local pkg_name="${2:-$1}" 
    local marker_dir="${XDG_STATE_HOME:-$HOME/.local/state}/zsh_prompts"
    local marker_file="$marker_dir/${cmd_name}"
    local install_cmd=""

    # 1. Check if the command is missing and we haven't asked yet
    if ! command -v "$cmd_name" &> /dev/null && [[ ! -f "$marker_file" ]]; then
        
        # 2. Detect the available package manager
        if command -v brew &> /dev/null; then
            install_cmd="brew install $pkg_name"
        elif command -v apt-get &> /dev/null; then
            install_cmd="sudo apt-get install -y $pkg_name"
        elif command -v dnf &> /dev/null; then
            install_cmd="sudo dnf install -y $pkg_name"
        elif command -v pacman &> /dev/null; then
            install_cmd="sudo pacman -S --noconfirm $pkg_name"
        else
            return 1 
        fi

        # 3. Prompt the user
        echo ""
        if read -q "REPLY?'$cmd_name' is missing. Run '$install_cmd'? [y/N] "; then
            echo -e "\nInstalling $pkg_name..."
            eval "$install_cmd"
        else
            echo -e "\nSkipping. You won't be asked again."
        fi
        
        # 4. Ensure the directory exists, then create the marker file
        mkdir -p "$marker_dir"
        touch "$marker_file"
    fi
}

###############################################################################
# Configure MacOS key bind
###############################################################################
if [[ "$OSTYPE" == darwin* ]]; then
    zstyle ':z4h:bindkey' keyboard  'mac'
fi

###############################################################################
# Aliases
###############################################################################

###
# `ls`
#
# ls - Classify items and use columns
# ll - "long list", show all items, use human readable values
# la - Show all items, classify, and use columns
###
case "$OSTYPE" in
    darwin*)
        # 1. One-time prompt for coreutils
        prompt_install "gls" "coreutils"

        # 2. Set aliases based on availability
        if command -v gls &> /dev/null; then
            alias ls='gls -CF --color=auto --group-directories-first'
            alias ll='gls -lAhF --color=auto --group-directories-first'
            alias la='gls -ACF --color=auto --group-directories-first'
        else
            # Native macOS BSD fallback
            alias ls='ls -GCF'
            alias ll='ls -GlAhp'
            alias la='ls -GACF'
        fi
        ;;

    linux*)
        # Standard GNU environment
        alias ls='ls -CF --color=auto --group-directories-first'
        alias ll='ls -lAhF --color=auto --group-directories-first'
        alias la='ls -ACF --color=auto --group-directories-first'
        ;;

    *)
        # Universal fallback for unknown operating systems
        alias ls='ls -CF'
        alias ll='ls -lAhF'
        alias la='ls -ACF'
        ;;
esac

###
# `cd`
###
alias cd..='cd ../'
alias ..='cd ../'
alias ...='cd ../../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'

# Show contents when changing directories
chpwd() {
    la
}

###
# `grep`
###
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'

###
# `tree`
###
prompt_install "tree"
if command -v tree &> /dev/null; then
    alias tree='tree -a -I .git'
fi

###
# `diff`
###
case "$OSTYPE" in
    darwin*)
        # We need GNU diffutils on Mac for color. It installs as 'gdiff'.
        prompt_install "gdiff" "diffutils"
        
        if command -v gdiff &> /dev/null; then
            alias diff='gdiff --color=auto -ys'
        else
            # Fallback to standard Mac diff without the color flag so it doesn't break
            alias diff='diff -ys'
        fi
        ;;

    linux*)
        alias diff='diff --color=auto -ys'
        ;;
        
    *)
        alias diff='diff -ys'
        ;;
esac

###
# Git
###
prompt_install "git"
if command -v git &> /dev/null; then
    alias gs='git status'
    alias gf='git fetch'
    alias ga='git add .'
    alias gc='git commit -S -m'    
    alias gl='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
fi

###
# IP Addresses (Public & Local)
###
prompt_install "curl"

publicip() {
    if command -v curl &> /dev/null; then
        echo "public: $(curl -s ipinfo.io/ip)"
    else
        echo "Error: 'curl' is required to fetch public IP."
    fi
}

localip() {
    case "$OSTYPE" in
        darwin*)
            # macOS uses ifconfig. 
            ifconfig | awk '/^[a-z0-9]+:/ { sub(/:$/, "", $1); iface=$1 } /inet / && $2 != "127.0.0.1" { print iface":", $2 }'
            ;;
        linux*)
            # -4 restricts to IPv4. 
            # -o (oneline) formats each interface onto a single line.
            ip -4 -o addr show | awk '$2 != "lo" {print $2": "$4}'
            ;;
        *)
            echo "Unsupported OS for localip"
            ;;
    esac
}

alias myip='publicip'
alias myip4='localip'
alias myips='publicip && localip'

###
# View Open Ports
###
case "$OSTYPE" in
    linux*)
        prompt_install "netstat" "net-tools"
        prompt_install "lsof"
        if command -v netstat &> /dev/null && command -v lsof &> /dev/null; then
            alias openports='sudo netstat -tulpn | grep -i "listen" && echo && sudo lsof -i | grep -i "listen"'
        fi
        ;;
    *)
        # Just use lsof (default on macOS)
        if command -v lsof &> /dev/null; then
            alias openports='sudo lsof -iTCP -iUDP -n -P | grep -i "listen"'
        fi
        ;;
esac

###
# List user processes
###
my_ps() { 
    ps "$@" -u "$USER" -o pid,%cpu,%mem,start,time,command
}

alias myps="my_ps"

###
# Safe File Operations
###
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -i'

alias mkdir='mkdir -pv'

###
# Disk Usage
###
alias df='df -h'
alias dus='du -sh * | sort -h'

###
# Replace `top` with `btop`
###
prompt_install "btop"
if command -v btop &> /dev/null; then
    alias top='btop'
fi

###############################################################################
# NVM (lazy loader)
###############################################################################
export NVM_DIR="$HOME/.nvm"

# Lazy-load handler
lazy_nvm_wrapper() {
    # 1. Capture the command the user actually typed (node, npm, etc.)
    local cmd="$1"
    shift
    
    # 2. Delete all the placeholder functions so they don't loop
    unset -f nvm node npm npx yarn pnpm
    
    # 3. Actually load NVM
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    # 4. Execute the command the user originally asked for
    "$cmd" "$@"
}

# Placeholder functions
nvm() { lazy_nvm_wrapper nvm "$@" }
node() { lazy_nvm_wrapper node "$@" }
npm() { lazy_nvm_wrapper npm "$@" }
npx() { lazy_nvm_wrapper npx "$@" }
yarn() { lazy_nvm_wrapper yarn "$@" }
pnpm() { lazy_nvm_wrapper pnpm "$@" }

###############################################################################
# Configure SSH Agent
###############################################################################
case "$OSTYPE" in
    darwin*)
        # macOS native launchd handles ssh-agent automatically.
        # Just ensure you have `AddKeysToAgent yes` and `UseKeychain yes` in your ~/.ssh/config
        ;;
        
    linux*)
        # 1. If a valid socket already exists (e.g., provided by Cinnamon), do nothing!
        if [ ! -S "$SSH_AUTH_SOCK" ]; then
            # Setup a persistent SSH agent to prevent zombie processes
            SSH_ENV="$HOME/.ssh/agent-environment"

            function start_agent {
                # Start ssh-agent and write the environment variables to a file
                ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV"
                chmod 600 "$SSH_ENV"
                . "$SSH_ENV" > /dev/null
            }

            # If the environment file exists, load it
            if [ -f "$SSH_ENV" ]; then
                . "$SSH_ENV" > /dev/null
                # Check if the PID is alive AND if the socket file actually exists
                if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null || ! [ -S "$SSH_AUTH_SOCK" ]; then
                    start_agent
                fi
            else
                start_agent
            fi
        fi
        ;;
esac

