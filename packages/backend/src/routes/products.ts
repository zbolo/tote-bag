import { Router, RequestHandler } from 'express';
import { requireAuth, extractUserId, AuthenticatedRequest } from '../middleware/auth';
import { ProductService } from '../services/ProductService';
import { getORM } from '../config/database';
import { searchProductsSchema } from '../types/validation';

const router = Router();

// Apply authentication to all routes
router.use(requireAuth);
router.use(extractUserId);

// Get product by barcode
router.get('/barcode/:barcode', (async (req: AuthenticatedRequest, res) => {
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
}) as RequestHandler);

// Search products
router.get('/search', (async (req: AuthenticatedRequest, res) => {
  const { query, limit } = searchProductsSchema.parse(req.query);
  const em = getORM().em.fork();
  const service = new ProductService(em);

  const products = await service.searchProducts(query, limit);

  res.json({
    status: 'success',
    data: { products },
  });
}) as RequestHandler);

export default router;
