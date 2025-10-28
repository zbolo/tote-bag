import { Entity, PrimaryKey, Property, ManyToOne, Enum } from '@mikro-orm/core';
import { v4 } from 'uuid';
import { User } from './User';
import { ShoppingList } from './ShoppingList';

export enum SharePermission {
  READ = 'read',
  WRITE = 'write',
  ADMIN = 'admin',
}

@Entity()
export class ListShare {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @ManyToOne(() => ShoppingList)
  list!: ShoppingList;

  @ManyToOne(() => User)
  user!: User;

  @Enum(() => SharePermission)
  permission: SharePermission = SharePermission.READ;

  @Property()
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ default: true })
  isActive: boolean = true;
}
