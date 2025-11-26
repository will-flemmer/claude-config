# plan-task

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Analyze tasks and create actionable implementation plans

---

## 🚨 MANDATORY SKILL INVOCATIONS - DO THESE FIRST 🚨

**BEFORE doing ANYTHING else, invoke these skills:**

1. **First request in session?**
   ```
   Skill({ skill: "query-decision" })
   ```
   ↳ Automatically decides if memory query is needed

2. **About to read/search 2+ files?**
   ```
   Skill({ skill: "parallel-execution-patterns" })
   ```
   ↳ Executes reads/searches in parallel (5-8x faster)

3. **Planning a feature?**
   ```
   Skill({ skill: "memory-driven-planning" })
   ```
   ↳ Queries memory for patterns, failures, decisions

**⚠️ STOP - Did you invoke the skills above? If not, DO IT NOW before continuing!**

---

## What This Does
1. **Analyzes** requirements and existing codebase
2. **Discovers & verifies** available APIs before suggesting their use
3. **Validates** technical assumptions using Explore agent
4. **Breaks down** work into 3-7 subtasks with complexity estimates
5. **Identifies** dependencies and execution order
6. **Provides** implementation guidance grounded in verified code

## Key Features
- **API verification** - every suggested API has file:line reference or marked "needs creation"
- **Explore agent validation** - technical assumptions verified before finalizing plan
- **Parallel execution** for 5-8x faster codebase analysis
- **Context integration** for multi-agent workflows
- **Complexity scoring** (Simple/Medium/Complex)
- **Dependency mapping** for optimal execution sequencing

**Configuration & Templates**: `~/.claude/commands/plan-task/`

## Usage

```bash
plan-task [OPTIONS] <task_description>
plan-task [OPTIONS] --interactive
```

## Parallel Execution Strategy

**CRITICAL**: Use parallel tool calls for 5-8x performance improvement.

### Pattern
Execute multiple tool calls in a single message for independent operations.

### When to Use
- **File discovery + reading**: Find files, then read relevant ones
- **Multi-file analysis**: Read related files simultaneously
- **Independent operations**: Any operations without dependencies

### Performance Example
```
Sequential:  5 files × 8 sec = 40 seconds
Parallel:    5 files in 1 call = 8 seconds (5x faster)
```

### Anti-Pattern (DO NOT DO)
Execute operations sequentially when they could be parallelized.

## Clarification Questions

**CRITICAL**: Always consider asking clarifying questions before starting analysis. Better to ask upfront than make wrong assumptions.

**When to Ask** (ask if ANY of these apply):
- Task description < 25 words
- Missing technical constraints or requirements
- Unclear boundaries or scope
- No mention of testing or quality requirements
- Integration points not specified
- Performance/scalability needs unclear
- Success criteria not defined
- ANY ambiguity about implementation approach

**Question Categories** (ask 3-5 targeted questions):
1. **Objective**: What problem are we solving? What's the desired outcome?
2. **Scope**: What's included/excluded? What's the boundary?
3. **Constraints**: Required technologies? Performance needs? Integration points?
4. **Quality**: Testing requirements? Documentation needs?
5. **Success**: How do we know when it's done? What are acceptance criteria?

**Default Behavior**: When in doubt, ASK. It's always better to clarify than to plan incorrectly.

The answers enrich the task context and ensure accurate planning.

## Options

- `-h, --help`: Show detailed help message with examples
- `-i, --interactive`: Interactive mode for complex task planning with detailed requirements gathering
- `--session-id <id>`: Use a specific session ID (default: auto-generated)

## Context Management

**MANDATORY**: Always create session context files for tracking.

**Context File Creation**:
1. Generate unique session ID: `plan_$(date +%Y%m%d_%H%M%S)_$RANDOM`
2. Create `tasks/session_context_<session_id>.md` immediately
3. Create `tasks/<descriptive-name>_<session_id>.md` for task plan

**Context Updates Required**:
1. **After codebase discovery**: Add discovered architecture to Technical Decisions
2. **After complexity analysis**: Update with findings and patterns
3. **Before completion**: Final summary with:
   - Current State: "Planning completed - [brief summary]"
   - Technical Decisions: Architecture choices, patterns
   - Activity Log: Complete analysis steps

## Execution Workflow

### 1. Context & Requirements Analysis
- **Create session context files** (session_context and task_doc)
- **Analyze task**: Extract objective, constraints, technologies
- **Ask clarifying questions**: 3-5 targeted questions (see Clarification Questions section)

### 2. Query Development Memory (Parallel Execution - READ from memory)
**IMPORTANT**: Query persistent memory for relevant past context before planning.

**Query in parallel** (single message with multiple MCP memory calls):
```javascript
// Search for similar past tasks
const similarTasks = await mcp__memory__search_nodes({
  query: "[task description keywords]"
});

// Get architectural constraints
const architecture = await mcp__memory__open_nodes({
  names: ["ProjectArchitecture"]
});

// Find relevant patterns
const patterns = await mcp__memory__search_nodes({
  query: "[technology/domain] patterns"
});

// Check for past failures
const failures = await mcp__memory__search_nodes({
  query: "[context] failed approach"
});
```

**Add to session context**:
Create "Relevant Past Context" section with:
- Similar tasks and their outcomes
- Architectural decisions to respect
- Proven patterns to follow
- Failed approaches to avoid

**If memory not initialized**: Skip this step silently (first-time usage is okay).

### 3. Codebase Discovery (Use Parallel Execution)
**Find relevant files**:
```bash
find . -type f -name "*.ts" -o -name "*.js" | head -20
grep -r "pattern" --include="*.ts"
```

**Read key files in parallel** (single message with multiple Read calls):
- README.md, ARCHITECTURE.md, CONTRIBUTING.md, package.json

**Update context**: Add discovered architecture to `Technical Decisions`

**Then proceed to Step 3.5** to store discovered patterns to memory.

### 3.5. Store Discovered Patterns to Memory
**IMPORTANT**: After codebase discovery, store valuable patterns to persistent memory for future planning sessions.

**Check for duplicates first**:
```javascript
// Query memory to avoid duplicates
const existingPatterns = await mcp__memory__search_nodes({
  query: "[pattern name or technology]"
});
```

**Store NEW insights only** (execute in parallel):

**Code Patterns Discovered**:
```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Pattern:[Technology]:[PatternName]",
    entityType: "Pattern",
    observations: [
      "Pattern: [description of pattern]",
      "Found in: [file paths]",
      "Used for: [purpose]",
      "Example: [brief code snippet or reference]",
      "Date: YYYY-MM-DD"
    ]
  }]
});

// Link to pattern registry
await mcp__memory__create_relations({
  relations: [{
    from: "Pattern:[Technology]:[PatternName]",
    to: "CodePatterns",
    relationType: "stored_in"
  }]
});
```

**Architecture Insights**:
```javascript
await mcp__memory__add_observations({
  observations: [{
    entityName: "ProjectArchitecture",
    contents: [
      "Module organization: [discovered structure]",
      "Layer separation: [how layers are organized]",
      "Design pattern: [architectural patterns found]",
      "Date: YYYY-MM-DD"
    ]
  }]
});
```

**Testing Patterns**:
```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Pattern:Testing:[Framework]:[Pattern]",
    entityType: "Pattern",
    observations: [
      "Framework: [Jest/Vitest/etc]",
      "Pattern: [testing approach]",
      "Location: [test file conventions]",
      "Mocking: [mocking strategy]",
      "Example: [reference to test file]",
      "Date: YYYY-MM-DD"
    ]
  }]
});
```

**Integration Patterns**:
```javascript
await mcp__memory__create_entities({
  entities: [{
    name: "Pattern:Integration:[ServiceName]",
    entityType: "Pattern",
    observations: [
      "Service: [external service name]",
      "Integration: [how it's integrated]",
      "Error handling: [approach]",
      "Location: [file paths]",
      "Pattern: [specific pattern used]",
      "Date: YYYY-MM-DD"
    ]
  }]
});
```

**When to Store**:
- ✅ NEW patterns not already in memory
- ✅ Reusable architectural insights
- ✅ Non-obvious design decisions
- ✅ Testing conventions and strategies
- ✅ Integration approaches

**When NOT to Store**:
- ❌ Duplicates (already in memory)
- ❌ Task-specific implementation details
- ❌ Temporary planning notes
- ❌ Trivial or obvious patterns

**Update session context** after storage:
```markdown
## Memory Storage
- Stored [count] code patterns
- Stored [count] architecture insights
- Stored [count] testing patterns
- Stored [count] integration patterns
```

**If memory not initialized**: Silently skip this step (optional feature).

### 4. API & Interface Discovery

**CRITICAL**: Before suggesting ANY API usage, verify it actually exists. Plans that suggest non-existent APIs are worse than no plan.

**For each module/service you plan to use:**

1. **Read the actual source file** - don't assume based on naming
2. **List exported functions/classes** with their signatures
3. **Note parameters and return types**
4. **Flag anything that needs to be created**

**Discovery approach** (execute in parallel):
```javascript
// Find service/module files
Glob({ pattern: "**/services/**/*.ts" })
Glob({ pattern: "**/lib/**/*.ts" })
Glob({ pattern: "**/utils/**/*.ts" })

// Search for specific functionality
Grep({ pattern: "export (function|class|const)", path: "src/" })
```

**Then read and document available APIs:**
```markdown
## Verified Available APIs

### src/services/UserService.ts
- `getUserById(id: string): Promise<User>` ✅ EXISTS (line 45)
- `updateUser(id: string, data: Partial<User>): Promise<User>` ✅ EXISTS (line 78)
- `authenticate()` ❌ DOES NOT EXIST - needs creation

### src/utils/validation.ts
- `validateEmail(email: string): boolean` ✅ EXISTS (line 12)
- `validatePhone()` ❌ DOES NOT EXIST - needs creation
```

**Rules:**
- ✅ Every API you suggest MUST have a file:line reference OR be marked "needs creation"
- ✅ Every import path MUST be verified to exist
- ❌ NEVER suggest methods based on assumed naming conventions
- ❌ NEVER assume a utility exists just because it would be convenient

### 5. Validation Phase (Use Explore Agent)

**MANDATORY**: After drafting implementation approach, validate technical assumptions.

**Use Explore agent** for efficient validation without bloating main context:
```javascript
Task({
  subagent_type: "Explore",
  prompt: `Verify these APIs/modules exist in the codebase. Be thorough - check all naming variations.

  APIs to verify:
  1. [API or function name]
  2. [Import path]
  3. [Class or module]

  For each item report:
  - EXISTS: file path + line number + actual signature
  - MISSING: not found after thorough search (checked: [locations searched])

  Also check for similar existing implementations that could be extended.`
})
```

**Update plan based on validation findings:**
1. **Remove** suggestions for non-existent APIs
2. **Add subtasks** for any APIs that need to be created
3. **Adjust complexity** estimates (creating new APIs adds work)
4. **Link to similar code** that can be used as reference

**Document validation results:**
```markdown
## Validation Results

### Verified to USE (exists)
| API | Location | Signature |
|-----|----------|-----------|
| `getUserById` | `src/services/UserService.ts:45` | `(id: string) => Promise<User>` |

### Must CREATE (verified missing)
| API | Suggested Location | Proposed Signature | Added as Subtask |
|-----|-------------------|-------------------|------------------|
| `authenticate` | `src/services/AuthService.ts` | `(creds: Credentials) => Promise<Token>` | Subtask 3 |

### Blocked/Unclear (cannot verify)
| Assumption | Blocker | Resolution Needed |
|------------|---------|-------------------|
| Redis cache available | No redis config found | Ask user about infrastructure |
```

### 6-8. Analysis Phase (Use Sequential Thinking)

**Use sequential thinking for task decomposition and analysis.**

This ensures thorough reasoning about how to break down the work.

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Analyzing task: [description]. I need to decompose this into implementable subtasks. Let me consider the logical components, dependencies, and risks.",
  thoughtNumber: 1,
  totalThoughts: 8,
  nextThoughtNeeded: true
})
```

**Required thinking steps:**

**Step 1**: Component Identification
- What are the logical components of this task?
- What functionality needs to be built?
- What are the boundaries of each component?

**Step 2**: Decomposition Strategy
- What's the simplest way to break this down?
- Are subtasks right-sized? (not too big, not too small)
- Is each subtask independently testable?

**Step 3**: Complexity Assessment
- Simple: Single file, < 50 LOC, no dependencies
- Medium: Multiple files, < 200 LOC, few dependencies
- Complex: Many files, > 200 LOC, or intricate logic
- Justify each complexity rating

**Step 4**: Dependency Analysis
- Which subtasks must complete first?
- Which can run in parallel?
- External dependencies (APIs, libraries)?
- Are there hidden dependencies?

**Step 5**: Risk Identification
- What could go wrong?
- Which parts are most uncertain?
- Where might estimates be wrong?
- What needs user clarification?

**Step 6**: Execution Order
- Optimal sequence for implementation
- Which tasks unblock others?
- Where are the critical paths?

**Step 7**: Testing Strategy
- How will each subtask be tested?
- What test patterns apply?
- Are there integration testing needs?

**Step 8**: Final Review
- Is the decomposition complete?
- Are all acceptance criteria clear?
- Is the plan implementable?
- Any revisions needed?

**Output from sequential thinking:**

**Subtasks** (3-7 subtasks, each with):
- Clear objective
- Acceptance criteria
- Estimated complexity (with justification)
- Dependencies (if any)

**Execution order**: Optimal sequence with rationale

**Implementation notes**:
- Architecture decisions and rationale
- Testing strategy
- Risk areas requiring attention

**Update context before completion**:
```markdown
Current State: Planning completed - [brief summary]
Technical Decisions: [key architectural choices]
Activity Log: [add entry with findings]
```

## Task File Structure

The command generates two interconnected files:

### 1. Session Context File (`tasks/session_context_<session_id>.md`)
Tracks the workflow state and execution progress:
- Objective and workflow type
- Current state
- Clarifications and Q&A
- Discovered context sections
- Execution activity log

### 2. Task Documentation File (`tasks/<descriptive-name>_<session_id>.md`)
Contains the actual task breakdown and plan:
- Task objective and description
- Task breakdown and subtasks
- Implementation steps
- **Existing code patterns and examples** (similar tests, implementations, patterns)
- Success criteria
- Links to session context

## Examples

### Basic Usage

```bash
# Simple task with clear description
plan-task "Implement user authentication with OAuth2 support for GitHub and Google providers"

# Expected:
# 1. Creates session context file
# 2. Reads README.md, ARCHITECTURE.md, AI_CONTRIBUTING.md IN PARALLEL to understand project structure
# 3. Searches IN PARALLEL for similar authentication tests and OAuth patterns in codebase
# 4. Generates structured task plan with subtasks and pattern links
# Output: Task plan created at tasks/user_authentication_oauth2_20251010_143022_12345.md
#   - Includes links to similar test files (e.g., src/auth/auth.spec.ts)
#   - Includes links to existing OAuth implementations
#   - Includes links to authentication utilities
```

### Interactive Mode

```bash
# Complex task needing detailed clarification
plan-task --interactive "Build a notification system"

# Expected:
# - Asks clarifying questions about scope, dependencies, technical constraints
# - Creates enriched session context with Q&A
# - Reads documentation and searches patterns IN PARALLEL
# - Generates comprehensive task breakdown
```

### Vague Task with Auto-Clarification

```bash
# Incomplete/vague task description
plan-task "Add some search features"

# Expected:
# - Detects vague description (under 20 words, contains "some")
# - Automatically asks clarifying questions:
#   * What specific search features? (keyword search, filters, facets?)
#   * Where should search be added? (which pages/components?)
#   * What content should be searchable?
#   * Any performance or scalability requirements?
# - Creates enriched context with answers
# - Executes documentation reading and pattern searches IN PARALLEL
# - Generates detailed task plan
```

## Integration with Other Commands

### Consumed By

- **implement-gh-issue**: Can read task plans to implement structured work
- **create-gh-issue**: Can convert task plans into GitHub issues
- **pr-checks**: Can validate implementation against task success criteria

### File Paths

All generated files are created in the **current project directory** (not ~/.claude/):
- Session context: `tasks/session_context_<session_id>.md`
- Task documentation: `tasks/<descriptive-name>_<session_id>.md`

**IMPORTANT**: Create files relative to the project root, NOT in ~/.claude/tasks/.

## Output Formats

### Human-Readable Output

```
✅ Task Plan Created Successfully

Session ID: plan_20251010_143022_12345
Session Context: tasks/session_context_plan_20251010_143022_12345.md
Task Plan: tasks/user_authentication_oauth2_20251010_143022_12345.md

📋 Task Summary:
- Task complexity: Medium
- Subtasks identified: 5
- Implementation steps: 12
- Estimated effort: 3-5 days

🔗 Files:
- Session Context: tasks/session_context_plan_20251010_143022_12345.md
- Task Plan: tasks/user_authentication_oauth2_20251010_143022_12345.md
```

## Requirements

### System Dependencies

- **Git**: For repository detection and working directory context
- **jq**: JSON processing for configuration
- **date**: For timestamp generation in session IDs

### Permissions

- **File System Access**: Write access to tasks/ directory
- **Task Files**: Permission to create markdown files in tasks/ directory

### Environment

- Must be run from within a git repository (or specify working directory)
- tasks/ directory must exist or be creatable
- Network connectivity not required (local operation only)

## Error Handling

- **Empty task description**: Prompts for meaningful task description
- **Missing tasks/ directory**: Creates directory automatically
- **File write failures**: Clear error messages with permission checks
- **Execution failures**: Graceful error reporting with retry suggestions

## Implementation

### File Structure

```
commands/plan-task/
├── templates/
│   ├── session_context.md      # Session context file template
│   └── task_doc.md             # Task documentation template
├── lib/                        # (Reserved for future helper scripts)
└── config.json                 # Configuration for clarification questions and templates
```


## Troubleshooting

### Common Issues

#### "tasks/ directory not found"

```bash
# Create tasks directory
mkdir -p tasks
```

#### "Session context file already exists"

```bash
# Use a different session ID or remove old file
rm tasks/session_context_<old_id>.md
```

## Quality Standards

### Input Validation

- **Non-empty descriptions**: Task description must have meaningful content
- **Character limits**: Descriptions should be between 10-1000 characters
- **Clarity checks**: Automatically triggers clarification for vague inputs

### Output Quality

- **Structured format**: Session context and task docs follow consistent templates
- **Absolute paths**: All file references use full absolute paths
- **Activity tracking**: Complete log of analysis steps in session context
- **Actionable subtasks**: Each subtask is concrete and implementable

## Execution Requirements

**MANDATORY**: This command MUST follow these execution guidelines:

### Required Steps

1. **Clarifying questions** - ask 3-5 targeted questions if ANY triggers apply (see "When to Ask" section)
2. **Context file creation** - always create session context files before starting analysis
3. **Memory querying** - query persistent memory for relevant past context (if initialized)
4. **Parallel operations** - always use parallel tool calls for independent operations (memory queries, documentation reading, pattern searches)
5. **API discovery** - verify all APIs/modules exist before suggesting their use
6. **Validation phase** - use Explore agent to validate technical assumptions
7. **Context updates** - update both session context and task documentation files with findings
8. **Pattern discovery** - include links to similar code patterns found in the codebase

### Compliance Checklist

When executing this command:

**Setup & Context**
- [ ] Clarifying questions asked if ANY "When to Ask" triggers apply
- [ ] Session context file is created with unique session ID
- [ ] Task documentation file is initialized

**Memory Integration**
- [ ] Memory system queried for relevant past context (if initialized)
- [ ] Memory queries executed IN PARALLEL (single message, multiple MCP memory calls)
- [ ] Discovered patterns stored to memory after codebase discovery (if initialized)
- [ ] Checked for duplicate patterns before storing to memory

**Discovery & Parallel Execution**
- [ ] Documentation files read IN PARALLEL (single message, multiple Read calls)
- [ ] Pattern searches executed IN PARALLEL (single message, multiple Grep/Glob calls)

**API & Technical Validation (CRITICAL)**
- [ ] Every suggested API verified with file:line reference OR marked "needs creation"
- [ ] Every import path verified to exist in codebase
- [ ] No methods suggested based on assumed naming conventions
- [ ] Explore agent used to validate technical assumptions
- [ ] Validation results documented (EXISTS/MISSING/BLOCKED tables)
- [ ] Missing APIs added as subtasks with complexity adjustment
- [ ] Blocked assumptions flagged for user resolution

**Output Quality**
- [ ] Both session context and task documentation files updated with findings
- [ ] Relevant past context from memory included in session context
- [ ] Existing code patterns and examples included in task documentation
- [ ] Session context updated with count of patterns stored to memory
- [ ] All implementation steps reference verified existing code or explicitly marked new code

This command delivers practical value for breaking down complex work into manageable, actionable components with maximum performance through parallel execution and **verified technical foundations**.
