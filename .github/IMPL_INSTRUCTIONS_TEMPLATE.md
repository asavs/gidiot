<!--
Implementation-instructions — written by the orchestration tier (see AGENTS.md
"Agent stack"). The seam hands this file to the executor inside the run worktree
(at .agent-input/<id>.md) and the directive reads it from there. Captures HOW, step
by step, precisely enough to execute without judgment. Lazy-point to the intent-spec;
do not restate its intent.
-->

# Implementation-instructions: <short title>

**Intent-spec:** <path or link>   <!-- the WHAT/WHY this expands; points back to the issue -->

## Files & steps (in order)
<!-- ordered and concrete: each step names a file and the exact edit/creation to make -->
1.
2.

## Approach notes
<!-- non-obvious decisions already made for the executor, so it makes no judgment calls -->

## Local gate (converge to green before pushing)
<!-- the exact command the executor loops on: lint + focused tests. CI is the final verdict.
Use POSIX paths relative to $PWD (the worktree root); never `cd` to a Windows C:\ path —
the worktree lives at an OS temp path and absolute drive paths break the gate. -->
```bash
<command>
```

## Reminders
- Make the smallest change that satisfies the intent-spec; do not refactor uninvited.
- Honor the folder-scoped GUIDELINES for any area you touch.
- If you cannot converge, emit a distilled failure report (what was tried, the persistent
  failure signature, your hypothesis) and stop — do not thrash past the cap.