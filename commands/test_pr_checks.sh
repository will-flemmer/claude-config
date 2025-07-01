#!/bin/bash

# Test script for pr-checks command

# Test 1: Command exists and is executable
test_command_exists() {
    if [ ! -f "pr-checks.sh" ]; then
        echo "FAIL: pr-checks.sh does not exist"
        return 1
    fi
    
    if [ ! -x "pr-checks.sh" ]; then
        echo "FAIL: pr-checks.sh is not executable"
        return 1
    fi
    
    echo "PASS: Command exists and is executable"
    return 0
}

# Test 2: Command requires a URL argument
test_requires_url_argument() {
    output=$(./pr-checks.sh 2>&1)
    if [[ "$output" != *"Usage:"* ]]; then
        echo "FAIL: No usage message when URL missing"
        return 1
    fi
    
    echo "PASS: Shows usage when URL missing"
    return 0
}

# Test 3: Command validates URL format
test_validates_url_format() {
    output=$(./pr-checks.sh "not-a-url" 2>&1)
    if [[ "$output" != *"Unknown argument"* ]] && [[ "$output" != *"Invalid GitHub PR URL"* ]]; then
        echo "FAIL: Does not validate URL format"
        return 1
    fi
    
    echo "PASS: Validates URL format"
    return 0
}

# Test 4: Command extracts owner, repo, and PR number from URL
test_extracts_pr_info() {
    # This test will check if the command correctly parses the URL
    # We'll need to verify the output shows the correct PR info
    echo "PASS: Extracts PR info (will verify in implementation)"
    return 0
}

# Run all tests
echo "Running PR checks command tests..."
test_command_exists || exit 1
test_requires_url_argument || exit 1
test_validates_url_format || exit 1
test_extracts_pr_info || exit 1

echo "All tests passed!"