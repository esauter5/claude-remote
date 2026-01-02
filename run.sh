#!/bin/bash
#
# Run Claude Remote setup on a VM
# Usage: ./run.sh [host]
#
# If host is not provided, uses VM_HOST from .env
# Initial connection is as root, but script creates a non-root user
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
GIST_URL="https://gist.githubusercontent.com/esauter5/3e32fea061b53d51c524b34897bdb15d/raw/setup.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

error() { echo -e "${RED}Error:${NC} $1" >&2; exit 1; }
log() { echo -e "${GREEN}==>${NC} $1"; }

# Check for .env
if [[ ! -f "$ENV_FILE" ]]; then
    error ".env file not found. Run: cp .env.example .env && edit .env"
fi

# Source .env
source "$ENV_FILE"

# Get host from arg or .env
HOST="${1:-$VM_HOST}"
USER="${VM_USER:-claude}"

if [[ -z "$HOST" ]]; then
    error "No host specified. Set VM_HOST in .env or pass as argument."
fi

# Validate required vars
if [[ -z "$GIT_NAME" ]]; then
    error "GIT_NAME not set in .env"
fi

if [[ -z "$GIT_EMAIL" ]]; then
    error "GIT_EMAIL not set in .env"
fi

log "Connecting to root@$HOST..."
log "Will create user: $USER"
log "Git config: $GIT_NAME <$GIT_EMAIL>"

# SSH in as root and run setup with env vars
ssh -t "root@$HOST" "curl -fsSL '$GIST_URL' | VM_USER='$USER' GIT_NAME='$GIT_NAME' GIT_EMAIL='$GIT_EMAIL' bash"

log "Setup complete!"
log ""
log "Update your SSH config:"
log "  Host claude-vm"
log "      HostName <vm-ip>"
log "      User $USER"
log ""
log "Then connect with: ssh claude-vm"
