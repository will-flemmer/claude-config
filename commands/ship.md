---
description: Create a branch, commit changes (conventional commits), and open a draft PR
argument-hint: [natural language flags, e.g. "without creating a branch" or "skip pr"]
allowed-tools: Read, Bash(gh:*), Bash(git:*), Bash(ls:*), Bash(find:*), Bash(test:*), Bash(jq:*), Glob, Grep, Skill
model: claude-opus-4-7
---

# Ship

End-to-end shipping pipeline: branch → commit → PR.

`$ARGUMENTS` is interpreted as natural language. Two toggles, both default **true**:

- **create-branch** — set to false when the user says things like "without a branch", "skip branch", "no branch", "stay on this branch", "don't create a branch"
- **create-pr** — set to false when the user says "skip pr", "no pr", "without a pr", "just commit", "don't open a pr"

If `$ARGUMENTS` is empty, both default to true.

---

## 1. Pre-flight (parallel)

Run in parallel:

```bash
git rev-parse --abbrev-ref HEAD
git status --short
git diff
git diff --cached
git log --oneline -10
git rev-parse --verify origin/HEAD 2>/dev/null || gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
```

From this, derive:

- `CURRENT_BRANCH` — current branch name
- `DEFAULT_BRANCH` — repo default (main/master)
- `ON_DEFAULT` — true if `CURRENT_BRANCH` is the default
- `HAS_UNCOMMITTED` — true if `git status --short` is non-empty
- `HAS_UNPUSHED` — true if `git log @{u}..HEAD` has commits (run if upstream exists)

### Stop conditions (error and exit)

| Condition | Message |
|---|---|
| `HAS_UNCOMMITTED == false` AND `HAS_UNPUSHED == false` | "Nothing to ship — clean tree, no unpushed commits." |
| `create-branch == false` AND `ON_DEFAULT == true` AND `HAS_UNCOMMITTED == true` | "Refusing to commit on `$DEFAULT_BRANCH`. Re-run without `skip branch` or check out a feature branch first." |

Print stop messages and exit. Do not proceed.

---

## 2. Detect commit type and message

Read the diff to classify and summarize. **Always** `fix:` or `feat:` — no other prefixes.

**Heuristics for `feat:` vs `fix:`:**

- **`feat:`** — new files added, new public exports/functions/classes, new commands, new UI elements, new endpoints, new config options, new dependencies for new functionality
- **`fix:`** — bug fixes, corrections to existing behavior, edge-case handling, typos, broken behavior repaired, regressions reverted, off-by-one errors, null/undefined guards added to existing code

If the diff is genuinely mixed (a new feature plus an unrelated bug fix), prefer `feat:` and mention the fix in the body of the commit (or split commits — but default to one commit unless the user has staged things deliberately).

**Subject line rules:**

- Format: `<type>: <description>`
- ≤60 chars total (matches the `commit-and-push` convention used in this repo)
- Imperative mood, lowercase after the prefix, no trailing period
- Be specific about *what* changed, not *that* something changed
- Examples:
  - ✅ `feat: add /ship command for branch+commit+pr`
  - ✅ `fix: handle empty diff in detect-base.sh`
  - ❌ `feat: updates` (vague)
  - ❌ `fix: Fixed the bug.` (capitalized, trailing period, vague)

**Show the user the proposed commit message before committing.** One line, no ceremony:

```
Commit: feat: add /ship command for branch+commit+pr
```

If they don't push back, proceed. If they correct it, use their version (still validate the `fix:`/`feat:` prefix and 60-char limit).

---

## 3. Create branch (if `create-branch == true`)

Skip this step if:
- `create-branch == false`, OR
- `ON_DEFAULT == false` (already on a feature branch — reuse it)

Otherwise, generate a branch name from the commit subject:

- Format: `<type>/<kebab-slug>`
- Slug = subject after the colon, lowercased, non-alphanumerics → `-`, trimmed, max 50 chars
- Example: `feat: add /ship command for branch+commit+pr` → `feat/add-ship-command-for-branch-commit-pr`

```bash
git checkout -b "$BRANCH_NAME"
```

Print: `Branch: <name>`

---

## 4. Commit

```bash
git add -A
git commit -m "$COMMIT_MESSAGE"
```

Do NOT use `--no-verify`. If the pre-commit hook fails, fix the issue and re-stage; do not amend.

Print: `Committed: <subject> (<short-sha>)`

---

## 5. Create PR (if `create-pr == true`)

Skip if `create-pr == false`. Otherwise invoke the `create-pr` skill:

```
Skill({ skill: "create-pr" })
```

The `create-pr` skill handles base detection, push, template filling, and `gh pr create --draft`.

When `create-pr == false`, still push the branch so the work isn't local-only:

```bash
git push -u origin HEAD
```

Print: `Pushed to origin/<branch>` (and skip the PR step).

---

## Output

End with a one-line summary:

- Both steps ran: `Shipped: <branch> → <pr-url>`
- PR skipped: `Pushed: origin/<branch> (no PR created)`
- Branch skipped: `Shipped on <existing-branch>: <pr-url>`

---

## Don't

- Use `--no-verify`, `--force`, or rebase.
- Amend a previous commit (always create a new one).
- Commit on the default branch unless `create-branch == false` was explicitly set AND there's a clear reason (in which case, the stop condition above already blocked us — so really, just don't).
- Use a commit prefix other than `fix:` or `feat:`. No `chore:`, `docs:`, `refactor:`, etc. — collapse those into `fix:` or `feat:` based on whether they fix existing behavior or add new behavior.
- Pause for confirmation between steps once the user has approved the commit message. The pipeline runs straight through.
- Fabricate test results or check statuses.
