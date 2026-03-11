import { EntitySchema } from '@mikro-orm/core';

/**
 * @typedef {Object} PantryItemProperties
 * @property {string} id - UUID primary key
 * @property {string} name - Item name
 * @property {number} quantity - Current remaining quantity
 * @property {number} maxQuantity - Original purchased quantity
 * @property {string|null} unit - Optional unit (kg, liters, pcs, etc.)
 * @property {string|null} category - Optional category
 * @property {string|null} notes - Optional notes
 * @property {Date|null} expirationDate - Optional expiration date
 * @property {Date|null} purchaseDate - Optional purchase date
 * @property {number|null} price - Latest purchase price
 * @property {string|null} barcode - Optional barcode
 * @property {number} lowStockThreshold - Fraction (0-1) of maxQuantity for low stock warning
 * @property {number} order - Display order
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 */

/**
 * Pantry Item Entity Schema
 * @type {EntitySchema<PantryItemProperties>}
 */
export const PantryItemSchema = new EntitySchema({
  name: 'PantryItem',
  tableName: 'pantry_item',
  properties: {
    id: {
      type: 'uuid',
      primary: true,
      onCreate: () => crypto.randomUUID(),
    },
    pantry: {
      kind: 'm:1',
      entity: 'Pantry',
    },
    name: {
      type: 'string',
    },
    quantity: {
      type: 'double',
      default: 1,
    },
    maxQuantity: {
      type: 'double',
      default: 1,
    },
    unit: {
      type: 'string',
      nullable: true,
    },
    category: {
      type: 'string',
      nullable: true,
    },
    storageLocation: {
      kind: 'm:1',
      entity: 'StorageLocation',
      nullable: true,
    },
    product: {
      kind: 'm:1',
      entity: 'Product',
      nullable: true,
    },
    barcode: {
      type: 'string',
      nullable: true,
    },
    notes: {
      type: 'string',
      nullable: true,
    },
    expirationDate: {
      type: 'Date',
      nullable: true,
    },
    purchaseDate: {
      type: 'Date',
      nullable: true,
    },
    price: {
      type: 'double',
      nullable: true,
    },
    contentQuantity: {
      type: 'double',
      nullable: true,
    },
    contentMaxQuantity: {
      type: 'double',
      nullable: true,
    },
    contentUnit: {
      type: 'string',
      nullable: true,
    },
    lowStockThreshold: {
      type: 'double',
      default: 0.25,
    },
    order: {
      type: 'number',
      default: 0,
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
  },
});
