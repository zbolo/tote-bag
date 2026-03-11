import { EntitySchema } from '@mikro-orm/core';

/**
 * Default storage locations created for every new pantry
 * @type {Array<{name: string, icon: string, order: number}>}
 */
export const DEFAULT_STORAGE_LOCATIONS = [
  { name: 'Fridge', icon: 'kitchen', order: 0 },
  { name: 'Freezer', icon: 'ac_unit', order: 1 },
  { name: 'Cupboard', icon: 'shelves', order: 2 },
  { name: 'Cellar', icon: 'warehouse', order: 3 },
  { name: 'Other', icon: 'inventory_2', order: 4 },
];

/**
 * @typedef {Object} StorageLocationProperties
 * @property {string} id - UUID primary key
 * @property {string} name - Location name (e.g. Fridge, Freezer)
 * @property {string} icon - Material icon name
 * @property {number} order - Display order
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 */

/**
 * Storage Location Entity Schema
 * @type {EntitySchema<StorageLocationProperties>}
 */
export const StorageLocationSchema = new EntitySchema({
  name: 'StorageLocation',
  tableName: 'storage_location',
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
    icon: {
      type: 'string',
      default: 'inventory_2',
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
