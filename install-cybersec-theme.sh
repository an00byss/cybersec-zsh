#!/bin/bash
# ================================================================
# CYBERSEC ZSH THEME INSTALLER
# ================================================================

set -e

echo "================================================"
echo "  CyberSec ZSH Theme Installation"
echo "================================================"
echo ""

# Configuration
INSTALL_DIR="$HOME/.zsh/cybersec"
THEME_DIR="$INSTALL_DIR/themes"
PLUGIN_DIR="$INSTALL_DIR/plugins"
LOG_DIR="$HOME/.zsh_logs"

# Create directories
echo "[+] Creating directory structure..."
mkdir -p "$THEME_DIR"
mkdir -p "$PLUGIN_DIR/core"
mkdir -p "$PLUGIN_DIR/custom"
mkdir -p "$PLUGIN_DIR/security"
mkdir -p "$LOG_DIR"

# Set secure permissions
chmod 700 "$INSTALL_DIR"
chmod 700 "$LOG_DIR"

echo "[+] Directories created:"
echo "    Theme: $THEME_DIR"
echo "    Plugins: $PLUGIN_DIR"
echo "    Logs: $LOG_DIR"
echo ""

# Backup existing .zshrc
if [[ -f "$HOME/.zshrc" ]]; then
    echo "[+] Backing up existing .zshrc..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Add configuration to .zshrc
echo "[+] Configuring .zshrc..."

cat >> "$HOME/.zshrc" << 'EOF'

# ================================================================
# CYBERSEC ZSH THEME CONFIGURATION
# ================================================================

# Theme location
export ZSH_CUSTOM="$HOME/.zsh/cybersec"

# Logging configuration
export CYBERSEC_LOG_DIR="$HOME/.zsh_logs"
export CYBERSEC_LOGGING_ENABLED=true

# Load theme
source "$ZSH_CUSTOM/themes/cybersec.zsh-theme"

# ================================================================
EOF

echo "[+] Installation complete!"
echo ""
echo "================================================"
echo "  Next Steps:"
echo "================================================"
echo "1. Copy the theme files to: $THEME_DIR"
echo "2. Copy plugin files to: $PLUGIN_DIR/core/"
echo "3. Restart your terminal or run: source ~/.zshrc"
echo "4. Check logs in: $LOG_DIR"
echo ""
echo "================================================"

