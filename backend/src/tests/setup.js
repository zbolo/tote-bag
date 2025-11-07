/**
 * Jest test setup file
 * This file runs before each test suite
 */

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.DB_HOST = 'localhost';
process.env.DB_PORT = '5432';
process.env.DB_NAME = 'tote_bag_test';
process.env.DB_USER = 'postgres';
process.env.DB_PASSWORD = 'postgres';
process.env.SUPERTOKENS_CONNECTION_URI = 'http://localhost:3567';
process.env.API_DOMAIN = 'http://localhost:3000';
process.env.WEBSITE_DOMAIN = 'http://localhost:3000';
