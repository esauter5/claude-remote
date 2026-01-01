#!/bin/bash
#
# Run Claude Remote setup on a VM
# Usage: ./run.sh [host]
#
# If host is not provided, uses VM_HOST from .env
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
GIST_URL="https://gist.githubusercontent.com/esauter5/13d635eab299c9a4bde76af1846e439a/raw/setup.sh"

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

log "Connecting to $HOST..."
log "Git config: $GIT_NAME <$GIT_EMAIL>"

# SSH in and run setup with env vars
ssh -t "$HOST" "curl -fsSL '$GIST_URL' | GIT_NAME='$GIT_NAME' GIT_EMAIL='$GIT_EMAIL' bash"

log "Setup complete!"
log "Reconnect with: ssh $HOST"
