# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.1] - 2026-03-11

### Changed
- **Add pantry item** converted from dialog to full-page screen for better usability with many fields
  - Organized form into clear sections: Product Info, Storage, Dates, Extra Details
  - Form validation with required field indicators
  - Section labels for better visual hierarchy
  - Date pickers styled as tappable tiles instead of plain ListTiles

### Added
- **Barcode scanning for pantry items** — scan a product barcode to auto-fill name and category
  - Prominent "Scan Barcode" button at the top of the add item form
  - Product found: displays product card with image, auto-fills name and category fields
  - Product not found: prompts for product name, then pre-fills the form
  - Scanned product can be cleared to enter details manually instead

## [0.7.0] - 2026-03-11

### Added
- **Pantry feature** — track what you have at home, complementary to shopping lists
  - Pantry CRUD with sharing support (read/write/admin permissions, like shopping lists)
  - Pantry items with: quantity, max quantity, unit, category, expiration date, purchase date, price, barcode, product reference, notes
  - **Quantity slider** for gradual consumption tracking — drag to reduce remaining quantity
  - Quantity progress bar color-coded: green (>50%), amber (25-50%), red (<25%)
  - **Custom storage locations** per pantry (default: Fridge, Freezer, Cupboard, Cellar, Other)
  - Add, edit, and remove storage locations via bottom sheet manager
  - Items grouped by storage location with collapsible sections
  - **Expiration date tracking** with color-coded chips: green (>7d), amber (3-7d), red (<3d), "Expired" badge
  - Expiration warning banner at top of pantry detail screen
  - **Low stock detection** — items flagged when quantity drops below threshold (default 25%)
  - Low stock badge on pantry cards and item cards
  - **Search and filter** — search items by name, filter by storage location via chips
  - Smart endpoints: GET expiring items, GET low-stock items, GET shopping list suggestions
  - **Move from shopping list** — bulk move checked items from shopping list to pantry with optional auto-removal
  - Backend: `Pantry`, `PantryItem`, `PantryShare`, `StorageLocation` MikroORM entities
  - Backend: `PantryService` with full CRUD, sharing, and smart query methods
  - Backend: REST API routes at `/api/v1/pantries/*` with Zod validation
  - Mobile: `Pantry`, `PantryItem`, `StorageLocation` Dart models with computed properties
  - Mobile: `PantryService` with full API client methods
  - Mobile: Riverpod providers for pantries, pantry detail, search, filter, view mode
  - Mobile: `PantryListScreen`, `PantryDetailScreen`, `AddPantryItemDialog`, `CreatePantryDialog`
  - Mobile: `PantryCard`, `PantryItemCard` widgets
  - Database migration for pantry, pantry_item, pantry_share, storage_location tables

### Changed
- Home screen replaced with `MainShellScreen` featuring a bottom navigation bar (Lists | Pantry)
- Router updated with pantry routes (`/pantry/:id`)

## [0.6.0] - 2026-03-11

### Added
- List/grid view toggle for shopping list items (Bring!/KitchenOwl style)
  - Toggle button in list detail screen app bar switches between list and card views
  - New `ListItemGridCard` widget displays items as visual cards in a 3-column grid
  - Grid cards show product image, name, quantity, category badge, favorite star, and check overlay
  - Long-press on grid card to delete item
  - `listViewModeProvider` (Riverpod StateProvider) tracks current view mode
- Widget tests for `ListItemGridCard` covering all display states

### Fixed
- Product image from OpenFoodFacts not saved after barcode scan
  - `ShoppingListService.addItem()` was spreading `productId` (string) directly into the entity create, but MikroORM expects a `product` reference object
  - Now properly resolves `productId` to a Product entity reference before creating the item
  - Response now populates the product relation so the image URL is available immediately
- "Something went wrong" error when toggling check on items with product images in card view
  - `ShoppingListService.updateItem()` was not populating the `product` relation
  - MikroORM returned the unpopulated product as a raw UUID string instead of a full object
  - Mobile tried to cast the UUID string to `Map<String, dynamic>` → type error
  - Items without products (null) were unaffected, causing the asymmetric behavior
  - Both items appeared checked because the API call succeeded server-side but the response parsing failed, preventing UI refresh until the next successful action
- Added `ValueKey` to grid card widgets to prevent stale widget reuse during list rebuilds
- OpenAPI spec updated to include `product` field in `ShoppingListItem` schema

### Changed
- Product images are now shown only in grid/card view, not in list view
  - `ListItemCard` no longer displays product thumbnails for a cleaner compact layout
  - Grid view is the place to see product images at a glance
- Updated `ListItemCard` test to reflect image removal from list view

## [0.5.0] - 2026-03-11

### Added
- Product image support for barcode scans
  - OpenFoodFacts images are displayed in product dialog, grid tiles, and list item cards using CachedNetworkImage for efficient caching
  - Manual product creation with image upload when barcode is not found in OpenFoodFacts
  - Image picker dialog (camera or gallery) in the "Product Not Found" manual entry screen
  - Backend image upload endpoint (`POST /api/v1/products`) with multer (JPEG, PNG, WebP, max 5 MB)
  - Backend image replacement endpoint (`POST /api/v1/products/:productId/image`)
  - Static file serving for uploaded product images at `/uploads/products/`
  - Backend `ProductService.createProduct()` for user-submitted products
  - Mobile `ProductService.createProduct()` and `uploadProductImage()` with multipart form data
- `image_picker` package for camera/gallery image selection on mobile
- `multer` package for multipart file upload handling on backend
- `createProductSchema` Zod validation for product creation endpoint
- OpenAPI spec updated with new product creation and image upload endpoints

### Changed
- Replaced compile-time `String.fromEnvironment` API URL config with runtime `flutter_dotenv`
  - `ApiConfig.baseUrl` now reads from `mobile/.env` file (`API_BASE_URL`)
  - Default URL set to `http://10.0.2.2:3000` (Android emulator pointing to host machine)
  - Added `mobile/.env.example` with documentation for different environments
- Product widgets (`ProductGridItem`, `ListItemCard`) now use `CachedNetworkImage` instead of `Image.network` for better caching and loading states
- Scanner's product found dialog displays larger (140px) image with rounded corners
- Scanner's manual entry dialog redesigned with image upload area, camera/gallery picker, and remove button

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

[Unreleased]: https://github.com/username/tote-bag/compare/v0.7.1...HEAD
[0.7.1]: https://github.com/username/tote-bag/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/username/tote-bag/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/username/tote-bag/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/username/tote-bag/compare/v0.4.1...v0.5.0
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
