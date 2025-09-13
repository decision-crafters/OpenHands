# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenHands (formerly OpenDevin) is a platform for AI software development agents that can modify code, run commands, browse the web, and interact with APIs. The project consists of a Python backend with FastAPI server and a React/TypeScript frontend, containerized with Docker.

## Development Setup Commands

### Initial Setup
```bash
# Build project with all dependencies and environment setup
make build

# Setup configuration (prompts for LLM API key, model, workspace)
make setup-config

# Create basic config without prompts
make setup-config-basic
```

### Development Commands
```bash
# Run full application (backend + frontend)
make run

# Run individual servers
make start-backend    # FastAPI server on localhost:3000
make start-frontend   # React dev server on localhost:3001

# Linting and formatting
make lint            # Run all linters (frontend + backend)
make lint-frontend   # ESLint, Prettier, TypeScript checks
make lint-backend    # pre-commit hooks (ruff, mypy, etc.)

# Testing
make test-frontend   # Vitest unit tests
poetry run pytest ./tests/unit/test_*.py  # Python unit tests

# Building
make build-frontend  # Build React app for production
```

### Docker Development
```bash
# Develop inside Docker container
make docker-dev

# Run application in Docker
make docker-run
```

## Code Architecture

### Backend Structure (`/openhands`)
- **`agenthub/`** - AI agents (CodeActAgent, PlannerAgent, etc.) 
- **`controller/`** - Agent execution orchestration
- **`core/`** - Core data structures (Action, Observation, State)
- **`runtime/`** - Execution environments (Docker, E2B, Local, etc.)
- **`server/`** - FastAPI web server and REST API endpoints
- **`llm/`** - LLM integration via litellm library
- **`events/`** - Event system for agent communication
- **`storage/`** - Data persistence and file management
- **`resolver/`** - Issue resolution workflow logic
- **`memory/`** - Conversation and context management

### Frontend Structure (`/frontend`)
- Built with React 19, TypeScript, React Router v7
- TailwindCSS + HeroUI for styling
- Redux Toolkit for state management
- Socket.io for real-time communication with backend
- Monaco Editor for code editing
- Xterm.js for terminal interface

### Package Management
- **Backend**: Poetry (pyproject.toml) - Python 3.12+ required
- **Frontend**: npm (package.json) - Node.js 22+ required
- **Dependencies**: All major dependencies locked in poetry.lock

### Runtime System
The runtime system supports multiple execution environments:
- **Docker**: Default containerized environment
- **Local**: Direct execution on host system  
- **E2B**: Cloud-based code execution
- **Modal**: Serverless compute platform
- **Kubernetes**: Container orchestration

### Testing Strategy
- **Frontend**: Vitest for unit tests, Playwright for E2E
- **Backend**: pytest for unit tests, coverage tracking
- **Integration**: Full stack testing via API endpoints

## Configuration Management
- **config.toml**: Main configuration file (workspace, LLM settings)
- **Environment variables**: Override config.toml settings
- **Priority**: Env vars > config.toml > defaults

## Key Dependencies and Tools
- **LLM Integration**: litellm library (supports OpenAI, Anthropic, etc.)
- **Web Framework**: FastAPI with uvicorn ASGI server
- **Code Quality**: pre-commit hooks with ruff (linting), mypy (typing)
- **Browser Automation**: BrowserGym for web interaction tasks
- **Terminal**: libtmux for session management
- **Container Runtime**: Docker with custom runtime images

## Development Workflow
1. Use `make build` for initial setup
2. Configure LLM via `make setup-config` 
3. Run `make run` to start both servers
4. Frontend available at http://localhost:3001
5. Backend API at http://localhost:3000
6. Always run `make lint` before committing changes
7. Use `export DEBUG=1` for LLM request/response logging

## Important Notes
- The system requires Docker for default runtime execution
- Poetry virtual environment managed automatically
- Pre-commit hooks enforce code quality standards  
- Frontend and backend can be developed independently
- LLM model configuration applies to headless mode; UI allows model selection