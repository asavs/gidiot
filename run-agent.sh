#!/bin/bash

EXECUTOR_CMD="${EXECUTOR_CMD:-opencode}"
EXECUTOR_MODEL="${EXECUTOR_MODEL:-opencode/north-mini-code-free}"
EXECUTOR_AGENT="${EXECUTOR_AGENT:-build}"
# north-mini-code-free supports the `none` and `high` reasoning variants only;
# there is no --reasoning-default run flag.
EXECUTOR_VARIANT="${EXECUTOR_VARIANT:-high}"

# OpenCode reads its providers/auth and config from the operator's real home.
# When run-agent.sh is dispatched from a context with a stripped environment,
# these must point back at that config or opencode silently falls back to a
# default model. Defaults capture the invoking shell's environment; override
# per machine. On native Git Bash these resolve to the user's real config.
EXECUTOR_HOME="${EXECUTOR_HOME:-$HOME}"
EXECUTOR_XDG_CONFIG_HOME="${EXECUTOR_XDG_CONFIG_HOME:-$EXECUTOR_HOME/.config}"
EXECUTOR_PATH="${EXECUTOR_PATH:-$EXECUTOR_HOME/.bun/bin:$PATH}"

set -euo pipefail

# jq parses the exported session metadata for the model assertion.
command -v jq >/dev/null 2>&1 || { echo "Error: 'jq' is required (session model assertion)" >&2; exit 2; }

# Launch the executor with the operator's real config regardless of the
# environment run-agent.sh was dispatched from.
run_executor() {
    env HOME="$EXECUTOR_HOME" XDG_CONFIG_HOME="$EXECUTOR_XDG_CONFIG_HOME" PATH="$EXECUTOR_PATH" "$@"
}

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
# North Mini advertises attachment: false, so the directive points at a
# worktree-local file (written below) rather than relying on -f.
directive="${3:-Read .agent-input/$run_id.md and execute it exactly. Create or modify only the files it names.}"

abs_impl="$(realpath "$impl_file")"
if [ ! -f "$abs_impl" ]; then
    echo "Error: implementation-instructions file '$impl_file' not found" >&2
    exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"
: "${base_ref:=$(detect_default_branch)}"

# OpenCode only permits worktrees under specific allowed external paths; on
# Windows that is %LOCALAPPDATA%\Temp\opencode. Build a POSIX path so the
# worktree and every local-gate command use forward-slash paths, never cd C:\.
if command -v cygpath >/dev/null 2>&1 && [ -n "${LOCALAPPDATA:-}" ]; then
    run_base="$(cygpath -u "$LOCALAPPDATA")/Temp/opencode"
else
    run_base="${TMPDIR:-/tmp}/opencode"
fi
mkdir -p "$run_base"
worktree="$run_base/run-$run_id"

git worktree add "$worktree" -b "agent/$run_id" "$base_ref"
cd "$worktree"
echo "RUN $run_id: worktree '$worktree' branched from base ref '$base_ref'"

# The seam owns the run log: write it to the main checkout, outside the
# executor's worktree, so a correction (run -c) running inside the worktree
# cannot delete or truncate it. Append, never overwrite, so the prior run's
# record survives each correction.
log_dir="$repo_root/.agent-runs"
mkdir -p "$log_dir"
log="$log_dir/$run_id.log"

# Hand the implementation-instructions to the executor as a worktree-local file
# (North Mini does not accept attachments); the directive reads it from $PWD.
mkdir -p "$worktree/.agent-input"
cp "$abs_impl" "$worktree/.agent-input/$run_id.md"

# Options MUST precede the directive: opencode parses the variadic [message..]
# positional before flags, so any flag after the directive is swallowed as
# prompt text and the run silently uses the default model.
# Redirect stdin from /dev/null: launched detached (no TTY) opencode otherwise
# blocks on its stdio environment instead of running headless.
session_title="agent-run-$run_id"
if run_executor "$EXECUTOR_CMD" run \
        --agent "$EXECUTOR_AGENT" \
        --model "$EXECUTOR_MODEL" \
        --variant "$EXECUTOR_VARIANT" \
        --format json \
        --title "$session_title" \
        --dangerously-skip-permissions \
        "$directive" < /dev/null >> "$log" 2>&1; then
    exit_code=0
else
    exit_code=$?
fi

echo "$worktree"
echo "$log"

# Assert the executor actually dispatched the intended model. Resolve the run's
# session by its unique title and read modelID from the exported metadata; a
# blank or mismatched model means flags were swallowed (silent fallback) or the
# config was unreachable. A green gate on the wrong model is still a failed run.
expected_model="${EXECUTOR_MODEL#*/}"
session_json="$log_dir/$run_id.session.json"
sid="$(run_executor "$EXECUTOR_CMD" session list -n 50 --format json 2>>"$log" \
    | jq -r --arg t "$session_title" 'map(select(.title==$t)) | sort_by(.created) | last | .id // empty' || true)"
resolved_model=""
if [ -n "$sid" ]; then
    run_executor "$EXECUTOR_CMD" export "$sid" --sanitize > "$session_json" 2>>"$log" || true
    resolved_model="$(jq -r '[.. | .modelID? // empty] | unique | .[0] // ""' "$session_json" 2>/dev/null || true)"
fi

if [ "$resolved_model" != "$expected_model" ]; then
    echo "RUN $run_id: FAIL - resolved model '${resolved_model:-<none>}' != expected '$expected_model'" >&2
    echo "  session: ${sid:-<none matched title '$session_title'>} | metadata: $session_json | log: $log" >&2
    echo "  A blank/wrong model means flags were swallowed as prompt text or the executor config was unreachable." >&2
    exit 3
fi

if [ $exit_code -eq 0 ]; then
    echo "RUN $run_id: success (local gate green, model '$resolved_model'). Review: $worktree"
    exit 0
else
    echo "RUN $run_id: stuck - distilled report in $log"
    exit $exit_code
fi
