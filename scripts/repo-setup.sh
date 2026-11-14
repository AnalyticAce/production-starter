#!/usr/bin/env bash
# Apply the GitHub settings that "Use this template" does not copy. Safe to re-run.
# Needs: gh CLI logged in with admin rights on the repo.
# Usage: scripts/repo-setup.sh [owner/repo]     (default: current repo)
set -euo pipefail

repo=${1:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}
ruleset_name="default-branch-protection"

echo "Configuring $repo"

# Squash-only merges, PR title becomes the commit message, clean up branches.
gh api -X PATCH "repos/$repo" --silent \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F allow_auto_merge=true \
  -F delete_branch_on_merge=true \
  -f squash_merge_commit_title=PR_TITLE \
  -f squash_merge_commit_message=PR_BODY
echo "✓ merge settings"

# Read-only GITHUB_TOKEN by default; let Actions open PRs (release-please needs this).
gh api -X PUT "repos/$repo/actions/permissions/workflow" --silent \
  -f default_workflow_permissions=read \
  -F can_approve_pull_request_reviews=true
echo "✓ actions token permissions"

# Changes reach the default branch only through a PR (no review requirements; the API needs every field set).
# Required checks are job names from the workflows in .github/workflows.
ruleset=$(cat <<JSON
{
  "name": "$ruleset_name",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "required_linear_history" },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 0,
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [
          { "context": "lint" },
          { "context": "docker" },
          { "context": "secrets" },
          { "context": "vulnerabilities" },
          { "context": "pr-title" }
        ]
      }
    }
  ]
}
JSON
)

id=$(gh api "repos/$repo/rulesets" -q ".[] | select(.name == \"$ruleset_name\") | .id")
if [[ -n $id ]]; then
  gh api -X PUT "repos/$repo/rulesets/$id" --silent --input - <<<"$ruleset"
  echo "✓ ruleset updated"
else
  gh api -X POST "repos/$repo/rulesets" --silent --input - <<<"$ruleset"
  echo "✓ ruleset created"
fi
