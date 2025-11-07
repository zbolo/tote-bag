import { EntityManager } from '@mikro-orm/core';
import { ShoppingList } from '../entities/ShoppingList.js';
import { ShoppingListItem } from '../entities/ShoppingListItem.js';
import { ListShare, SharePermission } from '../entities/ListShare.js';
import { User } from '../entities/User.js';
import { AppError } from '../middleware/errorHandler.js';

/**
 * Shopping List Service
 * Handles all business logic for shopping lists
 */
export class ShoppingListService {
  /**
   * @param {EntityManager} em - MikroORM Entity Manager
   */
  constructor(em) {
    this.em = em;
  }

  /**
   * Create a new shopping list
   * @param {string} ownerId - Supertokens user ID
   * @param {object} data - List data
   * @param {string} data.name - List name
   * @param {string} [data.description] - List description
   * @param {string} [data.color] - List color
   * @param {string} [data.icon] - List icon
   * @returns {Promise<ShoppingList>}
   */
  async createList(ownerId, data) {
    const owner = await this.em.findOne(User, { supertokensUserId: ownerId });
    if (!owner) {
      throw new AppError(404, 'User not found');
    }

    const list = this.em.create(ShoppingList, {
      ...data,
      owner,
    });

    await this.em.persistAndFlush(list);
    return list;
  }

  /**
   * Get all lists for a user (owned + shared)
   * @param {string} userId - Supertokens user ID
   * @returns {Promise<ShoppingList[]>}
   */
  async getUserLists(userId) {
    const user = await this.em.findOne(User, { supertokensUserId: userId });
    if (!user) {
      throw new AppError(404, 'User not found');
    }

    // Get owned lists
    const ownedLists = await this.em.find(
      ShoppingList,
      { owner: user, isArchived: false },
      { populate: ['items', 'shares.user'], orderBy: { updatedAt: 'DESC' } }
    );

    // Get shared lists
    const shares = await this.em.find(
      ListShare,
      { user, isActive: true },
      { populate: ['list.items', 'list.owner', 'list.shares.user'] }
    );

    const sharedLists = shares
      .map(share => share.list)
      .filter(list => !list.isArchived);

    // Combine and deduplicate
    const allLists = [...ownedLists, ...sharedLists];
    const uniqueLists = Array.from(new Map(allLists.map(list => [list.id, list])).values());

    return uniqueLists;
  }

  /**
   * Get a shopping list by ID
   * @param {string} listId - List ID
   * @param {string} userId - Supertokens user ID
   * @returns {Promise<ShoppingList>}
   */
  async getListById(listId, userId) {
    const user = await this.em.findOne(User, { supertokensUserId: userId });
    if (!user) {
      throw new AppError(404, 'User not found');
    }

    const list = await this.em.findOne(
      ShoppingList,
      { id: listId },
      { populate: ['items.product', 'owner', 'shares.user'] }
    );

    if (!list) {
      throw new AppError(404, 'Shopping list not found');
    }

    // Check if user has access
    const hasAccess = list.owner.id === user.id ||
      list.shares.getItems().some(share => share.user.id === user.id && share.isActive);

    if (!hasAccess) {
      throw new AppError(403, 'Access denied');
    }

    return list;
  }

  /**
   * Update a shopping list
   * @param {string} listId - List ID
   * @param {string} userId - Supertokens user ID
   * @param {object} data - Update data
   * @returns {Promise<ShoppingList>}
   */
  async updateList(listId, userId, data) {
    const list = await this.getListById(listId, userId);
    const user = await this.em.findOne(User, { supertokensUserId: userId });

    if (!user) {
      throw new AppError(404, 'User not found');
    }

    // Check if user has write permission
    const hasWriteAccess = list.owner.id === user.id ||
      list.shares.getItems().some(
        share => share.user.id === user.id &&
        share.isActive &&
        (share.permission === SharePermission.WRITE || share.permission === SharePermission.ADMIN)
      );

    if (!hasWriteAccess) {
      throw new AppError(403, 'Write permission required');
    }

    this.em.assign(list, data);
    await this.em.flush();

    return list;
  }

  /**
   * Delete a shopping list
   * @param {string} listId - List ID
   * @param {string} userId - Supertokens user ID
   * @returns {Promise<void>}
   */
  async deleteList(listId, userId) {
    const list = await this.getListById(listId, userId);
    const user = await this.em.findOne(User, { supertokensUserId: userId });

    if (!user || list.owner.id !== user.id) {
      throw new AppError(403, 'Only the owner can delete the list');
    }

    await this.em.removeAndFlush(list);
  }

  /**
   * Add an item to a shopping list
   * @param {string} listId - List ID
   * @param {string} userId - Supertokens user ID
   * @param {object} data - Item data
   * @returns {Promise<ShoppingListItem>}
   */
  async addItem(listId, userId, data) {
    const list = await this.getListById(listId, userId);
    const user = await this.em.findOne(User, { supertokensUserId: userId });

    if (!user) {
      throw new AppError(404, 'User not found');
    }

    const hasWriteAccess = list.owner.id === user.id ||
      list.shares.getItems().some(
        share => share.user.id === user.id &&
        share.isActive &&
        (share.permission === SharePermission.WRITE || share.permission === SharePermission.ADMIN)
      );

    if (!hasWriteAccess) {
      throw new AppError(403, 'Write permission required');
    }

    const maxOrder = Math.max(0, ...list.items.getItems().map(item => item.order));

    const item = this.em.create(ShoppingListItem, {
      ...data,
      list,
      order: maxOrder + 1,
    });

    await this.em.persistAndFlush(item);
    return item;
  }

  /**
   * Update a shopping list item
   * @param {string} itemId - Item ID
   * @param {string} userId - Supertokens user ID
   * @param {object} data - Update data
   * @returns {Promise<ShoppingListItem>}
   */
  async updateItem(itemId, userId, data) {
    const item = await this.em.findOne(
      ShoppingListItem,
      { id: itemId },
      { populate: ['list.owner', 'list.shares.user'] }
    );

    if (!item) {
      throw new AppError(404, 'Item not found');
    }

    const user = await this.em.findOne(User, { supertokensUserId: userId });
    if (!user) {
      throw new AppError(404, 'User not found');
    }

    const hasWriteAccess = item.list.owner.id === user.id ||
      item.list.shares.getItems().some(
        share => share.user.id === user.id &&
        share.isActive &&
        (share.permission === SharePermission.WRITE || share.permission === SharePermission.ADMIN)
      );

    if (!hasWriteAccess) {
      throw new AppError(403, 'Write permission required');
    }

    if (data.isChecked !== undefined && data.isChecked !== item.isChecked) {
      item.checkedAt = data.isChecked ? new Date() : undefined;
    }

    this.em.assign(item, data);
    await this.em.flush();

    return item;
  }

  /**
   * Delete a shopping list item
   * @param {string} itemId - Item ID
   * @param {string} userId - Supertokens user ID
   * @returns {Promise<void>}
   */
  async deleteItem(itemId, userId) {
    const item = await this.em.findOne(
      ShoppingListItem,
      { id: itemId },
      { populate: ['list.owner', 'list.shares.user'] }
    );

    if (!item) {
      throw new AppError(404, 'Item not found');
    }

    const user = await this.em.findOne(User, { supertokensUserId: userId });
    if (!user) {
      throw new AppError(404, 'User not found');
    }

    const hasWriteAccess = item.list.owner.id === user.id ||
      item.list.shares.getItems().some(
        share => share.user.id === user.id &&
        share.isActive &&
        (share.permission === SharePermission.WRITE || share.permission === SharePermission.ADMIN)
      );

    if (!hasWriteAccess) {
      throw new AppError(403, 'Write permission required');
    }

    await this.em.removeAndFlush(item);
  }

  /**
   * Share a list with another user
   * @param {string} listId - List ID
   * @param {string} ownerId - Owner's Supertokens user ID
   * @param {string} targetUserEmail - Target user's email
   * @param {string} permission - Permission level
   * @returns {Promise<ListShare>}
   */
  async shareList(listId, ownerId, targetUserEmail, permission) {
    const list = await this.getListById(listId, ownerId);
    const owner = await this.em.findOne(User, { supertokensUserId: ownerId });

    if (!owner || list.owner.id !== owner.id) {
      throw new AppError(403, 'Only the owner can share the list');
    }

    const targetUser = await this.em.findOne(User, { email: targetUserEmail });
    if (!targetUser) {
      throw new AppError(404, 'Target user not found');
    }

    // Check if already shared
    const existingShare = await this.em.findOne(ListShare, {
      list,
      user: targetUser,
    });

    if (existingShare) {
      existingShare.permission = permission;
      existingShare.isActive = true;
      await this.em.flush();
      return existingShare;
    }

    const share = this.em.create(ListShare, {
      list,
      user: targetUser,
      permission,
    });

    await this.em.persistAndFlush(share);
    return share;
  }

  /**
   * Unshare a list from a user
   * @param {string} listId - List ID
   * @param {string} ownerId - Owner's Supertokens user ID
   * @param {string} targetUserId - Target user ID
   * @returns {Promise<void>}
   */
  async unshareList(listId, ownerId, targetUserId) {
    const list = await this.getListById(listId, ownerId);
    const owner = await this.em.findOne(User, { supertokensUserId: ownerId });

    if (!owner || list.owner.id !== owner.id) {
      throw new AppError(403, 'Only the owner can unshare the list');
    }

    const targetUser = await this.em.findOne(User, { id: targetUserId });
    if (!targetUser) {
      throw new AppError(404, 'Target user not found');
    }

    const share = await this.em.findOne(ListShare, { list, user: targetUser });
    if (share) {
      await this.em.removeAndFlush(share);
    }
  }
}
