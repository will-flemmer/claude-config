---
description: Run the Smoke Tests section of a PR description against a running local environment and report pass/fail/blocked inline
argument-hint: [pr-number-or-url]
allowed-tools: Read, Write, Edit, Bash(gh:*), Bash(git:*), Bash(curl:*), Bash(lsof:*), Bash(jq:*), Bash(test:*), Bash(ls:*), Bash(find:*), Bash(python:*), Bash(python3:*), Bash(bash:*), Bash(xcrun:*), Bash(rails:*), Bash(bin/rails:*), Bash(bin/rails runner:*), Glob, Grep, mcp__qmd__query, mcp__qmd__get
model: claude-opus-4-7
---

# Smoke Test

Execute the `## Smoke Tests` checklist from a PR description against a running local environment. Report inline markdown with **Pass / Fail / Blocked** verdicts and concrete evidence for each.

This is **automated exploratory testing**, not a committed test suite. Nothing is written to the repo. The command should leave the working tree untouched.

`$ARGUMENTS` = optional PR number or URL. If omitted, resolve the PR for the current branch.

---

## Core principles

- **Goals, not scripts.** Each smoke test is a past-tense claim ("Verified user can submit form"). Treat it as a goal — re-observe state between actions, use role/text locators, don't pre-resolve selectors.
- **Three states only:** ✅ Pass / ❌ Fail / 🚫 Blocked. Never "flaky" or "partial". Blocked = environment problem (server down, sim won't boot). Fail = action ran, assertion failed.
- **Evidence before claims.** A test only passes when you can quote the observable: URL, response body substring, DB row, on-screen text, screenshot path. No "looked fine".
- **Auth once, reuse.** Set up the session once at the start of the run. Pass cookies/tokens into every subsequent test.
- **Idempotent test data.** Any record you create gets a timestamp suffix (`Test Order 1714502345`). Never assert exact counts.
- **Bounded retries.** Max 2 retries per step before marking the test blocked or failed.

---

## 1. Resolve PR and parse smoke tests

```bash
# Resolve PR
if [ -n "$ARGUMENTS" ]; then
  PR_REF="$ARGUMENTS"
else
  PR_REF="$(gh pr view --json number -q .number 2>/dev/null)"
fi

[ -z "$PR_REF" ] && { echo "No PR found for current branch. Pass a PR number/URL."; exit 1; }

gh pr view "$PR_REF" --json number,title,body,headRefName,baseRefName,url
```

Extract the `## Smoke Tests` section from the body. Parse each `- [ ] ...` (or `- [x] ...`) line into a smoke test item. Preserve the verbatim text.

**Bail conditions:**
- No `## Smoke Tests` section → "PR has no smoke tests section. Run `/create-pr` first or add one manually."
- Section says `N/A — ...` → print the N/A reason and exit cleanly. Nothing to run.
- Section is empty → same as missing.

**Tell the user:**
- The PR title and URL
- The number of smoke tests parsed
- A numbered preview of each test (verbatim, ≤80 chars per line)

Do NOT proceed silently — the user should confirm these are the tests to run before you boot anything heavy.

---

## 2. Detect stack

Read manifests in parallel to classify the project:

```bash
ls Gemfile package.json app.json ios/ android/ 2>/dev/null
test -f Gemfile && head -20 Gemfile
test -f package.json && jq -r '{name, deps: (.dependencies // {} | keys), scripts: (.scripts // {} | keys)}' package.json
test -f app.json && jq -r '.expo // .' app.json 2>/dev/null
```

Classify into one of:

| Stack          | Signals                                                        |
|----------------|----------------------------------------------------------------|
| `rails`        | `Gemfile` with `gem "rails"`, `config/application.rb`          |
| `react-web`    | `package.json` with `react` + `next`/`vite`/`react-scripts`    |
| `react-native` | `package.json` with `react-native` or `expo`, `ios/` or `android/` |
| `mixed`        | Multiple of the above (e.g. Rails API + RN client in monorepo) |

For `mixed`, inspect each smoke test's text to decide which sub-stack runs it (e.g. "API returns 201" → rails curl; "tapping login routes to /home" → RN sim).

**Tell the user the detected stack** before going further.

---

## 3. Health-check the environment (gate)

Run the matching health check from the stack-specific recipe below. **If health check fails, mark ALL tests as 🚫 Blocked and stop.** Do not attempt to run individual tests against a broken environment — that produces noise.

Print:
```
🚫 Blocked: <stack> dev environment not ready.
Reason: <one-line explanation>
Fix: <one-line suggestion: "start dev server with `bin/dev`" / "boot simulator">
```

Then exit. Do not auto-start servers or simulators — bail and let the user start them.

### Rails health check
```bash
curl -fsS -o /dev/null -w "%{http_code}" http://localhost:3000/up 2>/dev/null \
  || curl -fsS -o /dev/null -w "%{http_code}" http://localhost:3000/ 2>/dev/null
```
Expect 200/2xx/3xx. If connection refused → blocked.

### React (web) health check
```bash
lsof -i -P -n | grep LISTEN | grep -E ':(3000|3001|4200|5173|5174|8000|8080|8888) '
```
Pick the port that responds with HTML to a `curl` of `/`. Store as `$WEB_URL`.

### React Native health check
```bash
xcrun simctl list devices booted | grep -v '^--' | grep Booted
```
At least one device must be booted. Also verify Metro bundler is running:
```bash
curl -fsS -o /dev/null -w "%{http_code}" http://localhost:8081/status 2>/dev/null
```

---

## 4. Resolve auth via wiki

Before running the first test, look up auth/seed credentials for this project.

### 4a. Identify the project name

```bash
basename "$(git rev-parse --show-toplevel)"
git remote get-url origin 2>/dev/null
```

### 4b. Query the wiki

Use `mcp__qmd__query` against the `wiki` collection. Run these searches in parallel:

```javascript
mcp__qmd__query({
  collection: "wiki",
  searches: [
    { type: "lex", query: "<project-name> seed credentials" },
    { type: "lex", query: "<project-name> test user auth" },
    { type: "vec", query: "How do I log in to <project-name> in development?" }
  ],
  intent: "Finding seed credentials, test user, or auth setup for smoke testing this project's local dev environment"
})
```

Then `mcp__qmd__get` the top hit(s) to extract:
- Test user email + password
- Seed command (`bin/rails db:seed`, `pnpm seed:demo`)
- API token / JWT / session-cookie strategy
- Any environment variables that need to be set

### 4c. If wiki has nothing

Ask the user **once**:
> "I couldn't find auth info for this project in the wiki. Paste seed credentials or auth strategy (or 'skip' if no auth is needed)."

If the user says "skip", proceed without auth. Tests that need auth will likely Fail — that's fine, the report will surface it.

### 4d. Establish the session

For Rails / web:
```bash
# Cookie jar approach
COOKIE_JAR="$(mktemp)"
curl -c "$COOKIE_JAR" -b "$COOKIE_JAR" -X POST http://localhost:3000/sign_in \
  -H "Content-Type: application/json" \
  -d '{"email":"<from-wiki>","password":"<from-wiki>"}'
```

For Playwright (web/RN web): log in once, save `storage_state` to `/tmp/smoke-auth.json`, reuse via `browser.new_context(storage_state=...)`.

For React Native: log in once via simulator, leave the app at the post-auth root screen between tests.

---

## 5. Execute smoke tests

For **each** smoke test from step 1, run the matching recipe based on the stack and the test's intent. Recipes live below.

For each test, capture:

```
{
  "claim": "<verbatim past-tense text>",
  "status": "pass" | "fail" | "blocked",
  "evidence": "<one-line concrete observable>",
  "artifact": "<path to screenshot / log excerpt, if any>",
  "duration_s": <number>
}
```

**Per-test rules:**
- Time budget: 90s. If a test exceeds it, mark blocked with reason "timeout".
- Max 2 retries on a flaky step (e.g. element not yet rendered). After 2 retries with no progress, mark blocked or failed depending on whether you saw the element at all.
- On unexpected exception (network error, sim crash mid-test), mark blocked, record the exception, continue to the next test.
- After each web/RN test, leave the app in a clean state (logout-then-relogin if needed) — but only if a subsequent test needs it.

**Re-observe before each action.** For Playwright: snapshot DOM/a11y after every navigation. For RN: take a fresh screenshot + accessibility tree dump before tapping. Never chain blind actions.

**Self-verify each goal.** After executing, ask: "Does the current page/screen/response show evidence the claim is true?" Only that signal counts as Pass.

---

## 6. Report inline

Print to the conversation (NOT to a file):

```markdown
## Smoke Test Results — PR #<num>: <title>

**Stack:** <rails | react-web | react-native | mixed>
**Environment:** <URL or simulator name>
**Auth:** <wiki | provided | skipped>

**Summary:** ✅ <n_pass> / ❌ <n_fail> / 🚫 <n_blocked>  (total: <n>)

---

### ✅ Passed

1. <verbatim claim>
   *Evidence:* <one-line observable>

### ❌ Failed

1. <verbatim claim>
   *Last action:* <what you tried>
   *Expected:* <what the claim said>
   *Actual:* <what you observed>
   *Artifact:* `/tmp/smoke-<n>.png` (if applicable)

### 🚫 Blocked

1. <verbatim claim>
   *Reason:* <env issue, timeout, exception>
```

**Reporting rules:**
- Omit empty severity sections.
- Quote each claim verbatim — do not paraphrase.
- Evidence must be a concrete observable, not a restatement of the claim.
- For failures, the *Actual* line must show what you actually saw (text on page, response body, error message), not a generalized description.
- Top line first, details after. Reviewers scan.

---

## Stack-specific recipes

### Rails

**Health:** `curl localhost:3000/up`

**Auth:** cookie jar via curl, OR Playwright `storage_state`. For API-only Rails, prefer JWT/header.

**HTTP-level smoke** (preferred for non-UI tests):
```bash
curl -s -b "$COOKIE_JAR" -w "\n%{http_code}\n" http://localhost:3000/api/<endpoint>
# Assert response body contains expected substring + status code
```

**DB assertion** (only when claim names a side effect not visible in HTTP response):
```bash
bin/rails runner 'puts Order.where("created_at > ?", 1.minute.ago).count'
```

**UI smoke** (when the claim is about user-visible browser behavior): use Playwright via `webapp-testing` skill against `localhost:3000`.

**Forbidden:** opening `bin/rails console` interactively, running RSpec/Cucumber suites, booting Capybara.

### React (web)

**Health:** find listening port, `curl /` returns HTML.

**Tooling:** `webapp-testing` skill (Playwright Python). Read its SKILL.md if you don't already know how to use it.

**Pattern:**
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    ctx = browser.new_context(storage_state="/tmp/smoke-auth.json")
    page = ctx.new_page()
    page.goto("http://localhost:3000/<path>")
    page.wait_for_load_state("networkidle")
    # Re-observe: snapshot or query a11y tree before acting
    page.get_by_role("button", name="Submit").click()
    page.wait_for_load_state("networkidle")
    # Self-verify: assert observable evidence
    assert page.get_by_text("Order confirmed").is_visible()
    page.screenshot(path="/tmp/smoke-<n>.png")
    browser.close()
```

**Locator preference:** `get_by_role` > `get_by_label` > `get_by_text` > CSS. Never XPath.

### React Native

**Health:** simulator booted + Metro running on 8081.

**Tooling:** `ios-simulator-skill` scripts (semantic UI nav, screenshot evidence). Read the skill's SKILL.md.

**Pattern:**
1. Take fresh screenshot before each action: `python ~/.claude/skills/ios-simulator-skill/scripts/screenshot.py --output /tmp/smoke-<n>-pre.png`
2. Dump accessibility tree: `python ~/.claude/skills/ios-simulator-skill/scripts/a11y_dump.py`
3. Tap by accessibility identifier (preferred) or text label
4. Wait for next screen, re-screenshot
5. Self-verify: does the post-screenshot show the expected text/state?

**Locator preference:** accessibility identifier > accessibility label > visible text. Never raw coordinates unless absolutely no other handle exists.

**Avoid:** Detox, Appium, XCUITest harnesses — too heavy for PR-time smoke.

### Mixed (Rails API + RN client)

Inspect each test's wording. "API returns" / "endpoint" / "DB has" → Rails recipe. "Tap" / "screen" / "navigate to" → RN recipe.

---

## Don't

- Don't write any test files into the repo. This is runtime verification only.
- Don't auto-start dev servers or simulators. Bail with a clear "blocked" message.
- Don't paraphrase the smoke test claims in the report — quote verbatim.
- Don't claim a test passed without a concrete observable. "It looked fine" is not evidence.
- Don't keep retrying past 2 attempts. Mark blocked, move on.
- Don't update PR checkboxes or push to the branch. Reporting only.
- Don't run the project's full test suite (RSpec, jest, etc.) — that's CI's job.
