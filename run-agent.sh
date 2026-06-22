#!/bin/bash

EXECUTOR_CMD="${EXECUTOR_CMD:-opencode}"
EXECUTOR_MODEL="${EXECUTOR_MODEL:-opencode/north-mini-code-free}"
EXECUTOR_AGENT="${EXECUTOR_AGENT:-build}"

set -euo pipefail

usage() {
    echo "Usage: ./run-agent.sh [--base <ref>] <run-id> <implementation-instructions-file> [directive]" >&2
}

# The run's worktree branches from this ref, not the invoking checkout's HEAD,
# so dispatch is deterministic regardless of the operator's current branch.
# Default: the repo's protected default branch.
detect_default_branch() {
    local ref
    if ref="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"; then
        echo "${ref#origin/}"
        return
    fi
    local b
    for b in main master; do
        if git show-ref --verify --quiet "refs/heads/$b"; then
            echo "$b"
            return
        fi
    done
    git rev-parse --abbrev-ref HEAD
}

base_ref=""
positional=()
while [ $# -gt 0 ]; do
    case "$1" in
        --base) base_ref="${2:?--base requires a ref}"; shift 2 ;;
        --base=*) base_ref="${1#*=}"; shift ;;
        -h|--help) usage; exit 0 ;;
        --) shift; while [ $# -gt 0 ]; do positional+=("$1"); shift; done ;;
        *) positional+=("$1"); shift ;;
    esac
done
set -- ${positional[@]+"${positional[@]}"}

if [ $# -lt 2 ]; then
    usage
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
: "${base_ref:=$(detect_default_branch)}"

git worktree add "$repo_root/../run-$run_id" -b "agent/$run_id" "$base_ref"
cd "$repo_root/../run-$run_id"
echo "RUN $run_id: worktree branched from base ref '$base_ref'"

# The seam owns the run log: write it to the main checkout, outside the
# executor's worktree, so a correction (run -c) running inside the worktree
# cannot delete or truncate it. Append, never overwrite, so the prior run's
# record survives each correction.
log_dir="$repo_root/.agent-runs"
mkdir -p "$log_dir"
log="$log_dir/$run_id.log"

if "$EXECUTOR_CMD" run "$directive" --agent "$EXECUTOR_AGENT" -m "$EXECUTOR_MODEL" --dangerously-skip-permissions -f "$abs_impl" >> "$log" 2>&1; then
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
