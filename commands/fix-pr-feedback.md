---
description: Address and fix feedback/review comments on a GitHub PR
argument-hint: <pr-url>
allowed-tools: Read, Write, Edit, Bash(gh:*), Bash(git:*), Grep, Glob, mcp__memory__search_nodes, mcp__memory__open_nodes, mcp__sequential-thinking__sequentialthinking
model: claude-opus-4-5-20251101
---

# Fix PR Feedback

**PURPOSE**: Systematically address all review comments and feedback on a PR

**THINKING DEPTH**: Use **20+ sequential thinking steps** to methodically work through each piece of feedback. Do not rush. Understand feedback deeply before fixing.

---

## Mandatory Skill Invocations

**BEFORE making changes, invoke these skills:**

1. **Writing any code?**
   ```
   Skill({ skill: "software-development" })
   ```
   ↳ Clean code principles - layer separation, DRY, no unnecessary try/catch

2. **Feedback involves tests?**
   ```
   Skill({ skill: "unit-testing" })
   ```
   ↳ Applies TDD principles, no conditionals in tests

3. **Before claiming complete:**
   ```
   Skill({ skill: "verification-before-completion" })
   ```
   ↳ ALWAYS verify before claiming work is done

---

## Input

PR URL: $ARGUMENTS

---

## Phase 1: Gather PR Context & Feedback (Parallel Execution)

Execute ALL of these in a **single message** with parallel tool calls:

```bash
# Get PR metadata
gh pr view "$ARGUMENTS" --json title,body,author,baseRefName,headRefName,files,additions,deletions

# Get ALL review comments
gh pr view "$ARGUMENTS" --json reviews,comments

# Get inline/code comments
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments

# Get the current diff
gh pr diff "$ARGUMENTS"
```

---

## Phase 2: Checkout Branch

```bash
# Checkout the PR branch
gh pr checkout "$ARGUMENTS"
```

---

## Phase 3: Catalog All Feedback (Sequential Thinking)

**Use sequential thinking to systematically catalog and understand all feedback.**

### Feedback Cataloging Configuration

- **Minimum steps**: **5 thoughts** for cataloging
- **Create a complete list**: Every piece of feedback must be captured
- **Categorize by type**: Bug, suggestion, question, request, nitpick
- **Prioritize**: Critical → High → Medium → Low

### Initial Cataloging Thought

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Cataloging all feedback on PR. I will: (1) List every review comment, (2) List every inline comment, (3) Categorize each by type and severity, (4) Identify dependencies between fixes, (5) Create prioritized fix order.",
  thoughtNumber: 1,
  totalThoughts: 5,
  nextThoughtNeeded: true
})
```

### Feedback Categories

| Category | Description | Priority |
|----------|-------------|----------|
| **Bug/Correctness** | Logic errors, bugs identified | CRITICAL |
| **Security** | Security vulnerabilities | CRITICAL |
| **Breaking Change** | Changes that break callers | HIGH |
| **Missing Tests** | Test coverage gaps | HIGH |
| **Performance** | Performance concerns | MEDIUM |
| **Refactor Request** | Code quality improvements | MEDIUM |
| **Style/Convention** | Code style issues | LOW |
| **Question** | Clarification needed | - |
| **Nitpick** | Minor preferences | LOW |

### Feedback Tracking Format

Create a mental (or explicit) list:

```markdown
## Feedback Items

### Critical
1. [ ] file.ts:42 - Bug: Off-by-one error in loop (reviewer: @alice)
2. [ ] file.ts:88 - Security: SQL injection risk (reviewer: @bob)

### High
3. [ ] file.ts:120 - Missing test for error case (reviewer: @alice)
4. [ ] api.ts:55 - Breaking change to public API (reviewer: @carol)

### Medium
5. [ ] utils.ts:30 - Refactor: Extract to helper function (reviewer: @bob)

### Low
6. [ ] file.ts:15 - Style: Rename variable for clarity (reviewer: @alice)

### Questions to Address
7. [ ] file.ts:200 - Question: Why not use existing utility? (reviewer: @carol)
```

---

## Phase 4: Understand Context for Each Fix

**Before fixing anything, understand the full context.**

For each feedback item:

1. **Read the full file** containing the issue
2. **Read surrounding code** to understand context
3. **Find related code** that might be affected by the fix
4. **Check existing tests** that cover this area

```javascript
// For each feedback item - read context IN PARALLEL
Read({ file_path: "/path/to/file/with/feedback.ts" })
Grep({ pattern: "relatedFunction", glob: "**/*.ts" })
Grep({ pattern: "describe.*FileUnderReview", glob: "**/*.spec.ts" })
```

---

## Phase 5: Address Feedback Systematically (Sequential Thinking)

**Use sequential thinking to work through each fix methodically.**

### Fix Execution Configuration

- **Minimum steps**: **15 thoughts** for fixing
- **One fix per thought**: Focus on one feedback item at a time
- **Verify each fix**: Run relevant tests after each change
- **Track progress**: Mark items complete as you go

### Initial Fix Thought

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Beginning to address PR feedback. I have [N] items to fix. Starting with Critical items first. Item 1: [description]. Let me understand the issue fully before making changes.",
  thoughtNumber: 1,
  totalThoughts: 15,
  nextThoughtNeeded: true
})
```

### Fix Process for Each Item

**Step A**: Understand the Feedback
- What exactly is the reviewer asking for?
- Why is this a problem?
- What is the expected outcome?

**Step B**: Plan the Fix
- What changes are needed?
- What files will be affected?
- Are there any risks or side effects?

**Step C**: Implement the Fix
- Make the minimal change to address the feedback
- Don't over-engineer or scope creep
- Follow existing code patterns

**Step D**: Verify the Fix
- Does the code compile/lint?
- Do existing tests still pass?
- Does the fix actually address the feedback?

**Step E**: Add Tests (if needed)
- If feedback was about missing tests, add them
- If fix was for a bug, add regression test
- Follow existing test patterns

### Handling Different Feedback Types

**Bug/Correctness Feedback:**
```javascript
// 1. Read the code with the bug
Read({ file_path: "/path/to/buggy/file" })

// 2. Understand the expected behavior
// 3. Fix the bug
Edit({ file_path: "...", old_string: "buggy code", new_string: "fixed code" })

// 4. Add regression test
Edit({ file_path: "...test file...", ... })

// 5. Run tests to verify (use project's test command)
Bash({ command: "just test" })  // or project-specific test command
```

**Refactor Request:**
```javascript
// 1. Understand the current implementation
Read({ file_path: "/path/to/file" })

// 2. Understand the requested change
// 3. Make the refactor
Edit({ file_path: "...", ... })

// 4. Ensure tests still pass
Bash({ command: "just test" })  // or project-specific test command
```

**Question from Reviewer:**
```javascript
// 1. Understand the question
// 2. Research the answer (read related code)
Grep({ pattern: "existing utility", glob: "**/*" })

// 3. Either:
//    a) Make a code change if the question reveals an issue
//    b) Prepare an explanation to respond to the reviewer
```

**Style/Naming Feedback:**
```javascript
// Simple edit to address
Edit({ file_path: "...", old_string: "oldName", new_string: "newName", replace_all: true })
```

---

## Phase 6: Verify All Fixes

**Before completing, verify all changes work together.**

**Discover project's verification commands first:**
```javascript
// Check for project configuration
Read({ file_path: "justfile" })      // just commands
Read({ file_path: "Makefile" })      // make commands
Read({ file_path: "package.json" })  // npm scripts
Read({ file_path: "pyproject.toml" }) // python projects
Read({ file_path: "Cargo.toml" })    // rust projects
```

**Run project-appropriate verification:**
```bash
# Run full test suite (use project's test command)
just test          # or: make test, npm test, pytest, cargo test, go test, etc.

# Run linting (use project's lint command)
just lint          # or: make lint, npm run lint, ruff, clippy, golangci-lint, etc.

# Run type checking if applicable
just typecheck     # or: tsc, mypy, etc.
```

### Verification Checklist

- [ ] All feedback items addressed
- [ ] All tests pass
- [ ] Linting passes
- [ ] Type checking passes (if applicable)
- [ ] Changes are minimal and focused
- [ ] No unrelated changes introduced

---

## Phase 7: Prepare Response to Reviewers

For each feedback item, prepare a brief response:

**For fixes made:**
> "Fixed in [commit]. [Brief explanation of the fix]."

**For questions answered:**
> "[Explanation]. Let me know if you'd like me to change anything."

**For feedback you disagree with:**
> "I considered this, but [reasoning]. Happy to discuss further."

**For feedback that needs clarification:**
> "Could you clarify what you mean by [X]? I want to make sure I address this correctly."

---

## Phase 8: Commit and Push Changes

```bash
# Stage all changes
git add -A

# Create commit with clear message
git commit -m "Address PR review feedback

- Fix [issue 1]
- Fix [issue 2]
- Add tests for [area]
- Refactor [component] per review

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to PR branch
git push
```

---

## Final Step

After completing all fixes:

1. **Summarize changes made** for the user
2. **List any feedback items NOT addressed** (with reasons)
3. **Suggest responses** to post on the PR

> Would you like me to:
> 1. Post responses to each review comment on the PR
> 2. Request a re-review from the reviewers
> 3. Just summarize what was done

---

## Guidelines

**DO:**
- Address feedback exactly as requested
- Make minimal, focused changes
- Verify each fix works
- Maintain existing code style
- Add tests for bug fixes

**DON'T:**
- Scope creep beyond the feedback
- Make unrelated "improvements"
- Argue with reviewers in code comments
- Skip verification steps
- Batch too many changes without testing
