---
name: release_pipeline_reviewer
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /review_release_pipeline
- /analyze_release_workflow
- /check_dependabot_integration
inputs:
  - name: PROJECT_PATH
    description: "Path to the project directory (defaults to current directory)"
    type: string
    default: "."
  - name: TARGET_VERSION
    description: "Target version for release analysis (optional)"
    type: string
    default: ""
  - name: AI_MODEL
    description: "AI model to use: gemini, openai, claude, or custom"
    type: string
    default: "gemini"
  - name: API_KEY
    description: "API key for the selected AI model (will prompt if not provided)"
    type: string
    default: ""
  - name: CUSTOM_MODEL_ENDPOINT
    description: "Custom model endpoint URL (if using custom model)"
    type: string
    default: ""
  - name: CREATE_ISSUES
    description: "Create GitHub issues for identified improvements"
    type: boolean
    default: true
  - name: AUTO_RELEASE_THRESHOLD
    description: "Dependency update types that should trigger auto-release: patch, minor, major"
    type: string
    default: "patch"
  - name: ANALYZE_DOCS
    description: "Include project documentation in AI analysis"
    type: boolean
    default: true
---

You are the release pipeline reviewer that analyzes GitHub Actions workflows, Dependabot configuration, release automation, and automated release note generation for any software project.

## 🎯 **Release Pipeline Analysis & Optimization with AI-Enhanced Release Notes**

This microagent performs comprehensive analysis of release pipelines and creates actionable GitHub issues to improve automation, reliability, and release documentation.

### **Enhanced Core Analysis Areas:**

#### **1. GitHub Actions Workflow Analysis**
- ✅ Release workflow existence and completeness
- ✅ Version management automation
- ✅ Package publication workflows (npm, PyPI, Docker, etc.)
- ✅ Testing integration in release pipeline
- ✅ Security scanning and quality gates
- ✅ Multi-platform build support
- ✅ Artifact management and signing

#### **2. Dependabot Integration Assessment**
- ✅ Dependabot configuration completeness
- ✅ Auto-merge capabilities for dependency updates
- ✅ Integration with release automation
- ✅ Security update handling
- ✅ Dependency grouping optimization
- ✅ PR limits and scheduling efficiency

#### **3. Release Notes & Documentation Analysis**
- ✅ Current release note generation practices
- ✅ Changelog automation capabilities
- ✅ Conventional commit compliance
- ✅ Documentation integration with releases
- ✅ User-facing change communication
- ✅ Breaking change identification and documentation

#### **4. Version Management Analysis**
- ✅ Version file identification across ecosystems
- ✅ Semantic versioning compliance
- ✅ Version synchronization across files
- ✅ Release tagging consistency
- ✅ Changelog automation
- ✅ Release note generation

#### **5. Auto-Release Pipeline Design**
- ✅ Dependency update classification (patch/minor/major)
- ✅ Automated testing requirements for releases
- ✅ Quality gate bypass conditions
- ✅ Release approval workflows
- ✅ Rollback mechanisms
- ✅ Notification systems

## **Usage Examples:**

### **Interactive Model Selection:**
```bash
/review_release_pipeline
# Will prompt: "Which AI model would you like to use for enhanced analysis?"
# Options: 1) Gemini (default), 2) OpenAI GPT-4, 3) Claude, 4) Custom endpoint
```

### **Direct Model Specification:**
```bash
/review_release_pipeline AI_MODEL=openai API_KEY=your_openai_key
```

### **Custom Model with Documentation Analysis:**
```bash
/review_release_pipeline AI_MODEL=custom CUSTOM_MODEL_ENDPOINT=https://your-model.com/api ANALYZE_DOCS=true
```

### **Comprehensive Analysis:**
```bash
/review_release_pipeline PROJECT_PATH=/path/to/project CREATE_ISSUES=true AUTO_RELEASE_THRESHOLD=minor ANALYZE_DOCS=true
```

## **Enhanced Analysis Logic:**

### **Phase 1: Model Selection & Setup**

```bash
setup_ai_model() {
    local model="${AI_MODEL:-gemini}"
    local api_key="${API_KEY}"
    
    if [ -z "$api_key" ]; then
        echo "🤖 AI Model Selection"
        echo "Which AI model would you like to use for enhanced analysis?"
        echo "1) Gemini (Google) - Default, good for technical analysis"
        echo "2) OpenAI GPT-4 - Excellent for documentation and user-facing content"
        echo "3) Claude (Anthropic) - Strong technical writing and analysis"
        echo "4) Custom endpoint - Your own model/endpoint"
        echo ""
        read -p "Enter choice (1-4) [1]: " choice
        
        case ${choice:-1} in
            1) model="gemini" ;;
            2) model="openai" ;;
            3) model="claude" ;;
            4) model="custom" ;;
            *) model="gemini" ;;
        esac
        
        echo ""
        if [ "$model" != "custom" ]; then
            read -p "Enter your $model API key: " -s api_key
            echo ""
        else
            read -p "Enter custom model endpoint URL: " endpoint
            read -p "Enter API key (if required): " -s api_key
            CUSTOM_MODEL_ENDPOINT="$endpoint"
            echo ""
        fi
    fi
    
    AI_MODEL="$model"
    API_KEY="$api_key"
    
    echo "✅ AI Model configured: $AI_MODEL"
}
```

### **Phase 2: Project Documentation Analysis**

```bash
analyze_project_documentation() {
    local project_path="${PROJECT_PATH:-.}"
    local analyze_docs="${ANALYZE_DOCS:-true}"
    
    if [ "$analyze_docs" != "true" ]; then
        echo "⚠️  Documentation analysis disabled"
        return 0
    fi
    
    echo "📚 Analyzing project documentation..."
    
    local doc_files=()
    local doc_content=""
    
    # Find documentation files
    for pattern in "README*" "CHANGELOG*" "RELEASE*" "CONTRIBUTING*" "docs/*" ".github/*" "wiki/*"; do
        while IFS= read -r -d '' file; do
            if [[ -f "$file" && $(file "$file" | grep -i text) ]]; then
                doc_files+=("$file")
                echo "  📄 Found: $(basename "$file")"
            fi
        done < <(find "$project_path" -iname "$pattern" -type f -print0 2>/dev/null)
    done
    
    # Read key documentation files
    for doc_file in "${doc_files[@]:0:10}"; do  # Limit to first 10 files to avoid token limits
        if [[ $(stat -f%z "$doc_file" 2>/dev/null || stat -c%s "$doc_file") -lt 50000 ]]; then  # Skip very large files
            local filename=$(basename "$doc_file")
            doc_content+="=== $filename ===\n"
            doc_content+="$(cat "$doc_file")\n\n"
        fi
    done
    
    project_documentation="$doc_content"
    echo "📋 Analyzed ${#doc_files[@]} documentation files"
}
```

### **Phase 3: Release Notes Analysis**

```bash
analyze_release_notes_practices() {
    local project_path="${PROJECT_PATH:-.}"
    
    echo "📝 Analyzing current release notes practices..."
    
    local has_changelog=$(find "$project_path" -iname "*changelog*" -o -iname "*history*" -o -iname "*releases*" | head -1)
    local has_github_releases=$(gh release list --limit 5 2>/dev/null | wc -l)
    local has_conventional_commits=$(git log --oneline -n 20 | grep -E "^[a-f0-9]+ (feat|fix|docs|style|refactor|test|chore)(\(.+\))?:" | wc -l)
    local has_semantic_versioning=$(git tag --sort=-version:refname | head -5 | grep -E "^v?[0-9]+\.[0-9]+\.[0-9]+" | wc -l)
    
    echo "  📋 Changelog file: $([ -n "$has_changelog" ] && echo "✅ Found: $(basename "$has_changelog")" || echo "❌ Missing")"
    echo "  🏷️  GitHub releases: $([ "$has_github_releases" -gt 0 ] && echo "✅ $has_github_releases releases found" || echo "❌ No releases")"
    echo "  📝 Conventional commits: $([ "$has_conventional_commits" -gt 5 ] && echo "✅ $has_conventional_commits/20 commits follow convention" || echo "❌ Limited conventional commit usage")"
    echo "  🔢 Semantic versioning: $([ "$has_semantic_versioning" -gt 0 ] && echo "✅ $has_semantic_versioning semantic version tags" || echo "❌ No semantic versions")"
    
    # Analyze existing release notes quality
    local recent_release_notes=""
    if [ "$has_github_releases" -gt 0 ]; then
        recent_release_notes=$(gh release view --json body --jq '.body' 2>/dev/null | head -c 2000)
    fi
    
    release_notes_analysis="changelog:$([ -n "$has_changelog" ] && echo "true" || echo "false"),github_releases:$has_github_releases,conventional_commits:$has_conventional_commits,semantic_versioning:$has_semantic_versioning,recent_notes:$recent_release_notes"
}
```

### **Phase 4: AI-Enhanced Analysis with Documentation Context**

```bash
perform_ai_analysis() {
    local model="${AI_MODEL:-gemini}"
    local api_key="${API_KEY}"
    
    if [ -z "$api_key" ]; then
        echo "⚠️  No API key provided, skipping AI analysis"
        return 0
    fi
    
    echo "🤖 Performing AI-enhanced analysis with $model..."
    
    # Prepare comprehensive analysis context
    local analysis_context=$(cat << EOF
# Project Release Pipeline Analysis

## Project Structure
- Ecosystems: ${ecosystems[*]}
- Version files: ${version_files[*]}
- Documentation files: ${#doc_files[@]} files analyzed

## Current Release Pipeline
- Workflows: ${workflow_findings[*]}
- Dependabot: $dependabot_analysis
- Auto-release capability: $auto_release_assessment
- Release notes practices: $release_notes_analysis

## Project Documentation
$project_documentation

## Analysis Request
Please analyze this project's release pipeline and provide specific, actionable recommendations for:

1. **Automated Release Notes Generation**
   - How to improve release notes based on current practices
   - Integration with the existing workflow
   - Best practices for this specific project type

2. **Release Pipeline Security & Reliability**
   - Security vulnerabilities and mitigations
   - Reliability improvements
   - Industry best practices

3. **Dependabot Integration Optimization**
   - Auto-merge strategies
   - Release automation triggers
   - Risk mitigation for automated releases

4. **Documentation & Communication**
   - User-facing change communication
   - Breaking change identification
   - Release announcement strategies

5. **Specific Implementation Steps**
   - Prioritized action items
   - Code examples and configurations
   - Integration with existing tools

Format your response as structured recommendations with specific implementation details.
EOF
)
    
    # Call the selected AI model
    local ai_response=""
    case "$model" in
        "gemini")
            ai_response=$(call_gemini_api "$analysis_context")
            ;;
        "openai")
            ai_response=$(call_openai_api "$analysis_context")
            ;;
        "claude")
            ai_response=$(call_claude_api "$analysis_context")
            ;;
        "custom")
            ai_response=$(call_custom_api "$analysis_context")
            ;;
    esac
    
    ai_recommendations="$ai_response"
    echo "✅ AI analysis completed"
}

call_gemini_api() {
    local context="$1"
    
    curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"contents\": [{
                \"parts\": [{
                    \"text\": \"$context\"
                }]
            }]
        }" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null || echo "AI analysis failed"
}

call_openai_api() {
    local context="$1"
    
    curl -s -X POST "https://api.openai.com/v1/chat/completions" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"model\": \"gpt-4\",
            \"messages\": [{
                \"role\": \"user\",
                \"content\": \"$context\"
            }],
            \"max_tokens\": 4000
        }" | jq -r '.choices[0].message.content' 2>/dev/null || echo "AI analysis failed"
}

call_claude_api() {
    local context="$1"
    
    curl -s -X POST "https://api.anthropic.com/v1/messages" \
        -H "x-api-key: $API_KEY" \
        -H "Content-Type: application/json" \
        -H "anthropic-version: 2023-06-01" \
        -d "{
            \"model\": \"claude-3-sonnet-20240229\",
            \"max_tokens\": 4000,
            \"messages\": [{
                \"role\": \"user\",
                \"content\": \"$context\"
            }]
        }" | jq -r '.content[0].text' 2>/dev/null || echo "AI analysis failed"
}

call_custom_api() {
    local context="$1"
    
    curl -s -X POST "$CUSTOM_MODEL_ENDPOINT" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"prompt\": \"$context\",
            \"max_tokens\": 4000
        }" | jq -r '.response // .text // .content' 2>/dev/null || echo "AI analysis failed"
}
```

### **Phase 5: Enhanced Issue Generation with AI Insights**

```bash
generate_enhanced_issues() {
    local create_issues="${CREATE_ISSUES:-true}"
    
    if [ "$create_issues" != "true" ]; then
        echo "📋 Issue creation disabled, showing recommendations only"
        show_enhanced_recommendations
        return 0
    fi
    
    echo "📝 Creating enhanced GitHub issues with AI insights..."
    
    # Issue 1: Automated Release Notes Generation
    create_release_notes_issue
    
    # Issue 2: Dependabot Auto-Release Integration
    if [[ "$auto_release_assessment" == *"ready:false"* ]]; then
        create_auto_release_issue
    fi
    
    # Issue 3: Release Pipeline Security Enhancement
    create_security_enhancement_issue
    
    # Issue 4: Documentation Integration
    create_documentation_integration_issue
    
    # Issue 5: Version Management Centralization
    if [ ${#version_files[@]} -gt 1 ]; then
        create_version_management_issue
    fi
    
    echo "✅ Created enhanced release pipeline improvement issues"
}

create_release_notes_issue() {
    local title="Implement AI-Enhanced Automated Release Notes Generation"
    
    local issue_body=$(cat << EOF
## 🤖 Implement AI-Enhanced Automated Release Notes Generation

### **Current State Analysis**
$release_notes_analysis

### **AI-Enhanced Recommendations**
$ai_recommendations

### **Implementation Plan**

#### **Phase 1: Foundation Setup**
- [ ] Install and configure release note generation tools
- [ ] Set up conventional commit linting (if not already configured)
- [ ] Create release note templates for different change types
- [ ] Configure semantic versioning automation

#### **Phase 2: AI Integration**
- [ ] Set up $AI_MODEL integration for release note enhancement
- [ ] Create prompts for generating user-friendly release notes
- [ ] Implement breaking change detection and highlighting
- [ ] Add context from project documentation for relevant notes

#### **Phase 3: Workflow Integration**
- [ ] Integrate with existing GitHub Actions workflows
- [ ] Configure automatic release note generation on version bumps
- [ ] Set up release note preview in PRs
- [ ] Add manual override capabilities for sensitive releases

#### **Phase 4: Quality & Customization**
- [ ] Add project-specific terminology and style
- [ ] Implement user impact categorization
- [ ] Set up release note approval workflow
- [ ] Add metrics tracking for release note quality

### **Technical Implementation**

#### **GitHub Actions Workflow Example**
\`\`\`yaml
name: Generate Release Notes
on:
  push:
    tags: ['v*']

jobs:
  release-notes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Generate AI-Enhanced Release Notes
        env:
          AI_API_KEY: \${{ secrets.${AI_MODEL^^}_API_KEY }}
        run: |
          # Extract commits since last release
          COMMITS=\$(git log --oneline \$(git describe --tags --abbrev=0 HEAD~1)..HEAD)
          
          # Generate AI-enhanced release notes
          curl -X POST "https://api.${AI_MODEL}.com/generate" \\
            -H "Authorization: Bearer \$AI_API_KEY" \\
            -d "{
              \"prompt\": \"Generate user-friendly release notes for: \$COMMITS\",
              \"context\": \"$(cat README.md | head -c 1000)\"
            }"
      
      - name: Create GitHub Release
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create \${{ github.ref_name }} \\
            --title "Release \${{ github.ref_name }}" \\
            --notes-file release-notes.md
\`\`\`

#### **Release Note Template**
\`\`\`markdown
# Release {{version}} - {{date}}

{{ai_generated_summary}}

## 🚀 New Features
{{features}}

## 🐛 Bug Fixes
{{fixes}}

## 📚 Documentation
{{docs}}

## 🔒 Security Updates
{{security}}

## ⚠️ Breaking Changes
{{breaking_changes}}

## 📦 Dependencies
{{dependencies}}

## 🙏 Contributors
{{contributors}}
\`\`\`

### **Expected Benefits**
- ✅ Automated, consistent release notes
- ✅ AI-enhanced user-friendly language
- ✅ Project context-aware descriptions
- ✅ Breaking change highlighting
- ✅ Reduced manual release overhead

### **Success Metrics**
- Release note generation time < 2 minutes
- 100% automated release note coverage
- Improved user understanding of changes
- Reduced support questions about releases

---
*Generated by Release Pipeline Reviewer with $AI_MODEL analysis*
EOF
)

    gh issue create \
        --title "🤖 $title" \
        --body "$issue_body" \
        --label "release-pipeline,automation,ai-enhanced,documentation" \
        --assignee "@me"
    
    echo "✅ Created AI-enhanced release notes issue"
}
```

### **Enhanced Issue Templates with AI Context**

The microagent will create issues that include:

1. **AI model-specific recommendations** based on the selected model's analysis
2. **Project documentation context** integrated into suggestions
3. **Specific implementation code** tailored to the project's ecosystem
4. **Prioritized action items** based on AI analysis of the project's current state
5. **Breaking change detection** strategies specific to the project type
6. **User impact analysis** informed by existing documentation

### **Release Notes Enhancement Features**

- **Conventional commit parsing** with AI enhancement for better readability
- **Documentation context integration** for more relevant release notes
- **Breaking change detection** and user impact analysis
- **Multi-language support** based on project documentation
- **Custom terminology** extraction from project docs
- **User persona-aware** release note generation

This enhanced microagent provides comprehensive release pipeline analysis with intelligent, context-aware release note generation using the user's preferred AI model! 🎯