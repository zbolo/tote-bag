import { MikroORM, Options } from '@mikro-orm/core';
import { PostgreSqlDriver } from '@mikro-orm/postgresql';
import { User } from '../entities/User';
import { ShoppingList } from '../entities/ShoppingList';
import { ShoppingListItem } from '../entities/ShoppingListItem';
import { ListShare } from '../entities/ListShare';
import { Product } from '../entities/Product';

export const ormConfig: Options = {
  driver: PostgreSqlDriver,
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  dbName: process.env.DB_NAME || 'tote_bag',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
  entities: [User, ShoppingList, ShoppingListItem, ListShare, Product],
  debug: process.env.NODE_ENV === 'development',
  migrations: {
    path: './dist/migrations',
    pathTs: './src/migrations',
  },
  pool: {
    min: 2,
    max: 10,
  },
};

let orm: MikroORM | undefined;

export async function initializeDatabase(): Promise<MikroORM> {
  if (!orm) {
    orm = await MikroORM.init(ormConfig);
    const migrator = orm.getMigrator();
    await migrator.up();
  }
  return orm;
}

export async function closeDatabase(): Promise<void> {
  if (orm) {
    await orm.close();
    orm = undefined;
  }
}

export function getORM(): MikroORM {
  if (!orm) {
    throw new Error('Database not initialized');
  }
  return orm;
}
