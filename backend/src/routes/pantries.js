import { Router } from 'express';
import { requireAuth, extractUserId } from '../middleware/auth.js';
import { PantryService } from '../services/PantryService.js';
import { getORM } from '../config/database.js';
import {
  createPantrySchema,
  updatePantrySchema,
  addPantryItemSchema,
  updatePantryItemSchema,
  sharePantrySchema,
  moveFromShoppingListSchema,
  createStorageLocationSchema,
  updateStorageLocationSchema,
} from '../types/validation.js';

const router = Router();

// Apply authentication to all routes
router.use(requireAuth);
router.use(extractUserId);

// ── Pantry CRUD ──────────────────────────────────────────────

// Get all pantries for the authenticated user
router.get('/', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const pantries = await service.getUserPantries(req.userId);

  res.json({
    status: 'success',
    data: { pantries },
  });
});

// Create a new pantry
router.post('/', async (req, res) => {
  const data = createPantrySchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const pantry = await service.createPantry(req.userId, data);

  res.status(201).json({
    status: 'success',
    data: { pantry },
  });
});

// Get a specific pantry
router.get('/:pantryId', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const pantry = await service.getPantryById(req.params.pantryId, req.userId);

  res.json({
    status: 'success',
    data: { pantry },
  });
});

// Update a pantry
router.patch('/:pantryId', async (req, res) => {
  const data = updatePantrySchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const pantry = await service.updatePantry(req.params.pantryId, req.userId, data);

  res.json({
    status: 'success',
    data: { pantry },
  });
});

// Delete a pantry
router.delete('/:pantryId', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  await service.deletePantry(req.params.pantryId, req.userId);

  res.status(204).send();
});

// ── Item CRUD ────────────────────────────────────────────────

// Add an item to a pantry
router.post('/:pantryId/items', async (req, res) => {
  const data = addPantryItemSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const item = await service.addItem(req.params.pantryId, req.userId, data);

  res.status(201).json({
    status: 'success',
    data: { item },
  });
});

// Update a pantry item
router.patch('/:pantryId/items/:itemId', async (req, res) => {
  const data = updatePantryItemSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const item = await service.updateItem(req.params.itemId, req.userId, data);

  res.json({
    status: 'success',
    data: { item },
  });
});

// Delete a pantry item
router.delete('/:pantryId/items/:itemId', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  await service.deleteItem(req.params.itemId, req.userId);

  res.status(204).send();
});

// ── Storage Locations ────────────────────────────────────────

// Add a storage location to a pantry
router.post('/:pantryId/locations', async (req, res) => {
  const data = createStorageLocationSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const location = await service.addStorageLocation(req.params.pantryId, req.userId, data);

  res.status(201).json({
    status: 'success',
    data: { location },
  });
});

// Update a storage location
router.patch('/:pantryId/locations/:locationId', async (req, res) => {
  const data = updateStorageLocationSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const location = await service.updateStorageLocation(req.params.locationId, req.userId, data);

  res.json({
    status: 'success',
    data: { location },
  });
});

// Delete a storage location
router.delete('/:pantryId/locations/:locationId', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  await service.deleteStorageLocation(req.params.locationId, req.userId);

  res.status(204).send();
});

// ── Sharing ──────────────────────────────────────────────────

// Share a pantry
router.post('/:pantryId/share', async (req, res) => {
  const data = sharePantrySchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const share = await service.sharePantry(
    req.params.pantryId,
    req.userId,
    data.email,
    data.permission
  );

  res.status(201).json({
    status: 'success',
    data: { share },
  });
});

// Unshare a pantry
router.delete('/:pantryId/share/:userId', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  await service.unsharePantry(req.params.pantryId, req.userId, req.params.userId);

  res.status(204).send();
});

// ── Smart Features ───────────────────────────────────────────

// Get expiring items
router.get('/:pantryId/expiring', async (req, res) => {
  const days = parseInt(req.query.days || '7');
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const items = await service.getExpiringItems(req.params.pantryId, req.userId, days);

  res.json({
    status: 'success',
    data: { items },
  });
});

// Get low-stock items
router.get('/:pantryId/low-stock', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const items = await service.getLowStockItems(req.params.pantryId, req.userId);

  res.json({
    status: 'success',
    data: { items },
  });
});

// Suggest items for shopping list
router.get('/:pantryId/suggest-shopping-list', async (req, res) => {
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const suggestions = await service.suggestForShoppingList(req.params.pantryId, req.userId);

  res.json({
    status: 'success',
    data: { suggestions },
  });
});

// Move items from shopping list to pantry
router.post('/:pantryId/items/from-shopping-list', async (req, res) => {
  const data = moveFromShoppingListSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new PantryService(em);

  const items = await service.moveFromShoppingList(
    req.params.pantryId,
    req.userId,
    data.shoppingListId,
    data.itemIds,
    data.storageLocationId,
    data.removeFromList
  );

  res.status(201).json({
    status: 'success',
    data: { items },
  });
});

export default router;
