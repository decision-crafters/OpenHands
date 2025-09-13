# CI Fixer Microagent

## Description
This microagent automatically fixes failing continuous integration tests by pulling PR branches, analyzing CI failures through GitHub API, reproducing errors locally, fixing them, and verifying the fixes.

## Prerequisites
- GitHub MCP server configured with appropriate repository access
- Git configured with push access to the repository
- Local development environment matching CI requirements

## Input Requirements
When multiple pull requests exist, the agent will:
1. List all open PRs with failing CI checks
2. Ask the user to select which PR to focus on
3. Proceed with the selected PR

For a single PR or when PR is specified, provide:
- Pull request URL or number
- Repository information (owner/name)

## Workflow

### 1. PR Selection Phase
```
If multiple PRs with failing CI:
  - List all PRs with failing checks
  - Show PR title, number, and failing job names
  - Ask user: "Which PR would you like me to fix? Please provide the PR number."
  - Wait for user selection
```

### 2. Initial Setup
```
- Pull the PR branch locally
- Fetch latest changes
- Identify all failing CI workflows/jobs
```

### 3. Failure Analysis
```
For each failing workflow:
  - Use GitHub API to fetch workflow run details
  - Extract error logs and failure points
  - Identify the specific steps that failed
  - Parse error messages and stack traces
```

### 4. Local Reproduction
```
- Set up environment matching CI configuration
- Run the failing workflow steps locally
- Reproduce the exact error conditions
- Capture local error output for comparison
```

### 5. Fix Implementation
```
Based on error analysis:
  - If test failure: Fix test logic or update test expectations
  - If lint error: Run appropriate formatters/linters
  - If type error: Fix type annotations or imports
  - If build error: Resolve dependencies or compilation issues
  - If integration failure: Update API calls or configurations
```

### 6. Local Verification
```
- Re-run the previously failing workflow locally
- Ensure all steps pass
- Run any additional related tests
- Verify no new issues introduced
```

### 7. Push and Monitor
```
- Commit fixes with descriptive message
- Push to the PR branch
- Wait 90 seconds for CI to trigger
- Poll GitHub API for workflow status
- Report results to user
```

### 8. Iteration (if needed)
```
If CI still failing:
  - Analyze new/remaining failures
  - Repeat fix process
  - Maximum 3 iterations before requesting user intervention
```

## Example Prompts

### Single PR Fix
```
Please fix the failing CI tests for PR #6070 in All-Hands-AI/OpenHands.
Pull the branch, reproduce the failures locally, fix them, and verify CI passes.
```

### Multiple PR Selection
```
Agent: I found 3 PRs with failing CI checks:
  PR #6070: "Add Japanese translations" - Failing: lint, frontend-tests
  PR #6082: "Refactor runtime system" - Failing: backend-tests
  PR #6095: "Update dependencies" - Failing: security-scan

Which PR would you like me to fix? Please provide the PR number.

User: Fix PR #6070

Agent: Starting CI fix process for PR #6070...
```

## Error Handling

### Common CI Issues and Fixes

1. **Linting Errors**
   - Run `make lint` or equivalent
   - Auto-fix with formatters when possible
   - Manual fix for logic issues

2. **Test Failures**
   - Update test expectations
   - Fix test setup/teardown
   - Handle async/timing issues

3. **Type Checking**
   - Add missing type annotations
   - Fix type mismatches
   - Update import statements

4. **Build Failures**
   - Update dependencies
   - Fix import paths
   - Resolve version conflicts

5. **Security Scans**
   - Update vulnerable dependencies
   - Apply security patches
   - Adjust security configurations

## Success Criteria
- All CI workflows passing (green checks)
- No regression in other tests
- Clean commit history
- Descriptive fix messages

## Limitations
- Cannot fix issues requiring external service changes
- May need manual intervention for complex architectural problems
- Limited to 3 automatic retry attempts
- Requires appropriate repository permissions

## GitHub API Endpoints Used
- `GET /repos/{owner}/{repo}/pulls` - List PRs
- `GET /repos/{owner}/{repo}/pulls/{pull_number}` - PR details
- `GET /repos/{owner}/{repo}/actions/runs` - Workflow runs
- `GET /repos/{owner}/{repo}/actions/runs/{run_id}/jobs` - Job details
- `GET /repos/{owner}/{repo}/actions/runs/{run_id}/logs` - Download logs
- `GET /repos/{owner}/{repo}/commits/{ref}/check-runs` - Check run status

## Required MCP Tools
- `mcp_github_list_pulls` - List repository pull requests
- `mcp_github_get_pr` - Get PR details
- `mcp_github_get_workflow_runs` - Get workflow run information
- `mcp_github_get_job_logs` - Get CI job logs
- `mcp_github_get_check_runs` - Get check run status

## Configuration
```yaml
ci_fixer:
  max_retry_attempts: 3
  wait_time_after_push: 90  # seconds
  auto_commit_message_prefix: "fix(ci): "
  verbose_logging: true
  parallel_job_analysis: true
```