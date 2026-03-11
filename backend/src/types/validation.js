import { z } from 'zod';
import { SharePermission } from '../entities/ListShare.js';

/**
 * Zod validation schemas for API requests
 */

// Shopping List Schemas
export const createListSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional().nullable(),
  color: z.string().regex(/^#[0-9A-F]{6}$/i).optional().nullable(),
  icon: z.string().max(50).optional().nullable(),
});

export const updateListSchema = createListSchema.partial();

export const addItemSchema = z.object({
  name: z.string().min(1).max(200),
  quantity: z.number().positive().optional().nullable(),
  unit: z.string().max(50).optional().nullable(),
  notes: z.string().max(500).optional().nullable(),
  category: z.string().max(100).optional().nullable(),
  barcode: z.string().max(50).optional().nullable(),
  productId: z.string().uuid().optional().nullable(),
});

export const updateItemSchema = z.object({
  name: z.string().min(1).max(200).optional(),
  quantity: z.number().positive().optional().nullable(),
  unit: z.string().max(50).optional().nullable(),
  notes: z.string().max(500).optional().nullable(),
  isChecked: z.boolean().optional(),
  category: z.string().max(100).optional().nullable(),
  order: z.number().int().nonnegative().optional(),
});

export const shareListSchema = z.object({
  email: z.string().email(),
  permission: z.enum(Object.values(SharePermission)),
});

// User Schemas
export const updateUserSchema = z.object({
  displayName: z.string().min(1).max(100).optional(),
  avatarUrl: z.string().url().optional().nullable(),
});

export const searchUsersSchema = z.object({
  query: z.string().min(1),
  limit: z.number().int().positive().max(50).optional(),
});

// Product Schemas
export const searchProductsSchema = z.object({
  query: z.string().min(1),
  limit: z.number().int().positive().max(50).optional(),
});

export const createProductSchema = z.object({
  name: z.string().min(1).max(200),
  barcode: z.string().min(1).max(50),
  brand: z.string().max(200).optional().nullable(),
  category: z.string().max(100).optional().nullable(),
  quantity: z.string().max(100).optional().nullable(),
});

// Pantry Schemas
export const createPantrySchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional().nullable(),
  color: z.string().regex(/^#[0-9A-F]{6}$/i).optional().nullable(),
  icon: z.string().max(50).optional().nullable(),
});

export const updatePantrySchema = createPantrySchema.partial();

export const addPantryItemSchema = z.object({
  name: z.string().min(1).max(200),
  quantity: z.number().positive().optional().nullable(),
  maxQuantity: z.number().positive().optional().nullable(),
  unit: z.string().max(50).optional().nullable(),
  category: z.string().max(100).optional().nullable(),
  storageLocationId: z.string().uuid().optional().nullable(),
  expirationDate: z.string().datetime().optional().nullable(),
  purchaseDate: z.string().datetime().optional().nullable(),
  price: z.number().nonnegative().optional().nullable(),
  barcode: z.string().max(50).optional().nullable(),
  productId: z.string().uuid().optional().nullable(),
  notes: z.string().max(500).optional().nullable(),
  lowStockThreshold: z.number().min(0).max(1).optional().nullable(),
});

export const updatePantryItemSchema = z.object({
  name: z.string().min(1).max(200).optional(),
  quantity: z.number().nonnegative().optional().nullable(),
  maxQuantity: z.number().positive().optional().nullable(),
  unit: z.string().max(50).optional().nullable(),
  category: z.string().max(100).optional().nullable(),
  storageLocationId: z.string().uuid().optional().nullable(),
  expirationDate: z.string().datetime().optional().nullable(),
  purchaseDate: z.string().datetime().optional().nullable(),
  price: z.number().nonnegative().optional().nullable(),
  notes: z.string().max(500).optional().nullable(),
  lowStockThreshold: z.number().min(0).max(1).optional().nullable(),
  order: z.number().int().nonnegative().optional(),
});

export const sharePantrySchema = z.object({
  email: z.string().email(),
  permission: z.enum(Object.values(SharePermission)),
});

export const moveFromShoppingListSchema = z.object({
  shoppingListId: z.string().uuid(),
  itemIds: z.array(z.string().uuid()).min(1),
  storageLocationId: z.string().uuid().optional().nullable(),
  removeFromList: z.boolean().optional(),
});

export const createStorageLocationSchema = z.object({
  name: z.string().min(1).max(100),
  icon: z.string().max(50).optional(),
});

export const updateStorageLocationSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  icon: z.string().max(50).optional(),
  order: z.number().int().nonnegative().optional(),
});
