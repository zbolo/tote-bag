import { User } from '../entities/User.js';
import { AppError } from '../middleware/errorHandler.js';

/**
 * User Service
 * Handles user management and operations
 */
export class UserService {
  /**
   * @param {import('@mikro-orm/core').EntityManager} em - MikroORM Entity Manager
   */
  constructor(em) {
    this.em = em;
  }

  /**
   * Create a new user
   * @param {object} data - User data
   * @param {string} data.email - User email
   * @param {string} data.displayName - User display name
   * @param {string} data.supertokensUserId - Supertokens user ID
   * @param {string} [data.avatarUrl] - User avatar URL
   * @returns {Promise<User>}
   */
  async createUser(data) {
    console.log(`[UserService] Creating user: ${data.email}`);

    const existingUser = await this.em.findOne(User, {
      supertokensUserId: data.supertokensUserId,
    });

    if (existingUser) {
      console.log(`[UserService] User already exists: ${existingUser.email}`);
      return existingUser;
    }

    const user = this.em.create(User, data);
    await this.em.persistAndFlush(user);
    console.log(`[UserService] User created successfully: ${user.email}`);
    return user;
  }

  /**
   * Get user by Supertokens ID
   * @param {string} supertokensUserId - Supertokens user ID
   * @returns {Promise<User | null>}
   */
  async getUserBySupertokensId(supertokensUserId) {
    return this.em.findOne(User, { supertokensUserId });
  }

  /**
   * Get user by ID
   * @param {string} id - User ID
   * @returns {Promise<User | null>}
   */
  async getUserById(id) {
    return this.em.findOne(User, { id });
  }

  /**
   * Get user by email
   * @param {string} email - User email
   * @returns {Promise<User | null>}
   */
  async getUserByEmail(email) {
    return this.em.findOne(User, { email });
  }

  /**
   * Update user
   * @param {string} supertokensUserId - Supertokens user ID
   * @param {object} data - Update data
   * @param {string} [data.displayName] - Display name
   * @param {string} [data.avatarUrl] - Avatar URL
   * @returns {Promise<User>}
   */
  async updateUser(supertokensUserId, data) {
    console.log(`[UserService] Updating user: ${supertokensUserId}`);

    const user = await this.em.findOne(User, { supertokensUserId });

    if (!user) {
      throw new AppError(404, 'User not found');
    }

    this.em.assign(user, data);
    await this.em.flush();

    console.log(`[UserService] User updated successfully: ${user.email}`);
    return user;
  }

  /**
   * Search users by query
   * @param {string} query - Search query
   * @param {number} [limit=10] - Maximum results
   * @returns {Promise<User[]>}
   */
  async searchUsers(query, limit = 10) {
    console.log(`[UserService] Searching users: "${query}" (limit: ${limit})`);

    const users = await this.em.find(
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

    console.log(`[UserService] Found ${users.length} users`);
    return users;
  }
}
