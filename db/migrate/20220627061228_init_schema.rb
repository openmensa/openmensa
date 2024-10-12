# frozen_string_literal: true

class InitSchema < ActiveRecord::Migration[7.1] # rubocop:disable Metrics/ClassLength
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "pgcrypto"
    enable_extension "plpgsql"

    create_table "canteens", id: :serial do |t|
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
      t.boolean "availibility", default: true # rubocop:disable Rails/ThreeStateBooleanColumn
      t.string "openingTimes", array: true
      t.integer "replaced_by"
    end

    create_table "data_proposals", id: :serial do |t|
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

    create_table "days", id: :serial do |t|
      t.integer "canteen_id", null: false
      t.date "date", null: false
      t.boolean "closed", default: false # rubocop:disable Rails/ThreeStateBooleanColumn
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index ["canteen_id"], name: "index_days_on_canteen_id"
      t.index %w[date canteen_id], name: "index_days_on_date_and_canteen_id", unique: true
    end

    create_table "favorites", id: :serial do |t|
      t.integer "canteen_id"
      t.integer "user_id"
      t.integer "priority"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
    end

    create_table "feed_fetches", id: :serial do |t|
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

    create_table "feedbacks", id: :serial do |t|
      t.integer "canteen_id"
      t.integer "user_id"
      t.string "state", default: "new", null: false
      t.text "message"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
    end

    create_table "feeds", id: :serial do |t|
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
      t.index %w[source_id name], name: "index_feeds_on_source_id_and_name", unique: true
    end

    create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.jsonb "state"
    end

    create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" } do |t|
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
      t.index %w[active_job_id created_at], name: "index_good_jobs_on_active_job_id_and_created_at"
      t.index ["active_job_id"], name: "index_good_jobs_on_active_job_id"
      t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
      t.index %w[cron_key created_at], name: "index_good_jobs_on_cron_key_and_created_at"
      t.index %w[cron_key cron_at], name: "index_good_jobs_on_cron_key_and_cron_at", unique: true
      t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
      t.index %w[queue_name scheduled_at], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
      t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
    end

    create_table "identities", id: :serial do |t|
      t.integer "user_id"
      t.string "provider"
      t.string "uid"
      t.string "token"
      t.string "secret"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index ["user_id"], name: "index_identities_on_user_id"
    end

    create_table "meals", id: :serial do |t|
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

    create_table "meals_notes", id: :serial do |t|
      t.integer "meal_id"
      t.integer "note_id"
      t.index ["meal_id"], name: "index_meals_notes_on_meal_id"
    end

    create_table "messages", id: :serial do |t|
      t.integer "canteen_id"
      t.string "type", null: false
      t.string "priority", null: false
      t.text "data"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.string "messageable_type"
      t.integer "messageable_id"
      t.index ["canteen_id"], name: "index_messages_on_canteen_id"
      t.index %w[messageable_type messageable_id], name: "index_messages_on_messageable_type_and_messageable_id"
      t.index ["type"], name: "index_messages_on_type"
    end

    create_table "notes", id: :serial do |t|
      t.string "name", null: false
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index ["name"], name: "index_notes_on_name", unique: true
    end

    create_table "parsers", id: :serial do |t|
      t.integer "user_id"
      t.string "name", null: false
      t.string "version"
      t.string "info_url"
      t.string "index_url"
      t.boolean "maintainer_wanted", default: false, null: false
      t.datetime "last_report_at", precision: nil
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index %w[user_id name], name: "index_parsers_on_user_id_and_name", unique: true
    end

    create_table "sources", id: :serial do |t|
      t.integer "canteen_id"
      t.integer "parser_id"
      t.string "name", null: false
      t.string "meta_url"
      t.datetime "created_at", precision: nil
      t.datetime "updated_at", precision: nil
      t.index %w[canteen_id parser_id], name: "index_sources_on_canteen_id_and_parser_id", unique: true
      t.index %w[parser_id name], name: "index_sources_on_parser_id_and_name", unique: true
    end

    create_table "users", id: :serial do |t|
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

  def down
    raise ActiveRecord::IrreversibleMigration.new("The initial migration is not revertable")
  end
end
