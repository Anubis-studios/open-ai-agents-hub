# Vibe-Agents Changelog

## [Unreleased]

### Security
- Added environment variable configuration for CORS origins
- Implemented Pydantic models for request validation on all POST/PUT endpoints
- Enhanced API key error handling to prevent information leakage
- Added User-Agent header to outgoing requests

### Backend Improvements
- Enhanced health check endpoint with dependency verification
- Configurable request timeouts based on operation type (default, chat, image generation)
- Improved error handling with specific HTTP status codes:
  - 504 for timeouts
  - 503 for connection errors
  - 502 for upstream service errors
- Added structured logging with configurable log levels
- Removed unused dependencies (sqlalchemy, asyncpg, ruff)
- Pinned dependency versions for reproducible builds

### Frontend Improvements
- Added loading state with spinner for agent client wrapper
- Implemented error state UI with retry functionality
- Enhanced fetchAgentData with proper error handling and logging
- Environment-based API URL configuration via NEXT_PUBLIC_API_URL
- Better error messages for failed API requests

### Documentation
- Created comprehensive DEVELOPMENT.md guide
- Added .env.example with documented environment variables
- Created CHANGELOG.md for tracking changes

### Code Quality
- Added docstrings to all endpoint functions
- Implemented consistent logging patterns
- Added type hints throughout the codebase

## [1.0.0] - Initial Release
- Basic agent proxy functionality
- Simple CORS configuration
- Mock user authentication
- Basic health check endpoint
