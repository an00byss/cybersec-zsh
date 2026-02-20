# ================================================================
# CYBERSEC ZSH THEME - Security-Focused Terminal Theme
# ================================================================
# Features: Timestamps, Security Indicators, Git Status, Logging
# Author: An00byss
# Version: 1.1 - Fixed line editing
# ================================================================

# Enable required zsh options
setopt PROMPT_SUBST
setopt PROMPT_CR
setopt PROMPT_SP
autoload -Uz vcs_info
autoload -U colors && colors

# ================================================================
# COLOR SCHEME - Security-Focused Palette
# ================================================================
CYBERSEC_USER_COLOR="%{$fg_bold[cyan]%}"
CYBERSEC_ROOT_COLOR="%{$fg_bold[red]%}"
CYBERSEC_HOST_COLOR="%{$fg_bold[green]%}"
CYBERSEC_PATH_COLOR="%{$fg_bold[blue]%}"
CYBERSEC_GIT_COLOR="%{$fg_bold[magenta]%}"
CYBERSEC_TIME_COLOR="%{$fg_bold[yellow]%}"
CYBERSEC_ERROR_COLOR="%{$fg_bold[red]%}"
CYBERSEC_SUCCESS_COLOR="%{$fg_bold[green]%}"
CYBERSEC_WARN_COLOR="%{$fg_bold[yellow]%}"
CYBERSEC_INFO_COLOR="%{$fg[white]%}"
CYBERSEC_RESET="%{$reset_color%}"

# ================================================================
# SECURITY INDICATORS
# ================================================================
# Unicode symbols for security status
CYBERSEC_LOCK_SYMBOL="🔒"
CYBERSEC_UNLOCK_SYMBOL="🔓"
CYBERSEC_SHIELD_SYMBOL="🛡️"
CYBERSEC_ALERT_SYMBOL="⚠️"
CYBERSEC_ROOT_SYMBOL="👑"
CYBERSEC_USER_SYMBOL="👤"
CYBERSEC_SSH_SYMBOL="🌐"
CYBERSEC_LOCAL_SYMBOL="💻"
CYBERSEC_GIT_SYMBOL="⎇"
CYBERSEC_CMD_SYMBOL="⚡"

# Fallback ASCII symbols (if Unicode not supported)
if [[ "$CYBERSEC_ASCII_ONLY" == "true" ]]; then
    CYBERSEC_LOCK_SYMBOL="[L]"
    CYBERSEC_UNLOCK_SYMBOL="[U]"
    CYBERSEC_SHIELD_SYMBOL="[S]"
    CYBERSEC_ALERT_SYMBOL="[!]"
    CYBERSEC_ROOT_SYMBOL="[R]"
    CYBERSEC_USER_SYMBOL="[U]"
    CYBERSEC_SSH_SYMBOL="[SSH]"
    CYBERSEC_LOCAL_SYMBOL="[LOC]"
    CYBERSEC_GIT_SYMBOL="[G]"
    CYBERSEC_CMD_SYMBOL=">"
fi

# ================================================================
# GIT CONFIGURATION
# ================================================================
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr "%{$fg_bold[green]%}●%{$reset_color%}"
zstyle ':vcs_info:*' unstagedstr "%{$fg_bold[yellow]%}●%{$reset_color%}"
zstyle ':vcs_info:git:*' formats "%{$fg_bold[magenta]%}${CYBERSEC_GIT_SYMBOL} %b%u%c%{$reset_color%}"
zstyle ':vcs_info:git:*' actionformats "%{$fg_bold[red]%}${CYBERSEC_GIT_SYMBOL} %b|%a%u%c%{$reset_color%}"

# ================================================================
# PRIVILEGE LEVEL DETECTION
# ================================================================
function cybersec_privilege_indicator() {
    if [[ $EUID -eq 0 ]]; then
        print -n "%{$fg_bold[red]%}${CYBERSEC_ROOT_SYMBOL}%{$reset_color%}"
    else
        print -n "%{$fg_bold[cyan]%}${CYBERSEC_USER_SYMBOL}%{$reset_color%}"
    fi
}

# ================================================================
# CONNECTION TYPE INDICATOR
# ================================================================
function cybersec_connection_type() {
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        print -n "%{$fg_bold[yellow]%}${CYBERSEC_SSH_SYMBOL}%{$reset_color%}"
    else
        print -n "%{$fg[white]%}${CYBERSEC_LOCAL_SYMBOL}%{$reset_color%}"
    fi
}

# ================================================================
# SECURITY STATUS INDICATOR
# ================================================================
function cybersec_security_status() {
    local sec_status=""
    
    # Check if running in privileged mode
    if [[ $EUID -eq 0 ]]; then
        sec_status+="%{$fg_bold[red]%}${CYBERSEC_ALERT_SYMBOL}%{$reset_color%} "
    fi
    
    # Check if history logging is enabled
    if [[ -n "$CYBERSEC_LOGGING_ENABLED" ]] && [[ "$CYBERSEC_LOGGING_ENABLED" == "true" ]]; then
        sec_status+="%{$fg_bold[green]%}${CYBERSEC_SHIELD_SYMBOL}%{$reset_color%}"
    fi
    
    print -n "$sec_status"
}

# ================================================================
# EXECUTION TIME TRACKING
# ================================================================
function cybersec_preexec() {
    CYBERSEC_CMD_START_TIME=$SECONDS
    CYBERSEC_CMD_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
}

function cybersec_precmd() {
    local exit_code=$?
    CYBERSEC_LAST_EXIT_CODE=$exit_code
    
    # Calculate command execution time
    if [[ -n "$CYBERSEC_CMD_START_TIME" ]]; then
        local elapsed=$(($SECONDS - $CYBERSEC_CMD_START_TIME))
        
        if [[ $elapsed -gt 0 ]]; then
            CYBERSEC_EXEC_TIME="%{$fg_bold[yellow]%}⏱${elapsed}s%{$reset_color%}"
        else
            CYBERSEC_EXEC_TIME=""
        fi
        
        unset CYBERSEC_CMD_START_TIME
    else
        CYBERSEC_EXEC_TIME=""
    fi
    
    # Update VCS info
    vcs_info
}

# ================================================================
# TIMESTAMP DISPLAY
# ================================================================
function cybersec_timestamp() {
    print -n "%{$fg_bold[yellow]%}%D{%H:%M:%S}%{$reset_color%}"
}

# ================================================================
# LAST COMMAND STATUS
# ================================================================
function cybersec_return_status() {
    if [[ $CYBERSEC_LAST_EXIT_CODE -eq 0 ]]; then
        print -n "%{$fg_bold[green]%}✓%{$reset_color%}"
    else
        print -n "%{$fg_bold[red]%}✗%{$reset_color%}"
    fi
}

# ================================================================
# CURRENT WORKING DIRECTORY
# ================================================================
function cybersec_current_dir() {
    print -n "%{$fg_bold[blue]%}%~%{$reset_color%}"
}

# ================================================================
# USERNAME@HOSTNAME
# ================================================================
function cybersec_user_host() {
    if [[ $EUID -eq 0 ]]; then
        print -n "%{$fg_bold[red]%}%n%{$reset_color%}@%{$fg_bold[green]%}%m%{$reset_color%}"
    else
        print -n "%{$fg_bold[cyan]%}%n%{$reset_color%}@%{$fg_bold[green]%}%m%{$reset_color%}"
    fi
}

# ================================================================
# BACKGROUND JOBS INDICATOR
# ================================================================
function cybersec_jobs_indicator() {
    local job_count=$(jobs | wc -l | tr -d ' ')
    if [[ $job_count -gt 0 ]]; then
        print -n "%{$fg_bold[yellow]%}⚙${job_count}%{$reset_color%} "
    fi
}

# ================================================================
# COMPACT PROMPT CONSTRUCTION (Single line for better editing)
# ================================================================

# Option 1: Compact single-line prompt (RECOMMENDED for long commands)
if [[ "$CYBERSEC_COMPACT_MODE" == "true" ]]; then
    PROMPT='$(cybersec_timestamp) $(cybersec_user_host) $(cybersec_connection_type) $(cybersec_security_status) $(cybersec_current_dir) ${vcs_info_msg_0_} $(cybersec_jobs_indicator)${CYBERSEC_EXEC_TIME}
$(cybersec_privilege_indicator) ${CYBERSEC_CMD_SYMBOL} '

# Option 2: Two-line prompt (better readability, good editing)
elif [[ "$CYBERSEC_TWOLINES" == "true" ]]; then
    # First line with info
    PROMPT='%{$fg[cyan]%}┌─%{$reset_color%}[$(cybersec_timestamp)] $(cybersec_user_host) $(cybersec_connection_type) $(cybersec_security_status) $(cybersec_current_dir) ${vcs_info_msg_0_}
%{$fg[cyan]%}└─%{$reset_color%}$(cybersec_privilege_indicator) ${CYBERSEC_CMD_SYMBOL} '

# Option 3: Original three-line prompt (most info, can affect editing)
else
    PROMPT='%{$fg[cyan]%}╭─%{$reset_color%}[$(cybersec_timestamp)] $(cybersec_user_host) $(cybersec_connection_type) $(cybersec_security_status)
%{$fg[cyan]%}├─%{$reset_color%}$(cybersec_current_dir) ${vcs_info_msg_0_} $(cybersec_jobs_indicator)${CYBERSEC_EXEC_TIME}
%{$fg[cyan]%}╰─%{$reset_color%}$(cybersec_privilege_indicator) %{$reset_color%}'
fi

# Right prompt: Return status
RPROMPT='$(cybersec_return_status)'

# ================================================================
# ZLE WIDGETS FOR BETTER EDITING (FIX FOR CTRL+ARROW)
# ================================================================

# Ensure ZLE is properly initialized
autoload -Uz select-word-style
select-word-style bash

# Fix word movements
autoload -U select-word-style
select-word-style bash

# Bind keys for better navigation
bindkey '^[[1;5C' forward-word                    # Ctrl+Right
bindkey '^[[1;5D' backward-word                   # Ctrl+Left
bindkey '^[[3~' delete-char                       # Delete
bindkey '^[[H' beginning-of-line                  # Home
bindkey '^[[F' end-of-line                        # End
bindkey '^[[5~' up-line-or-history               # Page Up
bindkey '^[[6~' down-line-or-history             # Page Down

# Alternative bindings for different terminal emulators
bindkey '^[OC' forward-word                       # Ctrl+Right (alt)
bindkey '^[OD' backward-word                      # Ctrl+Left (alt)
bindkey '^[[1;2C' forward-word                    # Shift+Right
bindkey '^[[1;2D' backward-word                   # Shift+Left

# Emacs-style navigation (backup)
bindkey '^F' forward-word
bindkey '^B' backward-word
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line

# ================================================================
# HOOK REGISTRATION
# ================================================================
autoload -Uz add-zsh-hook
add-zsh-hook preexec cybersec_preexec
add-zsh-hook precmd cybersec_precmd

# ================================================================
# PLUGIN SUPPORT INITIALIZATION
# ================================================================
# Define plugin directories
typeset -A CYBERSEC_PLUGIN_DIRS
CYBERSEC_PLUGIN_DIRS=(
    core    "$HOME/.zsh/cybersec/plugins/core"
    custom  "$HOME/.zsh/cybersec/plugins/custom"
    security "$HOME/.zsh/cybersec/plugins/security"
)

# Create plugin directories if they don't exist
for dir in ${CYBERSEC_PLUGIN_DIRS[@]}; do
    [[ ! -d "$dir" ]] && mkdir -p "$dir"
done

# ================================================================
# PLUGIN LOADER
# ================================================================
function cybersec_load_plugin() {
    local plugin_name=$1
    local plugin_type=${2:-custom}
    local plugin_dir=${CYBERSEC_PLUGIN_DIRS[$plugin_type]}
    local plugin_file="${plugin_dir}/${plugin_name}.zsh"
    
    if [[ -f "$plugin_file" ]]; then
        source "$plugin_file"
        print -P "%F{green}✓%f Loaded plugin: $plugin_name"
    else
        print -P "%F{red}✗%f Plugin not found: $plugin_name"
        return 1
    fi
}

# ================================================================
# PLUGIN MANAGEMENT FUNCTIONS
# ================================================================
function cybersec_list_plugins() {
    echo "=== CyberSec Plugins ==="
    echo ""
    
    for type in ${(k)CYBERSEC_PLUGIN_DIRS}; do
        local plugin_dir=${CYBERSEC_PLUGIN_DIRS[$type]}
        echo "[$type]"
        
        if [[ -d "$plugin_dir" ]]; then
            local plugin_count=0
            for plugin in "$plugin_dir"/*.zsh(N); do
                if [[ -f "$plugin" ]]; then
                    echo "  - $(basename ${plugin%.zsh})"
                    ((plugin_count++))
                fi
            done
            
            if [[ $plugin_count -eq 0 ]]; then
                echo "  (no plugins)"
            fi
        else
            echo "  (directory not found)"
        fi
        echo ""
    done
}

function cybersec_reload_plugins() {
    echo "Reloading CyberSec plugins..."
    
    # Reload core plugins
    for plugin in ${CYBERSEC_PLUGIN_DIRS[core]}/*.zsh(N); do
        [[ -f "$plugin" ]] && source "$plugin"
    done
    
    print -P "%F{green}✓%f Plugins reloaded"
}

# ================================================================
# PROMPT MODE SWITCHING
# ================================================================
function cybersec_prompt_mode() {
    local mode=${1:-help}
    
    case $mode in
        compact)
            export CYBERSEC_COMPACT_MODE=true
            export CYBERSEC_TWOLINES=false
            print -P "%F{green}✓%f Switched to compact mode (single line)"
            ;;
        two)
            export CYBERSEC_COMPACT_MODE=false
            export CYBERSEC_TWOLINES=true
            print -P "%F{green}✓%f Switched to two-line mode"
            ;;
        full)
            export CYBERSEC_COMPACT_MODE=false
            export CYBERSEC_TWOLINES=false
            print -P "%F{green}✓%f Switched to full mode (three lines)"
            ;;
        help|*)
            echo "Usage: cybersec_prompt_mode <mode>"
            echo ""
            echo "Available modes:"
            echo "  compact  - Single line (best for long commands)"
            echo "  two      - Two lines (balanced)"
            echo "  full     - Three lines (most information)"
            echo ""
            echo "Current mode: "
            if [[ "$CYBERSEC_COMPACT_MODE" == "true" ]]; then
                echo "  compact"
            elif [[ "$CYBERSEC_TWOLINES" == "true" ]]; then
                echo "  two"
            else
                echo "  full"
            fi
            return
            ;;
    esac
    
    # Reload theme
    source ~/.zsh/cybersec/themes/cybersec.zsh-theme
}

# ================================================================
# AUTO-LOAD CORE PLUGINS
# ================================================================
if [[ -d "${CYBERSEC_PLUGIN_DIRS[core]}" ]]; then
    for plugin in ${CYBERSEC_PLUGIN_DIRS[core]}/*.zsh(N); do
        if [[ -f "$plugin" ]]; then
            source "$plugin"
        fi
    done
fi

# ================================================================
# THEME INFO
# ================================================================
function cybersec_theme_info() {
    print -P ""
    print -P "%F{cyan}╔════════════════════════════════════════════╗%f"
    print -P "%F{cyan}║%f    %F{green}CyberSec ZSH Theme v1.1%f            %F{cyan}║%f"
    print -P "%F{cyan}╠════════════════════════════════════════════╣%f"
    print -P "%F{cyan}║%f  Features:                                %F{cyan}║%f"
    print -P "%F{cyan}║%f    ${CYBERSEC_SHIELD_SYMBOL}  Security Status Indicators         %F{cyan}║%f"
    print -P "%F{cyan}║%f    ${CYBERSEC_LOCK_SYMBOL}  Command Logging & Audit Trail      %F{cyan}║%f"
    print -P "%F{cyan}║%f    ${CYBERSEC_GIT_SYMBOL}  Git Integration                    %F{cyan}║%f"
    print -P "%F{cyan}║%f    ⏱  Execution Time Tracking            %F{cyan}║%f"
    print -P "%F{cyan}║%f    📝  History Management                 %F{cyan}║%f"
    print -P "%F{cyan}║%f    🔌  Plugin Support                     %F{cyan}║%f"
    print -P "%F{cyan}║%f    ⌨️  Enhanced Line Editing              %F{cyan}║%f"
    print -P "%F{cyan}╠════════════════════════════════════════════╣%f"
    print -P "%F{cyan}║%f  Keyboard Shortcuts:                     %F{cyan}║%f"
    print -P "%F{cyan}║%f    Ctrl+→/←    Navigate by word          %F{cyan}║%f"
    print -P "%F{cyan}║%f    Ctrl+A/E    Start/End of line         %F{cyan}║%f"
    print -P "%F{cyan}║%f    Ctrl+K/U    Kill line forward/back    %F{cyan}║%f"
    print -P "%F{cyan}╠════════════════════════════════════════════╣%f"
    print -P "%F{cyan}║%f  Commands:                               %F{cyan}║%f"
    print -P "%F{cyan}║%f    cybersec_prompt_mode <mode>           %F{cyan}║%f"
    print -P "%F{cyan}║%f      compact/two/full                    %F{cyan}║%f"
    print -P "%F{cyan}║%f    cybersec_list_plugins                 %F{cyan}║%f"
    print -P "%F{cyan}║%f    logsearch <term> [days]               %F{cyan}║%f"
    print -P "%F{cyan}║%f    logsummary [days]                     %F{cyan}║%f"
    print -P "%F{cyan}╚════════════════════════════════════════════╝%f"
    print -P ""
}

# ================================================================
# STARTUP MESSAGE
# ================================================================
print -P ""
print -P "%F{green}✓%f CyberSec ZSH Theme Loaded"

# Show current mode
if [[ "$CYBERSEC_COMPACT_MODE" == "true" ]]; then
    print -P "  Mode: %F{cyan}Compact (single line)%f"
elif [[ "$CYBERSEC_TWOLINES" == "true" ]]; then
    print -P "  Mode: %F{cyan}Two-line%f"
else
    print -P "  Mode: %F{cyan}Full (three lines)%f"
fi

print -P "  Type %F{cyan}cybersec_theme_info%f for help"
print -P "  Type %F{cyan}cybersec_prompt_mode compact%f for better long command editing"
print -P ""
