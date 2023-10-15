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

ActiveRecord::Schema[7.1].define(version: 2023_10_15_110158) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "canteens", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "last_fetched_at", precision: nil
    t.float "longitude"
    t.float "latitude"
    t.string "city"
    t.string "state", default: "new", null: false
    t.string "phone"
    t.string "email"
    t.boolean "availibility", default: true
    t.string "openingTimes", array: true
    t.integer "replaced_by"
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "days", id: :serial, force: :cascade do |t|
    t.integer "canteen_id", null: false
    t.date "date", null: false
    t.boolean "closed", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["canteen_id"], name: "index_days_on_canteen_id"
    t.index ["date", "canteen_id"], name: "index_days_on_date_and_canteen_id", unique: true
  end

  create_table "favorites", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.integer "priority"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.datetime "executed_at", precision: nil, null: false
    t.index ["executed_at"], name: "index_feed_fetches_on_executed_at"
    t.index ["feed_id"], name: "index_feed_fetches_on_feed_id"
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "user_id"
    t.string "state", default: "new", null: false
    t.text "message"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "feeds", id: :serial, force: :cascade do |t|
    t.integer "source_id"
    t.integer "priority", default: 0, null: false
    t.string "name", null: false
    t.string "url", null: false
    t.string "schedule"
    t.integer "retry", array: true
    t.string "source_url"
    t.datetime "last_fetched_at", precision: nil
    t.datetime "next_fetch_at", precision: nil
    t.integer "current_retry", array: true
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["source_id", "name"], name: "index_feeds_on_source_id_and_name", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
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
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.string "secret"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "meals", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "messageable_type"
    t.integer "messageable_id"
    t.jsonb "payload", default: {}, null: false
    t.index ["canteen_id"], name: "index_messages_on_canteen_id"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id"
    t.index ["type"], name: "index_messages_on_type"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_notes_on_name", unique: true
  end

  create_table "parsers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "name", null: false
    t.string "version"
    t.string "info_url"
    t.string "index_url"
    t.boolean "maintainer_wanted", default: false, null: false
    t.datetime "last_report_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id", "name"], name: "index_parsers_on_user_id_and_name", unique: true
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.integer "parser_id"
    t.string "name", null: false
    t.string "meta_url"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["canteen_id", "parser_id"], name: "index_sources_on_canteen_id_and_parser_id", unique: true
    t.index ["parser_id", "name"], name: "index_sources_on_parser_id_and_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "time_zone"
    t.string "language", limit: 2
    t.string "login"
    t.boolean "admin"
    t.boolean "developer", default: false
    t.datetime "last_report_at", precision: nil
    t.string "public_email"
    t.string "public_name"
    t.string "notify_email"
    t.string "info_url"
  end

  add_foreign_key "canteens", "canteens", column: "replaced_by"
  add_foreign_key "data_proposals", "canteens", on_delete: :cascade
  add_foreign_key "data_proposals", "users", on_delete: :restrict
  add_foreign_key "days", "canteens", on_delete: :cascade
  add_foreign_key "favorites", "canteens", on_delete: :cascade
  add_foreign_key "favorites", "users", on_delete: :cascade
  add_foreign_key "feed_fetches", "feeds", on_delete: :cascade
  add_foreign_key "feedbacks", "canteens"
  add_foreign_key "feeds", "sources", on_delete: :cascade
  add_foreign_key "meals", "days", on_delete: :cascade
  add_foreign_key "messages", "canteens", on_delete: :cascade
  add_foreign_key "parsers", "users"
  add_foreign_key "sources", "canteens", on_delete: :cascade
  add_foreign_key "sources", "parsers", on_delete: :cascade
end
