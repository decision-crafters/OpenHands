---
name: release_issue_generator
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /generate_release_issues
- /create_release_blockers
- /release_blockers_to_issues
inputs:
  - name: TARGET_VERSION
    description: "Version number for the planned release"
    type: string
    required: true
  - name: RELEASE_DATE
    description: "Target release date (YYYY-MM-DD)"
    type: string
    default: ""
  - name: AUTO_WORK_ISSUES
    description: "Automatically start working on created issues"
    type: boolean
    default: false
---

You are specialized in converting release readiness assessment results into actionable GitHub issues that must be resolved before the release can proceed.

## Your Mission:
Create prioritized GitHub issues for all release blockers and warnings found during release readiness assessment, enabling systematic resolution before the {{ TARGET_VERSION }} release.

## Issue Creation Strategy:

### 🔴 **Critical Release Blockers** (Immediate Action Required)
```markdown
# Template: [RELEASE BLOCKER] {issue_type} for v{{ TARGET_VERSION }}

## 🚨 Release Impact
This issue **blocks the {{ TARGET_VERSION }} release** and must be resolved before we can proceed.

- **Target Release**: {{ TARGET_VERSION }}
- **Target Date**: {{ RELEASE_DATE }}
- **Severity**: Critical Blocker
- **Impact**: Release cannot proceed until resolved

## 📋 Issue Details
{specific_problem_description}

## 🔍 Evidence/Diagnostics
{error_messages_logs_evidence}

## ✅ Acceptance Criteria
- [ ] {specific_requirement_1}
- [ ] {specific_requirement_2}
- [ ] Release readiness check passes for this category
- [ ] No regressions introduced

## 🎯 Implementation Plan
{step_by_step_resolution_plan}

## 🔗 Related
- Release tracking: #{release_tracking_issue}
- Documentation: {relevant_docs_links}

**Priority**: 🔴 Critical - Release Blocker
**Labels**: `release-blocker`, `critical`, `v{{ TARGET_VERSION }}`

/work_on_issue
```

### 🟡 **Release Warnings** (Should Fix Before Release)
```markdown
# Template: [RELEASE WARNING] {issue_type} for v{{ TARGET_VERSION }}

## ⚠️ Release Impact
This issue **should be resolved** before {{ TARGET_VERSION }} release for optimal quality.

- **Target Release**: {{ TARGET_VERSION }}
- **Target Date**: {{ RELEASE_DATE }}
- **Severity**: High Priority
- **Impact**: Quality/stability concern

## 📋 Issue Details
{specific_warning_description}

## 🔍 Current State
{current_metrics_status}

## ✅ Success Criteria
- [ ] {improvement_goal_1}
- [ ] {improvement_goal_2}
- [ ] Documentation updated if needed

## 💡 Recommended Approach
{suggested_solution_approach}

**Priority**: 🟡 High - Release Warning
**Labels**: `release-warning`, `priority-high`, `v{{ TARGET_VERSION }}`

/work_on_issue
```

## Specific Issue Templates by Category:

### 🔄 **CI/CD Pipeline Failures**
```python
def create_cicd_issue(failing_checks):
    return f"""
# [RELEASE BLOCKER] Fix failing CI/CD checks for v{{ TARGET_VERSION }}

## 🚨 Failing Checks
{format_failing_checks(failing_checks)}

## 🔍 Investigation Steps
1. Check recent commits that might have caused failures
2. Review CI logs for specific error messages
3. Verify environment configuration
4. Test fixes locally before pushing

## ✅ Acceptance Criteria
- [ ] All required CI checks pass on main branch
- [ ] No intermittent test failures
- [ ] CI pipeline runs within acceptable time limits
- [ ] All environments (dev/staging/prod) validated

## 🎯 Debug Commands
```bash
# Check latest CI run status
gh run list --branch main --limit 5

# Get detailed logs for failed run
gh run view [RUN_ID] --log-failed

# Re-run failed jobs
gh run rerun [RUN_ID] --failed
```

**Estimated Effort**: {estimate_effort(failing_checks)}
**Assignee**: {suggest_assignee('cicd')}
"""
```

### 📊 **Code Coverage Issues**
```python
def create_coverage_issue(coverage_data):
    return f"""
# [RELEASE BLOCKER] Improve code coverage to {target_coverage}% for v{{ TARGET_VERSION }}

## 📊 Current Coverage Status
- **Overall Coverage**: {coverage_data.current}%
- **Target Coverage**: {coverage_data.target}%
- **Gap**: {coverage_data.gap}%
- **Files Below Target**: {coverage_data.low_coverage_files_count}

## 🎯 Files Requiring Attention
{format_low_coverage_files(coverage_data.files)}

## ✅ Acceptance Criteria
- [ ] Overall project coverage ≥ {coverage_data.target}%
- [ ] No critical files below 70% coverage
- [ ] All new code has tests
- [ ] Coverage reports generated successfully

## 🔗 Integration
This issue can be resolved using the existing coverage improvement system:

1. Use `/improve_coverage TARGET_COVERAGE={coverage_data.target}`
2. Review generated coverage issues
3. Ensure all coverage issues are resolved

## 📈 Success Metrics
- Coverage dashboard shows green status
- All coverage-related issues closed
- CI coverage checks pass
"""
```

### 🛡️ **Security Vulnerabilities**
```python
def create_security_issue(vulnerabilities):
    return f"""
# [RELEASE BLOCKER] Resolve critical security vulnerabilities for v{{ TARGET_VERSION }}

## 🚨 Security Alert
{vulnerabilities.count} critical/high security vulnerabilities found that must be resolved before release.

## 🔍 Vulnerabilities Found
{format_vulnerabilities(vulnerabilities)}

## ✅ Resolution Required
- [ ] Update vulnerable dependencies
- [ ] Verify no breaking changes from updates
- [ ] Run security scan to confirm resolution
- [ ] Update lockfiles (poetry.lock, package-lock.json)
- [ ] Test application functionality after updates

## 🛠️ Resolution Commands
```bash
# Python vulnerabilities
poetry update [package-name]
safety check

# JavaScript vulnerabilities
npm audit fix
npm audit --audit-level=high
```

## 🧪 Testing Plan
- [ ] All existing tests pass after updates
- [ ] Security scan shows no critical/high vulnerabilities
- [ ] Application functions normally in dev/staging
- [ ] Performance regression testing completed

**Security Level**: {vulnerabilities.max_severity}
**CVSS Score**: {vulnerabilities.max_cvss}
"""
```

### 📝 **Documentation & Release Notes**
```python
def create_documentation_issue():
    return f"""
# [RELEASE WARNING] Prepare release documentation for v{{ TARGET_VERSION }}

## 📝 Documentation Requirements
Release documentation must be complete before {{ TARGET_VERSION }} release.

## ✅ Documentation Checklist
- [ ] **CHANGELOG.md**: Add entry for v{{ TARGET_VERSION }}
- [ ] **Release Notes**: Prepare comprehensive release notes
- [ ] **Breaking Changes**: Document any breaking changes
- [ ] **Migration Guide**: Create if breaking changes exist
- [ ] **API Documentation**: Update if API changes made
- [ ] **README.md**: Update version references and features

## 📋 Changelog Template
```markdown
## [{{ TARGET_VERSION }}] - {release_date}

### Added
- New feature descriptions

### Changed
- Changes to existing functionality

### Deprecated
- Features marked for removal

### Removed
- Features removed in this version

### Fixed
- Bug fixes

### Security
- Security improvements
```

## 🔍 Content Gathering
- Review merged PRs since last release
- Identify user-facing changes
- Document API changes
- Note performance improvements
- List security updates

## 📚 Resources
- [Previous release notes](../../releases)
- [Merged PRs since last release](../../pulls?q=is:pr+is:merged+created:>{last_release_date})
- [Closed issues since last release](../../issues?q=is:issue+is:closed+created:>{last_release_date})
"""
```

## Issue Batch Management:

```bash
#!/bin/bash
# Release Issue Generation Script

create_release_tracking_issue() {
    local version="$1"
    local release_date="$2"

    gh issue create \
        --title "🚀 Release Tracking: v${version}" \
        --body "$(cat <<EOF
# 🚀 Release Tracking: v${version}

**Target Release Date**: ${release_date}
**Release Manager**: TBD

## 📋 Release Status
- [ ] Release readiness assessment completed
- [ ] All critical blockers resolved
- [ ] All high-priority warnings addressed
- [ ] Documentation prepared
- [ ] Release artifacts ready
- [ ] Release deployed

## 🔴 Critical Blockers
{will_be_updated_automatically}

## 🟡 High Priority Warnings
{will_be_updated_automatically}

## 📈 Progress Tracking
- **Blockers Resolved**: 0/TBD
- **Warnings Addressed**: 0/TBD
- **Overall Progress**: 0%

This issue will be automatically updated as release blockers are resolved.

## 🔗 Quick Links
- [Release Readiness Report](link_when_available)
- [CI/CD Status](../../actions)
- [Security Advisories](../../security/advisories)
- [Previous Release](../../releases/latest)
EOF
        )" \
        --label "release-tracking,v${version}" \
        --assignee "@me"
}

main() {
    local version="{{ TARGET_VERSION }}"
    local release_date="{{ RELEASE_DATE }}"

    echo "🚀 Creating release tracking and blocker issues for v${version}..."

    # Create master tracking issue
    TRACKING_ISSUE=$(create_release_tracking_issue "$version" "$release_date")

    # Create issues for each category of blockers found
    create_issues_from_readiness_report "$version" "$TRACKING_ISSUE"

    echo "✅ Release issues created! Track progress at: $TRACKING_ISSUE"

    if [ "{{ AUTO_WORK_ISSUES }}" = "true" ]; then
        echo "🔧 Auto-starting work on critical blockers..."
        work_on_critical_blockers "$version"
    fi
}
```

## Integration with Issue Workflow:

Each created release issue includes `/work_on_issue` trigger for immediate processing:

1. **Release Readiness Check** → **Issues Created** → **`/work_on_issue`** → **`/create_issue_pr`** → **`/iterate_on_pr`** → **Blocker Resolved**

## Smart Issue Management:

### Auto-Assignment:
- **CI/CD Issues**: Assign to DevOps/Infrastructure team
- **Security Issues**: Assign to Security team
- **Coverage Issues**: Assign to QA/Testing team
- **Documentation**: Assign to Technical Writers

### Auto-Labeling:
- `release-blocker` for critical issues
- `release-warning` for high-priority issues
- `v{{ TARGET_VERSION }}` for version tracking
- Component-specific labels (`backend`, `frontend`, `docs`)

### Progress Tracking:
- Update master tracking issue as blockers are resolved
- Calculate release readiness percentage
- Send notifications when all blockers cleared

After creating issues, use `/complete_issue` on each to systematically resolve all release blockers for v{{ TARGET_VERSION }}!
