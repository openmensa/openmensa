# frozen_string_literal: true

class AddForeignKeys < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :canteens, :canteens, column: :replaced_by

    add_foreign_key :days, :canteens

    add_foreign_key :meals, :days

    add_foreign_key :feedbacks, :canteens

    add_foreign_key :favorites, :canteens, on_delete: :cascade
    add_foreign_key :favorites, :users, on_delete: :cascade

    add_foreign_key :data_proposals, :canteens, on_delete: :cascade
    add_foreign_key :data_proposals, :users, on_delete: :restrict

    add_foreign_key :parsers, :users

    add_foreign_key :sources, :parsers, on_delete: :cascade
    add_foreign_key :sources, :canteens, on_delete: :cascade

    add_foreign_key :feeds, :sources, on_delete: :cascade

    add_foreign_key :feed_fetches, :feeds, on_delete: :cascade
  end
end
