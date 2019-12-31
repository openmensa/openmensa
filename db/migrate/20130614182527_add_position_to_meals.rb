# frozen_string_literal: true

class AddPositionToMeals < ActiveRecord::Migration[4.2]
  def change
    add_column :meals, :pos, :integer
  end
end
