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
| `.github/workflows/deploy.yml` | Build once, promote: merge to `main` → image pushed to GHCR and deployed to **staging**; GitHub Release → same image retagged and deployed to **production** after your approval. Deploy commands are placeholders |
| `.github/workflows/release.yml` | [release-please](https://github.com/googleapis/release-please): release PR → version tag, `CHANGELOG.md`, GitHub Release |
| `renovate.json` | [Renovate](https://docs.renovatebot.com/): lists every update on the **Dependency Dashboard** issue; a PR opens only when you tick its box |
| `.github/pull_request_template.md` | Default PR template; extra ones go in `.github/PULL_REQUEST_TEMPLATE/` (`?template=<name>.md`) |
| `.githooks/` | Thin shims into pre-commit: `pre-commit` runs the file checks, `commit-msg` validates messages with [conventional-pre-commit](https://github.com/compilerla/conventional-pre-commit) |
| `deploy/` | Dockerfile, build excludes, runtime config — see [deploy/README.md](deploy/README.md) |
| `docs/` | [Architecture](docs/architecture.md) and [contributing](docs/contributing.md) |
| `scripts/` | `setup.sh`, `check.sh`, and `repo-setup.sh` (GitHub settings, branch protection, deploy environments) |

## Using this template

1. Click **Use this template** on GitHub (enable it under *Settings → Template repository*).
2. Add the `OPENAI_API_KEY` repository secret to enable AI review. Tune PR-Agent in `.pr_agent.toml` ([options](https://github.com/The-PR-Agent/pr-agent/blob/main/pr_agent/settings/configuration.toml)).
3. Run `just repo-setup` (needs `gh` with admin rights): squash-only merges and a ruleset on the default branch that blocks direct pushes (changes land only via PR) and requires the `lint`, `docker`, `secrets`, `vulnerabilities` and `pr-title` checks to pass. It also creates the `staging` (default branch only) and `production` (`v*` tags only, your approval required) environments.
4. Add a `RELEASE_PLEASE_TOKEN` secret (fine-grained PAT with Contents, Issues and Pull requests write access). Without it, release PRs don't trigger CI and can't pass the required checks, and releases don't trigger the production deploy.
5. Install the [Renovate app](https://github.com/apps/renovate) on the repo (Renovate Only, Scan and Alert).
6. Update `LICENSE`, this README and `deploy/config/app.yaml`.

## Rules and decisions

`just repo-setup` applies these settings. Each one is a choice tuned for a **solo or small team**; the table says why, and how to change it. All of them live in [`scripts/repo-setup.sh`](scripts/repo-setup.sh) and are safe to re-apply after editing.

### How code reaches `main` (ruleset `default-branch-protection`)

| Rule | What it does | Why | Change it |
|------|--------------|-----|-----------|
| Require a pull request | `git push origin main` is rejected; every change goes through a PR | One reviewable, CI-checked unit per change | Core of the template; keep it |
| 0 required approvals | You can merge your own PR | Solo-first: approvals would block you | Team: set `required_approving_review_count` to 1+, and consider `dismiss_stale_reviews_on_push`, `require_code_owner_review` (with `.github/CODEOWNERS`), `required_review_thread_resolution` |
| Required checks: `lint`, `docker`, `secrets`, `vulnerabilities`, `pr-title` | Merge stays disabled until these pass | Broken or unsafe code can't land | Add your test job's name to `required_status_checks`. `pr-agent` is deliberately not required, so an AI outage never blocks a merge |
| Block force pushes and deletion | History on `main` can't be rewritten; `main` can't be deleted | Merged commits stay put | Keep |
| Linear history | No merge commits on `main` | Clean `git log`, easy `revert` and `bisect` | Remove `required_linear_history` and allow merge commits if you need them |

### How PRs merge (repo settings)

| Setting | Why | Change it |
|---------|-----|-----------|
| Squash merge only, PR title becomes the commit | One commit per PR; release-please reads the Conventional Commit titles to pick the next version and write `CHANGELOG.md` | Allowing other merge types breaks that link |
| Delete branch on merge | No stale branches piling up | Set `delete_branch_on_merge=false` |
| Auto-merge allowed | "Merge when checks pass" and walk away | Set `allow_auto_merge=false` |
| `GITHUB_TOKEN` read-only by default | Each workflow requests only the write access it needs (`permissions:`), so a compromised step can't push code | Keep |

### Where code runs (environments)

An **environment** (*Settings → Environments*) is a named deploy target that a workflow job joins with `environment: <name>`. It gives that job its own secrets and variables (production credentials are invisible to other jobs), gates the job with protection rules before any step runs, and records a deployment you can see and re-run (rollback).

| Environment | Who may deploy | Approval | Flow |
|-------------|----------------|----------|------|
| `staging` | Runs from `main` only | None | Every merge to `main` builds the image and deploys it |
| `production` | Runs from `v*` tags only | Required, from the repo owner | A published release retags the **same** image built on `main` (nothing is rebuilt) and waits for you to click *Review deployments → Approve* |

```
PR ── checks green ── squash merge ──► main ──► build image ──► staging
                                        └─► release-please PR ── merge ──► tag vX.Y.Z ──► ⏸ approve ──► production
```

Decisions behind this, and how to change them:

- **Self-approval allowed** (`prevent_self_review: false`): solo-first; otherwise you'd lock yourself out. Team: set it to `true` and add reviewers.
- **No UAT/dev environment**: two stages are enough to start. Add one by creating the environment in `repo-setup.sh` and a job in `deploy.yml` with `environment: uat`.
- **Production deploys only from releases**, never from a branch: a deploy always has a version, a changelog and an image already proven on staging.
- **Deploy steps are placeholders** (`echo`): replace them with your platform's command and put its credentials in each environment's secrets.

### Dependency updates

Renovate is set to **approval-only**: updates are listed on the *Dependency Dashboard* issue, and a PR opens only when you tick its box. It avoids PR noise while keeping every update visible. For automatic PRs, remove `dependencyDashboardApproval` from `renovate.json`; to wait before adopting fresh releases, add `"minimumReleaseAge": "7 days"`.

## Supply chain

Actions are pinned to full commit SHAs and the images workflows run to digests (version kept alongside); Renovate keeps both current, including the `docker run` image refs in workflows. `actionlint` and `zizmor` lint every workflow in pre-commit and CI.

## License

[MIT](LICENSE)
