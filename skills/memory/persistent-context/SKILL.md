---
name: Persistent Context Management
description: Long-term memory across development sessions using MCP memory server
tags: [memory, context, learning, knowledge-management]
version: 1.0.0
created: 2025-11-19
---

# Persistent Context Management

## Purpose

Build organizational memory that persists across Claude Code sessions, enabling agents to learn from past decisions, avoid repeated mistakes, and leverage proven patterns.

## When to Use

Use this skill when:
- Starting a new task (query for relevant past context)
- Completing a task (store learnings and decisions)
- Encountering a problem (check if it was solved before)
- Making architectural decisions (record for future reference)
- Discovering patterns (store for reuse)

## What to Store

### 1. Project Architecture Decisions

**When:** After completing /plan-task or making significant architectural choices

**Store:**
```javascript
// Entity type: "Architecture"
// Entity name: "ProjectArchitecture" or "Architecture:[ComponentName]"
create_entities({
  entities: [{
    name: "Architecture:AuthSystem",
    entityType: "Architecture",
    observations: [
      "Decision: Use JWT tokens instead of sessions",
      "Reason: Stateless auth for microservices architecture",
      "Trade-off: Cannot revoke tokens immediately",
      "Mitigation: Short token expiry (15min) with refresh tokens",
      "Date: 2025-11-19"
    ]
  }]
})
```

### 2. Code Patterns

**When:** After successful implementation of a reusable pattern

**Store:**
```javascript
// Entity type: "Pattern"
// Entity name: "Pattern:[PatternName]"
create_entities({
  entities: [{
    name: "Pattern:ErrorHandling",
    entityType: "Pattern",
    observations: [
      "Pattern: Centralized error boundary with context propagation",
      "Used in: src/api/handlers/*.ts",
      "Solves: Consistent error responses across API endpoints",
      "Example: try { ... } catch (error) { throw new AppError(error, context) }",
      "Benefits: Type-safe errors, automatic logging, client-friendly messages"
    ]
  }]
})
```

### 3. Bug Fixes & Root Causes

**When:** After fixing a bug, especially recurring or tricky ones

**Store:**
```javascript
// Entity type: "Bug"
// Entity name: "Bug:[Component]:[ShortDescription]"
create_entities({
  entities: [{
    name: "Bug:Authentication:TokenExpiry",
    entityType: "Bug",
    observations: [
      "Symptom: Users logged out randomly during active sessions",
      "Root cause: Token expiry check used client time instead of server time",
      "Fix: Use server timestamp in JWT payload, validate against server time",
      "File: src/auth/middleware.ts:45",
      "Prevention: Add integration test for token expiry edge cases",
      "Date: 2025-11-19"
    ]
  }]
})
```

### 4. Performance Optimizations

**When:** After successful performance improvement

**Store:**
```javascript
// Entity type: "Optimization"
// Entity name: "Optimization:[Area]"
create_entities({
  entities: [{
    name: "Optimization:DatabaseQueries",
    entityType: "Optimization",
    observations: [
      "Target: User profile loading endpoint",
      "Before: 1200ms average response time",
      "After: 85ms average response time (14x improvement)",
      "Technique: Added compound index on (user_id, created_at)",
      "Query: SELECT * FROM posts WHERE user_id = ? ORDER BY created_at DESC LIMIT 20",
      "Lesson: Always index foreign keys used in WHERE + ORDER BY"
    ]
  }]
})
```

### 5. Failed Approaches

**When:** Something doesn't work - critical for avoiding repeated mistakes

**Store:**
```javascript
// Entity type: "FailedApproach"
// Entity name: "FailedApproach:[Context]"
create_entities({
  entities: [{
    name: "FailedApproach:CachingStrategy",
    entityType: "FailedApproach",
    observations: [
      "Attempted: Redis caching for entire user session state",
      "Failed because: Session state too large (>5MB), caused network bottlenecks",
      "Symptom: Slower than no caching at all",
      "Lesson: Cache only specific expensive queries, not entire state objects",
      "Alternative that worked: Cache individual API responses with 60s TTL",
      "Date: 2025-11-19"
    ]
  }]
})
```

### 6. Libraries & Tools Evaluation

**When:** After evaluating and choosing (or rejecting) a library/tool

**Store:**
```javascript
// Entity type: "Tool"
// Entity name: "Tool:[ToolName]"
create_entities({
  entities: [{
    name: "Tool:Zod",
    entityType: "Tool",
    observations: [
      "Purpose: Runtime type validation for API inputs",
      "Chosen over: Yup, Joi, class-validator",
      "Reason: TypeScript-first, excellent type inference, composable schemas",
      "Used in: src/api/validation/*.ts",
      "Pattern: Define schema once, derive TS types: type User = z.infer<typeof userSchema>",
      "Gotcha: Performance impact with large arrays - validate samples only"
    ]
  }]
})
```

## Usage in Workflows

### Before Planning

**Query memory for relevant context:**

```javascript
// Search for similar past tasks
const similar = await search_nodes({
  query: "authentication system implementation"
})

// Get architectural decisions
const architecture = await open_nodes({
  names: ["ProjectArchitecture", "Architecture:AuthSystem"]
})

// Find relevant patterns
const patterns = await search_nodes({
  query: "JWT authentication patterns"
})

// Check for past failures
const failures = await search_nodes({
  query: "authentication failed approach"
})
```

**Include findings in task context:**
Add a "Relevant Past Context" section to your task planning document with:
- Similar tasks and their outcomes
- Architectural constraints to respect
- Proven patterns to follow
- Failed approaches to avoid

### After Completion

**Store all learnings:**

1. **Architectural decisions made** → create_entities
2. **New patterns created** → create_entities
3. **Bugs fixed** → create_entities
4. **Performance improvements** → create_entities
5. **Failed attempts** → create_entities (don't hide failures!)

**Create relationships:**

```javascript
// Link related concepts
create_relations({
  relations: [
    {
      from: "Architecture:AuthSystem",
      to: "Pattern:JWTValidation",
      relationType: "uses"
    },
    {
      from: "Bug:Authentication:TokenExpiry",
      to: "Architecture:AuthSystem",
      relationType: "found_in"
    }
  ]
})
```

## Integration with Existing Commands

### plan-task Integration

Add this section to plan-task workflow **before** generating task plan:

```markdown
## Query Development Memory

Before planning, use MCP memory tools to search for:

1. Similar past tasks:
   - search_nodes("similar to: [task description]")
   - Review outcomes and decisions

2. Architectural constraints:
   - open_nodes(["ProjectArchitecture"])
   - Check for existing patterns to follow

3. Relevant patterns:
   - search_nodes("[technology/domain] patterns")
   - Reuse proven solutions

4. Past failures to avoid:
   - search_nodes("[context] failed approach")
   - Don't repeat mistakes

Include findings in "Relevant Context" section of task plan.
```

### implement-plan Integration

Add this section to implement-plan workflow **after successful implementation**:

```markdown
## Store Implementation Knowledge

After implementation succeeds and tests pass:

1. Store architectural decisions:
   - What: Major design choices made
   - Why: Reasoning behind decisions
   - Trade-offs: What was sacrificed

2. Store new patterns:
   - Reusable code patterns created
   - Where used
   - When to use again

3. Store bug fixes:
   - What was broken
   - Root cause
   - How it was fixed

4. Store failed attempts (if any):
   - What was tried first
   - Why it didn't work
   - What was learned

5. Create relationships:
   - Link patterns to architecture
   - Link bugs to components
   - Link optimizations to problem areas
```

## Memory Querying Best Practices

### Be Specific

❌ Bad: `search_nodes("error")`
✅ Good: `search_nodes("authentication token validation error")`

### Use Multiple Queries

Don't rely on a single query. Try:
- By technology: "React hooks patterns"
- By problem: "slow database queries"
- By component: "authentication system"

### Review and Synthesize

Don't just dump memory results - synthesize them:
1. Read all relevant memories
2. Identify applicable patterns
3. Note constraints from past decisions
4. Highlight mistakes to avoid
5. Include in planning context

## Memory Storage Best Practices

### Write for Future You

Observations should be:
- **Specific:** Include file paths, line numbers, exact errors
- **Contextual:** Explain WHY, not just WHAT
- **Actionable:** What should future you do with this info?
- **Timestamped:** When did this happen?

### Don't Store Everything

❌ Don't store:
- Trivial changes (typo fixes, formatting)
- Implementation details better suited for code comments
- Temporary workarounds (unless they became permanent!)

✅ Do store:
- Non-obvious decisions
- Hard-won lessons
- Performance breakthroughs
- Recurring bug patterns

### Update, Don't Duplicate

If information changes, update the existing entity:

```javascript
add_observations({
  observations: [{
    entityName: "Architecture:AuthSystem",
    contents: [
      "Update 2025-11-20: Migrated from JWT to session-based auth",
      "Reason: Need immediate token revocation for security compliance",
      "Migration: Deployed Redis for session storage"
    ]
  }]
})
```

## Measuring Success

Your memory system is working well when:

1. **Planning is faster** - Agents find relevant context immediately
2. **Fewer repeated mistakes** - Failed approaches are remembered
3. **Patterns emerge** - Common solutions become reusable
4. **Context persists** - New agents can understand project history
5. **Knowledge compounds** - Each task adds to collective wisdom

## Anti-Patterns to Avoid

### 1. Memory Hoarding
Storing everything creates noise. Be selective.

### 2. Vague Observations
"This didn't work" is useless. "X failed because Y, use Z instead" is gold.

### 3. Forgetting to Query
Memory only helps if you use it! Always query before planning.

### 4. No Relationships
Isolated facts are less useful. Link related concepts.

### 5. Never Updating
Projects evolve. Update memories when decisions change.

## Example Workflow

### Starting a New Feature

```javascript
// 1. Query for context
const context = await search_nodes("user authentication")
const arch = await open_nodes(["ProjectArchitecture"])
const patterns = await search_nodes("authentication patterns")

// 2. Review findings and include in planning
// 3. Execute plan-task with enriched context
// 4. Implement feature
// 5. After success, store learnings

await create_entities({
  entities: [{
    name: "Feature:TwoFactorAuth",
    entityType: "Feature",
    observations: [
      "Implemented: TOTP-based 2FA using speakeasy library",
      "Integration: Extends existing JWT auth in src/auth/",
      "Pattern: Separate 2FA middleware after initial auth",
      "Storage: Encrypted secrets in user_security table",
      "Lesson: Must handle clock skew (accept ±1 time window)"
    ]
  }]
})

await create_relations({
  relations: [{
    from: "Feature:TwoFactorAuth",
    to: "Architecture:AuthSystem",
    relationType: "extends"
  }]
})
```

## Related Skills

- **subagent-driven-development** - Execute tasks with memory context
- **verification-before-completion** - Verify memory was stored
- **unit-testing** - Test memory integration

## MCP Tools Used

This skill uses these MCP memory tools:
- `create_entities` - Store new knowledge
- `search_nodes` - Find relevant context
- `open_nodes` - Retrieve specific entities
- `add_observations` - Update existing knowledge
- `create_relations` - Link related concepts
- `delete_entities` - Remove obsolete info (rare)
- `delete_observations` - Remove outdated observations

## Impact

When used consistently:
- **5-10 min saved per task** - From faster planning with context
- **Fewer repeated mistakes** - Remember what didn't work
- **Better architectural consistency** - Follow established patterns
- **Knowledge compounds** - Gets more valuable over time
- **Onboarding accelerated** - New team members access project history

This is a **foundational skill** that makes all other workflows smarter.
