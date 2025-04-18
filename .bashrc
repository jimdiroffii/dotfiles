# .bashrc
# 
# Author: Jim Diroff II
# Github: @jimdiroffii
# 		https://github.com/jimdiroffii/dotfiles
# 
# Acknowledgements
# - @natelandau | Some aliases, functions and macOS commands
# 		https://gist.github.com/natelandau/10654137
#			https://github.com/natelandau/dotfiles
# - @openai | Portions of this project were generated using OpenAI's ChatGPT.
# 
# Usage
# 	tldr: 
# 		Copy to home directory as .bashrc
#			Add the following line near the beginning of the .profile file
#        if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
#
# When Bash is invoked as an interactive login shell,
# or as a non-interactive shell with the --login option,
# it first reads and executes commands from the file
# /etc/profile, if that file exists. After reading that
# file, it looks for ~/.bash_profile, ~/.bash_login,
# and ~/.profile, in that order, and reads and executes
# commands from the first one that exists and is readable.
#
# The commands are intended for any Bourne-compatible shells
# The usage instructions populate the bashrc settings through
# the .profile file, which ensures bashrc is executed for
# login and nonlogin shells.
#
# Linux Usage:
#  1. Locate the .profile file in your home directory
#  2. Add the following line near the beginning of the .profile file
#        if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
#  3. Review the settings after this if statement to ensure no conflicts
#       with bashrc settings like PATH or PS1
#  4. Save the .profile file
#
# MacOS Usage:
#  1. Locate the .bash_profile file in your home directory
#  2. Follow the Linux Usage steps above
#
# Notes:
# - Use keyword 'unalias' in terminal to remove an alias temporarily
# - ANSI escape codes for colors, use \[\e[0m\] to reset
#     Foreground Colors:
#
#         Black: \[\e[30m\]
#         Red: \[\e[31m\]
#         Green: \[\e[32m\]
#         Yellow: \[\e[33m\]
#         Blue: \[\e[34m\]
#         Magenta: \[\e[35m\]
#         Cyan: \[\e[36m\]
#         White: \[\e[37m\]
#
#     Background Colors:
#
#         Black: \[\e[40m\]
#         Red: \[\e[41m\]
#         Green: \[\e[42m\]
#         Yellow: \[\e[43m\]
#         Blue: \[\e[44m\]
#         Magenta: \[\e[45m\]
#         Cyan: \[\e[46m\]
#         White: \[\e[47m\]
#
#------------------------------------------------------------------------------

###############################################################################
# If not running interactively, don't do anything
###############################################################################
case $- in
  *i*) ;;
  *) return;;
esac

###############################################################################
# Configure Proxy
#
# Include these settings in .proxyrc
#		export HTTP_PROXY=http://proxy.example.com:port
#		export HTTPS_PROXY=http://proxy.example.com:port
#		export FTP_PROXY=http://proxy.example.com:port
#		export SOCKS_PROXY=socks://proxy.example.com:port
#		export NO_PROXY=localhost,127.0.0.1,.example.com
###############################################################################
if [ -f ~/.proxyrc ]; then
	. ~/.proxyrc
fi

###############################################################################
# Determine the OS
###############################################################################
if [[ "$(uname)" == "Darwin" ]]; then
	OS="macos"
elif [[ -f /etc/os-release ]]; then
	. /etc/os-release
	if [[ "$ID" == *debian* ]] || [[ "$ID_LIKE" == *debian* ]]; then
			OS="debian"
	elif [[ "$ID" == *fedora* ]]; then
			OS="fedora"
	else
			OS="$ID_LIKE"
	fi
else
	echo -e "~/.bashrc error. Unknown OS. Some features might not work.\n"
fi

###############################################################################
# OS specific settings, example
###############################################################################
if [[ "$OS" == "macos" ]]; then
	# MacOS specific settings
	echo
elif [[ "$OS" == "debian" ]]; then
	# Debian/Ubuntu specific settings
	echo
elif [[ "$OS" == "fedora" ]]; then
	# Fedora specific settings
	echo
fi

###############################################################################
# History
###############################################################################
# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth
# Append to the history file, don't overwrite it
shopt -s histappend
# Set in-memory history length
HISTSIZE=1000
# Set file history length
HISTFILESIZE=50000

###############################################################################
# History Logging, Stop and Start
###############################################################################
alias stophistory='set +o history'
alias starthistory='set -o history'
alias stoph=stophistory
alias starth=starthistory

###############################################################################
# Sanitize command history to avoid storing sensitive data
# TODO: Needs some work. If the command contains a defined keyword followed by
# an equals [=] sign, the next word will be removed from history. Certainly not
# foolproof, but an interesting POC. It is probably better to just stop logging
# history if we don't want to record a command.
#
# UPDATE: If any keyword matches, the entire command is removed from history.
# TODO: Add ability to stop and start the sanitization
###############################################################################
sanitize_history() {
	# Enable case-insensitive pattern matching
  shopt -s nocasematch

  # Retrieve the last command
  local last_command=$(history 1 | sed 's/^ *[0-9]* *//')

  # Define a list of sensitive keywords
  local sensitive_keywords=(
		# General Authentication and Authorization Identifiers
		"password" "passwd" "pwd" "pass" "secret" "authentication" "auth" "login" "credentials"
		"token" "access_token" "auth_token" "bearer" "session" "session_id" "sessionid"

		# API Keys and Related
		"apikey" "api_key" "api-key" "access_key" "accesskey" "access-key" "secret_key" "secretkey" "secret-key"
		"client_id" "clientid" "client-id" "client_secret" "clientsecret" "client-secret"

		# Specific Key Types
		"private_key" "privatekey" "private-key" "public_key" "publickey" "public-key" "encryption_key" "encryptionkey" "encryption-key"
		"ssh_key" "sshkey" "ssh-key" "gpg_key" "gpgkey" "gpg-key" "pgp_key" "pgpkey" "pgp-key"
		"rsa_key" "rsakey" "rsa-key" "dsa_key" "dsakey" "dsa-key" "ecdsa_key" "ecdsakey" "ecdsa-key" "ed25519_key" "ed25519key" "ed25519-key"

		# Database Credentials
		"db_password" "dbpassword" "db-pass" "db_passwd" "dbpasswd" "db-passwd" "db_user" "dbuser" "db-user" "db_username" "dbusername" "db-username"
		"db_host" "dbhost" "db-host" "db_port" "dbport" "db-port"

		# Cloud Service Identifiers
		"aws_access_key_id" "aws_secret_access_key" "aws_session_token" 
		"azure_client_id" "azure_client_secret" 
		"gcp_credentials" "gcp_keyfile"

		# Other Sensitive Identifiers
		"smtp_password" "smtp_user" "ftp_password" "ftp_user"
		"oauth_token" "refresh_token" "id_token"

		# Certificate and Key Files
		"cert" "certificate" "pem" "pfx" "p12" "cred" "security"
	)
	
  # Check if the last command contains any sensitive keyword
  for keyword in "${sensitive_keywords[@]}"; do
    if [[ "$last_command" == *"$keyword"* ]]; then
      # Replace the sensitive data with "<sensitive_data_removed>"
      ##local sanitized_command=$(echo "$last_command" | sed -E "s/(${keyword})=[^ ]+/\\1=<sensitive_data_removed>/g")

			# Replace the entire command if a keyword matches
			local sanitized_command="<sensitive command removed>"

      # Update the history with the sanitized command
      history -d $(history 1 | awk '{print $1}')   # Remove the original command
      history -s "$sanitized_command"              # Add the sanitized command to history
      break
    fi
  done
}

# Disable case-insensitive pattern matching
shopt -u nocasematch

# Ensure the function is loaded before setting the PROMPT_COMMAND
sanitize_history

# Set the PROMPT_COMMAND to call sanitize_history
PROMPT_COMMAND="sanitize_history; $PROMPT_COMMAND"


###############################################################################
# Resize window after each command
###############################################################################
shopt -s checkwinsize

###############################################################################
# Enable programmable completion features if not already enabled
###############################################################################
if ! shopt -oq posix; then
  if [ -f /usr/local/etc/bash_completion ] || [ -f /usr/share/bash-completion/bash_completion ] || [ -f /etc/bash_completion ]; then
    if [ -f /usr/local/etc/bash_completion ]; then
      . /usr/local/etc/bash_completion
    elif [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  else
    echo -e "Consider installing 'bash-completion'\n"
  fi
fi

###############################################################################
# Prompt
###############################################################################
export PS1="\[\e[31m\]________________________________________________________________________________\n|\[\e[0m\]\[\e[36m\] \w \[\e[0m\]\[\e[33m\]@ \h (\u)\[\e[0m\] | \[\e[35m\]\t\[\e[0m\] | \[\e[35m\]\d\[\e[0m\]\n\[\e[31m\]| =>\[\e[0m\] "
export PS2="\[\e[31m\]| => \[\e[0m\]"

###############################################################################
# tmux
###############################################################################
if ! command -v tmux &> /dev/null; then
	echo -e "Consider installing 'tmux'\n"
else 
	alias tnew="tmux_new_session"             # Start new session with a name.
	alias tat="tmux attach -t"                # Attach to named session.
	alias tls="tmux list-sessions"            # List sessions.
	alias tkill="tmux kill-session -t"        # Kill named session.
	alias tres="tmux resurrect"            		# Resurrect previous tmux state.
fi

tmux_new_session() {
	read -p "Enter session name: " session_name

	if [[ -z "$session_name" ]] || [[ "$session_name" =~ [^a-zA-Z0-9] ]]; then
		echo "Session name cannot be empty!"
		return 1
	fi

	read -p "Enter window name: " window_name

	if [[ -z "$window_name" ]] || [[ "$window_name" =~ [^a-zA-Z0-9] ]]; then
		echo "Window name cannot be empty!"
		return 1
	fi

	tmux new-session -s "$session_name" -n "$window_name"
}

###############################################################################
# Generic Aliases
###############################################################################
alias ls='ls --color=auto'
alias ll='ls -FGlAhp --color=auto'          # "long list": vertical listing, colored, file type indicator, human readable sizes, all except . and ..
alias la='ls -ACF --color=auto'             # "list all": compact list, file type indicator, with all except . and ..

alias grep='grep --color=auto'

alias cp='cp -iv'                           # copy with confirmation
alias mv='mv -iv'                           # move with confirmation
alias rm='rm -Irdv'                         # remove recursively with confirmation, include empty dirs

alias cd..='cd ../'                         # Go back 1 directory level
alias ..='cd ../'                           # Go back 1 directory level
alias ...='cd ../../'                       # Go back 2 directory levels
alias .2='cd ../../'                        # Go back 2 directory levels
alias .3='cd ../../../'                     # Go back 3 directory levels
alias .4='cd ../../../../'                  # Go back 4 directory levels
alias .5='cd ../../../../../'               # Go back 5 directory levels
alias .6='cd ../../../../../../'            # Go back 6 directory levels

alias tarzip='tar -czvf'                    # Create a .tar.gz archive, ignoring potentially empty archives, or archives with unreadable files
alias backupdir='backup_dir_function'       # Calls custom backup directory function

###############################################################################
# Get Public IP
###############################################################################
if ! command -v curl &> /dev/null; then
	echo -e "Consider installing 'curl'\n"
else 
	alias myip='curl ipinfo.io/ip && echo'    # get public IP address and print a new line
	alias myIP='myip'
	alias myIp='myip'
fi

###############################################################################
# Configure SSH Agent
###############################################################################
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
  ssh-add ~/.ssh/id_rsa
fi

###############################################################################
# View Open Ports
###############################################################################
if [[ "$OS" == "macos" ]]; then
	if ! command -v lsof &> /dev/null; then
		echo -e "Consider installing 'lsof'\n"
	else
  	alias openports='sudo lsof -iTCP -iUDP -n -P | grep -i "listen"'
	fi
elif [[ "$OS" == "debian" ]] || [[ "$OS" == "fedora" ]]; then
	if ! command -v netstat &> /dev/null; then
		echo -e "Consider installing 'netstat (net-tools)'\n"
	elif ! command -v lsof &> /dev/null; then
		echo -e "Consider installing 'lsof'\n"
	else	
  	alias openports='sudo netstat -tulpn | grep -i "listen" && echo && sudo lsof -i | grep -i "listen"'
	fi
fi

###############################################################################
# Package managers
###############################################################################
if [[ "$OS" == "macos" ]]; then
  alias brewup='brew update && brew upgrade && brew cleanup'
elif [[ "$OS" == "debian" ]]; then
  alias aup='apt update && apt upgrade -y && apt autoremove -y'
  alias saup='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
elif [[ "$OS" == "fedora" ]]; then
  alias dup='dnf upgrade -y && dnf autoremove -y'
  alias sdup='sudo dnf upgrade -y && sudo dnf autoremove -y'
fi

###############################################################################
# Shell Functions
###############################################################################
# Always list directory contents upon 'cd'
cd () { builtin cd "$@"; la; }

# List processes owned by $USER
my_ps () { ps $@ -u $USER -o pid,%cpu,%mem,start,time,bsdtime,command ; }  
alias myps="my_ps"

extract () {                                                  
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1     ;;
      *.tar.gz)    tar xzf $1     ;;
      *.tar.xz)    tar xf $1      ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       unrar e $1     ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xf $1      ;;
      *.tbz2)      tar xjf $1     ;;
      *.tgz)       tar xzf $1     ;;
      *.zip)       unzip $1       ;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

backup_dir_function() {
  logger -p syslog.info "Starting backup process."

  # must pass in a directory
  directory="$1"

  # Convert to absolute path if a relative path is given
  if [[ ! "$directory" = /* ]]; then
    directory="$(pwd)/$directory"
  fi

  if [ -d "$directory" ]; then
    root_folder_name=$(basename "$directory")
    parent_directory=$(dirname "$directory")
    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_directory="/var/backups"
    backup_file_name="${backup_directory}/${root_folder_name}_${timestamp}.tar.gz"

    # Check and create backup directory
    if [ ! -d "$backup_directory" ]; then
      mkdir -p "$backup_directory"
      if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup directory."
        return 1
      fi
    fi

    # create the backup while preserving permissions without logging every file
    if sudo tar -zcpvf "$backup_file_name" -C "$parent_directory" "$root_folder_name" > /dev/null; then
      echo "Backup of $directory created at [$backup_directory] with name ${root_folder_name}_${timestamp}.tar.gz"
      logger -p syslog.info "Backup process completed successfully."
    else
      echo "Error: Backup of $directory failed."
      logger -p syslog.err "Error: Backup of $directory failed."
      return 1
    fi
  else
    echo "Error: $directory is not a directory."
    logger "Error: $directory is not a directory."
    return 1
  fi
}

# ------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------
export GPG_TTY=$(tty)

# Wheelhouse for CTF VMs
if [ -d /hax/.cache/wheelhouse ]; then
  if [[ -z "${PIP_FIND_LINKS:-}" ]] || [[ "$PIP_FIND_LINKS" != *"file:///hax/.cache/wheelhouse"* ]]; then
    export PIP_FIND_LINKS="file:///hax/.cache/wheelhouse"
  fi

  if [[ ":${PYTHONPATH:-}:" != *":/hax/lib:"* ]]; then
    export PYTHONPATH="${PYTHONPATH:+$PYTHONPATH:}/hax/lib"
  fi
fi

# ------------------------------------------------------------
# nvm / node / npm
# ------------------------------------------------------------
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
	export PATH="$PATH:$COMPOSER_BIN"
fi

# ------------------------------------------------------------
# Go
# ------------------------------------------------------------
GO_BIN="/usr/local/go/bin"
if [ -d $GO_BIN ]; then
  export PATH="$PATH:/usr/local/go/bin"
fi
