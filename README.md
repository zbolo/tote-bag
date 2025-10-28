# Tote Bag - Grocery Shopping Assistant

A beautiful, modern grocery shopping assistant app with shared lists and barcode scanning capabilities.

## Features

- **Shared Shopping Lists**: Create and manage shopping lists with family and friends
- **Barcode Scanning**: Scan product barcodes to quickly add items using OpenFoodFacts API
- **Real-time Sync**: All changes sync instantly across devices
- **Beautiful UI**: Modern, intuitive interface built with Flutter
- **Multi-platform**: iOS and Android support

## Tech Stack

### Frontend (Mobile)
- **Flutter**: Cross-platform mobile framework
- **Provider/Riverpod**: State management
- **mobile_scanner**: Barcode scanning

### Backend
- **Node.js**: Runtime environment
- **TypeScript**: Type-safe JavaScript
- **Express**: Web framework
- **MikroORM**: TypeScript ORM
- **PostgreSQL**: Database
- **Supertokens**: Authentication system

## Project Structure

```
tote-bag/
├── packages/
│   ├── backend/          # Node.js backend API
│   └── mobile/           # Flutter mobile app
├── docker-compose.yml    # Docker services configuration
└── package.json          # Root package configuration
```

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- Flutter SDK >= 3.0.0
- Docker and Docker Compose
- PostgreSQL (or use Docker)

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
cd packages/mobile
flutter pub get
```

4. Set up environment variables:
```bash
cp packages/backend/.env.example packages/backend/.env
# Edit .env with your configuration
```

5. Start the database:
```bash
npm run docker:up
```

6. Run database migrations:
```bash
npm run backend:migrate
```

### Development

Start the backend:
```bash
npm run backend
```

Run the mobile app:
```bash
npm run mobile:run
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

## API Documentation

API documentation is available at `http://localhost:3000/api/docs` when running the backend in development mode.

## Contributing

1. Create a feature branch
2. Make your changes
3. Write tests
4. Submit a pull request

## License

MIT
