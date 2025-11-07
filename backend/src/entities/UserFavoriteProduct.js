import { EntitySchema } from '@mikro-orm/core';

/**
 * @typedef {Object} UserFavoriteProductProperties
 * @property {string} id - UUID primary key
 * @property {import('./User.js').User} user - User who favorited the product
 * @property {import('./Product.js').Product} product - Favorited product
 * @property {Date} createdAt - When the product was favorited
 */

/**
 * UserFavoriteProduct Entity Schema
 * Represents the many-to-many relationship between users and their favorite products
 * @type {EntitySchema<UserFavoriteProductProperties>}
 */
export const UserFavoriteProductSchema = new EntitySchema({
  name: 'UserFavoriteProduct',
  tableName: 'user_favorite_product',
  properties: {
    id: {
      type: 'uuid',
      primary: true,
      onCreate: () => crypto.randomUUID(),
    },
    user: {
      kind: 'm:1',
      entity: 'User',
      eager: false,
    },
    product: {
      kind: 'm:1',
      entity: 'Product',
      eager: true,
    },
    createdAt: {
      type: 'Date',
      onCreate: () => new Date(),
    },
  },
  indexes: [
    {
      properties: ['user', 'product'],
      options: { unique: true },
    },
  ],
});
