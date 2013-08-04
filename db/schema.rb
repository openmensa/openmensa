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

ActiveRecord::Schema.define(version: 20130804181349) do

  create_table "canteens", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_fetched_at"
    t.integer  "fetch_hour"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "today_url"
    t.string   "city"
  end

  add_index "canteens", ["user_id"], name: "index_canteens_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.string   "message"
    t.integer  "user_id"
    t.integer  "commentee_id"
    t.string   "commentee_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentee_id"], name: "index_comments_on_commentee_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "days", force: true do |t|
    t.integer  "canteen_id"
    t.date     "date"
    t.boolean  "closed",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "days", ["canteen_id"], name: "index_days_on_canteen_id", using: :btree

  create_table "favorites", force: true do |t|
    t.integer  "canteen_id"
    t.integer  "user_id"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "meals", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category"
    t.integer  "day_id"
    t.decimal  "price_student",  precision: 8, scale: 2
    t.decimal  "price_employee", precision: 8, scale: 2
    t.decimal  "price_pupil",    precision: 8, scale: 2
    t.decimal  "price_other",    precision: 8, scale: 2
    t.integer  "pos"
  end

  add_index "meals", ["day_id"], name: "index_meals_on_day_id", using: :btree
  add_index "meals", ["pos"], name: "index_meals_on_pos", using: :btree

  create_table "meals_notes", force: true do |t|
    t.integer "meal_id"
    t.integer "note_id"
  end

  add_index "meals_notes", ["meal_id"], name: "index_meals_notes_on_meal_id", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "canteen_id"
    t.string   "type",       null: false
    t.string   "priority",   null: false
    t.text     "data",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "messages", ["canteen_id"], name: "index_messages_on_canteen_id", using: :btree
  add_index "messages", ["type"], name: "index_messages_on_type", using: :btree

  create_table "notes", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["name"], name: "index_notes_on_name", unique: true, using: :btree

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.string   "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: true do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.string   "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "ratings", force: true do |t|
    t.datetime "date"
    t.integer  "value"
    t.integer  "meal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["meal_id"], name: "index_ratings_on_meal_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "time_zone"
    t.string   "language",       limit: 2
    t.string   "login"
    t.boolean  "admin"
    t.boolean  "developer",                default: false
    t.datetime "last_report_at"
  end

end
