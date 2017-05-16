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

  create_table "canteens", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_fetched_at"
    t.float "longitude"
    t.float "latitude"
    t.string "city"
    t.string "state", default: "wanted", null: false
    t.string "phone"
    t.string "email"
    t.boolean "availibility", default: true
    t.string "openingTimes", array: true
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.string "message"
    t.integer "user_id"
    t.string "commentee_type"
    t.integer "commentee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["commentee_id"], name: "index_comments_on_commentee_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "data_proposals", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.string "state", default: "new", null: false
    t.string "name"
    t.string "city"
    t.string "address"
    t.float "longitude"
    t.float "latitude"
    t.string "phone"
    t.string "email"
    t.string "availibility"
    t.string "openingTimes", array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "days", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.date "date"
    t.boolean "closed", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["canteen_id"], name: "index_days_on_canteen_id"
  end

  create_table "favorites", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.integer "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feed_fetches", id: :serial, force: :cascade do |t|
    t.integer "feed_id"
    t.string "state", null: false
    t.string "reason", null: false
    t.string "version"
    t.integer "added_days"
    t.integer "updated_days"
    t.integer "added_meals"
    t.integer "updated_meals"
    t.integer "removed_meals"
    t.datetime "executed_at", null: false
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.string "state", default: "new", null: false
    t.text "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feeds", id: :serial, force: :cascade do |t|
    t.integer "source_id"
    t.integer "priority", default: 0, null: false
    t.string "name", null: false
    t.string "url", null: false
    t.string "schedule"
    t.integer "retry", array: true
    t.string "source_url"
    t.datetime "last_fetched_at"
    t.datetime "next_fetch_at"
    t.integer "current_retry", array: true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["source_id", "name"], name: "index_feeds_on_source_id_and_name", unique: true
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.string "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "meals", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "category"
    t.integer "day_id"
    t.decimal "price_student", precision: 8, scale: 2
    t.decimal "price_employee", precision: 8, scale: 2
    t.decimal "price_pupil", precision: 8, scale: 2
    t.decimal "price_other", precision: 8, scale: 2
    t.integer "pos"
    t.index ["day_id"], name: "index_meals_on_day_id"
    t.index ["pos"], name: "index_meals_on_pos"
  end

  create_table "meals_notes", id: :serial, force: :cascade do |t|
    t.integer "meal_id"
    t.integer "note_id"
    t.index ["meal_id"], name: "index_meals_notes_on_meal_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.string "type", null: false
    t.string "priority", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "messageable_type"
    t.integer "messageable_id"
    t.index ["canteen_id"], name: "index_messages_on_canteen_id"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id"
    t.index ["type"], name: "index_messages_on_type"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_notes_on_name", unique: true
  end

  create_table "oauth_access_grants", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.string "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", id: :serial, force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.string "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "parsers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", null: false
    t.string "version"
    t.string "info_url"
    t.string "index_url"
    t.boolean "maintainer_wanted", default: false, null: false
    t.datetime "last_report_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id", "name"], name: "index_parsers_on_user_id_and_name", unique: true
  end

  create_table "ratings", id: :serial, force: :cascade do |t|
    t.datetime "date"
    t.integer "value"
    t.integer "meal_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["meal_id"], name: "index_ratings_on_meal_id"
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "parser_id"
    t.string "name", null: false
    t.string "meta_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["canteen_id", "parser_id"], name: "index_sources_on_canteen_id_and_parser_id", unique: true
    t.index ["parser_id", "name"], name: "index_sources_on_parser_id_and_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "time_zone"
    t.string "language", limit: 2
    t.string "login"
    t.boolean "admin"
    t.boolean "developer", default: false
    t.datetime "last_report_at"
    t.string "public_email"
    t.string "public_name"
    t.string "notify_email"
    t.string "info_url"
  end

end
