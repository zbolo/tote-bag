import { MikroORM } from '@mikro-orm/core';
import { FavoriteProductService } from '../FavoriteProductService.js';
import { ormConfig } from '../../config/database.js';

describe('FavoriteProductService', () => {
  let orm;
  let em;
  let service;
  let testUser;
  let testProduct;

  beforeAll(async () => {
    orm = await MikroORM.init(ormConfig);
    const migrator = orm.getMigrator();
    await migrator.up();
  });

  afterAll(async () => {
    await orm.close();
  });

  beforeEach(async () => {
    em = orm.em.fork();
    service = new FavoriteProductService(em);

    // Create test user
    testUser = em.create('User', {
      email: `test${Date.now()}@example.com`,
      displayName: 'Test User',
      supertokensUserId: `test-${Date.now()}`,
    });

    // Create test product
    testProduct = em.create('Product', {
      barcode: `TEST${Date.now()}`,
      name: 'Test Product',
      brand: 'Test Brand',
      source: 'openfoodfacts',
    });

    await em.persistAndFlush([testUser, testProduct]);
  });

  afterEach(async () => {
    // Clean up test data
    await em.nativeDelete('UserFavoriteProduct', {});
    await em.nativeDelete('Product', {});
    await em.nativeDelete('User', {});
  });

  describe('addFavorite', () => {
    it('should add a product to favorites', async () => {
      const favorite = await service.addFavorite(testUser.id, testProduct.id);

      expect(favorite).toBeDefined();
      expect(favorite.user).toBe(testUser.id);
      expect(favorite.product).toBe(testProduct.id);

      const count = await em.count('UserFavoriteProduct', {
        user: testUser.id,
        product: testProduct.id,
      });
      expect(count).toBe(1);
    });

    it('should not create duplicate favorites', async () => {
      await service.addFavorite(testUser.id, testProduct.id);
      const favorite2 = await service.addFavorite(testUser.id, testProduct.id);

      expect(favorite2).toBeDefined();

      const count = await em.count('UserFavoriteProduct', {
        user: testUser.id,
        product: testProduct.id,
      });
      expect(count).toBe(1);
    });
  });

  describe('removeFavorite', () => {
    it('should remove a product from favorites', async () => {
      await service.addFavorite(testUser.id, testProduct.id);

      const removed = await service.removeFavorite(testUser.id, testProduct.id);

      expect(removed).toBe(true);

      const count = await em.count('UserFavoriteProduct', {
        user: testUser.id,
        product: testProduct.id,
      });
      expect(count).toBe(0);
    });

    it('should return false when favorite does not exist', async () => {
      const removed = await service.removeFavorite(testUser.id, testProduct.id);

      expect(removed).toBe(false);
    });
  });

  describe('toggleFavorite', () => {
    it('should add favorite when not favorited', async () => {
      const result = await service.toggleFavorite(testUser.id, testProduct.id);

      expect(result.isFavorite).toBe(true);

      const count = await em.count('UserFavoriteProduct', {
        user: testUser.id,
        product: testProduct.id,
      });
      expect(count).toBe(1);
    });

    it('should remove favorite when already favorited', async () => {
      await service.addFavorite(testUser.id, testProduct.id);

      const result = await service.toggleFavorite(testUser.id, testProduct.id);

      expect(result.isFavorite).toBe(false);

      const count = await em.count('UserFavoriteProduct', {
        user: testUser.id,
        product: testProduct.id,
      });
      expect(count).toBe(0);
    });
  });

  describe('getFavorites', () => {
    it('should return empty array when no favorites', async () => {
      const favorites = await service.getFavorites(testUser.id);

      expect(favorites).toEqual([]);
    });

    it('should return all favorite products', async () => {
      const product2 = em.create('Product', {
        barcode: `TEST2${Date.now()}`,
        name: 'Test Product 2',
        source: 'openfoodfacts',
      });
      await em.persistAndFlush(product2);

      await service.addFavorite(testUser.id, testProduct.id);
      await service.addFavorite(testUser.id, product2.id);

      const favorites = await service.getFavorites(testUser.id);

      expect(favorites).toHaveLength(2);
      expect(favorites.map(p => p.id)).toContain(testProduct.id);
      expect(favorites.map(p => p.id)).toContain(product2.id);
    });

    it('should return favorites ordered by creation date DESC', async () => {
      const product2 = em.create('Product', {
        barcode: `TEST2${Date.now()}`,
        name: 'Test Product 2',
        source: 'openfoodfacts',
      });
      await em.persistAndFlush(product2);

      await service.addFavorite(testUser.id, testProduct.id);
      await new Promise(resolve => setTimeout(resolve, 10));
      await service.addFavorite(testUser.id, product2.id);

      const favorites = await service.getFavorites(testUser.id);

      expect(favorites[0].id).toBe(product2.id);
      expect(favorites[1].id).toBe(testProduct.id);
    });
  });

  describe('isFavorite', () => {
    it('should return false when not favorited', async () => {
      const result = await service.isFavorite(testUser.id, testProduct.id);

      expect(result).toBe(false);
    });

    it('should return true when favorited', async () => {
      await service.addFavorite(testUser.id, testProduct.id);

      const result = await service.isFavorite(testUser.id, testProduct.id);

      expect(result).toBe(true);
    });
  });

  describe('getFavoriteStatuses', () => {
    it('should return status map for multiple products', async () => {
      const product2 = em.create('Product', {
        barcode: `TEST2${Date.now()}`,
        name: 'Test Product 2',
        source: 'openfoodfacts',
      });
      const product3 = em.create('Product', {
        barcode: `TEST3${Date.now()}`,
        name: 'Test Product 3',
        source: 'openfoodfacts',
      });
      await em.persistAndFlush([product2, product3]);

      await service.addFavorite(testUser.id, testProduct.id);
      await service.addFavorite(testUser.id, product3.id);

      const statuses = await service.getFavoriteStatuses(testUser.id, [
        testProduct.id,
        product2.id,
        product3.id,
      ]);

      expect(statuses.get(testProduct.id)).toBe(true);
      expect(statuses.get(product2.id)).toBe(false);
      expect(statuses.get(product3.id)).toBe(true);
    });
  });
});
