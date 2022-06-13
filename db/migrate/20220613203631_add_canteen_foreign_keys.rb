# frozen_string_literal: true

class AddCanteenForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :messages, :canteens, on_delete: :cascade

    remove_foreign_key :days, :canteens
    add_foreign_key :days, :canteens, on_delete: :cascade

    remove_foreign_key :meals, :days
    add_foreign_key :meals, :days, on_delete: :cascade
  end
end
