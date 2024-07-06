# has an ugly offset in certain terminals.
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = ""
$env.TRANSIENT_PROMPT_COMMAND = ""

# connect SSH agent (depends on a systemd service).
$env.SSH_AUTH_SOCK = $"($env.XDG_RUNTIME_DIR)ssh-agent"
