# Code Development Guidelines
These guidelines apply to ALL code written

## Project Commands (IMPORTANT)
When working in a project, ALWAYS check for a `Justfile` which contains useful commands that can be run via `just <command>`. These files typically contain project-specific commands for building, testing, linting, and other common development tasks. ALWAYS Use Just commands for:
- linting
- unit tests

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

## Code Quality Standards

### 1. Simplicity and Clarity
- Write the simplest code that could possibly work
- Each function should do exactly one thing
- Maximum function length: 20 lines
- Maximum cyclomatic complexity: 5
- No nested loops beyond 2 levels

### 2. DRY (Don't Repeat Yourself)
- Extract common code into well-named functions
- Use constants for repeated values
- Create helper functions for repeated patterns

### 3. SOLID Principles (Focus on S)
- **Single Responsibility**: Each function/class has one reason to change
- Functions should return values, not modify state when possible

### 4. Error Handling
- Use guard clauses to exit early
- Return explicit error values or throw descriptive exceptions
- Never ignore errors silently

### 5. Code Structure
- **Pure Functions**: Prefer functions without side effects
- **Descriptive Names**: Functions and variables should clearly state their purpose
- **No Magic Numbers**: Use named constants
- **One Assert Per Test**: Each test verifies one behavior

## Testing Requirements

### Test Characteristics (FIRST)
- **Independent**: Tests don't depend on each other
- **Repeatable**: Same result every time
- **Self-validating**: Pass/fail is obvious
- **Timely**: Written before production code

### Coverage Standards
- Minimum 100% line coverage
- Minimum 100% branch coverage

## Code Review Checklist

After each TDD cycle, verify:
- [ ] All tests pass
- [ ] Code is simpler than before refactoring
- [ ] No code duplication
- [ ] Function names clearly describe what they do
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
2. **Tests Pass**: Run the appropriate tests (use Justfile command) and ensure they ALL pass, else iteratively fix them.
3. **Code Quality Verification**: Ensure ALL code quality standards are met, by running linting commands (use Justfile commands)
4. **Only then** report the task as complete to the user

## Tools

### Required Tools
- **Git CLI (`git`)**: Used for version control operations including commits, branches, and repository management
- **GitHub CLI (`gh`)**: Used for GitHub operations including creating pull requests, managing issues, and viewing repository information
- **Just (`just`)**: Used for running Justfile commands
- **jq (`jq`)**: Used for parsing JSON

### Script Locations
**VERY IMPORTANT**: All Claude-specific scripts are located in the `~/.claude/commands/<name-of-command>` folder. where <name-of-command> matches the commands file name.
E.g for the `pr-checks` command which is defined in `~/.claude/commands/pr-checks.md`, the scripts are located in the `~/.claude/commands/pr-checks` directory.
This pattern is follow for all custom commands. 
