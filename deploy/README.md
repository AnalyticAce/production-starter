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

## Config precedence

1. Environment variables (secrets, per-environment overrides)
2. `config/app.yaml` (defaults checked into git)

Never bake secrets into the image. Inject them at runtime from your platform's secret store.
