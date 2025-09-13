---
name: documcp
type: knowledge
version: 1.0.0
agent: CodeActAgent
triggers:
- documentation
- docs
- documcp
- readme
- github pages
- static site
- mkdocs
- hugo
- jekyll
- docusaurus
- eleventy
---

# DocuMCP Documentation Assistant

You have access to the DocuMCP MCP server, an intelligent documentation deployment tool for open-source projects. This microagent helps you leverage DocuMCP's capabilities for automated documentation generation and deployment.

## DocuMCP Tools Available

The DocuMCP MCP server provides six core tools for comprehensive documentation workflow:

### 1. analyze_repository
Deep multi-layered analysis of project structure, dependencies, and documentation needs.
- Analyzes codebase structure and existing documentation
- Identifies documentation gaps and opportunities
- Provides insights for documentation strategy

### 2. recommend_ssg
Data-driven recommendations for static site generators (Jekyll, Hugo, Docusaurus, MkDocs, or Eleventy).
- Evaluates project characteristics and requirements
- Recommends the most suitable static site generator
- Provides rationale for recommendations

### 3. generate_config
Creates configuration files for the chosen static site generator.
- Generates optimized configurations
- Includes best practices and project-specific settings
- Supports multiple SSG platforms

### 4. setup_structure
Creates a Diataxis-compliant documentation structure with proper categorization.
- Implements the Diataxis documentation framework
- Organizes content into tutorials, how-to guides, explanations, and reference
- Creates proper directory structure and navigation

### 5. deploy_pages
Sets up GitHub Actions workflows for automated deployment to GitHub Pages.
- Creates CI/CD pipelines for documentation
- Configures automatic deployment on changes
- Handles build and deployment optimization

### 6. verify_deployment
Checks your setup and provides troubleshooting guidance.
- Validates configuration and setup
- Identifies common issues and solutions
- Provides deployment status and recommendations

## Usage Guidelines

### Prerequisites
Before using DocuMCP, ensure:
- You have a GitHub repository that needs documentation
- The repository is accessible (public or you have proper access)
- You want to set up or improve documentation using modern practices

### Typical Documentation Workflow

1. **Start with Repository Analysis**
   ```
   Use the analyze_repository tool to understand the current state of your project's documentation
   ```

2. **Get SSG Recommendations**
   ```
   Use recommend_ssg to get data-driven suggestions for the best static site generator for your project
   ```

3. **Generate Configuration**
   ```
   Use generate_config to create optimized configuration files for your chosen SSG
   ```

4. **Setup Documentation Structure**
   ```
   Use setup_structure to create a Diataxis-compliant documentation organization
   ```

5. **Deploy to GitHub Pages**
   ```
   Use deploy_pages to set up automated deployment workflows
   ```

6. **Verify Setup**
   ```
   Use verify_deployment to ensure everything is working correctly
   ```

### Best Practices

- **Always analyze first**: Start with `analyze_repository` to understand the current state
- **Follow recommendations**: Trust the data-driven suggestions from `recommend_ssg`
- **Use Diataxis framework**: The `setup_structure` tool follows proven documentation organization principles
- **Automate deployment**: Set up GitHub Actions with `deploy_pages` for continuous documentation updates
- **Verify regularly**: Use `verify_deployment` to catch and fix issues early

### Documentation Framework - Diataxis

DocuMCP follows the Diataxis documentation framework which organizes content into four types:

- **Tutorials**: Learning-oriented, hands-on lessons for beginners
- **How-to Guides**: Problem-oriented, practical step-by-step instructions
- **Explanations**: Understanding-oriented, theoretical background and context
- **Reference**: Information-oriented, technical specifications and API docs

### Integration with OpenHands

When working with documentation tasks:
- The microagent automatically triggers when documentation-related keywords are mentioned
- Use MCP tools through OpenHands' built-in MCP integration
- Combine DocuMCP tools with OpenHands' file editing capabilities for complete documentation workflows
- Leverage GitHub integration for seamless repository documentation updates

### Common Use Cases

- **New Project Documentation**: Set up documentation from scratch for new repositories
- **Legacy Project Modernization**: Upgrade existing documentation to modern standards
- **Documentation Site Migration**: Move from one SSG to another with proper configuration
- **GitHub Pages Setup**: Automate deployment and hosting configuration
- **Documentation Audit**: Analyze and improve existing documentation structure

### Troubleshooting

If you encounter issues:
1. Use `verify_deployment` to check for common problems
2. Ensure proper GitHub permissions and repository access
3. Check that the chosen SSG is compatible with your project structure
4. Verify GitHub Pages is enabled for your repository
5. Review GitHub Actions logs for deployment issues

This microagent enhances your documentation workflow by providing intelligent, automated tools for creating professional documentation sites that follow best practices and modern deployment standards.