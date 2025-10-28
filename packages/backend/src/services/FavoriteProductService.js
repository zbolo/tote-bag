import { EntityManager } from '@mikro-orm/core';

/**
 * Service for managing user favorite products
 */
export class FavoriteProductService {
  /**
   * @param {EntityManager} em - MikroORM entity manager
   */
  constructor(em) {
    this.em = em;
  }

  /**
   * Add a product to user's favorites
   * @param {string} userId - User ID
   * @param {string} productId - Product ID
   * @returns {Promise<Object>} The created favorite
   */
  async addFavorite(userId, productId) {
    // Check if already favorited
    const existing = await this.em.findOne('UserFavoriteProduct', {
      user: userId,
      product: productId,
    });

    if (existing) {
      return existing;
    }

    const favorite = this.em.create('UserFavoriteProduct', {
      user: userId,
      product: productId,
    });

    await this.em.persistAndFlush(favorite);
    return favorite;
  }

  /**
   * Remove a product from user's favorites
   * @param {string} userId - User ID
   * @param {string} productId - Product ID
   * @returns {Promise<boolean>} True if removed, false if not found
   */
  async removeFavorite(userId, productId) {
    const favorite = await this.em.findOne('UserFavoriteProduct', {
      user: userId,
      product: productId,
    });

    if (!favorite) {
      return false;
    }

    await this.em.removeAndFlush(favorite);
    return true;
  }

  /**
   * Toggle favorite status for a product
   * @param {string} userId - User ID
   * @param {string} productId - Product ID
   * @returns {Promise<{isFavorite: boolean}>} New favorite status
   */
  async toggleFavorite(userId, productId) {
    const favorite = await this.em.findOne('UserFavoriteProduct', {
      user: userId,
      product: productId,
    });

    if (favorite) {
      await this.em.removeAndFlush(favorite);
      return { isFavorite: false };
    } else {
      await this.addFavorite(userId, productId);
      return { isFavorite: true };
    }
  }

  /**
   * Get all favorite products for a user
   * @param {string} userId - User ID
   * @returns {Promise<Array>} Array of favorite products
   */
  async getFavorites(userId) {
    const favorites = await this.em.find(
      'UserFavoriteProduct',
      { user: userId },
      { populate: ['product'], orderBy: { createdAt: 'DESC' } }
    );

    return favorites.map(fav => fav.product);
  }

  /**
   * Check if a product is favorited by a user
   * @param {string} userId - User ID
   * @param {string} productId - Product ID
   * @returns {Promise<boolean>} True if favorited
   */
  async isFavorite(userId, productId) {
    const count = await this.em.count('UserFavoriteProduct', {
      user: userId,
      product: productId,
    });

    return count > 0;
  }

  /**
   * Get favorite status for multiple products
   * @param {string} userId - User ID
   * @param {string[]} productIds - Array of product IDs
   * @returns {Promise<Map<string, boolean>>} Map of product ID to favorite status
   */
  async getFavoriteStatuses(userId, productIds) {
    const favorites = await this.em.find('UserFavoriteProduct', {
      user: userId,
      product: { $in: productIds },
    });

    const statusMap = new Map();
    productIds.forEach(id => statusMap.set(id, false));
    favorites.forEach(fav => statusMap.set(fav.product.id, true));

    return statusMap;
  }
}
