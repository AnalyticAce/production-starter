#!/usr/bin/env bash
# One-time local setup.
set -euo pipefail
cd "$(dirname "$0")/.."

missing=()
for tool in git docker pre-commit just; do
  command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done
if ((${#missing[@]})); then
  echo "Missing tools: ${missing[*]}" >&2
  echo "Install guides: https://pre-commit.com  https://just.systems  https://docs.docker.com/get-docker/" >&2
  exit 1
fi

git config core.hooksPath .githooks
echo "✓ git hooks -> .githooks"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "✓ created .env from .env.example"
fi

pre-commit install-hooks
echo "✓ pre-commit hooks installed"
