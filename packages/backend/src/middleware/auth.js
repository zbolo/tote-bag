import { verifySession } from 'supertokens-node/recipe/session/framework/express/index.js';

/**
 * Middleware to require authentication
 */
export const requireAuth = verifySession();

/**
 * Middleware to extract user ID from session
 * @param {import('express').Request} req
 * @param {import('express').Response} _res
 * @param {import('express').NextFunction} next
 */
export const extractUserId = (req, _res, next) => {
  if (req.session) {
    req.userId = req.session.getUserId();
  }
  next();
};
