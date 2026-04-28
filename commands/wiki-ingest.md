---
description: Process a new source (URL, file, pasted content) into the LLM wiki
argument-hint: <source-path-or-url>
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, mcp__qmd__query
model: claude-opus-4-7
---

# wiki-ingest

**EXECUTION**: Main Claude agent (no routing)
**PURPOSE**: Process a new source into the LLM wiki

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

Processes a new source (URL, file, or pasted content) into the wiki by:
1. Acquiring and storing the raw source
2. Analyzing content for entities, concepts, and key points
3. Creating/updating wiki pages with cross-references
4. Updating the index and activity log

A single source typically touches 5-15 wiki pages.

## Usage

```bash
wiki-ingest <file-path-or-url>
wiki-ingest   # (then paste content when prompted)
```

## Workflow

### Phase 1: Acquire Source

Determine input type from `$ARGUMENTS`:

- **URL**: Use `WebFetch` to retrieve content. For JS-heavy pages, use puppeteer (`mcp__puppeteer__puppeteer_navigate` then `mcp__puppeteer__puppeteer_screenshot`).
- **File path**: Read the file directly.
- **No argument**: Ask the user to provide a URL, file path, or paste content.

### Phase 2: Store Raw Source

Save the raw content to `WIKI_ROOT/raw/{descriptive-filename}.md`.

**Filename**: descriptive slug based on content (e.g., `karpathy-llm-wiki-pattern.md`). The raw file is immutable after creation. Source type (article, code, docs, etc.) is captured in the wiki page frontmatter, not the directory structure.

### Phase 3: Read Schema

Read `WIKI_ROOT/CLAUDE.md` to ensure you follow current wiki conventions. This is mandatory — always re-read the schema.

### Phase 4: Analyze Content

Use sequential thinking (5-8 steps) to extract:

```javascript
mcp__sequential-thinking__sequentialthinking({
  thought: "Analyzing source for wiki ingest. I need to identify: 1) main topic and summary, 2) all entities mentioned, 3) all concepts covered, 4) key points, 5) relationships between entities/concepts.",
  thoughtNumber: 1,
  totalThoughts: 6,
  nextThoughtNeeded: true
})
```

Extract:
- **Summary**: 2-4 sentences describing the source
- **Entities**: all named things (people, tools, libraries, frameworks, companies, languages, etc.) with their domain classification
- **Concepts**: all ideas, patterns, strategies, techniques, methodologies with their domain classification
- **Key points**: 5-10 bullet points
- **Relationships**: how entities and concepts relate to each other

### Phase 5: Search Existing Wiki (Parallel)

In a single message, execute in parallel:
- Read `WIKI_ROOT/index.md` to understand current wiki state
- For each identified entity/concept, use qmd via MCP for semantic matching against existing pages:
  ```javascript
  mcp__qmd__query({
    searches: [
      { type: "lex", query: "<entity-or-concept-name>" },
      { type: "vec", query: "<entity-or-concept-name> <related terms>" }
    ],
    collections: ["wiki"],
    intent: "Find existing pages on this entity/concept so we update instead of duplicating"
  })
  ```
- If qmd is unavailable, fall back to: `Grep({ pattern: "{name}", path: "WIKI_ROOT/wiki/" })`

This determines which pages to update vs. create.

### Phase 6: Create/Update Pages

Following the schema in CLAUDE.md. All pages go in `wiki/` (flat). The `type` frontmatter field distinguishes page types.

1. **Create source summary** — `wiki/{date}-{slug}.md` with `type: source`, full frontmatter, summary, key points, entities mentioned, concepts covered.

2. **For each entity**:
   - If `wiki/{slug}.md` exists → update it: add new information, add source reference to Sources section, update `updated` date, append to Changelog.
   - If no page exists → create a stub (`status: stub`) with what we know from this source.

3. **For each concept**:
   - Same logic as entities.

4. **Cross-reference** — ensure all links are bidirectional. If page A mentions page B, both should link to each other.

**Decision rule**: always search by title, aliases, and tags before creating a new page. If a page with the same subject exists (even as a stub), update it rather than creating a duplicate.

### Phase 7: Update Index and Log

**index.md**: Add any new pages to the appropriate section. Keep entries sorted within sections.

**log.md**: Append an entry:
```markdown
- **HH:MM** INGEST: Processed "[Source Title]" ({type})
  - Created: wiki/{date}-{slug}.md (source)
  - Created: wiki/{slug}.md (entity stub)
  - Updated: wiki/{slug}.md (concept)
  - Updated: index.md
```

### Phase 8: Re-index Search

Update the qmd search index so new/updated pages are findable:
```bash
cd WIKI_ROOT && qmd update && qmd embed
```

### Phase 9: Report

Output a summary to the user:

```
✅ Source Ingested: [Title]

Raw source: raw/{filename}.md
Source summary: wiki/{date}-{slug}.md

Pages created (N):
  - wiki/{slug}.md (entity stub)
  - wiki/{slug}.md (concept)

Pages updated (N):
  - wiki/{slug}.md

New entities: [list]
New concepts: [list]
```

## Error Handling

- **URL fetch fails**: Report the error, ask user to provide content another way
- **Source already ingested**: Search `wiki/` for existing summary with same title (`type: source`). If found, ask user if they want to re-ingest (update) or skip.
- **Large source**: If content exceeds ~10,000 words, process in chunks. Summarize each chunk, then synthesize.
- **Ambiguous entity/concept**: If unsure whether something is an entity or concept, prefer entity for named things and concept for ideas/techniques.

## Requirements

- Wiki repo must exist at `~/Documents/llm-wiki/`
- `qmd` for semantic search (primary), `rg` (ripgrep) as fallback
- Network access for URL-based sources (WebFetch or puppeteer)
