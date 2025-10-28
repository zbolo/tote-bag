import { MikroORM } from '@mikro-orm/core';
import { PostgreSqlDriver } from '@mikro-orm/postgresql';
import { UserSchema } from '../entities/User.js';
import { ShoppingListSchema } from '../entities/ShoppingList.js';
import { ShoppingListItemSchema } from '../entities/ShoppingListItem.js';
import { ListShareSchema } from '../entities/ListShare.js';
import { ProductSchema } from '../entities/Product.js';

/**
 * MikroORM configuration
 * @type {import('@mikro-orm/core').Options}
 */
export const ormConfig = {
  driver: PostgreSqlDriver,
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  dbName: process.env.DB_NAME || 'tote_bag',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  entities: [UserSchema, ShoppingListSchema, ShoppingListItemSchema, ListShareSchema, ProductSchema],
  debug: process.env.NODE_ENV === 'development',
  migrations: {
    path: './src/migrations',
  },
  pool: {
    min: 2,
    max: 10,
  },
};

/**
 * @type {MikroORM|null}
 */
let orm = null;

/**
 * Initialize database connection and run migrations
 * @returns {Promise<MikroORM>}
 */
export async function initializeDatabase() {
  if (!orm) {
    orm = await MikroORM.init(ormConfig);
    const migrator = orm.getMigrator();
    await migrator.up();
  }
  return orm;
}

/**
 * Close database connection
 * @returns {Promise<void>}
 */
export async function closeDatabase() {
  if (orm) {
    await orm.close();
    orm = null;
  }
}

/**
 * Get ORM instance
 * @returns {MikroORM}
 * @throws {Error} If database not initialized
 */
export function getORM() {
  if (!orm) {
    throw new Error('Database not initialized');
  }
  return orm;
}
