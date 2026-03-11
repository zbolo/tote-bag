import { Migration } from '@mikro-orm/migrations';

export class Migration20260311101200 extends Migration {

  async up() {
    // Create pantry table
    this.addSql(`create table "pantry" (
      "id" uuid not null default gen_random_uuid(),
      "name" varchar(255) not null,
      "description" varchar(255) null,
      "color" varchar(255) null,
      "icon" varchar(255) null,
      "owner_id" uuid not null,
      "is_archived" boolean not null default false,
      "created_at" timestamptz not null default now(),
      "updated_at" timestamptz not null default now(),
      constraint "pantry_pkey" primary key ("id")
    );`);

    this.addSql(`alter table "pantry" add constraint "pantry_owner_id_foreign" foreign key ("owner_id") references "user" ("id") on update cascade;`);

    // Create storage_location table
    this.addSql(`create table "storage_location" (
      "id" uuid not null default gen_random_uuid(),
      "pantry_id" uuid not null,
      "name" varchar(255) not null,
      "icon" varchar(255) not null default 'inventory_2',
      "order" int not null default 0,
      "created_at" timestamptz not null default now(),
      "updated_at" timestamptz not null default now(),
      constraint "storage_location_pkey" primary key ("id")
    );`);

    this.addSql(`alter table "storage_location" add constraint "storage_location_pantry_id_foreign" foreign key ("pantry_id") references "pantry" ("id") on update cascade on delete cascade;`);

    // Create pantry_item table
    this.addSql(`create table "pantry_item" (
      "id" uuid not null default gen_random_uuid(),
      "pantry_id" uuid not null,
      "name" varchar(255) not null,
      "quantity" double precision not null default 1,
      "max_quantity" double precision not null default 1,
      "unit" varchar(255) null,
      "category" varchar(255) null,
      "storage_location_id" uuid null,
      "product_id" uuid null,
      "barcode" varchar(255) null,
      "notes" varchar(255) null,
      "expiration_date" timestamptz null,
      "purchase_date" timestamptz null,
      "price" double precision null,
      "low_stock_threshold" double precision not null default 0.25,
      "order" int not null default 0,
      "created_at" timestamptz not null default now(),
      "updated_at" timestamptz not null default now(),
      constraint "pantry_item_pkey" primary key ("id")
    );`);

    this.addSql(`alter table "pantry_item" add constraint "pantry_item_pantry_id_foreign" foreign key ("pantry_id") references "pantry" ("id") on update cascade on delete cascade;`);
    this.addSql(`alter table "pantry_item" add constraint "pantry_item_storage_location_id_foreign" foreign key ("storage_location_id") references "storage_location" ("id") on update cascade on delete set null;`);
    this.addSql(`alter table "pantry_item" add constraint "pantry_item_product_id_foreign" foreign key ("product_id") references "product" ("id") on update cascade on delete set null;`);

    // Create pantry_share table
    this.addSql(`create table "pantry_share" (
      "id" uuid not null default gen_random_uuid(),
      "pantry_id" uuid not null,
      "user_id" uuid not null,
      "permission" text check ("permission" in ('read', 'write', 'admin')) not null default 'read',
      "is_active" boolean not null default true,
      "created_at" timestamptz not null default now(),
      "updated_at" timestamptz not null default now(),
      constraint "pantry_share_pkey" primary key ("id")
    );`);

    this.addSql(`alter table "pantry_share" add constraint "pantry_share_pantry_id_foreign" foreign key ("pantry_id") references "pantry" ("id") on update cascade on delete cascade;`);
    this.addSql(`alter table "pantry_share" add constraint "pantry_share_user_id_foreign" foreign key ("user_id") references "user" ("id") on update cascade;`);
  }

  async down() {
    this.addSql(`drop table if exists "pantry_share" cascade;`);
    this.addSql(`drop table if exists "pantry_item" cascade;`);
    this.addSql(`drop table if exists "storage_location" cascade;`);
    this.addSql(`drop table if exists "pantry" cascade;`);
  }
}
