# update-tests

Update unit tests for changed files based on git diff output, following TDD principles. This command both adds new tests and removes redundant tests.

**IMPORTANT**: Always use the provided scripts from the `commands/update-tests` folder. Do NOT run custom test generation commands directly. Always use `just` commands for testing and linting.

## Usage

```bash
./commands/update-tests/update-tests.sh
```

## Features

- **TDD Workflow**: Follows strict test-driven development methodology
- **Pattern Matching**: Copies existing test patterns for consistency
- **Verification**: Confirms tests fail without functionality and pass with it
- **Automatic Discovery**: Analyzes git diff to identify changed files needing tests
- **Mock Reuse**: Uses existing mocking patterns from the codebase
- **Code Quality**: Runs lint commands to ensure standards are met
- **Test Cleanup**: Removes redundant tests that are no longer needed

## Workflow

The script will:
1. **Analyze changes**: Review git diff to identify modified functionality
2. **Add new tests**: Create tests for new or modified functionality
3. **Remove redundant tests**: Delete tests that are no longer needed
4. **Verify tests**: For each new test:
   - Verify the test passes with current code
   - Temporarily remove the functionality to verify test fails
   - Restore the functionality and confirm test passes again
5. **Run lint commands**: Ensure code quality standards are met

## Examples

```bash
# Run after making changes to update tests
./commands/update-tests/update-tests.sh

# The script will:
# - Analyze git diff for changed files
# - Identify testable functions/methods
# - Add new tests and remove redundant ones
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