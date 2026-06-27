# CLAUDE.md

**Read [AGENTS.md](./AGENTS.md), then the role guide it links for your work.** AGENTS is
the source of truth for repo-wide instructions; the role guides provide the only scoped
extensions. This file deliberately does not duplicate either.

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
