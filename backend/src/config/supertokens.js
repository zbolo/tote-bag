import supertokens from 'supertokens-node';
import Session from 'supertokens-node/recipe/session/index.js';
import EmailPassword from 'supertokens-node/recipe/emailpassword/index.js';
import Dashboard from 'supertokens-node/recipe/dashboard/index.js';

/**
 * Initialize Supertokens authentication
 * @returns {void}
 */
export function initSupertokens() {
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
      EmailPassword.init({
        signUpFeature: {
          formFields: [
            {
              id: 'displayName',
              optional: false,
            },
          ],
        },
      }),
      Session.init({
        getTokenTransferMethod: () => 'header',
      }),
      Dashboard.init({
        // Uncomment to enable dashboard authentication
        // admins: [
        //   {
        //     email: "admin@example.com",
        //     password: "admin123",
        //   },
        // ],
      }),
    ],
  });
}
