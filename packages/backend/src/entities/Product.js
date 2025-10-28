import { EntitySchema } from '@mikro-orm/core';

/**
 * @typedef {Object} ProductProperties
 * @property {string} id - UUID primary key
 * @property {string} barcode - Unique barcode
 * @property {string} name - Product name
 * @property {string|null} brand - Brand name
 * @property {string|null} description - Product description
 * @property {string|null} imageUrl - Product image URL
 * @property {string|null} category - Product category
 * @property {string|null} quantity - Product quantity/size
 * @property {Object|null} nutritionData - Nutrition information
 * @property {string} source - Data source (openfoodfacts)
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 * @property {Date|null} lastFetchedAt - Last API fetch timestamp
 */

/**
 * Product Entity Schema
 * @type {EntitySchema<ProductProperties>}
 */
export const ProductSchema = new EntitySchema({
  name: 'Product',
  tableName: 'product',
  properties: {
    id: {
      type: 'uuid',
      primary: true,
      onCreate: () => crypto.randomUUID(),
    },
    barcode: {
      type: 'string',
      unique: true,
    },
    name: {
      type: 'string',
    },
    brand: {
      type: 'string',
      nullable: true,
    },
    description: {
      type: 'text',
      nullable: true,
    },
    imageUrl: {
      type: 'string',
      nullable: true,
    },
    category: {
      type: 'string',
      nullable: true,
    },
    quantity: {
      type: 'string',
      nullable: true,
    },
    nutritionData: {
      type: 'jsonb',
      nullable: true,
    },
    source: {
      type: 'string',
      default: 'openfoodfacts',
    },
    createdAt: {
      type: 'Date',
      onCreate: () => new Date(),
    },
    updatedAt: {
      type: 'Date',
      onCreate: () => new Date(),
      onUpdate: () => new Date(),
    },
    lastFetchedAt: {
      type: 'Date',
      nullable: true,
    },
  },
});
