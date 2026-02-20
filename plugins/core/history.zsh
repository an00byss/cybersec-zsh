# ================================================================
# CYBERSEC HISTORY MODULE
# ================================================================
# Enhanced history configuration for security and forensics
# ================================================================

# History file configuration
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=1000000

# Create backup history directory
CYBERSEC_HISTORY_BACKUP_DIR="$HOME/.zsh_history_backups"
mkdir -p "$CYBERSEC_HISTORY_BACKUP_DIR"
chmod 700 "$CYBERSEC_HISTORY_BACKUP_DIR"

# ================================================================
# HISTORY OPTIONS
# ================================================================
setopt EXTENDED_HISTORY          # Write timestamp to history file
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new is duplicate
setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries to history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording
setopt HIST_VERIFY               # Show command with history expansion before running
setopt INC_APPEND_HISTORY        # Write to history file immediately
setopt SHARE_HISTORY             # Share history between all sessions
setopt APPEND_HISTORY            # Append to history file
setopt HIST_NO_STORE             # Don't store history commands

# ================================================================
# HISTORY BACKUP FUNCTIONS
# ================================================================
function cybersec_backup_history() {
    local backup_file="${CYBERSEC_HISTORY_BACKUP_DIR}/zsh_history_$(date +%Y%m%d_%H%M%S).bak"
    
    if [[ -f "$HISTFILE" ]]; then
        cp "$HISTFILE" "$backup_file"
        gzip "$backup_file"
        print -P "%F{green}✓%f History backed up to: ${backup_file}.gz"
    else
        print -P "%F{red}✗%f History file not found: $HISTFILE"
    fi
}

# Automatic daily backup
function cybersec_auto_backup_history() {
    local today=$(date +%Y%m%d)
    local backup_marker="$CYBERSEC_HISTORY_BACKUP_DIR/.last_backup"
    
    if [[ ! -f "$backup_marker" ]] || [[ "$(cat $backup_marker 2>/dev/null)" != "$today" ]]; then
        cybersec_backup_history
        echo "$today" > "$backup_marker"
    fi
}

# Run backup check on shell start
cybersec_auto_backup_history

# ================================================================
# HISTORY CLEANUP
# ================================================================
function cybersec_clean_history_backups() {
    local days=${1:-90}
    
    echo "Cleaning history backups older than $days days..."
    find "$CYBERSEC_HISTORY_BACKUP_DIR" -name "zsh_history_*.bak.gz" -mtime +${days} -delete 2>/dev/null
    echo "✓ Cleanup complete."
}

# ================================================================
# HISTORY ANALYSIS FUNCTIONS
# ================================================================
function cybersec_history_stats() {
    echo "=== ZSH History Statistics ==="
    echo "Total commands: $(wc -l < $HISTFILE 2>/dev/null || echo 0)"
    echo "Unique commands: $(cut -d';' -f2- $HISTFILE 2>/dev/null | sort -u | wc -l)"
    echo ""
    echo "Top 10 commands:"
    cut -d';' -f2- $HISTFILE 2>/dev/null | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
}

function cybersec_history_search() {
    local term=$1
    
    if [[ -z "$term" ]]; then
        echo "Usage: cybersec_history_search <search_term>"
        return 1
    fi
    
    grep -i "$term" "$HISTFILE" 2>/dev/null | tail -20
}

# ================================================================
# HISTORY FORENSICS
# ================================================================
function cybersec_history_timeline() {
    local days=${1:-1}
    
    echo "=== Command Timeline (Last $days days) ==="
    
    # For systems with GNU date
    if date --version &>/dev/null; then
        local start_date=$(date -d "$days days ago" +%s)
    # For BSD/macOS
    else
        local start_date=$(date -v-${days}d +%s)
    fi
    
    while IFS=';' read -r timestamp command; do
        # Extract timestamp (remove leading colon if present)
        timestamp=${timestamp#*:}
        timestamp=${timestamp## }
        
        if [[ $timestamp =~ ^[0-9]+$ ]] && [[ $timestamp -ge $start_date ]]; then
            # Format timestamp
            if date --version &>/dev/null; then
                local formatted_time=$(date -d @$timestamp '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
            else
                local formatted_time=$(date -r $timestamp '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
            fi
            
            echo "[$formatted_time] $command"
        fi
    done < "$HISTFILE" 2>/dev/null | tail -50
}

# ================================================================
# SENSITIVE DATA PROTECTION
# ================================================================
# Function to remove sensitive commands from history
function cybersec_sanitize_history() {
    local temp_file=$(mktemp)
    local backup_file="${CYBERSEC_HISTORY_BACKUP_DIR}/pre_sanitize_$(date +%Y%m%d_%H%M%S).bak"
    
    # Backup before sanitizing
    cp "$HISTFILE" "$backup_file"
    
    # Remove lines containing sensitive patterns
    grep -viE "(password|passwd|token|secret|key|api.?key)" "$HISTFILE" > "$temp_file" 2>/dev/null
    
    # Replace history file
    mv "$temp_file" "$HISTFILE"
    
    print -P "%F{green}✓%f History sanitized. Backup saved to: $backup_file"
}

# ================================================================
# ALIASES
# ================================================================
alias hbackup='cybersec_backup_history'
alias hclean='cybersec_clean_history_backups'
alias hstats='cybersec_history_stats'
alias hsearch='cybersec_history_search'
alias htimeline='cybersec_history_timeline'
alias hsanitize='cybersec_sanitize_history'

# ================================================================
# STARTUP MESSAGE
# ================================================================
print -P "%F{green}✓%f CyberSec History Module Loaded"
print -P "  History File: %F{cyan}${HISTFILE}%f"
print -P "  History Size: %F{cyan}${HISTSIZE}%f entries"

