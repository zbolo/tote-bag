import { Router } from 'express';
import { getORM } from '../config/database.js';
import { FavoriteProductService } from '../services/FavoriteProductService.js';
import { verifySession } from 'supertokens-node/recipe/session/framework/express/index.js';
import { extractUserId } from '../middleware/auth.js';

const router = Router();

// Apply authentication middleware to all routes
router.use(verifySession());
router.use(extractUserId);

/**
 * GET /api/favorites
 * Get all favorite products for the current user
 */
router.get('/', async (req, res, next) => {
  try {
    const orm = getORM();
    const em = orm.em.fork();
    const service = new FavoriteProductService(em);

    const favorites = await service.getFavorites(req.userId);

    res.json({
      success: true,
      data: favorites,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/favorites/:productId
 * Add a product to favorites
 */
router.post('/:productId', async (req, res, next) => {
  try {
    const { productId } = req.params;
    const orm = getORM();
    const em = orm.em.fork();
    const service = new FavoriteProductService(em);

    // Check if product exists
    const product = await em.findOne('Product', { id: productId });
    if (!product) {
      return res.status(404).json({
        success: false,
        error: 'Product not found',
      });
    }

    await service.addFavorite(req.userId, productId);

    res.status(201).json({
      success: true,
      message: 'Product added to favorites',
    });
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /api/favorites/:productId
 * Remove a product from favorites
 */
router.delete('/:productId', async (req, res, next) => {
  try {
    const { productId } = req.params;
    const orm = getORM();
    const em = orm.em.fork();
    const service = new FavoriteProductService(em);

    const removed = await service.removeFavorite(req.userId, productId);

    if (!removed) {
      return res.status(404).json({
        success: false,
        error: 'Favorite not found',
      });
    }

    res.json({
      success: true,
      message: 'Product removed from favorites',
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/favorites/:productId/toggle
 * Toggle favorite status for a product
 */
router.post('/:productId/toggle', async (req, res, next) => {
  try {
    const { productId } = req.params;
    const orm = getORM();
    const em = orm.em.fork();
    const service = new FavoriteProductService(em);

    // Check if product exists
    const product = await em.findOne('Product', { id: productId });
    if (!product) {
      return res.status(404).json({
        success: false,
        error: 'Product not found',
      });
    }

    const result = await service.toggleFavorite(req.userId, productId);

    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/favorites/:productId/status
 * Check if a product is favorited
 */
router.get('/:productId/status', async (req, res, next) => {
  try {
    const { productId } = req.params;
    const orm = getORM();
    const em = orm.em.fork();
    const service = new FavoriteProductService(em);

    const isFavorite = await service.isFavorite(req.userId, productId);

    res.json({
      success: true,
      data: { isFavorite },
    });
  } catch (error) {
    next(error);
  }
});

export default router;
