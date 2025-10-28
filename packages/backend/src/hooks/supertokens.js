import EmailPassword from 'supertokens-node/recipe/emailpassword';
import { UserService } from '../services/UserService.js';
import { getORM } from '../config/database.js';

// This hook is called after a user signs up via Supertokens
export async function createUserAfterSignup(
  user: {
    id: string;
    email: string;
  },
  formFields: Array<{ id: string; value: string }>
) {
  const displayNameField = formFields.find(field => field.id === 'displayName');
  const displayName = displayNameField?.value || user.email.split('@')[0];

  const em = getORM().em.fork();
  const userService = new UserService(em);

  await userService.createUser({
    email: user.email,
    displayName,
    supertokensUserId: user.id,
  });
}

// Register the hook with EmailPassword recipe
EmailPassword.init({
  override: {
    apis: (originalImplementation) => {
      return {
        ...originalImplementation,
        signUpPOST: async function (input) {
          if (originalImplementation.signUpPOST === undefined) {
            throw Error('Should never come here');
          }

          const response = await originalImplementation.signUpPOST(input);

          if (response.status === 'OK') {
            // Create user in our database
            await createUserAfterSignup(response.user, input.formFields);
          }

          return response;
        },
      };
    },
  },
});
