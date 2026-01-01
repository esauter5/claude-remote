#!/bin/bash
#
# Claude Code Remote Setup Script
# Run on a fresh Ubuntu 24.04 VM (as root)
#
# Usage:
#   curl -fsSL https://gist.githubusercontent.com/esauter5/13d635eab299c9a4bde76af1846e439a/raw/setup.sh | bash
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root"
fi

# ----------------------------
# Configuration (edit these)
# ----------------------------
GIT_NAME="${GIT_NAME:-}"
GIT_EMAIL="${GIT_EMAIL:-}"

# ----------------------------
# Security
# ----------------------------
log "Configuring firewall..."
apt-get update -qq
apt-get install -y -qq ufw fail2ban unattended-upgrades > /dev/null

ufw default deny incoming > /dev/null
ufw default allow outgoing > /dev/null
ufw allow 22/tcp > /dev/null
ufw --force enable > /dev/null

log "Hardening SSH..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

log "Enabling automatic security updates..."
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# ----------------------------
# Core Tools
# ----------------------------
log "Installing core packages..."
apt-get install -y -qq tmux git curl micro htop > /dev/null

# ----------------------------
# Node.js + Claude Code
# ----------------------------
log "Installing Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - > /dev/null 2>&1
apt-get install -y -qq nodejs > /dev/null

log "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code > /dev/null 2>&1

# ----------------------------
# Git Configuration
# ----------------------------
if [[ -n "$GIT_NAME" ]]; then
    log "Configuring git..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
fi

# Generate SSH key if it doesn't exist
if [[ ! -f ~/.ssh/id_ed25519 ]]; then
    log "Generating SSH key..."
    ssh-keygen -t ed25519 -C "${GIT_EMAIL:-claude-vm}" -f ~/.ssh/id_ed25519 -N ""
fi

# ----------------------------
# GitHub CLI
# ----------------------------
log "Installing GitHub CLI..."
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt-get update -qq
apt-get install -y -qq gh > /dev/null

log "Authenticating with GitHub..."
echo "Complete the browser auth flow to continue."
gh auth login -p https -h github.com -s admin:public_key -w

log "Adding SSH key to GitHub..."
gh ssh-key add ~/.ssh/id_ed25519.pub --title "claude-vm"

# ----------------------------
# Tmux Configuration
# ----------------------------
log "Configuring tmux..."
cat > ~/.tmux.conf << 'EOF'
# Prefix: Ctrl-a (easier than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Mouse support (useful for mobile)
set -g mouse on

# Larger history
set -g history-limit 50000

# Start numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Faster escape (better for vim/micro)
set -s escape-time 0

# Status bar
set -g status-position top
set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
set -g status-left '#[fg=#89b4fa,bold][#S] '
set -g status-right '#[fg=#a6adc8]%H:%M '

# Reload config
bind r source-file ~/.tmux.conf \; display "Reloaded"

# Split panes with | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
EOF

# ----------------------------
# Bash Configuration
# ----------------------------
log "Configuring bash..."
cat >> ~/.bashrc << 'EOF'

# --- Claude Remote Setup ---

# Auto-attach tmux on SSH login
if [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    tmux attach 2>/dev/null || tmux new
fi

# Aliases
alias c='claude'
alias cc='claude --continue'

# Colored prompt showing we're on remote
PS1='\[\e[32m\]\u@claude-vm\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ '

# Better history
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# --- End Claude Remote Setup ---
EOF

# ----------------------------
# Projects directory
# ----------------------------
mkdir -p ~/projects

# ----------------------------
# Summary
# ----------------------------
echo ""
echo "=========================================="
echo -e "${GREEN}Setup complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Authenticate Claude Code:"
echo "   claude"
echo ""
echo "2. Reconnect to SSH (to start tmux automatically)"
echo ""
echo "=========================================="
