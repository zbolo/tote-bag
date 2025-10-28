import { EntitySchema } from '@mikro-orm/core';

/**
 * @typedef {Object} ShoppingListProperties
 * @property {string} id - UUID primary key
 * @property {string} name - List name
 * @property {string|null} description - Optional description
 * @property {string|null} color - Optional color hex code
 * @property {string|null} icon - Optional icon name
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 * @property {boolean} isArchived - Whether list is archived
 */

/**
 * Shopping List Entity Schema
 * @type {EntitySchema<ShoppingListProperties>}
 */
export const ShoppingListSchema = new EntitySchema({
  name: 'ShoppingList',
  tableName: 'shopping_list',
  properties: {
    id: {
      type: 'uuid',
      primary: true,
      onCreate: () => crypto.randomUUID(),
    },
    name: {
      type: 'string',
    },
    description: {
      type: 'string',
      nullable: true,
    },
    color: {
      type: 'string',
      nullable: true,
    },
    icon: {
      type: 'string',
      nullable: true,
    },
    owner: {
      kind: 'm:1',
      entity: 'User',
    },
    items: {
      kind: '1:m',
      entity: 'ShoppingListItem',
      mappedBy: 'list',
      orphanRemoval: true,
    },
    shares: {
      kind: '1:m',
      entity: 'ListShare',
      mappedBy: 'list',
      orphanRemoval: true,
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
    isArchived: {
      type: 'boolean',
      default: false,
    },
  },
});
