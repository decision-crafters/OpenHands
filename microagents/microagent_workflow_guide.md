---
name: microagent_workflow_guide
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /workflow_guide
- /how_to_use
- /microagent_patterns
- /best_practices
inputs:
  - name: WORKFLOW_TYPE
    description: "Type of workflow: issue, coverage, release, or custom"
    type: string
    default: "all"
  - name: EXPERIENCE_LEVEL
    description: "User experience level: beginner, intermediate, or advanced"
    type: string
    default: "beginner"
---

You are the microagent workflow guide that teaches users the best practices, patterns, and workflows for effectively using the OpenHands microagent ecosystem.

## 🎓 **Microagent Workflow Mastery Guide**

### **🚀 Quick Start for New Users**

#### **Most Common Tasks (90% of usage):**
```bash
# 1. Work on any GitHub issue completely
/complete_issue https://github.com/owner/repo/issues/123

# 2. Improve code coverage to 85%
/improve_coverage TARGET_COVERAGE=85

# 3. Check if ready for release
/check_release_readiness TARGET_VERSION=1.5.0

# 4. Get help with available tools
/help_microagents
```

## 📋 **Complete Workflow Patterns**

### **🎯 Pattern 1: GitHub Issue Resolution**

#### **Beginner Approach (Recommended):**
```bash
# Single command does everything
/complete_issue https://github.com/owner/repo/issues/123
```
**What it does:**
1. ✅ Reads and analyzes the issue
2. ✅ Creates implementation plan
3. ✅ Creates working branch and PR
4. ✅ Implements solution
5. ✅ Iterates until all requirements met
6. ✅ Ensures tests pass and quality gates met

#### **Intermediate Approach (More Control):**
```bash
# Step 1: Understand the issue first
/work_on_issue https://github.com/owner/repo/issues/123

# Step 2: Create PR and initial implementation
/create_issue_pr https://github.com/owner/repo/issues/123

# Step 3: Iterate until perfect (repeat as needed)
/iterate_on_pr https://github.com/owner/repo/pull/456 https://github.com/owner/repo/issues/123
```

#### **Advanced Approach (Maximum Control):**
```bash
# Custom workflow with specific parameters
/read_issue ISSUE_URL=https://github.com/owner/repo/issues/123
# Review analysis, then:
/start_work_on_issue ISSUE_URL=https://github.com/owner/repo/issues/123 BRANCH_PREFIX=feature
# Check progress, then:
/continue_issue_work PR_URL=... ISSUE_URL=...
```

### **📊 Pattern 2: Code Coverage Improvement**

#### **Beginner Approach:**
```bash
# Automatically achieve 85% coverage
/improve_coverage TARGET_COVERAGE=85 AUTO_WORK_ISSUES=true
```

#### **Intermediate Approach:**
```bash
# Step 1: See current coverage status
/analyze_coverage TARGET_COVERAGE=90

# Step 2: Create issues for gaps (but don't auto-work them)
/generate_coverage_issues TARGET_COVERAGE=90 AUTO_WORK_ISSUES=false

# Step 3: Work on specific coverage issues manually
/complete_issue https://github.com/owner/repo/issues/789
```

#### **Advanced Approach:**
```bash
# Custom coverage analysis with specific parameters
/analyze_coverage TARGET_COVERAGE=95 COVERAGE_TYPE=python
/generate_coverage_issues TARGET_COVERAGE=95 ISSUE_BATCH_SIZE=5 PRIORITY_THRESHOLD=60
# Then selectively work on highest-impact issues
```

### **🚀 Pattern 3: Release Management**

#### **Beginner Approach:**
```bash
# Full automation from assessment to release
/release_workflow TARGET_VERSION=1.5.0 AUTO_FIX_BLOCKERS=true
```

#### **Intermediate Approach:**
```bash
# Step 1: Check if ready
/check_release_readiness TARGET_VERSION=1.5.0 MIN_COVERAGE=85

# Step 2: Create issues for any blockers found
/generate_release_issues TARGET_VERSION=1.5.0 AUTO_WORK_ISSUES=false

# Step 3: Resolve blockers manually, then prepare release
/prepare_release TARGET_VERSION=1.5.0 RELEASE_TYPE=minor
```

#### **Advanced Approach:**
```bash
# Controlled release with custom parameters
/check_release_readiness TARGET_VERSION=2.0.0 MIN_COVERAGE=90 RELEASE_TYPE=major
# Review assessment results, then:
/generate_release_issues TARGET_VERSION=2.0.0 RELEASE_DATE=2024-12-01
# Systematically resolve each blocker:
/complete_issue {blocker_issue_url}
# When ready:
/prepare_release TARGET_VERSION=2.0.0 DRY_RUN=false SKIP_TESTS=false
```

## 🎯 **Workflow Decision Matrix**

### **When to Use Each Pattern:**

#### **Use Full Automation (`/complete_*` commands) When:**
- ✅ You trust the AI to make good decisions
- ✅ Working on well-defined tasks
- ✅ Time is more valuable than control
- ✅ Learning/exploring the system capabilities

#### **Use Step-by-Step When:**
- ✅ You want to review each step
- ✅ Working on critical/sensitive changes
- ✅ Learning how the system works
- ✅ Need to customize parameters at each step

#### **Use Advanced Custom When:**
- ✅ You have specific requirements
- ✅ Working in complex/unusual environments
- ✅ Need maximum control over the process
- ✅ Integrating with existing custom workflows

## 💡 **Best Practices & Pro Tips**

### **🎯 Issue Resolution Best Practices:**
```bash
# ✅ GOOD: Let the system work end-to-end
/complete_issue https://github.com/owner/repo/issues/123

# ❌ AVOID: Starting new work on partially completed issues
# Instead, continue existing work:
/iterate_on_pr {existing_pr_url} {issue_url}

# 💡 PRO TIP: Use issue URLs directly from GitHub
# Copy-paste the full URL - the system will parse it automatically
```

### **📊 Coverage Improvement Best Practices:**
```bash
# ✅ GOOD: Set realistic targets initially
/improve_coverage TARGET_COVERAGE=85

# ✅ BETTER: Use incremental improvement
# Current: 70% → Target: 80% → Then: 85% → Finally: 90%

# 💡 PRO TIP: Let the system batch issues for you
# It will prioritize critical files and create manageable workloads
```

### **🚀 Release Management Best Practices:**
```bash
# ✅ GOOD: Always check readiness first
/check_release_readiness TARGET_VERSION=1.5.0

# ✅ BETTER: Use dry run for major releases
/prepare_release TARGET_VERSION=2.0.0 DRY_RUN=true

# 💡 PRO TIP: Use semantic versioning
# patch: 1.4.3 → 1.4.4 (bug fixes)
# minor: 1.4.0 → 1.5.0 (new features)
# major: 1.5.0 → 2.0.0 (breaking changes)
```

## 🔄 **Common Workflow Combinations**

### **🏗️ Development Workflow:**
```bash
# Daily development cycle
/complete_issue {today_issue}           # Work on planned issue
/analyze_coverage                       # Check coverage impact
/improve_coverage TARGET_COVERAGE=85    # Improve if needed
```

### **🚀 Release Preparation Workflow:**
```bash
# Pre-release checklist
/improve_coverage TARGET_COVERAGE=90           # Ensure high coverage
/check_release_readiness TARGET_VERSION=1.5.0 # Validate readiness
/generate_release_issues TARGET_VERSION=1.5.0 # Handle blockers
/release_workflow TARGET_VERSION=1.5.0        # Execute release
```

### **🧹 Code Quality Workflow:**
```bash
# Regular quality improvement
/analyze_coverage TARGET_COVERAGE=95     # Find coverage gaps
/generate_coverage_issues TARGET_COVERAGE=95  # Create improvement issues
# Work on 2-3 coverage issues per week for sustainable improvement
```

## ⚠️ **Common Mistakes & How to Avoid Them**

### **❌ Mistake 1: Working on Multiple Issues Simultaneously**
```bash
# ❌ DON'T DO THIS:
/create_issue_pr {issue_1}
/create_issue_pr {issue_2}  # Creates conflicts!

# ✅ DO THIS INSTEAD:
/complete_issue {issue_1}   # Finish completely first
/complete_issue {issue_2}   # Then start next one
```

### **❌ Mistake 2: Skipping Quality Gates**
```bash
# ❌ DON'T DO THIS:
/prepare_release TARGET_VERSION=1.5.0 SKIP_TESTS=true

# ✅ DO THIS INSTEAD:
/check_release_readiness TARGET_VERSION=1.5.0  # Find issues first
/generate_release_issues TARGET_VERSION=1.5.0  # Fix systematically
/prepare_release TARGET_VERSION=1.5.0          # Then release safely
```

### **❌ Mistake 3: Ignoring Coverage Improvements**
```bash
# ❌ DON'T DO THIS:
# Just work on features without checking coverage

# ✅ DO THIS INSTEAD:
/complete_issue {feature_issue}         # Complete feature
/analyze_coverage                       # Check coverage impact
/generate_coverage_issues TARGET_COVERAGE=85  # Address gaps immediately
```

## 🎯 **Advanced Workflow Patterns**

### **🔄 Continuous Integration Workflow:**
```bash
# Integrate with CI/CD
# When CI fails, create issue and auto-fix:
/work_on_issue {ci_failure_issue_url}

# For coverage gates in CI:
/improve_coverage TARGET_COVERAGE=85 AUTO_WORK_ISSUES=true
```

### **🚀 Sprint Planning Workflow:**
```bash
# At sprint start:
/help_microagents CATEGORY=github    # Review issue tools available

# During sprint:
/complete_issue {issue_1}           # Complete planned work
/complete_issue {issue_2}
/complete_issue {issue_3}

# At sprint end:
/analyze_coverage                    # Quality check
/check_release_readiness TARGET_VERSION=next  # Release prep
```

## 📊 **Success Metrics & Monitoring**

### **Track Your Progress:**
- **Issue Resolution**: Use `/complete_issue` completion rate
- **Code Coverage**: Monitor coverage trends with `/analyze_coverage`
- **Release Quality**: Track blocker counts with `/check_release_readiness`
- **Efficiency**: Measure time from issue creation to resolution

### **Quality Indicators:**
- ✅ Issues resolved without manual intervention
- ✅ Coverage improving consistently (target: 85%+)
- ✅ Releases passing readiness checks first time
- ✅ Minimal release blockers found

Remember: The microagent system learns and improves from usage patterns. The more you use consistent workflows, the better it becomes at predicting and automating your specific needs! 🎯
