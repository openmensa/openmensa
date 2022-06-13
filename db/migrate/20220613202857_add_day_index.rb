# frozen_string_literal: true

class AddDayIndex < ActiveRecord::Migration[7.0]
  def change
    change_column_null :days, :date, false
    change_column_null :days, :canteen_id, false
    add_index :days, %i[date canteen_id], unique: true
  end
end
