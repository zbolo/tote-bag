# Tote Bag - Technology Stack & Versions

**Last Updated:** January 2025
**Status:** All dependencies at latest stable versions

## Quick Reference

### Backend Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Node.js** | 20.x LTS | JavaScript runtime environment |
| **TypeScript** | ^5.7.2 | Type-safe JavaScript superset |
| **Express** | ^4.21.1 | Web application framework |
| **MikroORM** | ^6.3.12 | TypeScript ORM for PostgreSQL |
| **PostgreSQL** | 16-alpine | Relational database |
| **Supertokens** | ^20.1.5 | Authentication framework |
| **Zod** | ^3.23.8 | Schema validation |
| **Axios** | ^1.7.9 | HTTP client |
| **Jest** | ^29.7.0 | Testing framework |
| **ESLint** | ^9.15.0 | Code linting |
| **Helmet** | ^8.0.0 | Security middleware |
| **CORS** | ^2.8.5 | Cross-origin resource sharing |
| **Compression** | ^1.7.5 | Response compression |
| **express-rate-limit** | ^7.4.1 | Rate limiting |
| **uuid** | ^11.0.3 | UUID generation |
| **dotenv** | ^16.4.5 | Environment variables |
| **tsx** | ^4.19.2 | TypeScript execution |
| **ts-jest** | ^29.2.5 | Jest TypeScript preprocessor |

### Frontend Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.24.0+ | Cross-platform mobile framework |
| **Dart** | 3.5.0+ | Programming language |
| **Riverpod** | ^2.6.1 | State management |
| **Dio** | ^5.7.0 | HTTP client with interceptors |
| **Go Router** | ^14.6.2 | Declarative routing |
| **mobile_scanner** | ^5.2.3 | Barcode/QR code scanner |
| **Google Fonts** | ^6.2.1 | Beautiful typography |
| **flutter_secure_storage** | ^9.2.2 | Encrypted storage |
| **shared_preferences** | ^2.3.3 | Key-value storage |
| **cached_network_image** | ^3.4.1 | Image caching |
| **flutter_svg** | ^2.0.14 | SVG rendering |
| **shimmer** | ^3.0.0 | Loading effects |
| **intl** | ^0.19.0 | Internationalization |
| **uuid** | ^4.5.1 | UUID generation |
| **flutter_lints** | ^5.0.0 | Linting rules |
| **mockito** | ^5.4.4 | Testing mocks |
| **build_runner** | ^2.4.13 | Code generation |

### Infrastructure

| Service | Version | Purpose |
|---------|---------|---------|
| **PostgreSQL** | 16-alpine | Production database |
| **Supertokens Core** | 9.0 | Auth server (PostgreSQL) |
| **Docker** | 24.x+ | Containerization |
| **Docker Compose** | 2.x+ | Multi-container orchestration |

### External APIs

| API | Version | Purpose |
|-----|---------|---------|
| **OpenFoodFacts** | v2 | Product information database |

## Version Strategy

### Why Latest Versions?

1. **Security**: Latest patches and vulnerability fixes
2. **Performance**: Optimized code and improved performance
3. **Features**: Access to newest capabilities
4. **Support**: Better community and commercial support
5. **Compatibility**: Works with modern development tools

### Update Policy

- **Major versions**: Reviewed for breaking changes before updating
- **Minor versions**: Applied when stable and tested
- **Patch versions**: Applied promptly for security fixes
- **LTS versions**: Preferred for runtimes (Node.js 20.x)

## Key Highlights

### Backend Highlights

- **TypeScript 5.7.2**: Improved type inference, better error messages
- **MikroORM 6.3.12**: Enhanced type safety, better performance
- **Supertokens 20.1.5**: Improved security, better session management
- **Express 4.21.1**: Security updates, stability improvements
- **ESLint 9.15.0**: New flat config system

### Frontend Highlights

- **Flutter 3.24+**: Material Design 3, improved performance
- **Riverpod 2.6.1**: Better DevTools integration, improved API
- **Dio 5.7.0**: Better error handling, improved interceptors
- **mobile_scanner 5.2.3**: Performance improvements, better camera handling
- **Go Router 14.6.2**: Enhanced navigation, better deep linking

## Compatibility Matrix

| Component | Minimum Version | Recommended |
|-----------|----------------|-------------|
| Node.js | 20.0.0 | 20.x LTS |
| Flutter SDK | 3.24.0 | Latest stable |
| Dart SDK | 3.5.0 | 3.5.x |
| Docker | 24.0.0 | Latest stable |
| PostgreSQL | 14.x | 16.x |

## Development Environment

### Recommended IDE Setup

**For Backend:**
- VS Code with extensions:
  - TypeScript
  - ESLint
  - Prettier
  - REST Client

**For Frontend:**
- VS Code or Android Studio with:
  - Flutter extension
  - Dart extension
  - Flutter Riverpod Snippets
  - Error Lens

## Testing Coverage

| Package | Test Framework | Coverage Target |
|---------|---------------|-----------------|
| Backend | Jest + Supertest | 70%+ |
| Frontend | flutter_test + mockito | 70%+ |

## Build Configuration

### Backend Build
- Target: ES2022
- Module: CommonJS
- Strict mode enabled
- Source maps included

### Frontend Build
- Target: Android 6.0+ (API 23)
- Target: iOS 12.0+
- Material Design 3 enabled
- Null safety enforced

## License Compatibility

All dependencies use permissive licenses compatible with MIT:
- MIT License: Most packages
- BSD License: Flutter, Dart
- Apache 2.0: Some Google packages

---

**Note:** This document is automatically updated when dependencies are upgraded. Always refer to `package.json` and `pubspec.yaml` for the definitive version information.
