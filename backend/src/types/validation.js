import { z } from 'zod';
import { SharePermission } from '../entities/ListShare.js';

/**
 * Zod validation schemas for API requests
 */

// Shopping List Schemas
export const createListSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(500).optional(),
  color: z.string().regex(/^#[0-9A-F]{6}$/i).optional(),
  icon: z.string().max(50).optional(),
});

export const updateListSchema = createListSchema.partial();

export const addItemSchema = z.object({
  name: z.string().min(1).max(200),
  quantity: z.number().positive().optional(),
  unit: z.string().max(50).optional(),
  notes: z.string().max(500).optional(),
  category: z.string().max(100).optional(),
  barcode: z.string().max(50).optional(),
  productId: z.string().uuid().optional(),
});

export const updateItemSchema = z.object({
  name: z.string().min(1).max(200).optional(),
  quantity: z.number().positive().optional(),
  unit: z.string().max(50).optional(),
  notes: z.string().max(500).optional(),
  isChecked: z.boolean().optional(),
  category: z.string().max(100).optional(),
  order: z.number().int().nonnegative().optional(),
});

export const shareListSchema = z.object({
  email: z.string().email(),
  permission: z.enum(Object.values(SharePermission)),
});

// User Schemas
export const updateUserSchema = z.object({
  displayName: z.string().min(1).max(100).optional(),
  avatarUrl: z.string().url().optional(),
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
