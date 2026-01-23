# --- SSH agent / key setup (login shells) ---

# Start agent if needed
if [[ -z "$SSH_AUTH_SOCK" ]]; then
	eval "$(ssh-agent -s)" >/dev/null
fi

# Add key if agent has none (or if key isn't loaded)
# Return codes: 0=has keys, 1=no keys, 2=no agent
ssh-add -l >/dev/null 2>&1
rc=$?

if [[ $rc -eq 1 ]]; then
	# Force passphrase prompt to read from the terminal
	ssh-add ~/.ssh/id_rsa </dev/tty
elif [[ $rc -eq 2 ]]; then
	# Agent wasn't actually reachable; start then add
	eval "$(ssh-agent -s)" >/dev/null
	ssh-add ~/.ssh/id_rsa </dev/tty
fi

