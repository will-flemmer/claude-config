---
name: parallel-execution-patterns
description: Use when performing multiple independent operations like reading multiple files, searching patterns, or querying memory - executes operations in parallel for 5-8x performance improvement by sending all tool calls in a single message
---

# Parallel Execution Patterns

**Core rule:** If operations don't depend on each other, put them ALL in a single message. This applies to Read, Bash, graph tools, MCP queries, and Task/Agent dispatch.

## When to Parallelize

**Yes — operations are independent:**
- Reading multiple files
- Multiple graph queries (`semantic_search_nodes`, `query_graph`, `get_architecture_overview`)
- Multiple search patterns (grep, MCP queries)
- Multiple agent dispatches for independent subtasks
- Git read commands (`status`, `log`, `diff`)

**No — operations have dependencies:**
- Output of call A feeds into call B
- Both modify the same file
- Order matters for correctness

## How

Single message, multiple tool calls:

```javascript
// All of these execute in parallel:
Read({ file_path: "README.md" })
Read({ file_path: "package.json" })
Read({ file_path: "ARCHITECTURE.md" })
```

```javascript
// Graph + wiki in parallel:
mcp__code-review-graph__get_architecture_overview_tool({})
mcp__code-review-graph__semantic_search_nodes_tool({ query: "auth", limit: 20 })
mcp__qmd__query({ searches: [...], collections: ["wiki"], intent: "...", limit: 10 })
```

```javascript
// Multiple agents in parallel:
Agent({ description: "Fix bug A", prompt: "..." })
Agent({ description: "Fix bug B", prompt: "..." })
Agent({ description: "Fix bug C", prompt: "..." })
```

## Anti-Patterns

```
// BAD: sequential when independent
Read("file1.md")        // wait
Read("file2.md")        // wait
Read("file3.md")        // wait
// 24 seconds

// GOOD: parallel
Read("file1.md"), Read("file2.md"), Read("file3.md")  // single message
// 8 seconds
```

```
// BAD: parallelizing dependent operations
Glob("**/*.ts")          ]  // can't — Read needs
Read(glob_results)       ]  // Glob's output first

// GOOD: sequential when dependent
Glob("**/*.ts")          // wait for results
Read(specific_files)     // then read
```

## Checklist

Before executing 2+ operations:
1. Are they independent? → single message
2. Does one need another's output? → sequential
3. Do they modify the same file? → sequential
