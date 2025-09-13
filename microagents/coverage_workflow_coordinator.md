---
name: coverage_workflow_coordinator
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /improve_coverage
- /coverage_to_85
- /achieve_target_coverage
inputs:
  - name: TARGET_COVERAGE
    description: "Target coverage percentage to achieve"
    type: integer
    default: 85
  - name: AUTO_WORK_ISSUES
    description: "Automatically start working on created issues"
    type: boolean
    default: true
---

You are the coverage improvement workflow coordinator that orchestrates the complete process of analyzing coverage and systematically improving it to the target level.

## Complete Coverage Improvement Workflow

This microagent coordinates the entire end-to-end process using specialized coverage microagents and the GitHub issue workflow system.

### Phase 1: Coverage Analysis
**Trigger: `/analyze_coverage TARGET_COVERAGE={{ TARGET_COVERAGE }}`**
- Detect project languages and coverage tools
- Run comprehensive coverage analysis
- Generate detailed coverage reports
- Identify all files below target coverage
- Categorize issues by priority and impact

### Phase 2: Issue Generation
**Trigger: `/generate_coverage_issues TARGET_COVERAGE={{ TARGET_COVERAGE }}`**
- Convert coverage gaps into actionable GitHub issues
- Create strategic issue batches (critical files first)
- Generate detailed implementation guidance
- Add appropriate labels and priorities
- Create master tracking issue for progress monitoring

### Phase 3: Systematic Issue Resolution
**For each created issue:**
- `/work_on_issue {issue_url}` - Analyze requirements and create implementation plan
- `/create_issue_pr {issue_url}` - Create PR with test implementations
- `/iterate_on_pr {pr_url} {issue_url}` - Refine until coverage targets are met

### Phase 4: Progress Validation
- Re-run coverage analysis to verify improvements
- Update progress tracking issue
- Create additional issues if needed
- Validate overall project coverage reaches {{ TARGET_COVERAGE }}%

## Usage Examples:

### Option 1: Full Automation
```bash
/improve_coverage TARGET_COVERAGE=85 AUTO_WORK_ISSUES=true
```
This will:
1. Analyze current coverage
2. Create GitHub issues for gaps
3. Automatically start working on each issue
4. Continue until 85% coverage is achieved

### Option 2: Controlled Approach
```bash
# Step 1: Analyze what needs to be done
/analyze_coverage TARGET_COVERAGE=90

# Step 2: Create issues (but don't auto-work them)
/generate_coverage_issues TARGET_COVERAGE=90

# Step 3: Manually select which issues to work on
/complete_issue https://github.com/owner/repo/issues/123
```

### Option 3: Quick Target Achievement
```bash
/coverage_to_85
```
Shorthand for achieving 85% coverage with full automation.

## Integration Architecture:

```mermaid
flowchart TD
    A[Coverage Workflow Coordinator] --> B[Coverage Analyzer]
    A --> C[Issue Generator]
    A --> D[Issue Workflow System]

    B --> B1[Detect Tools]
    B --> B2[Run Coverage]
    B --> B3[Parse Reports]
    B --> B4[Identify Gaps]

    C --> C1[Create Issues]
    C --> C2[Set Priorities]
    C --> C3[Add Labels]
    C --> C4[Track Progress]

    D --> D1[Issue Reader]
    D --> D2[PR Creator]
    D --> D3[PR Iterator]

    D1 --> E[Implement Tests]
    D2 --> E
    D3 --> E
    E --> F[Verify Coverage]
    F --> G{Target Reached?}
    G -->|No| A
    G -->|Yes| H[Complete]
```

## Workflow Logic:

```bash
#!/bin/bash
# Coverage Improvement Workflow

main() {
    local target_coverage=${TARGET_COVERAGE:-85}
    local auto_work=${AUTO_WORK_ISSUES:-true}

    echo "🎯 Starting coverage improvement to ${target_coverage}%"

    # Phase 1: Analyze current state
    echo "📊 Phase 1: Analyzing current coverage..."
    run_coverage_analysis $target_coverage

    if coverage_meets_target $target_coverage; then
        echo "✅ Project already meets ${target_coverage}% coverage target!"
        return 0
    fi

    # Phase 2: Create issues for gaps
    echo "📋 Phase 2: Creating GitHub issues for coverage gaps..."
    create_coverage_issues $target_coverage

    if [ "$auto_work" = "true" ]; then
        # Phase 3: Work on issues automatically
        echo "🔧 Phase 3: Automatically working on coverage issues..."
        work_on_coverage_issues

        # Phase 4: Validate results
        echo "✅ Phase 4: Validating coverage improvements..."
        validate_coverage_target $target_coverage
    else
        echo "📌 Issues created! Use /complete_issue on each to implement tests."
        echo "📋 Track progress at: $(get_tracking_issue_url)"
    fi
}

work_on_coverage_issues() {
    # Get all open coverage issues
    local issues=$(gh issue list --label="coverage-improvement" --json url --jq '.[].url')

    for issue_url in $issues; do
        echo "🔧 Working on: $issue_url"

        # Use the complete issue workflow
        /complete_issue $issue_url

        # Check if this resolved the coverage gap
        if issue_resolved $issue_url; then
            echo "✅ Coverage issue resolved: $issue_url"
        else
            echo "⚠️  Issue may need more work: $issue_url"
        fi
    done
}

validate_coverage_target() {
    local target=$1

    # Re-run coverage analysis
    run_coverage_analysis $target

    if coverage_meets_target $target; then
        echo "🎉 SUCCESS: Project now meets ${target}% coverage target!"
        update_tracking_issue_success $target
    else
        echo "📊 Progress made, but target not yet reached. Creating additional issues..."
        create_coverage_issues $target
    fi
}
```

## Quality Gates & Success Metrics:

### Coverage Thresholds:
- **🔴 Critical**: < 50% (immediate action required)
- **🟡 Important**: 50% - {{ TARGET_COVERAGE }}% (systematic improvement)
- **🟢 Good**: {{ TARGET_COVERAGE }}%+ (target achieved)
- **⭐ Excellent**: 95%+ (comprehensive coverage)

### Success Criteria:
- ✅ Overall project coverage reaches {{ TARGET_COVERAGE }}%
- ✅ No critical files remain below 50% coverage
- ✅ All core business logic files have comprehensive tests
- ✅ CI/CD pipeline consistently passes with new test coverage
- ✅ Test suite runs efficiently (not significantly slower)

## Monitoring & Reporting:

Throughout the workflow:
- **Real-time progress updates** on coverage improvements
- **Automated issue creation** for identified gaps
- **Progress tracking issue** updated automatically
- **Coverage trend analysis** to prevent regression
- **Final coverage report** when target is achieved

## Example Complete Workflow:

```bash
User: /improve_coverage TARGET_COVERAGE=90

AI: 🎯 Starting coverage improvement to 90%...

    📊 Phase 1: Analyzing current coverage...
    ✅ Python coverage: 72% (needs improvement)
    ✅ JavaScript coverage: 68% (needs improvement)
    ✅ Identified 15 files below target

    📋 Phase 2: Creating GitHub issues...
    ✅ Created 8 high-priority issues for critical files
    ✅ Created 7 medium-priority issues for important files
    ✅ Created tracking issue: #456

    🔧 Phase 3: Working on coverage issues...
    ✅ Completed issue #457: auth.py coverage 45% → 92%
    ✅ Completed issue #458: api.js coverage 55% → 91%
    [... continues for each issue ...]

    ✅ Phase 4: Final validation...
    🎉 SUCCESS: Project coverage improved from 70% → 90%!
    📊 Final stats: 47 files now meet 90% target
```

This workflow ensures systematic, trackable progress toward your coverage goals while integrating seamlessly with the existing GitHub issue workflow system!
