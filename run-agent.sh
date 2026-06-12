#!/bin/bash

EXECUTOR_CMD="${EXECUTOR_CMD:-opencode}"
EXECUTOR_MODEL="${EXECUTOR_MODEL:-opencode/north-mini-code-free}"
EXECUTOR_AGENT="${EXECUTOR_AGENT:-build}"

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: ./run-agent.sh <run-id> <implementation-instructions-file> [directive]" >&2
    exit 2
fi

run_id="$1"
impl_file="$2"
directive="${3:-Implement the attached implementation-instructions exactly. Create or modify only the files it names.}"

abs_impl="$(realpath "$impl_file")"
if [ ! -f "$abs_impl" ]; then
    echo "Error: implementation-instructions file '$impl_file' not found" >&2
    exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"

(git worktree add "$repo_root/../run-$run_id" -b "agent/$run_id" || exit 1)
cd "$repo_root/../run-$run_id"

mkdir -p .agent-runs
log="$(realpath .agent-runs)/$run_id.log"

if "$EXECUTOR_CMD" run "$directive" --agent "$EXECUTOR_AGENT" -m "$EXECUTOR_MODEL" --dangerously-skip-permissions -f "$abs_impl" > "$log" 2>&1; then
    exit_code=0
else
    exit_code=$?
fi

worktree="$(pwd)"
echo "$worktree"
echo "$log"

if [ $exit_code -eq 0 ]; then
    echo "RUN $run_id: success (local gate green). Review: $worktree"
    exit 0
else
    echo "RUN $run_id: stuck - distilled report in $log"
    exit $exit_code
fi
