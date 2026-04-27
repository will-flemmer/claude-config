# wiki-capture

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Extract learnings from the current conversation and ingest them into the wiki

**WIKI_ROOT**: ~/Documents/llm-wiki

---

## 🚨 MANDATORY SKILL INVOCATIONS - DO THESE FIRST 🚨

**BEFORE doing ANYTHING else, invoke these skills:**

1. **About to read/search 2+ files?**
   ```
   Skill({ skill: "parallel-execution-patterns" })
   ```
   ↳ Executes reads/searches in parallel (5-8x faster)

**⚠️ STOP - Did you invoke the skills above? If not, DO IT NOW before continuing!**

---

## What This Does

Reviews the current conversation and extracts knowledge worth preserving — architectural decisions, debugging insights, patterns discovered, tool usage, gotchas, and anything else that would be useful in future sessions. Then ingests the extracted learnings into the wiki as pages.

Run this at the end of a session when you've learned something, or anytime mid-session when a valuable insight surfaces.

## Usage

```bash
wiki-capture                    # Auto-extract from conversation
wiki-capture <specific-topic>   # Focus extraction on a specific topic
```

## What Gets Captured

**High-value signals** (always capture):
- Architectural decisions and their rationale
- Debugging sessions: root cause + fix for non-trivial bugs
- Discovered patterns or anti-patterns in a codebase
- Tool/library gotchas, workarounds, or undocumented behavior
- Performance insights (what was slow, why, how it was fixed)
- Integration knowledge (how system A talks to system B)

**Medium-value signals** (capture if substantive):
- Configuration that was hard to get right
- API usage patterns that weren't obvious from docs
- Testing strategies that worked well for a specific scenario

**Low-value / skip**:
- Routine code changes (the git history captures these)
- Simple typo fixes or formatting
- Anything already well-documented in official docs
- Conversation logistics ("let me read that file", "here's the plan")

## Workflow

### Phase 1: Read Schema

Read `WIKI_ROOT/CLAUDE.md` to ensure you follow current wiki conventions.

### Phase 2: Scan Conversation

Review the full conversation history in this session. For each exchange, ask:
- Was something non-obvious learned here?
- Was a decision made that has rationale worth preserving?
- Was a problem solved in a way that would help future-me?
- Was a pattern, tool, or technique discussed that I'd want to find later?

Extract a list of **candidate learnings**, each with:
- **Topic**: what was learned (1 sentence)
- **Type**: entity (tool/library/service) or concept (pattern/technique/strategy)
- **Content**: the actual knowledge (2-10 sentences)
- **Context**: what project/task prompted this learning
- **Confidence**: high (verified by running code) or medium (discussed but not fully verified)

### Phase 3: Present to User

Show the candidate learnings to the user for approval:

```
📝 Learnings extracted from this session:

1. [Topic] (type: entity/concept, confidence: high/medium)
   Brief summary of what was learned...

2. [Topic] ...

Capture all of these? Or specify which to keep/skip (e.g., "1,3" or "skip 2").
```

Wait for user confirmation before proceeding. The user may:
- Approve all
- Select specific items (e.g., "1 and 3")
- Skip specific items (e.g., "skip 2")
- Add context or corrections to items
- Cancel entirely

### Phase 4: Search Existing Wiki (Parallel)

For each approved learning, search the wiki for existing pages:
- Use qmd via MCP: `mcp__qmd__query({ query: "{topic}", collection: "wiki" })` for semantic matching
- If qmd is unavailable, fall back to: `Grep({ pattern: "{topic keywords}", path: "WIKI_ROOT/wiki/" })`

This determines whether to create new pages or update existing ones.

### Phase 5: Create/Update Pages

For each approved learning:

1. **If an existing wiki page covers this topic** → update it:
   - Add new information under the appropriate section
   - Add a Changelog entry: `YYYY-MM-DD: Updated from [project-name] session — [what was added]`
   - Update `updated` date in frontmatter

2. **If no existing page** → create a new page in `wiki/`:
   - Filename: `{slug}.md` for entities/concepts, `{date}-{slug}.md` for one-off insights
   - Full frontmatter with type, tags, domain, status
   - Content structured per CLAUDE.md page format
   - Tag with the project name if applicable

3. **Cross-reference** — link to related existing wiki pages where relevant.

### Phase 6: Update Index, Log, and Search

**index.md**: Add any new pages to the appropriate section.

**log.md**: Append:
```markdown
- **HH:MM** CAPTURE: Extracted N learnings from [project-name] session
  - Created: wiki/{slug}.md
  - Updated: wiki/{slug}.md
```

**Re-index**: `cd WIKI_ROOT && qmd update && qmd embed`

### Phase 7: Report

```
✅ Wiki updated with N learnings from this session

Created (N):
  - wiki/{slug}.md — [brief description]

Updated (N):
  - wiki/{slug}.md — [what was added]

Run /wiki-query to search for these topics later.
```

## Examples

### After a debugging session
```
User: /wiki-capture

📝 Learnings extracted from this session:

1. React Server Components hydration error (type: concept, confidence: high)
   RSC hydration mismatches can occur when a client component wraps a server
   component that returns different HTML based on server-only state. The fix
   is to use suppressHydrationWarning or restructure to avoid the mismatch.
   Verified by reproducing and fixing in the codebase.

2. Next.js 15 app router caching behavior (type: entity, confidence: medium)
   The app router in Next.js 15 changed the default caching behavior for
   fetch() — it no longer caches by default. This was discussed but not
   directly tested in this session.

Capture all of these?
```

### After an architecture discussion
```
User: /wiki-capture event sourcing decision

📝 Learnings focused on "event sourcing decision":

1. Event sourcing for order service (type: concept, confidence: high)
   Decided to use event sourcing for the order service because we need
   complete audit trail for compliance. Using EventStoreDB. Key tradeoff:
   eventual consistency for reads is acceptable because the admin dashboard
   can tolerate 2-3s delay. CQRS with separate read models in Postgres.

Capture this?
```

## Error Handling

- **Nothing worth capturing**: Report "No significant learnings identified in this session." Don't create empty pages.
- **Wiki not found**: Error with instructions to run setup.sh.
- **User cancels**: Acknowledge and exit cleanly.
- **Duplicate knowledge**: If the wiki already has this information, tell the user and skip unless there's genuinely new detail to add.

## Requirements

- Wiki repo must exist at `~/Documents/llm-wiki/`
- `qmd` for semantic search (primary), `rg` (ripgrep) as fallback
- Must be run within a conversation that has context to extract from
