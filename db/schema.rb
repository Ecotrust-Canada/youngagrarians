# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160909182955) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "email",           null: false
    t.string   "password_digest", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "category_location_tags", force: :cascade do |t|
    t.integer  "category_id", null: false
    t.integer  "location_id", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "listing_comments", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "location_id",                 null: false
    t.text     "body"
    t.boolean  "is_spam",     default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "location_fields", force: :cascade do |t|
    t.string  "comment"
    t.integer "boolean_value", null: false
    t.integer "field_id",      null: false
    t.integer "location_id",   null: false
    t.text    "serial_data"
  end

  create_table "locations", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "gmaps"
    t.string   "street_address", limit: 255
    t.string   "name",           limit: 255
    t.text     "content"
    t.string   "bioregion",      limit: 255
    t.string   "phone",          limit: 255
    t.string   "url",            limit: 255
    t.string   "fb_url",         limit: 255
    t.string   "twitter_url",    limit: 255
    t.text     "description"
    t.integer  "is_approved",                default: 0
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "category_id"
    t.string   "resource_type",  limit: 255
    t.string   "email",          limit: 255
    t.string   "postal",         limit: 255
    t.date     "show_until"
    t.string   "city",           limit: 255
    t.string   "country",        limit: 255
    t.string   "province",       limit: 255
    t.integer  "account_id"
    t.boolean  "public_contact",             default: true, null: false
    t.tsvector "search"
    t.string   "land_size"
    t.string   "post_id"
    t.string   "post2_id"
  end

  add_index "locations", ["is_approved"], name: "index_locations_on_is_approved", using: :btree
  add_index "locations", ["show_until"], name: "index_locations_on_show_until", using: :btree

  create_table "locations_subcategories", id: false, force: :cascade do |t|
    t.integer "location_id"
    t.integer "subcategory_id"
  end

  create_table "nested_categories", force: :cascade do |t|
    t.integer  "parent_category_id"
    t.string   "name",               null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "rails_admin_histories", force: :cascade do |t|
    t.text     "message"
    t.string   "username",   limit: 255
    t.integer  "item"
    t.string   "table",      limit: 255
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", unique: true, using: :btree

  create_table "subcategories", force: :cascade do |t|
    t.integer  "category_id"
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "username",               limit: 255
    t.string   "email",                  limit: 255
    t.string   "password_salt",          limit: 255
    t.string   "encrypted_password",     limit: 255
    t.string   "password_reset_key",     limit: 255
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", using: :btree

end
