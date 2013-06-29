class AddIndeciesToDayAndMealAssociations < ActiveRecord::Migration
  def change
    add_index :days, :canteen_id
    add_index :meals, :day_id
  end
end
