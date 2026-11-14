#!/usr/bin/env bash
# One-time local setup. Safe to re-run.
#
# Dev tools that ship as Python packages (pre-commit) are installed with uv as isolated CLI tools.
# That's a tooling choice only: your project can be any language and never touches Python.
set -euo pipefail
cd "$(dirname "$0")/.."

missing=()
for tool in git docker just uv; do
  command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done
if ((${#missing[@]})); then
  echo "Missing tools: ${missing[*]}" >&2
  echo "Install guides:" >&2
  echo "  uv      https://docs.astral.sh/uv/getting-started/installation/" >&2
  echo "  just    https://just.systems/man/en/packages.html" >&2
  echo "  docker  https://docs.docker.com/get-docker/" >&2
  exit 1
fi

if ! command -v pre-commit >/dev/null 2>&1; then
  uv tool install pre-commit
  echo "✓ pre-commit installed with uv ($(uv tool dir --bin))"
fi
if ! command -v pre-commit >/dev/null 2>&1; then
  echo "pre-commit is installed but not on PATH. Run 'uv tool update-shell' and open a new shell." >&2
  exit 1
fi

git config core.hooksPath .githooks
echo "✓ git hooks -> .githooks"

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "✓ created .env from .env.example"
fi

pre-commit install-hooks
echo "✓ pre-commit hook environments ready"
