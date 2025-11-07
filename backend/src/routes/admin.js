import { Router } from 'express';
import supertokens from 'supertokens-node';
import { UserService } from '../services/UserService.js';
import { getORM } from '../config/database.js';

const router = Router();

/**
 * Admin endpoint to sync a SuperTokens user to the database
 * POST /admin/sync-user/:userId
 *
 * This is useful for fixing users who were created in SuperTokens
 * before the signup hook was implemented
 */
router.post('/sync-user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    console.log(`[Admin] Syncing user from SuperTokens: ${userId}`);

    const em = getORM().em.fork();
    const userService = new UserService(em);

    // Check if user already exists
    const existingUser = await userService.getUserBySupertokensId(userId);
    if (existingUser) {
      return res.json({
        status: 'success',
        message: 'User already exists in database',
        data: { user: existingUser },
      });
    }

    // Get user from SuperTokens
    const stUser = await supertokens.getUser(userId);

    if (!stUser) {
      console.error(`[Admin] User not found in SuperTokens: ${userId}`);
      return res.status(404).json({
        status: 'error',
        message: 'User not found in SuperTokens',
      });
    }

    console.log(`[Admin] SuperTokens user found:`, JSON.stringify(stUser, null, 2));

    // Find email from login methods
    const emailLoginMethod = stUser.loginMethods.find(
      lm => lm.recipeId === 'emailpassword' && lm.email
    );

    if (!emailLoginMethod) {
      console.error(`[Admin] No email found for user: ${userId}`);
      return res.status(400).json({
        status: 'error',
        message: 'No email found for this user',
      });
    }

    // Create user in database
    const user = await userService.createUser({
      email: emailLoginMethod.email,
      displayName: emailLoginMethod.email.split('@')[0],
      supertokensUserId: userId,
    });

    console.log(`[Admin] User synced successfully: ${user.email}`);

    res.json({
      status: 'success',
      message: 'User synced successfully',
      data: { user },
    });
  } catch (error) {
    console.error(`[Admin] Error syncing user:`, error);
    res.status(500).json({
      status: 'error',
      message: 'Failed to sync user',
      error: error.message,
    });
  }
});

export default router;
