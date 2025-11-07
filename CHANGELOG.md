# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/username/tote-bag/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/username/tote-bag/releases/tag/v0.0.1
