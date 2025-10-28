import { Entity, PrimaryKey, Property, OneToMany, Collection } from '@mikro-orm/core';
import { v4 } from 'uuid';
import { ShoppingList } from './ShoppingList';
import { ListShare } from './ListShare';

@Entity()
export class User {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @Property({ unique: true })
  email!: string;

  @Property()
  displayName!: string;

  @Property({ nullable: true })
  avatarUrl?: string;

  @Property()
  supertokensUserId!: string;

  @OneToMany(() => ShoppingList, list => list.owner)
  ownedLists = new Collection<ShoppingList>(this);

  @OneToMany(() => ListShare, share => share.user)
  sharedLists = new Collection<ListShare>(this);

  @Property()
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ default: true })
  isActive: boolean = true;
}
