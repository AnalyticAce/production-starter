set dotenv-load := true

default:
    @just --list

# One-time local setup (hooks, .env)
setup:
    scripts/setup.sh

# Lint, format and secret-scan everything
check:
    scripts/check.sh

# Build the production image
build:
    docker build -f deploy/docker/Dockerfile -t production-starter .

# Start the stack in the background
up:
    docker compose up --build -d

# Stop the stack
down:
    docker compose down

# Tail logs
logs:
    docker compose logs -f
