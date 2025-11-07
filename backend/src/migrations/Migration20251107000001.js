import { Migration } from '@mikro-orm/migrations';

export class Migration20251107000001 extends Migration {
  async up() {
    // Create users table
    this.addSql(`
      CREATE TABLE IF NOT EXISTS "user" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "supertokens_user_id" VARCHAR(255) NOT NULL UNIQUE,
        "email" VARCHAR(255) NOT NULL UNIQUE,
        "display_name" VARCHAR(255) NOT NULL,
        "avatar_url" TEXT,
        "is_active" BOOLEAN NOT NULL DEFAULT true,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    this.addSql(`CREATE INDEX IF NOT EXISTS "user_supertokens_user_id_index" ON "user" ("supertokens_user_id");`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "user_email_index" ON "user" ("email");`);

    // Create products table
    this.addSql(`
      CREATE TABLE IF NOT EXISTS "product" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "barcode" VARCHAR(255) NOT NULL UNIQUE,
        "name" VARCHAR(255) NOT NULL,
        "brand" VARCHAR(255),
        "description" TEXT,
        "image_url" TEXT,
        "category" VARCHAR(255),
        "quantity" VARCHAR(255),
        "nutrition_data" JSONB,
        "source" VARCHAR(50) NOT NULL DEFAULT 'manual',
        "last_fetched_at" TIMESTAMPTZ,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW()
      );
    `);

    this.addSql(`CREATE INDEX IF NOT EXISTS "product_barcode_index" ON "product" ("barcode");`);

    // Create shopping_list table
    this.addSql(`
      CREATE TABLE IF NOT EXISTS "shopping_list" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" VARCHAR(255) NOT NULL,
        "description" TEXT,
        "color" VARCHAR(50),
        "icon" VARCHAR(50),
        "is_archived" BOOLEAN NOT NULL DEFAULT false,
        "owner_id" UUID NOT NULL,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        CONSTRAINT "shopping_list_owner_id_foreign" FOREIGN KEY ("owner_id") REFERENCES "user" ("id") ON DELETE CASCADE
      );
    `);

    this.addSql(`CREATE INDEX IF NOT EXISTS "shopping_list_owner_id_index" ON "shopping_list" ("owner_id");`);

    // Create shopping_list_item table
    this.addSql(`
      CREATE TABLE IF NOT EXISTS "shopping_list_item" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "name" VARCHAR(255) NOT NULL,
        "quantity" INTEGER NOT NULL DEFAULT 1,
        "unit" VARCHAR(50),
        "notes" TEXT,
        "is_checked" BOOLEAN NOT NULL DEFAULT false,
        "checked_at" TIMESTAMPTZ,
        "category" VARCHAR(255),
        "order" INTEGER NOT NULL DEFAULT 0,
        "barcode" VARCHAR(255),
        "list_id" UUID NOT NULL,
        "product_id" UUID,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        CONSTRAINT "shopping_list_item_list_id_foreign" FOREIGN KEY ("list_id") REFERENCES "shopping_list" ("id") ON DELETE CASCADE,
        CONSTRAINT "shopping_list_item_product_id_foreign" FOREIGN KEY ("product_id") REFERENCES "product" ("id") ON DELETE SET NULL
      );
    `);

    this.addSql(`CREATE INDEX IF NOT EXISTS "shopping_list_item_list_id_index" ON "shopping_list_item" ("list_id");`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "shopping_list_item_product_id_index" ON "shopping_list_item" ("product_id");`);

    // Create list_share table
    this.addSql(`
      CREATE TABLE IF NOT EXISTS "list_share" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "permission" VARCHAR(50) NOT NULL DEFAULT 'read',
        "is_active" BOOLEAN NOT NULL DEFAULT true,
        "list_id" UUID NOT NULL,
        "user_id" UUID NOT NULL,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        CONSTRAINT "list_share_list_id_foreign" FOREIGN KEY ("list_id") REFERENCES "shopping_list" ("id") ON DELETE CASCADE,
        CONSTRAINT "list_share_user_id_foreign" FOREIGN KEY ("user_id") REFERENCES "user" ("id") ON DELETE CASCADE,
        CONSTRAINT "list_share_unique" UNIQUE ("list_id", "user_id")
      );
    `);

    this.addSql(`CREATE INDEX IF NOT EXISTS "list_share_list_id_index" ON "list_share" ("list_id");`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "list_share_user_id_index" ON "list_share" ("user_id");`);

    // Create user_favorite_product table
    this.addSql(`
      CREATE TABLE IF NOT EXISTS "user_favorite_product" (
        "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        "user_id" UUID NOT NULL,
        "product_id" UUID NOT NULL,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        CONSTRAINT "user_favorite_product_user_id_foreign" FOREIGN KEY ("user_id") REFERENCES "user" ("id") ON DELETE CASCADE,
        CONSTRAINT "user_favorite_product_product_id_foreign" FOREIGN KEY ("product_id") REFERENCES "product" ("id") ON DELETE CASCADE,
        CONSTRAINT "user_favorite_product_unique" UNIQUE ("user_id", "product_id")
      );
    `);

    this.addSql(`CREATE INDEX IF NOT EXISTS "user_favorite_product_user_id_index" ON "user_favorite_product" ("user_id");`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "user_favorite_product_product_id_index" ON "user_favorite_product" ("product_id");`);
  }

  async down() {
    this.addSql(`DROP TABLE IF EXISTS "user_favorite_product" CASCADE;`);
    this.addSql(`DROP TABLE IF EXISTS "list_share" CASCADE;`);
    this.addSql(`DROP TABLE IF EXISTS "shopping_list_item" CASCADE;`);
    this.addSql(`DROP TABLE IF EXISTS "shopping_list" CASCADE;`);
    this.addSql(`DROP TABLE IF EXISTS "product" CASCADE;`);
    this.addSql(`DROP TABLE IF EXISTS "user" CASCADE;`);
  }
}
