# implement-plan

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Implement task plans using TDD methodology

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

**9. Store Implementation Knowledge**
- Store learnings to persistent memory (if memory initialized)
- Extract and record: architectural decisions, patterns, bugs fixed, optimizations
- (update context: agent activity log with "Stored knowledge to memory")

See "Memory Storage" section below for details on what to store.

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

## Memory Storage

**IMPORTANT**: After successful implementation, store learnings to persistent memory for future reference.

### What to Store

Use the MCP memory server to store implementation knowledge. Execute in parallel for efficiency.

#### 1. Architectural Decisions

Store significant design choices made during implementation:

```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Architecture:[ComponentName]",
    entityType: "Architecture",
    observations: [
      "Decision: [what was decided]",
      "Reason: [why this approach]",
      "Trade-off: [what was sacrificed]",
      "Alternative considered: [other options]",
      "Date: YYYY-MM-DD",
      "Context: [relevant background]"
    ]
  }]
});

// Link to project architecture
await mcp__memory__create_relations({
  relations: [{
    from: "Architecture:[ComponentName]",
    to: "ProjectArchitecture",
    relationType: "part_of"
  }]
});
```

#### 2. Code Patterns

Store reusable patterns created during implementation:

```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Pattern:[PatternName]",
    entityType: "Pattern",
    observations: [
      "Pattern: [pattern description] [confidence: 0.8]",
      "Used in: [file paths]",
      "Solves: [problem it addresses]",
      "Example: [code snippet or reference]",
      "Benefits: [advantages]",
      "Date: YYYY-MM-DD",
      "Status: Active",
      "Validated: 1 implementation [last: YYYY-MM-DD]"
    ]
  }]
});

// Link to pattern registry
await mcp__memory__create_relations({
  relations: [{
    from: "Pattern:[PatternName]",
    to: "CodePatterns",
    relationType: "stored_in"
  }]
});
```

**Temporal Tracking Format:**
- **confidence: X** - How confident (0.5=experimental, 0.7=tested, 0.9=proven in production, 0.95=battle-tested)
- **Status: Active|Superseded|Deprecated** - Current state of this approach
- **Validated: N implementations [last: DATE]** - Track usage success
- **Supersedes: EntityName [date: DATE]** - If replacing an older approach
- **Date: YYYY-MM-DD** - When this was created/last updated

#### 3. Bugs Fixed

If implementation fixed bugs, record root causes:

```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Bug:[Component]:[ShortDescription]",
    entityType: "Bug",
    observations: [
      "Symptom: [how it manifested]",
      "Root cause: [underlying issue]",
      "Fix: [solution applied]",
      "File: [affected files]",
      "Prevention: [how to avoid in future]",
      "Date: YYYY-MM-DD"
    ]
  }]
});

// Link to bug registry
await mcp__memory__create_relations({
  relations: [{
    from: "Bug:[Component]:[ShortDescription]",
    to: "BugRegistry",
    relationType: "tracked_in"
  }]
});
```

#### 4. Performance Optimizations

If implementation included performance work:

```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Optimization:[Area]",
    entityType: "Optimization",
    observations: [
      "Target: [what was optimized]",
      "Before: [baseline metrics]",
      "After: [improved metrics]",
      "Improvement: [percentage or absolute gain]",
      "Technique: [how it was done]",
      "Date: YYYY-MM-DD"
    ]
  }]
});

// Link to optimization log
await mcp__memory__create_relations({
  relations: [{
    from: "Optimization:[Area]",
    to: "OptimizationLog",
    relationType: "logged_in"
  }]
});
```

#### 5. Failed Approaches (Critical!)

If you tried something that didn't work, record it:

```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "FailedApproach:[Context]",
    entityType: "FailedApproach",
    observations: [
      "Attempted: [what was tried]",
      "Failed because: [reason]",
      "Symptom: [how failure manifested]",
      "Lesson: [key takeaway]",
      "Alternative that worked: [successful approach]",
      "Date: YYYY-MM-DD"
    ]
  }]
});

// Link to lessons learned
await mcp__memory__create_relations({
  relations: [{
    from: "FailedApproach:[Context]",
    to: "FailedApproaches",
    relationType: "recorded_in"
  }]
});
```

#### 6. Tool/Library Usage

If you used a new library or tool:

```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Tool:[ToolName]",
    entityType: "Tool",
    observations: [
      "Purpose: [why it was used]",
      "Chosen over: [alternatives]",
      "Reason: [selection criteria]",
      "Used in: [file paths]",
      "Pattern: [how it's used]",
      "Gotcha: [pitfalls discovered]",
      "Date: YYYY-MM-DD"
    ]
  }]
});

// Link to tool evaluation
await mcp__memory__create_relations({
  relations: [{
    from: "Tool:[ToolName]",
    to: "ToolEvaluation",
    relationType: "evaluated_in"
  }]
});
```

### When to Store

Store knowledge in step 9 (after "Finalize Session") IF:
- Implementation completed successfully (all tests pass)
- At least one of the following applies:
  - Made architectural decisions
  - Created reusable patterns
  - Fixed bugs
  - Optimized performance
  - Tried and failed approaches
  - Used new tools/libraries

### Execution Pattern

**Use parallel MCP calls** for efficiency:

```javascript
// Execute all memory operations in parallel
await Promise.all([
  mcp__memory__create_entities({ entities: [...architectureEntities] }),
  mcp__memory__create_entities({ entities: [...patternEntities] }),
  mcp__memory__create_entities({ entities: [...bugEntities] })
]);

// Then create relationships
await mcp__memory__create_relations({ relations: [...allRelations] });
```

### If Memory Not Initialized

Silently skip this step. Memory storage is optional but recommended.

To initialize memory, run: `/init-memory`

### Selective Storage

**Store only significant learnings** - not every implementation detail:
- ✅ Store: Non-obvious decisions, hard-won insights, reusable patterns
- ❌ Don't store: Trivial changes, implementation details, temporary workarounds

### Update Session Context

After storing to memory, update session context:

```markdown
## Agent Activity Log
- [timestamp] Stored implementation knowledge to memory:
  - Architectural decisions: [count]
  - Code patterns: [count]
  - Bugs fixed: [count]
  - Optimizations: [count]
  - Failed approaches: [count]
```

### Memory Feedback Loop (Learning from Outcomes)

**When implementation uses existing memory entities:**

If you queried memory during planning and successfully used patterns/decisions:

1. **Identify which entities were applied**
   - Which patterns were followed?
   - Which architectural decisions guided implementation?
   - Which failed approaches were avoided?

2. **Update confidence and validation count:**

```javascript
// If Pattern:JWTAuth was used successfully
await mcp__memory__add_observations({
  observations: [{
    entityName: "Pattern:JWTAuth",
    contents: [
      "Validated: 2 implementations [last: 2025-11-24]",  // Increment count
      "Confidence increased: 0.85 → 0.90 (successful reuse)"  // Boost confidence
    ]
  }]
});
```

3. **Mark superseded approaches:**

```javascript
// If you replaced an old pattern
await mcp__memory__add_observations({
  observations: [{
    entityName: "Pattern:SessionCookies",
    contents: [
      "Status: Superseded",
      "Superseded by: Pattern:JWTAuth [date: 2025-11-24]",
      "Reason: Better scalability and performance"
    ]
  }]
});
```

4. **Record validation failures:**

If a pattern was tried but didn't work as expected:

```javascript
await mcp__memory__add_observations({
  observations: [{
    entityName: "Pattern:ProblematicPattern",
    contents: [
      "Validation failed: 2025-11-24",
      "Issue: [what went wrong]",
      "Context: [when it fails vs works]",
      "Confidence decreased: 0.8 → 0.6"
    ]
  }]
});
```

**Benefits:**
- Memory improves over time based on real outcomes
- Confidence scores reflect actual success rate
- Obsolete approaches are marked
- Future queries get better results

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

