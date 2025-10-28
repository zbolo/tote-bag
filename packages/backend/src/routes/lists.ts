import { Router } from 'express';
import { RequestHandler } from 'express';
import { requireAuth, extractUserId, AuthenticatedRequest } from '../middleware/auth';
import { ShoppingListService } from '../services/ShoppingListService';
import { getORM } from '../config/database';
import {
  createListSchema,
  updateListSchema,
  addItemSchema,
  updateItemSchema,
  shareListSchema,
} from '../types/validation';

const router = Router();

// Apply authentication to all routes
router.use(requireAuth);
router.use(extractUserId);

// Get all lists for the authenticated user
router.get('/', (async (req: AuthenticatedRequest, res) => {
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  const lists = await service.getUserLists(req.userId!);

  res.json({
    status: 'success',
    data: { lists },
  });
}) as RequestHandler);

// Create a new shopping list
router.post('/', (async (req: AuthenticatedRequest, res) => {
  const data = createListSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  const list = await service.createList(req.userId!, data);

  res.status(201).json({
    status: 'success',
    data: { list },
  });
}) as RequestHandler);

// Get a specific list
router.get('/:listId', (async (req: AuthenticatedRequest, res) => {
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  const list = await service.getListById(req.params.listId, req.userId!);

  res.json({
    status: 'success',
    data: { list },
  });
}) as RequestHandler);

// Update a shopping list
router.patch('/:listId', (async (req: AuthenticatedRequest, res) => {
  const data = updateListSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  const list = await service.updateList(req.params.listId, req.userId!, data);

  res.json({
    status: 'success',
    data: { list },
  });
}) as RequestHandler);

// Delete a shopping list
router.delete('/:listId', (async (req: AuthenticatedRequest, res) => {
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  await service.deleteList(req.params.listId, req.userId!);

  res.status(204).send();
}) as RequestHandler);

// Add an item to a shopping list
router.post('/:listId/items', (async (req: AuthenticatedRequest, res) => {
  const data = addItemSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  const item = await service.addItem(req.params.listId, req.userId!, data);

  res.status(201).json({
    status: 'success',
    data: { item },
  });
}) as RequestHandler);

// Update an item
router.patch('/:listId/items/:itemId', (async (req: AuthenticatedRequest, res) => {
  const data = updateItemSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  const item = await service.updateItem(req.params.itemId, req.userId!, data);

  res.json({
    status: 'success',
    data: { item },
  });
}) as RequestHandler);

// Delete an item
router.delete('/:listId/items/:itemId', (async (req: AuthenticatedRequest, res) => {
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  await service.deleteItem(req.params.itemId, req.userId!);

  res.status(204).send();
}) as RequestHandler);

// Share a list with another user
router.post('/:listId/share', (async (req: AuthenticatedRequest, res) => {
  const data = shareListSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  const share = await service.shareList(
    req.params.listId,
    req.userId!,
    data.email,
    data.permission
  );

  res.status(201).json({
    status: 'success',
    data: { share },
  });
}) as RequestHandler);

// Unshare a list
router.delete('/:listId/share/:userId', (async (req: AuthenticatedRequest, res) => {
  const em = getORM().em.fork();
  const service = new ShoppingListService(em);

  await service.unshareList(req.params.listId, req.userId!, req.params.userId);

  res.status(204).send();
}) as RequestHandler);

export default router;
