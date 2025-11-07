import { EntitySchema } from '@mikro-orm/core';

/**
 * @typedef {Object} ShoppingListItemProperties
 * @property {string} id - UUID primary key
 * @property {string} name - Item name
 * @property {number} quantity - Item quantity
 * @property {string|null} unit - Optional unit (kg, liters, etc.)
 * @property {string|null} notes - Optional notes
 * @property {boolean} isChecked - Whether item is checked
 * @property {string|null} category - Optional category
 * @property {string|null} barcode - Optional barcode
 * @property {Date} createdAt - Creation timestamp
 * @property {Date} updatedAt - Last update timestamp
 * @property {Date|null} checkedAt - When item was checked
 * @property {number} order - Display order
 */

/**
 * Shopping List Item Entity Schema
 * @type {EntitySchema<ShoppingListItemProperties>}
 */
export const ShoppingListItemSchema = new EntitySchema({
  name: 'ShoppingListItem',
  tableName: 'shopping_list_item',
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
    name: {
      type: 'string',
    },
    quantity: {
      type: 'number',
      default: 1,
    },
    unit: {
      type: 'string',
      nullable: true,
    },
    notes: {
      type: 'string',
      nullable: true,
    },
    isChecked: {
      type: 'boolean',
      default: false,
    },
    category: {
      type: 'string',
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
    createdAt: {
      type: 'Date',
      onCreate: () => new Date(),
    },
    updatedAt: {
      type: 'Date',
      onCreate: () => new Date(),
      onUpdate: () => new Date(),
    },
    checkedAt: {
      type: 'Date',
      nullable: true,
    },
    order: {
      type: 'number',
      default: 0,
    },
  },
});
