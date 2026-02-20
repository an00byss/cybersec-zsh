# ================================================================
# CYBERSEC HELPER FUNCTIONS
# ================================================================

# Quick security check
function cybersec_syscheck() {
    print -P "\n%F{cyan}=== System Security Check ===%f\n"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print -P "%F{red}⚠️  Running as ROOT%f"
    else
        print -P "%F{green}✓%f Running as user: $(whoami)"
    fi
    
    # Check SSH connection
    if [[ -n "$SSH_CLIENT" ]]; then
        print -P "%F{yellow}🌐 SSH Connection from: $SSH_CLIENT%f"
    else
        print -P "%F{green}💻 Local session%f"
    fi
    
    # Check logging status
    if [[ "$CYBERSEC_LOGGING_ENABLED" == "true" ]]; then
        print -P "%F{green}✓%f Command logging: ENABLED"
    else
        print -P "%F{red}✗%f Command logging: DISABLED"
    fi
    
    # Check for suspicious processes (optional)
    if command -v netstat &>/dev/null; then
        local listening=$(netstat -tuln 2>/dev/null | grep LISTEN | wc -l)
        print -P "%F{cyan}📡 Listening ports: $listening%f"
    fi
    
    # Disk usage
    print -P "%F{cyan}💾 Disk usage:%f"
    df -h / | tail -1 | awk '{print "   "$5" used on "$6}'
    
    print -P ""
}

# Quick log viewer
function cybersec_quicklog() {
    local lines=${1:-20}
    
    if [[ -f "$CYBERSEC_LOG_FILE" ]]; then
        print -P "\n%F{cyan}=== Last $lines commands ===%f\n"
        tail -$lines "$CYBERSEC_LOG_FILE" | while read line; do
            echo "$line"
        done
    else
        print -P "%F{red}✗%f Log file not found"
    fi
}

# Toggle logging
function cybersec_toggle_logging() {
    if [[ "$CYBERSEC_LOGGING_ENABLED" == "true" ]]; then
        export CYBERSEC_LOGGING_ENABLED=false
        print -P "%F{yellow}⚠️  Logging DISABLED%f"
    else
        export CYBERSEC_LOGGING_ENABLED=true
        print -P "%F{green}✓%f Logging ENABLED"
    fi
}

# Aliases
alias syscheck='cybersec_syscheck'
alias quicklog='cybersec_quicklog'
alias togglelog='cybersec_toggle_logging'

print -P "%F{green}✓%f CyberSec Helper Functions Loaded"

