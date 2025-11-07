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
   * @param {string} userId - SuperTokens user ID
   * @param {string} productId - Product ID
   * @returns {Promise<Object>} The created favorite
   */
  async addFavorite(userId, productId) {
    console.log(`[FavoriteProductService] Adding favorite for user ${userId}, product ${productId}`);

    // Look up the user by SuperTokens ID
    const user = await this.em.findOne('User', { supertokensUserId: userId });
    if (!user) {
      throw new Error('User not found');
    }

    // Check if already favorited
    const existing = await this.em.findOne('UserFavoriteProduct', {
      user: user.id,
      product: productId,
    });

    if (existing) {
      console.log(`[FavoriteProductService] Product already favorited`);
      return existing;
    }

    const favorite = this.em.create('UserFavoriteProduct', {
      user: user.id,
      product: productId,
    });

    await this.em.persistAndFlush(favorite);
    console.log(`[FavoriteProductService] Favorite added successfully`);
    return favorite;
  }

  /**
   * Remove a product from user's favorites
   * @param {string} userId - SuperTokens user ID
   * @param {string} productId - Product ID
   * @returns {Promise<boolean>} True if removed, false if not found
   */
  async removeFavorite(userId, productId) {
    console.log(`[FavoriteProductService] Removing favorite for user ${userId}, product ${productId}`);

    // Look up the user by SuperTokens ID
    const user = await this.em.findOne('User', { supertokensUserId: userId });
    if (!user) {
      console.log(`[FavoriteProductService] User not found`);
      return false;
    }

    const favorite = await this.em.findOne('UserFavoriteProduct', {
      user: user.id,
      product: productId,
    });

    if (!favorite) {
      console.log(`[FavoriteProductService] Favorite not found`);
      return false;
    }

    await this.em.removeAndFlush(favorite);
    console.log(`[FavoriteProductService] Favorite removed successfully`);
    return true;
  }

  /**
   * Toggle favorite status for a product
   * @param {string} userId - SuperTokens user ID
   * @param {string} productId - Product ID
   * @returns {Promise<{isFavorite: boolean}>} New favorite status
   */
  async toggleFavorite(userId, productId) {
    console.log(`[FavoriteProductService] Toggling favorite for user ${userId}, product ${productId}`);

    // Look up the user by SuperTokens ID
    const user = await this.em.findOne('User', { supertokensUserId: userId });
    if (!user) {
      throw new Error('User not found');
    }

    const favorite = await this.em.findOne('UserFavoriteProduct', {
      user: user.id,
      product: productId,
    });

    if (favorite) {
      await this.em.removeAndFlush(favorite);
      console.log(`[FavoriteProductService] Favorite removed (toggled off)`);
      return { isFavorite: false };
    } else {
      await this.addFavorite(userId, productId);
      console.log(`[FavoriteProductService] Favorite added (toggled on)`);
      return { isFavorite: true };
    }
  }

  /**
   * Get all favorite products for a user
   * @param {string} userId - SuperTokens user ID
   * @returns {Promise<Array>} Array of favorite products
   */
  async getFavorites(userId) {
    console.log(`[FavoriteProductService] Getting favorites for user: ${userId}`);

    // Look up the user by SuperTokens ID
    const user = await this.em.findOne('User', { supertokensUserId: userId });
    if (!user) {
      console.log(`[FavoriteProductService] User not found: ${userId}`);
      return [];
    }

    const favorites = await this.em.find(
      'UserFavoriteProduct',
      { user: user.id },
      { populate: ['product'], orderBy: { createdAt: 'DESC' } }
    );

    console.log(`[FavoriteProductService] Found ${favorites.length} favorites`);

    return favorites.map(fav => fav.product);
  }

  /**
   * Check if a product is favorited by a user
   * @param {string} userId - SuperTokens user ID
   * @param {string} productId - Product ID
   * @returns {Promise<boolean>} True if favorited
   */
  async isFavorite(userId, productId) {
    // Look up the user by SuperTokens ID
    const user = await this.em.findOne('User', { supertokensUserId: userId });
    if (!user) {
      return false;
    }

    const count = await this.em.count('UserFavoriteProduct', {
      user: user.id,
      product: productId,
    });

    return count > 0;
  }

  /**
   * Get favorite status for multiple products
   * @param {string} userId - SuperTokens user ID
   * @param {string[]} productIds - Array of product IDs
   * @returns {Promise<Map<string, boolean>>} Map of product ID to favorite status
   */
  async getFavoriteStatuses(userId, productIds) {
    // Look up the user by SuperTokens ID
    const user = await this.em.findOne('User', { supertokensUserId: userId });
    if (!user) {
      const statusMap = new Map();
      productIds.forEach(id => statusMap.set(id, false));
      return statusMap;
    }

    const favorites = await this.em.find('UserFavoriteProduct', {
      user: user.id,
      product: { $in: productIds },
    });

    const statusMap = new Map();
    productIds.forEach(id => statusMap.set(id, false));
    favorites.forEach(fav => statusMap.set(fav.product.id, true));

    return statusMap;
  }
}
