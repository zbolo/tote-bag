import { EntitySchema } from '@mikro-orm/core';
import { SharePermission } from './ListShare.js';

/**
 * @typedef {Object} PantryShareProperties
 * @property {string} id - UUID primary key
 * @property {string} permission - Permission level (read, write, admin)
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 * @property {boolean} isActive - Whether share is active
 */

/**
 * Pantry Share Entity Schema
 * @type {EntitySchema<PantryShareProperties>}
 */
export const PantryShareSchema = new EntitySchema({
  name: 'PantryShare',
  tableName: 'pantry_share',
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
    user: {
      kind: 'm:1',
      entity: 'User',
    },
    permission: {
      type: 'string',
      enum: true,
      items: Object.values(SharePermission),
      default: SharePermission.READ,
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
    isActive: {
      type: 'boolean',
      default: true,
    },
  },
});
