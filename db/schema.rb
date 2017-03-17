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

ActiveRecord::Schema.define(version: 20170317110435) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "canteens", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_fetched_at"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "city"
    t.string   "state",           default: "wanted", null: false
    t.string   "phone"
    t.string   "email"
    t.boolean  "availibility",    default: true
    t.string   "openingTimes",                                    array: true
  end

  create_table "comments", force: :cascade do |t|
    t.string   "message"
    t.integer  "user_id"
    t.integer  "commentee_id"
    t.string   "commentee_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentee_id"], name: "index_comments_on_commentee_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "data_proposals", force: :cascade do |t|
    t.integer  "canteen_id"
    t.integer  "user_id"
    t.string   "state",        default: "new", null: false
    t.string   "name"
    t.string   "city"
    t.string   "address"
    t.float    "longitude"
    t.float    "latitude"
    t.string   "phone"
    t.string   "email"
    t.string   "availibility"
    t.string   "openingTimes",                              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "days", force: :cascade do |t|
    t.integer  "canteen_id"
    t.date     "date"
    t.boolean  "closed",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "days", ["canteen_id"], name: "index_days_on_canteen_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "canteen_id"
    t.integer  "user_id"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_fetches", force: :cascade do |t|
    t.integer  "feed_id"
    t.string   "state",         null: false
    t.string   "reason",        null: false
    t.string   "version"
    t.integer  "added_days"
    t.integer  "updated_days"
    t.integer  "added_meals"
    t.integer  "updated_meals"
    t.integer  "removed_meals"
    t.datetime "executed_at",   null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "canteen_id"
    t.integer  "user_id"
    t.string   "state",      default: "new", null: false
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", force: :cascade do |t|
    t.integer  "source_id"
    t.integer  "priority",        default: 0, null: false
    t.string   "name",                        null: false
    t.string   "url",                         null: false
    t.string   "schedule"
    t.integer  "retry",                                    array: true
    t.string   "source_url"
    t.datetime "last_fetched_at"
    t.datetime "next_fetch_at"
    t.integer  "current_retry",                            array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feeds", ["source_id", "name"], name: "index_feeds_on_source_id_and_name", unique: true, using: :btree

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "meals", force: :cascade do |t|
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

  create_table "meals_notes", force: :cascade do |t|
    t.integer "meal_id"
    t.integer "note_id"
  end

  add_index "meals_notes", ["meal_id"], name: "index_meals_notes_on_meal_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "canteen_id"
    t.string   "type",             null: false
    t.string   "priority",         null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "messageable_id"
    t.string   "messageable_type"
  end

  add_index "messages", ["canteen_id"], name: "index_messages_on_canteen_id", using: :btree
  add_index "messages", ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id", using: :btree
  add_index "messages", ["type"], name: "index_messages_on_type", using: :btree

  create_table "notes", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["name"], name: "index_notes_on_name", unique: true, using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
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

  create_table "oauth_access_tokens", force: :cascade do |t|
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

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.string   "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "parsers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",                              null: false
    t.string   "version"
    t.string   "info_url"
    t.string   "index_url"
    t.boolean  "maintainer_wanted", default: false, null: false
    t.datetime "last_report_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parsers", ["user_id", "name"], name: "index_parsers_on_user_id_and_name", unique: true, using: :btree

  create_table "ratings", force: :cascade do |t|
    t.datetime "date"
    t.integer  "value"
    t.integer  "meal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["meal_id"], name: "index_ratings_on_meal_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "sources", force: :cascade do |t|
    t.integer  "canteen_id"
    t.integer  "parser_id"
    t.string   "name",       null: false
    t.string   "meta_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sources", ["canteen_id", "parser_id"], name: "index_sources_on_canteen_id_and_parser_id", unique: true, using: :btree
  add_index "sources", ["parser_id", "name"], name: "index_sources_on_parser_id_and_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
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
    t.string   "public_email"
    t.string   "public_name"
    t.string   "notify_email"
    t.string   "info_url"
  end

end
