# ================================================================
# CYBERSEC ZSH THEME - Security-Focused ZSH Terminal Theme
# ================================================================
# Features: Timestamps, Security Indicators, Git Status, Logging
# Author: An00byss
# Version: 1.0
# ================================================================

# Enable required zsh options
setopt PROMPT_SUBST
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
zstyle ':vcs_info:*' stagedstr "${CYBERSEC_SUCCESS_COLOR}●${CYBERSEC_RESET}"
zstyle ':vcs_info:*' unstagedstr "${CYBERSEC_WARN_COLOR}●${CYBERSEC_RESET}"
zstyle ':vcs_info:git:*' formats "${CYBERSEC_GIT_COLOR}${CYBERSEC_GIT_SYMBOL} %b%u%c${CYBERSEC_RESET}"
zstyle ':vcs_info:git:*' actionformats "${CYBERSEC_ERROR_COLOR}${CYBERSEC_GIT_SYMBOL} %b|%a%u%c${CYBERSEC_RESET}"

# ================================================================
# PRIVILEGE LEVEL DETECTION
# ================================================================
function cybersec_privilege_indicator() {
    if [[ $EUID -eq 0 ]]; then
        echo "${CYBERSEC_ROOT_COLOR}${CYBERSEC_ROOT_SYMBOL} ROOT${CYBERSEC_RESET}"
    else
        echo "${CYBERSEC_USER_COLOR}${CYBERSEC_USER_SYMBOL}${CYBERSEC_RESET}"
    fi
}

# ================================================================
# CONNECTION TYPE INDICATOR
# ================================================================
function cybersec_connection_type() {
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        echo "${CYBERSEC_WARN_COLOR}${CYBERSEC_SSH_SYMBOL} SSH${CYBERSEC_RESET}"
    else
        echo "${CYBERSEC_INFO_COLOR}${CYBERSEC_LOCAL_SYMBOL}${CYBERSEC_RESET}"
    fi
}

# ================================================================
# SECURITY STATUS INDICATOR
# ================================================================
function cybersec_security_status() {
    local sec_status=""
    
    # Check if running in privileged mode
    if [[ $EUID -eq 0 ]]; then
        sec_status+="${CYBERSEC_ERROR_COLOR}${CYBERSEC_ALERT_SYMBOL}${CYBERSEC_RESET} "
    fi
    
    # Check if history logging is enabled
    if [[ -n "$CYBERSEC_LOGGING_ENABLED" ]]; then
        sec_status+="${CYBERSEC_SUCCESS_COLOR}${CYBERSEC_SHIELD_SYMBOL}${CYBERSEC_RESET} "
    fi
    
    echo "$sec_status"
}

# ================================================================
# EXECUTION TIME TRACKING
# ================================================================
function cybersec_preexec() {
    CYBERSEC_CMD_START_TIME=$SECONDS
    CYBERSEC_CMD_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
}

function cybersec_precmd() {
    # Calculate command execution time
    if [[ -n "$CYBERSEC_CMD_START_TIME" ]]; then
        local elapsed=$(($SECONDS - $CYBERSEC_CMD_START_TIME))
        
        if [[ $elapsed -gt 0 ]]; then
            CYBERSEC_EXEC_TIME="${CYBERSEC_TIME_COLOR}⏱ ${elapsed}s${CYBERSEC_RESET}"
        else
            CYBERSEC_EXEC_TIME=""
        fi
        
        unset CYBERSEC_CMD_START_TIME
    fi
    
    # Update VCS info
    vcs_info
}

# ================================================================
# TIMESTAMP DISPLAY
# ================================================================
function cybersec_timestamp() {
    echo "${CYBERSEC_TIME_COLOR}[%D{%Y-%m-%d %H:%M:%S}]${CYBERSEC_RESET}"
}

# ================================================================
# LAST COMMAND STATUS
# ================================================================
function cybersec_return_status() {
    echo "%(?.${CYBERSEC_SUCCESS_COLOR}✓${CYBERSEC_RESET}.${CYBERSEC_ERROR_COLOR}✗ %?${CYBERSEC_RESET})"
}

# ================================================================
# CURRENT WORKING DIRECTORY
# ================================================================
function cybersec_current_dir() {
    echo "${CYBERSEC_PATH_COLOR}%~${CYBERSEC_RESET}"
}

# ================================================================
# USERNAME@HOSTNAME
# ================================================================
function cybersec_user_host() {
    local user_color
    if [[ $EUID -eq 0 ]]; then
        user_color=$CYBERSEC_ROOT_COLOR
    else
        user_color=$CYBERSEC_USER_COLOR
    fi
    
    echo "${user_color}%n${CYBERSEC_RESET}${CYBERSEC_INFO_COLOR}@${CYBERSEC_RESET}${CYBERSEC_HOST_COLOR}%m${CYBERSEC_RESET}"
}

# ================================================================
# BACKGROUND JOBS INDICATOR
# ================================================================
function cybersec_jobs_indicator() {
    local job_count=$(jobs | wc -l | tr -d ' ')
    if [[ $job_count -gt 0 ]]; then
        echo "${CYBERSEC_WARN_COLOR}⚙ ${job_count}${CYBERSEC_RESET} "
    fi
}

# ================================================================
# PROMPT CONSTRUCTION
# ================================================================
# Top line: Timestamp, User@Host, Connection Type, Security Status
CYBERSEC_LINE1='╭─$(cybersec_timestamp) $(cybersec_user_host) $(cybersec_connection_type) $(cybersec_security_status)'

# Middle line: Current Directory, Git Info, Jobs, Execution Time
CYBERSEC_LINE2='├─$(cybersec_current_dir) ${vcs_info_msg_0_} $(cybersec_jobs_indicator)${CYBERSEC_EXEC_TIME}'

# Bottom line: Privilege Indicator, Command Prompt
CYBERSEC_LINE3='╰─$(cybersec_privilege_indicator) ${CYBERSEC_CMD_SYMBOL} '

# Combine all lines
PROMPT="${CYBERSEC_LINE1}
${CYBERSEC_LINE2}
${CYBERSEC_LINE3}"

# Right prompt: Return status
RPROMPT='$(cybersec_return_status)'

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
    print -P "%F{cyan}║%f    %F{green}CyberSec ZSH Theme v1.0%f            %F{cyan}║%f"
    print -P "%F{cyan}╠════════════════════════════════════════════╣%f"
    print -P "%F{cyan}║%f  Features:                                %F{cyan}║%f"
    print -P "%F{cyan}║%f    ${CYBERSEC_SHIELD_SYMBOL}  Security Status Indicators         %F{cyan}║%f"
    print -P "%F{cyan}║%f    ${CYBERSEC_LOCK_SYMBOL}  Command Logging & Audit Trail      %F{cyan}║%f"
    print -P "%F{cyan}║%f    ${CYBERSEC_GIT_SYMBOL}  Git Integration                    %F{cyan}║%f"
    print -P "%F{cyan}║%f    ⏱  Execution Time Tracking            %F{cyan}║%f"
    print -P "%F{cyan}║%f    📝  History Management                 %F{cyan}║%f"
    print -P "%F{cyan}║%f    🔌  Plugin Support                     %F{cyan}║%f"
    print -P "%F{cyan}╠════════════════════════════════════════════╣%f"
    print -P "%F{cyan}║%f  Status:                                 %F{cyan}║%f"
    print -P "%F{cyan}║%f    Logging: $(if [[ -n "$CYBERSEC_LOGGING_ENABLED" ]]; then print -P "%F{green}Enabled%f "; else print -P "%F{red}Disabled%f"; fi)                   %F{cyan}║%f"
    print -P "%F{cyan}║%f    User: %F{yellow}$(whoami)%f                          %F{cyan}║%f"
    print -P "%F{cyan}║%f    Host: %F{yellow}$(hostname)%f                    %F{cyan}║%f"
    print -P "%F{cyan}╠════════════════════════════════════════════╣%f"
    print -P "%F{cyan}║%f  Commands:                               %F{cyan}║%f"
    print -P "%F{cyan}║%f    cybersec_theme_info                   %F{cyan}║%f"
    print -P "%F{cyan}║%f    cybersec_list_plugins                 %F{cyan}║%f"
    print -P "%F{cyan}║%f    cybersec_load_plugin <name> [type]    %F{cyan}║%f"
    print -P "%F{cyan}║%f    logsearch <term> [days]               %F{cyan}║%f"
    print -P "%F{cyan}║%f    logsummary [days]                     %F{cyan}║%f"
    print -P "%F{cyan}║%f    hstats                                %F{cyan}║%f"
    print -P "%F{cyan}╚════════════════════════════════════════════╝%f"
    print -P ""
}

# ================================================================
# STARTUP MESSAGE
# ================================================================
print -P ""
print -P "%F{green}✓%f CyberSec ZSH Theme Loaded"
print -P "  Type %F{cyan}cybersec_theme_info%f for more information"
print -P ""

