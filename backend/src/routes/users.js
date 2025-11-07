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

  // If user doesn't exist in database, create them automatically
  // This handles cases where signup hook failed or users existed before hook was added
  if (!user) {
    console.log(`[GET /me] User not found in database, fetching from SuperTokens...`);

    try {
      // Import SuperTokens to get user info
      const { default: supertokens } = await import('supertokens-node');
      const EmailPassword = (await import('supertokens-node/recipe/emailpassword/index.js')).default;

      // Get user info from SuperTokens
      const stUser = await EmailPassword.getUserById(req.userId);

      if (!stUser) {
        console.error(`[GET /me] User not found in SuperTokens: ${req.userId}`);
        return res.status(404).json({
          status: 'error',
          message: 'User not found',
        });
      }

      console.log(`[GET /me] Creating user in database: ${stUser.email}`);

      // Create user in database
      user = await service.createUser({
        email: stUser.email,
        displayName: stUser.email.split('@')[0],
        supertokensUserId: stUser.id,
      });

      console.log(`[GET /me] User created successfully: ${user.email}`);
    } catch (error) {
      console.error(`[GET /me] Error creating user:`, error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to create user profile',
      });
    }
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
