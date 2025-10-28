import { Request, Response, NextFunction } from 'express';
import { verifySession } from 'supertokens-node/recipe/session/framework/express';
import { SessionRequest } from 'supertokens-node/framework/express';

export const requireAuth = verifySession();

export interface AuthenticatedRequest extends SessionRequest {
  userId?: string;
}

export const extractUserId = (req: Request, _res: Response, next: NextFunction) => {
  const sessionReq = req as AuthenticatedRequest;
  if (sessionReq.session) {
    sessionReq.userId = sessionReq.session.getUserId();
  }
  next();
};
