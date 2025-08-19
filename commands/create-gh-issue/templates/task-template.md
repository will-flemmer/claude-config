# Task Template

Single actionable item with clear scope and well-defined deliverables.

## Structure

### Title Format
- Action verb + specific object (< 80 characters)
- Examples: "Add dark mode toggle to user settings", "Fix memory leak in data processor"

### Required Sections
- **Objective**: Clear statement of what needs to be accomplished
- **Acceptance Criteria**: Specific, measurable criteria for completion

### Optional Sections  
- **Implementation Notes**: Technical guidance and approach suggestions
- **Definition of Done**: Checklist for completion validation

## Content Template

```markdown
## Objective

{Clear statement of what needs to be accomplished}

## Acceptance Criteria

- [ ] {Specific, measurable criterion 1}
- [ ] {Specific, measurable criterion 2}
- [ ] {Specific, measurable criterion 3}

## Implementation Notes

{Technical approach, constraints, or guidance}

## Definition of Done

- [ ] Implementation meets functional requirements
- [ ] Code follows project standards and style guides
- [ ] Unit tests are written and passing
- [ ] Documentation is updated if needed
- [ ] Code review is completed and approved
```

## Characteristics

- **Complexity**: Low
- **Estimated Time**: 1-3 days
- **Typical Labels**: task, enhancement, good first issue
- **Assignable**: Usually single developer
- **Dependencies**: Minimal external dependencies

## Best Practices

1. **Be Specific**: Avoid vague terms like "improve" or "enhance"
2. **Single Responsibility**: One clear objective per task
3. **Measurable Criteria**: Each acceptance criterion should be verifiable
4. **Actionable**: Include enough detail for implementation
5. **Scoped**: Can be completed in a single sprint/iteration

## Examples

### Good Task Issues
- "Add search functionality to user dashboard with autocomplete"
- "Fix responsive layout bug on mobile checkout page" 
- "Implement email validation for registration form"
- "Create API endpoint for user profile updates"

### Poor Task Issues
- "Make the app better" (too vague)
- "Build entire user management system" (too large, should be story/project)
- "Fix all bugs" (not specific, not scoped)
- "Add some new features" (unclear scope and requirements)