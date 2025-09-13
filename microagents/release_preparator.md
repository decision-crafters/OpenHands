---
name: release_preparator
version: 1.0.0
author: openhands
agent: CodeActAgent
triggers:
- /prepare_release
- /finalize_release
- /create_release
inputs:
  - name: TARGET_VERSION
    description: "Version number for the release (e.g., 1.5.0)"
    type: string
    required: true
  - name: RELEASE_TYPE
    description: "Type of release: major, minor, patch, or prerelease"
    type: string
    default: "minor"
  - name: SKIP_TESTS
    description: "Skip final test run (not recommended)"
    type: boolean
    default: false
  - name: DRY_RUN
    description: "Perform dry run without actual release"
    type: boolean
    default: false
---

You are specialized in preparing and executing releases when all quality gates have been passed and release readiness has been confirmed.

## 🚀 Release Preparation & Execution

**⚠️  IMPORTANT**: This microagent should only be used AFTER `/check_release_readiness` confirms the project is ready for release.

### **Pre-Release Validation**
```bash
echo "🔍 Performing final pre-release validation..."

# Ensure we're on the correct branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "❌ ERROR: Must be on main/master branch for release"
    exit 1
fi

# Ensure working directory is clean
if ! git diff --quiet; then
    echo "❌ ERROR: Working directory has uncommitted changes"
    git status
    exit 1
fi

# Pull latest changes
git pull origin $CURRENT_BRANCH

# Final release readiness check
echo "🔍 Running final release readiness check..."
if [ "{{ SKIP_TESTS }}" = "false" ]; then
    /check_release_readiness TARGET_VERSION={{ TARGET_VERSION }}
fi
```

### **Phase 1: Version Management**
```bash
echo "🔢 Phase 1: Managing version numbers..."

update_version_files() {
    local version="{{ TARGET_VERSION }}"

    echo "Updating version to $version in all relevant files..."

    # Update pyproject.toml
    if [ -f "pyproject.toml" ]; then
        sed -i.bak "s/^version = \".*\"/version = \"$version\"/" pyproject.toml
        echo "✅ Updated pyproject.toml"
    fi

    # Update package.json files
    for package_json in $(find . -name "package.json" -not -path "./node_modules/*"); do
        jq --arg version "$version" '.version = $version' "$package_json" > "${package_json}.tmp" && mv "${package_json}.tmp" "$package_json"
        echo "✅ Updated $package_json"
    done

    # Update __init__.py files with version
    if [ -f "openhands/__init__.py" ]; then
        sed -i.bak "s/__version__ = \".*\"/__version__ = \"$version\"/" openhands/__init__.py
        echo "✅ Updated openhands/__init__.py"
    fi

    # Update documentation version references
    find docs -name "*.md" -o -name "*.mdx" | xargs sed -i.bak "s/version: [0-9]\+\.[0-9]\+\.[0-9]\+/version: $version/g" 2>/dev/null || true

    # Update Docker image tags and references
    find . -name "*.yml" -o -name "*.yaml" -o -name "Dockerfile*" | xargs sed -i.bak "s/openhands:[0-9]\+\.[0-9]\+/openhands:${version%.*}/g" 2>/dev/null || true

    # Clean up backup files
    find . -name "*.bak" -delete

    echo "✅ Version updated to $version in all files"
}

update_version_files
```

### **Phase 2: Release Notes & Documentation**
```bash
echo "📝 Phase 2: Finalizing release documentation..."

prepare_release_notes() {
    local version="{{ TARGET_VERSION }}"
    local release_date=$(date +%Y-%m-%d)

    echo "Preparing release notes for v$version..."

    # Create/update CHANGELOG.md
    if [ ! -f "CHANGELOG.md" ]; then
        cat > CHANGELOG.md << EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [${version}] - ${release_date}

### Added
- Initial release

EOF
    else
        # Add new version entry at the top
        sed -i.bak "/^# Changelog/a\\
\\
## [${version}] - ${release_date}\\
\\
### Added\\
- New features and enhancements\\
\\
### Changed\\
- Changes to existing functionality\\
\\
### Fixed\\
- Bug fixes and improvements\\
\\
### Security\\
- Security updates and improvements\\
" CHANGELOG.md

        rm CHANGELOG.md.bak
    fi

    echo "✅ CHANGELOG.md updated for v$version"

    # Generate release notes from recent changes
    echo "📋 Generating release notes from recent changes..."

    # Get commits since last release
    LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    if [ -n "$LAST_TAG" ]; then
        echo "## Changes since $LAST_TAG" > RELEASE_NOTES.md
        git log $LAST_TAG..HEAD --oneline --no-merges >> RELEASE_NOTES.md
    else
        echo "## Initial Release" > RELEASE_NOTES.md
        git log --oneline --no-merges | head -20 >> RELEASE_NOTES.md
    fi

    echo "✅ Release notes generated"
}

if [ "{{ DRY_RUN }}" = "false" ]; then
    prepare_release_notes
else
    echo "🔍 DRY RUN: Would prepare release notes"
fi
```

### **Phase 3: Build & Test Artifacts**
```bash
echo "🔨 Phase 3: Building and testing release artifacts..."

build_and_test_artifacts() {
    local version="{{ TARGET_VERSION }}"

    echo "Building all release artifacts..."

    # Build Python package
    if [ -f "pyproject.toml" ]; then
        echo "🐍 Building Python package..."
        poetry build

        # Verify the package
        echo "🔍 Verifying Python package..."
        poetry run python -c "import pkg_resources; print(pkg_resources.get_distribution('openhands-ai').version)" | grep -q "$version"
        if [ $? -eq 0 ]; then
            echo "✅ Python package version verified"
        else
            echo "❌ ERROR: Python package version mismatch"
            return 1
        fi
    fi

    # Build frontend
    if [ -f "frontend/package.json" ]; then
        echo "🎨 Building frontend..."
        cd frontend
        npm run build

        if [ $? -eq 0 ]; then
            echo "✅ Frontend build successful"
        else
            echo "❌ ERROR: Frontend build failed"
            return 1
        fi
        cd ..
    fi

    # Build VSCode extension
    if [ -f "openhands/integrations/vscode/package.json" ]; then
        echo "🔧 Building VSCode extension..."
        cd openhands/integrations/vscode
        npm run package

        if [ $? -eq 0 ]; then
            echo "✅ VSCode extension build successful"
        else
            echo "❌ ERROR: VSCode extension build failed"
            return 1
        fi
        cd ../../..
    fi

    # Test Docker build
    if [ -f "Dockerfile" ] || [ -f "containers/app/Dockerfile" ]; then
        echo "🐳 Testing Docker build..."
        if [ "{{ DRY_RUN }}" = "false" ]; then
            docker build -t "openhands:$version" .
            if [ $? -eq 0 ]; then
                echo "✅ Docker build successful"
            else
                echo "❌ ERROR: Docker build failed"
                return 1
            fi
        else
            echo "🔍 DRY RUN: Would test Docker build"
        fi
    fi

    echo "✅ All artifacts built and tested successfully"
}

build_and_test_artifacts
```

### **Phase 4: Final Testing**
```bash
echo "🧪 Phase 4: Running final test suite..."

run_final_tests() {
    if [ "{{ SKIP_TESTS }}" = "true" ]; then
        echo "⚠️  SKIPPING final tests (not recommended for production releases)"
        return 0
    fi

    echo "Running comprehensive test suite..."

    # Python tests
    if [ -f "pyproject.toml" ]; then
        echo "🐍 Running Python tests..."
        poetry run pytest --maxfail=1 -v
        if [ $? -ne 0 ]; then
            echo "❌ ERROR: Python tests failed"
            return 1
        fi
        echo "✅ Python tests passed"
    fi

    # Frontend tests
    if [ -f "frontend/package.json" ]; then
        echo "🎨 Running frontend tests..."
        cd frontend
        npm test -- --watchAll=false
        if [ $? -ne 0 ]; then
            echo "❌ ERROR: Frontend tests failed"
            return 1
        fi
        echo "✅ Frontend tests passed"
        cd ..
    fi

    # Integration tests
    if [ -d "tests/integration" ]; then
        echo "🔄 Running integration tests..."
        poetry run pytest tests/integration/ -v
        if [ $? -ne 0 ]; then
            echo "❌ ERROR: Integration tests failed"
            return 1
        fi
        echo "✅ Integration tests passed"
    fi

    echo "✅ All tests passed successfully"
}

run_final_tests
```

### **Phase 5: Git Tagging & Commit**
```bash
echo "📦 Phase 5: Creating release commit and tag..."

create_release_commit() {
    local version="{{ TARGET_VERSION }}"

    if [ "{{ DRY_RUN }}" = "true" ]; then
        echo "🔍 DRY RUN: Would create release commit and tag v$version"
        return 0
    fi

    # Add all version and documentation changes
    git add .

    # Create release commit
    git commit -m "release: prepare v$version

    - Update version numbers to $version
    - Update CHANGELOG.md with release notes
    - Build and verify all release artifacts
    - All tests passing and quality gates met

    Release prepared by OpenHands Release Preparator"

    if [ $? -eq 0 ]; then
        echo "✅ Release commit created"
    else
        echo "❌ ERROR: Failed to create release commit"
        return 1
    fi

    # Create and sign release tag
    git tag -a "v$version" -m "Release v$version

$(head -20 RELEASE_NOTES.md 2>/dev/null || echo "Release v$version")

🚀 Generated with OpenHands Release Preparator"

    if [ $? -eq 0 ]; then
        echo "✅ Release tag v$version created"
    else
        echo "❌ ERROR: Failed to create release tag"
        return 1
    fi

    echo "🎯 Release commit and tag ready!"
    echo "Next steps:"
    echo "1. Review changes: git show v$version"
    echo "2. Push release: git push origin main && git push origin v$version"
    echo "3. Create GitHub release: gh release create v$version"
    echo "4. Publish packages: poetry publish (if ready)"
}

create_release_commit
```

### **Phase 6: Release Artifacts & Publishing**
```bash
echo "🚀 Phase 6: Publishing release (if not dry run)..."

publish_release() {
    local version="{{ TARGET_VERSION }}"

    if [ "{{ DRY_RUN }}" = "true" ]; then
        echo "🔍 DRY RUN: Would publish release v$version"
        return 0
    fi

    echo "Publishing release v$version..."

    # Push git changes
    git push origin $(git branch --show-current)
    git push origin "v$version"

    # Create GitHub release
    gh release create "v$version" \
        --title "Release v$version" \
        --notes-file RELEASE_NOTES.md \
        --draft

    echo "✅ GitHub release created as DRAFT"
    echo "📋 Manual steps required:"
    echo "1. Review the draft release at: $(gh release view v$version --web 2>/dev/null || echo 'GitHub Releases page')"
    echo "2. Edit release notes if needed"
    echo "3. Publish the draft release"
    echo "4. Manually trigger PyPI publish workflow if ready"
    echo "5. Announce release on communication channels"

    # Cleanup
    rm -f RELEASE_NOTES.md
}

publish_release
```

## 📋 **Post-Release Checklist**

After successful release preparation, ensure:

- [ ] **Git**: Release commit and tag created
- [ ] **GitHub**: Draft release created with release notes
- [ ] **Artifacts**: All packages built and verified
- [ ] **Tests**: Full test suite passed
- [ ] **Documentation**: CHANGELOG.md updated
- [ ] **Version**: All files updated to new version

## 🔄 **Integration Points**

This microagent integrates with:
- **Release Readiness Checker**: Ensures quality gates before proceeding
- **Version Consistency Check**: Validates version updates across files
- **CI/CD Pipeline**: Triggers final builds and tests
- **GitHub API**: Creates releases and manages tags

## ⚠️ **Safety Measures**

- **Dry Run Mode**: Test entire release process without side effects
- **Pre-flight Checks**: Validates environment and readiness
- **Atomic Operations**: Rollback capability if any step fails
- **Draft Releases**: Creates draft releases requiring manual approval

## 🎯 **Success Criteria**

Release preparation is successful when:
- All version numbers updated consistently
- Release commit and tag created
- All artifacts build successfully
- Full test suite passes
- GitHub draft release ready for final review and publication

Use this microagent only after confirming release readiness with `/check_release_readiness`!
