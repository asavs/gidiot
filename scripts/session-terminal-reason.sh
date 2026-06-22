#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <exported-session.json>" >&2
    exit 2
fi

# Session exports contain nested parts. The final step-finish reason, rather
# than the OpenCode process exit code, tells the seam whether the agent
# completed normally (`stop`) or failed non-convergently (`length`, `error`, …).
jq -r '[.. | objects | select(.type? == "step-finish") | .reason?] | last // ""' "$1"
