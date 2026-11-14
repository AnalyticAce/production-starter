# Contributing

## Setup

```sh
scripts/setup.sh   # or: just setup
```

Prerequisites: git, Docker, [just](https://just.systems) and [uv](https://docs.astral.sh/uv/). The script installs pre-commit with `uv tool install` (uv handles the Python runtime pre-commit needs; your project does not need Python), points git at `.githooks/`, and creates `.env` from `.env.example`.

To add another dev tool distributed as a Python package, install it the same way (`uv tool install <tool>`) or run it ad hoc with `uvx <tool>`.

## Workflow

1. Branch from `main`: `feat/short-name`, `fix/short-name`.
2. Commit using [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): subject`, scope optional (`fix: handle empty input` and `feat(api): add health endpoint` are both valid). The `commit-msg` hook validates it with conventional-pre-commit.
3. Run `just check` before pushing.
4. Open a PR; the template loads automatically. Its **title** must be a Conventional Commit, since it becomes the squash commit. CI, security scans and the AI review run automatically.
5. Squash-merge once approved and green.

## Releases

`release-please` keeps a release PR open on `main` with the next version and changelog, derived from commit types (`fix` → patch, `feat` → minor, `!` → major). Merge it to tag and publish the release.

## Rules

- No secrets in git. Gitleaks runs on commit and in CI.
- Config goes in `deploy/config/app.yaml`; secrets in env vars, documented in `.env.example`.
- Keep `docs/architecture.md` current when you change the shape of the system.
