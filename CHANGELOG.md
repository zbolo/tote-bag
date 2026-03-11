# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.1] - 2026-03-11

### Changed
- Redesigned app logo to match the earthy color palette
  - Deep forest green gradient background
  - Terracotta-colored handles
  - Warm off-white bag body with checklist items
  - Golden mustard accent stripe
  - Small leaf accent for organic/natural feel
- Updated Android adaptive icon background to forest green (#1B6B4E)
- Added `remove_alpha_ios: true` for App Store compliance
- Regenerated all platform icons (Android, iOS, Web)

## [0.4.0] - 2026-03-11

### Added
- Structured logging service (`Log`) with debug/info/warn/error levels
  - Logs all API requests and responses with method, path, and status
  - Logs all state changes in providers (user, lists, favorites)
  - Logs all user interactions (sign in, create list, add item, scan barcode, etc.)
  - Only emits in debug mode — zero overhead in release builds
- `AppException` typed error class with user-friendly messages
  - Maps HTTP status codes to readable messages (401 → "Session expired", 500 → "Server error", etc.)
  - Maps Dio connection errors to network messages
  - Extracts server-side error messages when available
- `showErrorSnackBar` / `showSuccessSnackBar` / `showInfoSnackBar` helpers
  - Floating SnackBars with rounded corners matching app design
- Dio interceptor logging for all HTTP traffic (request → response / error)

### Changed
- All services now throw `AppException` instead of generic `Exception`
- Error SnackBars show user-friendly messages instead of raw `e.toString()`
- Error states in screens show friendly text with "Try Again" buttons
- Replaced `error_outline` icon with `cloud_off_outlined` for network errors
- Updated `create_list_dialog` color palette to match new app theme colors
- Regenerated Mockito mocks to fix stale `override_on_non_overriding_member` warning

## [0.3.0] - 2026-03-11

### Changed
- New UI color palette extracted from reference images (earthy/natural tones)
  - Primary: Deep forest green (#1B6B4E)
  - Secondary: Terracotta (#C47B62)
  - Accent: Golden mustard (#BFA033)
  - Background: Warm off-white (#F5F0EA)
  - Warm-toned text and border colors
- Added extended palette colors: sage light, olive sage, teal grey
- Updated all theme colors (text, borders, dividers) to warm tones

## [0.2.1] - 2026-03-11

### Changed
- Upgraded Node.js from 24.x to 25.x across the entire project
- Updated Dockerfile to use `node:25-alpine` base image
- Updated engine requirements to `>=25.0.0` in both root and backend package.json
- Updated README and CLAUDE.md to reflect Node.js 25.x

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

[Unreleased]: https://github.com/username/tote-bag/compare/v0.4.1...HEAD
[0.4.1]: https://github.com/username/tote-bag/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/username/tote-bag/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/username/tote-bag/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/username/tote-bag/compare/v0.2.0...v0.2.1
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
