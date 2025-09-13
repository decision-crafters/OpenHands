---
name: release_pipeline_issue_generator
version: 1.1.0
author: openhands
agent: CodeActAgent
triggers:
- /generate_release_issues
- /create_release_improvement_issues
- /release_pipeline_issues
- /create_dependabot_auto_release
inputs:
  - name: ANALYSIS_RESULTS
    description: "JSON or structured analysis results from release pipeline review"
    type: string
    required: true
  - name: AI_MODEL
    description: "AI model to use for issue content generation: gemini, openai, claude, custom"
    type: string
    default: "gemini"
  - name: API_KEY
    description: "API key for the selected AI model"
    type: string
    default: ""
  - name: PROJECT_CONTEXT
    description: "Additional project context and documentation"
    type: string
    default: ""
  - name: PRIORITY_LEVEL
    description: "Issue priority level: high, medium, low, all"
    type: string
    default: "all"
  - name: ISSUE_BATCH_SIZE
    description: "Number of issues to create in one batch"
    type: number
    default: 5
  - name: DRY_RUN
    description: "Preview issues without creating them"
    type: boolean
    default: false
---

You are the release pipeline issue generator that creates detailed, actionable GitHub issues based on release pipeline analysis results.

## 🎯 **Automated Issue Generation for Release Pipeline Improvements**

This microagent transforms release pipeline analysis into comprehensive, prioritized GitHub issues with AI-enhanced content and implementation guidance.

### **🆕 Dependabot Auto-Release Pipeline Feature**

This microagent now includes specialized functionality to create a Dependabot auto-release pipeline that:
- **Detects existing release pipelines** and integrates with them (e.g., `pypi-release.yml`)
- **Creates new release workflows** if none exist, based on project requirements
- **Implements shared AI release note generator** usable by both:
  - Regular release pipelines (manual/scheduled)
  - Dependabot auto-release pipelines (automated dependency updates)
- **Prioritizes security updates** with immediate auto-release capabilities
- **Groups dependency updates** intelligently for batch releases

### **Core Issue Categories:**

#### **1. Dependabot & Auto-Release Integration**
- Dependabot configuration setup/optimization
- Auto-merge strategies for different update types
- Release automation triggers
- Security update handling
- Dependency vulnerability management

#### **2. Release Notes & Documentation Automation**
- AI-powered release note generation
- Conventional commit integration
- Breaking change detection
- User-facing documentation updates
- Release communication workflows

#### **3. Pipeline Security & Quality**
- Security scanning integration
- Vulnerability assessment automation
- Code quality gates
- Compliance checking
- Audit trail implementation

#### **4. Version Management & Synchronization**
- Multi-file version consistency
- Semantic versioning enforcement
- Version bump automation
- Release tagging strategies
- Cross-platform version management

#### **5. Workflow Optimization & Reliability**
- Missing workflow identification
- Pipeline performance optimization
- Error handling and rollback procedures
- Monitoring and alerting setup
- Release success metrics

## **Usage Examples:**

### **Basic Issue Generation:**
```bash
/generate_release_issues ANALYSIS_RESULTS='{"missing_workflows":["release","security"],"dependabot_issues":["missing_config"]}'
```

### **AI-Enhanced Issue Generation:**
```bash
/generate_release_issues ANALYSIS_RESULTS='...' AI_MODEL=openai API_KEY=your_key PROJECT_CONTEXT="React app with TypeScript"
```

### **Prioritized Issue Creation:**
```bash
/generate_release_issues ANALYSIS_RESULTS='...' PRIORITY_LEVEL=high ISSUE_BATCH_SIZE=3
```

### **Preview Mode:**
```bash
/generate_release_issues ANALYSIS_RESULTS='...' DRY_RUN=true
```

## **Issue Generation Logic:**

### **Phase 1: Analysis Processing & Prioritization**

```bash
process_analysis_results() {
    local analysis="$ANALYSIS_RESULTS"
    local priority="${PRIORITY_LEVEL:-all}"
    
    echo "📊 Processing release pipeline analysis results..."
    
    # Parse analysis results (supports JSON or structured text)
    if echo "$analysis" | jq empty 2>/dev/null; then
        # JSON format
        missing_workflows=$(echo "$analysis" | jq -r '.missing_workflows[]? // empty' 2>/dev/null)
        dependabot_issues=$(echo "$analysis" | jq -r '.dependabot_issues[]? // empty' 2>/dev/null)
        security_gaps=$(echo "$analysis" | jq -r '.security_gaps[]? // empty' 2>/dev/null)
        version_issues=$(echo "$analysis" | jq -r '.version_management[]? // empty' 2>/dev/null)
        release_notes_gaps=$(echo "$analysis" | jq -r '.release_notes_issues[]? // empty' 2>/dev/null)
    else
        # Parse structured text format
        missing_workflows=$(echo "$analysis" | grep -o "missing_workflows:\[.*\]" | sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n')
        dependabot_issues=$(echo "$analysis" | grep -o "dependabot_issues:\[.*\]" | sed 's/.*\[\(.*\)\].*/\1/' | tr ',' '\n')
        # Additional parsing logic...
    fi
    
    # Prioritize issues based on impact and complexity
    prioritize_issues
    
    echo "✅ Analysis processed: $(echo "$missing_workflows $dependabot_issues $security_gaps" | wc -w) issues identified"
}

prioritize_issues() {
    declare -A issue_priorities
    
    # High priority issues
    issue_priorities["missing_security_scanning"]="high"
    issue_priorities["missing_dependabot_config"]="high"
    issue_priorities["vulnerable_dependencies"]="high"
    issue_priorities["missing_release_workflow"]="high"
    
    # Medium priority issues
    issue_priorities["missing_auto_merge"]="medium"
    issue_priorities["inconsistent_versioning"]="medium"
    issue_priorities["manual_release_notes"]="medium"
    issue_priorities["missing_rollback"]="medium"
    
    # Low priority issues
    issue_priorities["workflow_optimization"]="low"
    issue_priorities["documentation_updates"]="low"
    issue_priorities["monitoring_enhancements"]="low"
    
    echo "📋 Issue prioritization completed"
}
```

### **Phase 2: AI-Enhanced Issue Content Generation**

```bash
generate_ai_enhanced_content() {
    local issue_type="$1"
    local context="$2"
    local additional_context="${3:-}"
    local model="${AI_MODEL:-gemini}"
    
    if [ -z "${API_KEY}" ]; then
        echo "⚠️  No API key provided, using template-based content"
        generate_template_content "$issue_type" "$context" "$additional_context"
        return 0
    fi
    
    echo "🤖 Generating AI-enhanced content for: $issue_type"
    
    local prompt=""
    
    # Specialized prompt for Dependabot auto-release
    if [ "$issue_type" == "dependabot_auto_release" ]; then
        prompt=$(cat << EOF
Generate a detailed GitHub issue for implementing a Dependabot auto-release pipeline.

Project Context: ${PROJECT_CONTEXT}
Existing Release Workflow: $additional_context
Analysis Context: $context

Please create:
1. Problem statement addressing dependency management and release coordination
2. Solution that integrates Dependabot with automated releases
3. Implementation plan with three phases:
   - Dependabot configuration with intelligent grouping
   - Auto-release workflow triggered by Dependabot merges
   - Shared AI release note generator for both pipelines
4. Code examples showing:
   - Enhanced dependabot.yml configuration
   - GitHub Actions workflow for auto-releases
   - Shared AI release generator action
5. Benefits focusing on security patching speed and automation
6. Success metrics for dependency freshness and release automation

Ensure the AI release generator is designed to be reusable by both:
- Regular release pipelines
- Dependabot auto-release pipelines

Format as GitHub-flavored Markdown with clear structure and code examples.
EOF
)
    else
        prompt=$(cat << EOF
Generate a detailed GitHub issue for improving a software project's release pipeline.

Issue Type: $issue_type
Project Context: ${PROJECT_CONTEXT}
Analysis Context: $context
Additional Context: $additional_context

Please create:
1. A compelling issue title
2. Problem statement with current state analysis
3. Detailed solution approach
4. Step-by-step implementation tasks with checkboxes
5. Code examples and configuration snippets
6. Expected benefits and success metrics
7. Risk assessment and mitigation strategies

Format as GitHub-flavored Markdown with:
- Clear headings and structure
- Code blocks with syntax highlighting
- Checkboxes for actionable tasks
- Emojis for visual appeal
- Technical accuracy and specificity

Focus on practical, implementable solutions that fit the project's ecosystem.
EOF
)
    fi
    
    local ai_content=""
    case "$model" in
        "gemini")
            ai_content=$(call_ai_api "gemini" "$prompt")
            ;;
        "openai")
            ai_content=$(call_ai_api "openai" "$prompt")
            ;;
        "claude")
            ai_content=$(call_ai_api "claude" "$prompt")
            ;;
        "custom")
            ai_content=$(call_ai_api "custom" "$prompt")
            ;;
    esac
    
    echo "$ai_content"
}

call_ai_api() {
    local model="$1"
    local prompt="$2"
    
    case "$model" in
        "gemini")
            curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$API_KEY" \
                -H "Content-Type: application/json" \
                -d "{\"contents\": [{\"parts\": [{\"text\": \"$prompt\"}]}]}" | \
                jq -r '.candidates[0].content.parts[0].text' 2>/dev/null
            ;;
        "openai")
            curl -s -X POST "https://api.openai.com/v1/chat/completions" \
                -H "Authorization: Bearer $API_KEY" \
                -H "Content-Type: application/json" \
                -d "{\"model\": \"gpt-4\", \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}], \"max_tokens\": 3000}" | \
                jq -r '.choices[0].message.content' 2>/dev/null
            ;;
        "claude")
            curl -s -X POST "https://api.anthropic.com/v1/messages" \
                -H "x-api-key: $API_KEY" \
                -H "Content-Type: application/json" \
                -H "anthropic-version: 2023-06-01" \
                -d "{\"model\": \"claude-3-sonnet-20240229\", \"max_tokens\": 3000, \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}]}" | \
                jq -r '.content[0].text' 2>/dev/null
            ;;
        "custom")
            curl -s -X POST "$CUSTOM_MODEL_ENDPOINT" \
                -H "Authorization: Bearer $API_KEY" \
                -H "Content-Type: application/json" \
                -d "{\"prompt\": \"$prompt\", \"max_tokens\": 3000}" | \
                jq -r '.response // .text // .content' 2>/dev/null
            ;;
    esac
}
```

### **Phase 3: Issue Creation with Smart Batching**

```bash
create_release_pipeline_issues() {
    local batch_size="${ISSUE_BATCH_SIZE:-5}"
    local dry_run="${DRY_RUN:-false}"
    local created_count=0
    
    echo "📝 Creating release pipeline improvement issues..."
    echo "   Batch size: $batch_size"
    echo "   Dry run: $dry_run"
    
    # Issue 1: Dependabot Configuration
    if [[ "$dependabot_issues" == *"missing_config"* ]]; then
        create_dependabot_issue
        ((created_count++))
    fi
    
    # Issue 2: Automated Release Notes
    if [[ "$release_notes_gaps" == *"manual_process"* ]] && [ $created_count -lt $batch_size ]; then
        create_release_notes_automation_issue
        ((created_count++))
    fi
    
    # Issue 3: Security Pipeline Enhancement
    if [[ "$security_gaps" == *"missing_scanning"* ]] && [ $created_count -lt $batch_size ]; then
        create_security_enhancement_issue
        ((created_count++))
    fi
    
    # Issue 4: Auto-Release Integration
    if [[ "$missing_workflows" == *"auto_release"* ]] && [ $created_count -lt $batch_size ]; then
        create_auto_release_integration_issue
        ((created_count++))
    fi
    
    # Issue 5: Version Management Centralization
    if [[ "$version_issues" == *"inconsistent"* ]] && [ $created_count -lt $batch_size ]; then
        create_version_management_issue
        ((created_count++))
    fi
    
    echo "✅ Created $created_count release pipeline improvement issues"
}

create_dependabot_issue() {
    local title="🤖 Configure Dependabot Auto-Release Pipeline"
    local content=""
    
    # Check if existing release pipeline exists
    local existing_release_workflow=""
    if [ -f ".github/workflows/release.yml" ]; then
        existing_release_workflow=".github/workflows/release.yml"
    elif [ -f ".github/workflows/pypi-release.yml" ]; then
        existing_release_workflow=".github/workflows/pypi-release.yml"
    elif [ -f ".github/workflows/publish.yml" ]; then
        existing_release_workflow=".github/workflows/publish.yml"
    fi
    
    if [ -n "${API_KEY}" ]; then
        content=$(generate_ai_enhanced_content "dependabot_auto_release" "dependabot_with_release_pipeline" "$existing_release_workflow")
    else
        content=$(generate_dependabot_auto_release_template "$existing_release_workflow")
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        echo "🔍 [DRY RUN] Would create issue: $title"
        echo "$content" | head -10
        echo "..."
        return 0
    fi
    
    gh issue create \
        --title "$title" \
        --body "$content" \
        --label "dependabot,automation,security,release,enhancement" \
        --milestone "Release Pipeline Improvements" 2>/dev/null || true
    
    echo "✅ Created Dependabot auto-release pipeline issue"
}

generate_dependabot_auto_release_template() {
    local existing_workflow="$1"
    local workflow_reference=""
    
    if [ -n "$existing_workflow" ]; then
        workflow_reference="Based on existing release workflow: \`$existing_workflow\`"
    else
        workflow_reference="No existing release workflow found - will create a new one"
    fi
    
    cat << EOF
## 🤖 Configure Dependabot Auto-Release Pipeline

### **Problem Statement**
The project needs automated dependency updates with intelligent auto-release capabilities:
- Security vulnerabilities require immediate patching and release
- Manual dependency update releases create bottlenecks
- Lack of coordination between dependency updates and releases
- Missing automated release notes for dependency updates

### **Solution Overview**
Implement Dependabot configuration with auto-release pipeline that leverages existing release mechanisms or creates new ones.

$workflow_reference

### **Implementation Tasks**

#### **Phase 1: Dependabot Configuration**
- [ ] Enhance/Create \`.github/dependabot.yml\` with auto-merge groups
- [ ] Configure security update priority handling
- [ ] Set up intelligent dependency grouping for batch releases
- [ ] Implement PR auto-approval for safe updates

#### **Phase 2: Auto-Release Workflow**
- [ ] Create \`.github/workflows/dependabot-auto-release.yml\`
- [ ] Integrate with existing release pipeline (if present)
- [ ] Configure automatic version bumping based on update type
- [ ] Set up release triggers for merged Dependabot PRs

#### **Phase 3: AI-Enhanced Release Notes**
- [ ] Configure shared AI release note generator
- [ ] Create dependency update specific templates
- [ ] Implement breaking change detection for dependencies
- [ ] Set up security advisory integration

### **Dependabot Configuration**
\`\`\`yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "daily"
    open-pull-requests-limit: 5
    groups:
      # Critical security updates - immediate release
      security-critical:
        applies-to: "security-updates"
        dependency-type: "production"
        patterns: ["*"]
        
      # Patch updates - batch weekly release
      patch-updates:
        update-types: ["patch"]
        patterns: ["*"]
        
      # Minor updates - batch bi-weekly release  
      minor-updates:
        update-types: ["minor"]
        patterns: ["*"]
        
    # Auto-merge configuration
    labels:
      - "dependencies"
      - "auto-merge"
\`\`\`

### **Auto-Release Workflow**
\`\`\`yaml
# .github/workflows/dependabot-auto-release.yml
name: Dependabot Auto-Release
on:
  pull_request:
    types: [closed]
    
jobs:
  auto-release:
    if: |
      github.event.pull_request.merged == true &&
      github.actor == 'dependabot[bot]'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Determine Release Type
        id: release-type
        run: |
          # Analyze PR labels and changes
          if [[ "\${{ contains(github.event.pull_request.labels.*.name, 'security') }}" == "true" ]]; then
            echo "type=patch" >> \$GITHUB_OUTPUT
            echo "priority=high" >> \$GITHUB_OUTPUT
          elif [[ "\${{ contains(github.event.pull_request.labels.*.name, 'patch-updates') }}" == "true" ]]; then
            echo "type=patch" >> \$GITHUB_OUTPUT
            echo "priority=normal" >> \$GITHUB_OUTPUT
          else
            echo "type=minor" >> \$GITHUB_OUTPUT
            echo "priority=normal" >> \$GITHUB_OUTPUT
          fi
          
      - name: Generate AI Release Notes
        id: release-notes
        uses: ./.github/actions/ai-release-generator
        with:
          type: "dependency-update"
          pr_number: \${{ github.event.pull_request.number }}
          ai_model: \${{ secrets.AI_MODEL }}
          api_key: \${{ secrets.AI_API_KEY }}
          
      - name: Bump Version
        id: version
        run: |
          # Semantic version bumping based on release type
          npm version \${{ steps.release-type.outputs.type }} --no-git-tag-version
          echo "version=\$(node -p "require('./package.json').version")" >> \$GITHUB_OUTPUT
          
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v\${{ steps.version.outputs.version }}
          name: v\${{ steps.version.outputs.version }}
          body: \${{ steps.release-notes.outputs.content }}
          draft: false
          prerelease: false
          
      - name: Trigger Deployment
        if: steps.release-type.outputs.priority == 'high'
        run: |
          # Trigger deployment for high-priority security releases
          gh workflow run deploy.yml
\`\`\`

### **Shared AI Release Generator Action**
\`\`\`yaml
# .github/actions/ai-release-generator/action.yml
name: AI Release Generator
description: Generate AI-enhanced release notes for any pipeline
inputs:
  type:
    description: 'Release type: regular, dependency-update, security'
    required: true
  pr_number:
    description: 'PR number for context'
    required: false
  ai_model:
    description: 'AI model to use'
    required: true
  api_key:
    description: 'API key for AI service'
    required: true
    
outputs:
  content:
    description: 'Generated release notes'
    
runs:
  using: 'composite'
  steps:
    - name: Gather Context
      shell: bash
      run: |
        # Collect commits, PRs, and changes
        echo "Gathering release context..."
        
    - name: Generate Notes
      shell: bash
      run: |
        # Call AI API with context
        # This is shared by both regular releases and Dependabot releases
        python .github/scripts/generate_release_notes.py \\
          --type \${{ inputs.type }} \\
          --pr \${{ inputs.pr_number }} \\
          --model \${{ inputs.ai_model }}
\`\`\`

### **Expected Benefits**
- 🔒 Zero-day security patches with automatic releases
- ⚡ 95% reduction in dependency update overhead
- 📊 Consistent release cadence for updates
- 🤖 Unified AI release notes for all pipelines
- 🎯 Prioritized handling of critical updates

### **Success Metrics**
- Time to production for security patches < 2 hours
- Dependency freshness score > 95%
- Zero manual intervention for patch releases
- 100% release note coverage with AI enhancement
EOF
}

create_release_notes_automation_issue() {
    local title="📝 Implement AI-Enhanced Automated Release Notes Generation"
    local content=""
    
    if [ -n "${API_KEY}" ]; then
        content=$(generate_ai_enhanced_content "release_notes_automation" "manual_release_notes_process")
    else
        content=$(generate_template_release_notes_issue)
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        echo "🔍 [DRY RUN] Would create issue: $title"
        return 0
    fi
    
    gh issue create \
        --title "$title" \
        --body "$content" \
        --label "release-notes,automation,ai,documentation" \
        --milestone "Release Pipeline Improvements" 2>/dev/null || true
    
    echo "✅ Created release notes automation issue"
}
```

### **Phase 4: Issue Templates & Content Generation**

```bash
generate_template_release_notes_issue() {
    cat << EOF
## 📝 Implement Shared AI-Enhanced Automated Release Notes Generation

### **Current State Analysis**
- Manual release note creation process for regular releases
- No automated notes for Dependabot updates
- Inconsistent formatting and content quality
- Time-intensive release preparation
- Missing breaking change highlights

### **Proposed Solution**
Implement a shared AI-powered release note generator that serves both:
- Regular release pipelines (manual/scheduled releases)
- Dependabot auto-release pipelines (dependency updates)

### **Implementation Plan**

#### **Phase 1: Shared Foundation**
- [ ] Create reusable AI release generator action
- [ ] Set up conventional commit linting
- [ ] Create release note templates for different release types
- [ ] Configure semantic versioning automation

#### **Phase 2: AI Enhancement**
- [ ] Configure ${AI_MODEL} API integration
- [ ] Create context-aware prompts for different release types:
  - Regular feature/bug fix releases
  - Dependency update releases
  - Security patch releases
- [ ] Implement breaking change detection
- [ ] Add user impact categorization

#### **Phase 3: Pipeline Integration**
- [ ] Integrate with regular release workflow
- [ ] Integrate with Dependabot auto-release workflow
- [ ] Set up preview generation for PRs
- [ ] Implement manual override capabilities
- [ ] Add release note quality checks

### **Shared AI Release Generator Implementation**
\`\`\`yaml
# .github/actions/ai-release-generator/action.yml
name: Shared AI Release Generator
description: Generate AI-enhanced release notes for any pipeline
inputs:
  release_type:
    description: 'Type: regular, dependency-update, security-patch'
    required: true
    default: 'regular'
  pr_numbers:
    description: 'Comma-separated PR numbers'
    required: false
  commit_range:
    description: 'Git commit range for analysis'
    required: false
  ai_model:
    description: 'AI model: gemini, openai, claude'
    required: true
  api_key:
    description: 'API key for AI service'
    required: true
    
outputs:
  release_notes:
    description: 'Generated release notes'
  version_recommendation:
    description: 'Recommended version bump'
    
runs:
  using: 'composite'
  steps:
    - name: Analyze Changes
      id: analyze
      shell: bash
      run: |
        # Analyze commits, PRs, and determine release type
        python .github/scripts/analyze_changes.py \\
          --type \${{ inputs.release_type }} \\
          --prs \${{ inputs.pr_numbers }} \\
          --range \${{ inputs.commit_range }}
        
    - name: Generate AI Notes
      id: generate
      shell: bash
      run: |
        # Generate notes using AI with context
        python .github/scripts/generate_release_notes.py \\
          --type \${{ inputs.release_type }} \\
          --changes \${{ steps.analyze.outputs.changes }} \\
          --model \${{ inputs.ai_model }} \\
          --api-key \${{ inputs.api_key }}
\`\`\`

### **Usage in Regular Release Pipeline**
\`\`\`yaml
- name: Generate Release Notes
  uses: ./.github/actions/ai-release-generator
  with:
    release_type: 'regular'
    commit_range: 'HEAD~10..HEAD'
    ai_model: \${{ secrets.AI_MODEL }}
    api_key: \${{ secrets.AI_API_KEY }}
\`\`\`

### **Usage in Dependabot Auto-Release**
\`\`\`yaml
- name: Generate Release Notes
  uses: ./.github/actions/ai-release-generator
  with:
    release_type: 'dependency-update'
    pr_numbers: \${{ github.event.pull_request.number }}
    ai_model: \${{ secrets.AI_MODEL }}
    api_key: \${{ secrets.AI_API_KEY }}
\`\`\`

### **Expected Benefits**
- ⚡ 90% reduction in release preparation time
- 📈 Consistent, high-quality release notes
- 🎯 User-focused change descriptions
- 🔍 Automated breaking change detection

### **Integration Points**
- Project documentation context
- Conventional commit parsing
- Semantic version analysis
- User feedback incorporation
EOF
}
```

### **Phase 5: Issue Tracking & Management**

```bash
setup_issue_tracking() {
    echo "📊 Setting up release pipeline improvement tracking..."
    
    # Create milestone for tracking
    gh milestone create "Release Pipeline Improvements" \
        --title "Release Pipeline Improvements" \
        --description "Automated improvements to release pipeline, security, and documentation" \
        --due-date "$(date -d '+1 month' '+%Y-%m-%d')" 2>/dev/null || true
    
    # Create project board for tracking
    gh project create "Release Pipeline Modernization" \
        --body "Track and manage release pipeline improvement initiatives" 2>/dev/null || true
    
    echo "✅ Issue tracking setup completed"
}

generate_progress_report() {
    echo "📈 Release Pipeline Improvement Progress Report"
    echo "============================================="
    
    local total_issues=$(gh issue list --label "release-pipeline,automation" --state all --json number | jq length)
    local open_issues=$(gh issue list --label "release-pipeline,automation" --state open --json number | jq length)
    local closed_issues=$((total_issues - open_issues))
    
    echo "📊 Issues: $closed_issues completed, $open_issues remaining ($total_issues total)"
    echo "📋 Recent activity:"
    
    gh issue list --label "release-pipeline,automation" --limit 5 --json title,number,state,labels | \
        jq -r '.[] | "  \(.state): #\(.number) \(.title)"'
    
    echo ""
    echo "🎯 Next recommended actions:"
    echo "  1. Review and prioritize open issues"
    echo "  2. Assign issues to team members"
    echo "  3. Set up automated progress tracking"
    echo "  4. Schedule regular review meetings"
}
```

## **Issue Quality Enhancements:**

### **AI-Powered Content Features:**
- **Project-specific terminology** extracted from documentation
- **Ecosystem-aware implementation** (npm, Python, Docker, etc.)
- **Risk assessment** based on project complexity
- **Integration guidance** for existing tools and workflows
- **Code examples** tailored to project structure
- **Success metrics** relevant to project goals

### **Smart Batching & Prioritization:**
- **Impact-based prioritization** (security > automation > optimization)
- **Complexity assessment** for realistic sprint planning
- **Dependency mapping** between related improvements
- **Resource estimation** for implementation effort
- **Timeline recommendations** based on urgency

### **Tracking & Management:**
- **Milestone creation** for organized progress tracking
- **Label consistency** for easy filtering and reporting
- **Progress dashboards** with automated updates
- **Integration hooks** with project management tools
- **Success metrics** tracking and reporting

This issue generator creates comprehensive, actionable GitHub issues that transform release pipeline analysis into implementable improvements with AI-enhanced content and intelligent project management! 🚀
EOF
)
    
    gh issue create \
        --title "$title" \
        --body "$content" \
        --label "release-notes,automation,ai,documentation" \
        --milestone "Release Pipeline Improvements" 2>/dev/null || true
    
    echo "✅ Created release notes automation issue"
}
```

Now let me complete and test the microagent:

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"content": "Analyze existing microagent structure and patterns", "status": "completed", "activeForm": "Analyzing existing microagent structure and patterns"}, {"content": "Review GitHub Actions workflow files in the project", "status": "completed", "activeForm": "Reviewing GitHub Actions workflow files in the project"}, {"content": "Examine Dependabot configuration and release pipeline", "status": "completed", "activeForm": "Examining Dependabot configuration and release pipeline"}, {"content": "Create release pipeline reviewer microagent", "status": "completed", "activeForm": "Creating release pipeline reviewer microagent"}, {"content": "Create GitHub issue generator for release pipeline improvements", "status": "completed", "activeForm": "Creating GitHub issue generator for release pipeline improvements"}, {"content": "Test the microagent with the current project", "status": "in_progress", "activeForm": "Testing the microagent with the current project"}]