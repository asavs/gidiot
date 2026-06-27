> Docs-only — a GitHub Project is a real surface (user/org level), not a repo file. This is a setup guide, not a rendered template. Wire your own Project; nothing here is auto-created.

# project-template

How to adopt a **cross-repo GitHub Project** as your operating view — the one board where work
across your repos is visible and queryable, so an agent finds ready work without the originating
conversation. The Project gathers GitHub's native primitives into a single surface; it does not
replace them.

## Baseline fields — keep the schema minimal

Use built-in fields only:

| Field | Carries |
|-------|---------|
| `Repository` | where the item lives |
| `Milestone` | phase scope |
| `Parent issue` / `Sub-issue progress` | decomposition & progress |
| `Status` | operating state — `Todo` / `In Progress` / `Done` |

Do **not** add a custom `Phase` (milestones are the phase primitive), `Epic` / `Parent`
(parent/sub-issues are the decomposition primitive), or `Priority` (a proven-by-need escape
hatch, not baseline). See the primitive map in [`AGENTS.md`](../AGENTS.md#github-primitive-conventions).

## Operating rules

- **Set each fact on its issue** (milestone, labels, dependencies) — the board mirrors it. No
  double-entry; the issue is the source of truth, the board is the view.
- **`Status` is operating state only.** Blocked-ness is a **label**, never a Status value — a
  blocked issue is still `Todo`.
- **Agents discover work from the board** via the `ready()` predicate (see AGENTS.md): unblocked,
  specced, in the active milestone.

## Wiring it

A Project needs a `project`-scoped token — the default `repo` token cannot read or write
Projects v2:

```bash
gh auth refresh -s project
```

Then add items and set fields (`gh project item-add`, `gh project item-edit` with the Status
field/option ids). The exact commands and gotchas are in
[`gh-operations.md`](./gh-operations.md).

> Replace this line with your own board when you instantiate: name your Project, add the repos
> you want to span, and point your contributors at it.
