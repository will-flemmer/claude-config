# add-tests

Generate unit tests for changed files based on git diff output, following TDD principles.

**IMPORTANT**: Always use the provided scripts from the `commands/add-tests` folder. Do NOT run custom test generation commands directly.

## Usage

```bash
./commands/add-tests/add-tests.sh
```

## Features

- **TDD Workflow**: Follows strict test-driven development methodology
- **Pattern Matching**: Copies existing test patterns for consistency
- **Verification**: Confirms tests fail without functionality and pass with it
- **Automatic Discovery**: Analyzes git diff to identify changed files needing tests
- **Mock Reuse**: Uses existing mocking patterns from the codebase
- **Code Quality**: Runs lint commands to ensure standards are met

## Workflow

For each test added, the script will:
1. Add the test based on changed functionality
2. Verify the test passes with current code
3. Temporarily remove the functionality to verify test fails
4. Restore the functionality and confirm test passes again
5. Run lint commands to ensure code quality standards are met

## Examples

```bash
# Run after making changes to generate tests
./commands/add-tests/add-tests.sh

# The script will:
# - Analyze git diff for changed files
# - Identify testable functions/methods
# - Generate appropriate unit tests
# - Follow existing test patterns in the codebase
```

## Requirements

- Must be in a git repository with uncommitted changes
- Existing test framework must be set up
- Test files must follow project conventions
- Justfile with lint and test commands (if applicable)

## Error Handling

- Validates git repository status before running
- Ensures test framework is available
- Reports any tests that don't follow the fail-pass-fail-pass cycle
- Preserves original code state even if tests fail