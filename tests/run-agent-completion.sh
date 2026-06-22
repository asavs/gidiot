#!/bin/bash

set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

fixture_repo="$tmp/repo"
fake_executor="$tmp/fake-opencode"
impl="$tmp/impl.md"

git init -q -b main "$fixture_repo"
git -C "$fixture_repo" config user.name "Runner test"
git -C "$fixture_repo" config user.email "runner-test@example.invalid"
printf 'base\n' > "$fixture_repo/README.md"
git -C "$fixture_repo" add README.md
git -C "$fixture_repo" commit -qm "base"
printf '# no-op implementation instructions\n' > "$impl"

cat > "$fake_executor" <<'FAKE'
#!/bin/bash
set -euo pipefail

case "$1" in
    run)
        if [ "$FAKE_RUN_MODE" = "success" ]; then
            printf 'completed by fake executor\n' > completion.txt
            git add completion.txt
            git commit -qm "executor completion"
        fi
        exit 0
        ;;
    session)
        printf '[{"id":"fake-session","title":"agent-run-%s","created":1}]\n' "$FAKE_RUN_ID"
        ;;
    export)
        cat "$FAKE_SESSION_JSON"
        ;;
esac
FAKE
chmod +x "$fake_executor"

if command -v cygpath >/dev/null 2>&1 && [ -n "${LOCALAPPDATA:-}" ]; then
    run_base="$(cygpath -u "$LOCALAPPDATA")/Temp/opencode"
else
    run_base="${TMPDIR:-/tmp}/opencode"
fi

cleanup_case_worktree() {
    local name="$1"
    local worktree="$run_base/run-$name"
    git -C "$fixture_repo" worktree remove --force "$worktree" >/dev/null 2>&1 || true
    rm -rf "$worktree"
    git -C "$fixture_repo" branch -D "agent/$name" >/dev/null 2>&1 || true
}

run_case() {
    local name="$1"
    local mode="$2"
    local reason="$3"
    local tool_calls="$4"
    local expected_exit="$5"
    local session="$tmp/$name-session.json"
    printf '[' > "$session"
    {
        printf '{"type":"step-finish","reason":"%s","modelID":"north-mini-code-free"}\n' "$reason"
        if [ "$tool_calls" = "yes" ]; then
            printf ',{"type":"tool","tool":"bash"}\n'
        fi
    } >> "$session"
    printf ']\n' >> "$session"
    cleanup_case_worktree "$name"

    set +e
    (
        cd "$fixture_repo"
        FAKE_RUN_ID="$name" \
        FAKE_RUN_MODE="$mode" \
        FAKE_SESSION_JSON="$session" \
        EXECUTOR_CMD="$fake_executor" \
        EXECUTOR_HOME="$HOME" \
        EXECUTOR_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}" \
        EXECUTOR_PATH="$PATH" \
        "$repo_root/run-agent.sh" --base main "$name" "$impl"
    )
    local actual_exit=$?
    set -e

    if [ "$actual_exit" -ne "$expected_exit" ]; then
        echo "Expected $name to exit $expected_exit, got $actual_exit" >&2
        exit 1
    fi

    cleanup_case_worktree "$name"
}

test_prefix="runner-test-$$"
run_case "$test_prefix-length" no-change length no 4
run_case "$test_prefix-generic-stop" success stop no 7
run_case "$test_prefix-action-stop" success stop yes 0

echo "run-agent completion checks passed"
