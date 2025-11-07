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

  console.log(`[GET /me] Fetching user profile for: ${req.userId}`);

  let user = await service.getUserBySupertokensId(req.userId);

  // If user doesn't exist in database, return 404 and log details
  // User needs to sign out and sign up again to trigger the signup hook
  if (!user) {
    console.error(`[GET /me] User not found in database: ${req.userId}`);
    console.error(`[GET /me] This user exists in SuperTokens but not in our database.`);
    console.error(`[GET /me] Solution: Sign out and sign up again to trigger user creation hook.`);

    return res.status(404).json({
      status: 'error',
      message: 'User profile not found. Please sign out and sign up again.',
      code: 'USER_NOT_IN_DATABASE',
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
