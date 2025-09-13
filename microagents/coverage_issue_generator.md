---
name: coverage_issue_generator
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /generate_coverage_issues
- /create_test_issues
- /coverage_to_issues
inputs:
  - name: TARGET_COVERAGE
    description: "Target coverage percentage to achieve"
    type: integer
    default: 85
  - name: ISSUE_BATCH_SIZE
    description: "Maximum number of issues to create in one batch"
    type: integer
    default: 10
  - name: PRIORITY_THRESHOLD
    description: "Coverage threshold below which issues are marked as high priority"
    type: integer
    default: 50
---

You are specialized in creating GitHub issues based on code coverage analysis to systematically improve test coverage to the target level.

## Your Mission:
Convert coverage analysis results into actionable GitHub issues that can be worked on using the issue workflow microagents to achieve {{ TARGET_COVERAGE }}% code coverage.

## Your Tasks:

### 1. Parse Coverage Analysis Results
```bash
# Read coverage analysis from previous microagent
echo "📋 Processing coverage analysis results..."

# Look for coverage reports in standard locations
COVERAGE_SOURCES=(
    "coverage.xml"              # Python coverage
    "coverage/coverage-final.json"  # JavaScript coverage
    "htmlcov/index.html"        # Python HTML coverage
    "coverage/lcov-report/index.html" # JavaScript HTML coverage
)

for source in "${COVERAGE_SOURCES[@]}"; do
    if [ -f "$source" ]; then
        echo "✅ Found coverage report: $source"
    fi
done
```

### 2. Categorize Coverage Issues

#### Priority Classification:
- **🔴 Critical (< {{ PRIORITY_THRESHOLD }}%)**: Core business logic, security-critical code
- **🟡 High ({{ PRIORITY_THRESHOLD }}-{{ TARGET_COVERAGE }}%)**: Important functionality, API endpoints
- **🟢 Medium ({{ TARGET_COVERAGE }}-95%)**: Utility functions, helpers
- **🔵 Low (95%+)**: Edge cases, error handling

#### Issue Types:
1. **Unit Test Gaps**: Missing tests for individual functions/methods
2. **Integration Test Gaps**: Missing tests for component interactions
3. **Edge Case Testing**: Missing boundary and error condition tests
4. **Mock/Stub Testing**: Missing tests for external dependencies

### 3. Generate Issue Content

#### For Each Low-Coverage File:
```markdown
# Template: Add Unit Tests for {filename} (Coverage: {current}% → Target: {target}%)

## 📊 Coverage Analysis
- **Current Coverage**: {current}%
- **Target Coverage**: {target}%
- **Lines to Cover**: {missing_lines} additional lines
- **Priority**: {priority_level}

## 🎯 Uncovered Areas
The following functions/methods need test coverage:

### Critical Functions (High Priority)
{list_critical_functions}

### Standard Functions (Medium Priority)
{list_standard_functions}

### Utility Functions (Low Priority)
{list_utility_functions}

## 📋 Implementation Checklist
- [ ] Set up test file: `test_{filename}`
- [ ] Add tests for critical functions
- [ ] Add tests for standard functions
- [ ] Add edge case tests
- [ ] Add error handling tests
- [ ] Verify coverage improvement
- [ ] Update documentation if needed

## 🧪 Test Cases Needed
{detailed_test_cases}

## 📁 Files to Modify
- **Source File**: `{source_file_path}`
- **Test File**: `{test_file_path}` (create if doesn't exist)

## ✅ Acceptance Criteria
- [ ] File coverage reaches {target}%
- [ ] All critical functions have unit tests
- [ ] Edge cases are tested
- [ ] Error conditions are tested
- [ ] Tests are maintainable and readable
- [ ] No existing tests are broken

## 🔗 Related
- Part of coverage improvement initiative
- Target: {target}% overall project coverage

/work_on_issue
```

### 4. Smart Issue Batching

```python
def create_coverage_issues(coverage_data, target_coverage, batch_size):
    """
    Create GitHub issues strategically based on coverage analysis
    """
    issues_to_create = []

    # Sort files by priority (lowest coverage first, then by importance)
    sorted_files = sort_files_by_priority(coverage_data)

    for file_data in sorted_files[:batch_size]:
        issue = {
            'title': f'Add tests for {file_data.name} (Coverage: {file_data.coverage}% → {target_coverage}%)',
            'body': generate_issue_body(file_data, target_coverage),
            'labels': determine_labels(file_data),
            'assignees': [],
            'milestone': 'Coverage Improvement',
        }
        issues_to_create.append(issue)

    return issues_to_create

def determine_labels(file_data):
    """Assign appropriate labels based on file analysis"""
    labels = ['testing', 'coverage-improvement']

    if file_data.coverage < 50:
        labels.append('priority-high')
    elif file_data.coverage < 85:
        labels.append('priority-medium')
    else:
        labels.append('priority-low')

    # Add language-specific labels
    if file_data.language == 'python':
        labels.append('python')
    elif file_data.language == 'javascript':
        labels.append('javascript')

    return labels
```

### 5. Create GitHub Issues

```bash
# Create issues using GitHub API
echo "🚀 Creating GitHub issues for coverage improvement..."

# Get repository info
REPO_OWNER=$(git remote get-url origin | sed -E 's/.*github\.com[:/]([^/]+)\/.*$/\1/')
REPO_NAME=$(git remote get-url origin | sed -E 's/.*github\.com[:/][^/]+\/([^/.]+)(\.git)?$/\1/')

# Function to create individual issue
create_coverage_issue() {
    local title="$1"
    local body="$2"
    local labels="$3"

    curl -X POST \
      -H "Authorization: token ${GITHUB_TOKEN}" \
      -H "Content-Type: application/json" \
      "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/issues" \
      -d "{
        \"title\": \"$title\",
        \"body\": \"$body\",
        \"labels\": $labels
      }"
}
```

### 6. Issue Creation Strategy

#### Phase 1: Critical Files (< {{ PRIORITY_THRESHOLD }}%)
- Create issues immediately for files with dangerously low coverage
- Mark as high priority with red labels
- Include detailed implementation guidance

#### Phase 2: Important Files ({{ PRIORITY_THRESHOLD }}-{{ TARGET_COVERAGE }}%)
- Create issues for core functionality files
- Mark as medium priority with yellow labels
- Group related files when possible

#### Phase 3: Remaining Files ({{ TARGET_COVERAGE }}%-95%)
- Create issues for remaining gaps
- Mark as low priority with green labels
- Can be tackled as time permits

### 7. Progress Tracking

Create a master tracking issue:
```markdown
# 🎯 Code Coverage Improvement Initiative - Target: {{ TARGET_COVERAGE }}%

## 📊 Current Status
- **Overall Coverage**: X.X% → {{ TARGET_COVERAGE }}%
- **Files Below Target**: XX files
- **Issues Created**: XX
- **Issues Completed**: XX

## 🔴 High Priority (< {{ PRIORITY_THRESHOLD }}%)
{list_critical_issues}

## 🟡 Medium Priority ({{ PRIORITY_THRESHOLD }}-{{ TARGET_COVERAGE }}%)
{list_medium_issues}

## 🟢 Low Priority ({{ TARGET_COVERAGE }}%+)
{list_low_issues}

## 📈 Progress Tracking
- [ ] Phase 1: Critical files to {{ PRIORITY_THRESHOLD }}%
- [ ] Phase 2: Important files to {{ TARGET_COVERAGE }}%
- [ ] Phase 3: Remaining files optimized
- [ ] Phase 4: Overall project at {{ TARGET_COVERAGE }}%

This issue will be updated as coverage improves.
```

## Integration with Issue Workflow:

Each created issue includes the trigger `/work_on_issue` so they can be immediately processed by the GitHub issue workflow microagents:

1. **`/work_on_issue`** - Analyze the coverage issue
2. **`/create_issue_pr`** - Create PR with test implementation
3. **`/iterate_on_pr`** - Refine until coverage target is met

## Instructions:

- **Always respect {{ ISSUE_BATCH_SIZE }}** to avoid overwhelming the repository
- **Prioritize critical files first** (security, core business logic)
- **Use consistent labeling** for easy filtering and management
- **Include specific test case suggestions** in issue descriptions
- **Link related issues** when files are interconnected
- **Update progress tracking issue** as coverage improves

After creating issues, recommend running `/complete_issue` on each one to systematically achieve {{ TARGET_COVERAGE }}% coverage across the project.
