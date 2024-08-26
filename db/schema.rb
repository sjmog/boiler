# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_08_24_201007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "product_source_tags", force: :cascade do |t|
    t.bigint "product_source_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_source_id"], name: "index_product_source_tags_on_product_source_id"
    t.index ["tag_id"], name: "index_product_source_tags_on_tag_id"
  end

  create_table "product_sources", force: :cascade do |t|
    t.string "source"
    t.string "name"
    t.string "url"
    t.text "description"
    t.json "meta"
    t.datetime "sourced_at"
    t.bigint "product_id", null: false
    t.boolean "validated", default: false
    t.datetime "validated_at"
    t.bigint "validated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "original_data"
    t.index ["product_id"], name: "index_product_sources_on_product_id"
    t.index ["validated_by_id"], name: "index_product_sources_on_validated_by_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "url"
    t.integer "buzz"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "validated", default: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_products_on_deleted_at"
  end

  create_table "scraper_log_entries", force: :cascade do |t|
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scraper_statuses", force: :cascade do |t|
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scraping_records", force: :cascade do |t|
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.integer "status", default: 0, null: false
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_type", "source_id"], name: "index_scraping_records_on_source"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name", null: false
    t.integer "source_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "source_type"], name: "index_sources_on_name_and_source_type", unique: true
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "product_source_tags", "product_sources"
  add_foreign_key "product_source_tags", "tags"
  add_foreign_key "product_sources", "products"
  add_foreign_key "product_sources", "users", column: "validated_by_id"
end
