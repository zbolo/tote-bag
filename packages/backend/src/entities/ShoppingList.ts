import { Entity, PrimaryKey, Property, ManyToOne, OneToMany, Collection } from '@mikro-orm/core';
import { v4 } from 'uuid';
import { User } from './User';
import { ShoppingListItem } from './ShoppingListItem';
import { ListShare } from './ListShare';

@Entity()
export class ShoppingList {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @Property()
  name!: string;

  @Property({ nullable: true })
  description?: string;

  @Property({ nullable: true })
  color?: string;

  @Property({ nullable: true })
  icon?: string;

  @ManyToOne(() => User)
  owner!: User;

  @OneToMany(() => ShoppingListItem, item => item.list, { orphanRemoval: true })
  items = new Collection<ShoppingListItem>(this);

  @OneToMany(() => ListShare, share => share.list, { orphanRemoval: true })
  shares = new Collection<ListShare>(this);

  @Property()
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ default: false })
  isArchived: boolean = false;
}
