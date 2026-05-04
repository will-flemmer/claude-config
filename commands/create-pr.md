---
description: Create a GitHub PR with a description filled from the repo's PR template
argument-hint: [base-branch]
allowed-tools: Read, Bash(gh:*), Bash(git:*), Bash(ls:*), Bash(find:*), Bash(test:*), Bash(jq:*), Glob, Grep
model: claude-opus-4-7
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

### Smoke Tests section (always included)

After the rest of the template is filled, **append a `## Smoke Tests` section at the end of the body** (or replace any existing "Smoke Tests" / "Smoke test" section if the template has one). This section is mandatory — even when N/A.

**Framing.** This is a verification log the PR *author* (the user) fills in by ticking checkboxes as they manually verify. It is NOT a script for the reviewer to run. Write each item past tense, as a claim of what was verified — leave the checkbox empty so the user can tick it once they've confirmed.

**Format:**

```markdown
## Smoke Tests

- [ ] <one short past-tense sentence: what was verified>
- [ ] <one short past-tense sentence>
- [ ] <one short past-tense sentence> (optional third)
```

**Rules:**

- **2-3 items max.** This is smoke, not full QA. Cover the golden path + 1 obvious edge case. Don't enumerate every branch.

- **Past tense, one short sentence each.** "Verified that X" / "Confirmed that Y" / "Tapping Z routes to ...". No bold labels, no headers, no multi-clause descriptions. Aim for ≤25 words. Shared preconditions (seed account, env, fixture) go on a single `**Setup:**` line above the list.

- **Empty checkbox each (`- [ ]`).** Always unchecked when generating the PR. The user is the one who has actually run the verification and will check them in the GitHub UI.

- **A smoke test verifies feature behavior end-to-end against a running system.** It is *not* "ran the test suite" — that's CI's job. Forbidden:
  - "Ran `pnpm jest`", "Ran `pytest`", "Ran `cargo test`", `npm test`, `rspec`, etc.
  - "Linter passes", "typecheck passes"
  - "CI is green"
  - Anything that just re-runs existing test files
  
  If the diff only adds unit tests with no runnable behavior change, see the N/A clause below.

- **Verifiable in development, not "post-merge".** Frame items as something the user can do *now* on a dev build / sim / console. Mark "post-deploy" only when the behavior genuinely cannot run locally:
  - External webhook to a public URL (Stripe, GitHub)
  - Cron / scheduled job that only runs in production
  - Feature flag flippable only in a prod admin tool
  - Requires production-scale data or prod-only third-party integration
  
  **Not** acceptable reasons: "needs API + seed data" (dev API + seed is fine), "needs staging" (dev build pointing at staging is fine), "easier post-merge" (laziness).

- **Each item names a concrete observable.** UI state, route, DB record, log line, response shape. Not "verified it works."

- **State preconditions explicitly.** Name the seed script (`bin/rails db:seed`, `pnpm seed:demo`), fixture file, env var, or test account (`coach@playerdata.dev`). "Requires seed data" is not a precondition.

- **Ground in the stack you discovered in step 2** — use the project's actual dev-server command, console, simulator, etc. Rails repos use `bin/rails console` + `curl`. Next.js uses `npm run dev` + browser. Xcode uses the simulator.

- **N/A when truly non-runnable** — only for diffs with no exercisable behavior: docs-only, formatting, type-only refactors, dep bumps without behavior change, internal renames. Write:
  ```markdown
  ## Smoke Tests

  N/A — <one-line reason>. Verified via: <CI-green | rendered docs page | typecheck command>.
  ```
  Adding unit tests does NOT qualify as N/A — if there's new behavior, exercise it end-to-end.

**Examples by stack** (illustrative — adapt to what the diff actually changes):

- **Rails API** — `curl -X POST localhost:3000/api/sessions -H 'Content-Type: application/json' -d '{"email":"x@y.com"}'` → 201 response; in `bin/rails console`: `Session.last.user.email == "x@y.com"`
- **Next.js page** — `npm run dev`, navigate to `http://localhost:3000/checkout`, submit the form with valid card → order row appears in `orders` table (`select * from orders order by id desc limit 1`)
- **iOS feature** — boot simulator, launch app, tap "Sign In," enter test creds → keychain entry appears (`security find-generic-password -a test`), API request fires (visible in proxy / log)
- **Background job** — enqueue with `MyJob.perform_later(args)`, run worker (`bin/jobs run`), assert side effect (`SomeRecord.where(...).exists?`)
- **CLI tool** — `bin/mytool --new-flag value` → expected stdout / file produced / exit code 0

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
- Add `Co-Authored-By` unless the template asks for it.
- `--no-verify`, `--force`, or rebase.
