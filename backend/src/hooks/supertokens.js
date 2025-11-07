import { UserService } from '../services/UserService.js';
import { getORM } from '../config/database.js';

/**
 * This hook is called after a user signs up via SuperTokens
 * It creates a corresponding user record in our database
 * @param {object} user - SuperTokens user object
 * @param {string} user.id - SuperTokens user ID
 * @param {string} user.email - User email
 * @param {Array<{id: string, value: string}>} formFields - Sign up form fields
 * @returns {Promise<void>}
 */
export async function createUserAfterSignup(user, formFields) {
  console.log('[SuperTokens Hook] Creating user in database after signup:', user.email);

  try {
    const displayNameField = formFields.find(field => field.id === 'displayName');
    const displayName = displayNameField?.value || user.email.split('@')[0];

    const em = getORM().em.fork();
    const userService = new UserService(em);

    await userService.createUser({
      email: user.email,
      displayName,
      supertokensUserId: user.id,
    });

    console.log('[SuperTokens Hook] User created successfully in database:', user.email);
  } catch (error) {
    console.error('[SuperTokens Hook] Error creating user in database:', error);
    // Don't throw - allow signup to complete even if DB creation fails
    // User can be created later via /me endpoint or other means
  }
}

/**
 * Get the SuperTokens EmailPassword recipe override configuration
 * This integrates our user creation hook with SuperTokens signup
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
            // Create user in our database
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
