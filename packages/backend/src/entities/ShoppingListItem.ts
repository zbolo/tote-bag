import { Entity, PrimaryKey, Property, ManyToOne } from '@mikro-orm/core';
import { v4 } from 'uuid';
import { ShoppingList } from './ShoppingList';
import { Product } from './Product';

@Entity()
export class ShoppingListItem {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @ManyToOne(() => ShoppingList)
  list!: ShoppingList;

  @Property()
  name!: string;

  @Property({ default: 1 })
  quantity: number = 1;

  @Property({ nullable: true })
  unit?: string;

  @Property({ nullable: true })
  notes?: string;

  @Property({ default: false })
  isChecked: boolean = false;

  @Property({ nullable: true })
  category?: string;

  @ManyToOne(() => Product, { nullable: true })
  product?: Product;

  @Property({ nullable: true })
  barcode?: string;

  @Property()
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ nullable: true })
  checkedAt?: Date;

  @Property()
  order: number = 0;
}
