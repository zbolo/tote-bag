# TODO List - Tote Bag Project

This file tracks the remaining tasks to make the project production-ready.

## ✅ Completed

- [x] Fix Jest configuration to work with JavaScript (.js) instead of TypeScript (.ts)
- [x] Create CHANGELOG.md file with semantic versioning
- [x] Create CLAUDE.md with project-specific imperative rules
- [x] Fix docker-compose.yml paths (backend/ instead of packages/backend/)

## 🔴 Critical Priority

### Testing Infrastructure

- [ ] **Fix existing backend test files with TypeScript syntax**
  - `src/tests/services/ShoppingListService.test.js` - has TS syntax errors
  - `src/tests/services/ProductService.test.js` - has TS syntax errors
  - `src/services/__tests__/FavoriteProductService.test.js` - needs proper DB mocking
  - Status: Tests are currently failing due to TypeScript syntax and DB connection issues

- [ ] **Write unit tests for all backend services**
  - ShoppingListService (comprehensive coverage)
  - ProductService (comprehensive coverage)
  - UserService (needs tests)
  - FavoriteProductService (fix existing tests)
  - Target: 70% coverage threshold (branches, functions, lines, statements)

- [ ] **Write unit tests for all Flutter services and models**
  - Current: Only 3 test files for 24 source files
  - Needed:
    - `test/services/shopping_list_service_test.dart`
    - `test/services/product_service_test.dart`
    - `test/services/auth_service_test.dart`
    - `test/services/api_client_test.dart`
    - `test/services/favorite_service_test.dart`
    - `test/models/shopping_list_test.dart`
    - `test/models/shopping_list_item_test.dart`
    - `test/models/product_test.dart`
    - `test/models/user_test.dart`

- [ ] **Write widget tests for all Flutter screens**
  - `test/screens/home/home_screen_test.dart`
  - `test/screens/list/list_detail_screen_test.dart`
  - `test/screens/scanner/barcode_scanner_screen_test.dart`
  - `test/screens/auth/sign_in_screen_test.dart`
  - `test/screens/auth/sign_up_screen_test.dart`

## 🟠 High Priority

### Infrastructure & Logging

- [ ] **Add comprehensive logging infrastructure to backend**
  - Replace all `console.log` with structured logging
  - Use winston or pino for logging
  - Log levels: debug, info, warn, error
  - Log all API requests (method, path, user ID, duration)
  - Log all database operations (entity, operation, duration)
  - Log all external API calls (OpenFoodFacts, duration, status)
  - Add request ID tracking for tracing

- [ ] **Add logging infrastructure to Flutter mobile app**
  - Use logger package or similar
  - Log all API requests/responses (debug mode only)
  - Log all navigation events
  - Log all state changes
  - Log errors with stack traces

### Configuration & Environment

- [ ] **Create .env file from .env.example for backend**
  - Copy `.env.example` to `.env`
  - Configure for local development
  - Document required environment variables
  - Add validation for required env vars at startup

### API Documentation

- [ ] **Create OpenAPI specification with Swagger UI for all API endpoints**
  - Install swagger-jsdoc and swagger-ui-express
  - Document all endpoints in `/api/v1/lists`
  - Document all endpoints in `/api/v1/products`
  - Document all endpoints in `/api/v1/users`
  - Document all endpoints in `/api/v1/favorites`
  - Include request/response examples
  - Serve at `/api-docs` endpoint
  - All descriptions MUST be in English

## 🟡 Medium Priority

### Documentation & Versioning

- [ ] **Update README.md to reflect current project structure**
  - Change all references from `packages/backend/` to `backend/`
  - Change all references from `packages/mobile/` to `mobile/`
  - Update installation instructions
  - Update project structure diagram
  - Verify all paths and commands

- [ ] **Synchronize version numbers across all package.json files**
  - Root `package.json`: currently 1.0.0
  - `backend/package.json`: currently 0.0.1
  - `mobile/pubspec.yaml`: currently 0.0.1+1
  - Decide on unified versioning strategy
  - Update all to match (recommend 0.1.0 for initial release)
  - Update CHANGELOG.md with version bump

### Integration Testing

- [ ] **Add integration tests for critical user flows**
  - User registration and login flow
  - Create shopping list flow
  - Add items to list flow
  - Barcode scanning and product lookup flow
  - Share list with another user flow
  - Mark items as purchased flow
  - Favorite products flow

## 📝 Notes

### Testing Setup Requirements
- Start Docker services: `docker-compose up -d`
- Create test database: `tote_bag_test`
- Ensure PostgreSQL is accessible for tests
- Mock external APIs (OpenFoodFacts) in tests

### Version Strategy
Current versions are inconsistent:
- Root package.json: 1.0.0
- Backend: 0.0.1
- Mobile: 0.0.1+1

Recommendation: Align all to 0.1.0 (initial development release)

### Coverage Goals
- Backend: 70% minimum (configured in jest.config.js)
- Mobile: 70% target (not enforced yet)
- Focus on critical paths first (auth, lists, items, products)

### Dependencies Status
- Flutter: 22 packages have newer versions (check with `flutter pub outdated`)
- Consider updating after stabilizing tests

---

**Last Updated**: 2025-01-07
**Project Status**: Development (not production-ready)
**Blockers**: Testing infrastructure needs to be completed before production deployment
