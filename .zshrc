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

# PROMPT MODE SELECTION (choose one):
# For BEST editing experience with long commands:
export CYBERSEC_COMPACT_MODE=true    # Single line prompt (RECOMMENDED)

# OR for two-line prompt (good balance):
# export CYBERSEC_TWOLINES=true

# OR for three-line prompt (full info, but may affect editing):
# export CYBERSEC_COMPACT_MODE=false
# export CYBERSEC_TWOLINES=false

# History configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=1000000

# Better line editing
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

# Load the theme
if [[ -f "$ZSH_CUSTOM/themes/cybersec.zsh-theme" ]]; then
    source "$ZSH_CUSTOM/themes/cybersec.zsh-theme"
else
    echo "Warning: CyberSec theme not found!"
fi

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

# Quick mode switching
alias prompt-compact='cybersec_prompt_mode compact'
alias prompt-two='cybersec_prompt_mode two'
alias prompt-full='cybersec_prompt_mode full'

# ================================================================
