# implement-plan

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Implement task plans using TDD methodology

---

## 🚨 MANDATORY SKILL INVOCATIONS - DO THESE FIRST 🚨

**BEFORE doing ANYTHING else, invoke these skills:**

1. **Writing any code?**
   ```
   Skill({ skill: "software-development" })
   ```
   ↳ Clean code principles - layer separation, DRY, no unnecessary try/catch

2. **Writing/updating tests?**
   ```
   Skill({ skill: "unit-testing" })
   ```
   ↳ Applies TDD principles, filters redundant tests

3. **Before claiming complete:**
   ```
   Skill({ skill: "verification-before-completion" })
   ```
   ↳ ALWAYS verify before claiming work is done

**⚠️ STOP - Did you invoke the skills above? If not, DO IT NOW before continuing!**

---

## What This Does
Implements planned development tasks following TDD methodology. Reads planning documents, writes tests and code, updates session context throughout execution.

**Key Activities**: Test creation → Implementation → Refactoring → Context updates → Quality checks

## Context File Integration
**MANDATORY**: Always create session context files for tracking.

**Context File Creation**:
1. Generate session ID: `implement_$(date +%Y%m%d_%H%M%S)_$RANDOM`
2. Create `tasks/session_context_<session_id>.md` immediately
3. Initialize with objective, subtask tracking, TDD phase tracking

## Usage

```bash
implement-plan <plan_file_path>
```

**Arguments**:
- `plan_file_path` (required): Path to task plan file (e.g., `tasks/task_plan_*.md`)

## Context Updates Throughout Implementation

**CRITICAL**: Update session context at these key points using Edit tool:

**Current State** → After each major workflow step (e.g., "RED phase for subtask 1", "GREEN phase complete")
**Technical Decisions** → Architecture choices, design patterns, refactoring rationale
**TDD Cycle Tracking** → Phase start/end times, test counts, results
**Agent Activity Log** → Significant actions with timestamps
**Blockers** → Test failures, implementation issues, resolution attempts

Reference in workflow steps as: `(update context: section_name)`

## Automated TDD Workflow

### Setup Phase

**1. Validate Plan File** (Read tool)
- Load plan from `{{plan_file_path}}`
- Extract: objective, subtasks, acceptance criteria
- Verify actionable subtasks exist
- (update context: current state)

**2. Create Session Context** (Write tool)
- Generate session ID: `implement_$(date +%Y%m%d_%H%M%S)_$RANDOM`
- Create `tasks/session_context_{{session_id}}.md`
- Initialize: meta info, objective, subtask tracking, TDD phase tracking
- (update context: current state)

### Implementation Phase (For Each Subtask)

Execute complete TDD cycle for each subtask:

**3. RED Phase - Write Failing Tests**
- Write tests defining expected behavior for subtask
- Ensure tests fail (no implementation yet)
- Run related tests only (e.g., `just test path/to/test-file.spec.ts`)
- (update context: current state, TDD cycle tracking, technical decisions)

**4. GREEN Phase - Implement Code**
- Write minimal code to pass tests
- Run related tests only (verify subtask tests pass)
- If failures: debug → fix → re-run (retry up to 3 times)
- (update context: current state, TDD cycle tracking, blockers if failures)

**5. REFACTOR Phase - Improve Quality**
- Improve code: remove duplication, enhance readability
- Maintain passing tests throughout
- Run related tests only (verify still passing)
- Run: `just lint <files>` (lint only modified files)
- (update context: current state, TDD cycle tracking, technical decisions)

**6. Complete Subtask**
- Mark subtask complete in context
- Update current state to next subtask
- (update context: current state, agent activity log)

### Completion Phase

**7. Final Verification**
- Run tests for all changed files
- Run linting for all changed files
- Verify all subtasks complete
- (update context: current state)

**8. Finalize Session**
- Set status to "Completed" in context
- Update final quality gates checklist
- (update context: current state, agent activity log)

## TDD Methodology

Follow strict RED → GREEN → REFACTOR cycles:

**RED Phase**
- Write failing tests for single feature
- Verify tests fail with clear error messages
- Run only related tests (e.g., `just test path/to/feature.spec.ts`)
- Document expected behavior in context

**GREEN Phase**
- Implement minimal code to pass tests
- Verify related tests pass (run related tests only)
- Retry up to 3 times if failures occur

**REFACTOR Phase**
- Improve: remove duplication, enhance readability
- Maintain passing tests throughout
- Run related tests only (verify still passing)
- Lint modified files: `just lint <files>`

## Error Handling

**Test Failures**
- RED phase: Expected (tests should fail)
- GREEN phase: Retry up to 3 times → log blocker if unresolved
- REFACTOR phase: Revert or fix → ensure tests pass

**Linting Failures**
- Attempt to fix → continue with warning if unfixable
- Log all issues in context Blockers section
- Don't block completion (warnings only)

**Implementation Issues**
- Log in context → attempt recovery → mark subtask failed if unrecoverable
- Continue to next subtask to maximize progress

## Completion Criteria

Implementation complete when:
- ✅ All subtasks processed
- ✅ All related tests pass (tests for changed files)
- ✅ Linting clean for changed files
- ✅ Session context updated with final status

**Testing Strategy**: Run only tests related to the code being changed. This keeps feedback fast and focused.

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

## Key Features

- **Automated TDD**: Strict RED-GREEN-REFACTOR enforcement
- **Efficient Testing**: Run only tests related to changes (no full test suite runs)
- **Error Resilience**: Automatic retry logic (up to 3 attempts)
- **Quality Assurance**: Automated testing and linting for changed files
- **Progress Tracking**: Complete activity log in session context
- **Traceability**: Every decision, test run, and phase logged

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
