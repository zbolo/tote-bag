import { EntitySchema } from '@mikro-orm/core';

/**
 * @typedef {Object} PantryProperties
 * @property {string} id - UUID primary key
 * @property {string} name - Pantry name
 * @property {string|null} description - Optional description
 * @property {string|null} color - Optional color hex code
 * @property {string|null} icon - Optional icon name
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 * @property {boolean} isArchived - Whether pantry is archived
 */

/**
 * Pantry Entity Schema
 * @type {EntitySchema<PantryProperties>}
 */
export const PantrySchema = new EntitySchema({
  name: 'Pantry',
  tableName: 'pantry',
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
      entity: 'PantryItem',
      mappedBy: 'pantry',
      orphanRemoval: true,
    },
    storageLocations: {
      kind: '1:m',
      entity: 'StorageLocation',
      mappedBy: 'pantry',
      orphanRemoval: true,
    },
    shares: {
      kind: '1:m',
      entity: 'PantryShare',
      mappedBy: 'pantry',
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
