import { Entity, PrimaryKey, Property } from '@mikro-orm/core';
import { v4 } from 'uuid';

@Entity()
export class Product {
  @PrimaryKey({ type: 'uuid' })
  id: string = v4();

  @Property({ unique: true })
  barcode!: string;

  @Property()
  name!: string;

  @Property({ nullable: true })
  brand?: string;

  @Property({ nullable: true, type: 'text' })
  description?: string;

  @Property({ nullable: true })
  imageUrl?: string;

  @Property({ nullable: true })
  category?: string;

  @Property({ nullable: true })
  quantity?: string;

  @Property({ type: 'jsonb', nullable: true })
  nutritionData?: Record<string, any>;

  @Property({ default: 'openfoodfacts' })
  source: string = 'openfoodfacts';

  @Property()
  createdAt: Date = new Date();

  @Property({ onUpdate: () => new Date() })
  updatedAt: Date = new Date();

  @Property({ nullable: true })
  lastFetchedAt?: Date;
}
