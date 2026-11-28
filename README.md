# production-starter

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/AnalyticAce/production-starter/badge)](https://scorecard.dev/viewer/?uri=github.com/AnalyticAce/production-starter)

A language-agnostic template for production-ready apps: CI, security scanning, AI PR review, git hooks, and a hardened Docker setup.

## Prerequisites

| Tool | Used for | Install |
|------|----------|---------|
| git | version control | <https://git-scm.com/downloads> |
| Docker | building and running the app | <https://docs.docker.com/get-docker/> |
| [just](https://just.systems) | task runner (`just --list`) | <https://just.systems/man/en/packages.html> |
| [uv](https://docs.astral.sh/uv/) | installs dev tools (pre-commit) | <https://docs.astral.sh/uv/getting-started/installation/> |

**About uv:** some dev tools, like pre-commit, are distributed as Python packages. uv installs each one as an isolated command-line tool with its own interpreter, so you never manage Python yourself. This is a tooling choice only: your app can be written in any language. `scripts/setup.sh` installs pre-commit with uv for you; CI does the same with `uvx`.

## Quick start

```sh
scripts/setup.sh   # installs pre-commit via uv, enables git hooks, creates .env
just up            # build and run on http://localhost:8080
just check         # lint, format, secret-scan
```

Then make it yours: replace the placeholder `build` and `runtime` stages in `deploy/docker/Dockerfile`, add your language's hooks to `.pre-commit-config.yaml`, a test job to `ci.yml`, and Renovate picks up your package manager automatically.

## What's inside

| Path | What it does |
|------|--------------|
| `.github/workflows/ci.yml` | pre-commit checks, hadolint, Docker build, Trivy scan of the built image |
| `.github/workflows/security.yml` | Gitleaks (full history) + Trivy scan, on PR and weekly |
| `.github/workflows/pr-agent.yml` | [PR-Agent](https://github.com/The-PR-Agent/pr-agent) review on each PR, plus `/review`, `/describe`, `/improve`, `/ask` comments (needs `OPENAI_API_KEY` secret) |
| `.github/workflows/scorecard.yml` | OpenSSF Scorecard: weekly security-practices score, shown as the README badge |
| `.github/workflows/pr-title.yml` | Fails PRs whose title isn't a Conventional Commit (it becomes the squash commit) |
| `.github/workflows/release.yml` | [release-please](https://github.com/googleapis/release-please): release PR → version tag, `CHANGELOG.md`, GitHub Release |
| `renovate.json` | [Renovate](https://docs.renovatebot.com/): lists every update on the **Dependency Dashboard** issue; a PR opens only when you tick its box |
| `.github/pull_request_template.md` | Default PR template; extra ones go in `.github/PULL_REQUEST_TEMPLATE/` (`?template=<name>.md`) |
| `.githooks/` | Thin shims into pre-commit: `pre-commit` runs the file checks, `commit-msg` validates messages with [conventional-pre-commit](https://github.com/compilerla/conventional-pre-commit) |
| `deploy/` | Dockerfile, build excludes, runtime config — see [deploy/README.md](deploy/README.md) |
| `docs/` | [Architecture](docs/architecture.md) and [contributing](docs/contributing.md) |
| `scripts/` | `setup.sh`, `check.sh`, and `repo-setup.sh` (GitHub settings + branch protection) |

## Using this template

1. Click **Use this template** on GitHub (enable it under *Settings → Template repository*).
2. Add the `OPENAI_API_KEY` repository secret to enable AI review. Tune PR-Agent in `.pr_agent.toml` ([options](https://github.com/The-PR-Agent/pr-agent/blob/main/pr_agent/settings/configuration.toml)).
3. Run `just repo-setup` (needs `gh` with admin rights): squash-only merges and a ruleset on the default branch that blocks direct pushes (changes land only via PR) and requires the `lint`, `docker`, `secrets`, `vulnerabilities` and `pr-title` checks to pass.
4. Add a `RELEASE_PLEASE_TOKEN` secret (fine-grained PAT with Contents, Issues and Pull requests write access). Without it, release PRs don't trigger CI and can't pass the required checks.
5. Install the [Renovate app](https://github.com/apps/renovate) on the repo (Renovate Only, Scan and Alert).
6. Update `LICENSE`, this README and `deploy/config/app.yaml`.

## Supply chain

Actions are pinned to full commit SHAs and Docker images to digests (version kept alongside); Renovate keeps both current, including the `docker run` image refs in workflows. `actionlint` and `zizmor` lint every workflow in pre-commit and CI.

## License

[MIT](LICENSE)
