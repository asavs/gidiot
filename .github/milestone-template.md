> Docs-only — GitHub has no native milestone template primitive; this is a guide, not a rendered surface.

# milestone-template

How to write a **phase-gate milestone** so any tier-1 author shapes them the same way.
GitHub won't enforce this; copy the shape by hand when you create the milestone.

## What a phase-gate milestone is

A milestone here is a **phase gate**, not a deadline. It **closes when its issues
close** — never on a due date (leave the date empty; see issue #1). It groups work by
*capability* (what becomes true when the phase lands), and it spans many PRs. QA happens
at each PR, not at the milestone — closing it is just the rollup.

## Title convention

Use a short, intent-shaped capability name, e.g. `M0: Project management primitives`.

> Open question: whether to keep the `M0:` / `M1:` ordinals. They duplicate GitHub's
> own milestone numbers (the milestone already has a stable number), so the prefix may
> be redundant. Left in for now as a human-legible ordering cue; revisit if it drifts.

## Description template

```
<one line: the capability that is true once this phase's issues all close>

Gate: closes when its issues close (not on a date).
In:  <the capabilities / surfaces this phase covers>
Out: <adjacent work explicitly deferred to a later phase>
```
