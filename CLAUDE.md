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

### 1. Simplicity and Clarity (MOST IMPORTANT)
- **ALWAYS choose the simplest solution that works**
- Write the simplest code that could possibly work
- Each function should do exactly one thing
- Maximum function length: 20 lines
- Maximum cyclomatic complexity: 5
- No nested loops beyond 2 levels
- **Prefer simple, obvious code over clever code**

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
- **Simplicity > Complexity**

When in doubt, choose the solution that is easiest to verify as correct AND simplest to understand.

## Agent-First Task Execution

**MANDATORY**: For ALL tasks requiring implementation, analysis, or specialized work, ALWAYS use the appropriate specialized agent via the Task tool. Never attempt to complete complex tasks directly.

### Agent Selection Guidelines
- **Code implementation**: Use language-specific agents (frontend-developer, backend-developer, etc.)
- **Testing**: Always use test-automator agent
- **Code review/quality**: Use code-reviewer or pr-reviewer agents  
- **PR management**: Use pr-checker agent for monitoring and fixing CI/CD issues
- **Issue creation**: Use issue-writer agent for structured GitHub issues
- **Complex planning**: Use task-decomposition-expert agent
- **Command creation**: Use command-writer agent for CLI tools
- **Workflow design**: Use workflow-orchestrator agent

### Task Routing Process
1. **Identify Task Type**: Determine which specialized agent is most appropriate
2. **Use Task Tool**: Always use `Task(subagent_type: "agent-name", description: "brief", prompt: "detailed task")`
3. **Provide Context**: Give agents comprehensive context and clear success criteria
4. **Monitor Progress**: Let agents complete their specialized work

### Direct Task Exceptions
Only handle tasks directly for:
- Simple file reading/searching operations
- Basic git status checks
- Immediate clarification questions
- Agent coordination and routing decisions

## Task Completion Requirements

Before marking any task as complete:
1. **Agent Execution**: Ensure appropriate specialized agent completed the work
2. **Objective Review**: Review all changes made for correctness and adherence to TDD principles
3. **Tests Pass**: Run the appropriate tests (use Justfile command) and ensure they ALL pass, else iteratively fix them.
4. **Code Quality Verification**: Ensure ALL code quality standards are met, by running linting commands (use Justfile commands)
5. **Only then** report the task as complete to the user

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
