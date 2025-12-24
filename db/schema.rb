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

ActiveRecord::Schema[8.1].define(version: 2025_12_24_115844) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "canteens", id: :serial, force: :cascade do |t|
    t.string "address"
    t.boolean "availibility", default: true, null: false
    t.string "city"
    t.datetime "created_at", precision: nil
    t.string "email"
    t.datetime "last_fetched_at", precision: nil
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "openingTimes", array: true
    t.string "phone"
    t.integer "replaced_by"
    t.string "state", default: "new", null: false
    t.datetime "updated_at", precision: nil
  end

  create_table "data_proposals", id: :serial, force: :cascade do |t|
    t.string "address"
    t.string "availibility"
    t.integer "canteen_id"
    t.string "city"
    t.datetime "created_at", precision: nil
    t.string "email"
    t.float "latitude"
    t.float "longitude"
    t.string "name"
    t.string "openingTimes", array: true
    t.string "phone"
    t.string "state", default: "new", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
  end

  create_table "days", id: :serial, force: :cascade do |t|
    t.integer "canteen_id", null: false
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", precision: nil
    t.date "date", null: false
    t.datetime "updated_at", precision: nil
    t.index ["canteen_id"], name: "index_days_on_canteen_id"
    t.index ["date", "canteen_id"], name: "index_days_on_date_and_canteen_id", unique: true
  end

  create_table "favorites", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.datetime "created_at", precision: nil
    t.integer "priority"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
  end

  create_table "feed_fetches", id: :serial, force: :cascade do |t|
    t.integer "added_days"
    t.integer "added_meals"
    t.datetime "executed_at", precision: nil, null: false
    t.integer "feed_id"
    t.string "reason", null: false
    t.integer "removed_meals"
    t.string "state", null: false
    t.integer "updated_days"
    t.integer "updated_meals"
    t.string "version"
    t.index ["executed_at"], name: "index_feed_fetches_on_executed_at"
    t.index ["feed_id"], name: "index_feed_fetches_on_feed_id"
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.datetime "created_at", precision: nil
    t.text "message"
    t.string "state", default: "new", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
  end

  create_table "feeds", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "current_retry", array: true
    t.datetime "last_fetched_at", precision: nil
    t.string "name", null: false
    t.datetime "next_fetch_at", precision: nil
    t.integer "priority", default: 0, null: false
    t.integer "retry", array: true
    t.string "schedule"
    t.integer "source_id"
    t.string "source_url"
    t.datetime "updated_at", precision: nil
    t.string "url", null: false
    t.index ["source_id", "name"], name: "index_feeds_on_source_id_and_name", unique: true
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "callback_priority"
    t.text "callback_queue_name"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "enqueued_at"
    t.datetime "finished_at"
    t.datetime "jobs_finished_at"
    t.text "on_discard"
    t.text "on_finish"
    t.text "on_success"
    t.jsonb "serialized_properties"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id", null: false
    t.datetime "created_at", null: false
    t.interval "duration"
    t.text "error"
    t.text "error_backtrace", array: true
    t.integer "error_event", limit: 2
    t.datetime "finished_at"
    t.text "job_class"
    t.uuid "process_id"
    t.text "queue_name"
    t.datetime "scheduled_at"
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_type", limit: 2
    t.jsonb "state"
    t.datetime "updated_at", null: false
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "key"
    t.datetime "updated_at", null: false
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "active_job_id"
    t.uuid "batch_callback_id"
    t.uuid "batch_id"
    t.text "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "cron_at", precision: nil
    t.text "cron_key"
    t.text "error"
    t.integer "error_event", limit: 2
    t.integer "executions_count"
    t.datetime "finished_at", precision: nil
    t.boolean "is_discrete"
    t.text "job_class"
    t.text "labels", array: true
    t.datetime "locked_at"
    t.uuid "locked_by_id"
    t.datetime "performed_at", precision: nil
    t.integer "priority"
    t.text "queue_name"
    t.uuid "retried_good_job_id"
    t.datetime "scheduled_at", precision: nil
    t.jsonb "serialized_params"
    t.datetime "updated_at", null: false
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at_only", where: "(finished_at IS NOT NULL)"
    t.index ["job_class"], name: "index_good_jobs_on_job_class"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "identities", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "provider"
    t.string "secret"
    t.string "token"
    t.string "uid"
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "meals", id: :serial, force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", precision: nil
    t.integer "day_id"
    t.string "description"
    t.string "name"
    t.integer "pos"
    t.decimal "price_employee", precision: 8, scale: 2
    t.decimal "price_other", precision: 8, scale: 2
    t.decimal "price_pupil", precision: 8, scale: 2
    t.decimal "price_student", precision: 8, scale: 2
    t.datetime "updated_at", precision: nil
    t.index ["day_id"], name: "index_meals_on_day_id"
    t.index ["pos"], name: "index_meals_on_pos"
  end

  create_table "meals_notes", id: :serial, force: :cascade do |t|
    t.integer "meal_id"
    t.integer "note_id"
    t.index ["meal_id"], name: "index_meals_notes_on_meal_id"
    t.index ["note_id"], name: "index_meals_notes_on_note_id"
  end

  create_table "messages", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.datetime "created_at", precision: nil
    t.integer "messageable_id"
    t.string "messageable_type"
    t.jsonb "payload", default: {}, null: false
    t.string "priority", null: false
    t.string "type", null: false
    t.datetime "updated_at", precision: nil
    t.index ["canteen_id"], name: "index_messages_on_canteen_id"
    t.index ["messageable_type", "messageable_id"], name: "index_messages_on_messageable_type_and_messageable_id"
    t.index ["type"], name: "index_messages_on_type"
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name", null: false
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_notes_on_name", unique: true
  end

  create_table "parsers", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "index_url"
    t.string "info_url"
    t.datetime "last_report_at", precision: nil
    t.boolean "maintainer_wanted", default: false, null: false
    t.string "name", null: false
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.string "version"
    t.index ["user_id", "name"], name: "index_parsers_on_user_id_and_name", unique: true
  end

  create_table "sources", id: :serial, force: :cascade do |t|
    t.integer "canteen_id"
    t.datetime "created_at", precision: nil
    t.string "meta_url"
    t.string "name", null: false
    t.integer "parser_id"
    t.datetime "updated_at", precision: nil
    t.index ["canteen_id", "parser_id"], name: "index_sources_on_canteen_id_and_parser_id", unique: true
    t.index ["parser_id", "name"], name: "index_sources_on_parser_id_and_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: nil
    t.boolean "developer", default: false, null: false
    t.string "email"
    t.string "info_url"
    t.string "language", limit: 2
    t.datetime "last_report_at", precision: nil
    t.string "login"
    t.string "name"
    t.string "notify_email"
    t.string "public_email"
    t.string "public_name"
    t.string "time_zone"
    t.datetime "updated_at", precision: nil
    t.index ["login"], name: "index_users_on_login", unique: true
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
  add_foreign_key "identities", "users", on_delete: :cascade
  add_foreign_key "meals", "days", on_delete: :cascade
  add_foreign_key "meals_notes", "meals", on_delete: :cascade
  add_foreign_key "meals_notes", "notes", on_delete: :cascade
  add_foreign_key "messages", "canteens", on_delete: :cascade
  add_foreign_key "parsers", "users"
  add_foreign_key "sources", "canteens", on_delete: :cascade
  add_foreign_key "sources", "parsers", on_delete: :cascade
end
