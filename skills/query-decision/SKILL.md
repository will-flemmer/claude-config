---
name: query-decision
description: Automatically decide when to query persistent memory for historical context - checks if relevant information already exists in current conversation before querying to avoid redundancy
---

# Memory Query Decision

## When to Use This Skill

**INVOKE THIS SKILL at the start of EVERY substantial user request** - before starting any work.

This skill determines whether to query persistent memory for historical context.

**How to invoke:**
```
Skill({ skill: "query-decision" })
```

## Decision Process

### Step 1: Analyze the Request

What is the user asking for?
- Feature development / implementation
- Bug fix / debugging
- Testing / test updates
- Code review / refactoring
- Architecture / design decisions
- Quick fix / trivial change
- Question / exploration

### Step 2: Check Existing Context

**CRITICAL: Check if relevant information already exists in current conversation**

Ask yourself:
- Is the relevant architectural context already in this conversation?
- Did the user just provide the context I need?
- Is this a continuation of a previous task with loaded context?

**If YES to any:** Skip memory query (avoid redundancy)

### Step 3: Assess Query Value

Based on request type and missing context:

#### ALWAYS Query Memory

1. **New substantial feature** - Need architectural patterns, similar implementations
2. **Critical system changes** - Auth, payments, security, data migrations
3. **First question in a new project session** - Load project context
4. **Explicit user request** - "considering our past approach", "based on what we learned"
5. **Complex debugging** - Need bug history, root causes, failed attempts

#### PROBABLY Query Memory

6. **Implementing patterns** - Check if pattern exists and how it's done
7. **Test writing** - Look for testing patterns, mocking strategies
8. **Refactoring** - Check architectural constraints, past refactorings
9. **Code review** - Look for common issues, review patterns
10. **Design decisions** - Need architectural context and past choices

#### SKIP Memory

11. **Context already exists** - Relevant info in current conversation
12. **Simple fixes** - Typos, formatting, one-line changes
14. **Quick questions** - "What does this function do?"
15. **User said no history** - "ignore past approaches", "fresh start"

### Step 4: Determine Query Scope

If querying, what specifically to search for:

**For feature development:**
```javascript
- search_nodes("[feature/domain] implementation")
- search_nodes("[feature] patterns")
- search_nodes("[feature] failed approach")
- open_nodes(["ProjectArchitecture", "[Project]:ProjectArchitecture"])
```

**For bug fixing:**
```javascript
- search_nodes("[component] bug")
- search_nodes("[symptom] root cause")
- search_nodes("[area] failed approach")
```

**For testing:**
```javascript
- search_nodes("[framework] testing patterns")
- search_nodes("[technology] mocking")
- search_nodes("testing edge cases")
- search_nodes("testing failed approach")
```

**For architecture/design:**
```javascript
- open_nodes(["ProjectArchitecture", "[Project]:ProjectArchitecture"])
- search_nodes("[domain] architecture")
- search_nodes("[technology] patterns")
- search_nodes("[approach] failed approach")
```

**For first project session:**
```javascript
- open_nodes(["ProjectArchitecture", "[Project]:ProjectArchitecture"])
- search_nodes("[project] patterns")
- search_nodes("[project] failed approach")
```

### Step 5: Execute Query (if needed)

**Use parallel queries for efficiency:**
```javascript
const [similar, architecture, patterns, failures] = await Promise.all([
  mcp__memory__search_nodes({ query: "[context] implementation" }),
  mcp__memory__open_nodes({ names: ["ProjectArchitecture"] }),
  mcp__memory__search_nodes({ query: "[context] patterns" }),
  mcp__memory__search_nodes({ query: "[context] failed approach" })
]);
```

**Synthesize results:**
- Extract relevant observations
- Identify applicable patterns
- Note constraints from architecture
- Flag past failures to avoid

**Apply silently:**
- Don't announce "I queried memory" unless findings are relevant
- Incorporate findings naturally into response
- If memory is empty/not initialized, proceed without it

## Examples

### Example 1: First Question in New Session

**User:** "Add OAuth2 login to the app"

**Decision:**
- ✓ First substantial request in session
- ✓ Critical feature (authentication)
- ✓ No architectural context in conversation yet

**Action:**
```javascript
// Query memory
const context = await Promise.all([
  mcp__memory__search_nodes({ query: "authentication implementation" }),
  mcp__memory__search_nodes({ query: "OAuth patterns" }),
  mcp__memory__open_nodes({ names: ["ProjectArchitecture", "API:ProjectArchitecture"] }),
  mcp__memory__search_nodes({ query: "authentication failed approach" })
]);

// Findings might include:
// - "Use JWT with 15-min expiry" (from past OAuth work)
// - "Don't trust client time for expiry" (from past bug)
// - "Pattern:JWTValidation middleware pattern" (proven approach)

// Apply: Use these findings to inform the OAuth implementation
```

### Example 2: Context Already Exists

**User:** "Add OAuth2 login to the app"
**Claude:** [Queries memory, finds JWT pattern]

**User:** "Also add refresh tokens"

**Decision:**
- ✗ Same conversation
- ✗ OAuth context already loaded from previous query
- ✗ Refresh tokens are related to JWT context we already have

**Action:** Skip query, use existing context

### Example 3: Simple Fix

**User:** "Fix typo in README: 'recieve' should be 'receive'"

**Decision:**
- ✗ Trivial change
- ✗ No architectural context needed
- ✗ No patterns or history relevant

**Action:** Skip query, make the fix

### Example 4: Testing (Auto-Query)

**User:** "Write tests for the auth service"

**Decision:**
- ✓ Testing work
- ✓ Need testing patterns
- ✓ No testing context in conversation

**Action:**
```javascript
const testContext = await Promise.all([
  mcp__memory__search_nodes({ query: "testing patterns" }),
  mcp__memory__search_nodes({ query: "mocking strategies" }),
  mcp__memory__search_nodes({ query: "testing failed approach" }),
  mcp__memory__search_nodes({ query: "authentication testing" })
]);

// Apply: Use patterns, avoid past mistakes, follow mocking strategies
```

### Example 5: Debugging

**User:** "Users are getting logged out randomly during active sessions"

**Decision:**
- ✓ Bug investigation
- ✓ Authentication-related (critical)
- ✓ Might have seen similar bugs before

**Action:**
```javascript
const bugContext = await Promise.all([
  mcp__memory__search_nodes({ query: "authentication bug" }),
  mcp__memory__search_nodes({ query: "session logout" }),
  mcp__memory__search_nodes({ query: "token expiry" }),
  mcp__memory__search_nodes({ query: "authentication failed approach" })
]);

// Might find: "Bug:TokenExpiry:ClientTime - don't trust client time"
// Apply: Check if server-side time validation is in place
```

## Integration Pattern

This skill must be **manually invoked** as the first step when processing any substantial user request:

```
User asks question
  ↓
Step 1: Claude invokes Skill({ skill: "query-decision" })
  ↓
Step 2: If skill decides to query → Load memory context
  ↓
Step 3: Process request with enriched context
```

**Remember:** Skills don't auto-trigger. You must explicitly invoke them using the Skill tool.

## Key Principles

1. **Check existing context FIRST** - Never query redundantly
2. **Query in parallel** - Multiple searches at once for speed
3. **Apply silently** - Don't announce queries unless findings are significant
4. **Graceful degradation** - If memory not initialized, work without it
5. **Project-aware** - Use project prefix if multiple projects in memory
6. **Synthesize findings** - Don't just dump memory results, apply intelligently

## Decision Matrix Quick Reference

| Request Type | First in Session | Has Context | Query? |
|--------------|------------------|-------------|--------|
| Substantial feature | Yes | No | ✅ YES |
| Substantial feature | No | Yes | ❌ NO |
| Critical system | Yes/No | No | ✅ YES |
| Bug fix (complex) | Yes | No | ✅ YES |
| Testing | Yes | No | ✅ YES |
| Simple fix | Yes/No | Yes/No | ❌ NO |
| Question only | Yes/No | Yes/No | ❌ NO |
| Continuation | No | Yes | ❌ NO |

## Performance Considerations

- Memory queries add ~1-2 seconds
- Parallel queries (4 searches) take same time as 1 search
- Check existing context first to avoid this overhead
- Most sessions will query once at start, then reuse context

## Expected Behavior

**User perspective:**
- Memory "just works"
- Claude automatically has relevant historical context
- No need to say "check past work" or "remember when..."
- No announcement unless findings are particularly relevant

**Claude behavior:**
- Silently checks if memory query is valuable
- Loads context once per session/topic
- Applies historical knowledge naturally
- Avoids redundant queries via context checking

## Impact

When used consistently:
- **Smarter responses** - Informed by project history
- **Fewer mistakes** - Remember what didn't work
- **Faster development** - Leverage proven patterns
- **Better consistency** - Follow established architectural decisions
- **Seamless experience** - Memory feels like natural intelligence, not a separate system

This skill transforms persistent memory from an explicit tool into **automatic contextual intelligence**.