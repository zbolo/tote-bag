import { Router } from 'express';
import { requireAuth, extractUserId } from '../middleware/auth.js';
import { ProductService } from '../services/ProductService.js';
import { getORM } from '../config/database.js';
import { searchProductsSchema } from '../types/validation.js';

const router = Router();

// Apply authentication to all routes
router.use(requireAuth);
router.use(extractUserId);

// Get product by barcode
router.get('/barcode/:barcode', async (req, res) => {
  const em = getORM().em.fork();
  const service = new ProductService(em);

  const product = await service.getProductByBarcode(req.params.barcode);

  if (!product) {
    return res.status(404).json({
      status: 'error',
      message: 'Product not found',
    });
  }

  res.json({
    status: 'success',
    data: { product },
  });
});

// Search products
router.get('/search', async (req, res) => {
  const { query, limit } = searchProductsSchema.parse(req.query);
  const em = getORM().em.fork();
  const service = new ProductService(em);

  const products = await service.searchProducts(query, limit);

  res.json({
    status: 'success',
    data: { products },
  });
});

export default router;
