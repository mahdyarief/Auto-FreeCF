#!/bin/bash
set -e

# Auto-FreeCF Runner
# Usage:
#   ./run.sh --service-account <path> --delegated-email <email> --domain <domain> [--count N]
#   ./run.sh --token-file <path>  (for extracting CF account IDs)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Activate venv
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "Error: venv not found. Run: python3 -m venv venv && venv/bin/pip install -r requirements.txt"
    exit 1
fi

# Check if we're in token mode or Google Workspace mode
if [ "$1" = "--token-file" ]; then
    # Token extraction mode
    python cf_workerai_manager.py --token-file "$2"
elif [ "$1" = "--service-account" ]; then
    # Google Workspace user creation mode
    python bot.py "$@"
else
    echo "Usage:"
    echo "  Create Google Workspace users:"
    echo "    ./run.sh --service-account <path> --delegated-email <email> --domain <domain> [--count N]"
    echo ""
    echo "  Extract CF Account IDs:"
    echo "    ./run.sh --token-file <path>"
    exit 1
fi
