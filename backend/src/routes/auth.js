import { Router } from 'express';
import { verifySession } from 'supertokens-node/recipe/session/framework/express/index.js';
import EmailPassword from 'supertokens-node/recipe/emailpassword/index.js';
import supertokens from 'supertokens-node';
import { z } from 'zod';

const router = Router();

/**
 * Zod schema for change-password request
 */
const changePasswordSchema = z.object({
  currentPassword: z.string().min(1, 'Current password is required'),
  newPassword: z.string().min(8, 'New password must be at least 8 characters'),
});

/**
 * Change password for current user
 * POST /auth/change-password
 * Body: { currentPassword: string, newPassword: string }
 */
router.post('/change-password', verifySession(), async (req, res) => {
  const userId = req.session.getUserId();
  console.log(`[Auth] Password change requested by user ${userId}`);

  try {
    const { currentPassword, newPassword } = changePasswordSchema.parse(req.body);

    // Get user email for verification
    const userInfo = await supertokens.getUser(userId);
    if (!userInfo) {
      console.log(`[Auth] User ${userId} not found in SuperTokens`);
      return res.status(404).json({
        status: 'error',
        message: 'User not found',
      });
    }

    let email = userInfo.emails?.[0];
    if (!email && Array.isArray(userInfo.loginMethods)) {
      const emailPasswordMethod = userInfo.loginMethods.find(method => method.recipeId === 'emailpassword');
      email = emailPasswordMethod?.email;
    }

    if (!email) {
      console.log(`[Auth] No email found for user ${userId}`);
      return res.status(400).json({
        status: 'error',
        message: 'User email not found',
      });
    }

    // Verify current password by attempting sign-in
    console.log(`[Auth] Verifying current password for ${email}`);
    const signInResult = await EmailPassword.signIn('public', email, currentPassword);

    if (signInResult.status !== 'OK') {
      console.log(`[Auth] Current password verification failed: ${signInResult.status}`);
      return res.status(401).json({
        status: 'error',
        message: 'Current password is incorrect',
      });
    }

    // Update password
    console.log(`[Auth] Updating password for user ${userId}`);
    const updateResult = await EmailPassword.updateEmailOrPassword({
      recipeUserId: signInResult.recipeUserId,
      password: newPassword,
    });

    if (updateResult.status !== 'OK') {
      console.log(`[Auth] Password update failed: ${updateResult.status}`);
      return res.status(400).json({
        status: 'error',
        message: 'Failed to update password',
        details: updateResult.status,
      });
    }

    console.log(`[Auth] Password updated successfully for user ${userId}`);
    res.json({
      status: 'success',
      message: 'Password updated successfully',
    });
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.log(`[Auth] Validation error:`, error.errors);
      return res.status(400).json({
        status: 'error',
        message: 'Validation error',
        errors: error.errors,
      });
    }
    console.error('[Auth] Change password error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
    });
  }
});

/**
 * Health check for auth service
 * GET /auth/health
 */
router.get('/health', (_req, res) => {
  res.json({
    status: 'ok',
    service: 'auth',
    timestamp: new Date().toISOString(),
  });
});

export default router;
