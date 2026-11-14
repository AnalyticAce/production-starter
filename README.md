# production-starter

A language-agnostic template for production-ready apps: CI, security scanning, AI PR review, git hooks, and a hardened Docker setup.

## Quick start

```sh
scripts/setup.sh   # hooks + .env (needs git, docker, pre-commit, just)
just up            # build and run on http://localhost:8080
just check         # lint, format, secret-scan
```

Then make it yours: replace the placeholder `build` and `runtime` stages in `deploy/docker/Dockerfile`, add your language's hooks to `.pre-commit-config.yaml`, a test job to `ci.yml`, and your package ecosystem to `dependabot.yml`.

## What's inside

| Path | What it does |
|------|--------------|
| `.github/workflows/ci.yml` | pre-commit checks, hadolint, Docker build |
| `.github/workflows/security.yml` | Gitleaks (full history) + Trivy scan, on PR and weekly |
| `.github/workflows/pr-agent.yml` | [PR-Agent](https://github.com/The-PR-Agent/pr-agent) review on each PR, plus `/review`, `/describe`, `/improve`, `/ask` comments (needs `OPENAI_KEY` secret) |
| `.github/PULL_REQUEST_TEMPLATE/` | PR templates, picked with `?template=<name>.md` on the compare URL |
| `.githooks/` | `pre-commit` runs the hook suite; `commit-msg` enforces Conventional Commits |
| `deploy/` | Dockerfile, build excludes, runtime config — see [deploy/README.md](deploy/README.md) |
| `docs/` | [Architecture](docs/architecture.md) and [contributing](docs/contributing.md) |
| `scripts/` | `setup.sh` and `check.sh` |

## Using this template

1. Click **Use this template** on GitHub (enable it under *Settings → Template repository*).
2. Add the `OPENAI_KEY` repository secret to enable AI review. Tune PR-Agent in `.pr_agent.toml` ([options](https://github.com/The-PR-Agent/pr-agent/blob/main/pr_agent/settings/configuration.toml)).
3. Protect `main`: require the `CI` and `Security` checks to pass.
4. Update `LICENSE`, this README and `deploy/config/app.yaml`.

## License

[MIT](LICENSE)
