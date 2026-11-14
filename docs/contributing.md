# Contributing

## Setup

```sh
scripts/setup.sh   # or: just setup
```

This installs git hooks (`.githooks/`) and creates `.env` from `.env.example`.

## Workflow

1. Branch from `main`: `feat/short-name`, `fix/short-name`.
2. Commit using [Conventional Commits](https://www.conventionalcommits.org/) — the `commit-msg` hook enforces it.
3. Run `just check` before pushing.
4. Open a PR; the template loads automatically. Its **title** must be a Conventional Commit, since it becomes the squash commit. CI, security scans and the AI review run automatically.
5. Squash-merge once approved and green.

## Releases

`release-please` keeps a release PR open on `main` with the next version and changelog, derived from commit types (`fix` → patch, `feat` → minor, `!` → major). Merge it to tag and publish the release.

## Rules

- No secrets in git. Gitleaks runs on commit and in CI.
- Config goes in `deploy/config/app.yaml`; secrets in env vars, documented in `.env.example`.
- Keep `docs/architecture.md` current when you change the shape of the system.
