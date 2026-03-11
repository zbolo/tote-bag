import { UserService } from '../services/UserService.js';
import { getORM } from '../config/database.js';

/**
 * Create a user record in our database after admin creates them in SuperTokens Dashboard.
 * This is called from the admin sync endpoint.
 * @param {object} user - SuperTokens user object
 * @param {string} user.id - SuperTokens user ID
 * @param {string} user.email - User email
 * @param {string} [displayName] - Optional display name
 * @returns {Promise<void>}
 */
export async function createUserAfterSignup(user, displayName) {
  console.log('[SuperTokens Hook] Creating user in database:', user.email);

  try {
    const em = getORM().em.fork();
    const userService = new UserService(em);

    await userService.createUser({
      email: user.email,
      displayName: displayName || user.email.split('@')[0],
      supertokensUserId: user.id,
    });

    console.log('[SuperTokens Hook] User created successfully in database:', user.email);
  } catch (error) {
    console.error('[SuperTokens Hook] Error creating user in database:', error);
    throw error;
  }
}

// NOTE: Sign-up is currently disabled. The getEmailPasswordOverride function
// has been removed. When sign-up is re-enabled, add the override back to
// config/supertokens.js to auto-create users in the database on signup.
