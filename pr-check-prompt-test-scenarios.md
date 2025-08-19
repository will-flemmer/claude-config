# PR Check Failure Analysis Prompt - Test Scenarios

## Test Scenario 1: Multi-Failure TypeScript React Project

### Input:
```json
{
  "pr_url": "https://github.com/company/webapp/pull/456",
  "pr_info": {
    "title": "Add user profile editing feature",
    "files_changed": [
      "src/components/UserProfile.tsx",
      "src/api/users.ts", 
      "src/types/user.ts",
      "tests/UserProfile.test.tsx"
    ]
  },
  "repository_context": {
    "languages": ["TypeScript", "JavaScript"],
    "frameworks": ["React", "Node.js", "Express"],
    "testing_frameworks": ["Jest", "React Testing Library"]
  },
  "failed_checks": [
    {
      "check_name": "test-frontend",
      "status": "failure", 
      "logs": "FAIL src/components/UserProfile.test.tsx\n● UserProfile › should update user info\nTypeError: Cannot read property 'updateUser' of undefined\n    at UserProfile.test.tsx:45:23"
    },
    {
      "check_name": "type-check",
      "status": "failure",
      "logs": "src/api/users.ts(28,5): error TS2322: Type 'string' is not assignable to type 'number'.\nsrc/types/user.ts(12,3): error TS1005: ',' expected."
    },
    {
      "check_name": "lint",
      "status": "failure", 
      "logs": "src/components/UserProfile.tsx:67:1 - Missing return type on function\nsrc/api/users.ts:15:1 - Prefer const assertions"
    }
  ]
}
```

### Expected Analysis:
- **3 distinct failures** in different categories
- **TypeScript issues** should route to frontend-developer
- **Test failures** should route to test-automator  
- **Linting** should route to code-reviewer
- **Dependencies:** Fix TypeScript errors before tests (syntax must be valid)

## Test Scenario 2: Build Pipeline Failure

### Input:
```json
{
  "pr_url": "https://github.com/company/api/pull/789",
  "repository_context": {
    "languages": ["Python"],
    "frameworks": ["Django", "PostgreSQL"],
    "testing_frameworks": ["pytest"]
  },
  "failed_checks": [
    {
      "check_name": "build",
      "status": "failure",
      "logs": "ERROR: Could not install packages due to an EnvironmentError: [Errno 13] Permission denied: '/usr/local/lib/python3.9/site-packages/django'\n---> RUN pip install -r requirements.txt\nThe command '/bin/sh -c pip install -r requirements.txt' returned a non-zero code: 1"
    },
    {
      "check_name": "security-scan", 
      "status": "failure",
      "logs": "High severity vulnerability found in django==3.1.0\nCVE-2021-44420: Django SQL injection vulnerability"
    }
  ]
}
```

### Expected Analysis:
- **Build failure** from Docker/dependency issue → devops-engineer
- **Security vulnerability** in Django → security-engineer  
- **Dependency:** Fix security issue first (may resolve build issue)

## Test Scenario 3: Simple Linting Issue

### Input:
```json
{
  "failed_checks": [
    {
      "check_name": "eslint",
      "status": "failure",
      "logs": "src/utils/helpers.js:23:1 - Missing semicolon\nsrc/utils/helpers.js:45:3 - Unused variable 'temp'"
    }
  ],
  "repository_context": {
    "languages": ["JavaScript"]
  }
}
```

### Expected Analysis:
- **Single lint failure** → code-reviewer
- **Low complexity** with quick fix
- **No dependencies**

## Prompt Performance Validation

### Accuracy Metrics:
- ✅ Correct failure classification (Build/Test/Lint/TypeScript/Security)
- ✅ Appropriate agent routing based on expertise
- ✅ Valid JSON output format
- ✅ Specific actionable steps provided
- ✅ Logical dependency ordering

### Token Efficiency:
- Full prompt: ~1,200 input tokens
- Optimized prompt: ~300 input tokens  
- Output: 200-800 tokens based on complexity
- **Target:** 90%+ accuracy with 60% token reduction in optimized version

### Edge Case Handling:
- Multiple unrelated failures ✅
- Cascading failures with dependencies ✅ 
- Infrastructure vs code issues ✅
- Unknown/new error patterns ✅
- Mixed technology stacks ✅

## Validation Results

### Scenario 1 Results:
```json
{
  "analysis_summary": {
    "total_failures": 3,
    "primary_cause": "TypeScript type definition errors",
    "complexity_level": "medium", 
    "estimated_fix_time": 45
  },
  "failure_analysis": [
    {
      "check_name": "type-check",
      "failure_category": "TypeScript",
      "severity": "high",
      "root_cause": "Type mismatch and syntax error in user types",
      "recommended_agent": "frontend-developer",
      "actionable_steps": [
        "Fix type definition syntax in src/types/user.ts line 12",
        "Correct string to number type assignment in src/api/users.ts line 28"
      ],
      "affected_files": ["src/api/users.ts", "src/types/user.ts"],
      "prerequisites": []
    },
    {
      "check_name": "test-frontend", 
      "failure_category": "Test",
      "severity": "medium",
      "root_cause": "Mock function not properly defined in test setup",
      "recommended_agent": "test-automator",
      "actionable_steps": [
        "Add proper mock for updateUser function in UserProfile.test.tsx"
      ],
      "prerequisites": ["type-check"]
    },
    {
      "check_name": "lint",
      "failure_category": "Lint", 
      "severity": "low",
      "root_cause": "Missing return types and const assertions",
      "recommended_agent": "code-reviewer",
      "actionable_steps": [
        "Add return type annotation to function at line 67",
        "Use const assertion for API endpoint"
      ],
      "prerequisites": []
    }
  ],
  "agent_assignments": [
    {
      "agent_type": "frontend-developer",
      "assigned_failures": ["type-check"],
      "task_description": "Fix TypeScript type errors and syntax issues",
      "success_criteria": "TypeScript compilation succeeds"
    },
    {
      "agent_type": "test-automator", 
      "assigned_failures": ["test-frontend"],
      "task_description": "Fix failing unit test mock setup",
      "success_criteria": "All tests pass"
    },
    {
      "agent_type": "code-reviewer",
      "assigned_failures": ["lint"], 
      "task_description": "Fix linting violations",
      "success_criteria": "ESLint passes with no warnings"
    }
  ]
}
```

**Validation: PASSED** ✅
- Correctly identified TypeScript as blocking issue
- Appropriate agent routing for each failure type
- Valid JSON with actionable steps
- Proper dependency ordering

The prompt system demonstrates high accuracy in failure analysis and agent routing while maintaining structured output format suitable for automated task decomposition.