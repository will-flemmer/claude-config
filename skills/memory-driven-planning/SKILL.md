---
name: memory-driven-planning
description: Use when planning features or making architectural decisions - queries persistent memory for relevant past context, patterns, and failures, then synthesizes findings into actionable planning guidance to avoid repeated mistakes and leverage proven approaches
---

# Memory-Driven Planning

## Overview

Before planning any task, query persistent memory for relevant historical context. Synthesize findings to inform better decisions, avoid past failures, and leverage proven patterns.

**Core principle:** Learn from history before planning the future. Query memory, synthesize findings, apply insights.

## When to Use

Query memory before:
- Planning new features or major changes
- Making architectural decisions
- Implementing critical systems (auth, payments, security)
- Complex debugging or testing strategies
- First task in a new session

**Skip memory when:**
- Relevant context already in current conversation
- Simple fixes (typos, formatting, one-liners)
- Quick questions or exploration
- User explicitly said "ignore past approaches" or "fresh start"

## Memory Query Strategy

### Step 1: Identify What to Query

Based on task type, determine query categories:

**For feature development:**
- Similar past implementations
- Architectural patterns in that domain
- Technology-specific patterns
- Failed approaches in that area

**For bug fixing:**
- Similar bugs and root causes
- Component-specific issues
- Common failure patterns
- Testing gaps that led to bugs

**For testing:**
- Testing patterns for technology/framework
- Mocking strategies
- Edge cases previously missed
- Testing anti-patterns to avoid

**For architecture/design:**
- Project architecture entity
- Design patterns in use
- Technology choices and rationale
- Constraints and trade-offs

### Step 2: Execute Parallel Queries

**CRITICAL:** Execute all memory queries in parallel (single message, multiple MCP calls) for efficiency.

**Query pattern:**
```javascript
// Parallel memory queries (5-8x faster than sequential)
const [similar, architecture, patterns, failures] = await Promise.all([
  mcp__memory__search_nodes({
    query: "[domain/feature] implementation"
  }),
  mcp__memory__open_nodes({
    names: ["ProjectArchitecture", "[Project]:ProjectArchitecture"]
  }),
  mcp__memory__search_nodes({
    query: "[technology] patterns"
  }),
  mcp__memory__search_nodes({
    query: "[context] failed approach"
  })
]);
```

**Example for OAuth implementation:**
```javascript
const [authImpls, archConstraints, oauthPatterns, authFailures] = await Promise.all([
  mcp__memory__search_nodes({ query: "authentication implementation" }),
  mcp__memory__open_nodes({ names: ["ProjectArchitecture"] }),
  mcp__memory__search_nodes({ query: "OAuth patterns" }),
  mcp__memory__search_nodes({ query: "authentication failed approach" })
]);
```

### Step 3: Review Results

**For each query result:**
- Read entity observations
- Identify relevant vs irrelevant information
- Note specific constraints or decisions
- Flag critical failures to avoid

**Filters to apply:**
- **Recency:** Newer observations often more relevant
- **Specificity:** Specific to current domain/technology
- **Criticality:** Security, data integrity, performance critical items
- **Applicability:** Does it apply to current task?

### Step 4: Synthesize Findings

**Create synthesis in session context file:**

```markdown
## Relevant Past Context

### Similar Past Work
- [Entity name]: [Key observations relevant to current task]
- [Another entity]: [Relevant insights]

### Architectural Constraints
From ProjectArchitecture:
- [Constraint 1]: [Description and rationale]
- [Constraint 2]: [How it affects current task]

### Proven Patterns to Follow
- [Pattern name]: [What it does, when to use it]
- [Pattern name]: [Implementation notes]

### Failed Approaches to Avoid
- [FailedApproach entity]: [What failed, why, what to do instead]
- [Another failure]: [Lesson learned]

### Key Decisions
- [Decision 1]: [What was decided, why, trade-offs]
- [Decision 2]: [Context and implications]
```

### Step 5: Apply Insights to Planning

**Use synthesized findings to:**

1. **Inform architectural decisions**
   - Follow established patterns
   - Respect documented constraints
   - Avoid past architectural mistakes

2. **Guide implementation approach**
   - Use proven patterns from memory
   - Apply lessons from failures
   - Consider trade-offs from past decisions

3. **Identify risks early**
   - Note areas where past bugs occurred
   - Flag approaches that failed before
   - Plan mitigations for known issues

4. **Improve task breakdown**
   - Include subtasks that address past failures
   - Add testing for edge cases previously missed
   - Plan for constraints from architecture

## Query Patterns by Task Type

### Feature Development Queries

```javascript
const featureContext = await Promise.all([
  // Find similar features implemented before
  mcp__memory__search_nodes({
    query: "[feature type] implementation"
  }),

  // Get architectural foundation
  mcp__memory__open_nodes({
    names: ["ProjectArchitecture"]
  }),

  // Find patterns for this domain
  mcp__memory__search_nodes({
    query: "[domain] patterns"
  }),

  // Check what didn't work
  mcp__memory__search_nodes({
    query: "[feature area] failed approach"
  }),

  // Get testing strategies
  mcp__memory__search_nodes({
    query: "[technology] testing patterns"
  })
]);
```

### Bug Investigation Queries

```javascript
const bugContext = await Promise.all([
  // Similar bugs in this component
  mcp__memory__search_nodes({
    query: "[component] bug"
  }),

  // Root causes related to symptoms
  mcp__memory__search_nodes({
    query: "[symptom] root cause"
  }),

  // Known issues in this area
  mcp__memory__search_nodes({
    query: "[area] failed approach"
  }),

  // Component architecture
  mcp__memory__search_nodes({
    query: "[component] architecture"
  })
]);
```

### Testing Strategy Queries

```javascript
const testingContext = await Promise.all([
  // Testing patterns for framework
  mcp__memory__search_nodes({
    query: "[framework] testing patterns"
  }),

  // Mocking strategies
  mcp__memory__search_nodes({
    query: "[technology] mocking"
  }),

  // Edge cases to consider
  mcp__memory__search_nodes({
    query: "testing edge cases"
  }),

  // Testing mistakes to avoid
  mcp__memory__search_nodes({
    query: "testing failed approach"
  })
]);
```

### Architecture Decision Queries

```javascript
const archContext = await Promise.all([
  // Current architecture state
  mcp__memory__open_nodes({
    names: ["ProjectArchitecture"]
  }),

  // Domain architecture patterns
  mcp__memory__search_nodes({
    query: "[domain] architecture"
  }),

  // Technology patterns
  mcp__memory__search_nodes({
    query: "[technology] patterns"
  }),

  // Past architectural failures
  mcp__memory__search_nodes({
    query: "[approach] failed approach"
  }),

  // Tool evaluations
  mcp__memory__search_nodes({
    query: "[technology category] tool evaluation"
  })
]);
```

## Synthesis Techniques

### Technique 1: Pattern Extraction

From memory results, extract reusable patterns:

```markdown
### Pattern: JWT Authentication with Refresh Tokens

**Source:** Pattern:JWTAuth entity

**What:** Stateless authentication using JWT with short-lived access tokens and long-lived refresh tokens

**When to use:**
- Microservices architecture
- Need horizontal scaling
- Stateless API design

**How to implement:**
1. Access token: 15-min expiry, contains user claims
2. Refresh token: 7-day expiry, stored in httpOnly cookie
3. Refresh endpoint: Validates refresh token, issues new access token

**Gotchas:**
- Don't trust client time for expiry validation
- Use server timestamp in JWT payload
- Include token version for invalidation support
```

### Technique 2: Failure Analysis

From FailedApproach entities, create avoidance guidance:

```markdown
### Failed Approach: Redis Session Caching

**What was tried:** Cache entire user session state in Redis

**Why it failed:**
- Session state too large (>5MB per user)
- Network bottleneck retrieving large blobs
- Slower than no caching at all

**Symptoms:**
- High Redis network I/O
- Increased latency on session reads
- Memory pressure in Redis

**What to do instead:**
- Cache specific expensive queries only
- Keep cached values small (<100KB)
- Use 60-second TTL for API responses
- Don't cache entire state objects

**When this applies:** Any session state or caching strategy
```

### Technique 3: Constraint Mapping

From ProjectArchitecture, extract constraints:

```markdown
### Architectural Constraints

**From ProjectArchitecture:**

1. **Microservices Communication**
   - Must use gRPC for service-to-service
   - REST only for external API
   - Rationale: Performance and type safety
   - Impact: Auth service must expose gRPC endpoints

2. **Database Access**
   - No cross-service database queries
   - Each service owns its schema
   - Rationale: Loose coupling, independent deployment
   - Impact: Need User service API for user data

3. **Authentication Flow**
   - JWT tokens with 15-min expiry
   - Refresh tokens in httpOnly cookies
   - Rationale: Security and UX balance
   - Impact: Must implement refresh endpoint
```

### Technique 4: Decision Inheritance

From past decisions, inform new ones:

```markdown
### Decision: OAuth Provider Selection

**Past decision (from memory):**
- Chose OAuth2 with PKCE flow
- Support GitHub and Google initially
- Rationale: Most common for developer tools
- Trade-off: More complex than basic auth, better security

**Applies to current task:**
- Follow same OAuth2 + PKCE pattern
- Add new providers (Twitter, Microsoft) using same flow
- Reuse existing provider abstraction
- Maintain consistent UX across providers

**New considerations:**
- Microsoft uses different scopes syntax
- Twitter rate limits are stricter
- Need provider-specific configuration
```

## Silent Application

**IMPORTANT:** Apply memory findings silently unless particularly relevant.

**Don't announce:**
- "I queried memory and found..."
- "According to past work..."
- "Memory shows that..."

**Just apply:**
- Use patterns naturally in plan
- Avoid failures without mentioning them
- Follow constraints as if they're obvious
- Incorporate insights seamlessly

**Only mention when:**
- Finding directly answers user's question
- Critical failure prevented by memory
- User needs to know about past decision
- Conflict with user's stated approach

## If Memory Not Initialized

**Graceful degradation:**
1. Attempt memory query
2. If fails (memory not initialized):
   - Continue without memory
   - Don't announce failure
   - Proceed with planning based on current context
3. Optionally suggest: "Consider running /init-memory to enable persistent memory"

**Never:**
- Block planning on memory availability
- Make memory required for basic operation
- Announce "memory not available" prominently

## Integration with Commands

### plan-task Command

**Automatically queries memory:**
1. Before analyzing codebase
2. Search for similar tasks
3. Open ProjectArchitecture entity
4. Find relevant patterns
5. Check for failed approaches
6. Synthesize into "Relevant Past Context" section
7. Apply findings to task breakdown

**Memory enriches planning with:**
- Proven patterns to follow
- Architectural constraints to respect
- Failed approaches to avoid
- Similar past implementations for reference

### implement-plan Command

**Uses memory during implementation:**
1. Read memory context from planning phase
2. Apply patterns during implementation
3. Avoid documented failures
4. After successful implementation:
   - Store new patterns discovered
   - Document architectural decisions
   - Record bugs fixed
   - Note failed approaches tried

**Memory creates learning loop:**
- Plan → Query memory → Implement → Store learnings → Future plans benefit

### update-tests Command

**Queries testing-specific memory:**
1. Before writing tests
2. Search for testing patterns
3. Find mocking strategies
4. Check edge cases previously missed
5. Avoid testing anti-patterns
6. Apply findings to test creation

## Performance Considerations

**Query efficiency:**
- Memory queries add ~1-2 seconds
- Parallel queries (4+ searches) = same time as 1 search
- Most sessions query once at start, reuse context
- Checking existing conversation context first avoids query

**Context reuse:**
- First question in session: Query memory
- Subsequent questions: Reuse loaded context
- Only re-query if switching domains/topics

**Token efficiency:**
- Store synthesis in session context once
- Reference throughout session
- Don't repeat memory findings in every response

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Querying memory for every question | Check if context already in conversation first |
| Sequential memory queries | Use parallel queries (Promise.all) |
| Dumping raw memory results | Synthesize into actionable guidance |
| Querying memory for trivial tasks | Skip memory for simple fixes |
| Not applying findings | Use patterns, avoid failures, respect constraints |
| Announcing every memory query | Apply silently unless particularly relevant |
| Blocking on memory availability | Gracefully degrade if memory not initialized |

## Quality Standards

**Good memory synthesis:**
- Extracts only relevant observations
- Groups by category (patterns, constraints, failures)
- Provides specific, actionable guidance
- Includes examples or code snippets
- Notes applicability to current task

**Good application:**
- Uses patterns naturally in plan
- Respects architectural constraints
- Avoids documented failures
- Learns from past decisions
- Improves task breakdown quality

## Real-World Impact

**With memory-driven planning:**
- Avoid repeating past mistakes (failed approaches documented)
- Follow established patterns (consistency across codebase)
- Respect architectural decisions (alignment with project direction)
- Faster planning (leverage proven solutions)
- Better quality (informed by historical context)

**Without memory-driven planning:**
- Repeat failed experiments
- Violate architectural constraints
- Invent patterns that already exist
- Miss edge cases caught before
- Slower planning (research from scratch)

## Quick Reference

### Memory Query Checklist

Before planning:
- [ ] Determine task type (feature/bug/testing/architecture)
- [ ] Identify relevant query categories
- [ ] Execute queries in parallel (Promise.all)
- [ ] Review results for relevance
- [ ] Synthesize into session context
- [ ] Apply insights to planning

### Synthesis Template

```markdown
## Relevant Past Context

### Similar Past Work
- [Entities and key observations]

### Architectural Constraints
- [Constraints affecting current task]

### Proven Patterns to Follow
- [Patterns applicable to task]

### Failed Approaches to Avoid
- [Failures and lessons learned]

### Key Decisions
- [Past decisions informing current work]
```

### Application Checklist

During planning:
- [ ] Use patterns from memory naturally
- [ ] Respect architectural constraints
- [ ] Avoid documented failed approaches
- [ ] Learn from past decisions
- [ ] Improve task breakdown with insights
- [ ] Apply silently unless particularly relevant

## Related Skills

- **persistent-context** - Foundation for memory storage and retrieval
- **query-decision** - Deciding when to query memory (upstream skill)
- **context-file-management** - Where to store synthesized findings
- **agent-coordination** - Passing memory context to agents
