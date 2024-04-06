# frozen_string_literal: true

class AddForeignKeys2 < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :identities, :users, on_delete: :cascade

    add_foreign_key :meals_notes, :meals, on_delete: :cascade
    add_foreign_key :meals_notes, :notes, on_delete: :cascade
  end
end
