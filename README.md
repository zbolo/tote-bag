# Tote Bag - Grocery Shopping Assistant

A beautiful, modern grocery shopping assistant app with shared lists and barcode scanning capabilities.

## Features

- **Shared Shopping Lists**: Create and manage shopping lists with family and friends
- **Barcode Scanning**: Scan product barcodes to quickly add items using OpenFoodFacts API
- **Real-time Sync**: All changes sync instantly across devices
- **Beautiful UI**: Modern, intuitive interface built with Flutter
- **Multi-platform**: iOS and Android support

## Tech Stack

> All dependencies use the latest stable versions as of January 2025

### Frontend (Mobile)

#### Core Framework

- **Flutter SDK**: 3.24.0+ (stable channel)
- **Dart SDK**: 3.5.0+

#### UI & Design

- **google_fonts**: ^6.2.1 - Beautiful typography with 1000+ Google Fonts
- **flutter_svg**: ^2.0.14 - SVG rendering support
- **cached_network_image**: ^3.4.1 - Optimized image caching
- **shimmer**: ^3.0.0 - Shimmer loading effects
- **cupertino_icons**: ^1.0.8 - iOS-style icons

#### State Management

- **flutter_riverpod**: ^2.6.1 - Modern state management with compile-time safety

#### Networking & API

- **dio**: ^5.7.0 - Powerful HTTP client with interceptors
- **http**: ^1.2.2 - Standard HTTP package

#### Storage

- **shared_preferences**: ^2.3.3 - Key-value storage
- **flutter_secure_storage**: ^9.2.2 - Encrypted secure storage for tokens

#### Features

- **mobile_scanner**: ^5.2.3 - Fast barcode/QR code scanner using platform cameras
- **go_router**: ^14.6.2 - Declarative routing with deep linking
- **intl**: ^0.19.0 - Internationalization and localization
- **uuid**: ^4.5.1 - UUID generation

#### Development Tools

- **flutter_lints**: ^5.0.0 - Official Flutter linting rules
- **mockito**: ^5.4.4 - Mocking framework for testing
- **build_runner**: ^2.4.13 - Code generation

### Backend (Node.js)

#### Runtime & Language

- **Node.js**: 25.x - Latest with modern JavaScript features
- **Plain JavaScript (ES Modules)** - No TypeScript, no build step
- **JSDoc** - Type hints via JSDoc comments for IDE support

#### Web Framework

- **Express**: ^4.21.1 - Fast, unopinionated web framework
- **helmet**: ^8.0.0 - Security middleware with HTTP headers
- **cors**: ^2.8.5 - Cross-Origin Resource Sharing
- **compression**: ^1.7.5 - Response compression middleware
- **express-rate-limit**: ^7.4.1 - Rate limiting middleware

#### Database & ORM

- **MikroORM**: ^6.3.12 (core, postgresql, migrations)
  - EntitySchema-based ORM (no decorators needed)
  - Unit of Work pattern
  - Automatic migrations
  - Entity relationships and cascade operations
- **PostgreSQL**: 16.x (via Docker)

#### Authentication

- **Supertokens**: ^20.1.5 - Modern authentication with session management
  - Email/password authentication
  - Token refresh mechanism
  - Built-in security best practices

#### HTTP Client & Validation

- **axios**: ^1.7.9 - Promise-based HTTP client for OpenFoodFacts API
- **zod**: ^3.23.8 - TypeScript-first schema validation
- **dotenv**: ^16.4.5 - Environment variable management
- **uuid**: ^11.0.3 - UUID v4 generation

#### Testing

- **Jest**: ^29.7.0 - JavaScript testing framework
- **ts-jest**: ^29.2.5 - TypeScript preprocessor for Jest
- **supertest**: ^7.0.0 - HTTP assertion library
- **@types/jest**: ^29.5.14 - TypeScript definitions

#### Development Tools

- **tsx**: ^4.19.2 - TypeScript execution with watch mode
- **ESLint**: ^9.15.0 - Code linting
- **@typescript-eslint**: ^8.17.0 (plugin & parser) - TypeScript ESLint rules
- Various @types packages for TypeScript support

### Infrastructure

#### Database

- **PostgreSQL**: 16-alpine (Docker)
  - Production-ready relational database
  - JSONB support for flexible data
  - Full-text search capabilities

#### Authentication Server

- **Supertokens Core**: 9.0 (PostgreSQL variant)
  - Self-hosted authentication server
  - Session management
  - User management dashboard

To create first dashboard user:

```sh
curl --location --request POST 'http://localhost:3567/recipe/dashboard/user' \
    --header 'rid: dashboard' \
    --header 'api-key: api-key' \
    --header 'Content-Type: application/json' \
    --data-raw '{"email": "test@test.it","password": "Test1234!"}'
```

#### Containerization

- **Docker**: 24.x+
- **Docker Compose**: 2.x+
  - Multi-service orchestration
  - Development environment setup
  - Volume management for data persistence

### External APIs

- **OpenFoodFacts API**: v2
  - Product information database
  - Barcode lookup
  - Nutrition data
  - Free and open-source food database

## Project Structure

```
tote-bag/
├── backend/                        # Node.js Backend API
│   ├── src/
│   │   ├── config/                # Configuration files (database, supertokens)
│   │   ├── entities/              # MikroORM entities (User, ShoppingList, etc.)
│   │   ├── routes/                # Express route handlers
│   │   ├── services/              # Business logic layer
│   │   ├── middleware/            # Express middleware (auth, error handling)
│   │   ├── types/                 # Zod validation schemas
│   │   ├── hooks/                 # Lifecycle hooks (Supertokens)
│   │   ├── tests/                 # Unit and integration tests
│   │   └── index.js               # Application entry point
│   ├── package.json
│   ├── jest.config.js
│   ├── .env                       # Environment variables (not committed)
│   ├── .env.example               # Environment template
│   └── Dockerfile
│
├── mobile/                         # Flutter Mobile App
│   ├── lib/
│   │   ├── config/                # App configuration (theme, routes, API)
│   │   ├── models/                # Data models (ShoppingList, Product, User)
│   │   ├── providers/             # Riverpod state management
│   │   ├── screens/               # UI screens (auth, home, list detail, scanner)
│   │   ├── services/              # API services (HTTP clients)
│   │   ├── widgets/               # Reusable UI components
│   │   └── main.dart              # Application entry point
│   ├── test/                      # Widget and unit tests
│   ├── pubspec.yaml
│   └── analysis_options.yaml
│
├── docker-compose.yml             # Docker services orchestration
├── package.json                   # Root workspace configuration
├── CLAUDE.md                      # Project-specific development guidelines
├── CHANGELOG.md                   # Version history
├── TODO.md                        # Task tracking
└── README.md                      # This file
```

## Architecture & Design Patterns

### Backend Architecture

The backend follows a **layered architecture** with clear separation of concerns:

1. **Routes Layer** (`routes/`)
   - HTTP request handling
   - Request validation using Zod schemas
   - Response formatting

2. **Service Layer** (`services/`)
   - Business logic implementation
   - Database operations via MikroORM
   - External API integration (OpenFoodFacts)

3. **Data Layer** (`entities/`)
   - MikroORM entities with decorators
   - Database schema definitions
   - Relationships and cascading

4. **Middleware Layer** (`middleware/`)
   - Authentication with Supertokens
   - Error handling and logging
   - Request validation

**Key Patterns:**

- **Repository Pattern**: MikroORM EntityManager handles data access
- **Dependency Injection**: Services receive dependencies via constructor
- **Unit of Work**: MikroORM manages transactions automatically
- **DTO Pattern**: Zod schemas validate and transform data

### Frontend Architecture

The Flutter app follows **Clean Architecture** principles with Riverpod:

1. **Presentation Layer** (`screens/` & `widgets/`)
   - UI components and screens
   - User interaction handling
   - State consumption

2. **State Management** (`providers/`)
   - Riverpod providers for state
   - Asynchronous state handling
   - State notifiers for complex logic

3. **Domain Layer** (`models/`)
   - Business entities
   - Data transformation logic
   - Type-safe models

4. **Data Layer** (`services/`)
   - API communication
   - Local storage
   - Data caching

**Key Patterns:**

- **Provider Pattern**: Riverpod for state management
- **Repository Pattern**: Services abstract data sources
- **Observer Pattern**: Reactive state updates
- **Factory Pattern**: Model deserialization from JSON

## Getting Started

### Prerequisites

- **Node.js** >= 25.0.0
- **Flutter SDK** >= 3.24.0
- **Dart SDK** >= 3.5.0
- **Docker** >= 24.0.0
- **Docker Compose** >= 2.0.0
- **Git** for version control
- A code editor (VS Code, Android Studio, or IntelliJ IDEA recommended)

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
cd tote-bag
```

2. Install backend dependencies:

```bash
npm install
```

3. Install Flutter dependencies:

```bash
cd mobile
flutter pub get
cd ..
```

4. Set up environment variables:

```bash
cp backend/.env.example backend/.env
# Edit .env with your configuration
```

5. Start Docker services (PostgreSQL, Supertokens, Backend):

```bash
docker-compose up -d
```

### Development

#### Backend (with Docker)

```bash
docker-compose up
```

#### Mobile App

```bash
cd mobile
flutter run -d chrome  # For web
flutter run            # For connected device
```

### Testing

Run all tests:

```bash
npm test
```

Backend tests:

```bash
npm run backend:test
```

Mobile tests:

```bash
npm run mobile:test
```

## Dependency Version Policy

This project uses the latest stable versions of all dependencies (as of January 2025) to ensure:

- **Security**: Latest security patches and vulnerability fixes
- **Performance**: Optimized code and improved performance
- **Features**: Access to newest features and improvements
- **Compatibility**: Best compatibility with modern development tools
- **Long-term Support**: Using LTS versions where applicable (Node.js 20.x)

### Version Update Strategy

- **Major updates**: Carefully reviewed for breaking changes
- **Minor updates**: Applied when stable and tested
- **Patch updates**: Applied automatically for security fixes
- **Testing**: All updates are tested before deployment

### Key Version Highlights

- **Node.js 24.x**: Latest with ES2024 support and modern JavaScript features
- **Plain JavaScript**: Vanilla JS with JSDoc for type hints - no build step needed
- **Flutter 3.24+**: Stable channel with Material Design 3 support
- **MikroORM 6.3.12**: EntitySchema-based ORM without decorators
- **Supertokens 20.1.5**: Latest authentication with enhanced security
- **Riverpod 2.6.1**: Latest state management with improved DevTools

## API Documentation

### API Endpoints

#### Authentication (`/auth`)

- `POST /auth/signup` - Create new account
- `POST /auth/signin` - Sign in
- `POST /auth/signout` - Sign out
- `POST /auth/session/refresh` - Refresh session token

#### Shopping Lists (`/api/v1/lists`)

- `GET /api/v1/lists` - Get all lists
- `POST /api/v1/lists` - Create new list
- `GET /api/v1/lists/:id` - Get list details
- `PATCH /api/v1/lists/:id` - Update list
- `DELETE /api/v1/lists/:id` - Delete list
- `POST /api/v1/lists/:id/items` - Add item to list
- `PATCH /api/v1/lists/:listId/items/:itemId` - Update item
- `DELETE /api/v1/lists/:listId/items/:itemId` - Delete item
- `POST /api/v1/lists/:id/share` - Share list with user
- `DELETE /api/v1/lists/:listId/share/:userId` - Unshare list

#### Products (`/api/v1/products`)

- `GET /api/v1/products/barcode/:barcode` - Get product by barcode
- `GET /api/v1/products/search?query=...` - Search products

#### Users (`/api/v1/users`)

- `GET /api/v1/users/me` - Get current user profile
- `PATCH /api/v1/users/me` - Update profile
- `GET /api/v1/users/search?query=...` - Search users (for sharing)

## Contributing

1. Create a feature branch
2. Make your changes
3. Write tests
4. Submit a pull request

## License

MIT
