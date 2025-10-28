import { EntitySchema } from '@mikro-orm/core';

/**
 * Share permission levels
 * @enum {string}
 */
export const SharePermission = {
  READ: 'read',
  WRITE: 'write',
  ADMIN: 'admin',
};

/**
 * @typedef {Object} ListShareProperties
 * @property {string} id - UUID primary key
 * @property {string} permission - Permission level (read, write, admin)
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 * @property {boolean} isActive - Whether share is active
 */

/**
 * List Share Entity Schema
 * @type {EntitySchema<ListShareProperties>}
 */
export const ListShareSchema = new EntitySchema({
  name: 'ListShare',
  tableName: 'list_share',
  properties: {
    id: {
      type: 'uuid',
      primary: true,
      onCreate: () => crypto.randomUUID(),
    },
    list: {
      kind: 'm:1',
      entity: 'ShoppingList',
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
