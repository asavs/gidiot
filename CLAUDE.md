# CLAUDE.md

**Read [AGENTS.md](./AGENTS.md).** It is the single source of truth for agent
instructions in this repo; this file deliberately does not duplicate it.

Put Claude-specific content here only if it would be useless to other LLMs — which
is rare. In practice this file should stay nearly empty.

## Memory boundaries (where to write what)

When you learn something while working here, route it to the right place instead of
defaulting to this file:

- **Repo-shared facts** (stack, gotchas, conventions — useful to *any* contributor
  or agent) → add to **[AGENTS.md](./AGENTS.md)** and commit it.
- **Your per-project working notes** (useful to you, not the team) → your **project
  memory** directory. Not committed.
- **Facts about the user / cross-project preferences** → your **global/user
  memory**. Not committed.

Only land something in `CLAUDE.md` if it's a Claude-only instruction that must be
committed to the repo *and* doesn't generalize to other agents. If it generalizes,
it belongs in `AGENTS.md`.
