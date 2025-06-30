#!/bin/bash

# Test suite for implement-full.sh
# Following TDD principles - tests written first

TEST_PASSED=0
TEST_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local expected_exit_code="$2"
    local command="$3"
    
    echo "Running test: $test_name"
    
    # Run the command and capture exit code
    eval "$command" >/dev/null 2>&1
    local actual_exit_code=$?
    
    # Assert: Exit code must match expected
    if [ "$actual_exit_code" -eq "$expected_exit_code" ]; then
        echo "✓ PASS: $test_name"
        ((TEST_PASSED++))
    else
        echo "✗ FAIL: $test_name (expected exit code $expected_exit_code, got $actual_exit_code)"
        ((TEST_FAILED++))
    fi
    echo
}

# Function to test command output
test_output_contains() {
    local test_name="$1"
    local expected_text="$2"
    local command="$3"
    
    echo "Running test: $test_name"
    
    # Run command and capture output
    local output
    output=$(eval "$command" 2>&1)
    local exit_code=$?
    
    # Assert: Output must contain expected text
    if [[ "$output" == *"$expected_text"* ]]; then
        echo "✓ PASS: $test_name"
        ((TEST_PASSED++))
    else
        echo "✗ FAIL: $test_name"
        echo "Expected output to contain: '$expected_text'"
        echo "Actual output: '$output'"
        ((TEST_FAILED++))
    fi
    echo
}

# Function to validate file exists
validate_file_exists() {
    local file_path="$1"
    
    # Assert: File must exist
    if [ ! -f "$file_path" ]; then
        echo "Error: Test dependency missing - $file_path does not exist"
        exit 1
    fi
}

# Setup: Validate test dependencies
echo "================================================"
echo "Running implement-full.sh Test Suite"
echo "================================================"
echo

# Assert: Test script must exist before we can test it
SCRIPT_PATH="./commands/implement-full.sh"
validate_file_exists "$SCRIPT_PATH"

# Test 1: No arguments should show usage
run_test "No arguments shows usage and exits with code 1" 1 "$SCRIPT_PATH"

# Test 2: Empty description should fail
run_test "Empty description fails with code 1" 1 "$SCRIPT_PATH ''"

# Test 3: Valid description should start processing
test_output_contains "Valid description shows processing message" "Starting implement-full workflow" "$SCRIPT_PATH 'Create a simple calculator function'"

# Test 4: Usage message contains required text
test_output_contains "Usage message contains correct format" "Usage: implement-full.sh" "$SCRIPT_PATH"

# Test 5: Help flag shows usage
test_output_contains "Help flag shows usage" "Usage:" "$SCRIPT_PATH --help"

# Test 6: Invalid flag shows error
run_test "Invalid flag fails with code 1" 1 "$SCRIPT_PATH --invalid-flag"

# Summary
echo "================================================"
echo "Test Summary"
echo "================================================"
echo "Passed: $TEST_PASSED"
echo "Failed: $TEST_FAILED"

# Assert: All tests must pass
if [ "$TEST_FAILED" -gt 0 ]; then
    echo "Tests failed. Fix issues before continuing."
    exit 1
else
    echo "All tests passed!"
    exit 0
fi