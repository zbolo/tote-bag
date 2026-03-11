# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-03-11

### Added
- Change password endpoint (`POST /auth/change-password`) with current password verification
- Auth health check endpoint (`GET /auth/health`)
- Production Docker Compose configuration (`docker-compose.prod.yml`) with health checks, restart policies, and named volumes
- pgAdmin service in development Docker Compose for database management (port 8081)
- Docker health checks for all services (backend, postgres, supertokens)
- OpenAPI 3.0.3 specification with Swagger UI served at `/api-docs`
- Environment validation on startup (fails fast in production if secrets are missing)
- UserMetadata SuperTokens recipe

### Changed
- **BREAKING**: Upgraded SuperTokens from v20 to v24 (supertokens-node ^24.0.1)
- **BREAKING**: Upgraded Express from v4 to v5 (express ^5.2.1)
- **BREAKING**: Disabled user sign-up - users must be created by admin via SuperTokens Dashboard
- Upgraded SuperTokens Docker image from `latest` to pinned `11.4`
- Upgraded express-rate-limit from ^7.4.1 to ^8.3.0
- Added swagger-ui-express and yamljs dependencies for API documentation
- Improved structured logging with `[Module]` prefix throughout backend
- Graceful shutdown now properly closes database connections

### Removed
- Sign-up functionality (temporarily disabled, to be re-enabled later)
- JWT_SECRET environment variable (not needed with SuperTokens session management)

## [0.1.7] - 2026-03-11

### Fixed
- Fixed Docker build by tracking `package-lock.json` in git (required by `npm ci`)
- Updated Dockerfile to use `--omit=dev` instead of deprecated `--only=production`
- Removed `package-lock.json` from `.gitignore`

## [0.1.6] - 2025-11-07

### Fixed
- Fixed FavoriteProductService to lookup User entity by SuperTokens ID
- All favorite methods now correctly resolve user from supertokensUserId
- Resolved "Failed to load favorites" error in mobile app
- Fixed getFavorites, addFavorite, removeFavorite, toggleFavorite, isFavorite, and getFavoriteStatuses methods

### Added
- Comprehensive logging for favorite operations debugging

## [0.1.5] - 2025-11-07

### Fixed
- Fixed shopping list serialization by populating owner field in getUserLists
- Added explicit owner population after list creation
- Resolved "String is not a subtype of Map<String, dynamic>" error in Flutter app
- Shopping lists now return full owner object instead of just ID

### Changed
- Updated ShoppingListService.getUserLists to include 'owner' in populate array
- Updated ShoppingListService.createList to populate relations before returning

## [0.1.4] - 2025-11-07

### Fixed
- Fixed Zod validation to accept null values for optional fields
- Shopping list creation now works when mobile app sends null for optional fields (icon, description, color)
- Item creation accepts null for optional fields (quantity, unit, notes, category, barcode, productId)
- User profile updates accept null for avatarUrl

### Changed
- Updated all optional Zod schema fields to use `.nullable()` for better mobile app compatibility

## [0.1.3] - 2025-11-07

### Added
- Admin endpoint `/api/v1/admin/sync-user/:userId` to sync SuperTokens users to database
- ADMIN_ENDPOINTS.md documentation for admin operations
- Support for syncing users created directly in SuperTokens dashboard

### Fixed
- User lookup now correctly handles users created through SuperTokens dashboard
- Simplified `/api/v1/users/me` endpoint with clear error messages
- Removed complex fallback user creation logic that was causing errors

### Changed
- `/api/v1/users/me` now returns 404 with helpful message if user not in database
- Improved logging for user authentication and lookup operations

## [0.1.2] - 2025-11-07

### Fixed
- Fixed user creation after SuperTokens signup by implementing proper database hook
- Converted SuperTokens hook from TypeScript to JavaScript syntax
- Integrated user creation hook into SuperTokens EmailPassword recipe configuration
- Added automatic user creation in /me endpoint for existing users who signed up before hook was implemented
- Resolved 404 error on /api/v1/users/me endpoint

### Added
- Comprehensive logging for user creation and authentication flows
- Automatic fallback user creation when authenticated users don't exist in database

## [0.1.1] - 2025-11-07

### Fixed
- Removed Content Security Policy (CSP) restrictions that blocked SuperTokens dashboard resources
- Configured CORS to use SuperTokens.getAllCORSHeaders() for proper authentication header handling
- Disabled helmet CSP while maintaining other security headers
- Resolved CSP violation for cdn.jsdelivr.net resources required by SuperTokens

### Changed
- Updated CORS configuration to allow all origins in development mode
- Simplified CORS middleware to use SuperTokens recommended configuration

## [0.1.0] - 2025-11-07

### Added
- CLAUDE.md with project-specific development guidelines
- CHANGELOG.md following Keep a Changelog format
- Jest configuration for ES modules (JavaScript)
- Comprehensive logging requirements in CLAUDE.md

### Changed
- Fixed Jest configuration to work with JavaScript (.js) instead of TypeScript (.ts)
- Updated project structure documentation to reflect current layout

### Fixed
- Jest test setup for ES modules compatibility

## [0.0.1] - 2025-01-07

### Added
- Initial project setup with Flutter mobile app and Node.js backend
- Shared shopping lists functionality with real-time sync
- Barcode scanning with OpenFoodFacts API integration
- User authentication with Supertokens
- Multi-platform support (iOS and Android)
- Docker compose setup for PostgreSQL and Supertokens
- MikroORM integration for database operations
- Riverpod state management in Flutter
- Favorite products functionality
- Bring!-style UI with product grid for quick add
- Native TypeScript support with Node.js v24

### Technical Details
- Backend refactored from TypeScript to Plain JavaScript with JSDoc
- Project structure reorganized (moved from packages/ to root-level directories)
- Flutter SDK 3.24.0+
- Node.js 24.x with ES Modules
- PostgreSQL 16
- Supertokens 20.1.5
- MikroORM 6.3.12

[Unreleased]: https://github.com/username/tote-bag/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/username/tote-bag/compare/v0.1.7...v0.2.0
[0.1.7]: https://github.com/username/tote-bag/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/username/tote-bag/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/username/tote-bag/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/username/tote-bag/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/username/tote-bag/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/username/tote-bag/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/username/tote-bag/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/username/tote-bag/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/username/tote-bag/releases/tag/v0.0.1
