# frozen_string_literal: true

class AddIndeciesToDayAndMealAssociations < ActiveRecord::Migration[4.2]
  def change
    add_index :days, :canteen_id
    add_index :meals, :day_id
  end
end
