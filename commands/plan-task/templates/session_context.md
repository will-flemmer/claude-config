# Session Context: {{session_id}}

## Objective

{{task_description}}

## Workflow Type

Task Planning and Decomposition

## Current State

Initialized - awaiting task decomposition

## Session Metadata

- **Created**: {{timestamp}}
- **Command**: plan-task
- **Session ID**: {{session_id}}
- **Working Directory**: {{working_directory}}

## Clarifications

{{clarifications}}

## Discovered Context

### Task Analysis

This section will be populated by the task-decomposition-expert agent with:
- Task complexity assessment
- Identified components and dependencies
- Technical considerations
- Risk factors

### Task Breakdown

This section will be populated by the task-decomposition-expert agent with:
- Subtasks and components
- Task dependencies and ordering
- Effort estimates
- Technical approach

### Technical Decisions

This section will be populated by implementation agents with:
- Technology choices and rationale
- Architecture decisions
- Design patterns to use
- Testing strategy

## Agent Activity Log

- [{{timestamp}}] plan-task command: Created session context
- [{{timestamp}}] plan-task command: Initialized task documentation file
- [{{timestamp}}] plan-task command: Routing to task-decomposition-expert agent

## Next Steps

1. Task-decomposition-expert agent will analyze the task and update this context
2. Task documentation file will be updated with detailed breakdown
3. Implementation can proceed using the structured plan

## Related Files

- **Task Documentation**: {{task_doc_path}}
- **Session Context**: {{session_context_path}}
