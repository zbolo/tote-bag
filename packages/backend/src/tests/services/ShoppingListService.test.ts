import { ShoppingListService } from '../../services/ShoppingListService';
import { UserService } from '../../services/UserService';
import { orm } from '../setup';
import { SharePermission } from '../../entities/ListShare';

describe('ShoppingListService', () => {
  let listService: ShoppingListService;
  let userService: UserService;
  let testUser1: any;
  let testUser2: any;

  beforeEach(async () => {
    const em = orm.em.fork();
    listService = new ShoppingListService(em);
    userService = new UserService(em);

    // Create test users
    testUser1 = await userService.createUser({
      email: 'user1@test.com',
      displayName: 'User 1',
      supertokensUserId: 'st-user-1',
    });

    testUser2 = await userService.createUser({
      email: 'user2@test.com',
      displayName: 'User 2',
      supertokensUserId: 'st-user-2',
    });
  });

  describe('createList', () => {
    it('should create a new shopping list', async () => {
      const listData = {
        name: 'Groceries',
        description: 'Weekly groceries',
        color: '#FF5733',
      };

      const list = await listService.createList('st-user-1', listData);

      expect(list).toBeDefined();
      expect(list.name).toBe('Groceries');
      expect(list.description).toBe('Weekly groceries');
      expect(list.color).toBe('#FF5733');
      expect(list.owner.id).toBe(testUser1.id);
    });

    it('should throw error if user not found', async () => {
      await expect(
        listService.createList('non-existent', { name: 'Test' })
      ).rejects.toThrow('User not found');
    });
  });

  describe('getUserLists', () => {
    it('should return all lists owned by user', async () => {
      await listService.createList('st-user-1', { name: 'List 1' });
      await listService.createList('st-user-1', { name: 'List 2' });

      const lists = await listService.getUserLists('st-user-1');

      expect(lists).toHaveLength(2);
      expect(lists.map(l => l.name)).toContain('List 1');
      expect(lists.map(l => l.name)).toContain('List 2');
    });

    it('should return shared lists', async () => {
      const list = await listService.createList('st-user-1', { name: 'Shared List' });

      await listService.shareList(
        list.id,
        'st-user-1',
        'user2@test.com',
        SharePermission.WRITE
      );

      const user2Lists = await listService.getUserLists('st-user-2');

      expect(user2Lists).toHaveLength(1);
      expect(user2Lists[0].name).toBe('Shared List');
    });
  });

  describe('addItem', () => {
    it('should add item to shopping list', async () => {
      const list = await listService.createList('st-user-1', { name: 'Test List' });

      const item = await listService.addItem(list.id, 'st-user-1', {
        name: 'Milk',
        quantity: 2,
        unit: 'liters',
      });

      expect(item).toBeDefined();
      expect(item.name).toBe('Milk');
      expect(item.quantity).toBe(2);
      expect(item.unit).toBe('liters');
    });

    it('should throw error if user does not have write permission', async () => {
      const list = await listService.createList('st-user-1', { name: 'Test List' });

      await listService.shareList(
        list.id,
        'st-user-1',
        'user2@test.com',
        SharePermission.READ
      );

      await expect(
        listService.addItem(list.id, 'st-user-2', { name: 'Milk' })
      ).rejects.toThrow('Write permission required');
    });
  });

  describe('updateItem', () => {
    it('should update item properties', async () => {
      const list = await listService.createList('st-user-1', { name: 'Test List' });
      const item = await listService.addItem(list.id, 'st-user-1', {
        name: 'Milk',
        quantity: 1,
      });

      const updatedItem = await listService.updateItem(item.id, 'st-user-1', {
        quantity: 3,
        isChecked: true,
      });

      expect(updatedItem.quantity).toBe(3);
      expect(updatedItem.isChecked).toBe(true);
      expect(updatedItem.checkedAt).toBeDefined();
    });
  });

  describe('shareList', () => {
    it('should share list with another user', async () => {
      const list = await listService.createList('st-user-1', { name: 'Test List' });

      const share = await listService.shareList(
        list.id,
        'st-user-1',
        'user2@test.com',
        SharePermission.WRITE
      );

      expect(share).toBeDefined();
      expect(share.permission).toBe(SharePermission.WRITE);
      expect(share.user.id).toBe(testUser2.id);
    });

    it('should throw error if non-owner tries to share', async () => {
      const list = await listService.createList('st-user-1', { name: 'Test List' });

      await expect(
        listService.shareList(list.id, 'st-user-2', 'test@test.com', SharePermission.READ)
      ).rejects.toThrow();
    });
  });

  describe('deleteList', () => {
    it('should delete list if user is owner', async () => {
      const list = await listService.createList('st-user-1', { name: 'Test List' });

      await listService.deleteList(list.id, 'st-user-1');

      await expect(
        listService.getListById(list.id, 'st-user-1')
      ).rejects.toThrow('Shopping list not found');
    });

    it('should throw error if non-owner tries to delete', async () => {
      const list = await listService.createList('st-user-1', { name: 'Test List' });

      await expect(
        listService.deleteList(list.id, 'st-user-2')
      ).rejects.toThrow();
    });
  });
});
