<div align="center">

# {{PROJECT_NAME}}

**{{ONE_LINE_PITCH}}**

<!-- Badges — uncomment and point at your repo.
[![CI](https://github.com/{{OWNER}}/{{REPO}}/actions/workflows/test.yml/badge.svg)](https://github.com/{{OWNER}}/{{REPO}}/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
-->

</div>

---

## What is it?

{{A short, inviting paragraph for a human landing on GitHub. The problem it solves,
who it's for, and the one thing it does well. A screenshot or GIF here earns its
place — show, don't list.}}

## Principles

1. **Idiomatic GitHub use.** A durable system of record and runtime environment. State outlives your ephemeral context and CI runs the toolchain (npm, bun, build to a VM target), so you don't reproduce it locally.

2. **Fail cheap.** Tests, then code review, then QA: passing tests ≠ good code ≠ works for the user. Cheaper gates guard the costlier ones behind them.

3. **Lazy pointers.** Each fact has one home, and everything else points to it with a gist, so a reader dereferences only when the gist falls short. Same within a doc: reference what the title, issue, diff, or CI already holds instead of restating it.

4. **Naive stack, built around agents.** A yolo'd agent clears tests and review (goobreview, greptile, coderabbit); you take QA and merge.

## Install

```bash
git clone https://github.com/{{OWNER}}/{{REPO}}.git
cd {{REPO}}
# {{the shortest path from zero to running — one copyable block}}
```

## How it's laid out

```
{{REPO}}/
├── .github/
│   ├── workflows/                # test.yml (CI) + deploy.yml (deploy ladder)
│   ├── ISSUE_TEMPLATE/           # problem.md, task.md
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── src/                          # code — rename per your stack
├── tests/                        # or colocate, per your stack
└── docs/                         # docs-as-code, reviewed in PRs → Pages
```

## Roadmap & status

Planned work and current status live in
**[Projects](https://github.com/{{OWNER}}/{{REPO}}/projects)** and
**[Milestones](https://github.com/{{OWNER}}/{{REPO}}/milestones)** — built from
[open issues](https://github.com/{{OWNER}}/{{REPO}}/issues), so the roadmap *is* the
status. (Inline roadmaps rot; these don't.)

## Contributing

Everyone — human or agent — works through **[CONTRIBUTING.md](./CONTRIBUTING.md)**.
Agents should also read **[AGENTS.md](./AGENTS.md)** first — the stack, constraints,
and execution norms an agent can't infer from the code.

## License

MIT — see [LICENSE](./LICENSE).
