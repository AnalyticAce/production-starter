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
4. Open a PR and add `?template=pull_request_template.md` to the compare URL to load the template (see `.github/PULL_REQUEST_TEMPLATE/`). CI, security scans and the AI review run automatically.
5. Squash-merge once approved and green.

## Rules

- No secrets in git. Gitleaks runs on commit and in CI.
- Config goes in `deploy/config/app.yaml`; secrets in env vars, documented in `.env.example`.
- Keep `docs/architecture.md` current when you change the shape of the system.
