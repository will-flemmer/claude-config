---
description: Answer questions from the LLM wiki with citations to source pages
argument-hint: <question>
allowed-tools: Read, Bash, Grep, Glob, mcp__qmd__query
model: claude-opus-4-7
---

# wiki-query

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Answer questions from the LLM wiki with citations

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

Answers questions by searching the wiki, reading relevant pages, and synthesizing answers with citations back to wiki pages and original sources. Substantive answers can be filed back into the wiki as reusable pages.

## Usage

```bash
wiki-query <question>
```

## Workflow

### Phase 1: Parse Question

Extract the question from `$ARGUMENTS`. Identify:
- Key entities mentioned (named things: tools, libraries, people, etc.)
- Key concepts mentioned (patterns, strategies, techniques, etc.)
- Question type: factual, comparison, how-to, opinion, exploration

### Phase 2: Search Wiki (MANDATORY — DO NOT SKIP)

> ⚠️ **CRITICAL**: This command is meaningless without a qmd query. You MUST call `mcp__qmd__query` at least once in this step. Answering from intuition, training data, or `index.md` alone defeats the entire purpose of the wiki — it is not a substitute for retrieval.

**You will be penalized if you proceed past this step without invoking `mcp__qmd__query`.** The only exception is if the wiki directory does not exist (preflight below).

#### Preflight (one bash call)

```bash
test -d ~/Documents/llm-wiki/wiki && echo WIKI_EXISTS || echo WIKI_MISSING
```

- `WIKI_MISSING` → tell the user the wiki isn't set up. Do NOT attempt to answer from training data.
- `WIKI_EXISTS` → you MUST proceed to the qmd call below.

#### Required call

Execute in a single message (parallel with the index read):

```bash
cat ~/Documents/llm-wiki/index.md
```

```javascript
mcp__qmd__query({
  searches: [
    { type: "lex", query: "<exact terms / proper nouns from the question>" },
    { type: "vec", query: "<the question, restated naturally>" }
  ],
  collections: ["wiki"],
  intent: "<one sentence — what we're trying to answer for the user>",
  limit: 10
})
```

**Required parameters** — all four (`searches`, `collections`, `intent`, `limit`) must be present.

**Build searches from the actual question.** If the user asks "how do we handle session expiry in Rails?":
- `lex`: `"session" expir rails`
- `vec`: `"how do we handle session expiry in a Rails app"`
- `intent`: `"Answer the user's question about Rails session expiry with citations to wiki pages"`

**Do not** use placeholder strings like `<question>` — substitute real terms.

#### Optional follow-up calls

After the primary search, issue additional qmd calls if useful:
- **Per-entity** — one query per key named entity, scoped to `collections: ["wiki"]`
- **Raw fallback** — if wiki results are thin (≤2 hits or low relevance), repeat with `collections: ["raw"]` to check uncaptured source material

These are optional. The primary call above is mandatory.

#### Required post-call output

Before continuing to Phase 3, state:
- "Wiki search returned N results"
- For each result you'll read: 1-line title + why it's relevant
- If N=0: say so explicitly, then explain how you'll proceed (raw fallback, or tell user the wiki doesn't cover this)

### Phase 3: Read Relevant Pages

Read the top 5-10 most relevant pages found in Phase 2. Prioritize:
1. Entity/concept pages directly matching the question
2. Analysis pages related to the topic
3. Previously filed answers on similar questions
4. Source summaries with relevant content

Read these pages in parallel (single message, multiple Read calls).

### Phase 4: Synthesize Answer

Compose an answer that:
- Directly addresses the question
- Cites wiki pages: "According to [Page Title](wiki/path/to/page.md)..."
- Cites original sources where relevant: "...sourced from [Source](raw/path/to/source.md)"
- Notes confidence level: high (multiple corroborating sources), medium (single source), low (inferred)
- Highlights any contradictions found across pages

**Format the answer as clean markdown**, not as a wiki page. The user is reading this in the terminal.

### Phase 5: File Answer (Optional)

If the answer is substantive and reusable (not a simple fact lookup), ask the user:

> "This answer covers [topic]. Would you like me to file it as a wiki page for future reference?"

If yes:
1. Save as `wiki/answers/{date}-{slug}.md` with full frontmatter
2. Add cross-references to relevant entity/concept pages
3. Update `index.md` — add to Answers section
4. Append to `log.md`

### Phase 6: Report Gaps

If the wiki did not have enough information to fully answer the question:

```
⚠️ Knowledge gaps identified:
- [Topic/entity] has no wiki page yet
- [Concept] is only covered as a stub
- No sources cover [specific aspect]

Suggested sources to ingest:
- [Suggestion based on what would fill the gap]
```

## Answer Formatting

**For factual questions**: concise answer with citations.

**For comparisons**: table format comparing entities/concepts across dimensions, with source citations per cell.

**For how-to questions**: numbered steps with relevant wiki page references.

**For exploration questions**: structured overview with links to dive deeper into specific wiki pages.

## Error Handling

- **No matches found**: Tell the user the wiki has no relevant content yet. Suggest what sources to ingest.
- **Stale content**: If relevant pages have `status: stale` or old `updated` dates, note this in the answer: "Note: this information was last updated on [date] and may be outdated."
- **Empty wiki**: If index.md shows 0 sources, tell the user to start ingesting sources first.

## Requirements

- Wiki repo must exist at `~/Documents/llm-wiki/`
- `qmd` for semantic search (primary), `rg` (ripgrep) as fallback
- `tools/search.sh` must be executable (fallback)
