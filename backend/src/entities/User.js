import { EntitySchema } from '@mikro-orm/core';

/**
 * @typedef {Object} UserProperties
 * @property {string} id - UUID primary key
 * @property {string} email - Unique email address
 * @property {string} displayName - User's display name
 * @property {string|null} avatarUrl - Optional avatar URL
 * @property {string} supertokensUserId - Supertokens user ID
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 * @property {boolean} isActive - Whether user is active
 */

/**
 * User Entity Schema
 * @type {EntitySchema<UserProperties>}
 */
export const UserSchema = new EntitySchema({
  name: 'User',
  tableName: 'user',
  properties: {
    id: {
      type: 'uuid',
      primary: true,
      onCreate: () => crypto.randomUUID(),
    },
    email: {
      type: 'string',
      unique: true,
    },
    displayName: {
      type: 'string',
    },
    avatarUrl: {
      type: 'string',
      nullable: true,
    },
    supertokensUserId: {
      type: 'string',
    },
    ownedLists: {
      kind: '1:m',
      entity: 'ShoppingList',
      mappedBy: 'owner',
    },
    sharedLists: {
      kind: '1:m',
      entity: 'ListShare',
      mappedBy: 'user',
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
