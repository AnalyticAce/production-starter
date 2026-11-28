# Deploy

| Path | Purpose |
|------|---------|
| `docker/Dockerfile` | Production image. Non-root, healthcheck, built from repo root. |
| `docker/Dockerfile.dockerignore` | Build context excludes (BuildKit picks it up automatically). |
| `config/app.yaml` | Non-secret config, mounted read-only at `/app/config/app.yaml`. |

## Build & run

```sh
docker build -f deploy/docker/Dockerfile -t app .
docker run --rm -p 8080:8080 --env-file .env app
# or
just up
```

## Pipeline

`.github/workflows/deploy.yml` builds the image **once** and promotes it:

| Trigger | What happens | Environment |
|---------|--------------|-------------|
| Merge to `main` | Build, push `ghcr.io/<owner>/<repo>:sha-<commit>`, deploy | `staging` |
| GitHub Release `vX.Y.Z` published (release-please) | Retag that commit's image as `vX.Y.Z`, wait for your approval, deploy | `production` |

Production runs the exact bytes staging ran; nothing is rebuilt. Both deploy steps are placeholders: replace the `echo` with your platform's command, and put per-environment secrets in **Settings → Environments**. To roll back, re-run the production job of an older release.

## Config precedence

1. Environment variables (secrets, per-environment overrides)
2. `config/app.yaml` (defaults checked into git)

Never bake secrets into the image. Inject them at runtime from your platform's secret store.
