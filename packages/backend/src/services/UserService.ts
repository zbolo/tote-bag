import { EntityManager } from '@mikro-orm/core';
import { User } from '../entities/User';
import { AppError } from '../middleware/errorHandler';

export class UserService {
  constructor(private em: EntityManager) {}

  async createUser(data: {
    email: string;
    displayName: string;
    supertokensUserId: string;
    avatarUrl?: string;
  }): Promise<User> {
    const existingUser = await this.em.findOne(User, {
      supertokensUserId: data.supertokensUserId,
    });

    if (existingUser) {
      return existingUser;
    }

    const user = this.em.create(User, data);
    await this.em.persistAndFlush(user);
    return user;
  }

  async getUserBySupertokensId(supertokensUserId: string): Promise<User | null> {
    return this.em.findOne(User, { supertokensUserId });
  }

  async getUserById(id: string): Promise<User | null> {
    return this.em.findOne(User, { id });
  }

  async getUserByEmail(email: string): Promise<User | null> {
    return this.em.findOne(User, { email });
  }

  async updateUser(
    supertokensUserId: string,
    data: Partial<{
      displayName: string;
      avatarUrl: string;
    }>
  ): Promise<User> {
    const user = await this.em.findOne(User, { supertokensUserId });

    if (!user) {
      throw new AppError(404, 'User not found');
    }

    this.em.assign(user, data);
    await this.em.flush();

    return user;
  }

  async searchUsers(query: string, limit: number = 10): Promise<User[]> {
    return this.em.find(
      User,
      {
        $or: [
          { email: { $ilike: `%${query}%` } },
          { displayName: { $ilike: `%${query}%` } },
        ],
        isActive: true,
      },
      { limit }
    );
  }
}
