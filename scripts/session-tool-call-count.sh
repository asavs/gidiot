#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <exported-session.json>" >&2
    exit 2
fi

# A normal terminal reason alone is insufficient: North Mini can return a
# generic clarification with `stop` without acting on the directive. OpenCode
# records every executor action as a `tool` part in the exported session.
jq -r '[.. | objects | select(.type? == "tool")] | length' "$1"
