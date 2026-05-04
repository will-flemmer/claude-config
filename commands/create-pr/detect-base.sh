#!/usr/bin/env bash
# Determine the appropriate base branch for a new PR.
#
# Detects whether the current branch is stacked on top of an existing open PR
# by walking ancestor commits and matching them against open PRs' head SHAs.
#
# Usage:  detect-base.sh [explicit-base]
# Output: a single line of `key=value` pairs on stdout:
#           base=<branch>  source=explicit|stacked|default  parent_pr=<num-or-empty>
#         Diagnostic logs go to stderr.

set -euo pipefail

explicit="${1:-}"

# 1. Explicit override wins
if [[ -n "$explicit" ]]; then
  echo "base=${explicit} source=explicit parent_pr="
  echo "using explicit base: ${explicit}" >&2
  exit 0
fi

default_base=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo main)

# 2. Walk ancestors of HEAD looking for an open-PR head SHA
#    (skip HEAD itself — we want the *parent* of our work, not our own commits)
head_sha=$(git rev-parse HEAD)
current_branch=$(git rev-parse --abbrev-ref HEAD)

# List open PRs (excluding our own current branch if it has one)
prs_json=$(gh pr list --state open --limit 100 --json number,headRefOid,headRefName,baseRefName 2>/dev/null || echo '[]')

if [[ "$prs_json" == "[]" || -z "$prs_json" ]]; then
  echo "base=${default_base} source=default parent_pr="
  echo "no open PRs; using default base: ${default_base}" >&2
  exit 0
fi

# Build a lookup: head_sha -> "number|head_branch"
# Then walk our ancestors and find the closest match.
# `git rev-list --first-parent HEAD` gives us our branch's commits in order from HEAD back.
# Skip HEAD itself (it might be the tip of our own PR if we're updating).

# Bash associative array for quick SHA lookup
declare -A pr_by_sha
declare -A branch_by_pr
while IFS=$'\t' read -r number head_sha_pr head_branch base_branch; do
  # Skip PRs whose head is our current branch (would point at ourselves)
  if [[ "$head_branch" == "$current_branch" ]]; then
    continue
  fi
  pr_by_sha["$head_sha_pr"]="$number"
  branch_by_pr["$number"]="$head_branch"
done < <(echo "$prs_json" | jq -r '.[] | [.number, .headRefOid, .headRefName, .baseRefName] | @tsv')

# Walk ancestors, find closest match.
parent_pr=""
parent_branch=""
distance=0
while read -r ancestor_sha; do
  distance=$((distance + 1))
  # Skip HEAD itself
  if [[ "$ancestor_sha" == "$head_sha" ]]; then
    continue
  fi
  if [[ -n "${pr_by_sha[$ancestor_sha]:-}" ]]; then
    parent_pr="${pr_by_sha[$ancestor_sha]}"
    parent_branch="${branch_by_pr[$parent_pr]}"
    break
  fi
  # Limit lookback — don't scan thousands of commits
  if [[ $distance -gt 50 ]]; then
    break
  fi
done < <(git rev-list --first-parent HEAD 2>/dev/null)

if [[ -n "$parent_pr" ]]; then
  echo "base=${parent_branch} source=stacked parent_pr=${parent_pr}"
  echo "stacked: parent PR #${parent_pr} (branch: ${parent_branch}) found ${distance} commits back" >&2
  exit 0
fi

echo "base=${default_base} source=default parent_pr="
echo "no stacked parent detected; using default base: ${default_base}" >&2
