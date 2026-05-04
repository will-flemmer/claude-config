#!/usr/bin/env bash
# Set up (or reuse) a git worktree for reviewing a PR in isolation.
# Usage:  setup-worktree.sh <pr-url-or-number>
# Output: a single line of `key=value` pairs, space-separated, designed to be
#         consumed by Claude. Keys: main_repo_root, worktree_dir, head_sha,
#         pr_number, branch.
# Exits non-zero with a human-readable error on stderr if setup fails.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: setup-worktree.sh <pr-url-or-number>" >&2
  exit 2
fi

pr_arg="$1"

# Run from inside the target repo
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "error: not inside a git repository" >&2
  exit 1
fi

# Main repo root (parent of the shared .git, even if cwd is itself a worktree)
main_repo_root=$(cd "$(git rev-parse --git-common-dir)/.." && pwd)

# PR identifiers via gh
pr_number=$(gh pr view "$pr_arg" --json number --jq '.number') || {
  echo "error: gh pr view failed for '$pr_arg'" >&2
  exit 1
}
owner_repo=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' | tr '/' '-')

branch="pr-${pr_number}-review"
worktree_dir="$HOME/.claude/review-worktrees/${owner_repo}-pr-${pr_number}"
mkdir -p "$HOME/.claude/review-worktrees"

# Fetch the PR head into a local branch (idempotent — --force overwrites stale ref)
git fetch origin "pull/${pr_number}/head:${branch}" --force >&2

# Detect conflicts
existing=$(git worktree list --porcelain | awk -v b="refs/heads/${branch}" '
  $1=="worktree" {wt=$2}
  $1=="branch" && $2==b {print wt; exit}
')

if [[ -n "$existing" ]]; then
  if [[ "$existing" == "$worktree_dir" ]]; then
    # Reuse: bring it up to latest PR head
    echo "worktree exists at $worktree_dir — reusing" >&2
    git -C "$worktree_dir" checkout "$branch" >&2
    git -C "$worktree_dir" reset --hard FETCH_HEAD >&2
  elif [[ "$existing" == "$main_repo_root" ]]; then
    echo "error: PR branch '${branch}' is checked out in your main working tree at ${main_repo_root}." >&2
    echo "       switch your main checkout to a different branch, or review there directly." >&2
    exit 1
  else
    echo "error: PR branch '${branch}' is checked out at another worktree: ${existing}" >&2
    echo "       remove it first:  git worktree remove ${existing}" >&2
    exit 1
  fi
else
  # Create fresh worktree
  git worktree add "$worktree_dir" "$branch" >&2
fi

head_sha=$(git -C "$worktree_dir" rev-parse HEAD)

# Single-line machine-readable output on stdout
echo "main_repo_root=${main_repo_root} worktree_dir=${worktree_dir} pr_number=${pr_number} branch=${branch} head_sha=${head_sha}"
