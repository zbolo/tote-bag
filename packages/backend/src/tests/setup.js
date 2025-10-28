import { MikroORM } from '@mikro-orm/core';
import { ormConfig } from '../config/database.js';

let orm: MikroORM;

beforeAll(async () => {
  // Use test database
  const testConfig = {
    ...ormConfig,
    dbName: process.env.DB_NAME_TEST || 'tote_bag_test',
    allowGlobalContext: true,
  };

  orm = await MikroORM.init(testConfig);

  // Run migrations
  const migrator = orm.getMigrator();
  await migrator.up();
});

afterAll(async () => {
  if (orm) {
    await orm.close(true);
  }
});

beforeEach(async () => {
  // Clear all tables before each test
  const connection = orm.em.getConnection();
  await connection.execute('TRUNCATE TABLE "user", "shopping_list", "shopping_list_item", "list_share", "product" CASCADE');
});

export { orm };
