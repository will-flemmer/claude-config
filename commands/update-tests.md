# update-tests [input]

Update or create unit tests following TDD principles with focused, meaningful coverage. Automatically filters out redundant tests while ensuring critical paths are verified.

**Input formats:**
- File path: `/path/to/file.ts` - Update tests for specific file
- PR URL: `https://github.com/org/repo/pull/123` - Analyze PR changes and update relevant tests
- No input: Analyze git diff for uncommitted changes

---

## 🚨 MANDATORY SKILL INVOCATIONS - DO THESE FIRST 🚨

**BEFORE doing ANYTHING else, invoke these skills:**

1. **Working with unit tests?**
   ```
   Skill({ skill: "unit-testing" })
   ```
   ↳ Applies TDD principles, filters redundant tests, tests behavior not configuration

2. **About to read/search multiple files?**
   ```
   Skill({ skill: "parallel-execution-patterns" })
   ```
   ↳ Executes reads/searches in parallel (5-8x faster)

3. **Before claiming tests are complete:**
   ```
   Skill({ skill: "verification-before-completion" })
   ```
   ↳ ALWAYS verify tests pass before claiming done

**⚠️ STOP - Did you invoke the skills above? If not, DO IT NOW before continuing!**

---

## Usage

```bash
# Update tests for uncommitted changes
/update-tests

# Update tests for specific file
/update-tests src/services/auth.ts

# Update tests for PR changes
/update-tests https://github.com/myorg/myrepo/pull/456
```

## Core Instructions

You MUST use the `@unit-testing` skill for all test generation and updates.

### Step 1: Identify Changes

**For file path input:**
- Read the specified file
- Identify testable functionality

**For PR URL input:**
- Use `gh pr view <PR_NUMBER> --json files` to get changed files
- Use `gh pr diff <PR_NUMBER>` to see the actual changes
- Analyze what functionality changed or was added

**For no input (git diff):**
- Run `git diff` and `git diff --cached` to see uncommitted changes
- Identify modified functions, methods, and modules

### Step 2: Locate Test Files

- Follow project test file conventions (e.g., `*.test.*`, `*.spec.*`, `test/`, `__tests__/`)
- If test file doesn't exist, create it following project patterns
- Review existing tests to understand mocking patterns and structure

### Step 3: Apply @unit-testing Skill

When writing unit tests, automatically filter out unnecessary tests and write only meaningful ones.

**Write tests for:**
- Core functionality and public API behavior
- Critical edge cases (null/undefined, empty data, boundary conditions)
- State changes and side effects
- Key integration points

**Automatically skip tests for:**
- Implementation details (formatting, whitespace, internal methods)
- Redundant scenarios (testing same logic in different positions/with different enum values)
- Tests implicitly covered by other tests
- Multiple assertions of the same behavior

**Approach:**
- Focus on quality over quantity
- Each test should verify distinct, important behavior
- If a test feels redundant, skip it
- Prioritize coverage of critical paths over exhaustive coverage

### Step 4: Write/Update Tests Following TDD

For each new or modified test:

1. **RED**: Write test that should pass with current code
2. **GREEN**: Run test to verify it passes
3. **VERIFY**: Temporarily comment out the functionality, confirm test fails
4. **RESTORE**: Uncomment functionality, confirm test passes again

Use project's test runner:
```bash
# Run specific test file (adjust path pattern to match project)
just test path/to/test-file

# Or run all tests
just test
```

### Step 5: Remove Redundant Tests

- Identify tests that are no longer needed after refactoring
- Remove tests that duplicate behavior coverage
- Remove tests for deleted functionality
- Document removals in commit message

### Step 6: Verify Quality (MANDATORY)

**⚠️ INVOKE VERIFICATION SKILL NOW:**
```
Skill({ skill: "verification-before-completion" })
```

**Requirements before claiming complete:**
- Run appropriate tests and show the actual passing output
- Run `just lint` and show clean output (or fix issues)
- **Evidence required** - do NOT claim tests pass without showing output

## Test Selection Criteria

The `@unit-testing` skill provides detailed criteria, but key points:

**Priority 1:** Happy paths with valid inputs
**Priority 2:** Critical edges (null, undefined, empty, boundaries)
**Priority 3:** Error handling
**Priority 4:** State changes and side effects
**Priority 5:** Integration points

**When uncertain:** Ask "Would this test catch a real bug?" If no, skip it.

## Examples

### Example 1: Update tests for uncommitted changes

```bash
/update-tests
```

Claude will:
1. Analyze `git diff` output
2. Identify changed functionality
3. Update relevant test files
4. Verify tests with RED-GREEN-VERIFY-RESTORE cycle
5. Run lint and test commands

### Example 2: Update tests for specific file

```bash
/update-tests src/utils/validation.ts
```

Claude will:
1. Read `src/utils/validation.ts`
2. Find/create corresponding test file
3. Add tests for public functions
4. Focus on edge cases and error conditions
5. Verify with TDD cycle

### Example 3: Update tests for PR

```bash
/update-tests https://github.com/myorg/myrepo/pull/456
```

Claude will:
1. Fetch PR details using `gh` CLI
2. Analyze all changed files
3. Update tests for each modified module
4. Ensure tests cover new/changed behavior
5. Remove tests for deleted functionality

## Requirements

- Git repository (for git diff mode)
- Test framework set up in project
- `gh` CLI installed (for PR mode)
- Justfile with `test` and `lint` commands

## Common Patterns

### Following Existing Patterns

Always review existing tests first:
- Mock setup patterns
- Test structure and organization
- Assertion style
- File naming conventions

### Framework Agnostic

The command works with any test framework. Always:
- Review existing test files to understand project conventions
- Follow the same structure and patterns
- Use the same assertion style
- Match the project's mocking approach

## Quality Standards

- Each test verifies distinct behavior
- Tests are independent (no shared state)
- Use Arrange-Act-Assert pattern
- Mock external dependencies
- Clear, descriptive test names
- Focus on quality over quantity

## ✅ Completion Checklist

**Before claiming work is complete, verify:**

- [ ] Invoked `verification-before-completion` skill
- [ ] Appropriate tests pass and showed actual passing output
- [ ] Ran `just lint` and showed clean output
- [ ] All new tests follow RED-GREEN-VERIFY-RESTORE cycle
- [ ] No redundant tests were added

**⚠️ Never claim "tests pass" without showing the actual test output!**
