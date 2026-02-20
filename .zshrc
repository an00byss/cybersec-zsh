# ================================================================
# CYBERSEC ZSH CONFIGURATION
# ================================================================

# Basic ZSH configuration
export ZSH_CUSTOM="$HOME/.zsh/cybersec"

# Security settings
umask 077  # Restrictive file permissions by default

# Logging configuration
export CYBERSEC_LOG_DIR="$HOME/.zsh_logs"
export CYBERSEC_LOGGING_ENABLED=true
export CYBERSEC_ASCII_ONLY=false  # Set to true for ASCII-only symbols

# History configuration (loaded by plugin)
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=1000000

# Load the theme
if [[ -f "$ZSH_CUSTOM/themes/cybersec.zsh-theme" ]]; then
    source "$ZSH_CUSTOM/themes/cybersec.zsh-theme"
else
    echo "Warning: CyberSec theme not found!"
fi

# ================================================================
# CUSTOM PLUGINS
# ================================================================
# Load your custom security plugins here
# Example: cybersec_load_plugin "my-security-plugin" "security"

# ================================================================
# SECURITY ALIASES
# ================================================================
alias sudo='sudo '  # Enable alias expansion after sudo
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'

# Security shortcuts
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'
alias connections='netstat -an'

# ================================================================

