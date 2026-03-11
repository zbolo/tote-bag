import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';
import { requireAuth, extractUserId } from '../middleware/auth.js';
import { ProductService } from '../services/ProductService.js';
import { getORM } from '../config/database.js';
import { searchProductsSchema, createProductSchema } from '../types/validation.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const router = Router();

// Configure multer for product image uploads
const uploadsDir = path.join(__dirname, '../../uploads/products');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (_req, file, cb) => {
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    const ext = path.extname(file.originalname) || '.jpg';
    cb(null, `product-${uniqueSuffix}${ext}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (_req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only JPEG, PNG, and WebP images are allowed'));
    }
  },
});

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

// Create a product manually (for not-found barcodes) with optional image upload
router.post('/', upload.single('image'), async (req, res) => {
  console.log(`[Products] Creating product manually: ${JSON.stringify(req.body)}`);

  const { name, barcode, brand, category, quantity } = createProductSchema.parse(req.body);

  const em = getORM().em.fork();
  const service = new ProductService(em);

  let imageUrl = null;
  if (req.file) {
    const baseUrl = `${req.protocol}://${req.get('host')}`;
    imageUrl = `${baseUrl}/uploads/products/${req.file.filename}`;
    console.log(`[Products] Image uploaded: ${imageUrl}`);
  }

  const product = await service.createProduct({
    barcode,
    name,
    brand: brand || null,
    category: category || null,
    quantity: quantity || null,
    imageUrl,
    source: 'user',
  });

  console.log(`[Products] Product created: ${product.id} "${product.name}"`);

  res.status(201).json({
    status: 'success',
    data: { product },
  });
});

// Upload or replace image for an existing product
router.post('/:productId/image', upload.single('image'), async (req, res) => {
  const { productId } = req.params;
  console.log(`[Products] Uploading image for product ${productId}`);

  if (!req.file) {
    return res.status(400).json({
      status: 'error',
      message: 'No image file provided',
    });
  }

  const em = getORM().em.fork();
  const product = await em.findOne('Product', { id: productId });

  if (!product) {
    // Clean up uploaded file
    fs.unlinkSync(req.file.path);
    return res.status(404).json({
      status: 'error',
      message: 'Product not found',
    });
  }

  const baseUrl = `${req.protocol}://${req.get('host')}`;
  const imageUrl = `${baseUrl}/uploads/products/${req.file.filename}`;

  // Delete old uploaded image if it was a local file
  if (product.imageUrl && product.imageUrl.includes('/uploads/products/')) {
    try {
      const oldFilename = product.imageUrl.split('/uploads/products/').pop();
      const oldPath = path.join(uploadsDir, oldFilename);
      if (fs.existsSync(oldPath)) {
        fs.unlinkSync(oldPath);
        console.log(`[Products] Deleted old image: ${oldFilename}`);
      }
    } catch (err) {
      console.warn(`[Products] Could not delete old image: ${err.message}`);
    }
  }

  product.imageUrl = imageUrl;
  await em.flush();

  console.log(`[Products] Image updated for product ${productId}: ${imageUrl}`);

  res.json({
    status: 'success',
    data: { product },
  });
});

export default router;
