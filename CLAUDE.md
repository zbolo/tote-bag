# Tote Bag - Project-Specific Claude Instructions

## Critical Rules (MUST FOLLOW)

### Code Quality & Testing
- **ALWAYS** run `flutter analyze` after making changes to Flutter code. There MUST be 0 issues.
- **NEVER** commit code without passing tests. All tests must pass before committing.
- **ALWAYS** write unit tests for every new service, model, or business logic function.
- **ALWAYS** write widget tests for new Flutter screens and widgets.
- Test coverage threshold: minimum 70% for backend (branches, functions, lines, statements).
- Flutter test coverage should be comprehensive for critical user flows.

### Logging Requirements
- **ALWAYS** add debug logs for all business logic flows to enable immediate debugging.
- Backend: Use structured logging (NOT console.log) with log levels (debug, info, warn, error).
- Backend: Log all API requests (method, path, user ID, duration).
- Backend: Log all database operations (entity, operation, duration).
- Backend: Log all external API calls (service, endpoint, status, duration).
- Mobile: Use proper logging with log levels for debugging.
- Mobile: Log all API requests and responses (in debug mode only).
- Mobile: Log all navigation events and state changes.

### API Documentation
- **ALWAYS** maintain OpenAPI specification for all API endpoints.
- API descriptions MUST be in English.
- OpenAPI spec MUST be served with Swagger UI at `/api-docs`.
- Update OpenAPI spec whenever adding or modifying endpoints.
- Include request/response examples in OpenAPI spec.

### Version Control & Git
- **ALWAYS** check `git diff` before making changes to understand current state.
- **ALWAYS** work on feature branches (feature/*, bugfix/*, etc.).
- **NEVER** commit directly to main/master without review.
- **NEVER** include Anthropic or Claude signatures in commit messages (no "Generated with Claude Code" or "Co-Authored-By: Claude" footers).
- Commit messages must follow conventional commits format:
  - feat: new feature
  - fix: bug fix
  - refactor: code refactoring
  - test: adding tests
  - docs: documentation changes
  - chore: maintenance tasks

### Semantic Versioning & Changelog
- **ALWAYS** update version numbers following semantic versioning (MAJOR.MINOR.PATCH).
  - MAJOR: Breaking changes
  - MINOR: New features (backward compatible)
  - PATCH: Bug fixes (backward compatible)
- **ALWAYS** update CHANGELOG.md when changing features.
- CHANGELOG.md MUST follow Keep a Changelog format.
- Version numbers MUST be synchronized across:
  - Root package.json
  - backend/package.json
  - mobile/pubspec.yaml

### Code Standards

#### Backend (Node.js)
- Use **Plain JavaScript (ES Modules)** - NO TypeScript transpilation.
- Use **JSDoc comments** for type hints.
- Use **async/await** for asynchronous operations.
- Always use **try/catch** blocks with proper error handling.
- Use **AppError** class for application errors.
- Use **Zod schemas** for validation.
- Database operations MUST use **MikroORM EntityManager**.
- NEVER use raw SQL queries without proper escaping.

#### Frontend (Flutter/Dart)
- Follow **Clean Architecture** principles.
- Use **Riverpod** for state management.
- Use **go_router** for navigation.
- Widgets MUST be properly typed (no dynamic types).
- Use **const constructors** wherever possible for performance.
- Follow **flutter_lints** rules strictly.
- API calls MUST have proper error handling with user-friendly messages.

### Security
- **NEVER** commit secrets, API keys, or credentials.
- **NEVER** log sensitive data (passwords, tokens, PII).
- **ALWAYS** validate user input with Zod schemas (backend).
- **ALWAYS** sanitize data before database operations.
- Use **Supertokens** for authentication (already configured).
- API endpoints MUST check authentication and authorization.
- Rate limiting is configured - respect the limits.

### Environment & Configuration
- Backend requires `.env` file (copy from `.env.example`).
- **NEVER** commit `.env` files.
- Environment variables MUST be validated at startup.
- Use sensible defaults for non-critical configuration.

### Testing Strategy

#### Backend Testing
- Unit tests for all services using Jest.
- Mock external dependencies (database, external APIs).
- Test error cases and edge cases.
- Integration tests for API endpoints using supertest.
- Test files: `*.test.js` or `*.spec.js`.

#### Mobile Testing
- Unit tests for models and services.
- Widget tests for all screens and reusable widgets.
- Mock API responses for widget tests.
- Integration tests for critical user flows.
- Test files: `*_test.dart`.

### Development Workflow
1. Check `git diff` to see current changes.
2. Create/switch to feature branch if not already on one.
3. Make changes with proper logging.
4. Write/update tests.
5. Run tests: `npm test` (backend) or `flutter test` (mobile).
6. Run `flutter analyze` for Flutter changes (MUST show 0 issues).
7. Update CHANGELOG.md and version if needed.
8. Commit with conventional commit message.
9. Push changes.

### Project Structure
```
tote-bag/
├── backend/              # Node.js backend (NOT packages/backend/)
│   ├── src/
│   │   ├── config/      # Configuration
│   │   ├── entities/    # MikroORM entities
│   │   ├── routes/      # Express routes
│   │   ├── services/    # Business logic (MUST have tests)
│   │   ├── middleware/  # Express middleware
│   │   ├── types/       # Validation schemas
│   │   └── tests/       # Test files
│   └── package.json
├── mobile/               # Flutter mobile app (NOT packages/mobile/)
│   ├── lib/
│   │   ├── config/      # App configuration
│   │   ├── models/      # Data models (MUST have tests)
│   │   ├── providers/   # Riverpod providers
│   │   ├── screens/     # UI screens (MUST have widget tests)
│   │   ├── services/    # API services (MUST have tests)
│   │   └── widgets/     # Reusable widgets (MUST have tests)
│   └── test/            # Test files
├── docker-compose.yml   # Docker configuration
├── CHANGELOG.md         # Version history (MUST maintain)
└── README.md           # Documentation
```

### External APIs
- **OpenFoodFacts API**: For product information lookup.
  - Base URL: https://world.openfoodfacts.org/api/v2
  - ALWAYS handle API failures gracefully.
  - ALWAYS cache product data locally.

### Database
- PostgreSQL 16 via Docker.
- Use MikroORM for all database operations.
- Run migrations: `npm run migrate:create` (backend).
- NEVER modify database schema manually.

### Performance
- Use **pagination** for all list endpoints.
- Use **caching** for frequently accessed data.
- Optimize images with **cached_network_image** (Flutter).
- Use **const constructors** in Flutter for better performance.
- Backend: Use **compression** middleware (already configured).

### Error Handling
- Backend: Use AppError class with proper status codes.
- Mobile: Show user-friendly error messages.
- Log all errors with stack traces (in non-production).
- Never expose internal errors to users.

## Common Commands

### Backend
```bash
npm run dev          # Start development server
npm test            # Run tests
npm run lint        # Run ESLint
npm run migrate:create  # Create new migration
```

### Mobile
```bash
flutter run         # Run app
flutter test        # Run tests
flutter analyze     # Analyze code (MUST be 0 issues)
flutter pub get     # Get dependencies
```

### Docker
```bash
npm run docker:up   # Start all services
npm run docker:down # Stop all services
```

## Dependencies

### Backend
- Express 4.21.1 - Web framework
- MikroORM 6.3.12 - ORM (EntitySchema-based, no decorators)
- Supertokens 20.1.5 - Authentication
- Zod 3.23.8 - Validation
- Axios 1.7.9 - HTTP client
- Jest 29.7.0 - Testing framework

### Mobile
- Flutter 3.24.0+ - Framework
- Riverpod 2.6.1 - State management
- Dio 5.7.0 - HTTP client
- go_router 14.6.2 - Navigation
- mobile_scanner 5.2.3 - Barcode scanning

## Important Notes
- Node.js version: **24.x** (latest with ES2024 support).
- The project was recently refactored from TypeScript to **Plain JavaScript**.
- Jest configuration MUST match JavaScript files (.js not .ts).
- Project structure was moved from `packages/` to root-level `backend/` and `mobile/`.
