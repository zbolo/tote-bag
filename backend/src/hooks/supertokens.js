import { UserService } from '../services/UserService.js';
import { getORM } from '../config/database.js';

/**
 * Create a user record in our database after signup.
 * Called automatically by the EmailPassword override on successful signup,
 * and also from the admin sync endpoint.
 * @param {object} user - SuperTokens user object
 * @param {string} user.id - SuperTokens user ID
 * @param {string} user.email - User email
 * @param {Array<{id: string, value: string}>|string} [formFieldsOrDisplayName] - Form fields array or display name string
 * @returns {Promise<void>}
 */
export async function createUserAfterSignup(user, formFieldsOrDisplayName) {
  // SuperTokens v24: email is in user.emails[] array, not user.email
  const email = user.emails?.[0]
    ?? user.loginMethods?.find(m => m.recipeId === 'emailpassword')?.email
    ?? user.email;

  console.log('[SuperTokens Hook] Creating user in database:', email);

  let displayName;
  if (Array.isArray(formFieldsOrDisplayName)) {
    const field = formFieldsOrDisplayName.find(f => f.id === 'displayName');
    displayName = field?.value || email.split('@')[0];
  } else {
    displayName = formFieldsOrDisplayName || email.split('@')[0];
  }

  try {
    const em = getORM().em.fork();
    const userService = new UserService(em);

    await userService.createUser({
      email,
      displayName,
      supertokensUserId: user.id,
    });

    console.log('[SuperTokens Hook] User created successfully in database:', user.email);
  } catch (error) {
    console.error('[SuperTokens Hook] Error creating user in database:', error);
    // Don't throw - allow signup to complete even if DB creation fails
  }
}

/**
 * Get the SuperTokens EmailPassword recipe override configuration.
 * Hooks into signUpPOST to auto-create users in the database on signup.
 * @returns {object} EmailPassword recipe override configuration
 */
export function getEmailPasswordOverride() {
  return {
    apis: (originalImplementation) => {
      return {
        ...originalImplementation,
        signUpPOST: async function (input) {
          if (originalImplementation.signUpPOST === undefined) {
            throw Error('Should never come here');
          }

          console.log('[SuperTokens Hook] Processing signup...');
          const response = await originalImplementation.signUpPOST(input);

          if (response.status === 'OK') {
            console.log('[SuperTokens Hook] Signup successful, creating user in database...');
            await createUserAfterSignup(response.user, input.formFields);
          } else {
            console.log('[SuperTokens Hook] Signup failed:', response.status);
          }

          return response;
        },
      };
    },
  };
}
