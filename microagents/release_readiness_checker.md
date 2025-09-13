---
name: release_readiness_checker
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /check_release_readiness
- /release_readiness
- /can_we_release
inputs:
  - name: TARGET_VERSION
    description: "Version number for the planned release (e.g., 1.5.0)"
    type: string
    default: ""
  - name: MIN_COVERAGE
    description: "Minimum code coverage required for release"
    type: integer
    default: 85
  - name: RELEASE_TYPE
    description: "Type of release: major, minor, patch, or prerelease"
    type: string
    default: "minor"
---

You are specialized in comprehensively assessing whether a project is ready for release by checking all critical quality gates and potential blockers.

## Release Readiness Assessment Framework

### 🔍 **Phase 1: CI/CD Pipeline Status**
```bash
echo "🔄 Checking CI/CD Pipeline Status..."

# Check GitHub Actions status for main branch
gh run list --branch main --limit 10 --json status,conclusion,name

# Get latest commit status
LATEST_COMMIT=$(git rev-parse HEAD)
gh api "repos/{owner}/{repo}/commits/${LATEST_COMMIT}/status" --jq '.state'

# Check if all required checks pass
FAILING_CHECKS=$(gh api "repos/{owner}/{repo}/commits/${LATEST_COMMIT}/check-runs" \
  --jq '.check_runs[] | select(.conclusion != "success") | .name')

if [ -n "$FAILING_CHECKS" ]; then
    echo "❌ BLOCKER: Failing CI checks: $FAILING_CHECKS"
else
    echo "✅ All CI checks passing"
fi
```

### 📊 **Phase 2: Code Quality & Coverage**
```bash
echo "📊 Analyzing Code Quality & Coverage..."

# Run comprehensive test coverage analysis
/analyze_coverage TARGET_COVERAGE={{ MIN_COVERAGE }}

# Check for critical code quality issues
if command -v ruff >/dev/null 2>&1; then
    CRITICAL_ISSUES=$(ruff check --select E9,F63,F7,F82 --format=json . | jq '. | length')
    if [ "$CRITICAL_ISSUES" -gt 0 ]; then
        echo "❌ BLOCKER: $CRITICAL_ISSUES critical code quality issues"
    else
        echo "✅ No critical code quality issues"
    fi
fi

# Frontend quality checks
if [ -f "frontend/package.json" ]; then
    cd frontend
    if npm run lint --silent; then
        echo "✅ Frontend linting passes"
    else
        echo "❌ BLOCKER: Frontend linting fails"
    fi
    cd ..
fi
```

### 🔢 **Phase 3: Version Consistency**
```bash
echo "🔢 Checking Version Consistency..."

# Run version consistency check (if available)
if [ -f ".github/scripts/check_version_consistency.py" ]; then
    python .github/scripts/check_version_consistency.py
    VERSION_CHECK_STATUS=$?
    if [ $VERSION_CHECK_STATUS -eq 0 ]; then
        echo "✅ Version consistency verified"
    else
        echo "❌ BLOCKER: Version inconsistencies found"
    fi
fi

# Check if target version is valid and follows semver
if [ -n "{{ TARGET_VERSION }}" ]; then
    if echo "{{ TARGET_VERSION }}" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$'; then
        echo "✅ Target version {{ TARGET_VERSION }} follows semantic versioning"
    else
        echo "❌ BLOCKER: Invalid version format: {{ TARGET_VERSION }}"
    fi
fi
```

### 🛡️ **Phase 4: Security & Dependencies**
```bash
echo "🛡️ Checking Security & Dependencies..."

# Check for security vulnerabilities in Python dependencies
if command -v safety >/dev/null 2>&1; then
    safety check --json > safety_report.json 2>/dev/null
    CRITICAL_VULNS=$(jq '.vulnerabilities | length' safety_report.json 2>/dev/null || echo "0")
    if [ "$CRITICAL_VULNS" -gt 0 ]; then
        echo "❌ BLOCKER: $CRITICAL_VULNS security vulnerabilities in Python dependencies"
    else
        echo "✅ No critical Python security vulnerabilities"
    fi
fi

# Check for security vulnerabilities in JavaScript dependencies
if [ -f "frontend/package.json" ]; then
    cd frontend
    if npm audit --audit-level=high --json > ../npm_audit.json 2>/dev/null; then
        HIGH_VULNS=$(jq '.metadata.vulnerabilities.high // 0' ../npm_audit.json)
        CRITICAL_VULNS=$(jq '.metadata.vulnerabilities.critical // 0' ../npm_audit.json)
        if [ "$HIGH_VULNS" -gt 0 ] || [ "$CRITICAL_VULNS" -gt 0 ]; then
            echo "❌ BLOCKER: High/critical vulnerabilities in JavaScript dependencies"
        else
            echo "✅ No critical JavaScript security vulnerabilities"
        fi
    fi
    cd ..
fi

# Check for outdated critical dependencies
echo "📦 Checking for outdated dependencies..."
# Python dependencies
poetry show --outdated --only=main 2>/dev/null | head -5

# JavaScript dependencies
if [ -f "frontend/package.json" ]; then
    cd frontend && npm outdated --depth=0 2>/dev/null | head -5 && cd ..
fi
```

### 📝 **Phase 5: Documentation & Communication**
```bash
echo "📝 Checking Documentation & Release Notes..."

# Check if CHANGELOG exists and is updated
if [ -f "CHANGELOG.md" ]; then
    # Check if changelog has entry for target version
    if grep -q "{{ TARGET_VERSION }}" CHANGELOG.md; then
        echo "✅ Changelog updated for {{ TARGET_VERSION }}"
    else
        echo "⚠️  WARNING: No changelog entry for {{ TARGET_VERSION }}"
    fi
else
    echo "⚠️  WARNING: No CHANGELOG.md file found"
fi

# Check if README is up to date
README_AGE=$(find README.md -mtime +30 2>/dev/null | wc -l)
if [ "$README_AGE" -gt 0 ]; then
    echo "⚠️  WARNING: README.md not updated in 30+ days"
else
    echo "✅ README.md recently updated"
fi

# Check for API documentation
if [ -d "docs" ] || [ -f "openapi.json" ] || [ -f "docs/openapi.json" ]; then
    echo "✅ API documentation found"
else
    echo "⚠️  WARNING: No API documentation found"
fi
```

### 🐛 **Phase 6: Issue Analysis**
```bash
echo "🐛 Analyzing Open Issues & Pull Requests..."

# Check for critical open issues
CRITICAL_ISSUES=$(gh issue list --label="critical,blocker,security" --state=open --json number,title | jq '. | length')
if [ "$CRITICAL_ISSUES" -gt 0 ]; then
    echo "❌ BLOCKER: $CRITICAL_ISSUES critical/blocker issues open"
    gh issue list --label="critical,blocker,security" --state=open --json number,title,url
else
    echo "✅ No critical/blocker issues open"
fi

# Check for high-priority issues
HIGH_PRIORITY_ISSUES=$(gh issue list --label="priority-high" --state=open --json number | jq '. | length')
if [ "$HIGH_PRIORITY_ISSUES" -gt 5 ]; then
    echo "⚠️  WARNING: $HIGH_PRIORITY_ISSUES high-priority issues open"
else
    echo "✅ Acceptable number of high-priority issues ($HIGH_PRIORITY_ISSUES)"
fi

# Check for open PRs that might be release-relevant
PENDING_PRS=$(gh pr list --state=open --label="release-blocker" --json number,title | jq '. | length')
if [ "$PENDING_PRS" -gt 0 ]; then
    echo "❌ BLOCKER: $PENDING_PRS release-blocker PRs pending"
    gh pr list --state=open --label="release-blocker" --json number,title,url
else
    echo "✅ No release-blocker PRs pending"
fi
```

### ⚡ **Phase 7: Performance & Quality Gates**
```bash
echo "⚡ Checking Performance & Quality Gates..."

# Check build times
echo "🔨 Testing build processes..."
BUILD_START=$(date +%s)
if make build >/dev/null 2>&1; then
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    echo "✅ Build successful in ${BUILD_TIME}s"
    if [ "$BUILD_TIME" -gt 300 ]; then
        echo "⚠️  WARNING: Build time ($BUILD_TIME s) is quite long"
    fi
else
    echo "❌ BLOCKER: Build process fails"
fi

# Memory usage check (basic)
echo "💾 Basic system requirements check..."
AVAILABLE_MEMORY=$(free -m | awk 'NR==2{printf "%.1f", $7*100/1024}')
echo "Available memory: ${AVAILABLE_MEMORY}GB"
```

## 📋 **Release Readiness Report Generation**

```python
def generate_release_readiness_report(results):
    """Generate comprehensive release readiness report"""

    report = f"""
# 🚀 Release Readiness Report - Version {{ TARGET_VERSION }}
*Generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*

## 📊 Executive Summary
- **Release Candidate**: {{ TARGET_VERSION }}
- **Release Type**: {{ RELEASE_TYPE }}
- **Overall Status**: {get_overall_status(results)}
- **Blockers Found**: {count_blockers(results)}
- **Warnings**: {count_warnings(results)}

## 🔍 Detailed Assessment

### ✅ Passing Checks
{list_passing_checks(results)}

### ❌ Critical Blockers
{list_blockers(results)}

### ⚠️  Warnings & Recommendations
{list_warnings(results)}

## 📋 Release Checklist
- [ ] All CI/CD pipelines green
- [ ] Code coverage ≥ {{ MIN_COVERAGE }}%
- [ ] No critical security vulnerabilities
- [ ] Version consistency verified
- [ ] Release notes prepared
- [ ] No critical/blocker issues open
- [ ] Documentation updated
- [ ] Performance benchmarks pass

## 🎯 Next Steps
{generate_next_steps(results)}

## 🔗 Quick Links
- [CI/CD Pipelines](../../actions)
- [Open Issues](../../issues)
- [Security Advisories](../../security/advisories)
- [Latest Releases](../../releases)
"""
    return report
```

## Quality Gates & Thresholds:

### 🔴 **Critical Blockers** (Must Fix Before Release):
- CI/CD pipeline failures
- Critical security vulnerabilities
- Code coverage below {{ MIN_COVERAGE }}%
- Critical/blocker issues open
- Build process failures
- Version inconsistencies

### 🟡 **Warnings** (Recommended to Address):
- High-priority issues (>5 open)
- Outdated dependencies
- Missing documentation
- Performance concerns
- Missing changelog entries

### 🟢 **Recommendations** (Nice to Have):
- Additional test coverage
- Documentation improvements
- Performance optimizations
- Developer experience enhancements

After assessment, use `/generate_release_issues` to create GitHub issues for any blockers found, or `/prepare_release` if ready to proceed.
