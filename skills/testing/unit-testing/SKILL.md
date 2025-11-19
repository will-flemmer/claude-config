---
name: unit-testing
description: Use when writing or updating unit tests for code changes - applies TDD principles with focused test coverage, filtering out redundant tests while ensuring critical paths, edge cases, and state changes are verified
---

# Unit Testing

## Overview

Write meaningful unit tests following TDD principles. Focus on critical behavior verification while automatically filtering out redundant, implementation-detail, and implicitly-covered tests.

**Core principle:** Each test should verify distinct, important behavior. If a test feels redundant, skip it.

## When to Use

Use this skill when:
- Writing tests for new functionality
- Updating tests for modified code
- Reviewing test coverage for completeness
- Refactoring existing test suites

Do NOT use for:
- Integration tests (use integration-testing skill)
- E2E tests (use e2e-testing skill)
- Performance tests

## Test Selection Criteria

### Write Tests For

**Core functionality and public API behavior**
- Public methods and their contracts
- Expected return values and side effects
- API boundaries and interfaces

**Critical edge cases**
- Null/undefined inputs
- Empty data structures ([], {}, "")
- Boundary conditions (min/max values, array bounds)
- Invalid input handling

**State changes and side effects**
- Object state mutations
- External system calls (mocked)
- Event emissions
- Observable behavior changes

**Key integration points**
- Service boundaries
- External dependencies (mocked)
- Data transformations at boundaries

### Automatically Skip Tests For

**Implementation details**
- Code formatting or whitespace
- Private methods (test through public API)
- Internal variable naming
- Method ordering

**Redundant scenarios**
- Testing same logic with different enum values unless behavior differs
- Multiple positions in arrays when logic is position-agnostic
- Duplicate assertions of identical behavior
- Tests that only differ in input values but not logic paths

**Implicitly covered behavior**
- Functionality verified by other tests
- Simple getters/setters without logic
- Trivial delegations to other tested methods

**Multiple assertions of same behavior**
- Don't test string formatting 5 different ways
- Don't test each field separately if they use same mechanism

## Test Quality Standards

### Structure
Follow the Arrange-Act-Assert (AAA) pattern:

```
test 'should [expected behavior] when [condition]':
  // Arrange: Set up test data and mocks
  input = createTestInput()
  mock = createMock(expected)

  // Act: Execute the behavior
  result = method(input)

  // Assert: Verify outcomes
  assert result equals expected
  assert mock was called with input
```

### Naming Convention
- Use `should [expected behavior] when [condition]` format
- Be specific: "should return empty array when input is null"
- Not vague: "should work correctly"

### Test Independence
- Each test must be runnable in isolation
- No shared state between tests
- Use setup hooks for common initialization
- Clean up in teardown hooks if needed

### Mock Usage
- Mock external dependencies
- Don't mock the system under test
- Follow existing mocking patterns from codebase
- Verify mock interactions when they represent important behavior

## Target Coverage

**Focus on quality over quantity** - write only tests that verify distinct, important behavior.

Coverage goals:
- 100% of public API surface
- 100% of critical paths
- Representative edge cases (not exhaustive)
- Key error conditions

**Warning signs of over-testing:**
- Testing implementation details
- Being redundant
- Testing too granularly
- Each test doesn't add new confidence

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Testing private methods directly | Test through public API |
| Tests coupled to implementation | Test behavior, not structure |
| One assertion per test (too granular) | Group related assertions logically |
| Testing framework code | Only test your code |
| No arrange-act-assert structure | Follow AAA pattern |
| Brittle tests (break on refactor) | Test interface, not implementation |

## TDD Workflow Integration

When adding tests:
1. **RED**: Write failing test for missing/changed behavior
2. **GREEN**: Verify test passes with current implementation
3. **VERIFY**: Comment out functionality, confirm test fails
4. **RESTORE**: Uncomment functionality, confirm test passes again
5. **REFACTOR**: Improve test clarity if needed

## Quick Reference

### Test Categories by Priority

| Priority | Category | Examples |
|----------|----------|----------|
| 1 | Happy path | Valid inputs → expected outputs |
| 2 | Critical edges | null, undefined, empty, boundaries |
| 3 | Error handling | Invalid inputs, exceptions |
| 4 | State changes | Mutations, side effects |
| 5 | Integration points | Service calls, data transforms |

### When Uncertain

Ask yourself:
1. **Does this test verify distinct behavior?** → Keep it
2. **Would this test catch a real bug?** → Keep it
3. **Is this behavior already tested elsewhere?** → Skip it
4. **Am I testing implementation details?** → Skip it
5. **Would I write this test if I had to justify each one?** → Be honest

## Real-World Impact

**Before filtering:**
- 47 tests for a module
- 30-minute test suite runtime
- Tests break on every refactor
- Hard to identify real failures

**After filtering:**
- 12 focused tests for same module
- 5-minute test suite runtime
- Tests survive refactoring
- Failures indicate real issues

Fewer, better tests = higher confidence, faster feedback.
