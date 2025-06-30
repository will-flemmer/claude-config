# Code Development Guidelines
These guidelines apply ALL code written. This include, application code as well as test code as well as tools as well as any other code you write. Follow the guidelines strictly. Do not break them. 

## Core Principle: Test-Driven Development (TDD)

**MANDATORY**: All code must be written using strict TDD methodology:
1. **RED**: Write a failing test first
2. **GREEN**: Write minimal code to pass the test
3. **REFACTOR**: Improve code while keeping tests green

### TDD Workflow Requirements

1. **Never write implementation code without a failing test**
2. **Each RED→GREEN cycle must take less than 5 minutes**
3. **Refactor after EVERY green test**
4. **Review code after each complete TDD cycle**
5. **Commit after each RED→GREEN→REFACTOR cycle**
   - Commit messages must be a single line, 60 characters or less

## Code Quality Standards

### 1. Simplicity and Clarity
- Write the simplest code that could possibly work
- Each function should do exactly one thing
- Maximum function length: 20 lines
- Maximum cyclomatic complexity: 5
- No nested loops beyond 2 levels

### 2. NASA-Inspired Safety Rules
- **At least 1 assertion per function if over 5 lines, otherwise zero**
- **Check all return values**

### 3. DRY (Don't Repeat Yourself)
- Extract common code into well-named functions
- Use constants for repeated values
- Create helper functions for repeated patterns

### 4. SOLID Principles (Focus on S)
- **Single Responsibility**: Each function/class has one reason to change
- Functions should return values, not modify state when possible

### 5. Error Handling
- **Fail Fast**: Validate inputs at function entry
- Use guard clauses to exit early
- Return explicit error values or throw descriptive exceptions
- Never ignore errors silently

### 6. Code Structure
- **Pure Functions**: Prefer functions without side effects
- **Descriptive Names**: Functions and variables should clearly state their purpose
- **No Magic Numbers**: Use named constants
- **One Assert Per Test**: Each test verifies one behavior

## Testing Requirements

### Test Characteristics (FIRST)
- **Fast**: Tests run in milliseconds
- **Independent**: Tests don't depend on each other
- **Repeatable**: Same result every time
- **Self-validating**: Pass/fail is obvious
- **Timely**: Written before production code

### Coverage Standards
- Minimum 100% line coverage
- Minimum 100% branch coverage
- Test edge cases and error conditions

## Code Review Checklist

After each TDD cycle, verify:
- [ ] All tests pass
- [ ] Code is simpler than before refactoring
- [ ] No code duplication
- [ ] Function names clearly describe what they do
- [ ] At least 1 assertion per function if over 5 lines
- [ ] Error cases are handled
- [ ] No commented-out code

## Example TDD Cycle

```
1. Write test:
   test_calculate_sum_returns_zero_for_empty_array()
   
2. Write minimal code:
   def calculate_sum(arr):
       return 0
       
3. Add more tests:
   test_calculate_sum_returns_single_element()
   test_calculate_sum_returns_sum_of_multiple_elements()
   
4. Implement fully:
   def calculate_sum(arr):
       assert arr is not None, "Array cannot be None"
       assert isinstance(arr, list), "Input must be a list"
       
       total = 0
       for i in range(len(arr)):
           total += arr[i]
       return total
       
5. Refactor if needed, ensure tests still pass
```

## Implementation Order

1. Start with the simplest test case
2. Add one test at a time
3. Never skip ahead - let tests drive the implementation
4. If unsure what to test next, test the next simplest case

## Correctness Above All

- **Correctness > Performance**
- **Correctness > Cleverness**
- **Correctness > Brevity** (but keep it simple)

When in doubt, choose the solution that is easiest to verify as correct.

## Task Completion Requirements

Before marking any task as complete:
1. **Objective Review**: Review all changes made for correctness and adherence to TDD principles
2. **Code Quality Verification**: Ensure ALL code quality standards are met:
   - Maximum function length: 20 lines
   - Maximum cyclomatic complexity: 5
   - No nested loops beyond 2 levels
   - At least 1 assertion per function if over 5 lines
   - All return values checked
   - No code duplication
   - Descriptive names for all functions and variables
   - No magic numbers
   - All items in Code Review Checklist pass
3. **In-Depth Smoke Testing**: Perform comprehensive testing of the feature under development:
   - **NOTE: This is NOT running unit tests** - this is manual testing of actual functionality
   - Test all happy paths (e.g., hitting endpoints and verifying responses)
   - Test all edge cases (e.g., visiting web pages and checking UI renders correctly)
   - Test all error conditions (e.g., submitting invalid data and verifying error handling)
   - Verify integration with existing features
   - Manually test the feature as a user would use it
4. **Verification**: Ensure changes work as expected and all tests pass
5. **Only then** report the task as complete to the user

## Tools

### Required Tools
- **Git CLI (`git`)**: Used for version control operations including commits, branches, and repository management
- **GitHub CLI (`gh`)**: Used for GitHub operations including creating pull requests, managing issues, and viewing repository information

### Pull Request Guidelines
When creating pull requests:
- **Title**: Use the commit message as the PR title
- **Description**: **MUST be very concise (under 200 characters total)** and include:
  - **MANDATORY**: Brief summary (max 60 characters)
  - **MANDATORY**: List specific manual smoke tests performed (not unit tests)
  - Example: "Added user auth. Smoke tests: login page loads, valid/invalid credentials, logout redirects"

## Project Commands

When working in a project, always check for a `Justfile` which contains useful commands that can be run via `just <command>`. These files typically contain project-specific commands for building, testing, linting, and other common development tasks.

