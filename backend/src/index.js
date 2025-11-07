import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import rateLimit from 'express-rate-limit';
import supertokens from 'supertokens-node';
import { middleware as supertokensMiddleware } from 'supertokens-node/framework/express/index.js';
import { errorHandler as supertokensErrorHandler } from 'supertokens-node/framework/express/index.js';
import { initSupertokens } from './config/supertokens.js';
import { initializeDatabase } from './config/database.js';
import { errorHandler } from './middleware/errorHandler.js';
import listsRouter from './routes/lists.js';
import productsRouter from './routes/products.js';
import usersRouter from './routes/users.js';
import favoritesRouter from './routes/favoriteProducts.js';
import adminRouter from './routes/admin.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Supertokens
initSupertokens();

// Middleware
// Use helmet for security headers but disable CSP to allow SuperTokens dashboard resources
app.use(helmet({ contentSecurityPolicy: false }));
app.use(compression());

// CORS configuration - must be before other middleware
// Using SuperTokens recommended CORS configuration
console.log('[CORS] Allowing all origins with SuperTokens headers');

app.use(
  cors({
    origin: true, // Allow all origins
    allowedHeaders: ['content-type', ...supertokens.getAllCORSHeaders()],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    credentials: true,
  })
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api', limiter);

// Supertokens middleware
app.use(supertokensMiddleware());

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API Routes
const apiVersion = process.env.API_VERSION || 'v1';
app.use(`/api/${apiVersion}/lists`, listsRouter);
app.use(`/api/${apiVersion}/products`, productsRouter);
app.use(`/api/${apiVersion}/users`, usersRouter);
app.use(`/api/${apiVersion}/favorites`, favoritesRouter);
app.use(`/api/${apiVersion}/admin`, adminRouter);

// Error handlers
app.use(supertokensErrorHandler());
app.use(errorHandler);

// 404 handler
app.use((_req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found',
  });
});

/**
 * Start the server
 */
async function start() {
  try {
    // Initialize database
    await initializeDatabase();
    console.log('Database connected successfully');

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV}`);
      console.log(`API Version: ${apiVersion}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Handle shutdown gracefully
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  process.exit(0);
});

start();

export default app;
