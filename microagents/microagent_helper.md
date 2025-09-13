---
name: microagent_helper
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /help_microagents
- /list_microagents
- /microagents
- /what_can_i_do
- /available_tools
inputs:
  - name: CATEGORY
    description: "Filter by category: github, testing, coverage, release, workflow, or all"
    type: string
    default: "all"
  - name: SEARCH
    description: "Search term to filter microagents"
    type: string
    default: ""
  - name: FORMAT
    description: "Output format: summary, detailed, or usage"
    type: string
    default: "summary"
---

You are the microagent discovery helper that catalogs, explains, and guides users through all available microagents and their capabilities.

## 🔍 **Microagent Discovery & Assistance**

### **Phase 1: Scan Available Microagents**
```bash
echo "🔍 Discovering available microagents..."

# Function to parse microagent metadata
parse_microagent() {
    local file="$1"
    local name=""
    local triggers=""
    local description=""
    local version=""
    local inputs=""

    # Extract YAML frontmatter
    if grep -q "^---$" "$file"; then
        local yaml_content=$(sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d')

        name=$(echo "$yaml_content" | grep "^name:" | sed 's/name: *//; s/^"//; s/"$//')
        version=$(echo "$yaml_content" | grep "^version:" | sed 's/version: *//; s/^"//; s/"$//')
        triggers=$(echo "$yaml_content" | sed -n '/^triggers:/,/^[a-zA-Z]/p' | grep "^-" | sed 's/^- *//' | tr '\n' ',' | sed 's/,$//')

        # Extract inputs if present
        if echo "$yaml_content" | grep -q "^inputs:"; then
            inputs=$(echo "$yaml_content" | sed -n '/^inputs:/,/^[a-zA-Z]/p' | grep -A1 "name:" | grep "name:" | sed 's/.*name: *//; s/^"//; s/"$//' | tr '\n' ',' | sed 's/,$//')
        fi
    fi

    # Extract description from content (first paragraph after frontmatter)
    description=$(sed -n '/^---$/,/^---$/d; /^$/d; /^#/d; p; q' "$file" | head -1)

    echo "$name|$version|$triggers|$inputs|$description|$(basename "$file")"
}

# Scan all microagent files
echo "📁 Scanning microagents directory..."
MICROAGENTS_DATA=""

for file in microagents/*.md .openhands/microagents/*.md 2>/dev/null; do
    if [ -f "$file" ]; then
        MICROAGENT_INFO=$(parse_microagent "$file")
        MICROAGENTS_DATA="$MICROAGENTS_DATA$MICROAGENT_INFO\n"
    fi
done

echo "✅ Found $(echo -e "$MICROAGENTS_DATA" | wc -l) microagents"
```

### **Phase 2: Categorize and Filter**
```bash
# Function to categorize microagents
categorize_microagent() {
    local name="$1"
    local triggers="$2"
    local description="$3"

    # GitHub-related
    if echo "$name $triggers $description" | grep -qi "github\|issue\|pr\|pull.*request\|commit"; then
        echo "github"
    # Testing and Coverage
    elif echo "$name $triggers $description" | grep -qi "test\|coverage\|pytest"; then
        echo "testing"
    # Release Management
    elif echo "$name $triggers $description" | grep -qi "release\|version\|deploy"; then
        echo "release"
    # Code Quality
    elif echo "$name $triggers $description" | grep -qi "lint\|quality\|review"; then
        echo "quality"
    # Development Tools
    elif echo "$name $triggers $description" | grep -qi "docker\|build\|dev"; then
        echo "development"
    # Security
    elif echo "$name $triggers $description" | grep -qi "security\|vuln\|safe"; then
        echo "security"
    # Documentation
    elif echo "$name $triggers $description" | grep -qi "doc\|readme\|guide"; then
        echo "documentation"
    else
        echo "utility"
    fi
}

# Filter by category if specified
filter_by_category() {
    local category="{{ CATEGORY }}"
    local search_term="{{ SEARCH }}"

    if [ "$category" != "all" ] || [ -n "$search_term" ]; then
        echo "🔍 Filtering microagents..."
        # Apply filters (implementation would filter MICROAGENTS_DATA)
    fi
}

filter_by_category
```

### **Phase 3: Generate Microagent Catalog**

## 🎯 **Available Microagents Catalog**

### **📋 GitHub & Issue Management**
```markdown
#### 🔍 **GitHub Issue Reader** (`github_issue_reader.md`)
- **Triggers**: `/work_on_issue`, `/analyze_issue`, `/read_issue`
- **Purpose**: Reads and analyzes GitHub issues to understand requirements and create actionable plans
- **Inputs**: `ISSUE_URL` (required)
- **Use Case**: Start working on any GitHub issue systematically

#### 🚀 **GitHub Issue PR Creator** (`github_issue_pr_creator.md`)
- **Triggers**: `/create_issue_pr`, `/start_work_on_issue`
- **Purpose**: Creates pull requests that address GitHub issues with initial implementation
- **Inputs**: `ISSUE_URL` (required), `BRANCH_PREFIX` (optional)
- **Use Case**: Convert issue analysis into working code and PR

#### 🔄 **GitHub Issue PR Iterator** (`github_issue_pr_iterator.md`)
- **Triggers**: `/iterate_on_pr`, `/continue_issue_work`, `/refine_pr`
- **Purpose**: Iterates on pull requests until the associated issue is fully resolved
- **Inputs**: `PR_URL` (required), `ISSUE_URL` (required)
- **Use Case**: Keep working on PR until it meets all requirements

#### 🎯 **GitHub Issue Workflow Coordinator** (`github_issue_workflow.md`)
- **Triggers**: `/complete_issue`, `/issue_workflow`, `/end_to_end_issue`
- **Purpose**: Orchestrates complete end-to-end issue resolution process
- **Inputs**: `ISSUE_URL` (required)
- **Use Case**: Fully automate issue resolution from start to finish
```

### **📊 Code Coverage & Testing**
```markdown
#### 📈 **Code Coverage Analyzer** (`code_coverage_analyzer.md`)
- **Triggers**: `/analyze_coverage`, `/check_coverage`, `/coverage_report`
- **Purpose**: Analyzes code coverage across projects and identifies improvement areas
- **Inputs**: `TARGET_COVERAGE` (default: 85), `COVERAGE_TYPE` (default: both)
- **Use Case**: Understand current coverage status and gaps

#### 📋 **Coverage Issue Generator** (`coverage_issue_generator.md`)
- **Triggers**: `/generate_coverage_issues`, `/create_test_issues`
- **Purpose**: Creates GitHub issues for improving code coverage to target levels
- **Inputs**: `TARGET_COVERAGE` (default: 85), `ISSUE_BATCH_SIZE` (default: 10)
- **Use Case**: Systematically improve test coverage through issues

#### 🎯 **Coverage Workflow Coordinator** (`coverage_workflow_coordinator.md`)
- **Triggers**: `/improve_coverage`, `/coverage_to_85`, `/achieve_target_coverage`
- **Purpose**: Complete end-to-end coverage improvement to target percentage
- **Inputs**: `TARGET_COVERAGE` (default: 85), `AUTO_WORK_ISSUES` (default: true)
- **Use Case**: Automatically achieve 85%+ code coverage across project
```

### **🚀 Release Management**
```markdown
#### ✅ **Release Readiness Checker** (`release_readiness_checker.md`)
- **Triggers**: `/check_release_readiness`, `/release_readiness`, `/can_we_release`
- **Purpose**: Comprehensive assessment of whether project is ready for release
- **Inputs**: `TARGET_VERSION`, `MIN_COVERAGE` (default: 85), `RELEASE_TYPE`
- **Use Case**: Validate all quality gates before releasing

#### 📋 **Release Issue Generator** (`release_issue_generator.md`)
- **Triggers**: `/generate_release_issues`, `/create_release_blockers`
- **Purpose**: Creates GitHub issues for all release blockers found during assessment
- **Inputs**: `TARGET_VERSION` (required), `RELEASE_DATE`, `AUTO_WORK_ISSUES`
- **Use Case**: Convert release blockers into actionable tasks

#### 📦 **Release Preparator** (`release_preparator.md`)
- **Triggers**: `/prepare_release`, `/finalize_release`, `/create_release`
- **Purpose**: Prepares and executes releases when all quality gates pass
- **Inputs**: `TARGET_VERSION` (required), `RELEASE_TYPE`, `DRY_RUN`
- **Use Case**: Handle version updates, tagging, and release creation

#### 🎯 **Release Workflow Coordinator** (`release_workflow_coordinator.md`)
- **Triggers**: `/release_workflow`, `/full_release_process`, `/automated_release`
- **Purpose**: Complete end-to-end release management from assessment to publication
- **Inputs**: `TARGET_VERSION` (required), `RELEASE_TYPE`, `AUTO_FIX_BLOCKERS`
- **Use Case**: Fully automated, high-quality releases
```

### **🛠️ Development & Utility**
```markdown
#### 🔧 **Existing OpenHands Microagents**
- **GitHub Integration** (`github.md`): GitHub API operations and PR management
- **Address PR Comments** (`address_pr_comments.md`): Handle review feedback systematically
- **Update PR Description** (`update_pr_description.md`): Keep PR descriptions current
- **Docker Support** (`docker.md`): Docker best practices and guidelines
- **Security Guidelines** (`security.md`): Security best practices and vulnerability handling
- **Code Review** (`code-review.md`): Code review processes and standards
- [... and many more in the microagents/ directory]
```

## 💡 **Usage Patterns & Workflows**

### **🔄 Complete Issue Resolution Workflow**
```bash
# Option 1: Full automation
/complete_issue https://github.com/owner/repo/issues/123

# Option 2: Step by step
/work_on_issue https://github.com/owner/repo/issues/123
/create_issue_pr https://github.com/owner/repo/issues/123
/iterate_on_pr https://github.com/owner/repo/pull/456 https://github.com/owner/repo/issues/123
```

### **📊 Complete Coverage Improvement**
```bash
# Achieve 85% coverage automatically
/improve_coverage TARGET_COVERAGE=85 AUTO_WORK_ISSUES=true

# Or step by step
/analyze_coverage TARGET_COVERAGE=90
/generate_coverage_issues TARGET_COVERAGE=90
# Then work on individual issues created
```

### **🚀 Complete Release Process**
```bash
# Fully automated release
/release_workflow TARGET_VERSION=1.5.0 AUTO_FIX_BLOCKERS=true

# Or controlled process
/check_release_readiness TARGET_VERSION=1.5.0
/generate_release_issues TARGET_VERSION=1.5.0
# Resolve blockers, then:
/prepare_release TARGET_VERSION=1.5.0
```

## 🎯 **Smart Recommendations**

Based on your query: **{{ SEARCH }}** in category **{{ CATEGORY }}**

```python
def recommend_microagents(search_term, category):
    """Provide smart recommendations based on user intent"""

    recommendations = []

    if "issue" in search_term.lower():
        recommendations.extend([
            "🎯 Use `/complete_issue` for full automation",
            "🔍 Use `/work_on_issue` to start with analysis",
            "🚀 Use `/create_issue_pr` to create implementation PR"
        ])

    if "coverage" in search_term.lower() or "test" in search_term.lower():
        recommendations.extend([
            "📊 Use `/improve_coverage` to achieve target coverage",
            "📈 Use `/analyze_coverage` to understand current state",
            "📋 Use `/generate_coverage_issues` to create systematic plan"
        ])

    if "release" in search_term.lower():
        recommendations.extend([
            "🚀 Use `/release_workflow` for complete release automation",
            "✅ Use `/check_release_readiness` to validate quality gates",
            "📦 Use `/prepare_release` when ready to ship"
        ])

    return recommendations
```

## 🔍 **Search & Discovery Commands**

```bash
# Get all available microagents
/list_microagents

# Filter by specific category
/list_microagents CATEGORY=github

# Search for specific functionality
/list_microagents SEARCH=coverage

# Get detailed information about capabilities
/list_microagents FORMAT=detailed

# Get usage examples and patterns
/list_microagents FORMAT=usage
```

## 📚 **Quick Reference Guide**

### **Most Common Workflows:**
1. **Work on Issue**: `/complete_issue {issue_url}`
2. **Improve Coverage**: `/improve_coverage TARGET_COVERAGE=85`
3. **Release Software**: `/release_workflow TARGET_VERSION={version}`
4. **Get Help**: `/help_microagents` (this microagent!)

### **Emergency Commands:**
- **Fix Failing Tests**: `/work_on_issue` (with test failure issue)
- **Security Vulnerability**: `/work_on_issue` (with security issue)
- **Release Blocker**: `/check_release_readiness` then fix blockers

This microagent helper serves as your complete guide to the OpenHands microagent ecosystem! 🎯
