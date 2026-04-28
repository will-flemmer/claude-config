---
description: Create a GitHub PR with a description filled from the repo's PR template
argument-hint: [base-branch]
allowed-tools: Read, Bash(gh:*), Bash(git:*), Bash(ls:*), Bash(find:*), Bash(test:*), Glob, Grep
model: claude-opus-4-7
---

# Create PR

Generate a PR body from the repo's PR template + branch diff, then `gh pr create`.

`$ARGUMENTS` = base branch (default: repo default).

---

## 1. Gather context (parallel)

```bash
git rev-parse --abbrev-ref HEAD
gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo main
git status --short
git log "$BASE"..HEAD --pretty=format:'%h %s%n%b%n---'
git diff "$BASE"...HEAD
git diff --stat "$BASE"...HEAD
gh pr view --json url 2>/dev/null  # detect existing PR
find .github docs . -maxdepth 2 -type f \( -iname 'pull_request_template.md' -o -iname 'PULL_REQUEST_TEMPLATE.md' \) 2>/dev/null
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
```

**Stop if:** on base branch, 0 commits ahead, or PR already exists (print URL, ask whether to update body instead).

If diff > 2000 lines, use `git diff --name-status` and read individual files only when intent is unclear.

---

## 2. Fill the template

Template precedence: `.github/pull_request_template.md` → `.github/PULL_REQUEST_TEMPLATE.md` → root → `docs/` → `.github/PULL_REQUEST_TEMPLATE/*.md` (ask user if multiple). No template → use `## Summary\n\n## Changes\n\n## Test plan`.

Rules:
- Preserve heading hierarchy, ordering, and HTML comments verbatim.
- Be specific — file paths, function names, behavior changes. Not "updated some files."
- Checkboxes: `[x]` only when verifiable from the diff.
- Unfillable sections: `N/A — <one-line reason>`. Don't delete the section.
- Issue refs (`#123`, `Fixes #...`, `JIRA-456`): include only if present in commits or branch name.

**Tone and length — keep it tight.** PR descriptions are read by reviewers in 30 seconds. Default each filled section to bullets, not paragraphs.

- Bullets over prose. One line per point.
- ≤4 bullets per section. If you have more, the change is too big for one PR or the bullets are too granular.
- No restating what the diff already shows ("Modified `foo.ts` to add a function called `bar`" — the diff says that).
- No marketing tone ("This PR introduces a powerful new...", "We've enhanced..."). Just state what changed and why.
- No emojis, no horizontal rules, no decorative headers added beyond the template.
- Code blocks only when a name/signature/command is essential. ≤6 lines.
- Test plan: concrete commands or steps a reviewer can run, not "tested locally."

**Title** (under 70 chars, no trailing period): match the repo's commit style — check `git log --oneline -20` on BASE for Conventional Commits / case / mood.

---

## 3. Push and create

```bash
git push -u origin HEAD  # if no upstream
gh pr create --base "$BASE" --head "$HEAD" --title "<title>" --body "$(cat <<'EOF'
<filled template>
EOF
)"
```

Print the PR URL.

---

## Don't

- Pause for confirmation.
- Fabricate test results, screenshots, or issue links.
- Add `Co-Authored-By` unless the template asks for it.
- `--no-verify`, `--force`, or rebase.
