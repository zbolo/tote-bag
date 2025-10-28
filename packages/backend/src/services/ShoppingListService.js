import { EntityManager } from '@mikro-orm/core';
import { ShoppingList } from '../entities/ShoppingList.js';
import { ShoppingListItem } from '../entities/ShoppingListItem.js';
import { ListShare, SharePermission } from '../entities/ListShare.js';
import { User } from '../entities/User.js';
import { AppError } from '../middleware/errorHandler.js';

export class ShoppingListService {
  constructor(private em: EntityManager) {}

  async createList(ownerId: string, data: {
    name: string;
    description?: string;
    color?: string;
    icon?: string;
  }): Promise<ShoppingList> {
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

  async getUserLists(userId: string): Promise<ShoppingList[]> {
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

  async getListById(listId: string, userId: string): Promise<ShoppingList> {
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

  async updateList(listId: string, userId: string, data: Partial<{
    name: string;
    description: string;
    color: string;
    icon: string;
  }>): Promise<ShoppingList> {
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

  async deleteList(listId: string, userId: string): Promise<void> {
    const list = await this.getListById(listId, userId);
    const user = await this.em.findOne(User, { supertokensUserId: userId });

    if (!user || list.owner.id !== user.id) {
      throw new AppError(403, 'Only the owner can delete the list');
    }

    await this.em.removeAndFlush(list);
  }

  async addItem(listId: string, userId: string, data: {
    name: string;
    quantity?: number;
    unit?: string;
    notes?: string;
    category?: string;
    barcode?: string;
    productId?: string;
  }): Promise<ShoppingListItem> {
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

  async updateItem(itemId: string, userId: string, data: Partial<{
    name: string;
    quantity: number;
    unit: string;
    notes: string;
    isChecked: boolean;
    category: string;
    order: number;
  }>): Promise<ShoppingListItem> {
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

  async deleteItem(itemId: string, userId: string): Promise<void> {
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

  async shareList(
    listId: string,
    ownerId: string,
    targetUserEmail: string,
    permission: SharePermission
  ): Promise<ListShare> {
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

  async unshareList(listId: string, ownerId: string, targetUserId: string): Promise<void> {
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
