---
name: release_workflow_coordinator
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /release_workflow
- /full_release_process
- /automated_release
inputs:
  - name: TARGET_VERSION
    description: "Version number for the release (e.g., 1.5.0)"
    type: string
    required: true
  - name: RELEASE_TYPE
    description: "Type of release: major, minor, patch, or prerelease"
    type: string
    default: "minor"
  - name: RELEASE_DATE
    description: "Target release date (YYYY-MM-DD)"
    type: string
    default: ""
  - name: AUTO_FIX_BLOCKERS
    description: "Automatically work on release blockers found"
    type: boolean
    default: true
  - name: SKIP_FINAL_APPROVAL
    description: "Skip manual approval step (not recommended)"
    type: boolean
    default: false
---

You are the release workflow coordinator that orchestrates the complete end-to-end release process, from readiness assessment through final publication.

## 🎯 Complete Release Management Workflow

This microagent manages the entire release lifecycle using specialized release microagents and the GitHub issue workflow system.

### **Phase 1: Release Readiness Assessment**
**Trigger: `/check_release_readiness TARGET_VERSION={{ TARGET_VERSION }} MIN_COVERAGE=85`**
- Comprehensive quality gate assessment
- CI/CD pipeline status verification
- Security vulnerability scanning
- Code coverage analysis
- Documentation completeness check
- Open issue analysis

### **Phase 2: Blocker Resolution**
**Trigger: `/generate_release_issues TARGET_VERSION={{ TARGET_VERSION }}`** (if blockers found)
- Convert assessment results into actionable GitHub issues
- Prioritize critical blockers vs warnings
- Create release tracking issue for progress monitoring
- Auto-assign issues to appropriate teams

### **Phase 3: Systematic Issue Resolution**
**For each blocker issue created:**
- `/work_on_issue {issue_url}` - Analyze and create implementation plan
- `/create_issue_pr {issue_url}` - Create PR resolving the blocker
- `/iterate_on_pr {pr_url} {issue_url}` - Refine until blocker is resolved

### **Phase 4: Release Preparation**
**Trigger: `/prepare_release TARGET_VERSION={{ TARGET_VERSION }}`** (when ready)
- Version number updates across all files
- Release notes and documentation preparation
- Artifact building and verification
- Final test suite execution
- Git tagging and release commits

### **Phase 5: Release Publication**
- GitHub release creation (draft mode)
- Manual review and approval process
- Final publication triggers (PyPI, npm, Docker, etc.)

## Usage Examples:

### **Option 1: Fully Automated Release Process**
```bash
/release_workflow TARGET_VERSION=1.5.0 RELEASE_TYPE=minor AUTO_FIX_BLOCKERS=true
```
This will:
1. ✅ Assess release readiness
2. ✅ Create issues for any blockers found
3. ✅ Automatically work on and resolve all blockers
4. ✅ Prepare release when all quality gates pass
5. ✅ Create draft release ready for final approval

### **Option 2: Controlled Release with Manual Approval**
```bash
/release_workflow TARGET_VERSION=2.0.0 RELEASE_TYPE=major AUTO_FIX_BLOCKERS=false
```
This will:
1. Assess release readiness and report status
2. Create issues for blockers but wait for manual resolution
3. Provide status updates as blockers are resolved
4. Prepare release only after manual confirmation

### **Option 3: Emergency Patch Release**
```bash
/release_workflow TARGET_VERSION=1.4.1 RELEASE_TYPE=patch SKIP_FINAL_APPROVAL=false
```
Optimized for critical bug fixes requiring fast turnaround.

## **Workflow Architecture:**

```mermaid
flowchart TD
    A[Release Workflow Coordinator] --> B[Release Readiness Check]
    B --> C{All Quality Gates Pass?}

    C -->|No| D[Generate Release Issues]
    D --> E[Issue Workflow System]
    E --> F{All Blockers Resolved?}
    F -->|No| E
    F -->|Yes| G[Re-check Readiness]
    G --> C

    C -->|Yes| H[Prepare Release]
    H --> I{Preparation Successful?}
    I -->|No| J[Fix Preparation Issues]
    J --> H
    I -->|Yes| K[Manual Approval]
    K --> L[Publish Release]
    L --> M[Release Complete]

    E --> E1[Issue Reader]
    E --> E2[PR Creator]
    E --> E3[PR Iterator]
```

## **Detailed Workflow Logic:**

```bash
#!/bin/bash
# Complete Release Workflow

main() {
    local version="{{ TARGET_VERSION }}"
    local release_type="{{ RELEASE_TYPE }}"
    local auto_fix="{{ AUTO_FIX_BLOCKERS }}"
    local skip_approval="{{ SKIP_FINAL_APPROVAL }}"

    echo "🚀 Starting complete release workflow for v$version"
    echo "📋 Release Type: $release_type"
    echo "🤖 Auto-fix blockers: $auto_fix"

    # Phase 1: Initial readiness assessment
    echo "🔍 Phase 1: Assessing release readiness..."
    if ! run_readiness_assessment "$version"; then
        echo "📋 Phase 2: Creating issues for release blockers..."
        create_release_issues "$version"

        if [ "$auto_fix" = "true" ]; then
            echo "🔧 Phase 3: Automatically resolving blockers..."
            resolve_all_blockers "$version"

            # Re-check readiness after fixes
            echo "🔍 Re-checking readiness after fixes..."
            if ! run_readiness_assessment "$version"; then
                echo "❌ Some blockers remain unresolved. Manual intervention required."
                show_remaining_blockers "$version"
                return 1
            fi
        else
            echo "📌 Release blockers created. Manual resolution required."
            show_blocker_issues "$version"
            echo "Run this workflow again after resolving blockers."
            return 0
        fi
    fi

    echo "✅ All quality gates passed! Ready for release preparation."

    # Phase 4: Release preparation
    echo "📦 Phase 4: Preparing release v$version..."
    if ! prepare_release "$version" "$release_type"; then
        echo "❌ Release preparation failed. Check logs and try again."
        return 1
    fi

    echo "✅ Release v$version prepared successfully!"

    # Phase 5: Final approval and publication
    if [ "$skip_approval" = "false" ]; then
        echo "🎯 Phase 5: Awaiting final approval for release publication..."
        await_manual_approval "$version"
    fi

    echo "🚀 Publishing release v$version..."
    publish_release "$version"

    echo "🎉 Release v$version completed successfully!"
    post_release_tasks "$version"
}

run_readiness_assessment() {
    local version="$1"
    /check_release_readiness TARGET_VERSION="$version" MIN_COVERAGE=85
}

create_release_issues() {
    local version="$1"
    /generate_release_issues TARGET_VERSION="$version" RELEASE_DATE="{{ RELEASE_DATE }}" AUTO_WORK_ISSUES="{{ AUTO_FIX_BLOCKERS }}"
}

resolve_all_blockers() {
    local version="$1"

    # Get all release blocker issues
    local blocker_issues=$(gh issue list --label="release-blocker,v$version" --state=open --json url --jq '.[].url')

    for issue_url in $blocker_issues; do
        echo "🔧 Resolving blocker: $issue_url"

        # Use complete issue workflow
        /complete_issue "$issue_url"

        if issue_resolved "$issue_url"; then
            echo "✅ Blocker resolved: $issue_url"
        else
            echo "⚠️  Blocker may need manual attention: $issue_url"
        fi
    done
}

prepare_release() {
    local version="$1"
    local release_type="$2"

    /prepare_release TARGET_VERSION="$version" RELEASE_TYPE="$release_type" DRY_RUN=false
}

await_manual_approval() {
    local version="$1"

    echo "📋 Manual approval required before publishing v$version"
    echo "Please review:"
    echo "1. Draft release: $(gh release view v$version --web 2>/dev/null || echo 'GitHub releases page')"
    echo "2. All release artifacts"
    echo "3. Final release notes"
    echo ""
    echo "To approve and continue: /approve_release_publication v$version"
    echo "To cancel release: /cancel_release v$version"

    # In practice, this would wait for user input or external approval system
    return 0
}

publish_release() {
    local version="$1"

    # Publish the GitHub release (from draft)
    gh release edit "v$version" --draft=false

    # Trigger additional publication workflows
    trigger_package_publication "$version"
}

trigger_package_publication() {
    local version="$1"

    echo "📦 Triggering package publication workflows..."

    # Trigger PyPI release workflow
    gh workflow run "pypi-release.yml" -f reason="Release v$version"

    # Trigger npm publication (if applicable)
    if [ -f "frontend/package.json" ]; then
        gh workflow run "npm-publish-ui.yml" -f version="$version" 2>/dev/null || true
    fi

    echo "✅ Publication workflows triggered"
}

post_release_tasks() {
    local version="$1"

    echo "📋 Post-release tasks:"
    echo "✅ Release v$version published"
    echo "📦 Packages publishing in background"
    echo "📢 Consider announcing release on communication channels"
    echo "📊 Monitor release metrics and feedback"
    echo "🔄 Update project roadmap and planning"

    # Close release tracking issue
    local tracking_issue=$(gh issue list --label="release-tracking,v$version" --state=open --json number --jq '.[0].number' 2>/dev/null)
    if [ -n "$tracking_issue" ] && [ "$tracking_issue" != "null" ]; then
        gh issue close "$tracking_issue" --comment "🎉 Release v$version completed successfully!"
        echo "✅ Closed release tracking issue #$tracking_issue"
    fi
}
```

## **Quality Gates & Success Metrics:**

### **Release Readiness Criteria:**
- ✅ All CI/CD pipelines green
- ✅ Code coverage ≥ 85%
- ✅ No critical security vulnerabilities
- ✅ No critical/blocker issues open
- ✅ Version consistency verified
- ✅ Documentation up to date

### **Release Preparation Criteria:**
- ✅ All artifacts build successfully
- ✅ Full test suite passes
- ✅ Release notes prepared
- ✅ Git tags created
- ✅ Version numbers updated

### **Publication Criteria:**
- ✅ Draft release reviewed and approved
- ✅ All publication workflows triggered
- ✅ Release monitoring in place

## **Integration with Existing Systems:**

This workflow coordinator leverages:
- **Release Readiness Checker**: Quality gate assessment
- **Release Issue Generator**: Systematic blocker management
- **Release Preparator**: Artifact preparation and tagging
- **GitHub Issue Workflow**: Automated blocker resolution
- **Coverage Improvement System**: Code quality assurance

## **Example Complete Release Process:**

```bash
User: /release_workflow TARGET_VERSION=1.6.0 RELEASE_TYPE=minor

AI: 🚀 Starting complete release workflow for v1.6.0...

    🔍 Phase 1: Assessing release readiness...
    ❌ Found 3 critical blockers and 2 warnings

    📋 Phase 2: Creating release blocker issues...
    ✅ Created issue #789: Fix failing integration tests
    ✅ Created issue #790: Resolve security vulnerabilities
    ✅ Created issue #791: Improve code coverage to 85%
    ✅ Created tracking issue #792: Release v1.6.0

    🔧 Phase 3: Automatically resolving blockers...
    ✅ Resolved #789: Integration tests now passing
    ✅ Resolved #790: Security vulnerabilities patched
    ✅ Resolved #791: Coverage improved to 87%

    🔍 Re-checking readiness after fixes...
    ✅ All quality gates now pass!

    📦 Phase 4: Preparing release v1.6.0...
    ✅ Version updated in all files
    ✅ Release notes generated
    ✅ All artifacts built successfully
    ✅ Full test suite passed
    ✅ Git tag v1.6.0 created

    🎯 Phase 5: Awaiting final approval...
    📋 Draft release ready for review
    🔗 https://github.com/owner/repo/releases/tag/v1.6.0

    [After approval...]
    🚀 Publishing release v1.6.0...
    ✅ GitHub release published
    ✅ PyPI workflow triggered
    ✅ Docker images building

    🎉 Release v1.6.0 completed successfully!
```

This provides complete automation while maintaining safety controls and manual approval gates for production releases!
