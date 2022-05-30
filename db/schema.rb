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

ActiveRecord::Schema[7.0].define(version: 2022_05_30_122413) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "canteens", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "address", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "last_fetched_at", precision: nil
    t.float "longitude"
    t.float "latitude"
    t.string "city", limit: 255
    t.string "state", limit: 255, default: "new", null: false
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.boolean "availibility", default: true
    t.string "openingTimes", limit: 255, array: true
    t.integer "replaced_by"
  end

  create_table "data_proposals", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.string "state", limit: 255, default: "new", null: false
    t.string "name", limit: 255
    t.string "city", limit: 255
    t.string "address", limit: 255
    t.float "longitude"
    t.float "latitude"
    t.string "phone", limit: 255
    t.string "email", limit: 255
    t.string "availibility", limit: 255
    t.string "openingTimes", limit: 255, array: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "days", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.date "date"
    t.boolean "closed", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["canteen_id"], name: "index_days_on_canteen_id"
  end

  create_table "favorites", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.integer "priority"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "feed_fetches", id: :serial, force: :cascade do |t|
    t.integer "feed_id"
    t.string "state", limit: 255, null: false
    t.string "reason", limit: 255, null: false
    t.string "version", limit: 255
    t.integer "added_days"
    t.integer "updated_days"
    t.integer "added_meals"
    t.integer "updated_meals"
    t.integer "removed_meals"
    t.datetime "executed_at", precision: nil, null: false
    t.index ["executed_at"], name: "index_feed_fetches_on_executed_at"
    t.index ["feed_id"], name: "index_feed_fetches_on_feed_id"
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.string "state", limit: 255, default: "new", null: false
    t.text "message"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "feeds", id: :serial, force: :cascade do |t|
    t.integer "source_id"
    t.integer "priority", default: 0, null: false
    t.string "name", limit: 255, null: false
    t.string "url", limit: 255, null: false
    t.string "schedule", limit: 255
    t.integer "retry", array: true
    t.string "source_url", limit: 255
    t.datetime "last_fetched_at", precision: nil
    t.datetime "next_fetch_at", precision: nil
    t.integer "current_retry", array: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["source_id", "name"], name: "index_feeds_on_source_id_and_name", unique: true
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at", precision: nil
    t.datetime "performed_at", precision: nil
    t.datetime "finished_at", precision: nil
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at", precision: nil
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.string "token", limit: 255
    t.string "secret", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "meals", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "description", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "category", limit: 255
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
    t.string "type", limit: 255, null: false
    t.string "priority", limit: 255, null: false
    t.text "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "messageable_id"
    t.string "messageable_type", limit: 255
    t.index ["canteen_id"], name: "index_messages_on_canteen_id"
    t.index ["messageable_id", "messageable_type"], name: "index_messages_on_messageable_id_and_messageable_type"
    t.index ["type"], name: "index_messages_on_type"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_notes_on_name", unique: true
  end

  create_table "parsers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", limit: 255, null: false
    t.string "version", limit: 255
    t.string "info_url", limit: 255
    t.string "index_url", limit: 255
    t.boolean "maintainer_wanted", default: false, null: false
    t.datetime "last_report_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id", "name"], name: "index_parsers_on_user_id_and_name", unique: true
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "parser_id"
    t.string "name", limit: 255, null: false
    t.string "meta_url", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["canteen_id", "parser_id"], name: "index_sources_on_canteen_id_and_parser_id", unique: true
    t.index ["parser_id", "name"], name: "index_sources_on_parser_id_and_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "time_zone", limit: 255
    t.string "language", limit: 2
    t.string "login", limit: 255
    t.boolean "admin"
    t.boolean "developer", default: false
    t.datetime "last_report_at", precision: nil
    t.string "public_email", limit: 255
    t.string "public_name", limit: 255
    t.string "notify_email", limit: 255
    t.string "info_url", limit: 255
  end

  add_foreign_key "canteens", "canteens", column: "replaced_by"
  add_foreign_key "canteens", "canteens", column: "replaced_by", name: "fk_rails_canteen_replaced_by", on_delete: :restrict
  add_foreign_key "data_proposals", "canteens", on_delete: :cascade
  add_foreign_key "data_proposals", "users", on_delete: :restrict
  add_foreign_key "days", "canteens"
  add_foreign_key "days", "canteens", name: "fk_rails_days_canteen_id", on_delete: :restrict
  add_foreign_key "favorites", "canteens", on_delete: :cascade
  add_foreign_key "favorites", "users", on_delete: :cascade
  add_foreign_key "feed_fetches", "feeds", name: "fk_rails_feed_fetches_feed_id", on_delete: :cascade
  add_foreign_key "feed_fetches", "feeds", on_delete: :cascade
  add_foreign_key "feedbacks", "canteens"
  add_foreign_key "feedbacks", "canteens", name: "fk_rails_feedbacks_canteen_id", on_delete: :restrict
  add_foreign_key "feeds", "sources", name: "fk_rails_feeds_source_id", on_delete: :cascade
  add_foreign_key "feeds", "sources", on_delete: :cascade
  add_foreign_key "meals", "days"
  add_foreign_key "meals", "days", name: "fk_rails_meals_day_id", on_delete: :restrict
  add_foreign_key "parsers", "users"
  add_foreign_key "parsers", "users", name: "fk_rails_parsers_user_id", on_delete: :restrict
  add_foreign_key "sources", "canteens", name: "fk_rails_canteen_sources"
  add_foreign_key "sources", "canteens", on_delete: :cascade
  add_foreign_key "sources", "parsers", name: "fk_rails_sources_parser"
  add_foreign_key "sources", "parsers", on_delete: :cascade
end
