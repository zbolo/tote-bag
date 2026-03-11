import { Migration } from '@mikro-orm/migrations';

export class Migration20260311_add_content_quantity extends Migration {
  async up() {
    this.addSql(`alter table "pantry_item" add column if not exists "content_quantity" double precision null;`);
    this.addSql(`alter table "pantry_item" add column if not exists "content_max_quantity" double precision null;`);
    this.addSql(`alter table "pantry_item" add column if not exists "content_unit" varchar(255) null;`);
  }

  async down() {
    this.addSql(`alter table "pantry_item" drop column if exists "content_quantity";`);
    this.addSql(`alter table "pantry_item" drop column if exists "content_max_quantity";`);
    this.addSql(`alter table "pantry_item" drop column if exists "content_unit";`);
  }
}
