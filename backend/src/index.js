import 'dotenv/config';
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';
import path from 'path';
import { fileURLToPath } from 'url';
import { initSupertokens } from './config/supertokens.js';
import { middleware as supertokensMiddleware, errorHandler as supertokensErrorHandler } from 'supertokens-node/framework/express/index.js';
import supertokens from 'supertokens-node';
import { initializeDatabase, closeDatabase } from './config/database.js';
import { errorHandler } from './middleware/errorHandler.js';
import authRouter from './routes/auth.js';
import listsRouter from './routes/lists.js';
import productsRouter from './routes/products.js';
import usersRouter from './routes/users.js';
import favoritesRouter from './routes/favoriteProducts.js';
import adminRouter from './routes/admin.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Validate required environment variables in production
 * Fail fast if critical security-related env vars are missing
 */
function validateEnvironment() {
  const isProduction = process.env.NODE_ENV === 'production';

  if (isProduction) {
    const requiredVars = [];

    if (!process.env.DB_PASSWORD) {
      requiredVars.push('DB_PASSWORD');
    }

    if (!process.env.SUPERTOKENS_API_KEY) {
      requiredVars.push('SUPERTOKENS_API_KEY');
    }

    if (requiredVars.length > 0) {
      console.error('[Security] Missing required environment variables in production:');
      requiredVars.forEach(v => console.error(`  - ${v}`));
      console.error('Application cannot start with default credentials in production.');
      process.exit(1);
    }

    console.log('[Security] Required environment variables validated');
  } else {
    console.log('[Security] Running in development mode with fallback credentials');
  }
}

// Validate environment on startup
validateEnvironment();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Supertokens
initSupertokens();

// Middleware chain (same order as webdeploy/ms)
app.use(helmet({ contentSecurityPolicy: false }));

app.use(cors({
  origin: true,
  allowedHeaders: ['content-type', ...supertokens.getAllCORSHeaders()],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  credentials: true,
}));

app.use(compression());

const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api', limiter);

app.use(supertokensMiddleware());

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve uploaded files statically
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Swagger UI setup
try {
  const swaggerDocument = YAML.load(path.join(__dirname, '../docs/openapi.yaml'));

  const customCss = `
    .swagger-ui .topbar { background: linear-gradient(to right, #4CAF50, #8BC34A); }
    .swagger-ui .info .title { color: #333; }
  `;

  const options = {
    customCss,
    customSiteTitle: 'Tote Bag API Documentation',
  };

  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument, options));
  console.log('[Swagger] API documentation available at /api-docs');
} catch (error) {
  console.warn('[Swagger] Could not load OpenAPI specification:', error.message);
}

// Auth Routes (custom auth endpoints, SuperTokens handles /api/auth/* automatically)
app.use('/api/auth', authRouter);

// API Routes
const apiVersion = process.env.API_VERSION || 'v1';
app.use(`/api/${apiVersion}/lists`, listsRouter);
app.use(`/api/${apiVersion}/products`, productsRouter);
app.use(`/api/${apiVersion}/users`, usersRouter);
app.use(`/api/${apiVersion}/favorites`, favoritesRouter);
app.use(`/api/${apiVersion}/admin`, adminRouter);

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handlers
app.use(supertokensErrorHandler());

// 404 handler
app.use((_req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found',
  });
});

app.use(errorHandler);

/**
 * Start the server
 */
async function start() {
  try {
    await initializeDatabase();
    console.log('[Database] Connected successfully');

    app.listen(PORT, () => {
      console.log(`[Server] Running on port ${PORT}`);
      console.log(`[Server] Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`[Server] API Version: ${apiVersion}`);
    });
  } catch (error) {
    console.error('[Server] Failed to start:', error);
    process.exit(1);
  }
}

// Handle shutdown gracefully
process.on('SIGTERM', async () => {
  console.log('[Server] SIGTERM received, shutting down gracefully');
  await closeDatabase();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('[Server] SIGINT received, shutting down gracefully');
  await closeDatabase();
  process.exit(0);
});

start();

export default app;
