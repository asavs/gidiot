<!--
Implementation instructions — written by the Senior Engineer (see AGENTS.md
"Working roles"). The seam hands this file to the Junior Engineer inside the run worktree
(at .agent-input/<id>.md) and the directive reads it from there. Captures HOW, step
by step, precisely enough to execute without rediscovering settled decisions. Point to the
GitHub issue for intent; do not restate it.
-->

# Junior Engineer handoff: <short title>

**Issue:** #<n>   <!-- the WHAT/WHY; this handoff expands it into a bounded plan -->

## Role
You are the **Junior Engineer**. Implement this bounded task faithfully. Do not broaden
scope or redesign settled decisions. Resolve ordinary local failures yourself; if progress
stops, provide a distilled report of what you tried, the persistent failure signature, and
your hypothesis.

## Files & steps (in order)
<!-- ordered and concrete: each step names a file and the exact edit/creation to make.
If a step installs dependencies, use the frozen-lockfile form (`npm ci`, not `npm install`)
so the run's diff stays the intended files only — a mutating install rewrites the lockfile. -->
1.
2.

## Approach notes
<!-- non-obvious decisions already made by the Senior Engineer, so the Junior makes no
new architecture or product judgment calls -->

## Local gate (converge to green before pushing)
<!-- the exact command the Junior Engineer loops on: lint + focused tests. CI is the final verdict.
The gate must **exercise the produced artifact** — a smoke run, dry-run, or focused behavior
test — not a parse-only / syntax-only check: a `bash -n`-clean script can still carry semantic
bugs (e.g. a `set -e` exit-capture defeat or a cwd-dependent `cd`) that only a real run surfaces.
Scope the gate to the **touched files**: pre-existing lint/test debt in untouched files is a
false signal and must not fail the gate (run the linter/tests on the changed paths, not repo-wide).
Use POSIX paths relative to $PWD (the worktree root); never `cd` to a Windows C:\ path —
the worktree lives at an OS temp path and absolute drive paths break the gate. -->
```bash
<command>
```

## Commit (on success)
<!-- Committing the work is part of the run, not a follow-up: the Junior Engineer does not commit
unless told to. Name the files to stage and the message; an uncommitted tree is an
incomplete run. -->
```bash
git add <files this run created/modified>
git commit -m "<type>(<scope>): <imperative summary>"
```

## Reminders
- Make the smallest change that satisfies the issue; do not refactor uninvited.
- Honor the folder-scoped GUIDELINES for any area you touch.
- A run is complete only when its intended changes are committed — an uncommitted (or
  partially committed) worktree is an incomplete run, not a finished one.
- If you cannot converge, emit a distilled failure report (what was tried, the persistent
  failure signature, your hypothesis) and stop — do not thrash past the cap.
