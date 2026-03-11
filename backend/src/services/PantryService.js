import { AppError } from '../middleware/errorHandler.js';
import { SharePermission } from '../entities/ListShare.js';
import { DEFAULT_STORAGE_LOCATIONS } from '../entities/StorageLocation.js';

/**
 * Pantry Service
 * Handles all business logic for pantries
 */
export class PantryService {
  /**
   * @param {EntityManager} em - MikroORM Entity Manager
   */
  constructor(em) {
    this.em = em;
  }

  /**
   * Resolve user from SuperTokens ID
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<User>}
   */
  async #resolveUser(userId) {
    const user = await this.em.findOne('User', { supertokensUserId: userId });
    if (!user) {
      throw new AppError(404, 'User not found');
    }
    return user;
  }

  /**
   * Check if user has at least read access to a pantry
   * @param {object} pantry - Pantry entity (with shares populated)
   * @param {object} user - User entity
   * @returns {boolean}
   */
  #hasAccess(pantry, user) {
    return pantry.owner.id === user.id ||
      pantry.shares.getItems().some(share => share.user.id === user.id && share.isActive);
  }

  /**
   * Check if user has write access to a pantry
   * @param {object} pantry - Pantry entity (with shares populated)
   * @param {object} user - User entity
   * @returns {boolean}
   */
  #hasWriteAccess(pantry, user) {
    return pantry.owner.id === user.id ||
      pantry.shares.getItems().some(
        share => share.user.id === user.id &&
        share.isActive &&
        (share.permission === SharePermission.WRITE || share.permission === SharePermission.ADMIN)
      );
  }

  /**
   * Create a new pantry with default storage locations
   * @param {string} ownerId - SuperTokens user ID
   * @param {object} data - Pantry data
   * @returns {Promise<Pantry>}
   */
  async createPantry(ownerId, data) {
    const owner = await this.#resolveUser(ownerId);

    console.log(`[PantryService] Creating pantry "${data.name}" for user ${owner.id}`);

    const pantry = this.em.create('Pantry', {
      ...data,
      owner,
    });

    await this.em.persistAndFlush(pantry);

    // Seed default storage locations
    for (const loc of DEFAULT_STORAGE_LOCATIONS) {
      this.em.create('StorageLocation', {
        pantry,
        name: loc.name,
        icon: loc.icon,
        order: loc.order,
      });
    }
    await this.em.flush();

    await this.em.populate(pantry, ['owner', 'items.product', 'items.storageLocation', 'storageLocations', 'shares.user']);

    console.log(`[PantryService] Created pantry "${pantry.name}" (${pantry.id}) with ${DEFAULT_STORAGE_LOCATIONS.length} default locations`);
    return pantry;
  }

  /**
   * Get all pantries for a user (owned + shared)
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<Pantry[]>}
   */
  async getUserPantries(userId) {
    const user = await this.#resolveUser(userId);

    console.log(`[PantryService] Loading pantries for user ${user.id}`);

    const ownedPantries = await this.em.find(
      'Pantry',
      { owner: user, isArchived: false },
      { populate: ['owner', 'items.product', 'items.storageLocation', 'storageLocations', 'shares.user'], orderBy: { updatedAt: 'DESC' } }
    );

    const shares = await this.em.find(
      'PantryShare',
      { user, isActive: true },
      { populate: ['pantry.items.product', 'pantry.items.storageLocation', 'pantry.owner', 'pantry.storageLocations', 'pantry.shares.user'] }
    );

    const sharedPantries = shares
      .map(share => share.pantry)
      .filter(pantry => !pantry.isArchived);

    const allPantries = [...ownedPantries, ...sharedPantries];
    const uniquePantries = Array.from(new Map(allPantries.map(p => [p.id, p])).values());

    console.log(`[PantryService] Loaded ${uniquePantries.length} pantries (${ownedPantries.length} owned, ${sharedPantries.length} shared)`);
    return uniquePantries;
  }

  /**
   * Get a pantry by ID
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<Pantry>}
   */
  async getPantryById(pantryId, userId) {
    const user = await this.#resolveUser(userId);

    const pantry = await this.em.findOne(
      'Pantry',
      { id: pantryId },
      { populate: ['items.product', 'items.storageLocation', 'owner', 'storageLocations', 'shares.user'] }
    );

    if (!pantry) {
      throw new AppError(404, 'Pantry not found');
    }

    if (!this.#hasAccess(pantry, user)) {
      throw new AppError(403, 'Access denied');
    }

    return pantry;
  }

  /**
   * Update a pantry
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @param {object} data - Update data
   * @returns {Promise<Pantry>}
   */
  async updatePantry(pantryId, userId, data) {
    const pantry = await this.getPantryById(pantryId, userId);
    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    console.log(`[PantryService] Updating pantry "${pantry.name}" (${pantryId})`);
    this.em.assign(pantry, data);
    await this.em.flush();

    return pantry;
  }

  /**
   * Delete a pantry (owner only)
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<void>}
   */
  async deletePantry(pantryId, userId) {
    const pantry = await this.getPantryById(pantryId, userId);
    const user = await this.#resolveUser(userId);

    if (pantry.owner.id !== user.id) {
      throw new AppError(403, 'Only the owner can delete the pantry');
    }

    console.log(`[PantryService] Deleting pantry "${pantry.name}" (${pantryId})`);
    await this.em.removeAndFlush(pantry);
  }

  // ── Item CRUD ──────────────────────────────────────────────

  /**
   * Add an item to a pantry
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @param {object} data - Item data
   * @returns {Promise<PantryItem>}
   */
  async addItem(pantryId, userId, data) {
    const pantry = await this.getPantryById(pantryId, userId);
    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    const maxOrder = Math.max(0, ...pantry.items.getItems().map(item => item.order));

    const { productId, storageLocationId, expirationDate, purchaseDate, ...itemData } = data;

    // Resolve product reference
    let product = null;
    if (productId) {
      product = await this.em.findOne('Product', { id: productId });
      if (product) {
        console.log(`[PantryService] Linked product "${product.name}" (${product.id}) to pantry item`);
      }
    }

    // Resolve storage location
    let storageLocation = null;
    if (storageLocationId) {
      storageLocation = await this.em.findOne('StorageLocation', { id: storageLocationId, pantry });
      if (!storageLocation) {
        console.warn(`[PantryService] Storage location ${storageLocationId} not found in pantry ${pantryId}`);
      }
    }

    const item = this.em.create('PantryItem', {
      ...itemData,
      pantry,
      product,
      storageLocation,
      expirationDate: expirationDate ? new Date(expirationDate) : null,
      purchaseDate: purchaseDate ? new Date(purchaseDate) : null,
      order: maxOrder + 1,
    });

    await this.em.persistAndFlush(item);

    if (product) {
      await this.em.populate(item, ['product']);
    }
    if (storageLocation) {
      await this.em.populate(item, ['storageLocation']);
    }

    console.log(`[PantryService] Added item "${item.name}" (${item.id}) to pantry "${pantry.name}"`);
    return item;
  }

  /**
   * Update a pantry item
   * @param {string} itemId - Item ID
   * @param {string} userId - SuperTokens user ID
   * @param {object} data - Update data
   * @returns {Promise<PantryItem>}
   */
  async updateItem(itemId, userId, data) {
    const item = await this.em.findOne(
      'PantryItem',
      { id: itemId },
      { populate: ['pantry.owner', 'pantry.shares.user', 'product', 'storageLocation'] }
    );

    if (!item) {
      throw new AppError(404, 'Item not found');
    }

    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(item.pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    const { storageLocationId, expirationDate, purchaseDate, ...updateData } = data;

    // Resolve storage location if provided
    if (storageLocationId !== undefined) {
      if (storageLocationId) {
        const storageLocation = await this.em.findOne('StorageLocation', { id: storageLocationId, pantry: item.pantry });
        if (storageLocation) {
          updateData.storageLocation = storageLocation;
        }
      } else {
        updateData.storageLocation = null;
      }
    }

    // Parse dates if provided
    if (expirationDate !== undefined) {
      updateData.expirationDate = expirationDate ? new Date(expirationDate) : null;
    }
    if (purchaseDate !== undefined) {
      updateData.purchaseDate = purchaseDate ? new Date(purchaseDate) : null;
    }

    console.log(`[PantryService] Updating item "${item.name}" (${itemId}) — quantity: ${data.quantity ?? item.quantity}`);
    this.em.assign(item, updateData);
    await this.em.flush();

    return item;
  }

  /**
   * Delete a pantry item
   * @param {string} itemId - Item ID
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<void>}
   */
  async deleteItem(itemId, userId) {
    const item = await this.em.findOne(
      'PantryItem',
      { id: itemId },
      { populate: ['pantry.owner', 'pantry.shares.user'] }
    );

    if (!item) {
      throw new AppError(404, 'Item not found');
    }

    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(item.pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    console.log(`[PantryService] Deleting item "${item.name}" (${itemId})`);
    await this.em.removeAndFlush(item);
  }

  // ── Storage Locations ──────────────────────────────────────

  /**
   * Add a storage location to a pantry
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @param {object} data - Location data
   * @returns {Promise<StorageLocation>}
   */
  async addStorageLocation(pantryId, userId, data) {
    const pantry = await this.getPantryById(pantryId, userId);
    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    const maxOrder = Math.max(0, ...pantry.storageLocations.getItems().map(loc => loc.order));

    const location = this.em.create('StorageLocation', {
      pantry,
      name: data.name,
      icon: data.icon || 'inventory_2',
      order: maxOrder + 1,
    });

    await this.em.persistAndFlush(location);

    console.log(`[PantryService] Added storage location "${location.name}" (${location.id}) to pantry "${pantry.name}"`);
    return location;
  }

  /**
   * Update a storage location
   * @param {string} locationId - Location ID
   * @param {string} userId - SuperTokens user ID
   * @param {object} data - Update data
   * @returns {Promise<StorageLocation>}
   */
  async updateStorageLocation(locationId, userId, data) {
    const location = await this.em.findOne(
      'StorageLocation',
      { id: locationId },
      { populate: ['pantry.owner', 'pantry.shares.user'] }
    );

    if (!location) {
      throw new AppError(404, 'Storage location not found');
    }

    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(location.pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    console.log(`[PantryService] Updating storage location "${location.name}" (${locationId})`);
    this.em.assign(location, data);
    await this.em.flush();

    return location;
  }

  /**
   * Delete a storage location (moves items to null location)
   * @param {string} locationId - Location ID
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<void>}
   */
  async deleteStorageLocation(locationId, userId) {
    const location = await this.em.findOne(
      'StorageLocation',
      { id: locationId },
      { populate: ['pantry.owner', 'pantry.shares.user'] }
    );

    if (!location) {
      throw new AppError(404, 'Storage location not found');
    }

    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(location.pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    // Unset storage location on items that reference it
    const items = await this.em.find('PantryItem', { storageLocation: location });
    for (const item of items) {
      item.storageLocation = null;
    }
    await this.em.flush();

    console.log(`[PantryService] Deleting storage location "${location.name}" (${locationId}), unlinked ${items.length} items`);
    await this.em.removeAndFlush(location);
  }

  // ── Sharing ────────────────────────────────────────────────

  /**
   * Share a pantry with another user
   * @param {string} pantryId - Pantry ID
   * @param {string} ownerId - Owner's SuperTokens user ID
   * @param {string} targetUserEmail - Target user's email
   * @param {string} permission - Permission level
   * @returns {Promise<PantryShare>}
   */
  async sharePantry(pantryId, ownerId, targetUserEmail, permission) {
    const pantry = await this.getPantryById(pantryId, ownerId);
    const owner = await this.#resolveUser(ownerId);

    if (pantry.owner.id !== owner.id) {
      throw new AppError(403, 'Only the owner can share the pantry');
    }

    const targetUser = await this.em.findOne('User', { email: targetUserEmail });
    if (!targetUser) {
      throw new AppError(404, 'Target user not found');
    }

    const existingShare = await this.em.findOne('PantryShare', {
      pantry,
      user: targetUser,
    });

    if (existingShare) {
      existingShare.permission = permission;
      existingShare.isActive = true;
      await this.em.flush();
      console.log(`[PantryService] Updated share for pantry "${pantry.name}" with ${targetUserEmail} → ${permission}`);
      return existingShare;
    }

    const share = this.em.create('PantryShare', {
      pantry,
      user: targetUser,
      permission,
    });

    await this.em.persistAndFlush(share);
    console.log(`[PantryService] Shared pantry "${pantry.name}" with ${targetUserEmail} (${permission})`);
    return share;
  }

  /**
   * Unshare a pantry from a user
   * @param {string} pantryId - Pantry ID
   * @param {string} ownerId - Owner's SuperTokens user ID
   * @param {string} targetUserId - Target user ID
   * @returns {Promise<void>}
   */
  async unsharePantry(pantryId, ownerId, targetUserId) {
    const pantry = await this.getPantryById(pantryId, ownerId);
    const owner = await this.#resolveUser(ownerId);

    if (pantry.owner.id !== owner.id) {
      throw new AppError(403, 'Only the owner can unshare the pantry');
    }

    const targetUser = await this.em.findOne('User', { id: targetUserId });
    if (!targetUser) {
      throw new AppError(404, 'Target user not found');
    }

    const share = await this.em.findOne('PantryShare', { pantry, user: targetUser });
    if (share) {
      await this.em.removeAndFlush(share);
      console.log(`[PantryService] Unshared pantry "${pantry.name}" from user ${targetUserId}`);
    }
  }

  // ── Smart Features ─────────────────────────────────────────

  /**
   * Get items expiring within N days
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @param {number} days - Number of days to look ahead
   * @returns {Promise<PantryItem[]>}
   */
  async getExpiringItems(pantryId, userId, days = 7) {
    await this.getPantryById(pantryId, userId); // access check

    const deadline = new Date();
    deadline.setDate(deadline.getDate() + days);

    const items = await this.em.find(
      'PantryItem',
      {
        pantry: pantryId,
        expirationDate: { $ne: null, $lte: deadline },
        quantity: { $gt: 0 },
      },
      {
        populate: ['product', 'storageLocation'],
        orderBy: { expirationDate: 'ASC' },
      }
    );

    console.log(`[PantryService] Found ${items.length} items expiring within ${days} days in pantry ${pantryId}`);
    return items;
  }

  /**
   * Get items that are running low
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<PantryItem[]>}
   */
  async getLowStockItems(pantryId, userId) {
    await this.getPantryById(pantryId, userId); // access check

    const allItems = await this.em.find(
      'PantryItem',
      { pantry: pantryId },
      { populate: ['product', 'storageLocation'] }
    );

    const lowStockItems = allItems.filter(
      item => item.quantity <= item.lowStockThreshold * item.maxQuantity
    );

    console.log(`[PantryService] Found ${lowStockItems.length} low-stock items in pantry ${pantryId}`);
    return lowStockItems;
  }

  /**
   * Suggest items for a shopping list based on low stock
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<Array<{name: string, quantity: number, unit: string|null, category: string|null, barcode: string|null, productId: string|null}>>}
   */
  async suggestForShoppingList(pantryId, userId) {
    const lowStockItems = await this.getLowStockItems(pantryId, userId);

    const suggestions = lowStockItems.map(item => ({
      name: item.name,
      quantity: Math.ceil(item.maxQuantity - item.quantity),
      unit: item.unit,
      category: item.category,
      barcode: item.barcode,
      productId: item.product?.id ?? null,
    }));

    console.log(`[PantryService] Generated ${suggestions.length} shopping list suggestions from pantry ${pantryId}`);
    return suggestions;
  }

  /**
   * Move checked items from a shopping list to the pantry
   * @param {string} pantryId - Pantry ID
   * @param {string} userId - SuperTokens user ID
   * @param {string} shoppingListId - Shopping list ID
   * @param {string[]} itemIds - Shopping list item IDs to move
   * @param {string|null} storageLocationId - Default storage location for moved items
   * @param {boolean} removeFromList - Whether to remove items from shopping list
   * @returns {Promise<PantryItem[]>}
   */
  async moveFromShoppingList(pantryId, userId, shoppingListId, itemIds, storageLocationId = null, removeFromList = false) {
    const pantry = await this.getPantryById(pantryId, userId);
    const user = await this.#resolveUser(userId);

    if (!this.#hasWriteAccess(pantry, user)) {
      throw new AppError(403, 'Write permission required');
    }

    // Resolve storage location
    let storageLocation = null;
    if (storageLocationId) {
      storageLocation = await this.em.findOne('StorageLocation', { id: storageLocationId, pantry });
    }

    // Fetch shopping list items
    const shoppingListItems = await this.em.find(
      'ShoppingListItem',
      { id: { $in: itemIds }, list: shoppingListId },
      { populate: ['product'] }
    );

    if (shoppingListItems.length === 0) {
      throw new AppError(404, 'No matching shopping list items found');
    }

    console.log(`[PantryService] Moving ${shoppingListItems.length} items from shopping list ${shoppingListId} to pantry "${pantry.name}"`);

    const maxOrder = Math.max(0, ...pantry.items.getItems().map(item => item.order));
    const pantryItems = [];

    for (let i = 0; i < shoppingListItems.length; i++) {
      const slItem = shoppingListItems[i];
      const pantryItem = this.em.create('PantryItem', {
        pantry,
        name: slItem.name,
        quantity: slItem.quantity,
        maxQuantity: slItem.quantity,
        unit: slItem.unit,
        category: slItem.category,
        storageLocation,
        product: slItem.product,
        barcode: slItem.barcode,
        purchaseDate: new Date(),
        order: maxOrder + i + 1,
      });
      this.em.persist(pantryItem);
      pantryItems.push(pantryItem);
    }

    // Optionally remove from shopping list
    if (removeFromList) {
      for (const slItem of shoppingListItems) {
        this.em.remove(slItem);
      }
      console.log(`[PantryService] Removed ${shoppingListItems.length} items from shopping list ${shoppingListId}`);
    }

    await this.em.flush();

    // Populate for response
    for (const item of pantryItems) {
      await this.em.populate(item, ['product', 'storageLocation']);
    }

    console.log(`[PantryService] Created ${pantryItems.length} pantry items from shopping list`);
    return pantryItems;
  }
}
