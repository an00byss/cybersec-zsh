# ================================================================
# CYBERSEC LOGGING MODULE
# ================================================================
# Provides comprehensive command logging for security auditing
# ================================================================

# Configuration
CYBERSEC_LOG_DIR="${CYBERSEC_LOG_DIR:-$HOME/.zsh_logs}"
CYBERSEC_LOG_FILE="${CYBERSEC_LOG_DIR}/zsh-commands-$(date +%Y-%m-%d).log"
CYBERSEC_AUDIT_LOG="${CYBERSEC_LOG_DIR}/zsh-audit.log"
CYBERSEC_ERROR_LOG="${CYBERSEC_LOG_DIR}/zsh-errors.log"
CYBERSEC_LOGGING_ENABLED=true

# Create log directory
mkdir -p "$CYBERSEC_LOG_DIR"
chmod 700 "$CYBERSEC_LOG_DIR"

# ================================================================
# LOGGING FUNCTIONS
# ================================================================

# Log command before execution
function cybersec_log_preexec() {
    if [[ "$CYBERSEC_LOGGING_ENABLED" != "true" ]]; then
        return
    fi
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local username=$(whoami)
    local hostname=$(hostname)
    local pwd_path=$(pwd)
    local command_line="$1"
    local pid=$$
    local parent_pid=$PPID
    local tty=$(tty 2>/dev/null || echo "unknown")
    local ssh_info="${SSH_CLIENT:-LOCAL}"
    
    # Create log entry
    local log_entry="[${timestamp}] USER=${username} HOST=${hostname} TTY=${tty} SSH=${ssh_info} PID=${pid} PPID=${parent_pid} PWD=${pwd_path} CMD=${command_line}"
    
    # Write to daily log
    echo "$log_entry" >> "$CYBERSEC_LOG_FILE"
    
    # Write to audit log if privileged
    if [[ $EUID -eq 0 ]]; then
        echo "[ROOT] $log_entry" >> "$CYBERSEC_AUDIT_LOG"
    fi
    
    # Check for potentially dangerous commands
    cybersec_check_dangerous_command "$command_line" "$timestamp"
}

# Log command completion
function cybersec_log_precmd() {
    if [[ "$CYBERSEC_LOGGING_ENABLED" != "true" ]]; then
        return
    fi
    
    local exit_code=$?
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Log errors
    if [[ $exit_code -ne 0 ]]; then
        local last_cmd=$(fc -ln -1)
        echo "[${timestamp}] EXIT_CODE=${exit_code} CMD=${last_cmd}" >> "$CYBERSEC_ERROR_LOG"
    fi
}

# ================================================================
# DANGEROUS COMMAND DETECTION
# ================================================================
function cybersec_check_dangerous_command() {
    local command=$1
    local timestamp=$2
    local is_dangerous=0
    
    # Check for dangerous command patterns using case statement
    case "$command" in
        *"rm -rf /"*)
            is_dangerous=1
            ;;
        *"rm -rf /*"*)
            is_dangerous=1
            ;;
        *"dd if=/dev/zero"*)
            is_dangerous=1
            ;;
        *"mkfs"*)
            is_dangerous=1
            ;;
        *":(){ :|:& };:"*)
            is_dangerous=1
            ;;
        *"chmod -R 777"*)
            is_dangerous=1
            ;;
        *"chmod 777"*)
            is_dangerous=1
            ;;
        *"wget"*"|"*"bash"*)
            is_dangerous=1
            ;;
        *"curl"*"|"*"bash"*)
            is_dangerous=1
            ;;
        *"> /dev/sda"*)
            is_dangerous=1
            ;;
        *"> /dev/sd"*)
            is_dangerous=1
            ;;
        *"rm -rf --no-preserve-root"*)
            is_dangerous=1
            ;;
        *"shred"*)
            is_dangerous=1
            ;;
        *":(){:|:&};:"*)
            is_dangerous=1
            ;;
    esac
    
    # Log if dangerous
    if [[ $is_dangerous -eq 1 ]]; then
        local alert="[${timestamp}] [ALERT] DANGEROUS COMMAND DETECTED: ${command}"
        echo "$alert" >> "$CYBERSEC_AUDIT_LOG"
        
        # Try to send to syslog if logger is available
        if command -v logger &> /dev/null; then
            echo "$alert" | logger -t "CYBERSEC_ZSH" -p user.warning 2>/dev/null || true
        fi
        
        # Visual warning in terminal
        print -P "%F{red}⚠️  WARNING: Potentially dangerous command detected!%f"
    fi
}

# ================================================================
# LOG ROTATION
# ================================================================
function cybersec_rotate_logs() {
    local max_age_days=${1:-30}
    
    echo "Rotating logs older than ${max_age_days} days..."
    
    # Compress old logs
    find "$CYBERSEC_LOG_DIR" -name "zsh-commands-*.log" -mtime +${max_age_days} -exec gzip {} \; 2>/dev/null
    
    # Keep compressed logs for 90 days
    find "$CYBERSEC_LOG_DIR" -name "zsh-commands-*.log.gz" -mtime +90 -delete 2>/dev/null
    
    echo "✓ Log rotation complete."
}

# ================================================================
# LOG SEARCH UTILITIES
# ================================================================
function cybersec_search_logs() {
    local search_term=$1
    local days_back=${2:-7}
    
    if [[ -z "$search_term" ]]; then
        echo "Usage: cybersec_search_logs <search_term> [days_back]"
        echo "Example: cybersec_search_logs 'sudo' 7"
        return 1
    fi
    
    echo "Searching logs for: $search_term (last $days_back days)"
    echo "========================================================"
    
    # Search in recent log files
    find "$CYBERSEC_LOG_DIR" -name "zsh-commands-*.log" -mtime -${days_back} -type f -exec grep -i "$search_term" {} + 2>/dev/null
    
    # Search in compressed logs
    find "$CYBERSEC_LOG_DIR" -name "zsh-commands-*.log.gz" -mtime -${days_back} -type f -exec zgrep -i "$search_term" {} + 2>/dev/null
}

# Enhanced log search with filters
function cybersec_search_logs_advanced() {
    local search_term=$1
    local user_filter=$2
    local days_back=${3:-7}
    
    if [[ -z "$search_term" ]]; then
        echo "Usage: cybersec_search_logs_advanced <search_term> [user] [days_back]"
        echo "Example: cybersec_search_logs_advanced 'sudo' 'root' 7"
        return 1
    fi
    
    echo "Advanced search: $search_term"
    [[ -n "$user_filter" ]] && echo "User filter: $user_filter"
    echo "Days back: $days_back"
    echo "========================================================"
    
    local results=$(find "$CYBERSEC_LOG_DIR" -name "zsh-commands-*.log" -mtime -${days_back} -type f -exec grep -i "$search_term" {} + 2>/dev/null)
    
    if [[ -n "$user_filter" ]]; then
        echo "$results" | grep "USER=${user_filter}"
    else
        echo "$results"
    fi
}

# Search for root commands only
function cybersec_search_root_commands() {
    local days_back=${1:-7}
    
    echo "Root commands (last $days_back days)"
    echo "========================================================"
    
    find "$CYBERSEC_LOG_DIR" -name "zsh-commands-*.log" -mtime -${days_back} -type f -exec grep "\[ROOT\]" {} + 2>/dev/null | tail -50
}

# Search for failed commands
function cybersec_search_errors() {
    local days_back=${1:-7}
    
    echo "Failed commands (last $days_back days)"
    echo "========================================================"
    
    if [[ -f "$CYBERSEC_ERROR_LOG" ]]; then
        tail -100 "$CYBERSEC_ERROR_LOG"
    fi
}

# ================================================================
# SESSION LOGGING
# ================================================================
function cybersec_start_session_log() {
    if ! command -v script &> /dev/null; then
        echo "Error: 'script' command not found. Install it to use session logging."
        return 1
    fi
    
    local session_log="${CYBERSEC_LOG_DIR}/session-$(date +%Y%m%d-%H%M%S)-$$.log"
    echo "Starting session log: $session_log"
    script -q "$session_log"
}

# ================================================================
# LOG ANALYSIS
# ================================================================
function cybersec_log_summary() {
    local days=${1:-1}
    
    echo "=== Log Summary (Last $days day(s)) ==="
    echo ""
    
    local log_files=$(find "$CYBERSEC_LOG_DIR" -name "zsh-commands-*.log" -mtime -${days} -type f)
    
    if [[ -z "$log_files" ]]; then
        echo "No logs found for the specified period."
        return
    fi
    
    echo "Total commands executed:"
    cat $log_files 2>/dev/null | wc -l
    
    echo ""
    echo "Commands by user:"
    grep -h "USER=" $log_files 2>/dev/null | sed -n 's/.*USER=\([^ ]*\).*/\1/p' | sort | uniq -c | sort -rn
    
    echo ""
    echo "Most common commands:"
    grep -h "CMD=" $log_files 2>/dev/null | sed -n 's/.*CMD=\([^ ]*\).*/\1/p' | sort | uniq -c | sort -rn | head -10
    
    echo ""
    echo "SSH sessions:"
    grep -h "SSH=" $log_files 2>/dev/null | grep -v "SSH=LOCAL" | sed -n 's/.*SSH=\([^ ]*\).*/\1/p' | sort -u
    
    echo ""
    if [[ -f "$CYBERSEC_AUDIT_LOG" ]]; then
        local alerts=$(grep "\[ALERT\]" "$CYBERSEC_AUDIT_LOG" 2>/dev/null | wc -l)
        echo "Security alerts: $alerts"
        
        if [[ $alerts -gt 0 ]]; then
            echo ""
            echo "Recent alerts:"
            grep "\[ALERT\]" "$CYBERSEC_AUDIT_LOG" | tail -5
        fi
    fi
}

# ================================================================
# EXPORT LOGS
# ================================================================
function cybersec_export_logs() {
    local days=${1:-7}
    local output_file="${2:-cybersec-logs-export-$(date +%Y%m%d).tar.gz}"
    
    echo "Exporting logs from last $days days..."
    
    local temp_dir=$(mktemp -d)
    
    # Copy recent logs
    find "$CYBERSEC_LOG_DIR" -name "*.log" -mtime -${days} -type f -exec cp {} "$temp_dir/" \;
    find "$CYBERSEC_LOG_DIR" -name "*.log.gz" -mtime -${days} -type f -exec cp {} "$temp_dir/" \;
    
    # Create archive
    tar -czf "$output_file" -C "$temp_dir" .
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo "✓ Logs exported to: $output_file"
}

# ================================================================
# ALIASES
# ================================================================
alias logsearch='cybersec_search_logs'
alias logsearch-advanced='cybersec_search_logs_advanced'
alias logsearch-root='cybersec_search_root_commands'
alias logsearch-errors='cybersec_search_errors'
alias logrotate='cybersec_rotate_logs'
alias logsummary='cybersec_log_summary'
alias logexport='cybersec_export_logs'
alias logsession='cybersec_start_session_log'

# ================================================================
# REGISTER HOOKS
# ================================================================
autoload -Uz add-zsh-hook
add-zsh-hook preexec cybersec_log_preexec
add-zsh-hook precmd cybersec_log_precmd

# ================================================================
# STARTUP MESSAGE
# ================================================================
print -P "%F{green}✓%f CyberSec Logging Module Loaded"
print -P "  Log Directory: %F{cyan}${CYBERSEC_LOG_DIR}%f"
print -P "  Daily Log: %F{cyan}$(basename $CYBERSEC_LOG_FILE)%f"

# Log the shell startup
if [[ "$CYBERSEC_LOGGING_ENABLED" == "true" ]]; then
    local startup_msg="[$(date '+%Y-%m-%d %H:%M:%S')] [SHELL_START] USER=$(whoami) HOST=$(hostname) TTY=$(tty 2>/dev/null || echo 'unknown') PID=$$"
    echo "$startup_msg" >> "$CYBERSEC_LOG_FILE"
fi

