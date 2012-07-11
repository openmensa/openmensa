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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120711070028) do

  create_table "cafeterias", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "last_fetched_at"
    t.integer  "fetch_hour"
    t.float    "longitude"
    t.float    "latitude"
  end

  add_index "cafeterias", ["user_id"], :name => "index_cafeterias_on_user_id"

  create_table "comments", :force => true do |t|
    t.string   "message"
    t.integer  "user_id"
    t.integer  "commentee_id"
    t.string   "commentee_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "comments", ["commentee_id"], :name => "index_comments_on_commentee_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "identities", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "secret"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "identities", ["user_id"], :name => "index_identities_on_user_id"

  create_table "meals", :force => true do |t|
    t.string   "name"
    t.datetime "date"
    t.string   "description"
    t.integer  "cafeteria_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "category"
  end

  add_index "meals", ["cafeteria_id"], :name => "index_meals_on_cafeteria_id"

  create_table "oauth2_access_tokens", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "refresh_token_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "oauth2_authorization_codes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "token"
    t.string   "redirect_uri"
    t.datetime "expires_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "oauth2_clients", :force => true do |t|
    t.integer  "user_id"
    t.string   "identifier"
    t.string   "secret"
    t.string   "name"
    t.string   "website"
    t.string   "redirect_uri"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "oauth2_refresh_tokens", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.string   "token"
    t.datetime "expires_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "ratings", :force => true do |t|
    t.datetime "date"
    t.integer  "value"
    t.integer  "meal_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "ratings", ["meal_id"], :name => "index_ratings_on_meal_id"
  add_index "ratings", ["user_id"], :name => "index_ratings_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "time_zone"
    t.string   "language",   :limit => 2
    t.string   "login"
    t.boolean  "admin"
  end

end
