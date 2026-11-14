#!/usr/bin/env bash
# Run every check CI runs on lint. Usage: scripts/check.sh
set -euo pipefail
cd "$(dirname "$0")/.."

pre-commit run --all-files --show-diff-on-failure
