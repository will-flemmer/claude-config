# init-memory

Initialize persistent memory system for the current project using MCP memory server.

## Purpose

Sets up the foundational memory entities for a project, enabling long-term knowledge retention across Claude Code sessions. Creates core entity types for storing architectural decisions, patterns, bugs, optimizations, and lessons learned.

## Usage

```bash
/init-memory
```

Or with project-specific initialization:

```bash
/init-memory --project-name "MyProject" --description "Brief project description"
```

## What This Command Does

1. **Checks Memory Server Status**
   - Verifies MCP memory server is configured and accessible
   - Tests connection with a simple query

2. **Creates Core Memory Entities**
   - ProjectArchitecture: Root entity for architectural decisions
   - CodePatterns: Repository for reusable code patterns
   - BugRegistry: Catalog of bugs and their fixes
   - OptimizationLog: Record of performance improvements
   - ToolEvaluation: Library/tool choices and evaluations
   - FailedApproaches: Critical knowledge about what NOT to do

3. **Creates Project-Specific Entity**
   - Stores project metadata (name, description, initialization date)
   - Establishes relationships between core entities

4. **Verifies Installation**
   - Confirms all entities were created successfully
   - Displays memory system status

## Prerequisites

- MCP memory server must be configured in `.mcp.json`
- Run `./install-mcp-servers.sh` if you haven't already
- Restart Claude Code after MCP server installation

## Implementation

You are executing a slash command that initializes the persistent memory system. Follow these steps:

### Step 1: Verify MCP Memory Server

First, check if the memory MCP server is accessible:

```javascript
// Try to read the graph to verify connection
try {
  const graph = await mcp__memory__read_graph({});
  console.log("✓ Memory server is accessible");
} catch (error) {
  console.error("✗ Memory server not accessible");
  console.error("Please ensure:");
  console.error("  1. .mcp.json is configured correctly");
  console.error("  2. You've run ./install-mcp-servers.sh");
  console.error("  3. You've restarted Claude Code");
  throw error;
}
```

### Step 2: Check for Existing Initialization

Search for existing project entities to avoid duplicates:

```javascript
const existingProject = await mcp__memory__search_nodes({
  query: "ProjectArchitecture"
});

if (existingProject && existingProject.length > 0) {
  console.log("⚠ Memory system appears to be already initialized");
  console.log("Found existing entities:", existingProject.map(n => n.name));

  // Ask user if they want to reinitialize
  const response = await AskUserQuestion({
    questions: [{
      question: "Memory system is already initialized. What would you like to do?",
      header: "Action",
      multiSelect: false,
      options: [
        {
          label: "Keep existing",
          description: "Continue with current memory entities"
        },
        {
          label: "Add to existing",
          description: "Add new entities without removing old ones"
        },
        {
          label: "Reset completely",
          description: "Delete all and start fresh (destructive!)"
        }
      ]
    }]
  });

  if (response.answers["Action"] === "Keep existing") {
    console.log("✓ Keeping existing memory system");
    return;
  } else if (response.answers["Action"] === "Reset completely") {
    // Delete existing core entities
    await mcp__memory__delete_entities({
      entityNames: [
        "ProjectArchitecture",
        "CodePatterns",
        "BugRegistry",
        "OptimizationLog",
        "ToolEvaluation",
        "FailedApproaches"
      ]
    });
    console.log("✓ Cleared existing entities");
  }
}
```

### Step 3: Get Project Information

If user provided --project-name and --description flags, use those. Otherwise, try to detect from git:

```javascript
// Try to get project name from git
let projectName = "UnnamedProject";
let projectDescription = "No description provided";

try {
  const gitRemote = await Bash({
    command: "git remote get-url origin 2>/dev/null || echo 'no-remote'"
  });

  if (gitRemote && gitRemote !== "no-remote") {
    // Extract repo name from URL
    const match = gitRemote.match(/\/([^\/]+?)(\.git)?$/);
    if (match) {
      projectName = match[1];
    }
  }

  // Get project description from package.json or README
  const hasPackageJson = await Read({
    file_path: "package.json"
  }).catch(() => null);

  if (hasPackageJson) {
    try {
      const pkg = JSON.parse(hasPackageJson);
      if (pkg.description) {
        projectDescription = pkg.description;
      }
    } catch (e) {
      // Ignore JSON parse errors
    }
  }
} catch (error) {
  // Use defaults if git/file reading fails
}

console.log(`Initializing memory for project: ${projectName}`);
```

### Step 4: Create Core Memory Entities

Create the foundational entities for the memory system:

```javascript
const timestamp = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

await mcp__memory__create_entities({
  entities: [
    {
      name: "ProjectArchitecture",
      entityType: "Architecture",
      observations: [
        `Initialized: ${timestamp}`,
        `Project: ${projectName}`,
        `Description: ${projectDescription}`,
        "Purpose: Stores high-level architectural decisions and constraints",
        "Usage: Record major design choices, technology selections, patterns"
      ]
    },
    {
      name: "CodePatterns",
      entityType: "PatternRegistry",
      observations: [
        `Initialized: ${timestamp}`,
        "Purpose: Repository of reusable code patterns",
        "Usage: Store successful patterns for reuse across the codebase",
        "Examples: Error handling, validation, data transformation patterns"
      ]
    },
    {
      name: "BugRegistry",
      entityType: "BugTracking",
      observations: [
        `Initialized: ${timestamp}`,
        "Purpose: Catalog of bugs, root causes, and fixes",
        "Usage: Record bugs to prevent recurrence and inform testing",
        "Format: Bug:[Component]:[Description] with root cause analysis"
      ]
    },
    {
      name: "OptimizationLog",
      entityType: "Performance",
      observations: [
        `Initialized: ${timestamp}`,
        "Purpose: Record of performance improvements",
        "Usage: Track optimization attempts, techniques, and results",
        "Metrics: Before/after measurements, improvement techniques"
      ]
    },
    {
      name: "ToolEvaluation",
      entityType: "ToolRegistry",
      observations: [
        `Initialized: ${timestamp}`,
        "Purpose: Library and tool selection decisions",
        "Usage: Record why tools were chosen or rejected",
        "Details: Alternatives considered, trade-offs, lessons learned"
      ]
    },
    {
      name: "FailedApproaches",
      entityType: "LessonsLearned",
      observations: [
        `Initialized: ${timestamp}`,
        "Purpose: Critical knowledge about what NOT to do",
        "Usage: Prevent repeating failed experiments",
        "Value: Often more valuable than success stories"
      ]
    }
  ]
});

console.log("✓ Created core memory entities");
```

### Step 5: Create Relationships

Link the core entities to show their relationships:

```javascript
await mcp__memory__create_relations({
  relations: [
    {
      from: "CodePatterns",
      to: "ProjectArchitecture",
      relationType: "implements"
    },
    {
      from: "BugRegistry",
      to: "ProjectArchitecture",
      relationType: "tracks_issues_in"
    },
    {
      from: "OptimizationLog",
      to: "ProjectArchitecture",
      relationType: "improves"
    },
    {
      from: "ToolEvaluation",
      to: "ProjectArchitecture",
      relationType: "supports"
    },
    {
      from: "FailedApproaches",
      to: "ProjectArchitecture",
      relationType: "informs"
    }
  ]
});

console.log("✓ Created entity relationships");
```

### Step 6: Verify Installation

Query the graph to confirm everything was created:

```javascript
const verification = await mcp__memory__search_nodes({
  query: "Initialized: " + timestamp
});

console.log("\n✓ Memory system initialized successfully!");
console.log("\nCreated entities:");
console.log("  • ProjectArchitecture - Architectural decisions");
console.log("  • CodePatterns - Reusable code patterns");
console.log("  • BugRegistry - Bug tracking and root causes");
console.log("  • OptimizationLog - Performance improvements");
console.log("  • ToolEvaluation - Library/tool decisions");
console.log("  • FailedApproaches - Lessons learned");

console.log("\nNext steps:");
console.log("  1. Use /plan-task - Will automatically query memory for context");
console.log("  2. Use /implement-plan - Will automatically store learnings");
console.log("  3. Refer to @persistent-context skill for detailed usage");

console.log("\nTo view your memory graph:");
console.log("  Use mcp__memory__read_graph() to see all stored knowledge");
```

### Step 7: Create Initial Project Context

Store some initial project context if available:

```javascript
// Try to gather initial project context
const initialContext = [];

// Check for README
try {
  const readme = await Read({ file_path: "README.md" });
  if (readme && readme.length > 0) {
    initialContext.push("Project has README.md with documentation");
  }
} catch (e) {
  initialContext.push("No README.md found - consider creating one");
}

// Check for package.json (Node project)
try {
  const pkg = await Read({ file_path: "package.json" });
  if (pkg) {
    const pkgJson = JSON.parse(pkg);
    if (pkgJson.dependencies) {
      const depCount = Object.keys(pkgJson.dependencies).length;
      initialContext.push(`Node.js project with ${depCount} dependencies`);
    }
  }
} catch (e) {
  // Not a Node project or no package.json
}

// Check for common tech stack markers
const techMarkers = [
  { file: "tsconfig.json", tech: "TypeScript" },
  { file: "Cargo.toml", tech: "Rust" },
  { file: "go.mod", tech: "Go" },
  { file: "requirements.txt", tech: "Python" },
  { file: "Gemfile", tech: "Ruby" },
  { file: "pom.xml", tech: "Java/Maven" }
];

for (const marker of techMarkers) {
  try {
    await Read({ file_path: marker.file });
    initialContext.push(`Uses ${marker.tech}`);
  } catch (e) {
    // File doesn't exist
  }
}

if (initialContext.length > 0) {
  await mcp__memory__add_observations({
    observations: [{
      entityName: "ProjectArchitecture",
      contents: initialContext
    }]
  });

  console.log("\n✓ Added initial project context:");
  initialContext.forEach(ctx => console.log(`  • ${ctx}`));
}
```

## Error Handling

If memory server is not available:
- Provide clear error message
- Link to installation instructions
- Suggest checking .mcp.json configuration

If initialization fails partway through:
- Report which step failed
- Suggest cleanup (delete partial entities)
- Provide recovery steps

## Integration with Other Commands

This command is typically run ONCE per project, before using:
- `/plan-task` - Will query memory for context
- `/implement-plan` - Will store learnings to memory
- Any workflow that uses the `@persistent-context` skill

## Related

- **Skill:** `@persistent-context` - Detailed usage guide
- **Command:** `/plan-task` - Uses memory for planning context
- **Command:** `/implement-plan` - Stores implementation learnings
- **Config:** `.mcp.json` - MCP server configuration

## Example Output

```
Initializing memory for project: auction-api

✓ Memory server is accessible
✓ Created core memory entities
✓ Created entity relationships

✓ Memory system initialized successfully!

Created entities:
  • ProjectArchitecture - Architectural decisions
  • CodePatterns - Reusable code patterns
  • BugRegistry - Bug tracking and root causes
  • OptimizationLog - Performance improvements
  • ToolEvaluation - Library/tool decisions
  • FailedApproaches - Lessons learned

✓ Added initial project context:
  • Project has README.md with documentation
  • Node.js project with 24 dependencies
  • Uses TypeScript

Next steps:
  1. Use /plan-task - Will automatically query memory for context
  2. Use /implement-plan - Will automatically store learnings
  3. Refer to @persistent-context skill for detailed usage
```

## Notes

- Memory is stored globally across all projects by default
- Use project-specific entity names to separate projects
- Consider namespacing entities: "ProjectName:EntityType"
- Memory persists until explicitly deleted
- Can be queried from any Claude Code session

## Tips

1. **Project Namespacing**: For multi-project setups, prefix entities with project name:
   ```javascript
   name: "AuctionAPI:ProjectArchitecture"
   ```

2. **Team Usage**: If multiple people use the same memory:
   - Include author in observations
   - Use timestamps for all entries
   - Document reasoning clearly

3. **Maintenance**: Periodically review and update:
   - Remove obsolete information
   - Update outdated decisions
   - Consolidate duplicate patterns
