# implement-plan

Fully automated local implementation of task plans using strict Test-Driven Development (TDD) methodology.

**IMPORTANT**: This command takes a pre-analyzed task plan file and implements it locally using TDD methodology (RED-GREEN-REFACTOR). It does NOT create commits, PRs, or GitHub issues - it focuses purely on code implementation with automated testing.

## Overview

This command takes a task plan file (created by `plan-task` command) and automatically:
1. **Creates implementation session context** with progress tracking
2. **Implements each subtask** using strict TDD methodology (RED → GREEN → REFACTOR)
3. **Runs automated tests** after GREEN and REFACTOR phases
4. **Runs automated linting** after REFACTOR phase
5. **Updates session context** after each phase completion
6. **Provides progress tracking** throughout implementation

## Usage

```bash
implement-plan <plan_file_path>
```

**Arguments**:
- `plan_file_path` (required): Absolute path to task plan file (e.g., `tasks/user_authentication_oauth2_20251010_143022_12345.md`)

The command handles everything automatically - no manual steps required.

When you run this command, Claude executes the following automated workflow:

**Instructions to give Claude:**

> "Please fully implement the task plan at {{plan_file_path}} using this automated TDD workflow:
>
> ## SETUP PHASE
>
> 1. **Validate Input**:
>    - **UPDATE CONTEXT FILE: Starting Setup Phase**
>    - Verify plan file exists and is readable at: {{plan_file_path}}
>    - Extract objective and subtasks from plan file
>    - Validate plan file contains actionable subtasks
>    - **UPDATE CONTEXT FILE: Plan validation complete**
>
> 2. **Create Implementation Session**:
>    - **UPDATE CONTEXT FILE: Creating implementation session**
>    - Generate session ID: implement_$(date +%Y%m%d_%H%M%S)_$RANDOM
>    - Create session context file: tasks/session_context_{{session_id}}.md
>    - Initialize context with:
>      - Meta information (session ID, timestamp, plan file reference)
>      - Objective (from plan file)
>      - Current State: "Implementation Phase - Starting"
>      - Subtask tracking structure
>      - Empty sections for Technical Decisions, Blockers, Notes
>    - **UPDATE CONTEXT FILE: Setup Phase Complete**
>
> ## IMPLEMENTATION PHASE (For Each Subtask)
>
> For each subtask in the plan file, execute the complete TDD cycle:
>
> ### RED PHASE (Write Failing Tests)
>
> 1. **Start RED Phase**:
>    - **UPDATE CONTEXT FILE: Starting RED phase for subtask N**
>    - Context file: {{session_context_path}}. You are implementing subtask N from the plan. Write comprehensive tests that define the expected behavior. Follow TDD RED phase principles - write tests that will fail because the implementation doesn't exist yet. Before completing, update the context file with: 1) Current State: "RED phase for subtask N", 2) TDD Cycle Tracking: RED phase start/end times and test count, 3) Technical Decisions: Any key testing decisions, 4) Agent Activity Log: Add entry for RED phase completion.
>
> 2. **Verify Tests Fail**:
>    - Run: `just test`
>    - **Expected**: Tests should FAIL (this is correct for RED phase)
>    - If tests pass unexpectedly, log warning in context file
>    - **UPDATE CONTEXT FILE: RED phase complete, tests failing as expected**
>
> ### GREEN PHASE (Implement Code)
>
> 3. **Start GREEN Phase**:
>    - **UPDATE CONTEXT FILE: Starting GREEN phase for subtask N**
>    - Context file: {{session_context_path}}. You are implementing subtask N from the plan. Write minimal code to make the tests pass. Follow TDD GREEN phase principles - implement just enough to make tests pass, no more. Before completing, update the context file with: 1) Current State: "GREEN phase for subtask N", 2) TDD Cycle Tracking: GREEN phase start/end times and test results, 3) Technical Decisions: Any key implementation decisions, 4) Agent Activity Log: Add entry for GREEN phase completion.
>
> 4. **Verify Tests Pass**:
>    - Run: `just test`
>    - **Expected**: All tests should PASS
>    - **If tests fail**:
>      - **UPDATE CONTEXT FILE: Test failures in GREEN phase - attempting fix**
>      - Log error details in context file Blockers section
>      - Analyze failure and implement fix
>      - Retry up to 3 times
>      - If still failing after 3 attempts, log blocker and continue to next subtask
>    - **UPDATE CONTEXT FILE: GREEN phase complete, all tests passing**
>
> ### REFACTOR PHASE (Improve Code Quality)
>
> 5. **Start REFACTOR Phase**:
>    - **UPDATE CONTEXT FILE: Starting REFACTOR phase for subtask N**
>    - Context file: {{session_context_path}}. You are refactoring subtask N implementation. Improve code quality, readability, and maintainability while keeping tests green. Follow TDD REFACTOR phase principles - improve the code without changing behavior. Before completing, update the context file with: 1) Current State: "REFACTOR phase for subtask N", 2) TDD Cycle Tracking: REFACTOR phase start/end times and quality check results, 3) Technical Decisions: Any refactoring decisions and rationale, 4) Agent Activity Log: Add entry for REFACTOR phase completion.
>
> 6. **Verify Quality**:
>    - Run: `just test` (verify tests still pass)
>    - Run: `just lint` (verify code quality)
>    - **Expected**: Tests pass AND linting clean
>    - **If tests fail**:
>      - **UPDATE CONTEXT FILE: Tests failed during REFACTOR - reverting or fixing**
>      - Log issue in context file
>      - Fix or revert refactoring
>      - Retry until tests pass
>    - **If linting fails**:
>      - **UPDATE CONTEXT FILE: Linting issues found - attempting fixes**
>      - Log linting issues in context file
>      - Fix linting issues
>      - Continue (linting failures are warnings, not blockers)
>    - **UPDATE CONTEXT FILE: REFACTOR phase complete, quality checks passing**
>
> 7. **Complete Subtask**:
>    - **UPDATE CONTEXT FILE: Subtask N complete**
>    - Mark subtask as completed in Implementation Progress section
>    - Update Current State to next subtask or completion
>    - Log completion in Agent Activity Log
>
> ## COMPLETION PHASE
>
> After all subtasks are completed:
>
> 1. **Final Verification**:
>    - **UPDATE CONTEXT FILE: Starting final verification**
>    - Run: `just test` (final test suite run)
>    - Run: `just lint` (final linting check)
>    - Verify all Quality Gates in context file
>    - **UPDATE CONTEXT FILE: Final verification complete**
>
> 2. **Update Session Status**:
>    - **UPDATE CONTEXT FILE: Implementation complete**
>    - Set Status to "Completed" in Meta Information
>    - Set Current State to "Implementation Complete - All Subtasks Done"
>    - Update Final Quality Gates checklist
>    - Log completion in Agent Activity Log
>
> ## ERROR HANDLING
>
> - **Test Failures**: Log to context file, attempt fixes up to 3 times, mark subtask as failed if unresolvable
> - **Linting Failures**: Log to context file, attempt fixes, continue with warning if unfixable
> - **Command Errors**: Log to context file, attempt recovery, fail subtask gracefully if unrecoverable
> - **Context Updates**: MANDATORY after every phase change, before and after every test run
>
> ## SUCCESS CRITERIA
>
> The implementation is complete when:
> - ✅ All subtasks have been attempted
> - ✅ All tests passing (just test exits with code 0)
> - ✅ Linting clean (just lint exits with code 0)
> - ✅ Session context updated with final status
> - ✅ No critical blockers remaining
>
> Handle all phases automatically. Use session context file to track all progress, decisions, and issues. Stay local - do not create commits, PRs, or GitHub issues."

## How It Works

The main Claude agent handles the entire workflow by:

1. **Reading the task plan** from the provided file path
2. **Creating implementation session context** with tracking structure
3. **Implementing each subtask** using strict TDD methodology
4. **Updating context file** before and after each TDD phase
5. **Running automated tests** after GREEN and REFACTOR phases
6. **Running automated linting** after REFACTOR phase
7. **Tracking all progress** in the session context file
8. **Handling errors gracefully** with retry logic and blocker tracking
9. **Managing the context file** as the single source of truth for implementation progress

## TDD Methodology

This command enforces strict Test-Driven Development:

### RED Phase (Write Tests)
- Write tests that define expected behavior
- Tests MUST fail initially (no implementation exists yet)
- Focus on comprehensive test coverage
- Document testing decisions in context file

### GREEN Phase (Implement Code)
- Write minimal code to make tests pass
- Focus on making tests pass, not perfect code
- Run tests to verify all pass
- Handle failures with retry logic (up to 3 attempts)

### REFACTOR Phase (Improve Quality)
- Improve code quality while keeping tests green
- Run tests to verify they still pass
- Run linting to ensure code quality standards
- Document refactoring decisions in context file

## Context Management

The command creates and maintains a session context file that tracks:

### Meta Information
- Session ID and timestamps
- Plan file reference
- Working directory
- Overall status

### Implementation Progress
- Status of each subtask (Pending/In Progress/Completed/Failed)
- TDD phase tracking (RED/GREEN/REFACTOR)
- Timestamps for each phase

### Discovered Context
- **Technical Decisions**: Key implementation choices and rationale
- **Blockers**: Issues encountered and resolution attempts
- **Notes**: Additional observations and context

### Test Execution History
- Every test run is logged with timestamp, phase, command, and result
- Tracks expected vs actual test outcomes
- Documents test failure resolution attempts

### Agent Activity Log
- Complete chronological log of all activities
- Phase transitions and completions
- Test runs and quality checks
- Error occurrences and resolutions

## Completion Criteria

The automated workflow completes when:
- ✅ All subtasks have been processed
- ✅ All tests pass (just test exits with code 0)
- ✅ Linting clean (just lint exits with code 0)
- ✅ Session context updated with final status
- ✅ Quality Gates checklist complete

## Error Handling

Claude automatically handles:

### Test Failures
- **During RED phase**: Expected (tests should fail)
- **During GREEN phase**: Retry up to 3 times, log blocker if unresolved
- **During REFACTOR phase**: Revert or fix refactoring, ensure tests pass

### Linting Failures
- **During REFACTOR phase**: Attempt to fix, continue with warning if unfixable
- Log all linting issues in context file Blockers section
- Linting failures don't block completion (warnings only)

### Command Errors
- Log all errors in context file
- Attempt recovery where possible
- Mark subtask as failed if unrecoverable
- Continue to next subtask to maximize progress

### Context Updates
- MANDATORY before and after each phase
- MANDATORY before and after each test run
- Ensures complete traceability and progress tracking

## Examples

### Basic Usage

```bash
# Implement a pre-planned task
implement-plan tasks/user_authentication_oauth2_20251010_143022_12345.md

# Expected output:
# Creating implementation session...
# Session context: tasks/session_context_implement_20251010_150530_98765.md
#
# Implementing subtask 1/5: Create User model with OAuth fields
#   RED phase: Writing tests...
#   Tests written (3 new tests, all failing as expected)
#
#   GREEN phase: Implementing code...
#   Implementation complete (tests passing: 3/3)
#
#   REFACTOR phase: Improving code quality...
#   Refactoring complete (tests passing: 3/3, linting: clean)
#
# Subtask 1/5 complete ✓
#
# [... continues for all subtasks ...]
#
# Implementation complete!
#   Total subtasks: 5
#   Completed: 5
#   Failed: 0
#   Session context: tasks/session_context_implement_20251010_150530_98765.md
```

### With Test Failures

```bash
# Implementation with test failures (auto-retry)
implement-plan tasks/complex_feature_20251010_120000_11111.md

# Expected output:
# Creating implementation session...
# Session context: tasks/session_context_implement_20251010_153045_44444.md
#
# Implementing subtask 1/3: Complex calculation engine
#   RED phase: Writing tests...
#   Tests written (5 new tests, all failing as expected)
#
#   GREEN phase: Implementing code...
#   ⚠ Tests failed (2/5 passing) - Attempt 1/3
#   Analyzing failures and fixing...
#   ⚠ Tests failed (4/5 passing) - Attempt 2/3
#   Analyzing failures and fixing...
#   ✓ Implementation complete (tests passing: 5/5)
#
#   REFACTOR phase: Improving code quality...
#   Refactoring complete (tests passing: 5/5, linting: clean)
#
# Subtask 1/3 complete ✓
#
# [... continues ...]
```

## Integration with Other Commands

### Consumed By
- **plan-task**: Creates the task plan files that this command implements
- **implement-gh-issue**: Can use implement-plan internally for structured implementation

### Produces
- Session context files with complete implementation history
- Implemented code with comprehensive tests
- Progress tracking and technical decision documentation

### File Paths

All file paths must be absolute for reliability:
- **Plan File**: Provided as argument (e.g., `/Users/williamflemmer/Documents/claude-config/tasks/user_auth_20251010_143022_12345.md`)
- **Session Context**: Auto-generated at `/Users/williamflemmer/Documents/claude-config/tasks/session_context_implement_<timestamp>_<random>.md`

## Requirements

### System Dependencies

- **Git**: For repository context and working directory detection
- **just**: For running tests (`just test`) and linting (`just lint`)
- **Test framework**: Project must have working test suite accessible via `just test`
- **Linter**: Project must have working linter accessible via `just lint`

### Project Requirements

- **Justfile**: Must contain `test` and `lint` targets
- **Test Suite**: Must be functional and return proper exit codes (0 = success, non-zero = failure)
- **Linting Setup**: Must be configured and return proper exit codes

### Permissions

- **File System Access**: Read access to plan files, write access to tasks/ directory
- **Command Execution**: Permission to execute `just test` and `just lint`

### Environment

- Must be run from within the project directory
- Plan file must exist and be readable
- tasks/ directory must exist or be creatable

## Scope Limitations

This command is specifically scoped for LOCAL implementation only:

### What It Does
- ✅ Reads task plan files
- ✅ Implements code using TDD methodology
- ✅ Runs automated tests and linting
- ✅ Tracks progress in session context
- ✅ Handles errors and retries

### What It Does NOT Do
- ❌ Create git commits
- ❌ Push code to remote repositories
- ❌ Create pull requests
- ❌ Create or update GitHub issues
- ❌ Interact with external APIs or services (unless required by subtask)

Use `implement-gh-issue` command if you need the full workflow with commits, PRs, and CI/CD integration.

## Benefits

- **Fully Automated**: No manual intervention required from plan to implementation
- **Strict TDD Enforcement**: Mandatory RED-GREEN-REFACTOR cycle for every subtask
- **Complete Traceability**: Every decision, test run, and phase tracked in context file
- **Error Resilience**: Automatic retry logic for test failures
- **Quality Assurance**: Automated testing and linting after every implementation
- **Progress Visibility**: Real-time progress tracking in session context
- **Learning Tool**: Context file serves as documentation of TDD process

## Implementation Details

### File Structure

```
commands/implement-plan/
└── templates/
    └── session_context.md      # Implementation session context template
```

### Template Variables

The session context template uses these variables:
- `{{session_id}}`: Unique session identifier
- `{{timestamp}}`: ISO timestamp
- `{{plan_file_path}}`: Absolute path to plan file
- `{{working_directory}}`: Current working directory
- `{{objective}}`: Task objective from plan file
- `{{session_context_path}}`: Path to session context file
- `{{subtask_name}}`: Name of current subtask

### Agent Integration

This command uses the main Claude agent for all implementation work:
- **Main Claude Agent**: Handles TDD implementation, test execution, linting, and context updates

No specialized agents are required - the main agent performs all work directly following the TDD workflow instructions.

## Troubleshooting

### Common Issues

#### "Plan file not found"

```bash
# Verify plan file exists
ls -la tasks/user_auth_20251010_143022_12345.md

# Use absolute path
implement-plan /Users/williamflemmer/Documents/claude-config/tasks/user_auth_20251010_143022_12345.md
```

#### "just test command not found"

```bash
# Verify Justfile exists and has test target
just --list

# Verify test target works
just test
```

#### "Tests keep failing in GREEN phase"

Check session context file Blockers section for:
- Specific test failure messages
- Number of retry attempts
- Technical decisions that may need adjustment

The context file tracks all test failures and attempts, providing complete debugging history.

#### "Session context file not updating"

Ensure Claude has write permissions:
```bash
# Check permissions
ls -la tasks/

# Fix permissions if needed
chmod 755 tasks/
```

## Quality Standards

### Input Validation

- **Plan file exists**: Must be a readable file
- **Plan file format**: Must contain objective and subtasks
- **Actionable subtasks**: Plan must have concrete, implementable subtasks

### Output Quality

- **TDD methodology**: Strict RED-GREEN-REFACTOR cycle enforcement
- **Test coverage**: Comprehensive tests for all implemented code
- **Code quality**: All code passes linting checks
- **Progress tracking**: Complete activity log in session context
- **Error documentation**: All issues logged with resolution attempts

### Session Context Quality

- **Complete tracking**: Every phase, test run, and decision logged
- **Absolute paths**: All file references use full absolute paths
- **Structured format**: Follows consistent template structure
- **Actionable information**: Blockers and notes provide clear context for debugging

## Agent-First Execution Requirements

**MANDATORY**: This command follows Agent-First Task Execution guidelines:

### Direct Execution Pattern

Unlike commands that route to specialized agents, this command:
1. ✅ Main Claude agent executes implementation directly
2. ✅ Follows strict TDD workflow instructions
3. ✅ Updates context file at every phase transition
4. ✅ Runs automated tests and linting
5. ✅ Handles errors with retry logic

### Why No Specialized Agents?

This command uses direct execution because:
- **TDD workflow is prescriptive**: Clear step-by-step process doesn't require specialized analysis
- **Context sharing overhead**: Direct execution is more efficient for sequential, structured tasks
- **Single responsibility**: All work is code implementation using consistent methodology
- **Atomic operations**: Each TDD phase is self-contained and straightforward

### Compliance Verification

This command satisfies Agent-First principles by:
- [ ] Following structured, repeatable workflow
- [ ] Comprehensive context file tracking
- [ ] Automated quality checks at every phase
- [ ] Clear error handling and recovery
- [ ] Complete traceability of all decisions and actions

This command provides a robust, automated way to implement pre-planned tasks using industry-standard TDD methodology while maintaining complete visibility and traceability through comprehensive session context tracking.
