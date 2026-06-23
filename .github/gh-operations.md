# gh-operations

How to drive `gh` / `gh api` per GitHub primitive — so an agent authoring issues,
milestones, dependencies, and the Project board can do it without re-deriving the
mechanics. The proven gotchas from the #11/#27 dogfood live here, not in a transcript.

Replace `{owner}/{repo}` with the target repo (or rely on `gh`'s repo inference).

## Reading issues / fields

```bash
gh issue list --json number,title,milestone,labels
```

Some operations below need an issue's **internal `id`** (a large integer), not its
human-facing **number**. Get both at once:

```bash
gh api 'repos/{owner}/{repo}/issues?state=open&per_page=100' \
  --jq '.[]|"\(.number)\t\(.id)"'
```

## Issue dependencies & sub-issues — REST-only

Dependencies (hard order — A is *blocked_by* B) and sub-issues (decomposition — a
parent owns children) have **no first-class `gh` verb**. Drive them through `gh api`:

```bash
# A is blocked by another issue (dependency / hard order)
gh api --method POST repos/{owner}/{repo}/issues/{n}/dependencies/blocked_by \
  -F issue_id=<INTERNAL_ID>

# attach a child under a parent (sub-issue / decomposition)
gh api --method POST repos/{owner}/{repo}/issues/{parent}/sub_issues \
  -F sub_issue_id=<INTERNAL_ID>
```

**Gotcha (cost us a 422):** the body must be a *typed integer* of the internal `id`.

- Use `-F` (typed), **not** `-f` — `-f` sends a string and the API rejects it with
  `422 ... not of type integer`.
- It's the issue **`id`** (the large internal integer), **not** its **number**.

Progress surfaces back on the issue payload — read it rather than tracking it yourself:

```bash
gh api repos/{owner}/{repo}/issues/{n} \
  --jq '{issue_dependencies_summary, sub_issues_summary}'
```

## Milestones & labels

```bash
gh issue edit <n> --milestone "M0: Project management primitives"
gh issue edit <n> --add-label ready

gh label create <name> --color <hex> --description "..."
```

## Projects v2 — the operating board

Projects v2 needs a **`project`-scoped token**. The default `repo` token can neither
read nor write Projects v2 — `gh project ...` fails with a missing `read:project`
scope. One-time setup prerequisite:

```bash
gh auth refresh -s project
```

Then add items and set fields:

```bash
gh project item-add <num> --owner <owner> --url <issue-url>
gh project item-edit ...   # set Status, custom fields, etc.
```

## Two principles worth stating

- **Native fields flow through — no double-entry.** A milestone set *on the issue*
  appears on the board's Milestone field automatically. Set facts on the primitive,
  not on the Project; the board reflects them.
- **Blocked-ness is a label, never a Status.** Project `Status` is only
  `Todo` / `In Progress` / `Done`. Express "blocked" with a label (and the real
  dependency via the `blocked_by` API above), not by inventing a Status value.
