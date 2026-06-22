#!/bin/bash

set -euo pipefail

# Run from native Git Bash on Windows. This exercises the production OpenCode
# invocation (rather than a fake executor) against the operator's configured
# north-mini-code-free account. It intentionally leaves the isolated worktree
# and its log behind for inspection after a failed run.
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
run_id="${1:-north-mini-smoke-$(date +%s)}"
sentinel=".north-mini-smoke-$run_id"
impl="$(mktemp)"
trap 'rm -f "$impl"' EXIT

cat > "$impl" <<EOF
# North Mini headless smoke test

1. Run \`pwd\` and confirm you are in the isolated worktree.
2. Read \`.agent-input/$run_id.md\` from the current working directory.
3. Create \`$sentinel\` containing exactly \`north-mini smoke passed\` plus a newline.
4. Commit only \`$sentinel\` with message \`test(runner): add North Mini smoke sentinel\`.
EOF

"$repo_root/run-agent.sh" --base origin/main "$run_id" "$impl" \
    "Run pwd. Read .agent-input/$run_id.md from the current working directory, then execute its four steps exactly."

if command -v cygpath >/dev/null 2>&1 && [ -n "${LOCALAPPDATA:-}" ]; then
    run_base="$(cygpath -u "$LOCALAPPDATA")/Temp/opencode"
else
    run_base="${TMPDIR:-/tmp}/opencode"
fi
worktree="$run_base/run-$run_id"

if [ ! -f "$worktree/$sentinel" ]; then
    echo "RUN $run_id: FAIL - North Mini committed no sentinel at $worktree/$sentinel" >&2
    exit 8
fi
if [ "$(cat "$worktree/$sentinel")" != "north-mini smoke passed" ]; then
    echo "RUN $run_id: FAIL - sentinel content is not exact" >&2
    exit 8
fi
if ! git -C "$worktree" log --format=%H -- "$sentinel" | grep -q .; then
    echo "RUN $run_id: FAIL - sentinel is not committed" >&2
    exit 8
fi

echo "RUN $run_id: North Mini smoke passed. Sentinel commit: $(git -C "$worktree" rev-parse HEAD)"
