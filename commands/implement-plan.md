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

**Key Activities**: Parse execution waves → Dispatch parallel subagents per wave → Integration checks → Final verification

**Parallel Strategy**: Subtasks within the same wave have no dependencies and are dispatched as parallel subagents. Each subagent follows full TDD (RED → GREEN → REFACTOR) independently.

## Context File Integration
**MANDATORY**: Always create session context files for tracking.

**Context File Creation**:
1. Generate session ID: `implement_YYYYMMDD_HHMMSS` (use today's date from `<env>` + current time estimate, e.g., `implement_20251129_143022`)
2. Create `tasks/session_context_<session_id>.md` immediately
3. Initialize with objective, subtask tracking, TDD phase tracking

> **Note**: Generate the session ID directly from the date shown in `<env>` section. No shell command needed.

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
- **Parse `## Execution Waves` section** — extract wave structure and subtask assignments
- Verify actionable subtasks exist
- (update context: current state)

**2. Create Session Context** (Write tool)
- Generate session ID: `implement_YYYYMMDD_HHMMSS` (from `<env>` date)
- Create `tasks/session_context_{{session_id}}.md`
- Initialize: meta info, objective, wave tracking, subtask tracking, TDD phase tracking
- (update context: current state)

### Implementation Phase (Wave-Based Parallel Dispatch)

**For each execution wave** (Wave 1, Wave 2, ... Wave N):

**3. Dispatch Parallel Subagents**

For each subtask in the current wave, dispatch a `Task` subagent **in parallel** (all in a single message):

```javascript
// Example: Wave 1 has Subtask 1 and Subtask 3
Task({
  subagent_type: "general-purpose",
  description: "Implement Subtask 1: [Title]",
  prompt: `You are implementing a single subtask using TDD methodology.

## Subtask
[Full subtask text from plan: title, description, acceptance criteria, file references]

## Instructions
1. **RED Phase**: Write failing tests for the behavior described above
   - Run tests: \`just test path/to/test-file.spec.ts\`
   - Verify tests FAIL (expected — no implementation yet)

2. **GREEN Phase**: Write minimal code to make tests pass
   - Run tests again — verify they PASS
   - If failures: debug and fix (up to 3 retries)

3. **REFACTOR Phase**: Improve code quality
   - Remove duplication, improve readability
   - Run tests — verify still passing
   - Run: \`just lint <modified-files>\`

## Constraints
- Only modify files relevant to THIS subtask
- Do NOT modify files outside your scope
- Follow existing code patterns and conventions

## Return
Report: files changed, tests written, test results, lint status, summary of implementation`
})
```

**Dispatch ALL subtasks in the wave as parallel `Task` calls in a single message.**

**4. Integration Check (After Each Wave)**
- Wait for all subagents in the wave to complete
- Review each subagent's report (files changed, test results)
- **Conflict detection**: Check if any subagents modified the same files
  - If conflicts found: resolve manually before proceeding
- **Integration test**: Run tests for ALL files changed in this wave together
  - `just test <all-changed-test-files-from-this-wave>`
- **Lint check**: `just lint <all-changed-files-from-this-wave>`
- (update context: wave results, integration test results, blockers if any)

**5. Complete Wave**
- Mark all subtasks in wave as complete in context
- Update current state to next wave
- (update context: current state, agent activity log)

**Repeat steps 3-5 for each subsequent wave.**

### Sequential Fallback

If the plan has **no `## Execution Waves` section** or all subtasks are linearly dependent (one subtask per wave), fall back to sequential execution:

For each subtask (in order):
- **RED Phase**: Write failing tests, run related tests only
- **GREEN Phase**: Implement minimal code, retry up to 3 times on failure
- **REFACTOR Phase**: Improve quality, run tests + lint
- Mark subtask complete, move to next

### Completion Phase

**6. Final Verification**
- Run tests for ALL changed files across all waves
- Run linting for ALL changed files
- Verify all subtasks complete
- (update context: current state)

**7. Finalize Session**
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
- ✅ All waves executed (all subtasks processed)
- ✅ Integration check passed after each wave (no file conflicts, tests passing)
- ✅ Final verification: all tests pass across all waves
- ✅ Linting clean for all changed files
- ✅ Session context updated with final status

**Testing Strategy**: Each subagent runs only its related tests during TDD. Integration tests run between waves. Full test suite runs at final verification.

## Examples

### Basic Usage (Parallel Waves)

```bash
# Implement a pre-planned task with execution waves
implement-plan tasks/user_authentication_oauth2_20251010_143022_12345.md

# Expected output:
# Creating implementation session...
# Session context: tasks/session_context_implement_20251010_150530_98765.md
# Parsed execution waves: 3 waves, 5 subtasks
#
# === Wave 1 (2 subtasks in parallel) ===
# Dispatching parallel subagents...
#   Subtask 1: Create User model with OAuth fields → subagent dispatched
#   Subtask 3: Set up OAuth provider config → subagent dispatched
# Waiting for Wave 1 subagents...
#   Subtask 1 complete ✓ (3 tests, all passing, lint clean)
#   Subtask 3 complete ✓ (2 tests, all passing, lint clean)
# Integration check: 5/5 tests passing, no file conflicts
#
# === Wave 2 (2 subtasks in parallel) ===
# Dispatching parallel subagents...
#   Subtask 2: Implement OAuth callback handlers → subagent dispatched
#   Subtask 4: Add session management → subagent dispatched
# Waiting for Wave 2 subagents...
#   Subtask 2 complete ✓ (4 tests, all passing, lint clean)
#   Subtask 4 complete ✓ (3 tests, all passing, lint clean)
# Integration check: 12/12 tests passing, no file conflicts
#
# === Wave 3 (1 subtask) ===
#   Subtask 5: Integration tests for full OAuth flow
#   Complete ✓ (6 tests, all passing, lint clean)
#
# Final verification: 18/18 tests passing, lint clean
# Implementation complete!
#   Total subtasks: 5 | Waves: 3 | Failed: 0
```

### Sequential Fallback (No Waves)

```bash
# Plan without execution waves — falls back to sequential
implement-plan tasks/simple_feature_20251010_120000_11111.md

# Expected output:
# No execution waves found — using sequential execution
#
# Implementing subtask 1/3: [Title]
#   RED → GREEN → REFACTOR ✓
# Implementing subtask 2/3: [Title]
#   RED → GREEN → REFACTOR ✓
# Implementing subtask 3/3: [Title]
#   RED → GREEN → REFACTOR ✓
#
# Final verification: all tests passing, lint clean
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
- **Session Context**: Auto-generated at `tasks/session_context_implement_<YYYYMMDD_HHMMSS>.md`

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

- **Wave-based parallel dispatch**: Independent subtasks run simultaneously as parallel subagents
- **Automated TDD per subagent**: Each subagent follows strict RED-GREEN-REFACTOR
- **Integration checks between waves**: Tests and conflict detection after each parallel batch
- **Graceful sequential fallback**: Plans without execution waves degrade to sequential execution
- **Efficient Testing**: Run only tests related to changes (no full test suite runs)
- **Error Resilience**: Automatic retry logic (up to 3 attempts per subagent)
- **Quality Assurance**: Automated testing and linting for changed files
- **Progress Tracking**: Complete activity log with wave-level tracking in session context
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
