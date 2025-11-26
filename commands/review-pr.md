---
description: Review a GitHub PR for code quality, security, and best practices
argument-hint: <pr-url>
allowed-tools: Read, Bash(gh:*), Grep, Glob, mcp__memory__search_nodes, mcp__memory__open_nodes, mcp__sequential-thinking__sequentialthinking
model: claude-opus-4-5-20251101
---

# PR Review

**PURPOSE**: Perform deep, thorough code review on the specified PR using structured reasoning

**THINKING DEPTH**: This review requires extensive analysis. Take your time. Use **36+ sequential thinking steps minimum** (10 for exploration + 26 for analysis). Branch and revise thoughts as needed. Do not rush. Code correctness is the highest priority, followed by maintainability.

---

## Mandatory Skill Invocation

**BEFORE analyzing tests, invoke the unit-testing skill:**

```
Skill({ skill: "unit-testing" })
```

This skill provides critical guidance for evaluating test quality, especially distinguishing **behavior tests** (valuable) from **configuration tests** (wasteful).

---

## Input

PR URL: $ARGUMENTS

---

## Phase 1: Gather PR Metadata (Parallel Execution)

Execute ALL of these in a **single message** with parallel tool calls:

```bash
# Get PR metadata
gh pr view "$ARGUMENTS" --json title,body,author,baseRefName,headRefName,files,additions,deletions,comments,reviews

# Get the diff
gh pr diff "$ARGUMENTS"

# Get PR comments/conversation
gh pr view "$ARGUMENTS" --json comments,reviews --jq '.comments[], .reviews[]'
```

Also query memory in parallel (if initialized):
```javascript
mcp__memory__search_nodes({ query: "[technology from PR] review patterns" })
mcp__memory__search_nodes({ query: "security vulnerabilities" })
```

---

## Phase 1.5: Checkout Branch & Deep Codebase Exploration (CRITICAL)

**You MUST checkout the PR branch and thoroughly explore the codebase using sequential thinking.**

### Checkout the Branch

```bash
# Checkout the PR branch locally
gh pr checkout "$ARGUMENTS"
```

### Structured Exploration with Sequential Thinking

**DO NOT just read the diff. You must understand the FULL context.**

**Use sequential thinking to systematically explore. Use parallel tool calls within each step.**

#### Exploration Thinking Configuration

- **Minimum steps**: **10 thoughts** for exploration
- **Use parallel tools**: Within each thought, execute multiple Read/Grep/Glob in parallel
- **Be thorough**: Better to over-explore than under-explore
- **Document findings**: Each thought should summarize what was learned

#### Initial Exploration Thought

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Beginning codebase exploration for PR. Modified files: [list]. I will systematically explore: (1) full file contents, (2) call sites and dependencies, (3) related patterns, (4) test coverage, (5) project standards. Starting with reading all modified files in their entirety.",
  thoughtNumber: 1,
  totalThoughts: 10,
  nextThoughtNeeded: true
})
```

#### Required Exploration Steps

**Exploration Step 1**: Read All Modified Files Completely
- Read the ENTIRE file for each modified file, not just the changed lines
- Understand what each file does and its role in the architecture
- Note all functions/classes defined in each file

```javascript
// Execute in parallel within this thought
Read({ file_path: "/path/to/modified/file1.ts" })
Read({ file_path: "/path/to/modified/file2.ts" })
Read({ file_path: "/path/to/modified/file3.ts" })
```

**Exploration Step 2**: Identify All Changed Functions/Classes
- List every function, class, type, or export that was modified
- Note the signature changes (parameters, return types)
- Identify any renamed or removed exports

**Exploration Step 3**: Trace Call Sites (Critical)
- For EACH changed function/class, find ALL places that use it
- Search aggressively - use multiple search patterns
- Understand how changes will affect callers

```javascript
// Search for every modified function - IN PARALLEL
// Use appropriate glob for project language (*.ts, *.py, *.go, *.rs, *.java, etc.)
Grep({ pattern: "functionName\\(", glob: "**/*" })
Grep({ pattern: "ClassName", glob: "**/*" })
Grep({ pattern: "import.*moduleName", glob: "**/*" })
```

**Exploration Step 4**: Trace Dependencies (What This Code Uses)
- What does the modified code import/depend on?
- Read those dependencies to understand constraints
- Are there breaking changes in how dependencies are used?

```javascript
// Read dependencies - IN PARALLEL
Read({ file_path: "/path/to/imported/module.ts" })
Read({ file_path: "/path/to/base/class.ts" })
Read({ file_path: "/path/to/types.ts" })
```

**Exploration Step 5**: Find Similar Patterns in Codebase
- Search for similar implementations elsewhere
- Are there established patterns this PR should follow?
- Are there anti-patterns this PR might be introducing?

```javascript
// Search for patterns - IN PARALLEL
// Adjust globs for project language
Grep({ pattern: "similar_pattern", glob: "**/*" })
Grep({ pattern: "class.*extends.*BaseClass", glob: "**/*" })
Glob({ pattern: "**/*Service*" })
```

**Exploration Step 6**: Understand Module Structure
- Read the module's index/entry point
- Understand the public API
- Check for README or documentation

```javascript
// Read module context - IN PARALLEL
// Adjust paths for project structure and language
Read({ file_path: "/path/to/module/index" })  // or __init__.py, mod.rs, etc.
Read({ file_path: "/path/to/module/README.md" })
Glob({ pattern: "src/[module]/**/*" })
```

**Exploration Step 7**: Review Existing Tests
- Find ALL tests related to modified code
- Read the tests to understand expected behavior
- Note testing patterns and mocking strategies

```javascript
// Find and read tests - IN PARALLEL
// Adjust patterns for project's test conventions
Grep({ pattern: "[ModifiedClass]", glob: "**/*test*" })
Grep({ pattern: "[modifiedFunction]", glob: "**/*spec*" })
Glob({ pattern: "**/test*/**/*" })  // or tests/, __tests__/, *_test.go, etc.
```

**Exploration Step 8**: Review Project Standards
- Read CLAUDE.md for coding standards
- Check linting and language configuration
- Look for architectural decision records

```javascript
// Read config - IN PARALLEL
// Adjust for project's configuration files
Read({ file_path: "CLAUDE.md" })
Glob({ pattern: "*config*" })      // tsconfig, pyproject.toml, Cargo.toml, etc.
Glob({ pattern: "*lint*" })        // .eslintrc, .ruff.toml, .golangci.yml, etc.
Glob({ pattern: "**/ADR*.md" })
```

**Exploration Step 9**: Check for Breaking Changes
- Based on call sites found, are there breaking changes?
- Are there places that need updating but weren't in the PR?
- Are there implicit contracts being violated?

**Exploration Step 10**: Synthesize Exploration Findings
- Summarize what you learned about the codebase
- List concerns discovered during exploration
- Note patterns that should be followed or are being violated
- Identify any red flags for deeper analysis

### Exploration Checklist

Before proceeding to Phase 2, confirm via sequential thinking:
- [ ] All modified files read in their entirety
- [ ] All call sites identified and understood
- [ ] Dependencies traced and understood
- [ ] Similar patterns in codebase identified
- [ ] Module structure understood
- [ ] Existing test coverage reviewed
- [ ] Project standards (CLAUDE.md) consulted
- [ ] Potential breaking changes identified
- [ ] Findings synthesized and documented

**Time spent here is NOT wasted. Shallow context = shallow review.**

---

## Phase 2: Deep Structured Analysis (MANDATORY)

**YOU MUST use sequential thinking for the review analysis.**

### Thinking Configuration

- **Minimum steps**: **26 thoughts** (increase `totalThoughts` if needed for larger PRs)
- **Use branching**: When exploring alternative interpretations, use `branchFromThought` and `branchId`
- **Use revision**: When you reconsider a finding, use `isRevision: true` and `revisesThought`
- **Extend freely**: Set `needsMoreThoughts: true` if you need to go deeper
- **Do not rush**: Quality over speed. Each thought should be substantive.
- **Priority order**: (1) Code correctness, (2) Maintainability/Readability, (3) Security, (4) Performance

### Initial Thought

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Analyzing PR: [title]. Scope: [N] files, [+additions/-deletions]. Purpose: [from description]. I will conduct a thorough multi-pass review with emphasis on CODE CORRECTNESS as the highest priority, followed by MAINTAINABILITY and READABILITY. I'll examine logic deeply, trace execution paths, evaluate code quality for long-term maintenance, and verify edge case handling.",
  thoughtNumber: 1,
  totalThoughts: 26,
  nextThoughtNeeded: true
})
```

### Required Analysis Phases

**Phase A: Understanding & Context Synthesis (Steps 1-3)**

*Use insights from Phase 1.5 codebase exploration here.*

**Step 1**: Scope & Intent Analysis
- What problem is this PR solving?
- What is the expected behavior change?
- What files are affected and why?
- What is the blast radius if something goes wrong?
- Are there any implicit assumptions?
- How does this relate to the broader codebase you explored?

**Step 2**: Architecture Impact
- How does this change fit into the existing architecture?
- Are there ripple effects to other components? (Reference call sites found)
- Does this introduce new dependencies?
- Is the abstraction level appropriate?
- Does it follow patterns seen elsewhere in the codebase?

**Step 3**: Context Synthesis
- Synthesize findings from codebase exploration
- What did you learn from reading the full files (not just diff)?
- Are there existing patterns this PR follows or violates?
- What do the existing tests tell you about expected behavior?
- Any concerns from related code that weren't obvious from the diff?

**Phase B: Code Correctness Deep Dive (Steps 4-10) - HIGHEST PRIORITY**

This is the most important phase. Spend at least 6-7 thoughts here.

**Step 4**: Logic Correctness - Happy Path
- Does the logic accomplish the stated goal?
- Trace through the code line-by-line for the main use case
- Are the algorithms correct? Verify any non-trivial logic
- Is the control flow sound? No unreachable code?
- Are return values correct in all branches?

**Step 5**: Logic Correctness - Conditional Branches
- Are all if/else branches correct?
- Are switch statements exhaustive? Missing cases?
- Are boolean conditions correct? (Watch for && vs ||, ! placement)
- Are comparisons correct? (< vs <=, == vs ===)
- Are ternary operators readable and correct?

**Step 6**: Logic Correctness - Loops & Iteration
- Are loop bounds correct? Off-by-one errors?
- Are loop termination conditions correct?
- Are break/continue used correctly?
- Are async iterations handled properly (for await, Promise.all)?
- Are there infinite loop risks?

**Step 7**: Logic Correctness - Data Flow
- Is data transformed correctly through each step?
- Are mutations happening where expected (and not where unexpected)?
- Are immutability guarantees maintained?
- Are there race conditions in async code?
- Is state being updated correctly?

**Step 8**: Edge Cases & Boundaries
- What happens with null/undefined/empty inputs?
- What happens at boundaries (0, -1, MAX_INT, empty string, empty array)?
- What happens with very large inputs?
- What happens with malformed inputs?
- Are all error conditions handled?
- Are resources properly cleaned up on failure?
- What happens on timeout/cancellation?

**Step 9**: Type Safety & Coercion
- Are types correct throughout? (especially in JS/TS)
- Are there implicit type coercions that could cause bugs?
- Are nullable types handled correctly?
- Are generic types constrained properly?
- Are any `any` types hiding potential issues?

**Step 10**: Concurrency & Async Correctness
- Are promises handled correctly? (await, .then, .catch)
- Are there race conditions?
- Is error propagation correct in async code?
- Are concurrent operations properly synchronized?
- Are there deadlock risks?

**Step 11**: API Design & Parameter Redundancy (IMPORTANT)
- For each function/method, check parameters:
  - Can any parameter be derived from another? (e.g., `func(user, user.id)` - why pass both?)
  - If `param_a.related_field` gives you `param_b`, why require both?
  - Are there parameters that are always used together? (should be a single object?)
- Check for confusing APIs:
  - Could a caller pass mismatched parameters? (e.g., `attendee` from event A, but `event` B)
  - Is the parameter order intuitive?
  - Are optional parameters at the end?
- Flag redundant/confusing parameters as **MEDIUM** severity

**Phase C: Security, Performance & Quality (Steps 12-16)**

**Step 12**: Security Deep Dive (OWASP Top 10)
- **Injection**: SQL, command, LDAP, XPath, XSS
- **Broken Auth**: Session management, credential handling
- **Sensitive Data**: Encryption, logging, error messages
- **XXE**: XML parsing configuration
- **Broken Access Control**: Authorization checks
- **Misconfig**: Default settings, error handling
- **CSRF/SSRF**: Request forgery vectors
- **Insecure Deserialization**: Untrusted data parsing
- **Vulnerable Components**: Known CVEs in dependencies
- **Logging**: Sensitive data in logs, insufficient logging

**Step 13**: Performance Analysis
- Time complexity of new algorithms
- Space complexity and memory usage
- Database query efficiency (N+1, missing indexes)
- Network call patterns (batching, caching)
- Blocking operations in async contexts
- Resource pooling and limits

**Step 14**: Testing Adequacy (CRITICAL - Use unit-testing skill)

**Coverage Analysis:**
- Are critical paths tested?
- Are edge cases covered?
- Are error paths tested?
- Would these tests catch regressions?
- Are there integration/e2e gaps?

**Test Quality Analysis (HIGH PRIORITY):**

Flag as **MEDIUM or HIGH severity** any tests that:

| Anti-Pattern | Example | Why It's Bad |
|--------------|---------|--------------|
| **Configuration tests** | `expect(service.logger).toBeDefined()` | Tests wiring, not behavior |
| **Property existence tests** | `expect(obj.items).toEqual([])` | Doesn't verify functionality |
| **Type checking tests** | `expect(Array.isArray(result)).toBe(true)` | TypeScript already does this |
| **Redundant tests** | Same logic tested with different enum values | No additional confidence |
| **Implementation detail tests** | Testing private methods or internal state | Breaks on refactor |
| **Trivial getter/setter tests** | `expect(user.getName()).toBe('test')` | No logic to verify |

**The Key Question for Each Test:**
> "If this test passes, does it prove the feature actually works?"
> - If YES → Behavior test (keep it) ✅
> - If NO → Configuration test (flag it) ❌

**Examples to Flag:**

```typescript
// ❌ FLAG THIS - Configuration test
test('should have bcrypt hasher configured', () => {
  expect(authService.hasher).toBeInstanceOf(BcryptHasher)
})

// ✅ THIS IS GOOD - Behavior test
test('should return false when password is incorrect', () => {
  const result = authService.login('user@example.com', 'wrongpass')
  expect(result.success).toBe(false)
})
```

**Severity for Test Issues:**
- Redundant/needless tests bloating the suite → **MEDIUM**
- Tests that give false confidence (pass but don't verify behavior) → **HIGH**
- Missing tests for critical behavior → **HIGH**

**Phase D: Maintainability Deep Dive (Steps 15-20) - SECOND PRIORITY**

This phase is critical for long-term code health. Spend 5-6 thoughts here.

**Step 15**: Readability - Can You Understand It?
- Can a new developer understand this code in 5 minutes?
- Is the code self-documenting through clear naming?
- Are complex algorithms explained with comments?
- Is the control flow easy to follow?
- Are there any "clever" tricks that obscure intent?
- Would YOU understand this code 6 months from now?

**Step 16**: Maintainability - Can You Change It?
- How hard would it be to modify this code?
- Are there hidden dependencies that make changes risky?
- Is the code modular or is it a monolith?
- Are responsibilities clearly separated?
- Is there excessive coupling between components?
- Could you safely refactor without breaking things?

**Step 17**: Extendability - Can You Build On It?
- How easy would it be to add new features?
- Are extension points clear and documented?
- Is the architecture open for extension, closed for modification?
- Are there hardcoded values that should be configurable?
- Is the code too specific or appropriately generic?
- Would adding a new use case require rewriting?

**Step 18**: DRY & Code Duplication
- Is there copy-pasted code that should be abstracted?
- Are there repeated patterns that could be unified?
- Is there over-abstraction (DRY taken too far)?
- Are utilities and helpers used appropriately?
- Could shared logic be extracted?

**Step 19**: Complexity & Simplicity
- Is the solution as simple as possible (but no simpler)?
- Are there unnecessary abstractions?
- Is there premature optimization?
- Are there overly clever one-liners?
- Could this be done with fewer lines without sacrificing clarity?
- Is cyclomatic complexity reasonable?

**Step 20**: Project Standards & Consistency
- Follows CLAUDE.md conventions?
- Consistent with existing codebase patterns?
- Type safety maintained?
- Naming conventions followed?
- File organization matches project structure?
- Import/export patterns consistent?

**Phase E: Synthesis & Verdict (Steps 21-26)**

**Step 21**: Cross-Cutting Concerns
- Revisit earlier findings with full context
- Look for interactions between issues
- Consider cumulative risk
- Re-examine any code correctness concerns

**Step 22**: Prioritization
- Rank all findings by severity and effort
- Identify blocking vs. non-blocking issues
- Distinguish real risks from preferences
- Ensure code correctness issues are properly weighted

**Step 23**: Alternative Approaches
- Are there better ways to solve this problem?
- What trade-offs did the author make?
- Are those trade-offs reasonable?

**Step 24**: Revision & Refinement
- Revisit any uncertain findings
- Re-trace any complex logic one more time
- Strengthen or weaken assessments based on full picture
- Ensure consistency across findings

**Step 25**: Maintainability Second Pass
- Review maintainability findings with full context
- Consider: "Would I want to maintain this code?"
- Final check on readability and extendability

**Step 26**: Final Verdict
- Synthesize into clear recommendation
- Ensure all critical issues (especially correctness & maintainability) are captured
- Prepare constructive feedback
- Final confidence check: "Am I certain about my findings?"

### Thinking Guidelines

**Use branching when:**
- Uncertain if something is a bug or intentional
- Multiple valid interpretations exist
- Exploring "what if" scenarios

**Use revision when:**
- Later context changes your assessment
- You find evidence that contradicts earlier thought
- You want to upgrade/downgrade severity

**Extend thoughts when:**
- Large PR with many files
- Complex domain logic
- Security-sensitive code
- You haven't fully analyzed all changes

**Continue sequential thinking until `nextThoughtNeeded: false`**

---

### CRITICAL: DO NOT RATIONALIZE AWAY FINDINGS

**When you identify a potential issue, REPORT IT. Do not assume the author had good reasons.**

| ❌ DON'T DO THIS | ✅ DO THIS INSTEAD |
|------------------|-------------------|
| "This may be intentional for admin use cases" | Flag it and let the author explain |
| "The author probably had a reason for this" | Report the concern, ask for clarification |
| "This might be a design decision" | Flag as potential issue, note uncertainty |
| "I could be wrong about this" | Report it anyway with your reasoning |

**Your job is to identify concerns, not justify the author's choices.**

**Examples of issues to FLAG, not rationalize:**

1. **Redundant parameters**: If `func(user, user_id)` and `user.id` exists, flag it
   - Could lead to bugs if caller passes mismatched values
   - Makes API confusing
   - Let author explain if intentional

2. **Suspicious patterns**: If something looks wrong, flag it
   - Don't assume "they must have tested this"
   - Don't assume "there's probably a reason"
   - Flag and let author respond

3. **Potential edge cases**: If you're unsure if an edge case is handled
   - Don't assume "they probably thought of this"
   - Flag it and ask

**The rule**: If you notice something that MIGHT be an issue, flag it. The cost of a false positive (author explains it's fine) is much lower than the cost of a false negative (bug ships to production).

---

## Phase 3: Severity Classification

Rate each finding from sequential analysis:

| Severity | Criteria | Action |
|----------|----------|--------|
| **CRITICAL** | **Logic bug**, security vuln, data loss risk, crash | **MUST fix before merge** |
| **HIGH** | Edge case failure, race condition, false-confidence tests | Should fix before merge |
| **MEDIUM** | Performance issue, redundant tests, missing coverage | Consider fixing |
| **LOW** | Style, minor improvement | Optional |
| **NIT** | Preference, suggestion | FYI only |

### Code Correctness Severity (Highest Priority)

| Issue | Severity | Rationale |
|-------|----------|-----------|
| Logic error in happy path | **CRITICAL** | Code doesn't do what it's supposed to |
| Off-by-one error | **CRITICAL/HIGH** | Will cause wrong results or crashes |
| Unhandled null/undefined | **HIGH** | Runtime crash waiting to happen |
| Race condition | **HIGH** | Intermittent bugs, hard to reproduce |
| Incorrect comparison (< vs <=) | **HIGH** | Boundary bugs |
| Missing error handling | **HIGH** | Unhandled exceptions crash the app |
| Infinite loop risk | **CRITICAL** | Will hang the application |
| Type coercion bug | **MEDIUM/HIGH** | Subtle incorrect behavior |

### API Design Severity

| Issue | Severity | Rationale |
|-------|----------|-----------|
| Redundant parameters (can derive one from another) | **MEDIUM** | Confusing API, potential for mismatched values |
| Mismatched parameter risk (e.g., `attendee` + `event` when `attendee.event` exists) | **MEDIUM** | Caller could pass inconsistent data |
| Unintuitive parameter order | **LOW** | Confusing to use, error-prone |
| Parameters that should be a single object | **LOW** | Verbose, harder to extend |

### Maintainability Severity (Second Priority)

| Issue | Severity | Rationale |
|-------|----------|-----------|
| Unreadable code (can't understand in 5 min) | **HIGH** | Future developers will struggle or make mistakes |
| God function (50+ lines, multiple responsibilities) | **HIGH** | Impossible to test, modify, or debug |
| Tight coupling between components | **HIGH** | Changes cascade, refactoring is risky |
| DRY violation (copy-pasted logic) | **MEDIUM** | Bug fixes need multiple changes |
| Poor naming (single letters, misleading names) | **MEDIUM** | Causes confusion and bugs |
| Hardcoded values that should be configurable | **MEDIUM** | Requires code changes for config |
| Over-abstraction / premature generalization | **MEDIUM** | Adds complexity without benefit |
| Missing comments on complex logic | **LOW** | Slows down future understanding |
| Minor inconsistency with codebase patterns | **LOW** | Reduces uniformity |

### Test-Specific Severity

| Issue | Severity | Rationale |
|-------|----------|-----------|
| Configuration test (tests wiring not behavior) | **HIGH** | False confidence - passes but doesn't verify functionality |
| Redundant/duplicate test | **MEDIUM** | Bloats suite, slows CI, no additional value |
| Missing test for critical path | **HIGH** | Real bugs can slip through |
| Missing test for edge case | **MEDIUM** | Less critical but should be covered |
| Implementation detail test | **MEDIUM** | Will break on refactor, maintenance burden |

---

## Phase 4: Output Format

Structure your review as:

```markdown
## PR Review: [PR Title]

**PR**: [URL]
**Author**: [name]
**Changes**: +[additions] / -[deletions] across [N] files

### Summary
[1-2 sentence summary of what this PR does and overall assessment]

### Code Correctness Issues (HIGHEST PRIORITY)
[Logic errors, bugs, edge case failures - these BLOCK merge]
- **[CRITICAL]** file:42 - Logic error: [describe the bug and why it's wrong]
- **[HIGH]** file:78 - Edge case: [describe what input causes failure]
- **[HIGH]** file:120 - Race condition: [describe the concurrency issue]

### Security Issues
[Security vulnerabilities - these BLOCK merge]
- **[CRITICAL]** file:55 - [Vulnerability type and impact]

### API Design Issues
[Confusing or error-prone interfaces]
- **[MEDIUM]** file:42 - Redundant parameter: `func(attendee, event)` but `attendee.event` already provides event
- **[MEDIUM]** file:88 - Mismatched risk: Caller could pass `attendee` from event A with `event` B

### Test Quality Issues
[Flag any configuration tests, redundant tests, or missing behavior tests]
- **[HIGH]** test_file:45 - Configuration test: Tests that `logger` is defined but not that logging actually works
- **[MEDIUM]** test_file:78 - Redundant test: Same logic as line 52, just different input value
- **[HIGH]** Missing: No tests for error handling in `processPayment()`

### Maintainability Issues (SECOND PRIORITY)
[Readability, extendability, complexity concerns]
- **[HIGH]** file:150-200 - Readability: 50-line function with nested conditionals, hard to follow
- **[MEDIUM]** file:88 - DRY violation: Same logic repeated in `handleCreate()` and `handleUpdate()`
- **[MEDIUM]** file:220 - Extendability: Hardcoded list of types, adding new type requires code change
- **[LOW]** file:45 - Naming: Variable `d` should be `userData` for clarity

### Recommendations
[MEDIUM severity items worth addressing]
- **[MEDIUM]** file:120 - [Issue and suggestion]

### Minor Suggestions
[LOW/NIT items - optional improvements]
- **[LOW]** file:15 - [Suggestion]
- **[NIT]** file:88 - [Optional improvement]

### Verdict
- [ ] **Approve** - Ready to merge
- [ ] **Request Changes** - Issues must be addressed
- [ ] **Comment** - Questions/suggestions, non-blocking
```

---

## Review Guidelines

**DO:**
- Be specific - reference file:line for issues
- Explain WHY something is problematic
- Suggest concrete fixes
- Prioritize critical over cosmetic

**DON'T:**
- Nitpick style that linters should catch
- Comment on every line
- Be vague ("this could be better")

---

## Final Step

After completing the review, ask:

> Would you like me to:
> 1. Post this review as a comment on the PR (`gh pr comment`)
> 2. Just keep the review here for reference
