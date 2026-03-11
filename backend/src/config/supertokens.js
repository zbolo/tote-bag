import supertokens from 'supertokens-node';
import Session from 'supertokens-node/recipe/session/index.js';
import EmailPassword from 'supertokens-node/recipe/emailpassword/index.js';
import Dashboard from 'supertokens-node/recipe/dashboard/index.js';
import UserMetadata from 'supertokens-node/recipe/usermetadata/index.js';

/**
 * Initialize Supertokens authentication
 * Sign-up is disabled - only admins can create users via SuperTokens Dashboard
 * @returns {void}
 */
export function initSupertokens() {
  console.log('[SuperTokens] Initializing authentication...');

  supertokens.init({
    framework: 'express',
    supertokens: {
      connectionURI: process.env.SUPERTOKENS_CONNECTION_URI || 'http://localhost:3567',
      apiKey: process.env.SUPERTOKENS_API_KEY,
    },
    appInfo: {
      appName: 'Tote Bag',
      apiDomain: process.env.API_DOMAIN || 'http://localhost:3000',
      websiteDomain: process.env.WEBSITE_DOMAIN || 'http://localhost:3000',
      apiBasePath: '/auth',
      websiteBasePath: '/auth',
    },
    recipeList: [
      Dashboard.init({
        apiKey: process.env.SUPERTOKENS_API_KEY || 'supertokens-dashboard-key',
      }),
      EmailPassword.init({
        signUpFeature: {
          disableDefaultImplementation: true,
        },
        override: {
          apis: (originalImplementation) => {
            return {
              ...originalImplementation,
              signUpPOST: undefined,
            };
          },
        },
      }),
      Session.init({
        getTokenTransferMethod: () => 'header',
      }),
      UserMetadata.init(),
    ],
  });

  console.log('[SuperTokens] Initialization complete (signup disabled, header-based sessions)');
}
