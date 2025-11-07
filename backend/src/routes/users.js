import { Router } from 'express';
import { requireAuth, extractUserId } from '../middleware/auth.js';
import { UserService } from '../services/UserService.js';
import { getORM } from '../config/database.js';
import { updateUserSchema, searchUsersSchema } from '../types/validation.js';

const router = Router();

// Apply authentication to all routes
router.use(requireAuth);
router.use(extractUserId);

// Get current user profile
router.get('/me', async (req, res) => {
  const em = getORM().em.fork();
  const service = new UserService(em);

  const user = await service.getUserBySupertokensId(req.userId);

  if (!user) {
    return res.status(404).json({
      status: 'error',
      message: 'User not found',
    });
  }

  res.json({
    status: 'success',
    data: { user },
  });
});

// Update current user profile
router.patch('/me', async (req, res) => {
  const data = updateUserSchema.parse(req.body);
  const em = getORM().em.fork();
  const service = new UserService(em);

  const user = await service.updateUser(req.userId, data);

  res.json({
    status: 'success',
    data: { user },
  });
});

// Search users (for sharing lists)
router.get('/search', async (req, res) => {
  const { query, limit } = searchUsersSchema.parse(req.query);
  const em = getORM().em.fork();
  const service = new UserService(em);

  const users = await service.searchUsers(query, limit);

  res.json({
    status: 'success',
    data: { users },
  });
});

export default router;
