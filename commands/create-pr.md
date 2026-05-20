---
description: Create a GitHub PR with a description filled from the repo's PR template
argument-hint: [base-branch]
allowed-tools: Read, Bash(gh:*), Bash(git:*), Bash(ls:*), Bash(find:*), Bash(test:*), Bash(jq:*), Glob, Grep
model: claude-opus-4-6
---

# Create PR

Generate a PR body from the repo's PR template + branch diff, then `gh pr create`.

`$ARGUMENTS` = optional explicit base branch. If omitted, the base is auto-detected:
- If the current branch is stacked on top of an open PR (an ancestor commit matches that PR's head), the new PR targets that PR's head branch.
- Otherwise, the repo's default branch.

---

## 1. Resolve base branch

```bash
~/.claude/commands/create-pr/detect-base.sh "$ARGUMENTS"
```

Stdout is a single `key=value` line:

```
base=<branch> source=explicit|stacked|default parent_pr=<num-or-empty>
```

Parse into `$BASE`, `$BASE_SOURCE`, `$PARENT_PR`. Show the user the chosen base and why:

- `source=stacked` → "Stacking on PR #<num> (`<branch>`)"
- `source=default` → "Targeting default branch (`<branch>`)"
- `source=explicit` → "Targeting `<branch>` (you passed it)"

stderr from the script may contain useful diagnostics (how many commits back the parent was found); pass it through to the user.

## 2. Gather context (parallel)

```bash
git rev-parse --abbrev-ref HEAD
git status --short
git log "$BASE"..HEAD --pretty=format:'%h %s%n%b%n---'
git diff "$BASE"...HEAD
git diff --stat "$BASE"...HEAD
gh pr view --json url 2>/dev/null  # detect existing PR
find .github docs . -maxdepth 2 -type f \( -iname 'pull_request_template.md' -o -iname 'PULL_REQUEST_TEMPLATE.md' \) 2>/dev/null
ls .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
ls README.md README.rst CONTRIBUTING.md AGENTS.md CLAUDE.md docs/ 2>/dev/null
ls Gemfile package.json pyproject.toml Cargo.toml go.mod justfile Makefile 2>/dev/null
```

**Stop if:** on base branch, 0 commits ahead, or PR already exists (print URL, ask whether to update body instead).

If diff > 2000 lines, use `git diff --name-status` and read individual files only when intent is unclear.

**Read the discovered docs and manifests** — they ground the smoke-tests section (step 3) in the project's actual stack and conventions. Skim only; don't deep-read. Look for: dev-server command, test command, console/REPL command, stack identifiers (Rails, Next.js, FastAPI, iOS, etc.).

---

## 3. Fill the template

Template precedence: `.github/pull_request_template.md` → `.github/PULL_REQUEST_TEMPLATE.md` → root → `docs/` → `.github/PULL_REQUEST_TEMPLATE/*.md` (ask user if multiple). No template → use `## Summary\n\n## Changes\n\n## Test plan`.

Rules:
- Preserve heading hierarchy, ordering, and HTML comments verbatim.
- Checkboxes: `[x]` only when verifiable from the diff.
- Unfillable sections: leave blank or don't check the box. Don't delete the section.
- Issue refs: only if present in commits, branch name, or conversation context.

### Writing style — match the author's voice

**The PR author writes casual, terse descriptions. Match this tone exactly.**

Study these real examples from the author's PRs:

```
save distribution times
```
```
cleanup session models
as well as some single session report code
```
```
fetch data for the metric tiles
```
```
add remaining filters to api, to be used in https://github.com/PlayerData/web/pull/3640
```
```
add `filters` to flexible report charts. just added the `athlete_name` filter for now, but adding the others should be straightforward once this is in
```

**Key characteristics:**
- Lowercase, no formal sentence structure — fragments are fine
- Often just a phrase describing what changed: "save distribution times", "cleanup session models"
- Mention the *next PR* or *companion PR* when relevant, casually inline
- Only explain the *why* when it's non-obvious from the diff
- Never list files, functions, or implementation details — the diff shows that
- No marketing tone, no "This PR introduces...", no emoji, no decorative formatting
- `ref` / `resolves` / `requires` links to issues — lowercase, at the start, no ceremony
- Collapsible `<details>` blocks for diagrams or screenshots when useful, but only when they add real context

### Linking a GitHub issue from conversation context

If the conversation references a specific GitHub issue, link it as the first line of the Overview section.

Use `resolves` (lowercase) when the PR fully addresses the issue, `ref` when partial. When uncertain, prefer `ref`. Use the full URL. Don't invent issue links.

```markdown
### Overview

resolves https://github.com/owner/repo/issues/123

save distribution times
```

**Overview: 1-2 short sentences or fragments. That's it.** Do NOT add:
- Implementation bullets
- "Out of scope" / "follow-up" disclaimers
- "Stacked on #N" lines
- Anything the title or diff already conveys

**Other sections:** keep them equally terse. One line per bullet, ≤4 bullets. Cut anything the diff already shows.

**Title** (under 70 chars, no trailing period): match the repo's commit style — check `git log --oneline -20` on BASE for Conventional Commits / case / mood.

### Smoke Tests section

If the repo's template already has a Smoke Tests section, fill it in place. Otherwise append one at the end. This section is for the PR author to tick off as they manually verify.

**Match the author's casual style.** Study these real smoke test entries:

```
- [x] distributions created via admin have times persisted
- [x] distributions created via web app have times persisted
```
```
- [x] works with https://github.com/PlayerData/web/pull/3640
```
```
- [x] can create flexible report & distribution via graphiql
- [x] can update flexible report & distribution via graphiql
- [x] errors get returned via graphiql
```
```
- [x] CI
```
```
- [x] unit tests
```
```
- [x] red -> green unit test reproducing the bug
```
```
- [x] averages & person bests get pulled through to the report correctly
```

**Key characteristics:**
- Lowercase fragments, casual tone — not formal past-tense sentences
- "CI" and "unit tests" are perfectly valid items for small/internal changes
- Links to companion PRs or CI runs are fine
- Screenshots inline when they help (just paste the GitHub image link)
- 1-4 items typically. One is fine for small changes.
- Leave checkboxes **unchecked** (`- [ ]`) — the author ticks them after verifying
- When the change has no runnable behavior (docs, cleanup, internal renames): `- [ ] CI` is fine

---

## 4. Push and create

```bash
git push -u origin HEAD  # if no upstream
gh pr create --draft --base "$BASE" --head "$HEAD" --title "<title>" --body "$(cat <<'EOF'
<filled template>
EOF
)"
```

Always pass `--draft`. The user marks ready for review themselves.

After creating, print:
- The new PR URL
- If `$BASE_SOURCE == stacked`: "Stacked on #$PARENT_PR — merging this depends on #$PARENT_PR landing first."

---

## Don't

- Pause for confirmation.
- Fabricate test results, screenshots, or issue links.
- Add `Co-Authored-By` trailers to commits. No co-author lines, ever.
- `--no-verify`, `--force`, or rebase.
