# implement-full

Comprehensive workflow command that implements a coding task using the Explore, Plan, Code methodology with TDD principles, and PR checks.

## CRITICAL: Complete ALL Steps

**IMPORTANT**: This workflow consists of MULTIPLE PHASES that MUST ALL be completed:
1. **Phase 1**: Implementation (Explore, Plan, Code)
2. **Phase 2**: PR Creation and Commit
3. **Phase 3**: PR Checks Monitoring
4. **Phase 4**: Completion

**The agent MUST complete ALL phases. Do NOT stop after Phase 1.**

## Usage

This is a Claude Code workflow command. To execute:

1. Clear your Claude Code session history
2. Copy and paste the ENTIRE workflow prompt below
3. Replace `[GITHUB_ISSUE_URL]` with the URL of the GitHub issue to implement
4. Submit to Claude Code

## Complete Workflow Prompt

```
I need you to complete the ENTIRE implement-full workflow for the following GitHub issue:

GITHUB_ISSUE_URL: [GITHUB_ISSUE_URL]

YOU MUST COMPLETE ALL 4 PHASES. DO NOT STOP UNTIL THE PR IS CREATED AND CHECKS PASS.

PHASE 1: AGENT-DRIVEN IMPLEMENTATION
====================================
**MANDATORY**: Use specialized agents for ALL implementation phases. Follow Agent-First Task Execution guidelines.

0. ISSUE ANALYSIS AND TASK DECOMPOSITION (Use task-decomposition-expert agent):
   - Fetch and analyze the GitHub issue using gh cli or WebFetch
   - Extract requirements, acceptance criteria, and context from the issue
   - Route to task-decomposition-expert for complex task breakdown
   - Identify which specialized agents are needed
   - Get structured plan with agent assignments
   - Ask clarifying questions through appropriate agents

1. EXPLORE (Use general-purpose agent):
   - Use Task(subagent_type: "general-purpose") for codebase exploration
   - Agent searches for related files and patterns
   - Agent reads existing code to understand conventions
   - Agent identifies optimal placement for new code

2. PLAN (Use appropriate domain expert agent):
   - Use Task(subagent_type: "frontend-developer") for frontend tasks
   - Use Task(subagent_type: "backend-developer") for backend tasks
   - Agent creates detailed TDD implementation plan
   - Agent presents plan to user for approval
   - Agent lists all test cases and API definitions

3. IMPLEMENT (Use test-automator + domain agent):
   - **Testing**: Use Task(subagent_type: "test-automator") for ALL test creation
   - **Code**: Use appropriate domain agent for implementation
   - Agents follow strict TDD: RED → GREEN → REFACTOR
   - Agents ensure 100% test coverage
   - Agents run quality checks and perform smoke testing

**CRITICAL**: Never implement directly. Always use specialized agents via Task tool.

PHASE 2: PR CREATION (MANDATORY - DO NOT SKIP)
==============================================
After completing implementation, you MUST:

1. Create a semantic branch name from the task description
   Example: "create-user-authentication-system"

2. Create the branch and switch to it:
   git checkout -b [branch-name]

3. Use the commit-and-push script for committing:
   ./commands/commit-and-push.sh "feat: [short task description]"
   
   **IMPORTANT**: Keep commit message under 60 characters. Use the PR description for detailed information.

4. If you need to push a new branch:
   git push -u origin [branch-name]

6. Create the pull request: `gh pr create`
   - use the commit message as PR title
   - use PR template as body

7. Save the PR URL for the next phase

PHASE 3: AGENT-DRIVEN PR CHECKS (MANDATORY - DO NOT SKIP)
========================================================
**MANDATORY**: Use pr-checker agent for automated CI/CD monitoring and fixing.

1. **Route to PR-Checker Agent**:
   Use Task(subagent_type: "pr-checker", description: "Monitor and fix PR checks", 
           prompt: "Monitor and fix all failing checks for PR: [PR-URL] using enhanced workflow")

2. **Agent Automatically Handles**:
   - Intelligent failure analysis with context gathering
   - Routes specific failures to appropriate specialist agents
   - Coordinates multi-agent fixes (test-automator, frontend-developer, etc.)
   - Automatic commit and push of fixes
   - Continuous monitoring until all checks pass

3. **Enhanced Capabilities**:
   - Uses pr-checks-enhanced.sh for comprehensive analysis
   - Integrates with task-decomposition-expert for complex failures
   - Leverages prompt-engineer-optimized failure classification
   - Provides automated agent routing and fix coordination

**CRITICAL**: Never handle PR checks manually. Always use pr-checker agent.

**IMPORTANT**: Always use the provided scripts. Never run raw git or gh commands.

**VERY IMPORTANT**: The scripts can be found in the `~/.claude/commands` folder. Read the `.md` files in this directory to find the correct script to use.

PHASE 4: COMPLETION
==================
After all checks pass, the workflow is complete.

COMPLETION CRITERIA
==================
The workflow is ONLY complete when:
✅ Implementation is done with 100% test coverage
✅ PR is created with comprehensive description
✅ All PR checks pass

DO NOT STOP until ALL criteria are met.
```

## Detailed Phase Descriptions

### Phase 1: Agent-Driven Implementation (Decompose, Explore, Plan, Code)

This phase involves using specialized agents for all implementation tasks according to Agent-First guidelines.

**Key Agent Activities:**
- **task-decomposition-expert**: Breaks down complex tasks and assigns appropriate agents
- **general-purpose**: Explores codebase and understands existing patterns
- **Domain agents**: Create TDD plans and get user approval (frontend-developer, backend-developer, etc.)
- **test-automator**: Writes all tests following TDD principles
- **Domain agents**: Implement code with quality standards

**Critical Requirement**: NEVER implement directly. Always route to specialized agents via Task tool.

**Common Mistake**: Attempting direct implementation instead of using agents. YOU MUST USE AGENTS FOR ALL WORK.

### Phase 2: PR Creation and Management

This phase involves creating a feature branch, committing changes, and opening a pull request.

**Key Activities:**
- Create semantic branch name
- Commit changes
- Push to remote repository
- Create PR with detailed description
- Save PR URL for later phases

**Common Mistake**: Forgetting to push or create the PR. ALL steps are required.

### Phase 3: Agent-Driven Quality Validation

This phase uses the pr-checker agent for automated CI/CD monitoring and intelligent failure resolution.

**Key Agent Activities:**
- **pr-checker**: Monitors PR status with intelligent failure analysis
- **pr-checker**: Routes failures to appropriate specialist agents automatically
- **Specialist agents**: Implement targeted fixes (test-automator, frontend-developer, etc.)
- **pr-checker**: Coordinates multi-agent fixes and manages commits/pushes
- **pr-checker**: Continues monitoring until all checks pass

**Critical Requirement**: NEVER handle PR checks manually. Always use pr-checker agent with enhanced workflow.

**Common Mistake**: Attempting manual check monitoring instead of using pr-checker agent automation.

### Phase 4: Completion

This phase marks the end of the workflow after all checks pass.

**Key Activities:**
- Verify all checks have passed
- Confirm PR is ready for review by others

**Common Mistake**: Stopping before all checks pass.

## Requirements

- **Git**: Must be in a git repository
- **GitHub CLI (`gh`)**: Must be installed and authenticated
- **Repository Access**: Must have permissions to create branches and PRs

## Best Practices

1. **Agent-First Execution**: Always use specialized agents via Task tool for all implementation work
2. **Clear Task Descriptions**: Be specific about what needs to be implemented for proper agent routing
3. **Follow TDD via Agents**: Use test-automator for all tests, never write tests directly
4. **Complete All Phases**: Don't let any phase stop early, ensure agent completion
5. **Verify Agent Completion**: Check that agents completed their tasks and PR checks pass
6. **Trust Agent Expertise**: Let specialized agents handle their domain areas without interference

## Example Execution

```
I need you to complete the ENTIRE implement-full workflow for the following GitHub issue:

GITHUB_ISSUE_URL: https://github.com/user/repo/issues/42

YOU MUST COMPLETE ALL 4 PHASES. DO NOT STOP UNTIL THE PR IS CREATED AND CHECKS PASS.

[... rest of the workflow prompt ...]
```

The system should then route to agents:
1. ✅ Fetch and analyze GitHub issue for requirements  
2. ✅ task-decomposition-expert: Break down issue into implementation tasks
3. ✅ general-purpose: Explore existing code patterns
4. ✅ domain-agent: Plan implementation architecture based on issue requirements
5. ✅ test-automator: Create comprehensive test suite
6. ✅ domain-agent: Implement solution with TDD
7. ✅ Direct execution: Create branch, commit, push, and create PR
8. ✅ pr-checker: Monitor and fix all PR checks until they pass

## Common Pitfalls to Avoid

1. **Direct Implementation**: NEVER implement directly - always use specialized agents
2. **Stopping After Implementation**: The workflow is NOT complete after coding
3. **Skipping Agent Routes**: Use test-automator for tests, pr-checker for PR monitoring
4. **Manual Check Handling**: Failed checks must be handled by pr-checker agent
5. **Ignoring Agent Expertise**: Trust agents to handle their specialized domains

## Verification Checklist

Before considering the workflow complete, verify:
- [ ] GitHub issue was fetched and analyzed for requirements
- [ ] Task was decomposed by task-decomposition-expert agent
- [ ] Exploration was completed by general-purpose agent
- [ ] Tests were written by test-automator agent with 100% coverage
- [ ] Implementation was completed by appropriate domain agent
- [ ] All agents followed TDD principles and quality standards
- [ ] Branch is created and pushed
- [ ] PR is opened with proper description
- [ ] PR checks were monitored and fixed by pr-checker agent
- [ ] All PR checks pass

Only when ALL agent-driven tasks are verified complete is the workflow truly complete.